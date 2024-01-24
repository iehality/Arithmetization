import Arithmetization.Exponential.Exp
import Mathlib.Tactic.Linarith

namespace LO.FirstOrder

namespace Arith

noncomputable section

variable {M : Type} [Zero M] [One M] [Add M] [Mul M] [LT M] [𝐏𝐀⁻.Mod M]

namespace Model

section ISigma₀

variable [𝐈𝚺₀.Mod M]

lemma log_exists_unique_pos {y : M} (hy : 0 < y) : ∃! x, x < y ∧ ∃ y' ≤ y, Exp x y' ∧ y < 2 * y' := by
  have : ∃ x < y, ∃ y' ≤ y, Exp x y' ∧ y < 2 * y' := by
    revert hy
    induction y using hierarchy_polynomial_induction_sigma₀
    · definability
    case zero => simp
    case even y IH =>
      intro hy
      rcases (IH (by simpa using hy) : ∃ x < y, ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') with ⟨x, hxy, y', gey, H, lty⟩
      exact ⟨x + 1, lt_of_lt_of_le (by simp [hxy]) (succ_le_double_of_pos (pos_of_gt hxy)),
        2 * y', by simpa using gey, Exp.exp_succ_mul_two.mpr H, by simpa using lty⟩
    case odd y IH =>
      intro hy
      rcases (zero_le y : 0 ≤ y) with (rfl | pos)
      · simp; exact ⟨1, by simp [one_lt_two]⟩
      · rcases (IH pos : ∃ x < y, ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') with ⟨x, hxy, y', gey, H, lty⟩
        exact ⟨x + 1, by simp; exact lt_of_lt_of_le hxy (by simp),
          2 * y', le_trans (by simpa using gey) le_self_add, Exp.exp_succ_mul_two.mpr H, two_mul_add_one_lt_two_mul_of_lt lty⟩
  rcases this with ⟨x, hx⟩
  exact ExistsUnique.intro x hx (fun x' ↦ by
    intro hx'
    by_contra A
    wlog lt : x < x'
    · exact this hy x' hx' x hx (Ne.symm A) (lt_of_le_of_ne (by simpa using lt) A)
    rcases hx with ⟨_, z, _, H, hyz⟩
    rcases hx' with ⟨_, z', hzy', H', _⟩
    have : z < z' := Exp.monotone H H' lt
    have : y < y := calc
      y < 2 * z := hyz
      _ ≤ z'    := (Pow2.lt_iff_two_mul_le H.range_pow2 H'.range_pow2).mp this
      _ ≤ y     := hzy'
    simp at this)

lemma log_exists_unique (y : M) : ∃! x, (y = 0 → x = 0) ∧ (0 < y → x < y ∧ ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') := by
  by_cases hy : y = 0
  · rcases hy; simp
  · simp [hy, pos_iff_ne_zero.mpr hy, log_exists_unique_pos]

def log (a : M) : M := Classical.choose! (log_exists_unique a)

@[simp] lemma log_zero : log (0 : M) = 0 :=
  (Classical.choose!_spec (log_exists_unique (0 : M))).1 rfl

lemma log_pos {y : M} (pos : 0 < y) : ∃ y' ≤ y, Exp (log y) y' ∧ y < 2 * y' :=
  ((Classical.choose!_spec (log_exists_unique y)).2 pos).2

lemma log_lt_self_of_pos {y : M} (pos : 0 < y) : log y < y :=
  ((Classical.choose!_spec (log_exists_unique y)).2 pos).1

@[simp] lemma log_le_self (a : M) : log a ≤ a := by
  rcases zero_le a with (rfl | pos)
  · simp
  · exact le_of_lt <| log_lt_self_of_pos pos

lemma log_graph {x y : M} : x = log y ↔ (y = 0 → x = 0) ∧ (0 < y → x < y ∧ ∃ y' ≤ y, Exp x y' ∧ y < 2 * y') := Classical.choose!_eq_iff _

def logdef : Σᴬ[0] 2 := ⟨“(#1 = 0 → #0 = 0) ∧ (0 < #1 → #0 < #1 ∧ ∃[#0 < #2 + 1] (!Exp.def [#1, #0] ∧ #2 < 2 * #0))”, by simp⟩

lemma log_defined : Σᴬ[0]-Function₁ (log : M → M) logdef := by
  intro v; simp [logdef, log_graph, Exp.defined.pval, ←le_iff_lt_succ]

instance {b s} : DefinableFunction₁ b s (log : M → M) := defined_to_with_param₀ _ log_defined

instance : PolyBounded₁ (log : M → M) := ⟨#0, λ _ ↦ by simp⟩

lemma log_eq_of_pos {x y : M} (pos : 0 < y) {y'} (H : Exp x y') (hy' : y' ≤ y) (hy : y < 2 * y') : log y = x :=
  (log_exists_unique_pos pos).unique ⟨log_lt_self_of_pos pos, log_pos pos⟩ ⟨lt_of_lt_of_le H.dom_lt_range hy', y', hy', H, hy⟩

@[simp] lemma log_one : log (1 : M) = 0 := log_eq_of_pos (by simp) (y' := 1) (by simp) (by rfl) (by simp [one_lt_two])

lemma log_two_mul_of_pos {y : M} (pos : 0 < y) : log (2 * y) = log y + 1 := by
  rcases log_pos pos with ⟨y', hy', H, hy⟩
  exact log_eq_of_pos (by simpa using pos) (Exp.exp_succ_mul_two.mpr H) (by simpa using hy') (by simpa using hy)

lemma log_two_mul_add_one_of_pos {y : M} (pos : 0 < y) : log (2 * y + 1) = log y + 1 := by
  rcases log_pos pos with ⟨y', hy', H, hy⟩
  exact log_eq_of_pos (by simp) (Exp.exp_succ_mul_two.mpr H)
    (le_trans (by simpa using hy') le_self_add) (two_mul_add_one_lt_two_mul_of_lt hy)

lemma log_eq_of_exp {x y : M} (H : Exp x y) : log y = x :=
  log_eq_of_pos H.range_pos H (by { rfl }) (lt_mul_of_pos_of_one_lt_left H.range_pos one_lt_two)

lemma exp_of_pow2 {p : M} (pp : Pow2 p) : Exp (log p) p := by
  rcases log_pos pp.pos with ⟨q, hq, H, hp⟩
  suffices : p = q
  · simpa [this] using H
  by_contra ne
  have : q < p := lt_of_le_of_ne hq (Ne.symm ne)
  have : 2 * q < 2 * q := calc
    2 * q ≤ p     := (Pow2.lt_iff_two_mul_le H.range_pow2 pp).mp this
    _     < 2 * q := hp
  simp at this

lemma log_mul_pow2_add_of_lt {a p b : M} (pos : 0 < a) (pp : Pow2 p) (hb : b < p) : log (a * p + b) = log a + log p := by
  rcases log_pos pos with ⟨a', ha', Ha, ha⟩
  rcases log_pos pp.pos with ⟨p', hp', Hp, hp⟩
  exact log_eq_of_pos (lt_of_lt_of_le (mul_pos pos pp.pos) le_self_add)
    (Exp.add_mul Ha Hp) (le_trans (mul_le_mul' ha' hp') le_self_add) (by
      rcases Hp.uniq (exp_of_pow2 pp)
      calc
        a * p + b < a * p + p    := by simp [hb]
        _         = (a + 1) * p  := by simp [add_mul]
        _         ≤ 2 * (a' * p) := by simp [←mul_assoc]; exact mul_le_mul_right (lt_iff_succ_le.mp ha))

lemma log_mul_pow2 {a p : M} (pos : 0 < a) (pp : Pow2 p) : log (a * p) = log a + log p := by
  simpa using log_mul_pow2_add_of_lt pos pp pp.pos

lemma log_monotone {a b : M} (h : a ≤ b) : log a ≤ log b := by
  rcases zero_le a with (rfl | posa)
  · simp
  rcases zero_le b with (rfl | posb)
  · have := lt_of_lt_of_le posa h; simp_all
  rcases log_pos posa with ⟨a', ha', Ha, _⟩
  rcases log_pos posb with ⟨b', _, Hb, hb⟩
  by_contra lt
  have : b' < a' := (Exp.monotone_iff Hb Ha).mp (by simpa using lt)
  have : b < b := calc
    b < 2 * b' := hb
    _ ≤ a'     := (Pow2.lt_iff_two_mul_le Hb.range_pow2 Ha.range_pow2).mp this
    _ ≤ a      := ha'
    _ ≤ b      := h
  simp_all

def binaryLength (a : M) : M := if 0 < a then log a + 1 else 0

notation "‖" a "‖" => binaryLength a

@[simp] lemma binary_length_zero : ‖(0 : M)‖ = 0 := by simp [binaryLength]

lemma binary_length_of_pos {a : M} (pos : 0 < a) : ‖a‖ = log a + 1 := by simp [binaryLength, pos]

@[simp] lemma binary_length_le (a : M) : ‖a‖ ≤ a := by
  rcases zero_le a with (rfl | pos)
  · simp
  · simp [pos, binary_length_of_pos, ←lt_iff_succ_le, log_lt_self_of_pos]

lemma binary_length_graph {i a : M} : i = ‖a‖ ↔ (0 < a → ∃ k ≤ a, k = log a ∧ i = k + 1) ∧ (a = 0 → i = 0) := by
  rcases zero_le a with (rfl | pos)
  · simp
  · simp [binary_length_of_pos, pos, pos_iff_ne_zero.mp pos]
    constructor
    · rintro rfl; exact ⟨log a, by simp⟩
    · rintro ⟨_, _, rfl, rfl⟩; rfl

def binarylengthdef : Σᴬ[0] 2 := ⟨“(0 < #1 → ∃[#0 < #2 + 1] (!logdef [#0, #2] ∧ #1 = #0 + 1)) ∧ (#1 = 0 → #0 = 0)”, by simp⟩

lemma binary_length_defined : Σᴬ[0]-Function₁ (binaryLength : M → M) binarylengthdef := by
  intro v; simp [binarylengthdef, binary_length_graph, log_defined.pval, ←le_iff_lt_succ]

instance {b s} : DefinableFunction₁ b s (binaryLength : M → M) := defined_to_with_param₀ _ binary_length_defined

instance : PolyBounded₁ (binaryLength : M → M) := ⟨#0, λ _ ↦ by simp⟩

@[simp] lemma binary_length_one : ‖(1 : M)‖ = 1 := by simp [binaryLength]

lemma binary_length_two_mul_of_pos {a : M} (pos : 0 < a) : ‖2 * a‖ = ‖a‖ + 1 := by
  simp [pos, binary_length_of_pos, log_two_mul_of_pos]

lemma binary_length_two_mul_add_one (a : M) : ‖2 * a + 1‖ = ‖a‖ + 1 := by
  rcases zero_le a with (rfl | pos)
  · simp
  · simp [pos, binary_length_of_pos, log_two_mul_add_one_of_pos]

lemma binary_length_mul_pow2_add_of_lt {a p b : M} (pos : 0 < a) (pp : Pow2 p) (hb : b < p) : ‖a * p + b‖ = ‖a‖ + log p := by
  simp [binary_length_of_pos, pos, pp.pos, log_mul_pow2_add_of_lt pos pp hb, add_right_comm (log a) (log p) 1]

lemma binary_length_mul_pow2 {a p : M} (pos : 0 < a) (pp : Pow2 p) : ‖a * p‖ = ‖a‖ + log p := by
  simp [binary_length_of_pos, pos, pp.pos, log_mul_pow2 pos pp, add_right_comm (log a) (log p) 1]

end ISigma₀

section ISigma₁

variable [𝐈𝚺₁.Mod M]

@[simp] lemma log_exponential (a : M) : log (exp a) = a := log_eq_of_exp (exp_exponential a)

lemma exponential_log_le_self {a : M} (pos : 0 < a) : exp (log a) ≤ a := by
  rcases log_pos pos with ⟨_, _, H, _⟩
  rcases H.uniq (exp_exponential (log a))
  assumption

lemma lt_two_mul_exponential_log {a : M} (pos : 0 < a) : a < 2 * exp (log a) := by
  rcases log_pos pos with ⟨_, _, H, _⟩
  rcases H.uniq (exp_exponential (log a))
  assumption

@[simp] lemma binary_length_exponential (a : M) : ‖exp a‖ = a + 1 := by
  simp [binary_length_of_pos]

lemma exp_add (a b : M) : exp (a + b) = exp a * exp b :=
  exponential_of_exp (Exp.add_mul (exp_exponential a) (exp_exponential b))

lemma log_mul_exp_add_of_lt {a b : M} (pos : 0 < a) (i : M) (hb : b < exp i) : log (a * exp i + b) = log a + i := by
  simp [log_mul_pow2_add_of_lt pos (exp_pow2 i) hb]

lemma log_mul_exp {a : M} (pos : 0 < a) (i : M) : log (a * exp i) = log a + i := by
  simp [log_mul_pow2 pos (exp_pow2 i)]

lemma binary_length_mul_exp_add_of_lt {a b : M} (pos : 0 < a) (i : M) (hb : b < exp i) : ‖a * exp i + b‖ = ‖a‖ + i := by
  simp [binary_length_mul_pow2_add_of_lt pos (exp_pow2 i) hb]

lemma binary_length_mul_exp {a : M} (pos : 0 < a) (i : M) : ‖a * exp i‖ = ‖a‖ + i := by
  simp [binary_length_mul_pow2 pos (exp_pow2 i)]

lemma exp_le_iff_le_log {i a : M} (pos : 0 < a) : exp i ≤ a ↔ i ≤ log a :=
  ⟨by intro h; simpa using log_monotone h, fun h ↦ le_trans (exponential_monotone_le.mpr h) (exponential_log_le_self pos)⟩

end ISigma₁

end Model

end

end FirstOrder.Arith

end LO