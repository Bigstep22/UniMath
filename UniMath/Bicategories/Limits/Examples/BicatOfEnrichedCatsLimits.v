(*********************************************************************************

 Limits of enriched categories

 In this file we construct several limits of enriched categories.

 Contents:
 1. Final object
 2. Equifiers

 *********************************************************************************)
Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Core.NaturalTransformations.
Require Import UniMath.CategoryTheory.Core.Univalence.
Require Import UniMath.CategoryTheory.Subcategory.Core.
Require Import UniMath.CategoryTheory.Subcategory.Full.
Require Import UniMath.CategoryTheory.categories.StandardCategories.
Require Import UniMath.CategoryTheory.Monoidal.MonoidalCategories.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.EnrichedCats.Enrichment.
Require Import UniMath.CategoryTheory.EnrichedCats.EnrichmentFunctor.
Require Import UniMath.CategoryTheory.EnrichedCats.EnrichmentTransformation.
Require Import UniMath.CategoryTheory.EnrichedCats.Examples.UnitEnriched.
Require Import UniMath.CategoryTheory.EnrichedCats.Examples.FullSubEnriched.
Require Import UniMath.Bicategories.Core.Bicat.
Import Bicat.Notations.
Require Import UniMath.Bicategories.Core.Invertible_2cells.
Require Import UniMath.Bicategories.Core.Examples.BicatOfUnivCats.
Require Import UniMath.Bicategories.DisplayedBicats.DispBicat.
Import DispBicat.Notations.
Require Import UniMath.Bicategories.DisplayedBicats.Examples.EnrichedCats.
Require Import UniMath.Bicategories.Limits.Final.
Require Import UniMath.Bicategories.Limits.Equifiers.

Local Open Scope cat.
Local Open Scope moncat.

Opaque mon_linvunitor mon_rinvunitor.

Section LimitsEnrichedCats.
  Context (V : monoidal_cat).

  (**
   1. Final object
   *)

  (**
   Note that to construct the final object, we assume that the
   monoidal category `V` is semi-cartesian, which means that
   the unit is a terminal object. We use this to construct the
   univalent enriched unit category.
   *)
  Section FinalObject.
    Context (HV : isTerminal V 𝟙).

    Let enriched_bifinal : bicat_of_enriched_cats V
      := unit_category ,, unit_enrichment V HV.

    Definition is_bifinal_enriched_cats
      : is_bifinal enriched_bifinal.
    Proof.
      use make_is_bifinal.
      - exact (λ E,
               functor_to_unit _
               ,,
               functor_to_unit_enrichment V HV (pr2 E)).
      - exact (λ C F G,
               unit_category_nat_trans (pr1 F) (pr1 G)
               ,,
               nat_trans_to_unit_enrichment _ _ _ (pr2 F) (pr2 G)).
      - abstract
          (intros C f g α β ;
           use subtypePath ;
           [ intro ; apply isaprop_nat_trans_enrichment
           | ] ;
           apply nat_trans_to_unit_eq).
    Defined.

    Definition bifinal_enriched_cats
      : bifinal_obj (bicat_of_enriched_cats V)
      := enriched_bifinal ,, is_bifinal_enriched_cats.
  End FinalObject.

  (**
   2. Equifiers
   *)
  Section EquifierEnrichedCat.
    Context {E₁ E₂ : bicat_of_enriched_cats V}
            {F G : E₁ --> E₂}
            (τ θ : F ==> G).

    Definition equifier_bicat_of_enriched_cats
      : bicat_of_enriched_cats V.
    Proof.
      simple refine (_ ,, _).
      - use (subcategory_univalent (pr1 E₁)).
        intro x.
        use make_hProp.
        + exact (pr11 τ x = pr11 θ x).
        + apply homset_property.
      - apply (fullsub_enrichment _ (pr2 E₁)).
    Defined.

    Definition equifier_bicat_of_enriched_cats_pr1
      : equifier_bicat_of_enriched_cats --> E₁
      := sub_precategory_inclusion _ _ ,, fullsub_inclusion_enrichment _ _ _.

    Definition equifier_bicat_of_enriched_cats_eq
      : equifier_bicat_of_enriched_cats_pr1 ◃ τ
        =
        equifier_bicat_of_enriched_cats_pr1 ◃ θ.
    Proof.
      use subtypePath.
      {
        intro.
        apply isaprop_nat_trans_enrichment.
      }
      use nat_trans_eq.
      {
        apply homset_property.
      }
      intro x.
      exact (pr2 x).
    Qed.

    Definition equifier_bicat_of_enriched_cats_cone
      : equifier_cone F G τ θ
      := make_equifier_cone
           equifier_bicat_of_enriched_cats
           equifier_bicat_of_enriched_cats_pr1
           equifier_bicat_of_enriched_cats_eq.

    Section EquifierUMP1.
      Context (E₀ : bicat_of_enriched_cats V)
              (H : E₀ --> E₁)
              (q : H ◃ τ = H ◃ θ).

      Definition equifier_bicat_of_enriched_cats_ump_1_functor_data
        : functor_data
            (pr11 E₀)
            (pr11 equifier_bicat_of_enriched_cats).
      Proof.
        use make_functor_data.
        - refine (λ x, pr11 H x ,, _).
          exact (maponpaths (λ z, pr11 z x) q).
        - exact (λ x y f, # (pr11 H) f ,, tt).
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_1_functor_laws
        : is_functor equifier_bicat_of_enriched_cats_ump_1_functor_data.
      Proof.
        split ; intro ; intros.
        - use subtypePath ; [ intro ; apply isapropunit | ] ; cbn.
          apply functor_id.
        - use subtypePath ; [ intro ; apply isapropunit | ] ; cbn.
          apply functor_comp.
      Qed.

      Definition equifier_bicat_of_enriched_cats_ump_1_functor
        : pr11 E₀ ⟶ pr11 equifier_bicat_of_enriched_cats.
      Proof.
        use make_functor.
        - exact equifier_bicat_of_enriched_cats_ump_1_functor_data.
        - exact equifier_bicat_of_enriched_cats_ump_1_functor_laws.
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_1_enrichment
        : functor_enrichment
            equifier_bicat_of_enriched_cats_ump_1_functor
            (pr2 E₀)
            (fullsub_enrichment V (pr2 E₁) _).
      Proof.
        simple refine (_ ,, _).
        - exact (λ x y, pr12 H x y).
        - repeat split.
          + abstract
              (intros x ; cbn ;
               exact (functor_enrichment_id (pr2 H) x)).
          + abstract
              (intros x y z ; cbn ;
               exact (functor_enrichment_comp (pr2 H) x y z)).
          + abstract
              (intros x y f ; cbn ;
               exact (functor_enrichment_from_arr (pr2 H) f)).
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_1_mor
        : E₀ --> equifier_bicat_of_enriched_cats_cone.
      Proof.
        simple refine (_ ,, _).
        - exact equifier_bicat_of_enriched_cats_ump_1_functor.
        - exact equifier_bicat_of_enriched_cats_ump_1_enrichment.
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_1_cell
        : equifier_bicat_of_enriched_cats_ump_1_mor
          · equifier_bicat_of_enriched_cats_pr1
          ==>
          H.
      Proof.
        simple refine (_ ,, _).
        - use make_nat_trans.
          + exact (λ _, identity _).
          + abstract
              (intros x y f ; cbn ;
               rewrite id_left, id_right ;
               apply idpath).
        - abstract
            (intros x y ; cbn ;
             rewrite id_right ;
             rewrite !enriched_from_arr_id ;
             rewrite tensor_split' ;
             rewrite !assoc' ;
             rewrite <- enrichment_id_right ;
             rewrite !assoc ;
             etrans ;
             [ apply maponpaths_2 ;
               refine (!_) ;
               apply tensor_rinvunitor
             | ] ;
             rewrite !assoc' ;
             rewrite mon_rinvunitor_runitor ;
             rewrite id_right ;
             rewrite tensor_split ;
             rewrite !assoc' ;
             rewrite <- enrichment_id_left ;
             rewrite !assoc ;
             refine (!_) ;
             etrans ;
             [ apply maponpaths_2 ;
               refine (!_) ;
               apply tensor_linvunitor
             | ] ;
             rewrite !assoc' ;
             rewrite mon_linvunitor_lunitor ;
             apply id_right).
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_1_inv
        : H
          ==>
          equifier_bicat_of_enriched_cats_ump_1_mor
          · equifier_bicat_of_enriched_cats_pr1.
      Proof.
        simple refine (_ ,, _).
        - use make_nat_trans.
          + exact (λ _, identity _).
          + abstract
              (intros x y f ; cbn ;
               rewrite id_left, id_right ;
               apply idpath).
        - abstract
            (intros x y ; cbn ;
             rewrite id_right ;
             rewrite !enriched_from_arr_id ;
             rewrite tensor_split' ;
             rewrite !assoc' ;
             rewrite <- enrichment_id_right ;
             rewrite !assoc ;
             etrans ;
             [ apply maponpaths_2 ;
               refine (!_) ;
               apply tensor_rinvunitor
             | ] ;
             rewrite !assoc' ;
             rewrite mon_rinvunitor_runitor ;
             rewrite id_right ;
             rewrite tensor_split ;
             rewrite !assoc' ;
             rewrite <- enrichment_id_left ;
             rewrite !assoc ;
             refine (!_) ;
             etrans ;
             [ apply maponpaths_2 ;
               refine (!_) ;
               apply tensor_linvunitor
             | ] ;
             rewrite !assoc' ;
             rewrite mon_linvunitor_lunitor ;
             apply id_right).
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_1_inv2cell
        : invertible_2cell
            (equifier_bicat_of_enriched_cats_ump_1_mor
             · equifier_bicat_of_enriched_cats_pr1)
            H.
      Proof.
        use make_invertible_2cell.
        - exact equifier_bicat_of_enriched_cats_ump_1_cell.
        - use make_is_invertible_2cell.
          + exact equifier_bicat_of_enriched_cats_ump_1_inv.
          + abstract
              (use subtypePath ; [ intro ; apply isaprop_nat_trans_enrichment | ] ;
               use nat_trans_eq ; [ apply homset_property | ] ;
               intro ;
               apply id_right).
          + abstract
              (use subtypePath ; [ intro ; apply isaprop_nat_trans_enrichment | ] ;
               use nat_trans_eq ; [ apply homset_property | ] ;
               intro ;
               apply id_right).
      Defined.
    End EquifierUMP1.

    Definition equifier_bicat_of_enriched_cats_ump_1
      : has_equifier_ump_1 equifier_bicat_of_enriched_cats_cone.
    Proof.
      intros q.
      use make_equifier_1cell.
      - exact (equifier_bicat_of_enriched_cats_ump_1_mor (pr1 q) (pr12 q) (pr22 q)).
      - exact (equifier_bicat_of_enriched_cats_ump_1_inv2cell (pr1 q) (pr12 q) (pr22 q)).
    Defined.

    Section EquifierUMP2.
      Context {D : bicat_of_enriched_cats V}
              {H₁ H₂ : D --> equifier_bicat_of_enriched_cats_cone}
              (α : H₁ · equifier_cone_pr1 equifier_bicat_of_enriched_cats_cone
                   ==>
                   H₂ · equifier_cone_pr1 equifier_bicat_of_enriched_cats_cone).

      Definition equifier_bicat_of_univ_cats_ump_2_nat_trans
        : pr1 H₁ ==> pr1 H₂.
      Proof.
        use make_nat_trans.
        - exact (λ x, pr11 α x ,, tt).
        - abstract
            (intros x y f ;
             use subtypePath ; [ intro ; apply isapropunit | ] ;
             cbn ;
             exact (nat_trans_ax (pr1 α) _ _ f)).
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_2_enrichment
        : nat_trans_enrichment
            (pr1 equifier_bicat_of_univ_cats_ump_2_nat_trans)
            (pr2 H₁)
            (pr2 H₂).
      Proof.
        intros x y ; cbn.
        pose (pr2 α x y) as p.
        cbn in p.
        rewrite !id_right in p.
        exact p.
      Qed.

      Definition equifier_bicat_of_enriched_cats_ump_2_cell
        : H₁ ==> H₂.
      Proof.
        simple refine (_ ,, _).
        - exact equifier_bicat_of_univ_cats_ump_2_nat_trans.
        - exact equifier_bicat_of_enriched_cats_ump_2_enrichment.
      Defined.

      Definition equifier_bicat_of_enriched_cats_ump_2_eq
        : equifier_bicat_of_enriched_cats_ump_2_cell ▹ _  = α.
      Proof.
        use subtypePath.
        {
          intro.
          apply isaprop_nat_trans_enrichment.
        }
        use nat_trans_eq.
        {
          apply homset_property.
        }
        intro x.
        apply idpath.
      Qed.
    End EquifierUMP2.

    Definition equifier_bicat_of_enriched_cats_ump_2
      : has_equifier_ump_2 equifier_bicat_of_enriched_cats_cone.
    Proof.
      intros D H₁ H₂ α.
      exact (equifier_bicat_of_enriched_cats_ump_2_cell α
             ,,
             equifier_bicat_of_enriched_cats_ump_2_eq α).
    Defined.

    Definition equifier_bicat_of_enriched_cats_ump_eq
      : has_equifier_ump_eq equifier_bicat_of_enriched_cats_cone.
    Proof.
      intros D H₁ H₂ α φ₁ φ₂ p q.
      use subtypePath.
      {
        intro.
        apply isaprop_nat_trans_enrichment.
      }
      use nat_trans_eq.
      {
        apply homset_property.
      }
      intro x.
      use subtypePath.
      {
        intro.
        apply isapropunit.
      }
      exact (maponpaths (λ z, pr11 z x) (p @ !q)).
    Qed.
  End EquifierEnrichedCat.

  Definition has_equifiers_bicat_of_enriched_cats
    : has_equifiers (bicat_of_enriched_cats V).
  Proof.
    intros E₁ E₂ F G τ θ.
    simple refine (_ ,, _ ,, _ ,, _).
    - exact (equifier_bicat_of_enriched_cats τ θ).
    - exact (equifier_bicat_of_enriched_cats_pr1 τ θ).
    - exact (equifier_bicat_of_enriched_cats_eq τ θ).
    - simple refine (_ ,, _ ,, _).
      + exact (equifier_bicat_of_enriched_cats_ump_1 τ θ).
      + exact (equifier_bicat_of_enriched_cats_ump_2 τ θ).
      + exact (equifier_bicat_of_enriched_cats_ump_eq τ θ).
  Defined.
End LimitsEnrichedCats.
