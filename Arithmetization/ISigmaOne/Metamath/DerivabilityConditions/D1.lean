import Arithmetization.ISigmaOne.Metamath.Theory.SigmaOneDefinable

noncomputable section

open Classical

namespace LO.FirstOrder

open LO.Arith FirstOrder.Arith

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Language} [(k : ℕ) → Encodable (L.Func k)] [(k : ℕ) → Encodable (L.Rel k)] [DefinableLanguage L]

variable (V)

namespace Derivation2

def Sequent.codeIn (Γ : Finset (SyntacticFormula L)) : V := ∑ p ∈ Γ, exp (⌜p⌝ : V)

instance : GoedelQuote (Finset (SyntacticFormula L)) V := ⟨Sequent.codeIn V⟩

lemma Sequent.codeIn_def (Γ : Finset (SyntacticFormula L)) : ⌜Γ⌝ = ∑ p ∈ Γ, exp (⌜p⌝ : V) := rfl

variable {V}

open Classical

@[simp] lemma Sequent.codeIn_empty : (⌜(∅ : Finset (SyntacticFormula L))⌝ : V) = ∅ := by
  simp [Sequent.codeIn_def, emptyset_def]

lemma Sequent.mem_codeIn_iff {Γ : Finset (SyntacticFormula L)} {p} : ⌜p⌝ ∈ (⌜Γ⌝ : V) ↔ p ∈ Γ := by
  induction Γ using Finset.induction generalizing p
  case empty => simp [Sequent.codeIn_def]
  case insert a Γ ha ih =>
    have : exp ⌜a⌝ + ∑ p ∈ Γ, exp (⌜p⌝ : V) = insert (⌜a⌝ : V) (⌜Γ⌝ : V) := by
      simp [insert, bitInsert, (not_iff_not.mpr ih.symm).mp ha, add_comm]
      rw [Sequent.codeIn_def]
    simp [ha, Sequent.codeIn_def]
    rw [this]
    simp [←ih]

@[simp] lemma Sequent.codeIn_insert (Γ : Finset (SyntacticFormula L)) (p) : (⌜(insert p Γ)⌝ : V) = insert ⌜p⌝ ⌜Γ⌝ := by
  by_cases hp : p ∈ Γ
  · simp [Sequent.mem_codeIn_iff, hp, insert_eq_self_of_mem]
  · have : (⌜insert p Γ⌝ : V) = exp ⌜p⌝ + ⌜Γ⌝ := by simp [Sequent.codeIn_def, hp]
    simp [Sequent.mem_codeIn_iff, this, insert_eq, bitInsert, hp, add_comm]

lemma Sequent.mem_codeIn {Γ : Finset (SyntacticFormula L)} (hx : x ∈ (⌜Γ⌝ : V)) : ∃ p ∈ Γ, x = ⌜p⌝ := by
  induction Γ using Finset.induction
  case empty => simp at hx
  case insert a Γ _ ih =>
    have : x = ⌜a⌝ ∨ x ∈ (⌜Γ⌝ : V) := by simpa using hx
    rcases this with (rfl | hx)
    · exact ⟨a, by simp⟩
    · rcases ih hx with ⟨p, hx, rfl⟩
      exact ⟨p, by simp [*]⟩

variable (V)

def codeIn : {Γ : Finset (SyntacticFormula L)} → ⊢¹ᶠ Γ → V
  | _, axL (Δ := Δ) p _ _                     => Arith.axL ⌜Δ⌝ ⌜p⌝
  | _, verum (Δ := Δ) _                       => Arith.verumIntro ⌜Δ⌝
  | _, and (Δ := Δ) _ (p := p) (q := q) bp bq => Arith.andIntro ⌜Δ⌝ ⌜p⌝ ⌜q⌝ bp.codeIn bq.codeIn
  | _, or (Δ := Δ) (p := p) (q := q) _ d      => Arith.orIntro ⌜Δ⌝ ⌜p⌝ ⌜q⌝ d.codeIn
  | _, all (Δ := Δ) (p := p) _ d              => Arith.allIntro ⌜Δ⌝ ⌜p⌝ d.codeIn
  | _, ex (Δ := Δ) (p := p) _ t d             => Arith.exIntro ⌜Δ⌝ ⌜p⌝ ⌜t⌝ d.codeIn
  | _, wk (Γ := Γ) d _                        => Arith.wkRule ⌜Γ⌝ d.codeIn
  | _, shift (Δ := Δ) d                       => Arith.shiftRule ⌜Δ.image Rew.shift.hom⌝ d.codeIn
  | _, cut (Δ := Δ) (p := p) d dn             => Arith.cutRule ⌜Δ⌝ ⌜p⌝ d.codeIn dn.codeIn

instance (Γ : Finset (SyntacticFormula L)) : GoedelQuote (⊢¹ᶠ Γ) V := ⟨codeIn V⟩

lemma quote_derivation_def {Γ : Finset (SyntacticFormula L)} (d : ⊢¹ᶠ Γ) : (⌜d⌝ : V) = d.codeIn V := rfl

@[simp] lemma fstidx_quote {Γ : Finset (SyntacticFormula L)} (d : ⊢¹ᶠ Γ) : fstIdx (⌜d⌝ : V) = ⌜Γ⌝ := by
  induction d <;> simp [quote_derivation_def, codeIn]

end Derivation2

end LO.FirstOrder

namespace LO.Arith

open FirstOrder FirstOrder.Arith FirstOrder.Semiformula

variable {V : Type*} [Zero V] [One V] [Add V] [Mul V] [LT V] [V ⊧ₘ* 𝐈𝚺₁]

variable {L : Language} [(k : ℕ) → Encodable (L.Func k)] [(k : ℕ) → Encodable (L.Rel k)] [DefinableLanguage L]

open Classical

@[simp] lemma formulaSet_codeIn_finset (Γ : Finset (SyntacticFormula L)) : (L.codeIn V).FormulaSet ⌜Γ⌝ := by
  intro x hx
  rcases Derivation2.Sequent.mem_codeIn hx with ⟨p, _, rfl⟩;
  apply semiformula_quote

open Derivation2

lemma quote_image_shift (Γ : Finset (SyntacticFormula L)) : (L.codeIn V).setShift (⌜Γ⌝ : V) = ⌜Γ.image Rew.shift.hom⌝ := by
  induction Γ using Finset.induction
  case empty => simp
  case insert p Γ _ ih => simp [shift_quote, ih]

@[simp] lemma derivation_quote {Γ : Finset (SyntacticFormula L)} (d : ⊢¹ᶠ Γ) : (L.codeIn V).Derivation ⌜d⌝ := by
  induction d
  case axL p hp hn =>
    exact Language.Derivation.axL (by simp)
      (by simp [Sequent.mem_codeIn_iff, hp])
      (by simp [Sequent.mem_codeIn_iff, neg_quote, hn])
  case verum Δ h =>
    exact Language.Derivation.verumIntro (by simp)
      (by simpa [quote_verum] using (Sequent.mem_codeIn_iff (V := V)).mpr h)
  case and Δ p q hpq dp dq ihp ihq =>
    apply Language.Derivation.andIntro
      (by simpa using (Sequent.mem_codeIn_iff (V := V)).mpr hpq)
      ⟨by simp [fstidx_quote], ihp⟩
      ⟨by simp [fstidx_quote], ihq⟩
  case or Δ p q hpq d ih =>
    apply Language.Derivation.orIntro
      (by simpa using (Sequent.mem_codeIn_iff (V := V)).mpr hpq)
      ⟨by simp [fstidx_quote], ih⟩
  case all Δ p h d ih =>
    apply Language.Derivation.allIntro
      (by simpa using (Sequent.mem_codeIn_iff (V := V)).mpr h)
      ⟨by simp [fstidx_quote, quote_image_shift, free_quote], ih⟩
  case ex Δ p h t d ih =>
    apply Language.Derivation.exIntro
      (by simpa using (Sequent.mem_codeIn_iff (V := V)).mpr h)
      (semiterm_codeIn t)
      ⟨by simp [fstidx_quote, ←substs_quote, Language.substs₁], ih⟩
  case wk Δ Γ d h ih =>
    apply Language.Derivation.wkRule (s' := ⌜Δ⌝)
      (by simp)
      (by intro x hx; rcases Sequent.mem_codeIn hx with ⟨p, hp, rfl⟩
          simp [Sequent.mem_codeIn_iff, h hp])
      ⟨by simp [fstidx_quote], ih⟩
  case shift Δ d ih =>
    simp [quote_derivation_def, Derivation2.codeIn, ←quote_image_shift]
    apply Language.Derivation.shiftRule
      ⟨by simp [fstidx_quote], ih⟩
  case cut Δ p d dn ih ihn =>
    apply Language.Derivation.cutRule
      ⟨by simp [fstidx_quote], ih⟩
      ⟨by simp [fstidx_quote, neg_quote], ihn⟩

@[simp] lemma derivationOf_quote {Γ : Finset (SyntacticFormula L)} (d : ⊢¹ᶠ Γ) : (L.codeIn V).DerivationOf ⌜d⌝ ⌜Γ⌝ :=
  ⟨by simp, by simp⟩

lemma derivable_of_quote {Γ : Finset (SyntacticFormula L)} (d : ⊢¹ᶠ Γ) : (L.codeIn V).Derivable ⌜Γ⌝ :=
  ⟨⌜d⌝, by simp⟩

section

variable {T : Theory L} [T.Sigma₁Definable]

/-- D1 -/
theorem provable_of_provable : T ⊢! σ → (T.codeIn V).Provable ⌜σ⌝ := by
  intro h
  rcases provable_iff_derivation2.mp h with ⟨Γ, h, ⟨d⟩⟩
  refine ⟨⌜Γ⌝, ?_, ?_⟩
  · intro x hx
    rcases Sequent.mem_codeIn hx with ⟨p, hp, rfl⟩
    rcases h p hp with ⟨π, hπ, hπp⟩
    have : p = ~Rew.embs.hom π := by simp [hπp]
    rcases this with rfl
    simp [neg_quote, ←quote_semisentence_def]; exact mem_coded_theory hπ
  · have : (⌜Γ⌝ : V) ∪ {⌜σ⌝} = insert ⌜σ⌝ ⌜Γ⌝ := mem_ext fun x ↦ by simp; tauto
    rw [this]
    simpa [quote_semisentence_def] using derivable_of_quote (V := V) d

theorem tprovable_of_provable : T ⊢! σ → T.codeIn V ⊢! ⌜σ⌝ := fun h ↦ by
  simpa [Language.Theory.TProvable.iff_provable] using provable_of_provable (V := V) h

end

end LO.Arith
