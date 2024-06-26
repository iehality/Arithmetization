import Arithmetization.ISigmaOne.Metamath.Language
import Arithmetization.ISigmaOne.HFS

noncomputable section

namespace LO.Arith

open FirstOrder FirstOrder.Arith

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Arith.Language V} {pL : LDef} [Arith.Language.Defined L pL]

section term

def qqBvar (z : V) : V := ⟪0, z⟫ + 1

def qqFvar (x : V) : V := ⟪1, x⟫ + 1

def qqFunc (k f v : V) : V := ⟪2, k, f, v⟫ + 1

scoped prefix:max "^#" => qqBvar

scoped prefix:max "^&" => qqFvar

scoped prefix:max "^func " => qqFunc

@[simp] lemma var_lt_qqBvar (z : V) : z < ^#z := lt_succ_iff_le.mpr <| le_pair_right 0 z

@[simp] lemma var_lt_qqFvar (x : V) : x < ^&x := lt_succ_iff_le.mpr <| le_pair_right 1 x

@[simp] lemma arity_lt_qqFunc (k f v : V) : k < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_right 2 k) <| pair_le_pair_right 2 <| le_pair_left k ⟪f, v⟫

@[simp] lemma func_lt_qqFunc (k f v : V) : f < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_left f v) <| le_trans (le_pair_right k ⟪f, v⟫) <| le_pair_right 2 ⟪k, ⟪f, v⟫⟫

@[simp] lemma terms_lt_qqFunc (k f v : V) : v < ^func k f v :=
  le_iff_lt_succ.mp <| le_trans (le_pair_right f v) <| le_trans (le_pair_right k ⟪f, v⟫) <| le_pair_right 2 ⟪k, ⟪f, v⟫⟫

lemma lt_qqFunc_of_mem {i b k f v : V} (hi : ⟪i, b⟫ ∈ v) : b < ^func k f v :=
  _root_.lt_trans (lt_of_mem_rng hi) (terms_lt_qqFunc k f v)

@[simp] lemma qqBvar_inj {z z' : V} : ^#z = ^#z' ↔ z = z' := by simp [qqBvar]

@[simp] lemma qqFvar_inj {x x' : V} : ^&x = ^&x' ↔ x = x' := by simp [qqFvar]

@[simp] lemma qqFunc_inj {k f v k' f' v' : V} : ^func k f v = ^func k' f' v' ↔ k = k' ∧ f = f' ∧ v = v' := by simp [qqFunc]

def _root_.LO.FirstOrder.Arith.qqBvarDef : 𝚺₀-Semisentence 2 := .mkSigma “t z | ∃ t' < t, !pairDef t' 0 z ∧ t = t' + 1” (by simp)

lemma qqBvar_defined : 𝚺₀-Function₁ (qqBvar : V → V) via qqBvarDef := by
  intro v; simp [qqBvarDef]
  constructor
  · intro h; exact ⟨⟪0, v 1⟫, by simp [qqBvar, h], rfl, h⟩
  · rintro ⟨x, _, rfl, h⟩; exact h

@[simp] lemma eval_qqBvarDef (v) :
    Semiformula.Evalbm V v qqBvarDef.val ↔ v 0 = ^#(v 1) := qqBvar_defined.df.iff v

def _root_.LO.FirstOrder.Arith.qqFvarDef : 𝚺₀-Semisentence 2 := .mkSigma “t x | ∃ t' < t, !pairDef t' 1 x ∧ t = t' + 1” (by simp)

lemma qqFvar_defined : 𝚺₀-Function₁ (qqFvar : V → V) via qqFvarDef := by
  intro v; simp [qqFvarDef]
  constructor
  · intro h; exact ⟨⟪1, v 1⟫, by simp [qqFvar, h], rfl, h⟩
  · rintro ⟨x, _, rfl, h⟩; exact h

@[simp] lemma eval_qqFvarDef (v) :
    Semiformula.Evalbm V v qqFvarDef.val ↔ v 0 = ^&(v 1) := qqFvar_defined.df.iff v

private lemma qqFunc_graph {x k f v : V} :
    x = ^func k f v ↔ ∃ fv < x, fv = ⟪f, v⟫ ∧ ∃ kfv < x, kfv = ⟪k, fv⟫ ∧ ∃ x' < x, x' = ⟪2, kfv⟫ ∧ x = x' + 1 :=
  ⟨by rintro rfl
      exact ⟨⟪f, v⟫, lt_succ_iff_le.mpr <| le_trans (le_pair_right _ _) (le_pair_right _ _), rfl,
        ⟪k, f, v⟫, lt_succ_iff_le.mpr <| by simp, rfl,
        ⟪2, k, f, v⟫, by simp [qqFunc], rfl, rfl⟩,
   by rintro ⟨_, _, rfl, _, _, rfl, _, _, rfl, rfl⟩; rfl⟩

def _root_.LO.FirstOrder.Arith.qqFuncDef : 𝚺₀-Semisentence 4 := .mkSigma
  “x k f v | ∃ fv < x, !pairDef fv f v ∧ ∃ kfv < x, !pairDef kfv k fv ∧ ∃ x' < x, !pairDef x' 2 kfv ∧ x = x' + 1” (by simp)

lemma qqFunc_defined : 𝚺₀-Function₃ (qqFunc : V → V → V → V) via qqFuncDef := by
  intro v; simp [qqFuncDef, qqFunc_graph]

@[simp] lemma eval_qqFuncDef (v) :
    Semiformula.Evalbm V v qqFuncDef.val ↔ v 0 = ^func (v 1) (v 2) (v 3) := qqFunc_defined.df.iff v

namespace FormalizedTerm

variable (L)

def Phi (n : V) (C : Set V) (t : V) : Prop :=
  (∃ z < n, t = ^#z) ∨ (∃ x, t = ^&x) ∨ (∃ k f v : V, L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i u, ⟪i, u⟫ ∈ v → u ∈ C) ∧ t = ^func k f v)

private lemma phi_iff (n : V) (C : V) (t : V) :
    Phi L n {x | x ∈ C} t ↔
    (∃ z < n, t = ^#z) ∨
    (∃ x < t, t = ^&x) ∨
    (∃ k < t, ∃ f < t, ∃ v < t, L.Func k f ∧ Seq v ∧ k = lh v ∧ (∀ i < v, ∀ u < v, ⟪i, u⟫ ∈ v → u ∈ C) ∧ t = ^func k f v) where
  mp := by
    rintro (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, Sv, hk, hv, rfl⟩)
    · left; exact ⟨z, hz, rfl⟩
    · right; left
      exact ⟨x, lt_succ_iff_le.mpr <| by simp, rfl⟩
    · right; right
      exact ⟨k, by simp, f, by simp, v, by simp, hkf, Sv, hk, fun i _ u _ hi ↦ hv i u hi, rfl⟩
  mpr := by
    unfold Phi
    rintro (⟨z, hz, rfl⟩ | ⟨x, _, rfl⟩ | ⟨k, _, f, _, v, _, hkf, Sv, hk, hv, rfl⟩)
    · left; exact ⟨z, hz, rfl⟩
    · right; left; exact ⟨x, rfl⟩
    · right; right; exact ⟨k, f, v, hkf, Sv, hk,
        fun i u hi ↦ hv i (lt_of_mem_dom hi) u (lt_of_mem_rng hi) hi, rfl⟩

def formula (pL : LDef) : Fixpoint.Blueprint 1 := ⟨.ofZero (.mkSigma
  “t C n |
    (∃ z < n, !qqBvarDef t z) ∨
    (∃ x < t, !qqFvarDef t x) ∨
    (∃ k < t, ∃ f < t, ∃ v < t, !pL.func k f ∧ :Seq v ∧ !lhDef k v ∧ (∀ i < v, ∀ u < v, i ~[v] u → u ∈ C) ∧ !qqFuncDef t k f v)”
  (by simp)) _⟩

def construction : Fixpoint.Construction V (formula pL) where
  Φ := fun n ↦ Phi L (n 0)
  defined := .of_zero <| by intro v; simp [phi_iff, Language.Defined.eval_func (L := L) (pL := pL)]
  monotone := by
    rintro C C' hC v x (h | h | ⟨k, f, v, hkf, Sv, hk, h, rfl⟩)
    · exact Or.inl h
    · exact Or.inr <| Or.inl h
    · exact Or.inr <| Or.inr ⟨k, f, v, hkf, Sv, hk, fun i u hi ↦ hC (h i u hi), rfl⟩

instance : (construction L).StrongFinite V where
  strong_finite := by
    rintro C v x (h | h | ⟨k, f, v, hkf, Sv, hk, h, rfl⟩)
    · exact Or.inl h
    · exact Or.inr <| Or.inl h
    · exact Or.inr <| Or.inr ⟨k, f, v, hkf, Sv, hk, fun i u hi ↦
        ⟨h i u hi, _root_.lt_trans (lt_of_mem_rng hi) (by simp)⟩, rfl⟩

end FormalizedTerm

open FormalizedTerm

variable (L)

def Language.IsSemiterm (n : V) : V → Prop := (construction L).Fixpoint ![n]

def _root_.LO.FirstOrder.Arith.LDef.isSemitermDef (pL : LDef) : 𝚫₁-Semisentence 2 := (formula pL).fixpointDefΔ₁.rew (Rew.substs ![#1, #0])

lemma isSemiterm_defined : 𝚫₁-Relation L.IsSemiterm via pL.isSemitermDef :=
  ⟨HSemiformula.ProperOn.rew (construction L).fixpoint_definedΔ₁.proper _,
   by intro v; simp [LDef.isSemitermDef, (construction L).eval_fixpointDefΔ₁]; rfl⟩

@[simp] lemma eval_isSemitermDef (v) :
    Semiformula.Evalbm V v pL.isSemitermDef.val ↔ L.IsSemiterm (v 0) (v 1) := (isSemiterm_defined L).df.iff v

instance isSemitermDef_definable : 𝚫₁-Relation (L.IsSemiterm) := Defined.to_definable _ (isSemiterm_defined L)

@[simp, definability] instance isSemitermDef_definable' (Γ) : (Γ, m + 1)-Relation (L.IsSemiterm) :=
  .of_deltaOne (isSemitermDef_definable L) _ _

def Language.TermSeq (n m w : V) : Prop := Seq w ∧ n = lh w ∧ ∀ i u, ⟪i, u⟫ ∈ w → L.IsSemiterm m u

variable {L}

protected lemma Language.TermSeq.seq {n m w : V} (h : L.TermSeq n m w) : Seq w := h.1

protected lemma Language.TermSeq.lh {n m w : V} (h : L.TermSeq n m w) : n = lh w := h.2.1

lemma Language.TermSeq.prop {n m w : V} (h : L.TermSeq n m w) : ∀ i u, ⟪i, u⟫ ∈ w → L.IsSemiterm m u := h.2.2

section

private lemma termSeq_iff (n m w : V) :
    L.TermSeq n m w ↔ Seq w ∧ n = lh w ∧ ∀ i < w, ∀ u < w, ⟪i, u⟫ ∈ w → L.IsSemiterm m u :=
  ⟨fun h ↦ ⟨Language.TermSeq.seq h, Language.TermSeq.lh h, fun i _ u _ hi ↦ Language.TermSeq.prop h i u hi⟩,
   by rintro ⟨Sw, hn, h⟩
      exact ⟨by simpa using Sw, by simpa using hn,
        fun i u hi ↦ by simpa using h i (lt_of_mem_dom <| by simpa using hi) u (lt_of_mem_rng <| by simpa using hi) (by simpa using hi)⟩⟩

def _root_.LO.FirstOrder.Arith.LDef.termSeqDef (pL : LDef) : 𝚫₁-Semisentence 3 := .mkDelta
  (.mkSigma
    “n m w | :Seq w ∧ !lhDef n w ∧ ∀ i < w, ∀ u < w, i ~[w] u → !pL.isSemitermDef.sigma m u”
    (by simp))
  (.mkPi
    “n m w | :Seq w ∧ !lhDef n w ∧ ∀ i < w, ∀ u < w, i ~[w] u → !pL.isSemitermDef.pi m u”
    (by simp))

variable (L)

lemma termSeq_defined : 𝚫₁-Relation₃ (L.TermSeq) via pL.termSeqDef :=
  ⟨by intro v; simp [LDef.termSeqDef, HSemiformula.val_sigma, eval_isSemitermDef L, (isSemiterm_defined L).proper.iff'],
   by intro v; simp [LDef.termSeqDef, HSemiformula.val_sigma, eval_isSemitermDef L, termSeq_iff]⟩

@[simp] lemma eval_termSeq (v) :
    Semiformula.Evalbm V v pL.termSeqDef.val ↔ L.TermSeq (v 0) (v 1) (v 2) := (termSeq_defined L).df.iff v

instance termSeq_definable : 𝚫₁-Relation₃ (L.TermSeq) := Defined.to_definable _ (termSeq_defined L)

@[simp, definability] instance termSeq_definable' (Γ) : (Γ, m + 1)-Relation₃ (L.TermSeq) :=
  .of_deltaOne (termSeq_definable L) _ _

end

variable {n : V}

local prefix:80 "𝐓ⁿ " => L.IsSemiterm n

lemma Language.IsSemiterm.case_iff {t : V} :
    𝐓ⁿ t ↔
    (∃ z < n, t = ^#z) ∨
    (∃ x, t = ^&x) ∨
    (∃ k f v : V, L.Func k f ∧ L.TermSeq k n v ∧ t = ^func k f v) := by
  simpa [construction, Phi, TermSeq, and_assoc] using (construction L).case

alias ⟨Language.IsSemiterm.case, Language.IsSemiterm.mk⟩ := Language.IsSemiterm.case_iff

@[simp] lemma IsSemiterm.bvar {z : V} : 𝐓ⁿ ^#z ↔ z < n :=
  ⟨by intro h
      rcases h.case with (⟨z', hz, hzz'⟩ | ⟨x, h⟩ | ⟨k, f, v, _, _, h⟩)
      · rcases (show z = z' from by simpa using hzz'); exact hz
      · simp [qqBvar, qqFvar] at h
      · simp [qqBvar, qqFunc] at h,
    fun hz ↦ Language.IsSemiterm.mk (Or.inl ⟨z, hz, rfl⟩)⟩

@[simp] lemma IsSemiterm.fvar (x : V) : 𝐓ⁿ ^&x := Language.IsSemiterm.mk (Or.inr <| Or.inl ⟨x, rfl⟩)

@[simp] lemma IsSemiterm.func_iff {k f v : V} :
    𝐓ⁿ (^func k f v) ↔ L.Func k f ∧ L.TermSeq k n v :=
  ⟨by intro h
      rcases h.case with (⟨_, _, h⟩ | ⟨x, h⟩ | ⟨k', f', v', hkf, ⟨Sv, hk, hv⟩, h⟩)
      · simp [qqFunc, qqBvar] at h
      · simp [qqFunc, qqFvar] at h
      · rcases (show k = k' ∧ f = f' ∧ v = v' by simpa [qqFunc] using h) with ⟨rfl, rfl, rfl⟩
        exact ⟨hkf, Sv, hk, hv⟩,
   by rintro ⟨hkf, Sv, hk, hv⟩; exact Language.IsSemiterm.mk (Or.inr <| Or.inr ⟨k, f, v, hkf, ⟨Sv, hk, hv⟩, rfl⟩)⟩

lemma IsSemiterm.func {k f v : V} (hkf : L.Func k f) (hv : L.TermSeq k n v) :
    𝐓ⁿ (^func k f v) := IsSemiterm.func_iff.mpr ⟨hkf, hv⟩

lemma IsSemiterm.induction (Γ) {P : V → Prop} (hP : (Γ, 1)-Predicate P)
    (hbvar : ∀ z < n, P (^#z)) (hfvar : ∀ x, P (^&x))
    (hfunc : ∀ k f v, L.Func k f → L.TermSeq k n v → (∀ i u, ⟪i, u⟫ ∈ v → P u) → P (^func k f v)) :
    ∀ t, 𝐓ⁿ t → P t :=
  (construction L).induction (v := ![n]) hP (by
    rintro C hC x (⟨z, hz, rfl⟩ | ⟨x, rfl⟩ | ⟨k, f, v, hkf, Sv, hk, h, rfl⟩)
    · exact hbvar z hz
    · exact hfvar x
    · exact hfunc k f v hkf ⟨Sv, hk, fun i u hi ↦ hC u (h i u hi) |>.1⟩ (fun i u hi ↦ hC u (h i u hi) |>.2))

end term

section termSubst

namespace FormalizedTermSubst

variable (L)

def Phi (n m w : V) (C : Set V) (p : V) : Prop :=
  L.IsSemiterm n (π₁ p) ∧ L.IsSemiterm m (π₂ p) ∧
  ( (∃ z < n, π₁ p = ^#z ∧ ⟪z, π₂ p⟫ ∈ w) ∨
    (∃ x, π₁ p = ^&x ∧ π₂ p = ^&x) ∨
    (∃ k f v v', π₁ p = ^func k f v ∧ π₂ p = ^func k f v' ∧ ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → ⟪u, u'⟫ ∈ C) )

private lemma phi_iff (n m w C p : V) :
    Phi L n m w {x | x ∈ C} p ↔
    ∃ t₁ ≤ p, ∃ t₂ ≤ p, p = ⟪t₁, t₂⟫ ∧ L.IsSemiterm n t₁ ∧ L.IsSemiterm m t₂ ∧
    ( (∃ z < n, t₁ = ^#z ∧ ⟪z, t₂⟫ ∈ w) ∨
      (∃ x < t₁, t₁ = ^&x ∧ t₂ = ^&x) ∨
      (∃ k < t₁, ∃ f < t₁, ∃ v < t₁, ∃ v' < t₂, t₁ = ^func k f v ∧ t₂ = ^func k f v' ∧
        (∀ i < v, ∀ u < v, ∀ u' < v', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → ⟪u, u'⟫ ∈ C)) ) := by
  constructor
  ·{intro ⟨hp₁, hp₂, h⟩
    refine ⟨π₁ p, by simp, π₂ p, by simp, by simp, hp₁, hp₂, ?_⟩
    rcases h with (⟨z, hz, h₁, h⟩ | ⟨x, h₁, h₂⟩ | ⟨k, f, v, v', h₁, h₂, h⟩)
    · left; exact ⟨z, hz, h₁, h⟩
    · right; left; exact ⟨x, by simp [h₁], h₁, h₂⟩
    · right; right
      exact ⟨k, by simp [h₁], f, by simp [h₁], v, by simp [h₁], v', by simp [h₂],
        h₁, h₂, fun i _ u _ u' _ hi hi' ↦ h i u u' hi hi'⟩}
  · rintro ⟨t₁, _, t₂, _, rfl, ht₁, ht₂, h⟩
    refine ⟨by simpa using ht₁, by simpa using ht₂, ?_⟩
    rcases h with (⟨z, hz, rfl, h⟩ | ⟨x, _, rfl, rfl⟩ | ⟨k, _, f, _, v, _, v', _, rfl, rfl, h⟩)
    · left; exact ⟨z, hz, by simp [h]⟩
    · right; left; exact ⟨x, by simp⟩
    · right; right
      exact ⟨k, f, v, v', by simp, by simp, fun i u u' hi hi' ↦
        h i (lt_of_mem_dom hi) u (lt_of_mem_rng hi) u' (lt_of_mem_rng hi') hi hi'⟩

def formulaAux : Semisentence ℒₒᵣ 7 := “t₁ t₂ p C n m w |
  (∃ z < n, !qqBvarDef t₁ z ∧ z ~[w] t₂) ∨
  (∃ x < t₁, !qqFvarDef t₁ x ∧ !qqFvarDef t₂ x) ∨
  (∃ k < t₁, ∃ f < t₁, ∃ v < t₁, ∃ v' < t₂, !qqFuncDef t₁ k f v ∧ !qqFuncDef t₂ k f v' ∧
  (∀ i < v, ∀ u < v, ∀ u' < v', i ~[v] u → i ~[v'] u' → u ~[C] u'))”

def formula (pL : LDef) : Fixpoint.Blueprint 3 := ⟨.mkDelta
  (.mkSigma
    “p C n m w |
      ∃ t₁ <⁺ p, ∃ t₂ <⁺ p, !pairDef p t₁ t₂ ∧ !pL.isSemitermDef.sigma n t₁ ∧ !pL.isSemitermDef.sigma m t₂ ∧
      !formulaAux t₁ t₂ p C n m w”
    (by simp [formulaAux]))
  (.mkPi
    “p C n m w |
      ∃ t₁ <⁺ p, ∃ t₂ <⁺ p, !pairDef p t₁ t₂ ∧ !pL.isSemitermDef.pi n t₁ ∧ !pL.isSemitermDef.pi m t₂ ∧
      !formulaAux t₁ t₂ p C n m w”
    (by simp [formulaAux]))⟩

def construction : Fixpoint.Construction V (formula pL) where
  Φ := fun v ↦ Phi L (v 0) (v 1) (v 2)
  defined := ⟨fun v ↦
    by simp [formula, HSemiformula.val_sigma, eval_isSemitermDef L, (isSemiterm_defined L).proper.iff'],
  fun v ↦ by simpa [formula, HSemiformula.val_sigma, eval_isSemitermDef L, formulaAux] using phi_iff _ _ _ _ _ _⟩
  monotone := by
    rintro C C' hC v p ⟨ht₁, ht₂, (h | h | ⟨k, f, v, v', h₁, h₂, h⟩)⟩
    · exact ⟨ht₁, ht₂, Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inr ⟨k, f, v, v', h₁, h₂, fun i u u' hi hi' ↦ hC (h i u u' hi hi')⟩⟩

instance : (construction L).StrongFinite V where
  strong_finite := by
    rintro C v p ⟨ht₁, ht₂, (h | h | ⟨k, f, v, v', h₁, h₂, h⟩)⟩
    · exact ⟨ht₁, ht₂, Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inr ⟨k, f, v, v', h₁, h₂, fun i u u' hi hi' ↦ ⟨h i u u' hi hi', by
      have : ⟪u, u'⟫ < ⟪π₁ p, π₂ p⟫ := pair_lt_pair (by simpa [h₁] using lt_qqFunc_of_mem hi) (by simpa [h₂] using lt_qqFunc_of_mem hi')
      simpa using this⟩⟩⟩

def Subst (n m w : V) : V → Prop := (construction L).Fixpoint ![n, m, w]

def _root_.LO.FirstOrder.Arith.LDef.substDef (pL : LDef) : 𝚫₁-Semisentence 4 :=
  (formula pL).fixpointDefΔ₁.rew <| Rew.substs ![#3, #0, #1, #2]

lemma subst_defined : 𝚫₁-Relation₄ (Subst L) via pL.substDef :=
  ⟨HSemiformula.ProperOn.rew (construction L).fixpoint_definedΔ₁.proper _,
   by intro v; simp [LDef.substDef, (construction L).eval_fixpointDefΔ₁, Subst]⟩

@[simp] lemma eval_substDef (v) :
    Semiformula.Evalbm V v pL.substDef.val ↔ Subst L (v 0) (v 1) (v 2) (v 3) := (subst_defined L).df.iff v

instance subst_definable : 𝚫₁-Relation₄ (Subst L) := Defined.to_definable _ (subst_defined L)

@[simp, definability] instance subst_definable' (Γ) : (Γ, m + 1)-Relation₄ (Subst L) :=
  .of_deltaOne (subst_definable L) _ _

variable {L}

lemma Subst.case_iff {n m w p : V} :
    Subst L n m w p ↔
    L.IsSemiterm n (π₁ p) ∧ L.IsSemiterm m (π₂ p) ∧
    ( (∃ z < n, π₁ p = ^#z ∧ ⟪z, π₂ p⟫ ∈ w) ∨
      (∃ x, π₁ p = ^&x ∧ π₂ p = ^&x) ∨
      (∃ k f v v', π₁ p = ^func k f v ∧ π₂ p = ^func k f v' ∧ ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → Subst L n m w ⟪u, u'⟫) ) :=
  (construction L).case

alias ⟨Subst.case, Subst.mk⟩ := Subst.case_iff

lemma Subst.semiterm₁ {n m w t t'} (h : Subst L n m w ⟪t, t'⟫) : L.IsSemiterm n t := by simpa using h.case.1

lemma Subst.semiterm₂ {n m w t t'} (h : Subst L n m w ⟪t, t'⟫) : L.IsSemiterm m t' := by simpa using h.case.2.1

lemma Subst.bvar {n m w z u : V} (hz : z < n) (hu : L.IsSemiterm m u) (h : ⟪z, u⟫ ∈ w) :
    Subst L n m w ⟪^#z, u⟫ := Subst.mk ⟨by simp [hz], by simpa using hu, Or.inl ⟨z, hz, by simpa using h⟩⟩

lemma Subst.bvar_iff {n m w z u : V} :
    Subst L n m w ⟪^#z, u⟫ ↔ z < n ∧ L.IsSemiterm m u ∧ ⟪z, u⟫ ∈ w :=
  ⟨by intro h
      rcases h.case with ⟨_, hu, (⟨z', hz', hzz', h⟩ | ⟨x, h, _⟩ | ⟨k, f, v, v', h, _⟩)⟩
      · rcases (show z = z' from by simpa using hzz'); exact ⟨hz', by simpa using hu, by simpa using h⟩
      · simp [qqBvar, qqFvar] at h
      · simp [qqBvar, qqFunc] at h,
   by rintro ⟨hz, Hu, h⟩; exact Subst.bvar hz Hu h⟩

@[simp] lemma Subst.fvar {n m w x : V} :
    Subst L n m w ⟪^&x, ^&x⟫ := Subst.mk ⟨by simp, by simp, Or.inr <| Or.inl ⟨x, by simp⟩⟩

lemma Subst.fvar_iff {n m w x u : V} :
    Subst L n m w ⟪^&x, u⟫ ↔ u = ^&x := by
  constructor
  · intro h
    rcases h.case with ⟨_, _, (⟨_, _, h, _⟩ | ⟨x', hx', h⟩ | ⟨_, _, _, _, h, _⟩)⟩
    · simp [qqBvar, qqFvar] at h
    · rcases (show x = x' from by simpa using hx'); simpa using h
    · simp [qqFvar, qqFunc] at h
  · rintro rfl; simp

lemma Subst.func {n m w k f v v' : V}
    (hkf : L.Func k f)
    (hv : L.TermSeq k n v)
    (hv' : L.TermSeq k m v')
    (H : ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → Subst L n m w ⟪u, u'⟫) :
    Subst L n m w ⟪^func k f v, ^func k f v'⟫ :=
  Subst.mk ⟨
    by rw [pi₁_pair]; exact IsSemiterm.func hkf hv,
    by rw [pi₂_pair]; exact IsSemiterm.func hkf hv',
    Or.inr <| Or.inr ⟨k, f, v, v', by simp, by simp, H⟩⟩

lemma Subst.func' {n m w k f v u : V} (h : Subst L n m w ⟪^func k f v, u⟫) :
    ∃ v', Seq v' ∧ k = lh v' ∧ (∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → Subst L n m w ⟪u, u'⟫) ∧ u = ^func k f v' := by
  rcases h.case with ⟨_, hu, (⟨_, _, h, _⟩ | ⟨x, h, _⟩ | ⟨k', f', v', v'', h₁, h₂, hv⟩)⟩
  · simp [qqFunc, qqBvar] at h
  · simp [qqFunc, qqFvar] at h
  · rcases (show k = k' ∧ f = f' ∧ v = v' by simpa [qqFunc] using h₁) with ⟨rfl, rfl, rfl⟩
    rcases (show u = ^func k f v'' by simpa using h₂)
    have : L.Func k f ∧ Seq v'' ∧ k = lh v'' ∧ ∀ i u, ⟪i, u⟫ ∈ v'' → L.IsSemiterm m u := by simpa [IsSemiterm.func_iff] using hu
    rcases this with ⟨_, Sv'', hk'', _⟩
    exact ⟨v'', Sv'', hk'', hv, rfl⟩

variable {n m w} (TSw : L.TermSeq n m w)

lemma Subst.rng_exists {t : V} (ht : L.IsSemiterm n t) : ∃ u, Subst L n m w ⟪t, u⟫ := by
  apply IsSemiterm.induction 𝚺 ?_ ?_ ?_ ?_ t ht
  · definability
  · intro z hz
    have : ∃ u, ⟪z, u⟫ ∈ w := TSw.seq.exists (show z < lh w by simpa [TSw.lh] using hz)
    rcases this with ⟨u, hu⟩
    exact ⟨u, Subst.bvar hz (TSw.prop z u hu) hu⟩
  · intro x; exact ⟨^&x, by simp⟩
  · rintro k f v hkf hv ih
    have : ∃ v', Seq v' ∧ lh v' = lh v ∧ ∀ i u', ⟪i, u'⟫ ∈ v' → ∀ u, ⟪i, u⟫ ∈ v → Subst L n m w ⟪u, u'⟫ := by
      have : ∀ i < lh v, ∃ u', ∀ u, ⟪i, u⟫ ∈ v → Subst L n m w ⟪u, u'⟫ := by
        intro i hi
        have : ∃ u, Subst L n m w ⟪hv.seq.nth hi, u⟫ := ih i (hv.seq.nth hi) (by simp)
        rcases this with ⟨u', hu'⟩
        exact ⟨u', fun u hiuv  ↦ by rcases hv.seq.nth_uniq hi hiuv; exact hu'⟩
      exact sigmaOne_skolem_seq
        (by have : 𝚺₁-Relation fun x y ↦ ∀ u < v, ⟪x, u⟫ ∈ v → Subst L n m w ⟪u, y⟫ := by definability
            exact this.of_iff fun w ↦ ⟨fun h u _ ↦ h u, fun h u hv ↦ h u (lt_of_mem_rng hv) hv⟩)
        this
    rcases this with ⟨v', Sv', hvv', h⟩
    exact ⟨^func k f v',
      Subst.func hkf hv ⟨Sv', by simp [hvv', hv.lh],
        (fun i u' hi ↦ by
          have : i < lh v := by simpa [hvv'] using Sv'.lt_lh_of_mem hi
          exact h i u' hi (hv.seq.nth this) (by simp) |>.semiterm₂)⟩
        (fun i u u' hi hi' ↦ h i u' hi' u hi)⟩

lemma Subst.rng_unique
    {t u₁ u₂ : V} : Subst L n m w ⟪t, u₁⟫ → Subst L n m w ⟪t, u₂⟫ → u₁ = u₂ := by
  revert u₁ u₂
  suffices L.IsSemiterm n t → ∀ u₁ u₂, Subst L n m w ⟪t, u₁⟫ → Subst L n m w ⟪t, u₂⟫ → u₁ = u₂
  by intro u₁ u₂ h₁ h₂; exact this h₁.semiterm₁ u₁ u₂ h₁ h₂
  intro ht
  apply IsSemiterm.induction 𝚷 ?_ ?_ ?_ ?_ t ht
  · definability
  · simp only [bvar_iff, and_imp]
    intro z _ u₁ u₂ _ _ h₁ _ _ h₂
    exact TSw.seq.isMapping.uniq h₁ h₂
  · simp [Subst.fvar_iff]
  · intro k f v _ hv ih u₁ u₂ h₁ h₂
    rcases Subst.func' h₁ with ⟨v₁, Sv₁, hk₁, hvv₁, rfl⟩
    rcases Subst.func' h₂ with ⟨v₂, Sv₂, hk₂, hvv₂, rfl⟩
    have : v₁ = v₂ := Sv₁.lh_ext Sv₂ (by simp [←hk₁, ←hk₂]) (by
      intro i x₁ x₂ hxv₁ hxv₂
      have hi : i < lh v := by simpa [←hv.lh, hk₁] using Sv₁.lt_lh_of_mem hxv₁
      exact ih i (hv.seq.nth hi) (by simp) _ _ (hvv₁ _ _ _ (hv.seq.nth_mem hi) hxv₁) (hvv₂ _ _ _ (hv.seq.nth_mem hi) hxv₂))
    rw [this]

lemma Subst.rng_exists_unique {t : V} (ht : L.IsSemiterm n t) : ∃! u, Subst L n m w ⟪t, u⟫ := by
  rcases Subst.rng_exists TSw ht with ⟨u, hu⟩
  exact ExistsUnique.intro u hu (fun u' hu' ↦ Subst.rng_unique TSw hu' hu)

variable (L)

lemma Subst.rng_exists_unique_total (n m w t : V) :
    ∃! u, (L.TermSeq n m w ∧ L.IsSemiterm n t → Subst L n m w ⟪t, u⟫) ∧ (¬(L.TermSeq n m w ∧ L.IsSemiterm n t) → u = 0) := by
  by_cases h : L.TermSeq n m w ∧ L.IsSemiterm n t
  · simp [h]; exact Subst.rng_exists_unique h.1 h.2
  · simp [h]

end FormalizedTermSubst

open FormalizedTermSubst

variable (L)

def Language.termSubst (n m w t : V) : V := Classical.choose! (Subst.rng_exists_unique_total L n m w t)

variable {L}

def Language.TermSeq.spec_of_semiterm {n m w t : V} (TSw : L.TermSeq n m w) (ht : L.IsSemiterm n t) : Subst L n m w ⟪t, L.termSubst n m w t⟫ :=
  Classical.choose!_spec (Subst.rng_exists_unique_total L n m w t) |>.1 ⟨TSw, ht⟩

def Language.TermSeq.substs_isterm {n m w t : V} (TSw : L.TermSeq n m w) (ht : L.IsSemiterm n t) :
    L.IsSemiterm m (L.termSubst n m w t) := TSw.spec_of_semiterm ht |>.semiterm₂

def termSubst_spec {n m w t : V} :
    ¬(L.TermSeq n m w ∧ L.IsSemiterm n t) → L.termSubst n m w t = 0 :=
  Classical.choose!_spec (Subst.rng_exists_unique_total L n m w t) |>.2

variable {n m w : V} (TSw : L.TermSeq n m w)

lemma Language.TermSeq.termSubst_eq_of {t} (ht : L.IsSemiterm n t) (h : Subst L n m w ⟪t, u⟫) : L.termSubst n m w t = u :=
  (TSw.spec_of_semiterm ht).rng_unique TSw h

lemma termSubst_bvar {z : V} (hz : z < n) (hu : ⟪z, u⟫ ∈ w) : L.termSubst n m w (^#z) = u :=
  TSw.termSubst_eq_of (by simp [hz]) (Subst.bvar hz (TSw.prop z u hu) hu)

@[simp] lemma termSubst_fvar (x : V) : L.termSubst n m w (^&x) = ^&x :=
  TSw.termSubst_eq_of (by simp) (by simp)

lemma termSubst_func {k f v v' : V} (hfk : L.Func k f)
    (hv : L.TermSeq k n v)
    (hv' : L.TermSeq k m v')
    (H : ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → L.termSubst n m w u = u') : L.termSubst n m w (^func k f v) = ^func k f v' :=
  TSw.termSubst_eq_of (IsSemiterm.func hfk hv)
    (Subst.func hfk hv hv' (fun i u u' hi hi' ↦ by
      rcases H i u u' hi hi'; exact TSw.spec_of_semiterm (hv.prop i u hi)))

section

variable (L)

private lemma termSubst_graph (u n m w t : V) :
    u = L.termSubst n m w t ↔
    (L.TermSeq n m w ∧ L.IsSemiterm n t → ∃ p ≤ (t + u + 1)^2, p = ⟪t, u⟫ ∧ Subst L n m w p) ∧ (¬(L.TermSeq n m w ∧ L.IsSemiterm n t) → u = 0) :=
  Iff.trans (Classical.choose!_eq_iff (Subst.rng_exists_unique_total L n m w t)) ⟨by
    rintro ⟨hp, hn⟩
    exact ⟨fun h ↦ ⟨⟪t, u⟫, by simp, rfl, hp h⟩, hn⟩, by
    rintro ⟨hp, hn⟩
    exact ⟨fun h ↦ by rcases hp h with ⟨_, _, rfl, h⟩; exact h, hn⟩⟩

def _root_.LO.FirstOrder.Arith.LDef.termSubstDef (pL : LDef) : 𝚺₁-Semisentence 5 := .mkSigma
  “u n m w t | (!pL.termSeqDef.pi n m w ∧ !pL.isSemitermDef.pi n t → ∃ p <⁺ (t + u + 1)², !pairDef p t u ∧ !pL.substDef.sigma n m w p) ∧
    (¬(!pL.termSeqDef.sigma n m w ∧ !pL.isSemitermDef.sigma n t) → u = 0)” (by simp)

lemma termSubst_defined : 𝚺₁-Function₄ L.termSubst via pL.termSubstDef := by
  intro v
  simp [LDef.termSubstDef, termSubst_graph, HSemiformula.val_sigma, eval_termSeq L,
    eval_isSemitermDef L, (termSeq_defined L).proper.iff', (isSemiterm_defined L).proper.iff', eval_substDef L, -and_imp, -not_and]
  apply iff_of_eq; congr; simp [imp_iff_not_or]; rfl

@[simp] lemma termSubst_defined_iff (v : Fin 5 → V) :
    Semiformula.Evalbm (L := ℒₒᵣ) V v pL.termSubstDef ↔ v 0 = L.termSubst (v 1) (v 2) (v 3) (v 4) := (termSubst_defined L).df.iff v

instance termSubst_definable : 𝚺₁-Function₄ L.termSubst :=
  Defined.to_definable _ (termSubst_defined L)
/-
@[simp, definability] instance termSubst_definable' (Γ m) : (Γ, m + 1)-Function₄ L.termSubst :=
  .of_sigmaOne (termSubst_definable L) _ _
-/
instance termSubst_definable₂ (n m) : 𝚺₁-Function₂ (L.termSubst n m) := by
  simpa using DefinableFunction.retractiont (n := 2) (termSubst_definable L) ![&n, &m, #0, #1]

@[simp, definability] instance termSubst_definable₂' (Γ l n m) : (Γ, l + 1)-Function₂ (L.termSubst n m) :=
  .of_sigmaOne (termSubst_definable₂ L n m) _ _

end

end termSubst

section termShift

namespace FormalizedTermShift

variable (L)

def Phi (n : V) (C : Set V) (p : V) : Prop :=
  L.IsSemiterm n (π₁ p) ∧ L.IsSemiterm n (π₂ p) ∧
  ( (∃ z < n, π₁ p = ^#z ∧ π₂ p = ^#z) ∨
    (∃ x, π₁ p = ^&x ∧ π₂ p = ^&(x + 1)) ∨
    (∃ k f v v', π₁ p = ^func k f v ∧ π₂ p = ^func k f v' ∧ ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → ⟪u, u'⟫ ∈ C) )

private lemma phi_iff (n C p : V) :
    Phi L n {x | x ∈ C} p ↔
    ∃ t₁ ≤ p, ∃ t₂ ≤ p, p = ⟪t₁, t₂⟫ ∧ L.IsSemiterm n t₁ ∧ L.IsSemiterm n t₂ ∧
    ( (∃ z < n, t₁ = ^#z ∧ t₂ = ^#z) ∨
      (∃ x < t₁, t₁ = ^&x ∧ t₂ = ^&(x + 1)) ∨
      (∃ k < t₁, ∃ f < t₁, ∃ v < t₁, ∃ v' < t₂, t₁ = ^func k f v ∧ t₂ = ^func k f v' ∧
        (∀ i < v, ∀ u < v, ∀ u' < v', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → ⟪u, u'⟫ ∈ C)) ) := by
  constructor
  ·{intro ⟨hp₁, hp₂, h⟩
    refine ⟨π₁ p, by simp, π₂ p, by simp, by simp, hp₁, hp₂, ?_⟩
    rcases h with (⟨z, hz, h₁, h⟩ | ⟨x, h₁, h₂⟩ | ⟨k, f, v, v', h₁, h₂, h⟩)
    · left; exact ⟨z, hz, h₁, h⟩
    · right; left; exact ⟨x, by simp [h₁], h₁, h₂⟩
    · right; right
      exact ⟨k, by simp [h₁], f, by simp [h₁], v, by simp [h₁], v', by simp [h₂],
        h₁, h₂, fun i _ u _ u' _ hi hi' ↦ h i u u' hi hi'⟩}
  · rintro ⟨t₁, _, t₂, _, rfl, ht₁, ht₂, h⟩
    refine ⟨by simpa using ht₁, by simpa using ht₂, ?_⟩
    rcases h with (⟨z, hz, rfl, h⟩ | ⟨x, _, rfl, rfl⟩ | ⟨k, _, f, _, v, _, v', _, rfl, rfl, h⟩)
    · left; exact ⟨z, hz, by simp [h]⟩
    · right; left; exact ⟨x, by simp⟩
    · right; right
      exact ⟨k, f, v, v', by simp, by simp, fun i u u' hi hi' ↦
        h i (lt_of_mem_dom hi) u (lt_of_mem_rng hi) u' (lt_of_mem_rng hi') hi hi'⟩

def formulaAux : Semisentence ℒₒᵣ 5 := “t₁ t₂ p C n |
  (∃ z < n, !qqBvarDef t₁ z ∧ !qqBvarDef t₂ z) ∨
  (∃ x < t₁, !qqFvarDef t₁ x ∧ !qqFvarDef t₂ (x + 1)) ∨
  (∃ k < t₁, ∃ f < t₁, ∃ v < t₁, ∃ v' < t₂, !qqFuncDef t₁ k f v ∧ !qqFuncDef t₂ k f v' ∧
  (∀ i < v, ∀ u < v, ∀ u' < v', i ~[v] u → i ~[v'] u' → u ~[C] u'))”

def formula (pL : LDef) : Fixpoint.Blueprint 1 := ⟨.mkDelta
  (.mkSigma
    “p C n |
      ∃ t₁ <⁺ p, ∃ t₂ <⁺ p, !pairDef p t₁ t₂ ∧ !pL.isSemitermDef.sigma n t₁ ∧ !pL.isSemitermDef.sigma n t₂ ∧
      !formulaAux t₁ t₂ p C n”
    (by simp [formulaAux]))
  (.mkPi
    “p C n |
      ∃ t₁ <⁺ p, ∃ t₂ <⁺ p, !pairDef p t₁ t₂ ∧ !pL.isSemitermDef.pi n t₁ ∧ !pL.isSemitermDef.pi n t₂ ∧
      !formulaAux t₁ t₂ p C n”
    (by simp [formulaAux]))⟩

def construction : Fixpoint.Construction V (formula pL) where
  Φ := fun v ↦ Phi L (v 0)
  defined := ⟨fun v ↦
    by simp [formula, HSemiformula.val_sigma, eval_isSemitermDef L, (isSemiterm_defined L).proper.iff'],
  fun v ↦ by simpa [formula, HSemiformula.val_sigma, eval_isSemitermDef L, formulaAux] using phi_iff _ _ _ _⟩
  monotone := by
    rintro C C' hC v p ⟨ht₁, ht₂, (h | h | ⟨k, f, v, v', h₁, h₂, h⟩)⟩
    · exact ⟨ht₁, ht₂, Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inr ⟨k, f, v, v', h₁, h₂, fun i u u' hi hi' ↦ hC (h i u u' hi hi')⟩⟩

instance : (construction L).StrongFinite V where
  strong_finite := by
    rintro C v p ⟨ht₁, ht₂, (h | h | ⟨k, f, v, v', h₁, h₂, h⟩)⟩
    · exact ⟨ht₁, ht₂, Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inl h⟩
    · exact ⟨ht₁, ht₂, Or.inr <| Or.inr ⟨k, f, v, v', h₁, h₂, fun i u u' hi hi' ↦ ⟨h i u u' hi hi', by
      have : ⟪u, u'⟫ < ⟪π₁ p, π₂ p⟫ := pair_lt_pair (by simpa [h₁] using lt_qqFunc_of_mem hi) (by simpa [h₂] using lt_qqFunc_of_mem hi')
      simpa using this⟩⟩⟩

def Shift (n : V) : V → Prop := (construction L).Fixpoint ![n]

def shiftDef (pL : LDef) : 𝚫₁-Semisentence 2 := (formula pL).fixpointDefΔ₁.rew <| Rew.substs ![#1, #0]

lemma shift_defined : 𝚫₁-Relation (Shift L) via (shiftDef pL) :=
  ⟨HSemiformula.ProperOn.rew (construction L).fixpoint_definedΔ₁.proper _,
   by intro v; simp [shiftDef, (construction L).eval_fixpointDefΔ₁, Shift]⟩

@[simp] lemma eval_shiftDef (v) :
    Semiformula.Evalbm V v (shiftDef pL).val ↔ Shift L (v 0) (v 1) := (shift_defined L).df.iff v

instance shift_definable : 𝚫₁-Relation (Shift L) := Defined.to_definable _ (shift_defined L)

@[simp, definability] instance shift_definable' (Γ) : (Γ, m + 1)-Relation (Shift L) :=
  .of_deltaOne (shift_definable L) _ _

variable {L}

lemma Shift.case_iff {n p : V} :
    Shift L n p ↔
    L.IsSemiterm n (π₁ p) ∧ L.IsSemiterm n (π₂ p) ∧
    ( (∃ z < n, π₁ p = ^#z ∧ π₂ p = ^#z) ∨
      (∃ x, π₁ p = ^&x ∧ π₂ p = ^&(x + 1)) ∨
      (∃ k f v v', π₁ p = ^func k f v ∧ π₂ p = ^func k f v' ∧ ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → Shift L n ⟪u, u'⟫) ) :=
  (construction L).case

alias ⟨Shift.case, Shift.mk⟩ := Shift.case_iff

lemma Shift.semiterm₁ {n t t'} (h : Shift L n ⟪t, t'⟫) : L.IsSemiterm n t := by simpa using h.case.1

lemma Shift.semiterm₂ {n t t'} (h : Shift L n ⟪t, t'⟫) : L.IsSemiterm n t' := by simpa using h.case.2.1

@[simp] lemma Shift.bvar {n z : V} (hz : z < n) :
    Shift L n ⟪^#z, ^#z⟫ := Shift.mk ⟨by simp [hz], by simp [hz]⟩

lemma Shift.bvar_iff {n z u : V} :
    Shift L n ⟪^#z, u⟫ ↔ z < n ∧ u = ^#z :=
  ⟨by intro h
      rcases h.case with ⟨_, _, (⟨z', hz', hzz', h⟩ | ⟨x, h, _⟩ | ⟨k, f, v, v', h, _⟩)⟩
      · rcases (show z = z' from by simpa using hzz'); exact ⟨hz', by simpa using h⟩
      · simp [qqBvar, qqFvar] at h
      · simp [qqBvar, qqFunc] at h,
   by rintro ⟨hz, Hu, h⟩; exact Shift.bvar hz⟩

@[simp] lemma Shift.fvar {n : V} (x : V):
    Shift L n ⟪^&x, ^&(x + 1)⟫ := Shift.mk ⟨by simp, by simp⟩

lemma Shift.fvar_iff {n x u : V} :
    Shift L n ⟪^&x, u⟫ ↔ u = ^&(x + 1) :=
  ⟨by intro h
      rcases h.case with ⟨_, _, (⟨_, _, h, _⟩ | ⟨x', hx', h⟩ | ⟨_, _, _, _, h, _, _⟩)⟩
      · simp [qqBvar, qqFvar] at h
      · rcases (show x = x' by simpa using hx'); simpa using h
      · simp [qqFvar, qqFunc] at h,
   by rintro ⟨hz, Hu, h⟩; exact Shift.fvar x⟩

lemma Shift.func {n k f v v' : V}
    (hkf : L.Func k f)
    (hv : L.TermSeq k n v)
    (hv' : L.TermSeq k n v')
    (H : ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → Shift L n ⟪u, u'⟫) :
    Shift L n ⟪^func k f v, ^func k f v'⟫ :=
  Shift.mk ⟨
    by rw [pi₁_pair]; exact IsSemiterm.func hkf hv,
    by rw [pi₂_pair]; exact IsSemiterm.func hkf hv',
    Or.inr <| Or.inr ⟨k, f, v, v', by simp, by simp, H⟩⟩

lemma Shift.func' {n k f v u : V} (h : Shift L n ⟪^func k f v, u⟫) :
    ∃ v', Seq v' ∧ k = lh v' ∧ (∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → Shift L n ⟪u, u'⟫) ∧ u = ^func k f v' := by
  rcases h.case with ⟨_, hu, (⟨_, _, h, _⟩ | ⟨x, h, _⟩ | ⟨k', f', v', v'', h₁, h₂, hv⟩)⟩
  · simp [qqFunc, qqBvar] at h
  · simp [qqFunc, qqFvar] at h
  · rcases (show k = k' ∧ f = f' ∧ v = v' by simpa [qqFunc] using h₁) with ⟨rfl, rfl, rfl⟩
    rcases (show u = ^func k f v'' by simpa using h₂)
    have : L.Func k f ∧ Seq v'' ∧ k = lh v'' ∧ ∀ i u, ⟪i, u⟫ ∈ v'' → L.IsSemiterm n u := by simpa [IsSemiterm.func_iff] using hu
    rcases this with ⟨_, Sv'', hk'', _⟩
    exact ⟨v'', Sv'', hk'', hv, rfl⟩

variable {n : V}

lemma Shift.rng_exists {t : V} (ht : L.IsSemiterm n t) : ∃ u, Shift L n ⟪t, u⟫ := by
  apply IsSemiterm.induction 𝚺 ?_ ?_ ?_ ?_ t ht
  · definability
  · intro z hz; exact ⟨^#z, Shift.bvar hz⟩
  · intro x; exact ⟨^&(x + 1), by simp⟩
  · rintro k f v hkf hv ih
    have : ∃ v', Seq v' ∧ lh v' = lh v ∧ ∀ i u', ⟪i, u'⟫ ∈ v' → ∀ u, ⟪i, u⟫ ∈ v → Shift L n ⟪u, u'⟫ := by
      have : ∀ i < lh v, ∃ u', ∀ u, ⟪i, u⟫ ∈ v → Shift L n ⟪u, u'⟫ := by
        intro i hi
        have : ∃ u, Shift L n ⟪hv.seq.nth hi, u⟫ := ih i (hv.seq.nth hi) (by simp)
        rcases this with ⟨u', hu'⟩
        exact ⟨u', fun u hiuv  ↦ by rcases hv.seq.nth_uniq hi hiuv; exact hu'⟩
      exact sigmaOne_skolem_seq
        (by have : 𝚺₁-Relation fun x y ↦ ∀ u < v, ⟪x, u⟫ ∈ v → Shift L n ⟪u, y⟫ := by definability
            exact this.of_iff fun w ↦ ⟨fun h u _ ↦ h u, fun h u hv ↦ h u (lt_of_mem_rng hv) hv⟩)
        this
    rcases this with ⟨v', Sv', hvv', h⟩
    exact ⟨^func k f v',
      Shift.func hkf hv ⟨Sv', by simp [hvv', hv.lh],
        (fun i u' hi ↦ by
          have : i < lh v := by simpa [hvv'] using Sv'.lt_lh_of_mem hi
          exact h i u' hi (hv.seq.nth this) (by simp) |>.semiterm₂)⟩
        (fun i u u' hi hi' ↦ h i u' hi' u hi)⟩

lemma Shift.rng_unique
    {t u₁ u₂ : V} : Shift L n ⟪t, u₁⟫ → Shift L n ⟪t, u₂⟫ → u₁ = u₂ := by
  revert u₁ u₂
  suffices L.IsSemiterm n t → ∀ u₁ u₂, Shift L n ⟪t, u₁⟫ → Shift L n ⟪t, u₂⟫ → u₁ = u₂
  by intro u₁ u₂ h₁ h₂; exact this h₁.semiterm₁ u₁ u₂ h₁ h₂
  intro ht
  apply IsSemiterm.induction 𝚷 ?_ ?_ ?_ ?_ t ht
  · definability
  · simp only [bvar_iff, and_imp]
    rintro z _ u₁ u₂ _ rfl _ rfl; rfl
  · simp [Shift.fvar_iff]
  · intro k f v _ hv ih u₁ u₂ h₁ h₂
    rcases Shift.func' h₁ with ⟨v₁, Sv₁, hk₁, hvv₁, rfl⟩
    rcases Shift.func' h₂ with ⟨v₂, Sv₂, hk₂, hvv₂, rfl⟩
    have : v₁ = v₂ := Sv₁.lh_ext Sv₂ (by simp [←hk₁, ←hk₂]) (by
      intro i x₁ x₂ hxv₁ hxv₂
      have hi : i < lh v := by simpa [←hv.lh, hk₁] using Sv₁.lt_lh_of_mem hxv₁
      exact ih i (hv.seq.nth hi) (by simp) _ _ (hvv₁ _ _ _ (hv.seq.nth_mem hi) hxv₁) (hvv₂ _ _ _ (hv.seq.nth_mem hi) hxv₂))
    rw [this]

lemma Shift.rng_exists_unique {t : V} (ht : L.IsSemiterm n t) : ∃! u, Shift L n ⟪t, u⟫ := by
  rcases Shift.rng_exists ht with ⟨u, hu⟩
  exact ExistsUnique.intro u hu (fun u' hu' ↦ Shift.rng_unique hu' hu)

variable (L)

lemma Shift.rng_exists_unique_total (n t : V) :
    ∃! u, (L.IsSemiterm n t → Shift L n ⟪t, u⟫) ∧ (¬L.IsSemiterm n t → u = 0) := by
  by_cases h : L.IsSemiterm n t
  · simp [h]; exact Shift.rng_exists_unique h
  · simp [h]

end FormalizedTermShift

open FormalizedTermShift

variable (L)

def Language.termShift (n t : V) : V := Classical.choose! (Shift.rng_exists_unique_total L n t)

variable {L}

lemma Language.IsSemiterm.termShift_spec {n t : V} (ht : L.IsSemiterm n t) : Shift L n ⟪t, L.termShift n t⟫ :=
  Classical.choose!_spec (Shift.rng_exists_unique_total L n t) |>.1 ht

lemma termShift_spec_of_not_termShift {n t : V} :
    ¬L.IsSemiterm n t → L.termShift n t = 0 :=
  Classical.choose!_spec (Shift.rng_exists_unique_total L n t) |>.2

lemma Language.IsSemiterm.termShift_eq_of {n t} (ht : L.IsSemiterm n t) (h : Shift L n ⟪t, u⟫) : L.termShift n t = u :=
  ht.termShift_spec.rng_unique h

lemma termShift_bvar {z : V} (hz : z < n) : L.termShift n (^#z) = ^#z :=
  Language.IsSemiterm.termShift_eq_of (by simp [hz]) (Shift.bvar hz)

@[simp] lemma termShift_fvar (x : V) : L.termShift n (^&x) = ^&(x + 1) :=
  Language.IsSemiterm.termShift_eq_of (by simp) (Shift.fvar x)

lemma termShift_func {k f v v' : V} (hfk : L.Func k f)
    (hv : L.TermSeq k n v)
    (hv' : L.TermSeq k n v')
    (H : ∀ i u u', ⟪i, u⟫ ∈ v → ⟪i, u'⟫ ∈ v' → L.termShift n u = u') : L.termShift n (^func k f v) = ^func k f v' :=
  Language.IsSemiterm.termShift_eq_of (IsSemiterm.func hfk hv)
    (Shift.func hfk hv hv' (fun i u u' hi hi' ↦ by
      rcases H i u u' hi hi'
      exact Language.IsSemiterm.termShift_spec (hv.prop i u hi)))

section

variable (L)

private lemma termShift_graph (u n t : V) :
    u = L.termShift n t ↔
    (L.IsSemiterm n t → ∃ p ≤ (t + u + 1)^2, p = ⟪t, u⟫ ∧ Shift L n p) ∧ (¬L.IsSemiterm n t → u = 0) :=
  Iff.trans (Classical.choose!_eq_iff (Shift.rng_exists_unique_total L n t)) ⟨by
    rintro ⟨hp, hn⟩
    exact ⟨fun h ↦ ⟨⟪t, u⟫, by simp, rfl, hp h⟩, hn⟩, by
    rintro ⟨hp, hn⟩
    exact ⟨fun h ↦ by rcases hp h with ⟨_, _, rfl, h⟩; exact h, hn⟩⟩

def _root_.LO.FirstOrder.Arith.LDef.termShiftDef (pL : LDef) : 𝚺₁-Semisentence 3 := .mkSigma
  “u n t | (!pL.isSemitermDef.pi n t → ∃ p <⁺ (t + u + 1)², !pairDef p t u ∧ !(shiftDef pL).sigma n p) ∧ (¬!pL.isSemitermDef.sigma n t → u = 0)” (by simp)

lemma termShift_defined : 𝚺₁-Function₂ L.termShift via pL.termShiftDef := by
  intro v
  simp [LDef.termShiftDef, termShift_graph, HSemiformula.val_sigma, eval_termSeq L,
    eval_isSemitermDef L, (termSeq_defined L).proper.iff', (isSemiterm_defined L).proper.iff', eval_shiftDef L, -and_imp, -not_and]

@[simp] lemma termShift_defined_iff (v : Fin 3 → V) :
    Semiformula.Evalbm (L := ℒₒᵣ) V v pL.termShiftDef ↔ v 0 = L.termShift (v 1) (v 2) := (termShift_defined L).df.iff v

instance termShift_definable : 𝚺₁-Function₂ L.termShift :=
  Defined.to_definable _ (termShift_defined L)

end

end termShift

end LO.Arith

end
