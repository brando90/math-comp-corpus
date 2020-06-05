
From mathcomp Require Import ssreflect ssrbool ssrfun eqtype ssrnat seq div.
From mathcomp Require Import choice fintype tuple finfun bigop ssralg poly.
From mathcomp Require Import polydiv finset fingroup morphism quotient perm.
From mathcomp Require Import action zmodp cyclic matrix mxalgebra vector.
From mathcomp Require Import falgebra fieldext separable.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Reserved Notation "''Gal' ( A / B )"
  (at level 8, A at level 35, format "''Gal' ( A  /  B )").

Import GroupScope GRing.Theory.
Local Open Scope ring_scope.

Section SplittingFieldFor.

Variables (F : fieldType) (L : fieldExtType F).

Definition splittingFieldFor (U : {vspace L}) (p : {poly L}) (V : {vspace L}) :=
  exists2 rs, p %= \prod_(z <- rs) ('X - z%:P) & <<U & rs>>%VS = V.

Lemma splittingFieldForS (K M E : {subfield L}) p :
    (K <= M)%VS -> (M <= E)%VS ->
  splittingFieldFor K p E -> splittingFieldFor M p E.
Proof.
move=> sKM sKE [rs Dp genL]; exists rs => //; apply/eqP.
rewrite eqEsubv -[in X in _ && (X <= _)%VS]genL adjoin_seqSl // andbT.
by apply/Fadjoin_seqP; split; rewrite // -genL; apply: seqv_sub_adjoin.
Qed.

End SplittingFieldFor.

Section kHom.

Variables (F : fieldType) (L : fieldExtType F).
Implicit Types (U V : {vspace L}) (K E : {subfield L}) (f g : 'End(L)).

Definition kHom U V f := ahom_in V f && (U <= fixedSpace f)%VS.

Lemma kHomP {K V f} :
  reflect [/\ {in V &, forall x y, f (x * y) = f x * f y}
            & {in K, forall x, f x = x}]
          (kHom K V f).
Proof.
apply: (iffP andP) => [[/ahom_inP[fM _] /subvP idKf] | [fM idKf]].
  by split=> // x /idKf/fixedSpaceP.
split; last by apply/subvP=> x /idKf/fixedSpaceP.
by apply/ahom_inP; split=> //; rewrite idKf ?mem1v.
Qed.

Lemma kAHomP {U V} {f : 'AEnd(L)} :
  reflect {in U, forall x, f x = x} (kHom U V f).
Proof. by rewrite /kHom ahomWin; apply: fixedSpacesP. Qed.

Lemma kHom1 U V : kHom U V \1.
Proof. by apply/kAHomP => u _; rewrite lfunE. Qed.

Lemma k1HomE V f : kHom 1 V f = ahom_in V f.
Proof. by apply: andb_idr => /ahom_inP[_ f1]; apply/fixedSpaceP. Qed.

Lemma kHom_lrmorphism (f : 'End(L)) : reflect (lrmorphism f) (kHom 1 {:L} f).
Proof. by rewrite k1HomE; apply: ahomP. Qed.

Lemma k1AHom V (f : 'AEnd(L)) : kHom 1 V f.
Proof. by rewrite k1HomE ahomWin. Qed.

Lemma kHom_poly_id K E f p :
  kHom K E f -> p \is a polyOver K -> map_poly f p = p.
Proof.
by case/kHomP=> _ idKf /polyOverP Kp; apply/polyP=> i; rewrite coef_map /= idKf.
Qed.

Lemma kHomSl U1 U2 V f : (U1 <= U2)%VS -> kHom U2 V f -> kHom U1 V f.
Proof. by rewrite /kHom => sU12 /andP[-> /(subv_trans sU12)]. Qed.

Lemma kHomSr K V1 V2 f : (V1 <= V2)%VS -> kHom K V2 f -> kHom K V1 f.
Proof. by move/subvP=> sV12 /kHomP[/(sub_in2 sV12)fM idKf]; apply/kHomP. Qed.

Lemma kHomS K1 K2 V1 V2 f :
  (K1 <= K2)%VS -> (V1 <= V2)%VS -> kHom K2 V2 f -> kHom K1 V1 f.
Proof. by move=> sK12 sV12 /(kHomSl sK12)/(kHomSr sV12). Qed.

Lemma kHom_eq K E f g :
  (K <= E)%VS -> {in E, f =1 g} -> kHom K E f = kHom K E g.
Proof.
move/subvP=> sKE eq_fg; wlog suffices: f g eq_fg / kHom K E f -> kHom K E g.
  by move=> IH; apply/idP/idP; apply: IH => x /eq_fg.
case/kHomP=> fM idKf; apply/kHomP.
by split=> [x y Ex Ey | x Kx]; rewrite -!eq_fg ?fM ?rpredM // ?idKf ?sKE.
Qed.

Lemma kHom_inv K E f : kHom K E f -> {in E, {morph f : x / x^-1}}.
Proof.
case/kHomP=> fM idKf x Ex.
case (eqVneq x 0) => [-> | nz_x]; first by rewrite linear0 invr0 linear0.
have fxV: f x * f x^-1 = 1 by rewrite -fM ?rpredV ?divff // idKf ?mem1v.
have Ufx: f x \is a GRing.unit by apply/unitrPr; exists (f x^-1).
by apply: (mulrI Ufx); rewrite divrr.
Qed.

Lemma kHom_dim K E f : kHom K E f -> \dim (f @: E) = \dim E.
Proof.
move=> homKf; have [fM idKf] := kHomP homKf.
apply/limg_dim_eq/eqP; rewrite -subv0; apply/subvP=> v.
rewrite memv_cap memv0 memv_ker => /andP[Ev]; apply: contraLR => nz_v.
by rewrite -unitfE unitrE -(kHom_inv homKf) // -fM ?rpredV ?divff ?idKf ?mem1v.
Qed.

Lemma kHom_is_rmorphism K E f :
  kHom K E f -> rmorphism (f \o vsval : subvs_of E -> L).
Proof.
case/kHomP=> fM idKf; split=> [a b|]; first exact: raddfB.
by split=> [a b|] /=; [rewrite /= fM ?subvsP | rewrite algid1 idKf // mem1v].
Qed.
Definition kHom_rmorphism K E f homKEf :=
  RMorphism (@kHom_is_rmorphism K E f homKEf).

Lemma kHom_horner K E f p x :
  kHom K E f -> p \is a polyOver E -> x \in E -> f p.[x] = (map_poly f p).[f x].
Proof.
move=> homKf /polyOver_subvs[{p}p -> Ex]; pose fRM := kHom_rmorphism homKf.
by rewrite (horner_map _ _ (Subvs Ex)) -[f _](horner_map fRM) map_poly_comp.
Qed.

Lemma kHom_root K E f p x :
    kHom K E f -> p \is a polyOver E -> x \in E -> root p x ->
  root (map_poly f p) (f x).
Proof.
by move/kHom_horner=> homKf Ep Ex /rootP px0; rewrite /root -homKf ?px0 ?raddf0.
Qed.

Lemma kHom_root_id K E f p x :
   (K <= E)%VS -> kHom K E f -> p \is a polyOver K -> x \in E -> root p x ->
  root p (f x).
Proof.
move=> sKE homKf Kp Ex /(kHom_root homKf (polyOverSv sKE Kp) Ex).
by rewrite (kHom_poly_id homKf).
Qed.

Section kHomExtend.

Variables (K E : {subfield L}) (f : 'End(L)) (x y : L).

Fact kHomExtend_subproof :
  linear (fun z => (map_poly f (Fadjoin_poly E x z)).[y]).
Proof.
move=> k a b; rewrite linearP /= raddfD hornerE; congr (_ + _).
rewrite -[rhs in _ = rhs]mulr_algl -hornerZ /=; congr _.[_].
by apply/polyP => i; rewrite !(coefZ, coef_map) /= !mulr_algl linearZ.
Qed.
Definition kHomExtend := linfun (Linear kHomExtend_subproof).

Lemma kHomExtendE z : kHomExtend z = (map_poly f (Fadjoin_poly E x z)).[y].
Proof. by rewrite lfunE. Qed.

Hypotheses (sKE : (K <= E)%VS) (homKf : kHom K E f).
Local Notation Px := (minPoly E x).
Hypothesis fPx_y_0 : root (map_poly f Px) y.

Lemma kHomExtend_id z : z \in E -> kHomExtend z = f z.
Proof. by move=> Ez; rewrite kHomExtendE Fadjoin_polyC ?map_polyC ?hornerC. Qed.

Lemma kHomExtend_val : kHomExtend x = y.
Proof.
have fX: map_poly f 'X = 'X by rewrite (kHom_poly_id homKf) ?polyOverX.
have [Ex | E'x] := boolP (x \in E); last first.
  by rewrite kHomExtendE Fadjoin_polyX // fX hornerX.
have:= fPx_y_0; rewrite (minPoly_XsubC Ex) raddfB /= map_polyC fX root_XsubC /=.
by rewrite (kHomExtend_id Ex) => /eqP->.
Qed.

Lemma kHomExtend_poly p :
  p \in polyOver E -> kHomExtend p.[x] = (map_poly f p).[y].
Proof.
move=> Ep; rewrite kHomExtendE (Fadjoin_poly_mod x) //.
rewrite (divp_eq (map_poly f p) (map_poly f Px)).
rewrite !hornerE (rootP fPx_y_0) mulr0 add0r.
have [p1 ->] := polyOver_subvs Ep.
have [Px1 ->] := polyOver_subvs (minPolyOver E x).
by rewrite -map_modp -!map_poly_comp (map_modp (kHom_rmorphism homKf)).
Qed.

Lemma kHomExtendP : kHom K <<E; x>> kHomExtend.
Proof.
have [fM idKf] := kHomP homKf.
apply/kHomP; split=> [|z Kz]; last by rewrite kHomExtend_id ?(subvP sKE) ?idKf.
move=> _ _ /Fadjoin_polyP[p Ep ->] /Fadjoin_polyP[q Eq ->].
rewrite -hornerM !kHomExtend_poly ?rpredM // -hornerM; congr _.[_].
apply/polyP=> i; rewrite coef_map !coefM /= linear_sum /=.
by apply: eq_bigr => j _; rewrite !coef_map /= fM ?(polyOverP _).
Qed.

End kHomExtend.

Definition kAut U V f := kHom U V f && (f @: V == V)%VS.

Lemma kAutE K E f : kAut K E f = kHom K E f && (f @: E <= E)%VS.
Proof.
apply/andP/andP=> [[-> /eqP->] // | [homKf EfE]].
by rewrite eqEdim EfE /= (kHom_dim homKf).
Qed.

Lemma kAutS U1 U2 V f : (U1 <= U2)%VS -> kAut U2 V f -> kAut U1 V f.
Proof. by move=> sU12 /andP[/(kHomSl sU12)homU1f EfE]; apply/andP. Qed.

Lemma kHom_kAut_sub K E f : kAut K E f -> kHom K E f. Proof. by case/andP. Qed.

Lemma kAut_eq K E (f g : 'End(L)) :
  (K <= E)%VS -> {in E, f =1 g} -> kAut K E f = kAut K E g.
Proof.
by move=> sKE eq_fg; rewrite !kAutE (kHom_eq sKE eq_fg) (eq_in_limg eq_fg).
Qed.

Lemma kAutfE K f : kAut K {:L} f = kHom K {:L} f.
Proof. by rewrite kAutE subvf andbT. Qed.

Lemma kAut1E E (f : 'AEnd(L)) : kAut 1 E f = (f @: E <= E)%VS.
Proof. by rewrite kAutE k1AHom. Qed.

Lemma kAutf_lker0 K f : kHom K {:L} f -> lker f == 0%VS.
Proof.
move/(kHomSl (sub1v _))/kHom_lrmorphism=> fM.
by apply/lker0P; apply: (fmorph_inj (RMorphism fM)).
Qed.

Lemma inv_kHomf K f : kHom K {:L} f -> kHom K {:L} f^-1.
Proof.
move=> homKf; have [[fM idKf] kerf0] := (kHomP homKf, kAutf_lker0 homKf).
have f1K: cancel f^-1%VF f by apply: lker0_lfunVK.
apply/kHomP; split=> [x y _ _ | x Kx]; apply: (lker0P kerf0).
  by rewrite fM ?memvf ?{1}f1K.
by rewrite f1K idKf.
Qed.

Lemma inv_is_ahom (f : 'AEnd(L)) : ahom_in {:L} f^-1.
Proof.
have /ahomP/kHom_lrmorphism hom1f := valP f.
exact/ahomP/kHom_lrmorphism/inv_kHomf.
Qed.

Canonical inv_ahom (f : 'AEnd(L)) : 'AEnd(L) := AHom (inv_is_ahom f).
Notation "f ^-1" := (inv_ahom f) : lrfun_scope.

Lemma comp_kHom_img K E f g :
  kHom K (g @: E) f -> kHom K E g -> kHom K E (f \o g).
Proof.
move=> /kHomP[fM idKf] /kHomP[gM idKg]; apply/kHomP; split=> [x y Ex Ey | x Kx].
  by rewrite !lfunE /= gM // fM ?memv_img.
by rewrite lfunE /= idKg ?idKf.
Qed.

Lemma comp_kHom K E f g : kHom K {:L} f -> kHom K E g -> kHom K E (f \o g).
Proof. by move/(kHomSr (subvf (g @: E))); apply: comp_kHom_img. Qed.

Lemma kHom_extends K E f p U :
    (K <= E)%VS -> kHom K E f ->
     p \is a polyOver K -> splittingFieldFor E p U ->
  {g | kHom K U g & {in E, f =1 g}}.
Proof.
move=> sKE homEf Kp /sig2_eqW[rs Dp <-{U}].
set r := rs; have rs_r: all (mem rs) r by apply/allP.
elim: r rs_r => [_|z r IHr /=/andP[rs_z rs_r]] /= in E f sKE homEf *.
  by exists f; rewrite ?Fadjoin_nil.
set Ez := <<E; z>>%AS; pose fpEz := map_poly f (minPoly E z).
suffices{IHr} /sigW[y fpEz_y]: exists y, root fpEz y.
  have homEz_fz: kHom K Ez (kHomExtend E f z y) by apply: kHomExtendP.
  have sKEz: (K <= Ez)%VS := subv_trans sKE (subv_adjoin E z).
  have [g homGg Dg] := IHr rs_r _ _ sKEz homEz_fz.
  exists g => [|x Ex]; first by rewrite adjoin_cons.
  by rewrite -Dg ?subvP_adjoin // kHomExtend_id.
have [m DfpEz]: {m | fpEz %= \prod_(w <- mask m rs) ('X - w%:P)}.
  apply: dvdp_prod_XsubC; rewrite -(eqp_dvdr _ Dp) -(kHom_poly_id homEf Kp).
  have /polyOver_subvs[q Dq] := polyOverSv sKE Kp.
  have /polyOver_subvs[qz Dqz] := minPolyOver E z.
  rewrite /fpEz Dq Dqz -2?{1}map_poly_comp (dvdp_map (kHom_rmorphism homEf)).
  rewrite -(dvdp_map [rmorphism of @vsval _ _ E]) -Dqz -Dq.
  by rewrite minPoly_dvdp ?(polyOverSv sKE) // (eqp_root Dp) root_prod_XsubC.
exists (mask m rs)`_0; rewrite (eqp_root DfpEz) root_prod_XsubC mem_nth //.
rewrite -ltnS -(size_prod_XsubC _ id) -(eqp_size DfpEz).
rewrite size_poly_eq -?lead_coefE ?size_minPoly // (monicP (monic_minPoly E z)).
by have [_ idKf] := kHomP homEf; rewrite idKf ?mem1v ?oner_eq0.
Qed.

End kHom.

Notation "f ^-1" := (inv_ahom f) : lrfun_scope.

Arguments kHomP {F L K V f}.
Arguments kAHomP {F L U V f}.
Arguments kHom_lrmorphism {F L f}.

Module SplittingField.

Import GRing.

Section ClassDef.

Variable F : fieldType.

Definition axiom (L : fieldExtType F) :=
  exists2 p : {poly L}, p \is a polyOver 1%VS & splittingFieldFor 1 p {:L}.

Record class_of (L : Type) : Type :=
  Class {base : FieldExt.class_of F L; _ : axiom (FieldExt.Pack _ base)}.
Local Coercion base : class_of >-> FieldExt.class_of.

Structure type (phF : phant F) := Pack {sort; _ : class_of sort}.
Local Coercion sort : type >-> Sortclass.
Variable (phF : phant F) (T : Type) (cT : type phF).
Definition class := let: Pack _ c as cT' := cT return class_of cT' in c.
Let xT := let: Pack T _ := cT in T.
Notation xclass := (class : class_of xT).

Definition clone c of phant_id class c := @Pack phF T c.

Definition pack b0 (ax0 : axiom (@FieldExt.Pack F (Phant F) T b0)) :=
 fun bT b & phant_id (@FieldExt.class F phF bT) b =>
 fun   ax & phant_id ax0 ax => Pack (Phant F) (@Class T b ax).

Definition eqType := @Equality.Pack cT xclass.
Definition choiceType := @Choice.Pack cT xclass.
Definition zmodType := @Zmodule.Pack cT xclass.
Definition ringType := @Ring.Pack cT xclass.
Definition unitRingType := @UnitRing.Pack cT xclass.
Definition comRingType := @ComRing.Pack cT xclass.
Definition comUnitRingType := @ComUnitRing.Pack cT xclass.
Definition idomainType := @IntegralDomain.Pack cT xclass.
Definition fieldType := @Field.Pack cT xclass.
Definition lmodType := @Lmodule.Pack F phF cT xclass.
Definition lalgType := @Lalgebra.Pack F phF cT xclass.
Definition algType := @Algebra.Pack F phF cT xclass.
Definition unitAlgType := @UnitAlgebra.Pack F phF cT xclass.
Definition vectType := @Vector.Pack F phF cT xclass.
Definition FalgType := @Falgebra.Pack F phF cT xclass.
Definition fieldExtType := @FieldExt.Pack F phF cT xclass.

End ClassDef.

Module Exports.

Coercion sort : type >-> Sortclass.
Bind Scope ring_scope with sort.
Coercion base : class_of >-> FieldExt.class_of.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion zmodType : type >-> Zmodule.type.
Canonical zmodType.
Coercion ringType : type >-> Ring.type.
Canonical ringType.
Coercion unitRingType : type >-> UnitRing.type.
Canonical unitRingType.
Coercion comRingType : type >-> ComRing.type.
Canonical comRingType.
Coercion comUnitRingType : type >-> ComUnitRing.type.
Canonical comUnitRingType.
Coercion idomainType : type >-> IntegralDomain.type.
Canonical idomainType.
Coercion fieldType : type >-> Field.type.
Canonical fieldType.
Coercion lmodType : type >-> Lmodule.type.
Canonical lmodType.
Coercion lalgType : type >-> Lalgebra.type.
Canonical lalgType.
Coercion algType : type >-> Algebra.type.
Canonical algType.
Coercion unitAlgType : type >-> UnitAlgebra.type.
Canonical unitAlgType.
Coercion vectType : type >-> Vector.type.
Canonical vectType.
Coercion FalgType : type >-> Falgebra.type.
Canonical FalgType.
Coercion fieldExtType : type >-> FieldExt.type.
Canonical fieldExtType.

Notation splittingFieldType F := (type (Phant F)).
Notation SplittingFieldType F L ax := (@pack _ (Phant F) L _ ax _ _ id _ id).
Notation "[ 'splittingFieldType' F 'of' L 'for' K ]" :=
  (@clone _ (Phant F) L K _ idfun)
  (at level 0, format "[ 'splittingFieldType'  F  'of'  L  'for'  K ]")
  : form_scope.
Notation "[ 'splittingFieldType' F 'of' L ]" :=
  (@clone _ (Phant F) L _ _ id)
  (at level 0, format "[ 'splittingFieldType'  F  'of'  L ]") : form_scope.

End Exports.
End SplittingField.
Export SplittingField.Exports.

Lemma normal_field_splitting (F : fieldType) (L : fieldExtType F) :
  (forall (K : {subfield L}) x,
    exists r, minPoly K x == \prod_(y <- r) ('X - y%:P)) ->
  SplittingField.axiom L.
Proof.
move=> normalL; pose r i := sval (sigW (normalL 1%AS (tnth (vbasis {:L}) i))).
have sz_r i: size (r i) <= \dim {:L}.
  rewrite -ltnS -(size_prod_XsubC _ id) /r; case: sigW => _ /= /eqP <-.
  rewrite size_minPoly ltnS; move: (tnth _ _) => x.
  by rewrite adjoin_degreeE dimv1 divn1 dimvS // subvf.
pose mkf (z : L) := 'X - z%:P.
exists (\prod_i \prod_(j < \dim {:L} | j < size (r i)) mkf (r i)`_j).
  apply: rpred_prod => i _; rewrite big_ord_narrow /= /r; case: sigW => rs /=.
  by rewrite (big_nth 0) big_mkord => /eqP <- {rs}; apply: minPolyOver.
rewrite pair_big_dep /= -big_filter filter_index_enum -(big_map _ xpredT mkf).
set rF := map _ _; exists rF; first exact: eqpxx.
apply/eqP; rewrite eqEsubv subvf -(span_basis (vbasisP {:L})).
apply/span_subvP=> _ /tnthP[i ->]; set x := tnth _ i.
have /tnthP[j ->]: x \in in_tuple (r i).
  by rewrite -root_prod_XsubC /r; case: sigW => _ /=/eqP<-; apply: root_minPoly.
apply/seqv_sub_adjoin/imageP; rewrite (tnth_nth 0) /in_mem/=.
by exists (i, widen_ord (sz_r i) j) => /=.
Qed.

Fact regular_splittingAxiom F : SplittingField.axiom (regular_fieldExtType F).
Proof.
exists 1; first exact: rpred1.
by exists [::]; [rewrite big_nil eqpxx | rewrite Fadjoin_nil regular_fullv].
Qed.

Canonical regular_splittingFieldType (F : fieldType) :=
  SplittingFieldType F F^o (regular_splittingAxiom F).

Section SplittingFieldTheory.

Variables (F : fieldType) (L : splittingFieldType F).

Implicit Types (U V W : {vspace L}).
Implicit Types (K M E : {subfield L}).

Lemma splittingFieldP : SplittingField.axiom L.
Proof. by case: L => ? []. Qed.

Lemma splittingPoly :
  {p : {poly L} | p \is a polyOver 1%VS & splittingFieldFor 1 p {:L}}.
Proof.
pose factF p s := (p \is a polyOver 1%VS) && (p %= \prod_(z <- s) ('X - z%:P)).
suffices [[p rs] /andP[]]: {ps | factF F L ps.1 ps.2 & <<1 & ps.2>> = {:L}}%VS.
  by exists p; last exists rs.
apply: sig2_eqW; have [p F0p [rs splitLp genLrs]] := splittingFieldP.
by exists (p, rs); rewrite // /factF F0p splitLp.
Qed.

Fact fieldOver_splitting E : SplittingField.axiom (fieldOver_fieldExtType E).
Proof.
have [p Fp [r Dp defL]] := splittingFieldP; exists p.
  apply/polyOverP=> j; rewrite trivial_fieldOver.
  by rewrite (subvP (sub1v E)) ?(polyOverP Fp).
exists r => //; apply/vspaceP=> x; rewrite memvf.
have [L0 [_ _ defL0]] :=  @aspaceOverP _ _ E <<1 & r : seq (fieldOver E)>>.
rewrite defL0; have: x \in <<1 & r>>%VS by rewrite defL (@memvf _ L).
apply: subvP; apply/Fadjoin_seqP; rewrite -memvE -defL0 mem1v.
by split=> // y r_y; rewrite -defL0 seqv_sub_adjoin.
Qed.
Canonical fieldOver_splittingFieldType E :=
  SplittingFieldType (subvs_of E) (fieldOver E) (fieldOver_splitting E).

Lemma enum_AEnd : {kAutL : seq 'AEnd(L) | forall f, f \in kAutL}.
Proof.
pose isAutL (s : seq 'AEnd(L)) (f : 'AEnd(L)) := kHom 1 {:L} f = (f \in s).
suffices [kAutL in_kAutL] : {kAutL : seq 'AEnd(L) | forall f, isAutL kAutL f}.
  by exists kAutL => f; rewrite -in_kAutL k1AHom.
have [p Kp /sig2_eqW[rs Dp defL]] := splittingPoly.
do [rewrite {}/isAutL -(erefl (asval 1)); set r := rs; set E := 1%AS] in defL *.
have [sKE rs_r]: (1 <= E)%VS /\ all (mem rs) r by split; last apply/allP.
elim: r rs_r => [_|z r IHr /=/andP[rs_z rs_r]] /= in (E) sKE defL *.
  rewrite Fadjoin_nil in defL; exists [tuple \1%AF] => f; rewrite defL inE.
  apply/idP/eqP=> [/kAHomP f1 | ->]; last exact: kHom1.
  by apply/val_inj/lfunP=> x; rewrite id_lfunE f1 ?memvf.
do [set Ez := <<E; z>>%VS; rewrite adjoin_cons] in defL.
have sEEz: (E <= Ez)%VS := subv_adjoin E z; have sKEz := subv_trans sKE sEEz.
have{IHr} [homEz DhomEz] := IHr rs_r _ sKEz defL.
have Ep: p \in polyOver E := polyOverSv sKE Kp.
have{rs_z} pz0: root p z by rewrite (eqp_root Dp) root_prod_XsubC.
pose pEz := minPoly E z; pose n := \dim_E Ez.
have{pz0} [rz DpEz]: {rz : n.-tuple L | pEz %= \prod_(w <- rz) ('X - w%:P)}.
  have /dvdp_prod_XsubC[m DpEz]: pEz %| \prod_(w <- rs) ('X - w%:P).
    by rewrite -(eqp_dvdr _ Dp) minPoly_dvdp ?(polyOverSv sKE).
  suffices sz_rz: size (mask m rs) == n by exists (Tuple sz_rz).
  rewrite -[n]adjoin_degreeE -eqSS -size_minPoly.
  by rewrite (eqp_size DpEz) size_prod_XsubC.
have fEz i (y := tnth rz i): {f : 'AEnd(L) | kHom E {:L} f & f z = y}.
  have homEfz: kHom E Ez (kHomExtend E \1 z y).
    rewrite kHomExtendP ?kHom1 // lfun1_poly.
    by rewrite (eqp_root DpEz) -/rz root_prod_XsubC mem_tnth.
  have splitFp: splittingFieldFor Ez p {:L}.
    exists rs => //; apply/eqP; rewrite eqEsubv subvf -defL adjoin_seqSr //.
    exact/allP.
  have [f homLf Df] := kHom_extends sEEz homEfz Ep splitFp.
  have [ahomf _] := andP homLf; exists (AHom ahomf) => //.
  rewrite -Df ?memv_adjoin ?(kHomExtend_val (kHom1 E E)) // lfun1_poly.
  by rewrite (eqp_root DpEz) root_prod_XsubC mem_tnth.
exists [seq (s2val (fEz i) \o f)%AF| i <- enum 'I_n, f <- homEz] => f.
apply/idP/allpairsP => [homLf | [[i g] [_ Hg ->]] /=]; last first.
  by case: (fEz i) => fi /= /comp_kHom->; rewrite ?(kHomSl sEEz) ?DhomEz.
have /tnthP[i Dfz]: f z \in rz.
  rewrite memtE /= -root_prod_XsubC -(eqp_root DpEz).
  by rewrite (kHom_root_id _ homLf) ?memvf ?subvf ?minPolyOver ?root_minPoly.
case Dfi: (fEz i) => [fi homLfi fi_z]; have kerfi0 := kAutf_lker0 homLfi.
set fj := (fi ^-1 \o f)%AF; suffices Hfj : fj \in homEz.
  exists (i, fj) => //=; rewrite mem_enum inE Hfj; split => //.
  by apply/val_inj; rewrite {}Dfi /= (lker0_compVKf kerfi0).
rewrite -DhomEz; apply/kAHomP => _ /Fadjoin_polyP[q Eq ->].
have homLfj: kHom E {:L} fj := comp_kHom (inv_kHomf homLfi) homLf.
have /kHom_lrmorphism fjM := kHomSl (sub1v _) homLfj.
rewrite -[fj _](horner_map (RMorphism fjM)) (kHom_poly_id homLfj) //=.
by rewrite lfunE /= Dfz -fi_z lker0_lfunK.
Qed.

Lemma splitting_field_normal K x :
  exists r, minPoly K x == \prod_(y <- r) ('X - y%:P).
Proof.
pose q1 := minPoly 1 x; pose fx_root q (f : 'AEnd(L)) := root q (f x).
have [[p F0p splitLp] [autL DautL]] := (splittingFieldP, enum_AEnd).
suffices{K} autL_px q: q != 0 -> q %| q1 -> size q > 1 -> has (fx_root q) autL.
  set q := minPoly K x; have: q \is monic := monic_minPoly K x.
  have: q %| q1 by rewrite minPolyS // sub1v.
  elim: {q}_.+1 {-2}q (ltnSn (size q)) => // d IHd q leqd q_dv_q1 mon_q.
  have nz_q: q != 0 := monic_neq0 mon_q.
  have [|q_gt1|q_1] := ltngtP (size q) 1; last first; last by rewrite polySpred.
    by exists nil; rewrite big_nil -eqp_monic ?monic1 // -size_poly_eq1 q_1.
  have /hasP[f autLf /factor_theorem[q2 Dq]] := autL_px q nz_q q_dv_q1 q_gt1.
  have mon_q2: q2 \is monic by rewrite -(monicMr _ (monicXsubC (f x))) -Dq.
  rewrite Dq size_monicM -?size_poly_eq0 ?size_XsubC ?addn2 //= ltnS in leqd.
  have q2_dv_q1: q2 %| q1 by rewrite (dvdp_trans _ q_dv_q1) // Dq dvdp_mulr.
  rewrite Dq; have [r /eqP->] := IHd q2 leqd q2_dv_q1 mon_q2.
  by exists (f x :: r); rewrite big_cons mulrC.
elim: {q}_.+1 {-2}q (ltnSn (size q)) => // d IHd q leqd nz_q q_dv_q1 q_gt1.
without loss{d leqd IHd nz_q q_gt1} irr_q: q q_dv_q1 / irreducible_poly q.
  move=> IHq; apply: wlog_neg => not_autLx_q; apply: IHq => //.
  split=> // q2 q2_neq1 q2_dv_q; rewrite -dvdp_size_eqp // eqn_leq dvdp_leq //=.
  rewrite leqNgt; apply: contra not_autLx_q => ltq2q.
  have nz_q2: q2 != 0 by apply: contraTneq q2_dv_q => ->; rewrite dvd0p.
  have{q2_neq1} q2_gt1: size q2 > 1 by rewrite neq_ltn polySpred in q2_neq1 *.
  have{leqd ltq2q} ltq2d: size q2 < d by apply: leq_trans ltq2q _.
  apply: sub_has (IHd _ ltq2d nz_q2 (dvdp_trans q2_dv_q q_dv_q1) q2_gt1) => f.
  by rewrite /fx_root !root_factor_theorem => /dvdp_trans->.
have{irr_q} [Lz [inLz [z qz0]]]: {Lz : fieldExtType F &
  {inLz : 'AHom(L, Lz) & {z : Lz | root (map_poly inLz q) z}}}.
- have [Lz0 _ [z qz0 defLz]] := irredp_FAdjoin irr_q.
  pose Lz := baseField_extFieldType Lz0.
  pose inLz : {rmorphism L -> Lz} := [rmorphism of in_alg Lz0].
  have inLzL_linear: linear (locked inLz).
    move=> a u v; rewrite -(@mulr_algl F Lz) baseField_scaleE.
    by rewrite -{1}mulr_algl rmorphD rmorphM -lock.
  have ihLzZ: ahom_in {:L} (linfun (Linear inLzL_linear)).
    by apply/ahom_inP; split=> [u v|]; rewrite !lfunE (rmorphM, rmorph1).
  exists Lz, (AHom ihLzZ), z; congr (root _ z): qz0.
  by apply: eq_map_poly => y; rewrite lfunE /= -lock.
pose imL := [aspace of limg inLz]; pose pz := map_poly inLz p.
have in_imL u: inLz u \in imL by rewrite memv_img ?memvf.
have F0pz: pz \is a polyOver 1%VS.
  apply/polyOverP=> i; rewrite -(aimg1 inLz) coef_map /= memv_img //.
  exact: (polyOverP F0p).
have{splitLp} splitLpz: splittingFieldFor 1 pz imL.
  have [r def_p defL] := splitLp; exists (map inLz r) => [|{def_p}].
    move: def_p; rewrite -(eqp_map [rmorphism of inLz]) rmorph_prod.
    rewrite big_map; congr (_ %= _); apply: eq_big => // y _.
    by rewrite rmorphB /= map_polyX map_polyC.
  apply/eqP; rewrite eqEsubv /= -{2}defL {defL}; apply/andP; split.
    by apply/Fadjoin_seqP; rewrite sub1v; split=> // _ /mapP[y r_y ->].
  elim/last_ind: r => [|r y IHr] /=; first by rewrite !Fadjoin_nil aimg1.
  rewrite map_rcons !adjoin_rcons /=.
  apply/subvP=> _ /memv_imgP[_ /Fadjoin_polyP[p1 r_p1 ->] ->].
  rewrite -horner_map /= mempx_Fadjoin //=; apply/polyOverP=> i.
  by rewrite coef_map (subvP IHr) //= memv_img ?(polyOverP r_p1).
have [f homLf fxz]: exists2 f : 'End(Lz), kHom 1 imL f & f (inLz x) = z.
  pose q1z := minPoly 1 (inLz x).
  have Dq1z: map_poly inLz q1 %| q1z.
    have F0q1z i: exists a, q1z`_i = a%:A by apply/vlineP/polyOverP/minPolyOver.
    have [q2 Dq2]: exists q2, q1z = map_poly inLz q2.
      exists (\poly_(i < size q1z) (sval (sig_eqW (F0q1z i)))%:A).
      rewrite -{1}[q1z]coefK; apply/polyP=> i; rewrite coef_map !{1}coef_poly.
      by case: sig_eqW => a; case: ifP; rewrite /= ?rmorph0 ?linearZ ?rmorph1.
    rewrite Dq2 dvdp_map minPoly_dvdp //.
      apply/polyOverP=> i; have[a] := F0q1z i.
      rewrite -(rmorph1 [rmorphism of inLz]) -linearZ.
      by rewrite Dq2 coef_map => /fmorph_inj->; rewrite rpredZ ?mem1v.
    by rewrite -(fmorph_root [rmorphism of inLz]) -Dq2 root_minPoly.
  have q1z_z: root q1z z.
    rewrite !root_factor_theorem in qz0 *.
    by apply: dvdp_trans qz0 (dvdp_trans _ Dq1z); rewrite dvdp_map.
  have map1q1z_z: root (map_poly \1%VF q1z) z.
    by rewrite map_poly_id => // ? _; rewrite lfunE.
  pose f0 := kHomExtend 1 \1 (inLz x) z.
  have{map1q1z_z} hom_f0 : kHom 1 <<1; inLz x>> f0.
    by apply: kHomExtendP map1q1z_z => //; apply: kHom1.
  have{splitLpz} splitLpz: splittingFieldFor <<1; inLz x>> pz imL.
    have [r def_pz defLz] := splitLpz; exists r => //.
    apply/eqP; rewrite eqEsubv -{2}defLz adjoin_seqSl ?sub1v // andbT.
    apply/Fadjoin_seqP; split; last first.
      by rewrite /= -[limg _]defLz; apply: seqv_sub_adjoin.
    by apply/FadjoinP/andP; rewrite sub1v memv_img ?memvf.
  have [f homLzf Df] := kHom_extends (sub1v _) hom_f0 F0pz splitLpz.
  have [-> | x'z] := eqVneq (inLz x) z.
    by exists \1%VF; rewrite ?lfunE ?kHom1.
  exists f => //; rewrite -Df ?memv_adjoin ?(kHomExtend_val (kHom1 1 1)) //.
  by rewrite lfun1_poly.
pose f1 := (inLz^-1 \o f \o inLz)%VF; have /kHomP[fM fFid] := homLf.
have Df1 u: inLz (f1 u) = f (inLz u).
  rewrite !comp_lfunE limg_lfunVK //= -[limg _]/(asval imL).
  have [r def_pz defLz] := splitLpz.
  have []: all (mem r) r /\ inLz u \in imL by split; first apply/allP.
  rewrite -{1}defLz; elim/last_ind: {-1}r {u}(inLz u) => [|r1 y IHr1] u.
    by rewrite Fadjoin_nil => _ Fu; rewrite fFid // (subvP (sub1v _)).
  rewrite all_rcons adjoin_rcons => /andP[rr1 ry] /Fadjoin_polyP[pu r1pu ->].
  rewrite (kHom_horner homLf) -defLz; last exact: seqv_sub_adjoin; last first.
    by apply: polyOverS r1pu; apply/subvP/adjoin_seqSr/allP.
  apply: rpred_horner.
    by apply/polyOverP=> i; rewrite coef_map /= defLz IHr1 ?(polyOverP r1pu).
  rewrite seqv_sub_adjoin // -root_prod_XsubC -(eqp_root def_pz).
  rewrite (kHom_root_id _ homLf) ?sub1v //.
    by rewrite -defLz seqv_sub_adjoin.
  by rewrite (eqp_root def_pz) root_prod_XsubC.
suffices f1_is_ahom : ahom_in {:L} f1.
  apply/hasP; exists (AHom f1_is_ahom); first exact: DautL.
  by rewrite /fx_root -(fmorph_root [rmorphism of inLz]) /= Df1 fxz.
apply/ahom_inP; split=> [a b _ _|]; apply: (fmorph_inj [rmorphism of inLz]).
  by rewrite rmorphM /= !Df1 rmorphM fM ?in_imL.
by rewrite /= Df1 /= fFid ?rmorph1 ?mem1v.
Qed.

Lemma kHom_to_AEnd K E f : kHom K E f -> {g : 'AEnd(L) | {in E, f =1 val g}}.
Proof.
move=> homKf; have{homKf} [homFf sFE] := (kHomSl (sub1v K) homKf, sub1v E).
have [p Fp /(splittingFieldForS sFE (subvf E))splitLp] := splittingPoly.
have [g0 homLg0 eq_fg] := kHom_extends sFE homFf Fp splitLp.
by apply: exist (Sub g0 _) _ =>  //; apply/ahomP/kHom_lrmorphism.
Qed.

End SplittingFieldTheory.

Module Import AEnd_FinGroup.
Section AEnd_FinGroup.

Variables (F : fieldType) (L : splittingFieldType F).
Implicit Types (U V W : {vspace L}) (K M E : {subfield L}).

Definition inAEnd f := SeqSub (svalP (enum_AEnd L) f).
Fact inAEndK : cancel inAEnd val. Proof. by []. Qed.

Definition AEnd_countMixin := Eval hnf in CanCountMixin inAEndK.
Canonical AEnd_countType := Eval hnf in CountType 'AEnd(L) AEnd_countMixin.
Canonical AEnd_subCountType := Eval hnf in [subCountType of 'AEnd(L)].
Definition AEnd_finMixin := Eval hnf in CanFinMixin inAEndK.
Canonical AEnd_finType := Eval hnf in FinType 'AEnd(L) AEnd_finMixin.
Canonical AEnd_subFinType := Eval hnf in [subFinType of 'AEnd(L)].

Definition comp_AEnd (f g : 'AEnd(L)) : 'AEnd(L) := (g \o f)%AF.

Fact comp_AEndA : associative comp_AEnd.
Proof. by move=> f g h; apply: val_inj; symmetry; apply: comp_lfunA. Qed.

Fact comp_AEnd1l : left_id \1%AF comp_AEnd.
Proof. by move=> f; apply/val_inj/comp_lfun1r. Qed.

Fact comp_AEndK : left_inverse \1%AF (@inv_ahom _ L) comp_AEnd.
Proof.  by move=> f; apply/val_inj; rewrite /= lker0_compfV ?AEnd_lker0. Qed.

Definition AEnd_baseFinGroupMixin :=
  FinGroup.Mixin comp_AEndA comp_AEnd1l comp_AEndK.
Canonical AEnd_baseFinGroupType :=
  BaseFinGroupType 'AEnd(L) AEnd_baseFinGroupMixin.
Canonical AEnd_finGroupType := FinGroupType comp_AEndK.

Definition kAEnd U V := [set f : 'AEnd(L) | kAut U V f].
Definition kAEndf U := kAEnd U {:L}.

Lemma kAEnd_group_set K E : group_set (kAEnd K E).
Proof.
apply/group_setP; split=> [|f g]; first by rewrite inE /kAut kHom1 lim1g eqxx.
rewrite !inE !kAutE => /andP[homKf EfE] /andP[/(kHomSr EfE)homKg EgE].
by rewrite (comp_kHom_img homKg homKf) limg_comp (subv_trans _ EgE) ?limgS.
Qed.
Canonical kAEnd_group K E := group (kAEnd_group_set K E).
Canonical kAEndf_group K := [group of kAEndf K].

Lemma kAEnd_norm K E : kAEnd K E \subset 'N(kAEndf E)%g.
Proof.
apply/subsetP=> x; rewrite -groupV 2!in_set => /andP[_ /eqP ExE].
apply/subsetP=> _ /imsetP[y homEy ->]; rewrite !in_set !kAutfE in homEy *.
apply/kAHomP=> u Eu; have idEy := kAHomP homEy; rewrite -ExE in idEy.
by rewrite !lfunE /= lfunE /= idEy ?memv_img // lker0_lfunVK ?AEnd_lker0.
Qed.

Lemma mem_kAut_coset K E (g : 'AEnd(L)) :
  kAut K E g -> g \in coset (kAEndf E) g.
Proof.
move=> autEg; rewrite val_coset ?rcoset_refl //.
by rewrite (subsetP (kAEnd_norm K E)) // inE.
Qed.

Lemma aut_mem_eqP E (x y : coset_of (kAEndf E)) f g :
  f \in x -> g \in y -> reflect {in E, f =1 g} (x == y).
Proof.
move=> x_f y_g; rewrite -(coset_mem x_f) -(coset_mem y_g).
have [Nf Ng] := (subsetP (coset_norm x) f x_f, subsetP (coset_norm y) g y_g).
rewrite (sameP eqP (rcoset_kercosetP Nf Ng)) mem_rcoset inE kAutfE.
apply: (iffP kAHomP) => idEfg u Eu.
  by rewrite -(mulgKV g f) lfunE /= idEfg.
by rewrite lfunE /= idEfg // lker0_lfunK ?AEnd_lker0.
Qed.

End AEnd_FinGroup.
End AEnd_FinGroup.

Section GaloisTheory.

Variables (F : fieldType) (L : splittingFieldType F).

Implicit Types (U V W : {vspace L}).
Implicit Types (K M E : {subfield L}).

Section gal_of_Definition.

Variable V : {vspace L}.

Inductive gal_of := Gal of [subg kAEnd_group 1 <<V>> / kAEndf (agenv V)].
Definition gal (f : 'AEnd(L)) := Gal (subg _ (coset _ f)).
Definition gal_sgval x := let: Gal u := x in u.

Fact gal_sgvalK : cancel gal_sgval Gal. Proof. by case. Qed.
Let gal_sgval_inj := can_inj gal_sgvalK.

Definition gal_eqMixin := CanEqMixin gal_sgvalK.
Canonical gal_eqType := Eval hnf in EqType gal_of gal_eqMixin.
Definition gal_choiceMixin := CanChoiceMixin gal_sgvalK.
Canonical gal_choiceType := Eval hnf in ChoiceType gal_of gal_choiceMixin.
Definition gal_countMixin := CanCountMixin gal_sgvalK.
Canonical gal_countType := Eval hnf in CountType gal_of gal_countMixin.
Definition gal_finMixin := CanFinMixin gal_sgvalK.
Canonical gal_finType := Eval hnf in FinType gal_of gal_finMixin.

Definition gal_one := Gal 1%g.
Definition gal_inv x := Gal (gal_sgval x)^-1.
Definition gal_mul x y := Gal (gal_sgval x * gal_sgval y).
Fact gal_oneP : left_id gal_one gal_mul.
Proof. by move=> x; apply/gal_sgval_inj/mul1g. Qed.
Fact gal_invP : left_inverse gal_one gal_inv gal_mul.
Proof. by move=> x; apply/gal_sgval_inj/mulVg. Qed.
Fact gal_mulP : associative gal_mul.
Proof. by move=> x y z; apply/gal_sgval_inj/mulgA. Qed.

Definition gal_finGroupMixin :=
  FinGroup.Mixin gal_mulP gal_oneP gal_invP.
Canonical gal_finBaseGroupType :=
  Eval hnf in BaseFinGroupType gal_of gal_finGroupMixin.
Canonical gal_finGroupType := Eval hnf in FinGroupType gal_invP.

Coercion gal_repr u : 'AEnd(L) := repr (sgval (gal_sgval u)).

Fact gal_is_morphism : {in kAEnd 1 (agenv V) &, {morph gal : x y / x * y}%g}.
Proof.
move=> f g /= autEa autEb; congr (Gal _).
by rewrite !morphM ?mem_morphim // (subsetP (kAEnd_norm 1 _)).
Qed.
Canonical gal_morphism := Morphism gal_is_morphism.

Lemma gal_reprK : cancel gal_repr gal.
Proof. by case=> x; rewrite /gal coset_reprK sgvalK. Qed.

Lemma gal_repr_inj : injective gal_repr.
Proof. exact: can_inj gal_reprK. Qed.

Lemma gal_AEnd x : gal_repr x \in kAEnd 1 (agenv V).
Proof.
rewrite /gal_repr; case/gal_sgval: x => _ /=/morphimP[g Ng autEg ->].
rewrite val_coset //=; case: repr_rcosetP => f; rewrite groupMr // !inE kAut1E.
by rewrite kAutE -andbA => /and3P[_ /fixedSpace_limg-> _].
Qed.

End gal_of_Definition.

Prenex Implicits gal_repr.

Lemma gal_eqP E {x y : gal_of E} : reflect {in E, x =1 y} (x == y).
Proof.
by rewrite -{1}(subfield_closed E); apply: aut_mem_eqP; apply: mem_repr_coset.
Qed.

Lemma galK E (f : 'AEnd(L)) : (f @: E <= E)%VS -> {in E, gal E f =1 f}.
Proof.
rewrite -kAut1E -{1 2}(subfield_closed E) => autEf.
apply: (aut_mem_eqP (mem_repr_coset _) _ (eqxx _)).
by rewrite subgK /= ?(mem_kAut_coset autEf) // ?mem_quotient ?inE.
Qed.

Lemma eq_galP E (f g : 'AEnd(L)) :
   (f @: E <= E)%VS -> (g @: E <= E)%VS ->
  reflect {in E, f =1 g} (gal E f == gal E g).
Proof.
move=> EfE EgE.
by apply: (iffP gal_eqP) => Dfg a Ea; have:= Dfg a Ea; rewrite !{1}galK.
Qed.

Lemma limg_gal E (x : gal_of E) : (x @: E)%VS = E.
Proof. by have:= gal_AEnd x; rewrite inE subfield_closed => /andP[_ /eqP]. Qed.

Lemma memv_gal E (x : gal_of E) a : a \in E -> x a \in E.
Proof. by move/(memv_img x); rewrite limg_gal. Qed.

Lemma gal_id E a : (1 : gal_of E)%g a = a.
Proof. by rewrite /gal_repr repr_coset1 id_lfunE. Qed.

Lemma galM E (x y : gal_of E) a : a \in E -> (x * y)%g a = y (x a).
Proof.
rewrite /= -comp_lfunE; apply/eq_galP; rewrite ?limg_comp ?limg_gal //.
by rewrite morphM /= ?gal_reprK ?gal_AEnd.
Qed.

Lemma galV E (x : gal_of E) : {in E, (x^-1)%g =1 x^-1%VF}.
Proof.
move=> a Ea; apply: canRL (lker0_lfunK (AEnd_lker0 _)) _.
by rewrite -galM // mulVg gal_id.
Qed.

Definition galoisG V U := gal V @* <<kAEnd (U :&: V) V>>.
Local Notation "''Gal' ( V / U )" := (galoisG V U) : group_scope.
Canonical galoisG_group E U := Eval hnf in [group of (galoisG E U)].
Local Notation "''Gal' ( V / U )" := (galoisG_group V U) : Group_scope.

Section Automorphism.

Lemma gal_cap U V : 'Gal(V / U) = 'Gal(V / U :&: V).
Proof. by rewrite /galoisG -capvA capvv. Qed.

Lemma gal_kAut K E x : (K <= E)%VS -> (x \in 'Gal(E / K)) = kAut K E x.
Proof.
move=> sKE; apply/morphimP/idP=> /= [[g EgE KautEg ->{x}] | KautEx].
  rewrite genGid !inE kAut1E /= subfield_closed (capv_idPl sKE) in KautEg EgE.
  by apply: etrans KautEg; apply/(kAut_eq sKE); apply: galK.
exists (x : 'AEnd(L)); rewrite ?gal_reprK ?gal_AEnd //.
by rewrite (capv_idPl sKE) mem_gen ?inE.
Qed.

Lemma gal_kHom K E x : (K <= E)%VS -> (x \in 'Gal(E / K)) = kHom K E x.
Proof. by move/gal_kAut->; rewrite /kAut limg_gal eqxx andbT. Qed.

Lemma kAut_to_gal K E f :
  kAut K E f -> {x : gal_of E | x \in 'Gal(E / K) & {in E, f =1 x}}.
Proof.
case/andP=> homKf EfE; have [g Df] := kHom_to_AEnd homKf.
have{homKf EfE} autEg: kAut (K :&: E) E g.
  rewrite /kAut -(kHom_eq (capvSr _ _) Df) (kHomSl (capvSl _ _) homKf) /=.
  by rewrite -(eq_in_limg Df).
have FautEg := kAutS (sub1v _) autEg.
exists (gal E g) => [|a Ea]; last by rewrite {f}Df // galK // -kAut1E.
by rewrite mem_morphim /= ?subfield_closed ?genGid ?inE.
Qed.

Lemma fixed_gal K E x a :
  (K <= E)%VS -> x \in 'Gal(E / K) -> a \in K -> x a = a.
Proof. by move/gal_kHom=> -> /kAHomP idKx /idKx. Qed.

Lemma fixedPoly_gal K E x p :
  (K <= E)%VS -> x \in 'Gal(E / K) -> p \is a polyOver K -> map_poly x p = p.
Proof.
move=> sKE galEKx /polyOverP Kp; apply/polyP => i.
by rewrite coef_map /= (fixed_gal sKE).
Qed.

Lemma root_minPoly_gal K E x a :
  (K <= E)%VS -> x \in 'Gal(E / K) -> a \in E -> root (minPoly K a) (x a).
Proof.
move=> sKE galEKx Ea; have homKx: kHom K E x by rewrite -gal_kHom.
have K_Pa := minPolyOver K a; rewrite -[minPoly K a](fixedPoly_gal _ galEKx) //.
by rewrite (kHom_root homKx) ?root_minPoly // (polyOverS (subvP sKE)).
Qed.

End Automorphism.

Lemma gal_adjoin_eq K a x y :
    x \in 'Gal(<<K; a>> / K) -> y \in 'Gal(<<K; a>> / K) ->
  (x == y) = (x a == y a).
Proof.
move=> galKa_x galKa_y; apply/idP/eqP=> [/eqP-> // | eq_xy_a].
apply/gal_eqP => _ /Fadjoin_polyP[p Kp ->].
by rewrite -!horner_map !(fixedPoly_gal (subv_adjoin K a)) //= eq_xy_a.
Qed.

Lemma galS K M E : (K <= M)%VS -> 'Gal(E / M) \subset 'Gal(E / K).
Proof.
rewrite gal_cap (gal_cap K E) => sKM; apply/subsetP=> x.
by rewrite !gal_kAut ?capvSr //; apply: kAutS; apply: capvS.
Qed.

Lemma gal_conjg K E x : 'Gal(E / K) :^ x = 'Gal(E / x @: K).
Proof.
without loss sKE: K / (K <= E)%VS.
  move=> IH_K; rewrite gal_cap {}IH_K ?capvSr //.
  transitivity 'Gal(E / x @: K :&: x @: E); last by rewrite limg_gal -gal_cap.
  congr 'Gal(E / _); apply/eqP; rewrite eqEsubv limg_cap; apply/subvP=> a.
  rewrite memv_cap => /andP[/memv_imgP[b Kb ->] /memv_imgP[c Ec] eq_bc].
  by rewrite memv_img // memv_cap Kb (lker0P (AEnd_lker0 _) _ _ eq_bc).
wlog suffices IHx: x K sKE / 'Gal(E / K) :^ x \subset 'Gal(E / x @: K).
  apply/eqP; rewrite eqEsubset IHx // -sub_conjgV (subset_trans (IHx _ _ _)) //.
    by apply/subvP=> _ /memv_imgP[a Ka ->]; rewrite memv_gal ?(subvP sKE).
  rewrite -limg_comp (etrans (eq_in_limg _) (lim1g _)) // => a /(subvP sKE)Ka.
  by rewrite !lfunE /= -galM // mulgV gal_id.
apply/subsetP=> _ /imsetP[y galEy ->]; rewrite gal_cap gal_kHom ?capvSr //=.
apply/kAHomP=> _ /memv_capP[/memv_imgP[a Ka ->] _]; have Ea := subvP sKE a Ka.
by rewrite -galM // -conjgC galM // (fixed_gal sKE galEy).
Qed.

Definition fixedField V (A : {set gal_of V}) :=
  (V :&: \bigcap_(x in A) fixedSpace x)%VS.

Lemma fixedFieldP E {A : {set gal_of E}} a :
  a \in E -> reflect (forall x, x \in A -> x a = a) (a \in fixedField A).
Proof.
by rewrite memv_cap => ->; apply: (iffP subv_bigcapP) => cAa x /cAa/fixedSpaceP.
Qed.

Lemma mem_fixedFieldP E (A : {set gal_of E}) a :
  a \in fixedField A -> a \in E /\ (forall x, x \in A -> x a = a).
Proof.
by move=> fixAa; have [Ea _] := memv_capP fixAa; have:= fixedFieldP Ea fixAa.
Qed.

Fact fixedField_is_aspace E (A : {set gal_of E}) : is_aspace (fixedField A).
Proof.
rewrite /fixedField; elim/big_rec: _ {1}E => [|x K _ IH_K] M.
  exact: (valP (M :&: _)%AS).
by rewrite capvA IH_K.
Qed.
Canonical fixedField_aspace E A : {subfield L} :=
  ASpace (@fixedField_is_aspace E A).

Lemma fixedField_bound E (A : {set gal_of E}) : (fixedField A <= E)%VS.
Proof. exact: capvSl. Qed.

Lemma fixedFieldS E (A B : {set gal_of E}) :
   A \subset B -> (fixedField B <= fixedField A)%VS.
Proof.
move/subsetP=> sAB; apply/subvP => a /mem_fixedFieldP[Ea cBa].
by apply/fixedFieldP; last apply: sub_in1 cBa.
Qed.

Lemma galois_connection_subv K E :
  (K <= E)%VS -> (K <= fixedField ('Gal(E / K)))%VS.
Proof.
move=> sKE; apply/subvP => a Ka; have Ea := subvP sKE a Ka.
by apply/fixedFieldP=> // x galEx; apply: (fixed_gal sKE).
Qed.

Lemma galois_connection_subset E (A : {set gal_of E}):
  A \subset 'Gal(E / fixedField A).
Proof.
apply/subsetP => x Ax; rewrite gal_kAut ?capvSl // kAutE limg_gal subvv andbT.
by apply/kAHomP=> a /mem_fixedFieldP[_ ->].
Qed.

Lemma galois_connection K E (A : {set gal_of E}):
  (K <= E)%VS -> (A \subset 'Gal(E / K)) = (K <= fixedField A)%VS.
Proof.
move=> sKE; apply/idP/idP => [/fixedFieldS | /(galS E)].
  by apply: subv_trans; apply galois_connection_subv.
by apply: subset_trans; apply: galois_connection_subset.
Qed.

Definition galTrace U V a := \sum_(x in 'Gal(V / U)) (x a).

Definition galNorm U V a := \prod_(x in 'Gal(V / U)) (x a).

Section TraceAndNormMorphism.

Variables U V : {vspace L}.

Fact galTrace_is_additive : additive (galTrace U V).
Proof.
by move=> a b /=; rewrite -sumrB; apply: eq_bigr => x _; rewrite rmorphB.
Qed.
Canonical galTrace_additive := Additive galTrace_is_additive.

Lemma galNorm1 : galNorm U V 1 = 1.
Proof. by apply: big1 => x _; rewrite rmorph1. Qed.

Lemma galNormM : {morph galNorm U V : a b / a * b}.
Proof.
by move=> a b /=; rewrite -big_split; apply: eq_bigr => x _; rewrite rmorphM.
Qed.

Lemma galNormV : {morph galNorm U V : a / a^-1}.
Proof.
by move=> a /=; rewrite -prodfV; apply: eq_bigr => x _; rewrite fmorphV.
Qed.

Lemma galNormX n : {morph galNorm U V : a / a ^+ n}.
Proof.
move=> a; elim: n => [|n IHn]; first by apply: galNorm1.
by rewrite !exprS galNormM IHn.
Qed.

Lemma galNorm_prod (I : Type) (r : seq I) (P : pred I) (B : I -> L) :
  galNorm U V (\prod_(i <- r | P i) B i)
   = \prod_(i <- r | P i) galNorm U V (B i).
Proof. exact: (big_morph _ galNormM galNorm1). Qed.

Lemma galNorm0 : galNorm U V 0 = 0.
Proof. by rewrite /galNorm (bigD1 1%g) ?group1 // rmorph0 /= mul0r. Qed.

Lemma galNorm_eq0 a : (galNorm U V a == 0) = (a == 0).
Proof.
apply/idP/eqP=> [/prodf_eq0[x _] | ->]; last by rewrite galNorm0.
by rewrite fmorph_eq0 => /eqP.
Qed.

End TraceAndNormMorphism.

Section TraceAndNormField.

Variables K E : {subfield L}.

Lemma galTrace_fixedField a :
  a \in E -> galTrace K E a \in fixedField 'Gal(E / K).
Proof.
move=> Ea; apply/fixedFieldP=> [|x galEx].
  by apply: rpred_sum => x _; apply: memv_gal.
rewrite {2}/galTrace (reindex_acts 'R _ galEx) ?astabsR //=.
by rewrite rmorph_sum; apply: eq_bigr => y _; rewrite galM ?lfunE.
Qed.

Lemma galTrace_gal a x :
  a \in E -> x \in 'Gal(E / K) -> galTrace K E (x a) = galTrace K E a.
Proof.
move=> Ea galEx; rewrite {2}/galTrace (reindex_inj (mulgI x)).
by apply: eq_big => [b | b _]; rewrite ?groupMl // galM ?lfunE.
Qed.

Lemma galNorm_fixedField a :
  a \in E -> galNorm K E a \in fixedField 'Gal(E / K).
Proof.
move=> Ea; apply/fixedFieldP=> [|x galEx].
  by apply: rpred_prod => x _; apply: memv_gal.
rewrite {2}/galNorm (reindex_acts 'R _ galEx) ?astabsR //=.
by rewrite rmorph_prod; apply: eq_bigr => y _; rewrite galM ?lfunE.
Qed.

Lemma galNorm_gal a x :
  a \in E -> x \in 'Gal(E / K) -> galNorm K E (x a) = galNorm K E a.
Proof.
move=> Ea galEx; rewrite {2}/galNorm (reindex_inj (mulgI x)).
by apply: eq_big => [b | b _]; rewrite ?groupMl // galM ?lfunE.
Qed.

End TraceAndNormField.

Definition normalField U V := [forall x in kAEndf U, x @: V == V]%VS.

Lemma normalField_kAut K M E f :
  (K <= M <= E)%VS -> normalField K M -> kAut K E f -> kAut K M f.
Proof.
case/andP=> sKM sME nKM /kAut_to_gal[x galEx /(sub_in1 (subvP sME))Df].
have sKE := subv_trans sKM sME; rewrite gal_kHom // in galEx.
rewrite (kAut_eq sKM Df) /kAut (kHomSr sME) //= (forall_inP nKM) // inE.
by rewrite kAutfE; apply/kAHomP; apply: (kAHomP galEx).
Qed.

Lemma normalFieldP K E :
  reflect {in E, forall a, exists2 r,
            all (mem E) r & minPoly K a = \prod_(b <- r) ('X - b%:P)}
          (normalField K E).
Proof.
apply: (iffP eqfun_inP) => [nKE a Ea | nKE x]; last first.
  rewrite inE kAutfE => homKx; suffices: kAut K E x by case/andP=> _ /eqP.
  rewrite kAutE (kHomSr (subvf E)) //=; apply/subvP=> _ /memv_imgP[a Ea ->].
  have [r /allP/=srE splitEa] := nKE a Ea.
  rewrite srE // -root_prod_XsubC -splitEa.
  by rewrite -(kHom_poly_id homKx (minPolyOver K a)) fmorph_root root_minPoly.
have [r /eqP splitKa] := splitting_field_normal K a.
exists r => //; apply/allP => b; rewrite -root_prod_XsubC -splitKa => pKa_b_0.
pose y := kHomExtend K \1 a b; have [hom1K lf1p] := (kHom1 K K, lfun1_poly).
have homKy: kHom K <<K; a>> y by apply/kHomExtendP; rewrite ?lf1p.
have [[g Dy] [_ idKy]] := (kHom_to_AEnd homKy, kHomP homKy).
have <-: g a = b by rewrite -Dy ?memv_adjoin // (kHomExtend_val hom1K) ?lf1p.
suffices /nKE <-: g \in kAEndf K by apply: memv_img.
by rewrite inE kAutfE; apply/kAHomP=> c Kc; rewrite -Dy ?subvP_adjoin ?idKy.
Qed.

Lemma normalFieldf K : normalField K {:L}.
Proof.
apply/normalFieldP=> a _; have [r /eqP->] := splitting_field_normal K a.
by exists r => //; apply/allP=> b; rewrite /= memvf.
Qed.

Lemma normalFieldS K M E : (K <= M)%VS -> normalField K E -> normalField M E.
Proof.
move=> sKM /normalFieldP nKE; apply/normalFieldP=> a Ea.
have [r /allP Er splitKa] := nKE a Ea.
have /dvdp_prod_XsubC[m splitMa]: minPoly M a %| \prod_(b <- r) ('X - b%:P).
  by rewrite -splitKa minPolyS.
exists (mask m r); first by apply/allP=> b /mem_mask/Er.
by apply/eqP; rewrite -eqp_monic ?monic_prod_XsubC ?monic_minPoly.
Qed.

Lemma splitting_normalField E K :
   (K <= E)%VS ->
  reflect (exists2 p, p \is a polyOver K & splittingFieldFor K p E)
          (normalField K E).
Proof.
move=> sKE; apply: (iffP idP) => [nKE| [p Kp [rs Dp defE]]]; last first.
  apply/forall_inP=> g; rewrite inE kAutE => /andP[homKg _].
  rewrite -dimv_leqif_eq ?limg_dim_eq ?(eqP (AEnd_lker0 g)) ?capv0 //.
  rewrite -defE aimg_adjoin_seq; have [_ /fixedSpace_limg->] := andP homKg.
  apply/adjoin_seqSr=> _ /mapP[a rs_a ->].
  rewrite -!root_prod_XsubC -!(eqp_root Dp) in rs_a *.
  by apply: kHom_root_id homKg Kp _ rs_a; rewrite ?subvf ?memvf.
pose splitK a r := minPoly K a = \prod_(b <- r) ('X - b%:P).
have{nKE} rK_ a: {r | a \in E -> all (mem E) r /\ splitK a r}.
  case Ea: (a \in E); last by exists [::].
  by have /sig2_eqW[r] := normalFieldP _ _ nKE a Ea; exists r.
have sXE := basis_mem (vbasisP E); set X : seq L := vbasis E in sXE.
exists (\prod_(a <- X) minPoly K a).
  by apply: rpred_prod => a _; apply: minPolyOver.
exists (flatten [seq (sval (rK_ a)) | a <- X]).
  move/allP: sXE; elim: X => [|a X IHX]; first by rewrite !big_nil eqpxx.
  rewrite big_cons /= big_cat /= => /andP[Ea sXE].
  by case: (rK_ a) => /= r [] // _ <-; apply/eqp_mull/IHX.
apply/eqP; rewrite eqEsubv; apply/andP; split.
  apply/Fadjoin_seqP; split=> // b /flatten_mapP[a /sXE Ea].
  by apply/allP; case: rK_ => r /= [].
rewrite -{1}(span_basis (vbasisP E)); apply/span_subvP=> a Xa.
apply/seqv_sub_adjoin/flatten_mapP; exists a => //; rewrite -root_prod_XsubC.
by case: rK_ => /= r [| _ <-]; rewrite ?sXE ?root_minPoly.
Qed.

Lemma kHom_to_gal K M E f :
    (K <= M <= E)%VS -> normalField K E -> kHom K M f ->
  {x | x \in 'Gal(E / K) & {in M, f =1 x}}.
Proof.
case/andP=> /subvP sKM /subvP sME nKE KhomMf.
have [[g Df] [_ idKf]] := (kHom_to_AEnd KhomMf, kHomP KhomMf).
suffices /kAut_to_gal[x galEx Dg]: kAut K E g.
  by exists x => //= a Ma; rewrite Df // Dg ?sME.
have homKg: kHom K {:L} g by apply/kAHomP=> a Ka; rewrite -Df ?sKM ?idKf.
by rewrite /kAut (kHomSr (subvf _)) // (forall_inP nKE) // inE kAutfE.
Qed.

Lemma normalField_root_minPoly K E a b :
    (K <= E)%VS -> normalField K E -> a \in E -> root (minPoly K a) b ->
  exists2 x, x \in 'Gal(E / K) & x a = b.
Proof.
move=> sKE nKE Ea pKa_b_0; pose f := kHomExtend K \1 a b.
have homKa_f: kHom K <<K; a>> f.
  by apply: kHomExtendP; rewrite ?kHom1 ?lfun1_poly.
have sK_Ka_E: (K <= <<K; a>> <= E)%VS.
  by rewrite subv_adjoin; apply/FadjoinP; rewrite sKE Ea.
have [x galEx Df] := kHom_to_gal sK_Ka_E nKE homKa_f; exists x => //.
by rewrite -Df ?memv_adjoin // (kHomExtend_val (kHom1 K K)) ?lfun1_poly.
Qed.

Arguments normalFieldP {K E}.

Lemma normalField_factors K E :
   (K <= E)%VS ->
 reflect {in E, forall a, exists2 r : seq (gal_of E),
            r \subset 'Gal(E / K)
          & minPoly K a = \prod_(x <- r) ('X - (x a)%:P)}
   (normalField K E).
Proof.
move=> sKE; apply: (iffP idP) => [nKE a Ea | nKE]; last first.
  apply/normalFieldP=> a Ea; have [r _ ->] := nKE a Ea.
  exists [seq x a | x : gal_of E <- r]; last by rewrite big_map.
  by rewrite all_map; apply/allP=> b _; apply: memv_gal.
have [r Er splitKa] := normalFieldP nKE a Ea.
pose f b := [pick x in 'Gal(E / K) | x a == b].
exists (pmap f r).
  apply/subsetP=> x; rewrite mem_pmap /f => /mapP[b _].
  by case: (pickP _) => // c /andP[galEc _] [->].
rewrite splitKa; have{splitKa}: all (root (minPoly K a)) r.
  by apply/allP => b; rewrite splitKa root_prod_XsubC.
elim: r Er => /= [|b r IHr]; first by rewrite !big_nil.
case/andP=> Eb Er /andP[pKa_b_0 /(IHr Er){IHr Er}IHr].
have [x galE /eqP xa_b] := normalField_root_minPoly sKE nKE Ea pKa_b_0.
rewrite /(f b); case: (pickP _) => [y /andP[_ /eqP<-]|/(_ x)/andP[]//].
by rewrite !big_cons IHr.
Qed.

Definition galois U V := [&& (U <= V)%VS, separable U V & normalField U V].

Lemma galoisS K M E : (K <= M <= E)%VS -> galois K E -> galois M E.
Proof.
case/andP=> sKM sME /and3P[_ sepUV nUV].
by rewrite /galois sME (separableSl sKM) ?(normalFieldS sKM).
Qed.

Lemma galois_dim K E : galois K E -> \dim_K E = #|'Gal(E / K)|.
Proof.
case/and3P=> sKE /eq_adjoin_separable_generator-> // nKE.
set a := separable_generator K E in nKE *.
have [r /allP/=Er splitKa] := normalFieldP nKE a (memv_adjoin K a).
rewrite (dim_sup_field (subv_adjoin K a)) mulnK ?adim_gt0 //.
apply/eqP; rewrite -eqSS -adjoin_degreeE -size_minPoly splitKa size_prod_XsubC.
set n := size r; rewrite eqSS -[n]card_ord.
have x_ (i : 'I_n): {x | x \in 'Gal(<<K; a>> / K) & x a = r`_i}.
  apply/sig2_eqW/normalField_root_minPoly; rewrite ?subv_adjoin ?memv_adjoin //.
  by rewrite splitKa root_prod_XsubC mem_nth.
have /card_image <-: injective (fun i => s2val (x_ i)).
  move=> i j /eqP; case: (x_ i) (x_ j) => y /= galEy Dya [z /= galEx Dza].
  rewrite gal_adjoin_eq // Dya Dza nth_uniq // => [/(i =P j)//|].
  by rewrite -separable_prod_XsubC -splitKa; apply: separable_generatorP.
apply/eqP/eq_card=> x; apply/codomP/idP=> [[i ->] | galEx]; first by case: x_.
have /(nthP 0) [i ltin Dxa]: x a \in r.
  rewrite -root_prod_XsubC -splitKa.
  by rewrite root_minPoly_gal ?memv_adjoin ?subv_adjoin.
exists (Ordinal ltin); apply/esym/eqP.
by case: x_ => y /= galEy /eqP; rewrite Dxa gal_adjoin_eq.
Qed.

Lemma galois_factors K E :
    (K <= E)%VS ->
  reflect {in E, forall a, exists r, let r_a := [seq x a | x : gal_of E <- r] in
            [/\ r \subset 'Gal(E / K), uniq r_a
              & minPoly K a = \prod_(b <- r_a) ('X - b%:P)]}
          (galois K E).
Proof.
move=> sKE; apply: (iffP and3P) => [[_ sepKE nKE] a Ea | galKE].
  have [r galEr splitEa] := normalField_factors sKE nKE a Ea.
  exists r; rewrite /= -separable_prod_XsubC !big_map -splitEa.
  by split=> //; apply: separableP Ea.
split=> //.
  apply/separableP => a /galKE[r [_ Ur_a splitKa]].
  by rewrite /separable_element splitKa separable_prod_XsubC.
apply/(normalField_factors sKE)=> a /galKE[r [galEr _ ->]].
by rewrite big_map; exists r.
Qed.

Lemma splitting_galoisField K E :
  reflect (exists p, [/\ p \is a polyOver K, separable_poly p
                       & splittingFieldFor K p E])
          (galois K E).
Proof.
apply: (iffP and3P) => [[sKE sepKE nKE]|[p [Kp sep_p [r Dp defE]]]].
  rewrite (eq_adjoin_separable_generator sepKE) // in nKE *.
  set a := separable_generator K E in nKE *; exists (minPoly K a).
  split; first 1 [exact: minPolyOver | exact/separable_generatorP].
  have [r /= /allP Er splitKa] := normalFieldP nKE a (memv_adjoin _ _).
  exists r; first by rewrite splitKa eqpxx.
  apply/eqP; rewrite eqEsubv; apply/andP; split.
    by apply/Fadjoin_seqP; split => //; apply: subv_adjoin.
  apply/FadjoinP; split; first exact: subv_adjoin_seq.
  by rewrite seqv_sub_adjoin // -root_prod_XsubC -splitKa root_minPoly.
have sKE: (K <= E)%VS by rewrite -defE subv_adjoin_seq.
split=> //; last by apply/splitting_normalField=> //; exists p; last exists r.
rewrite -defE; apply/separable_Fadjoin_seq/allP=> a r_a.
by apply/separable_elementP; exists p; rewrite (eqp_root Dp) root_prod_XsubC.
Qed.

Lemma galois_fixedField K E :
  reflect (fixedField 'Gal(E / K) = K) (galois K E).
Proof.
apply (iffP idP) => [/and3P[sKE /separableP sepKE nKE] | fixedKE].
  apply/eqP; rewrite eqEsubv galois_connection_subv ?andbT //.
  apply/subvP=> a /mem_fixedFieldP[Ea fixEa]; rewrite -adjoin_deg_eq1.
  have [r /allP Er splitKa] := normalFieldP nKE a Ea.
  rewrite -eqSS -size_minPoly splitKa size_prod_XsubC eqSS -/(size [:: a]).
  have Ur: uniq r by rewrite -separable_prod_XsubC -splitKa; apply: sepKE.
  rewrite -uniq_size_uniq {Ur}// => b; rewrite inE -root_prod_XsubC -splitKa.
  apply/eqP/idP=> [-> | pKa_b_0]; first exact: root_minPoly.
  by have [x /fixEa-> ->] := normalField_root_minPoly sKE nKE Ea pKa_b_0.
have sKE: (K <= E)%VS by rewrite -fixedKE capvSl.
apply/galois_factors=> // a Ea.
pose r_pKa := [seq x a | x : gal_of E in 'Gal(E / K)].
have /fin_all_exists2[x_ galEx_ Dx_a] (b : seq_sub r_pKa) := imageP (valP b).
exists (codom x_); rewrite -map_comp; set r := map _ _.
have r_xa x: x \in 'Gal(E / K) -> x a \in r.
  move=> galEx; have r_pKa_xa: x a \in r_pKa by apply/imageP; exists x.
  by rewrite [x a](Dx_a (SeqSub r_pKa_xa)); apply: codom_f.
have Ur: uniq r by apply/injectiveP=> b c /=; rewrite -!Dx_a => /val_inj.
split=> //; first by apply/subsetP=> _ /codomP[b ->].
apply/eqP; rewrite -eqp_monic ?monic_minPoly ?monic_prod_XsubC //.
apply/andP; split; last first.
  rewrite uniq_roots_dvdp ?uniq_rootsE // all_map.
  by apply/allP=> b _ /=; rewrite root_minPoly_gal.
apply: minPoly_dvdp; last by rewrite root_prod_XsubC -(gal_id E a) r_xa ?group1.
rewrite -fixedKE; apply/polyOverP => i; apply/fixedFieldP=> [|x galEx].
  rewrite (polyOverP _) // big_map rpred_prod // => b _.
  by rewrite polyOverXsubC memv_gal.
rewrite -coef_map rmorph_prod; congr (_ : {poly _})`_i.
symmetry; rewrite (perm_big (map x r)) /= ?(big_map x).
  by apply: eq_bigr => b _; rewrite rmorphB /= map_polyX map_polyC.
have Uxr: uniq (map x r) by rewrite map_inj_uniq //; apply: fmorph_inj.
have /uniq_min_size: {subset map x r <= r}.
  by rewrite -map_comp => _ /codomP[b ->] /=; rewrite -galM // r_xa ?groupM.
by rewrite (size_map x) perm_sym; case=> // _ /uniq_perm->.
Qed.

Lemma mem_galTrace K E a : galois K E -> a \in E -> galTrace K E a \in K.
Proof. by move/galois_fixedField => {2}<- /galTrace_fixedField. Qed.

Lemma mem_galNorm K E a : galois K E -> a \in E -> galNorm K E a \in K.
Proof. by move/galois_fixedField=> {2}<- /galNorm_fixedField. Qed.

Lemma gal_independent_contra E (P : pred (gal_of E)) (c_ : gal_of E -> L) x :
    P x -> c_ x != 0 ->
  exists2 a, a \in E & \sum_(y | P y) c_ y * y a != 0.
Proof.
elim: {P}_.+1 c_ x {-2}P (ltnSn #|P|) => // n IHn c_ x P lePn Px nz_cx.
rewrite ltnS (cardD1x Px) in lePn; move/IHn: lePn => {n IHn}/=IH_P.
have [/eqfun_inP c_Px'_0 | ] := boolP [forall (y | P y && (y != x)), c_ y == 0].
  exists 1; rewrite ?mem1v // (bigD1 x Px) /= rmorph1 mulr1.
  by rewrite big1 ?addr0 // => y /c_Px'_0->; rewrite mul0r.
rewrite negb_forall_in => /exists_inP[y Px'y nz_cy].
have [Py /gal_eqP/eqlfun_inP/subvPn[a Ea]] := andP Px'y.
rewrite memv_ker !lfun_simp => nz_yxa; pose d_ y := c_ y * (y a - x a).
have /IH_P[//|b Eb nz_sumb]: d_ y != 0 by rewrite mulf_neq0.
have [sumb_0|] := eqVneq (\sum_(z | P z) c_ z * z b) 0; last by exists b.
exists (a * b); first exact: rpredM.
rewrite -subr_eq0 -[z in _ - z](mulr0 (x a)) -[in z in _ - z]sumb_0.
rewrite mulr_sumr -sumrB (bigD1 x Px) rmorphM /= mulrCA subrr add0r.
congr (_ != 0): nz_sumb; apply: eq_bigr => z _.
by rewrite mulrCA rmorphM -mulrBr -mulrBl mulrA.
Qed.

Lemma gal_independent E (P : pred (gal_of E)) (c_ : gal_of E -> L) :
    (forall a, a \in E -> \sum_(x | P x) c_ x * x a = 0) ->
  (forall x, P x -> c_ x = 0).
Proof.
move=> sum_cP_0 x Px; apply/eqP/idPn=> /(gal_independent_contra Px)[a Ea].
by rewrite sum_cP_0 ?eqxx.
Qed.

Lemma Hilbert's_theorem_90 K E x a :
   generator 'Gal(E / K) x -> a \in E ->
 reflect (exists2 b, b \in E /\ b != 0 & a = b / x b) (galNorm K E a == 1).
Proof.
move/(_ =P <[x]>)=> DgalE Ea.
have galEx: x \in 'Gal(E / K) by rewrite DgalE cycle_id.
apply: (iffP eqP) => [normEa1 | [b [Eb nzb] ->]]; last first.
  by rewrite galNormM galNormV galNorm_gal // mulfV // galNorm_eq0.
have [x1 | ntx] := eqVneq x 1%g.
  exists 1; first by rewrite mem1v oner_neq0.
  by rewrite -{1}normEa1 /galNorm DgalE x1 cycle1 big_set1 !gal_id divr1.
pose c_ y := \prod_(i < invm (injm_Zpm x) y) (x ^+ i)%g a.
have nz_c1: c_ 1%g != 0 by rewrite /c_ morph1 big_ord0 oner_neq0.
have [d] := @gal_independent_contra _ (mem 'Gal(E / K)) _ _ (group1 _) nz_c1.
set b := \sum_(y in _) _ => Ed nz_b; exists b.
  split=> //; apply: rpred_sum => y galEy.
  by apply: rpredM; first apply: rpred_prod => i _; apply: memv_gal.
apply: canRL (mulfK _) _; first by rewrite fmorph_eq0.
rewrite rmorph_sum mulr_sumr [b](reindex_acts 'R _ galEx) ?astabsR //=.
apply: eq_bigr => y galEy; rewrite galM // rmorphM mulrA; congr (_ * _).
have /morphimP[/= i _ _ ->] /=: y \in Zpm @* Zp #[x] by rewrite im_Zpm -DgalE.
have <-: Zpm (i + 1) = (Zpm i * x)%g by rewrite morphM ?mem_Zp ?order_gt1.
rewrite /c_ !invmE ?mem_Zp ?order_gt1 //= addn1; set n := _.+2.
transitivity (\prod_(j < i.+1) (x ^+ j)%g a).
  rewrite big_ord_recl gal_id rmorph_prod; congr (_ * _).
  by apply: eq_bigr => j _; rewrite expgSr galM ?lfunE.
have [/modn_small->//||->] := ltngtP i.+1 n; first by rewrite ltnNge ltn_ord.
rewrite modnn big_ord0; apply: etrans normEa1; rewrite /galNorm DgalE -im_Zpm.
rewrite morphimEdom big_imset /=; last exact/injmP/injm_Zpm.
by apply: eq_bigl => j /=; rewrite mem_Zp ?order_gt1.
Qed.

Section Matrix.

Variable (E : {subfield L}) (A : {set gal_of E}).

Let K := fixedField A.

Lemma gal_matrix :
  {w : #|A|.-tuple L | {subset w <= E} /\ 0 \notin w &
    [/\ \matrix_(i, j < #|A|) enum_val i (tnth w j) \in unitmx,
        directv (\sum_i K * <[tnth w i]>) &
        group_set A -> (\sum_i K * <[tnth w i]>)%VS = E] }.
Proof.
pose nzE (w : #|A|.-tuple L) := {subset w <= E} /\ 0 \notin w.
pose M w := \matrix_(i, j < #|A|) nth 1%g (enum A) i (tnth w j).
have [w [Ew nzw] uM]: {w : #|A|.-tuple L | nzE w & M w \in unitmx}.
  rewrite {}/nzE {}/M cardE; have: uniq (enum A) := enum_uniq _.
  elim: (enum A) => [|x s IHs] Uxs.
    by exists [tuple]; rewrite // flatmx0 -(flatmx0 1%:M) unitmx1.
  have [s'x Us]: x \notin s /\ uniq s by apply/andP.
  have{IHs} [w [Ew nzw] uM] := IHs Us; set M := \matrix_(i, j) _ in uM.
  pose a := \row_i x (tnth w i) *m invmx M.
  pose c_ y := oapp (a 0) (-1) (insub (index y s)).
  have cx_n1 : c_ x = -1 by rewrite /c_ insubN ?index_mem.
  have nz_cx : c_ x != 0 by rewrite cx_n1 oppr_eq0 oner_neq0.
  have Px: [pred y in x :: s] x := mem_head x s.
  have{Px nz_cx} /sig2W[w0 Ew0 nzS] := gal_independent_contra Px nz_cx.
  exists [tuple of cons w0 w].
    split; first by apply/allP; rewrite /= Ew0; apply/allP.
    rewrite inE negb_or (contraNneq _ nzS) // => <-.
    by rewrite big1 // => y _; rewrite rmorph0 mulr0.
  rewrite unitmxE -[\det _]mul1r; set M1 := \matrix_(i, j < 1 + size s) _.
  have <-: \det (block_mx 1 (- a) 0 1%:M) = 1 by rewrite det_ublock !det1 mulr1.
  rewrite -det_mulmx -[M1]submxK mulmx_block !mul0mx !mul1mx !add0r !mulNmx.
  have ->: drsubmx M1 = M by apply/matrixP => i j; rewrite !mxE !(tnth_nth 0).
  have ->: ursubmx M1 - a *m M = 0.
    by apply/rowP=> i; rewrite mulmxKV // !mxE !(tnth_nth 0) subrr.
  rewrite det_lblock unitrM andbC -unitmxE uM unitfE -oppr_eq0.
  congr (_ != 0): nzS; rewrite [_ - _]mx11_scalar det_scalar !mxE opprB /=.
  rewrite -big_uniq // big_cons /= cx_n1 mulN1r addrC; congr (_ + _).
  rewrite (big_nth 1%g) big_mkord; apply: eq_bigr => j _.
  by rewrite /c_ index_uniq // valK; congr (_ * _); rewrite !mxE.
exists w => [//|]; split=> [||gA].
- by congr (_ \in unitmx): uM; apply/matrixP=> i j; rewrite !mxE -enum_val_nth.
- apply/directv_sum_independent=> kw_ Kw_kw sum_kw_0 j _.
  have /fin_all_exists2[k_ Kk_ Dk_] i := memv_cosetP (Kw_kw i isT).
  pose kv := \col_i k_ i.
  transitivity (kv j 0 * tnth w j); first by rewrite !mxE.
  suffices{j}/(canRL (mulKmx uM))->: M w *m kv = 0 by rewrite mulmx0 mxE mul0r.
  apply/colP=> i; rewrite !mxE; pose Ai := nth 1%g (enum A) i.
  transitivity (Ai (\sum_j kw_ j)); last by rewrite sum_kw_0 rmorph0.
  rewrite rmorph_sum; apply: eq_bigr => j _; rewrite !mxE /= -/Ai.
  rewrite Dk_ mulrC rmorphM /=; congr (_ * _).
  by have /mem_fixedFieldP[_ -> //] := Kk_ j; rewrite -mem_enum mem_nth -?cardE.
pose G := group gA; have G_1 := group1 G; pose iG := enum_rank_in G_1.
apply/eqP; rewrite eqEsubv; apply/andP; split.
  apply/subv_sumP=> i _; apply: subv_trans (asubv _).
  by rewrite prodvS ?capvSl // -memvE Ew ?mem_tnth.
apply/subvP=> w0 Ew0; apply/memv_sumP.
pose wv := \col_(i < #|A|) enum_val i w0; pose v := invmx (M w) *m wv.
exists (fun i => tnth w i * v i 0) => [i _|]; last first.
  transitivity (wv (iG 1%g) 0); first by rewrite mxE enum_rankK_in ?gal_id.
  rewrite -[wv](mulKVmx uM) -/v; rewrite mxE; apply: eq_bigr => i _.
  by congr (_ * _); rewrite !mxE -enum_val_nth enum_rankK_in ?gal_id.
rewrite mulrC memv_mul ?memv_line //; apply/fixedFieldP=> [|x Gx].
  rewrite mxE rpred_sum // => j _; rewrite !mxE rpredM //; last exact: memv_gal.
  have E_M k l: M w k l \in E by rewrite mxE memv_gal // Ew ?mem_tnth.
  have Edet n (N : 'M_n) (E_N : forall i j, N i j \in E): \det N \in E.
    by apply: rpred_sum => sigma _; rewrite rpredMsign rpred_prod.
  rewrite /invmx uM 2!mxE mulrC rpred_div ?Edet //.
  by rewrite rpredMsign Edet // => k l; rewrite 2!mxE.
suffices{i} {2}<-: map_mx x v = v by rewrite [map_mx x v i 0]mxE.
have uMx: map_mx x (M w) \in unitmx by rewrite map_unitmx.
rewrite map_mxM map_invmx /=; apply: canLR {uMx}(mulKmx uMx) _.
apply/colP=> i; rewrite !mxE; pose ix := iG (enum_val i * x)%g.
have Dix b: b \in E -> enum_val ix b = x (enum_val i b).
  by move=> Eb; rewrite enum_rankK_in ?groupM ?enum_valP // galM ?lfunE.
transitivity ((M w *m v) ix 0); first by rewrite mulKVmx // mxE Dix.
rewrite mxE; apply: eq_bigr => j _; congr (_ * _).
by rewrite !mxE -!enum_val_nth Dix // ?Ew ?mem_tnth.
Qed.

End Matrix.

Lemma dim_fixedField E (G : {group gal_of E}) : #|G| = \dim_(fixedField G) E.
Proof.
have [w [_ nzw] [_ Edirect /(_ (groupP G))defE]] := gal_matrix G.
set n := #|G|; set m := \dim (fixedField G); rewrite -defE (directvP Edirect).
rewrite -[n]card_ord -(@mulnK #|'I_n| m) ?adim_gt0 //= -sum_nat_const.
congr (_ %/ _)%N; apply: eq_bigr => i _.
by rewrite dim_cosetv ?(memPn nzw) ?mem_tnth.
Qed.

Lemma dim_fixed_galois K E (G : {group gal_of E}) :
    galois K E -> G \subset 'Gal(E / K) ->
  \dim_K (fixedField G) = #|'Gal(E / K) : G|.
Proof.
move=> galE sGgal; have [sFE _ _] := and3P galE; apply/eqP.
rewrite -divgS // eqn_div ?cardSg // dim_fixedField -galois_dim //.
by rewrite mulnC muln_divA ?divnK ?field_dimS ?capvSl -?galois_connection.
Qed.

Lemma gal_fixedField E (G : {group gal_of E}): 'Gal(E / fixedField G) = G.
Proof.
apply/esym/eqP; rewrite eqEcard galois_connection_subset /= (dim_fixedField G).
rewrite galois_dim //; apply/galois_fixedField/eqP.
rewrite eqEsubv galois_connection_subv ?capvSl //.
by rewrite fixedFieldS ?galois_connection_subset.
Qed.

Lemma gal_generated E (A : {set gal_of E}) : 'Gal(E / fixedField A) = <<A>>.
Proof.
apply/eqP; rewrite eqEsubset gen_subG galois_connection_subset.
by rewrite -[<<A>>]gal_fixedField galS // fixedFieldS // subset_gen.
Qed.

Lemma fixedField_galois E (A : {set gal_of E}): galois (fixedField A) E.
Proof.
have: galois (fixedField <<A>>) E.
  by apply/galois_fixedField; rewrite gal_fixedField.
by apply: galoisS; rewrite capvSl fixedFieldS // subset_gen.
Qed.

Section FundamentalTheoremOfGaloisTheory.

Variables E K : {subfield L}.
Hypothesis galKE : galois K E.

Section IntermediateField.

Variable M : {subfield L}.
Hypothesis (sKME : (K <= M <= E)%VS) (nKM : normalField K M).

Lemma normalField_galois : galois K M.
Proof.
have [[sKM sME] [_ sepKE nKE]] := (andP sKME, and3P galKE).
by rewrite /galois sKM (separableSr sME).
Qed.

Definition normalField_cast (x : gal_of E) : gal_of M := gal M x.

Lemma normalField_cast_eq x :
  x \in 'Gal(E / K) -> {in M, normalField_cast x =1 x}.
Proof.
have [sKM sME] := andP sKME; have sKE := subv_trans sKM sME.
rewrite gal_kAut // => /(normalField_kAut sKME nKM).
by rewrite kAutE => /andP[_ /galK].
Qed.

Lemma normalField_castM :
  {in 'Gal(E / K) &, {morph normalField_cast : x y / (x * y)%g}}.
Proof.
move=> x y galEx galEy /=; apply/eqP/gal_eqP => a Ma.
have Ea: a \in E by have [_ /subvP->] := andP sKME.
rewrite normalField_cast_eq ?groupM ?galM //=.
by rewrite normalField_cast_eq ?memv_gal // normalField_cast_eq.
Qed.
Canonical normalField_cast_morphism := Morphism normalField_castM.

Lemma normalField_ker : 'ker normalField_cast = 'Gal(E / M).
Proof.
have [sKM sME] := andP sKME.
apply/setP=> x; apply/idP/idP=> [kerMx | galEMx].
  rewrite gal_kHom //; apply/kAHomP=> a Ma.
  by rewrite -normalField_cast_eq ?(dom_ker kerMx) // (mker kerMx) gal_id.
have galEM: x \in 'Gal(E / K) := subsetP (galS E sKM) x galEMx.
apply/kerP=> //; apply/eqP/gal_eqP=> a Ma.
by rewrite normalField_cast_eq // gal_id (fixed_gal sME).
Qed.

Lemma normalField_normal : 'Gal(E / M) <| 'Gal(E / K).
Proof. by rewrite -normalField_ker ker_normal. Qed.

Lemma normalField_img : normalField_cast @* 'Gal(E / K) = 'Gal(M / K).
Proof.
have [[sKM sME] [sKE _ nKE]] := (andP sKME, and3P galKE).
apply/setP=> x; apply/idP/idP=> [/morphimP[{x}x galEx _ ->] | galMx].
  rewrite gal_kHom //; apply/kAHomP=> a Ka; have Ma := subvP sKM a Ka.
  by rewrite normalField_cast_eq // (fixed_gal sKE).
have /(kHom_to_gal sKME nKE)[y galEy eq_xy]: kHom K M x by rewrite -gal_kHom.
apply/morphimP; exists y => //; apply/eqP/gal_eqP => a Ha.
by rewrite normalField_cast_eq // eq_xy.
Qed.

Lemma normalField_isom :
  {f : {morphism ('Gal(E / K) / 'Gal(E / M)) >-> gal_of M} |
     isom ('Gal(E / K) / 'Gal (E / M)) 'Gal(M / K) f
   & (forall A, f @* (A / 'Gal(E / M)) = normalField_cast @* A)
  /\ {in 'Gal(E / K) & M, forall x, f (coset 'Gal (E / M) x) =1 x} }%g.
Proof.
have:= first_isom normalField_cast_morphism; rewrite normalField_ker.
case=> f injf Df; exists f; first by apply/isomP; rewrite Df normalField_img.
split=> [//|x a galEx /normalField_cast_eq<- //]; congr ((_ : gal_of M) a).
apply: set1_inj; rewrite -!morphim_set1 ?mem_quotient ?Df //.
by rewrite (subsetP (normal_norm normalField_normal)).
Qed.

Lemma normalField_isog : 'Gal(E / K) / 'Gal(E / M) \isog 'Gal(M / K).
Proof. by rewrite -normalField_ker -normalField_img first_isog. Qed.

End IntermediateField.

Section IntermediateGroup.

Variable G : {group gal_of E}.
Hypothesis nsGgalE : G <| 'Gal(E / K).

Lemma normal_fixedField_galois : galois K (fixedField G).
Proof.
have [[sKE sepKE nKE] [sGgal nGgal]] := (and3P galKE, andP nsGgalE).
rewrite /galois -(galois_connection _ sKE) sGgal.
rewrite (separableSr _ sepKE) ?capvSl //; apply/forall_inP=> f autKf.
rewrite eqEdim limg_dim_eq ?(eqP (AEnd_lker0 _)) ?capv0 // leqnn andbT.
apply/subvP => _ /memv_imgP[a /mem_fixedFieldP[Ea cGa] ->].
have /kAut_to_gal[x galEx -> //]: kAut K E f.
  rewrite /kAut (forall_inP nKE) // andbT; apply/kAHomP.
  by move: autKf; rewrite inE kAutfE => /kHomP[].
apply/fixedFieldP=> [|y Gy]; first exact: memv_gal.
by rewrite -galM // conjgCV galM //= cGa // memJ_norm ?groupV ?(subsetP nGgal).
Qed.

End IntermediateGroup.

End FundamentalTheoremOfGaloisTheory.

End GaloisTheory.

Prenex Implicits gal_repr gal gal_reprK.
Arguments gal_repr_inj {F L V} [x1 x2].

Notation "''Gal' ( V / U )" := (galoisG V U) : group_scope.
Notation "''Gal' ( V / U )" := (galoisG_group V U) : Group_scope.

Arguments fixedFieldP {F L E A a}.
Arguments normalFieldP {F L K E}.
Arguments splitting_galoisField {F L K E}.
Arguments galois_fixedField {F L K E}.