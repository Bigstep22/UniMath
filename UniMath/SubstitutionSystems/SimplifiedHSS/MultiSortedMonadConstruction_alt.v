(**

This file contains the final steps of the formalization of multisorted binding signatures:

- Construction of a monad on C^sort from a multisorted signature
  ([MultiSortedSigToMonad])
- Instantiation of MultiSortedSigToMonad for C = Set
  ([MultiSortedSigToMonadSet])

Written by: Anders Mörtberg, 2021. The formalization is an adaptation of
Multisorted.v

version for simplified notion of HSS by Ralph Matthes (2022, 2023)
the file is identical to the homonymous file in the parent directory, except for importing files from the present directory

*)
Require Import UniMath.Foundations.PartD.
Require Import UniMath.Foundations.Sets.

Require Import UniMath.MoreFoundations.Tactics.

Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.FunctorCategory.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.limits.binproducts.
Require Import UniMath.CategoryTheory.limits.products.
Require Import UniMath.CategoryTheory.limits.bincoproducts.
Require Import UniMath.CategoryTheory.limits.coproducts.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.FunctorAlgebras.
Require Import UniMath.CategoryTheory.exponentials.
Require Import UniMath.CategoryTheory.Chains.All.
Require Import UniMath.CategoryTheory.Monads.Monads.
Require Import UniMath.CategoryTheory.categories.HSET.Core.
Require Import UniMath.CategoryTheory.categories.HSET.Colimits.
Require Import UniMath.CategoryTheory.categories.HSET.Limits.
Require Import UniMath.CategoryTheory.categories.HSET.Structures.
Require Import UniMath.CategoryTheory.categories.StandardCategories.
Require Import UniMath.CategoryTheory.Groupoids.

Require Import UniMath.SubstitutionSystems.Signatures.
Require Import UniMath.SubstitutionSystems.SumOfSignatures.
Require Import UniMath.SubstitutionSystems.BinProductOfSignatures.
Require Import UniMath.SubstitutionSystems.SimplifiedHSS.SubstitutionSystems.
Require Import UniMath.SubstitutionSystems.SimplifiedHSS.LiftingInitial_alt.
Require Import UniMath.SubstitutionSystems.SimplifiedHSS.MonadsFromSubstitutionSystems.
Require Import UniMath.SubstitutionSystems.SignatureExamples.
Require Import UniMath.SubstitutionSystems.SimplifiedHSS.BindingSigToMonad.
Require Import UniMath.SubstitutionSystems.MultiSorted_alt.

Local Open Scope cat.

Section MBindingSig.

(* Interestingly we only need that [sort] is a 1-type *)
Variables (sort : UU) (Hsort : isofhlevel 3 sort) (C : category).

(* Assumptions on [C] used to construct the functor *)
(* Note that there is some redundancy in the assumptions *)
Variables (TC : Terminal C) (IC : Initial C)
          (BP : BinProducts C) (BC : BinCoproducts C)
          (PC : forall (I : UU), Products I C) (CC : forall (I : UU), isaset I → Coproducts I C).

Local Notation "'1'" := (TerminalObject TC).
Local Notation "a ⊕ b" := (BinCoproductObject (BC a b)).

(** Define the discrete category of sorts *)
Let sort_cat : category := path_pregroupoid sort Hsort.

(** This represents "sort → C" *)
Let sortToC : category := [sort_cat,C].
Let make_sortToC (f : sort → C) : sortToC := functor_path_pregroupoid Hsort f.

Let BCsortToC : BinCoproducts sortToC := BinCoproducts_functor_precat _ _ BC.
Let BPC : BinProducts [sortToC,C] := BinProducts_functor_precat sortToC C BP.

(* Assumptions needed to prove ω-cocontinuity of the functor *)
Variables (expSortToCC : Exponentials BPC)
          (HC : Colims_of_shape nat_graph C).
(* The expSortToCC assumption says that [sortToC,C] has exponentials. It
   could be reduced to exponentials in C, but we only have the case
   for C = Set formalized in

     CategoryTheory.categories.HSET.Structures.Exponentials_functor_HSET

 *)

(** * Construction of a monad from a multisorted signature *)
Section monad.

Let Id_H := Id_H sortToC BCsortToC.

(* ** Construction of initial algebra for a signature with strength on C^sort *)
Definition SignatureInitialAlgebra
  (H : Signature sortToC sortToC sortToC) (Hs : is_omega_cocont H) :
  Initial (FunctorAlg (Id_H H)).
Proof.
use colimAlgInitial.
- apply Initial_functor_precat, Initial_functor_precat, IC.
- apply (is_omega_cocont_Id_H), Hs.
- apply ColimsFunctorCategory_of_shape, ColimsFunctorCategory_of_shape, HC.
Defined.

Let HSS := @hss_category _ BCsortToC.

(* ** Multisorted signature to a HSS *)
Definition MultiSortedSigToHSS (sig : MultiSortedSig sort) :
  HSS (MultiSortedSigToSignature sort Hsort C TC BP BC CC sig).
Proof.
apply SignatureToHSS.
+ apply Initial_functor_precat, IC.
+ apply ColimsFunctorCategory_of_shape, HC.
+ apply is_omega_cocont_MultiSortedSigToSignature; try assumption.
Defined.

(* The above HSS is initial *)
Definition MultiSortedSigToHSSisInitial (sig : MultiSortedSig sort) :
  isInitial _ (MultiSortedSigToHSS sig).
Proof.
now unfold MultiSortedSigToHSS, SignatureToHSS; destruct InitialHSS.
Qed.

(** ** Function from multisorted binding signatures to monads *)
Definition MultiSortedSigToMonad (sig : MultiSortedSig sort) : Monad sortToC.
Proof.
use Monad_from_hss.
- apply BCsortToC.
- apply (MultiSortedSigToSignature sort Hsort C TC BP BC CC sig).
- apply MultiSortedSigToHSS.
Defined.

End monad.

End MBindingSig.

Section MBindingSigMonadHSET.

(* Assume a set of sorts *)
Context (sort : hSet) (Hsort : isofhlevel 3 sort).

Let sortToSet : category := [path_pregroupoid sort Hsort, HSET].

Definition projSortToSet : sort → functor sortToSet HSET :=
  projSortToC sort Hsort HSET.

Definition hat_functorSet : sort → HSET ⟶ sortToSet :=
  hat_functor sort (isofhlevelssnset 1 _ (setproperty sort)) HSET CoproductsHSET.

Definition sorted_option_functorSet : sort → sortToSet ⟶ sortToSet :=
  sorted_option_functor _ (isofhlevelssnset 1 _ (setproperty sort)) HSET
                        TerminalHSET BinCoproductsHSET CoproductsHSET.

Definition MultiSortedSigToSignatureSet : MultiSortedSig sort → Signature sortToSet sortToSet sortToSet.
Proof.
use MultiSortedSigToSignature.
- apply TerminalHSET.
- apply BinProductsHSET.
- apply BinCoproductsHSET.
- apply CoproductsHSET.
Defined.

Definition MultiSortedSigToMonadSet (ms : MultiSortedSig sort) :
  Monad sortToSet.
Proof.
use MultiSortedSigToMonad.
- apply TerminalHSET.
- apply InitialHSET.
- apply BinProductsHSET.
- apply BinCoproductsHSET.
- apply ProductsHSET.
- apply CoproductsHSET.
- apply Exponentials_functor_HSET.
- apply ColimsHSET_of_shape.
- apply ms.
Defined.

End MBindingSigMonadHSET.
