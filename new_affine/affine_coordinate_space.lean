import .list_as_k_tuple linear_algebra.affine_space.basic
import .affine_with_frame

universes u v w
variables (X : Type u) (k : Type v) (V : Type w) (n : ℕ) (id : ℕ)
[inhabited k] [ring k] [add_comm_group V] [module k V] [affine_space V X]

open list
open vecl
/-- type class for affine vectors. This models n-dimensional K-coordinate space. -/
@[ext]
structure aff_vec :=
(l : list k)
(len_fixed : l.length = n + 1)
(fst_zero : head l = 0)

/-- type class for affine points for coordinate spaces. -/
@[ext]
structure aff_pt :=
(l : list k)
(len_fixed : l.length = n + 1)
(fst_one : head l = 1)

variables (x y : aff_vec k n) (a b : aff_pt k n)

-- lemmas so that the following operations are well-defined
/-- the length of the sum of two length n+1 vectors is n+1 -/
lemma list_sum_fixed : length (ladd x.1 y.1) = n + 1 := 
    by simp only [length_sum x.1 y.1, x.2, y.2, min_self]

lemma aff_not_nil : x.1 ≠ [] := 
begin
intro h,
have f : 0 ≠ n + 1 := ne.symm (nat.succ_ne_zero n),
have len_x_nil : length x.1 = length nil := by rw h,
have len_fixed : length nil = n + 1 := eq.trans (eq.symm len_x_nil) x.2,
have bad : 0 = n + 1 := eq.trans (eq.symm len_nil) len_fixed,
contradiction,
end

lemma aff_cons : ∃ x_hd : k, ∃ x_tl : list k, x.1 = x_hd :: x_tl :=
begin
cases x,
cases x_l,
{
    have f : 0 ≠ n + 1 := ne.symm (nat.succ_ne_zero n),
    have bad := eq.trans (eq.symm len_nil) x_len_fixed,
    contradiction
},
{
    apply exists.intro x_l_hd,
    apply exists.intro x_l_tl,
    exact rfl
}
end

/-- head is compatible with addition -/
lemma head_sum : head x.1 + head y.1 = head (ladd x.1 y.1) := 
begin
cases x,
cases y,
cases x_l,
    have f : 0 ≠ n + 1 := ne.symm (nat.succ_ne_zero n),
    have bad := eq.trans (eq.symm len_nil) x_len_fixed,
    contradiction,
cases y_l,
    have f : 0 ≠ n + 1 := ne.symm (nat.succ_ne_zero n),
    have bad := eq.trans (eq.symm len_nil) y_len_fixed,
    contradiction,
have head_xh : head (x_l_hd :: x_l_tl) = x_l_hd := rfl,
have head_yh : head (y_l_hd :: y_l_tl) = y_l_hd := rfl,
rw head_xh at x_fst_zero,
rw head_yh at y_fst_zero,
simp [x_fst_zero, y_fst_zero, add_cons_cons 0 0 x_l_tl y_l_tl],
end

/-- the head of the sum of two vectors is 0 -/
lemma sum_fst_fixed : head (ladd x.1 y.1) = 0 :=
    by simp only [eq.symm (head_sum k n x y), x.3, y.3]; exact add_zero 0

/-- the length of the zero vector is n+1 -/
lemma len_zero : length (zero_vector k n) = n + 1 :=
begin
induction n with n',
refl,
{
have h₃ : nat.succ (n' + 1) = nat.succ n' + 1 := rfl,
have h₄ : length (zero_vector k (nat.succ n')) = nat.succ (n' + 1) :=
    by {rw eq.symm n_ih, refl},
rw eq.symm h₃,
exact h₄,
}
end

/-- the head of the zero vector is zero -/
lemma head_zero : head (zero_vector k n) = 0 := by {cases n, refl, refl}

lemma vec_len_neg : length (vecl_neg x.1) = n + 1 := by {simp only [len_neg], exact x.2}

lemma head_neg_0 : head (vecl_neg x.1) = 0 :=
begin
cases x,
cases x_l,
contradiction,
rw neg_cons x_l_hd x_l_tl,
have head_xh : head (x_l_hd :: x_l_tl) = x_l_hd := rfl,
have head_0 : head (0 :: vecl_neg x_l_tl) = 0 := rfl,
rw head_xh at x_fst_zero,
simp only [x_fst_zero, neg_zero, head_0],
end

/-! ### abelian group operations -/
def vec_add : aff_vec k n → aff_vec k n → aff_vec k n :=
    λ x y, ⟨ladd x.1 y.1, list_sum_fixed k n x y, sum_fst_fixed k n x y⟩
def vec_zero : aff_vec k n := ⟨zero_vector k n, len_zero k n, head_zero k n⟩
def vec_neg : aff_vec k n → aff_vec k n
| ⟨l, len, fst⟩ := ⟨vecl_neg l, vec_len_neg k n ⟨l, len, fst⟩, head_neg_0 k n ⟨l, len, fst⟩⟩

/-! ### type class instances for the abelian group operations -/
instance : has_add (aff_vec k n) := ⟨vec_add k n⟩
instance : has_zero (aff_vec k n) := ⟨vec_zero k n⟩
instance : has_neg (aff_vec k n) := ⟨vec_neg k n⟩

-- misc
def pt_zero_f : ℕ → list k
| 0 := [1]
| (nat.succ n) := [1] ++ zero_vector k n

lemma pt_zero_len : length (pt_zero_f k n) = n + 1 := sorry

lemma pt_zero_hd : head (pt_zero_f k n) = 1 := by {cases n, refl, refl} 

def pt_zero : aff_pt k n := ⟨pt_zero_f k n, pt_zero_len k n, pt_zero_hd k n⟩

lemma vec_zero_is : (0 : aff_vec k n) = vec_zero k n := rfl

lemma vec_zero_list' : (0 : aff_vec k n).1 = zero_vector k n := rfl

-- properties necessary to show aff_vec K n is an instance of add_comm_group
#print add_comm_group
lemma vec_add_assoc : ∀ x y z : aff_vec k n,  x + y + z = x + (y + z) :=
begin
intros,
cases x,
cases y,
cases z,
dsimp [has_add.add, vec_add],
ext,
split,
intros,
dsimp [ladd, has_add.add] at a_1,
sorry, sorry,
end

lemma vec_zero_add : ∀ x : aff_vec k n, 0 + x = x :=
begin
intro x,
cases x,
rw vec_zero_is,
ext,
split,
intros,
dsimp [has_add.add, vec_add, vec_zero] at a_1,
change a ∈ (ladd (zero_vector k n) x_l).nth n_1 at a_1,
rw zero_ladd' x_l n x_len_fixed at a_1,
exact a_1,

intros,
dsimp [has_add.add, vec_add, vec_zero],
change a ∈ (ladd (zero_vector k n) x_l).nth n_1,
rw zero_ladd' x_l n x_len_fixed,
exact a_1,
end

lemma vec_add_zero : ∀ x : aff_vec k n, x + 0 = x :=
begin
intro x,
cases x,
rw vec_zero_is,
ext,
split,
intros,
dsimp [has_add.add, vec_add, vec_zero] at a_1,
change a ∈ (ladd x_l (zero_vector k n)).nth n_1 at a_1,
rw ladd_zero' x_l n x_len_fixed at a_1,
exact a_1,

intros,
dsimp [has_add.add, vec_add, vec_zero],
change a ∈ (ladd x_l (zero_vector k n)).nth n_1,
rw ladd_zero' x_l n x_len_fixed,
exact a_1,
end

lemma vec_add_left_neg : ∀ x : aff_vec k n, -x + x = 0 :=
begin
intro x,
cases x,
rw vec_zero_is,
ext,
split,
intros,
dsimp [vec_zero],
dsimp [has_neg.neg, vec_neg, has_add.add, vec_add] at a_1,
cases x_l,
contradiction,
have nz : n + 1 ≠ 0 := nat.succ_ne_zero n,
have hnz : (cons x_l_hd x_l_tl).length ≠ 0 := ne_of_eq_of_ne x_len_fixed nz,
change a ∈ (ladd (vecl_neg (x_l_hd :: x_l_tl)) (x_l_hd :: x_l_tl)).nth n_1 at a_1,
rw ladd_left_neg (cons x_l_hd x_l_tl) at a_1,
dsimp [zero_vector] at a_1,
simp only [nat.add_succ_sub_one, add_zero] at a_1,
sorry,
contradiction,
intros,
sorry,
end

lemma vec_add_comm : ∀ x y : aff_vec k n, x + y = y + x :=
begin
intros x y,
cases x,
cases y,
ext,
split,
intros,
dsimp [has_add.add, vec_add],
dsimp [has_add.add, vec_add] at a_1,
change a ∈ (ladd y_l x_l).nth n_1,
rw ladd_comm,
exact a_1,

intros,
dsimp [has_add.add, vec_add],
dsimp [has_add.add, vec_add] at a_1,
change a ∈ (ladd x_l y_l).nth n_1,
rw ladd_comm,
exact a_1,
end

/-! ### Type class instance for abelian group -/
instance aff_comm_group : add_comm_group (aff_vec k n) :=
begin
split,
exact vec_add_left_neg k n,
exact vec_add_comm k n,
exact vec_add_assoc k n,
exact vec_zero_add k n,
exact vec_add_zero k n,
end



/-! ### Scalar action -/
#check semimodule
#check distrib_mul_action
lemma scale_head : ∀ a : k, head (scalar_mul a x.1) = 0 :=
begin
intros,
cases x,
cases x_l,
rw scalar_nil,
contradiction,
have hd0 : x_l_hd = 0 := x_fst_zero,
rw [scalar_cons, hd0, mul_zero],
refl,
end

@[ext]
def vec_scalar : k → aff_vec k n → aff_vec k n :=
    λ a x, ⟨scalar_mul a x.1, trans (scale_len a x.1) x.2, scale_head k n x a⟩

instance : has_scalar k (aff_vec k n) := ⟨vec_scalar k n⟩

lemma vec_one_smul : (1 : k) • x = x := 
begin
cases x,
ext,
split,
intros,
dsimp only [has_scalar.smul, vec_scalar] at a_1,
rw one_smul_cons at a_1,
exact a_1,

intros,
dsimp only [has_scalar.smul, vec_scalar],
rw one_smul_cons,
exact a_1,
end

lemma vec_mul_smul : ∀ g h : k, ∀ x : aff_vec k n, (g * h) • x = g • h • x := sorry

instance : mul_action k (aff_vec k n) := ⟨vec_one_smul k n, vec_mul_smul k n⟩

lemma vec_smul_add : ∀ g : k, ∀ x y : aff_vec k n, g • (x + y) = g•x + g•y := sorry

lemma vec_smul_zero : ∀ g : k, g • (0 : aff_vec k n) = 0 := sorry

instance : distrib_mul_action k (aff_vec k n) := ⟨vec_smul_add k n, vec_smul_zero k n⟩

lemma vec_add_smul : ∀ g h : k, ∀ x : aff_vec k n, (g + h) • x = g•x + h•x := sorry

lemma vec_zero_smul : ∀ x : aff_vec k n, (0 : k) • x = 0 := sorry

instance aff_semimod : semimodule k (aff_vec k n) := ⟨vec_add_smul k n, vec_zero_smul k n⟩

instance aff_module : module k (aff_vec k n) := aff_semimod k n

/-! ### group action of aff_vec on aff_pt -/
-- need to actually write out the function
def aff_group_action : aff_vec k n → aff_pt k n → aff_pt k n :=
    λ x y, ⟨ladd x.1 y.1, sorry, sorry⟩

def aff_group_sub : aff_pt k n → aff_pt k n → aff_vec k n :=
    λ x y, ⟨ladd x.1 (vecl_neg y.1), sorry, sorry⟩

#check add_action

instance : has_vadd (aff_vec k n) (aff_pt k n) := ⟨aff_group_action k n⟩

instance : has_vsub (aff_vec k n) (aff_pt k n) := ⟨aff_group_sub k n⟩

lemma aff_zero_sadd : ∀ x : aff_pt k n, (0 : aff_vec k n) +ᵥ x = x := sorry

lemma aff_add_sadd : ∀ x y : aff_vec k n, ∀ a : aff_pt k n, x +ᵥ (y +ᵥ a) = x + y +ᵥ a := sorry

instance : add_action (aff_vec k n) (aff_pt k n) := ⟨aff_group_action k n, aff_zero_sadd k n, aff_add_sadd k n⟩

lemma aff_add_trans : ∀ a b : aff_pt k n, ∃ x : aff_vec k n, x +ᵥ a = b := sorry

lemma aff_add_free : ∀ a : aff_pt k n, ∀ g h : aff_vec k n, g +ᵥ a = h +ᵥ a → g = h := sorry

lemma aff_vadd_vsub : ∀ a b : aff_pt k n, a -ᵥ b +ᵥ b = a := sorry

instance aff_torsor : add_torsor (aff_vec k n) (aff_pt k n) := 
begin
sorry
end


-- ⟨aff_group_action k n, aff_zero_sadd k n, aff_add_sadd k n, aff_group_sub k n, aff_vadd_vsub k n  ⟩
-- WTS the pair aff_vec and aff_pt form an affine space

instance aff_coord_is : affine_space (aff_vec k n) (aff_pt k n) := aff_torsor k n


variables (ι : Type*) (vec : ι → V) (frame : affine_frame (aff_pt k n) k (aff_vec k n) ι)

open aff_fr

abbreviation vwf := vec_with_frame (aff_pt k n) k (aff_vec k n) ι frame

abbreviation pwf := pt_with_frame (aff_pt k n) k (aff_vec k n) ι frame

/-
def vec_basis : ι → aff_vec k n := λ x, [0, 1, 0, 0] [0, 0, 1, 0] [0, 0, 0, 1]


def f : affine_frame (aff_pt k n) k (aff_vec k n) ι := ⟨[1, 0, 0, 0], vec_basis, pf_that_vec_basis_is_basis⟩

v : vec_with_frame f ⟨[0,1,2,3]⟩

x = aff_pt [1, 0, 0, 0]

new frame -> ⟨v +ᵥ x, new_basis, pf_that_vec_basis_is_basis⟩ ( from f)

frame c = ....
pt = [1, 1, 1]
basis = 
frame a (pt, basis, standard frame)


pt2 = ...
b2 = ...
frame b (pt2, b2, frame a)
-/