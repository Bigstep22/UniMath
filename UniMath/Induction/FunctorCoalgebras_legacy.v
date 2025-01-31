(** ***************************************************************

Contents:
 - Category of coalgebras over an endofunctor.
 - Dual of Lambek's lemma: if (A,α) is terminal coalgebra, α is an isomorphism.

******************************************************************)

Require Import UniMath.Foundations.Propositions.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.limits.terminal.

Local Open Scope cat.

Section Coalgebra_Definition.

Context {C : precategory} (F : functor C C).

Definition coalgebra : UU := ∑ X : C, X --> F X.

Definition coalgebra_ob (X : coalgebra) : C := pr1 X.
Local Coercion coalgebra_ob : coalgebra >-> ob.

Definition coalgebra_mor (X : coalgebra) : C ⟦X, F X ⟧ := pr2 X.

(** A homomorphism of F-coalgebras (F A, α : C ⟦A, F A⟧) and (F B, β : C ⟦B, F B⟧)
    is a morphism f : C ⟦A, B⟧ s.t. the below diagram commutes.

  <<
         f
     A -----> B
     |        |
     | α      | β
     |        |
     V        V
    F A ---> F B
        F f
  >>
*)

Definition is_coalgebra_homo {X Y : coalgebra} (f : C ⟦X, Y⟧) : UU
  := (coalgebra_mor X) · #F f = f · (coalgebra_mor Y).

Definition coalgebra_homo (X Y : coalgebra) := ∑ f : C ⟦X, Y⟧, is_coalgebra_homo f.


Definition mor_from_coalgebra_homo (X Y : coalgebra) (f : coalgebra_homo X Y)
  : C ⟦X, Y⟧ := pr1 f.
Coercion mor_from_coalgebra_homo : coalgebra_homo >-> precategory_morphisms.

Definition coalgebra_homo_eq (hasHom : has_homsets C) {X Y : coalgebra}
           (f g : coalgebra_homo X Y) : (f : C ⟦X, Y⟧) = g ≃ f = g.
Proof.
  apply invweq.
  apply subtypeInjectivity.
  intro. apply hasHom.
Defined.

Lemma coalgebra_homo_commutes {X Y : coalgebra} (f : coalgebra_homo X Y)
  : (coalgebra_mor X) · #F f = f · (coalgebra_mor Y).
Proof.
  exact (pr2 f).
Defined.

Definition coalgebra_homo_id (X : coalgebra) : coalgebra_homo X X.
Proof.
  exists (identity _).
  unfold is_coalgebra_homo.
  rewrite id_left.
  rewrite functor_id.
  rewrite id_right.
  apply idpath.
Defined.

Definition coalgebra_homo_comp (X Y Z : coalgebra) (f : coalgebra_homo X Y)
           (g : coalgebra_homo Y Z) : coalgebra_homo X Z.
Proof.
  exists (f · g).
  unfold is_coalgebra_homo.
  rewrite functor_comp.
  rewrite assoc.
  rewrite coalgebra_homo_commutes.
  rewrite <- assoc.
  rewrite coalgebra_homo_commutes.
  rewrite assoc.
  apply idpath.
Defined.

Definition CoAlg_precategory_ob_mor : precategory_ob_mor :=
  make_precategory_ob_mor coalgebra coalgebra_homo.

Definition CoAlg_precategory_data: precategory_data :=
  make_precategory_data CoAlg_precategory_ob_mor
                        coalgebra_homo_id
                        coalgebra_homo_comp.

End Coalgebra_Definition.


Definition isaset_coalgebra_homo {C : category}  (F : functor C C) {X Y : coalgebra F}
           : isaset (coalgebra_homo F X Y).
Proof.
  apply (isofhleveltotal2 2).
  - apply C.
  - intro f.
    apply isasetaprop.
    apply C.
Defined.

Lemma CoAlg_is_precategory {C : category}  (F : functor C C)
  : is_precategory (CoAlg_precategory_data F).
Proof.
  split.
  - split.
    + intros. apply coalgebra_homo_eq.
      * apply C.
      * apply id_left.
    + intros. apply coalgebra_homo_eq.
      * apply C.
      * apply id_right.
  - { split.
      - intros.
        apply coalgebra_homo_eq.
        + apply C.
        + apply assoc.
      - intros.
        apply coalgebra_homo_eq.
        + apply C.
        + apply assoc'. }
Defined.

Definition CoAlg_precategory {C : category}  (F : functor C C) : precategory
  := make_precategory (CoAlg_precategory_data F) (CoAlg_is_precategory F).

Lemma has_homsets_coalgebra {C : category}  (F : functor C C) : has_homsets (CoAlg_precategory F).
Proof.
  intros f g.
  apply isaset_coalgebra_homo.
Defined.

Definition CoAlg_category {C : category}  (F : functor C C) : category
  := make_category _ (has_homsets_coalgebra F).


Section Lambek_dual.
(** Dual of Lambeks Lemma : If (A,α) is terminal F-coalgebra, then α is an iso *)

Context (C : category)
        (F : functor C C)
        (X : coalgebra F).

Local Notation F_CoAlg := (CoAlg_category F).

Context (isTerminalX : isTerminal F_CoAlg X).

Definition TerminalX : Terminal F_CoAlg := make_Terminal _ isTerminalX.

Local Notation α := (coalgebra_mor _ (TerminalObject TerminalX)).
Local Notation A := (coalgebra_ob _ (TerminalObject TerminalX)).

(** FX := (FA,Fα) is also an F-coalgebra *)
Definition FX : coalgebra F := tpair _ (F A) (#F α).

(** By terminality there is an arrow α' : FA → A, s.t.:
  <<
         α'
    FA ------> A
    |          |
    | Fα       | α
    V          V
   FFA ------> FA
         Fα'
  >>
  commutes *)

Definition f : F_CoAlg ⟦FX, TerminalX⟧ := (@TerminalArrow F_CoAlg TerminalX FX).

Definition α' : C ⟦F A, A⟧ := mor_from_coalgebra_homo F FX X f.

Definition αα'_mor : coalgebra_homo F X X.
Proof.
  exists (α · α').
  unfold is_coalgebra_homo.
  rewrite <- assoc.
  apply cancel_precomposition.
  rewrite functor_comp.
  apply (coalgebra_homo_commutes F f).
Defined.

Definition αα'_idA : α · α' = identity A
  := maponpaths pr1 (TerminalEndo_is_identity (T:=TerminalX) αα'_mor).

Lemma α'α_idFA : α' · α = identity (F A).
Proof.
  rewrite <- functor_id.
  rewrite <- αα'_idA.
  rewrite functor_comp.
  unfold α'.
  apply pathsinv0.
  apply (coalgebra_homo_commutes F f).
Defined.

Lemma terminalcoalgebra_isiso : is_iso α.
Proof.
  apply (is_iso_qinv α α').
  split.
  - exact αα'_idA.
  - exact α'α_idFA.
Defined.

Definition terminalcoalgebra_iso : iso A (F A) := make_iso α terminalcoalgebra_isiso.

End Lambek_dual.
