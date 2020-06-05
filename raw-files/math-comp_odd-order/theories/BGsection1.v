
Require Import mathcomp.ssreflect.ssreflect.
From mathcomp
Require Import ssrbool ssrfun eqtype ssrnat seq path div fintype.
From mathcomp
Require Import bigop prime binomial finset fingroup morphism perm automorphism.
From mathcomp
Require Import quotient action gproduct gfunctor commutator.
From mathcomp
Require Import ssralg finalg zmodp cyclic center pgroup finmodule gseries.
From mathcomp
Require Import nilpotent sylow abelian maximal hall extremal.
From mathcomp
Require Import matrix mxalgebra mxrepresentation mxabelem.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Import GroupScope.

Section Definitions.

Variables (n : nat) (gT : finGroupType).
Implicit Type p : nat.

Definition plength_1 p (G : {set gT}) := 'O_{p^', p, p^'}(G) == G.

Definition p_elt_gen p (G : {set gT}) := <<[set x in G | p.-elt x]>>.

Definition p_constrained p (G : {set gT}) :=
  forall P : {group gT},
    p.-Sylow('O_{p^',p}(G)) P ->
  'C_G(P) \subset 'O_{p^',p}(G).

Definition p_abelian_constrained p (G : {set gT}) :=
  forall S A : {group gT},
    p.-Sylow(G) S -> abelian A -> A <| S ->
  A \subset 'O_{p^',p}(G).

Definition p_stable p (G : {set gT}) :=
  forall P A : {group gT},
     p.-group P -> 'O_p^'(G) * P <| G ->
     p.-subgroup('N_G(P)) A -> [~: P, A, A] = 1 ->
  A / 'C_G(P) \subset 'O_p('N_G(P) / 'C_G(P)).

Definition generated_by (gp : pred {group gT}) (E : {set gT}) :=
  [exists gE : {set {group gT}}, <<\bigcup_(G in gE | gp G) G>> == E].

Definition norm_abelian (D : {set gT}) : pred {group gT} :=
  fun A => (D \subset 'N(A)) && abelian A.

Definition p_norm_abelian p (D : {set gT}) : pred {group gT} :=
  fun A => p.-group A && norm_abelian D A.

Definition Puig_succ (D E : {set gT}) :=
  <<\bigcup_(A in subgroups D | norm_abelian E A) A>>.

Definition Puig_rec D := iter n (Puig_succ D) 1.

End Definitions.

Definition Puig_at := nosimpl Puig_rec.

Definition Puig_inf (gT : finGroupType) (G : {set gT}) := Puig_at #|G|.*2 G.

Definition Puig (gT : finGroupType) (G : {set gT}) := Puig_at #|G|.*2.+1 G.

Notation "p .-length_1" := (plength_1 p)
  (at level 2, format "p .-length_1") : group_scope.

Notation "p .-constrained" := (p_constrained p)
  (at level 2, format "p .-constrained") : group_scope.
Notation "p .-abelian_constrained" := (p_abelian_constrained p)
  (at level 2, format "p .-abelian_constrained") : group_scope.
Notation "p .-stable" := (p_stable p)
  (at level 2, format "p .-stable") : group_scope.

Notation "''L_[' G ] ( L )" := (Puig_succ G L)
  (at level 8, format  "''L_[' G ] ( L )") : group_scope.
Notation "''L_{' n } ( G )" := (Puig_at n G)
  (at level 8, format "''L_{' n } ( G )") : group_scope.
Notation "''L_*' ( G )" := (Puig_inf G)
  (at level 8, format "''L_*' ( G )") : group_scope.
Notation "''L' ( G )" := (Puig G)
  (at level 8, format "''L' ( G )") : group_scope.

Section BGsection1.

Implicit Types (gT : finGroupType) (p : nat).

Lemma minnormal_solvable_abelem gT (M G : {group gT}) :
  minnormal M G -> solvable M -> is_abelem M.
Proof. by move=> minM solM; case: (minnormal_solvable minM (subxx _) solM). Qed.

Lemma minnormal_solvable_Fitting_center gT (M G : {group gT}) :
  minnormal M G ->  M \subset G -> solvable M -> M \subset 'Z('F(G)).
Proof.
have nZG: 'Z('F(G)) <| G by rewrite !gFnormal_trans.
move=> minM sMG solM; have[/andP[ntM nMG] minM'] := mingroupP minM.
apply/setIidPl/minM'; last exact: subsetIl.
apply/andP; split; last by rewrite normsI // normal_norm.
apply: meet_center_nil => //; first by apply: Fitting_nil.
apply/andP; split; last exact: gFsub_trans.
apply: Fitting_max; rewrite // /normal ?sMG //; apply: abelian_nil.
by move: (minnormal_solvable_abelem minM solM) => /abelem_abelian.
Qed.

Lemma sol_chief_abelem gT (G V U : {group gT}) :
  solvable G -> chief_factor G V U -> is_abelem (U / V).
Proof.
move=> solG chiefUV; have minUV := chief_factor_minnormal chiefUV.
have [|//] := minnormal_solvable minUV (quotientS _ _) (quotient_sol _ solG).
by case/and3P: chiefUV.
Qed.

Section HallLemma.

Variables (gT : finGroupType) (G G' : {group gT}).

Hypothesis solG : solvable G.
Hypothesis nsG'G : G' <| G.

Let sG'G : G' \subset G. Proof. exact: normal_sub. Qed.
Let nG'G : G \subset 'N(G'). Proof. exact: normal_norm. Qed.
Let nsF'G : 'F(G') <| G. Proof. exact: gFnormal_trans. Qed.

Let Gchief (UV : {group gT} * {group gT}) := chief_factor G UV.2 UV.1.
Let H := \bigcap_(UV | Gchief UV) 'C(UV.1 / UV.2 | 'Q).
Let H' :=
  G' :&: \bigcap_(UV | Gchief UV && (UV.1 \subset 'F(G'))) 'C(UV.1 / UV.2 | 'Q).

Proposition Fitting_stab_chief : 'F(G') \subset H.
Proof.
apply/bigcapsP=> [[U V] /= chiefUV].
have minUV: minnormal (U / V) (G / V) := chief_factor_minnormal chiefUV.
have{chiefUV} [/=/maxgroupp/andP[_ nVG] sUG nUG] := and3P chiefUV.
have solUV: solvable (U / V) by rewrite quotient_sol // (solvableS sUG).
have{solUV minUV}: U / V \subset 'Z('F(G / V)).
  exact: minnormal_solvable_Fitting_center minUV (quotientS V sUG) solUV.
rewrite sub_astabQ gFsub_trans ?(subset_trans sG'G) //=.
case/subsetIP=> _; rewrite centsC; apply: subset_trans.
by rewrite Fitting_max ?quotient_normal ?quotient_nil ?Fitting_nil.
Qed.

Proposition chief_stab_sub_Fitting : H' \subset 'F(G').
Proof.
without loss: / {K | [min K | K <| G & ~~ (K \subset 'F(G'))] & K \subset H'}.
  move=> IH; apply: wlog_neg => s'H'F; apply/IH/mingroup_exists=> {IH}/=.
  rewrite /normal subIset ?sG'G ?normsI ?norms_bigcap {s'H'F}//.
  apply/bigcapsP=> /= U /andP[/and3P[/maxgroupp/andP/=[_ nU2G] _ nU1G] _].
  exact: subset_trans (actsQ nU2G nU1G) (astab_norm 'Q (U.1 / U.2)).
case=> K /mingroupP[/andP[nsKG s'KF] minK] /subsetIP[sKG' nFK].
have [[Ks chiefKs defK] sKG]:= (chief_series_exists nsKG, normal_sub nsKG).
suffices{nsKG s'KF} cKsK: (K.-central).-series 1%G Ks.
  by rewrite Fitting_max ?(normalS _ sG'G) ?(centrals_nil cKsK) in s'KF.
move: chiefKs; rewrite -!(rev_path _ _ Ks) {}defK.
case: {Ks}(rev _) => //= K1 Kr /andP[chiefK1 chiefKr].
have [/maxgroupp/andP[/andP[sK1K ltK1K] nK1G] _] := andP chiefK1.
suffices{chiefK1} cKrK: [rel U V | central_factor K V U].-series K1 Kr.
  have cKK1: abelian (K / K1) := abelem_abelian (sol_chief_abelem solG chiefK1).
  by rewrite /central_factor subxx sK1K der1_min //= (subset_trans sKG).
have{minK ltK1K nK1G} sK1F: K1 \subset 'F(G').
  have nsK1G: K1 <| G by rewrite /normal (subset_trans sK1K).
  by apply: contraR ltK1K => s'K1F; rewrite (minK K1) ?nsK1G.
elim: Kr K1 chiefKr => //= K2 Kr IHr K1 /andP[chiefK2 chiefKr] in sK1F sK1K *.
have [/maxgroupp/andP[/andP[sK21 _] /(subset_trans sKG)nK2K] _] := andP chiefK2.
rewrite /central_factor sK1K {}IHr ?(subset_trans sK21) {chiefKr}// !andbT.
rewrite commGC -sub_astabQR ?(subset_trans _ nK2K) //.
exact/(subset_trans nFK)/(bigcap_inf (K1, K2))/andP.
Qed.

End HallLemma.

Proposition cent_sub_Fitting gT (G : {group gT}) :
  solvable G -> 'C_G('F(G)) \subset 'F(G).
Proof.
move=> solG; apply: subset_trans (chief_stab_sub_Fitting solG _) => //.
rewrite subsetI subsetIl; apply/bigcapsP=> [[U V]] /=.
case/andP=> /andP[/maxgroupp/andP[_ nVG] _] sUF.
by rewrite astabQ (subset_trans _ (morphpre_cent _ _)) // setISS ?centS.
Qed.

Proposition coprime_trivg_cent_Fitting gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|G| #|A| -> solvable G ->
  'C_A(G) = 1 -> 'C_A('F(G)) = 1.
Proof.
move=> nGA coGA solG regAG; without loss cycA: A nGA coGA regAG / cyclic A.
  move=> IH; apply/trivgP/subsetP=> a; rewrite -!cycle_subG subsetI.
  case/andP=> saA /setIidPl <-.
  rewrite {}IH ?cycle_cyclic ?(coprimegS saA) ?(subset_trans saA) //.
  by apply/trivgP; rewrite -regAG setSI.
pose X := G <*> A; pose F := 'F(X); pose pi := \pi(A); pose Q := 'O_pi(F).
have pi'G: pi^'.-group G by rewrite /pgroup -coprime_pi' //= coprime_sym.
have piA: pi.-group A by apply: pgroup_pi.
have oX: #|X| = (#|G| * #|A|)%N by rewrite [X]norm_joinEr ?coprime_cardMg.
have hallG: pi^'.-Hall(X) G.
  by rewrite /pHall -divgS joing_subl //= pi'G pnatNK oX mulKn.
have nsGX: G <| X by rewrite /normal joing_subl join_subG normG.
have{oX pi'G piA} hallA: pi.-Hall(X) A.
  by rewrite /pHall -divgS joing_subr //= piA oX mulnK.
have nsQX: Q <| X by rewrite !gFnormal_trans.
have{solG cycA} solX: solvable X.
  rewrite (series_sol nsGX) {}solG /= norm_joinEr // quotientMidl //.
  by rewrite morphim_sol // abelian_sol // cyclic_abelian.
have sQA: Q \subset A.
  by apply: normal_sub_max_pgroup (Hall_max hallA) (pcore_pgroup _ _) nsQX.
have pi'F: 'O_pi(F) = 1.
  suff cQG: G \subset 'C(Q) by apply/trivgP; rewrite -regAG subsetI sQA centsC.
  apply/commG1P/trivgP; rewrite -(coprime_TIg coGA) subsetI commg_subl.
  rewrite (subset_trans sQA) // (subset_trans _ sQA) // commg_subr.
  by rewrite (subset_trans _ (normal_norm nsQX)) ?joing_subl.
have sFG: F \subset G.
  have /dprodP[_ defF _ _]: _ = F := nilpotent_pcoreC pi (Fitting_nil _).
  by rewrite (sub_normal_Hall hallG) ?gFsub //= -defF pi'F mul1g pcore_pgroup.
have <-: F = 'F(G).
  apply/eqP; rewrite eqEsubset -{1}(setIidPr sFG) FittingS ?joing_subl //=.
  by rewrite Fitting_max ?Fitting_nil // gFnormal_trans.
apply/trivgP; rewrite /= -(coprime_TIg coGA) subsetI subsetIl andbT.
apply: subset_trans (subset_trans (cent_sub_Fitting solX) sFG).
by rewrite setSI ?joing_subr.
Qed.

Proposition coprime_cent_Fitting gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|G| #|A| -> solvable G ->
  'C_A('F(G)) \subset 'C(G).
Proof.
move=> nGA coGA solG; apply: subset_trans (subsetIr A _); set C := 'C_A(G).
rewrite -quotient_sub1 /= -/C; last first.
  by rewrite subIset // normsI ?normG // norms_cent.
apply: subset_trans (quotient_subcent _ _ _) _; rewrite /= -/C.
have nCG: G \subset 'N(C) by rewrite cents_norm // centsC subsetIr.
rewrite /= -(setIidPr (Fitting_sub _)) -[(G :&: _) / _](morphim_restrm nCG).
rewrite injmF //=; last first.
  by rewrite ker_restrm ker_coset setIA (coprime_TIg coGA) subIset ?subxx.
rewrite morphim_restrm -quotientE setIid.
rewrite coprime_trivg_cent_Fitting ?quotient_norms ?coprime_morph //=.
  exact: morphim_sol.
rewrite -strongest_coprime_quotient_cent ?trivg_quotient ?solG ?orbT //.
  by rewrite -setIA subsetIl.
by rewrite coprime_sym -setIA (coprimegS (subsetIl _ _)).
Qed.

Proposition coprimeR_cent_prod gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|[~: G, A]| #|A| -> solvable [~: G, A] ->
  [~: G, A] * 'C_G(A) = G.
Proof.
move=> nGA coRA solR; apply/eqP; rewrite eqEsubset mulG_subG commg_subl nGA.
rewrite subsetIl -quotientSK ?commg_norml //=.
rewrite coprime_norm_quotient_cent ?commg_normr //=.
by rewrite subsetI subxx quotient_cents2r.
Qed.

Proposition coprime_cent_prod gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|G| #|A| -> solvable G ->
  [~: G, A] * 'C_G(A) = G.
Proof.
move=> nGA; have sRG: [~: G, A] \subset G by rewrite commg_subl.
rewrite -(Lagrange sRG) coprime_mull => /andP[coRA _] /(solvableS sRG).
exact: coprimeR_cent_prod.
Qed.

Proposition coprime_commGid gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|G| #|A| -> solvable G ->
  [~: G, A, A] = [~: G, A].
Proof.
move=> nGA coGA solG; apply/eqP; rewrite eqEsubset commSg ?commg_subl //.
have nAC: 'C_G(A) \subset 'N(A) by rewrite subIset ?cent_sub ?orbT.
rewrite -{1}(coprime_cent_prod nGA) // commMG //=; first 1 last.
  by rewrite !normsR // subIset ?normG.
by rewrite (commG1P (subsetIr _ _)) mulg1.
Qed.

Proposition coprime_commGG1P gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|G| #|A| -> solvable G ->
  [~: G, A, A] = 1 -> A \subset 'C(G).
Proof.
by move=> nGA coGA solG; rewrite centsC coprime_commGid // => /commG1P.
Qed.

Definition coprime_abel_cent_TI := coprime_abel_cent_TI.

Proposition coprime_abelian_cent_dprod gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|G| #|A| -> abelian G ->
  [~: G, A] \x 'C_G(A) = G.
Proof.
move=> nGA coGA abelG; rewrite dprodE ?coprime_cent_prod ?abelian_sol //.
  by rewrite subIset 1?(subset_trans abelG) // centS // commg_subl.
by apply/trivgP; rewrite /= setICA coprime_abel_cent_TI ?subsetIr.
Qed.

Proposition coprime_abelian_faithful_Ohm1 gT (A G : {group gT}) :
    A \subset 'N(G) -> coprime #|G| #|A| -> abelian G ->
  A \subset 'C('Ohm_1(G)) -> A \subset 'C(G).
Proof.
move=> nGA coGA cGG; rewrite !(centsC A) => cAG1.
have /dprodP[_ defG _ tiRC] := coprime_abelian_cent_dprod nGA coGA cGG.
have sRG: [~: G, A] \subset G by rewrite commg_subl.
rewrite -{}defG -(setIidPl sRG) TI_Ohm1 ?mul1g ?subsetIr //.
by apply/trivgP; rewrite -{}tiRC setIS // subsetI Ohm_sub.
Qed.

Proposition coprime_cent_Phi gT p (A G : {group gT}) :
    p.-group G -> coprime #|G| #|A| -> [~: G, A] \subset 'Phi(G) ->
  A \subset 'C(G).
Proof.
move=> pG coGA sRphi; rewrite centsC; apply/setIidPl.
rewrite -['C_G(A)]genGid; apply/Phi_nongen/eqP.
rewrite eqEsubset join_subG Phi_sub subsetIl -genM_join sub_gen //=.
rewrite -{1}(coprime_cent_prod _ coGA) ?(pgroup_sol pG) ?mulSg //.
by rewrite -commg_subl (subset_trans sRphi) ?Phi_sub.
Qed.

Proposition stable_factor_cent gT (A G H : {group gT}) :
    A \subset 'C(H) -> stable_factor A H G ->
    coprime #|G| #|A| -> solvable G ->
  A \subset 'C(G).
Proof.
move=> cHA /and3P[sRH sHG nHG] coGA solG.
suffices: G \subset 'C_G(A) by rewrite subsetI subxx centsC.
rewrite -(quotientSGK nHG) ?subsetI ?sHG 1?centsC //.
by rewrite coprime_quotient_cent ?cents_norm ?subsetI ?subxx ?quotient_cents2r.
Qed.

Proposition stable_series_cent gT (A G : {group gT}) s :
   last 1%G s :=: G -> (A.-stable).-series 1%G s ->
   coprime #|G| #|A| -> solvable G ->
  A \subset 'C(G).
Proof.
move=> <-{G}; elim/last_ind: s => /= [|s G IHs]; first by rewrite cents1.
rewrite last_rcons rcons_path /= => /andP[/IHs{IHs}].
move: {s}(last _ _) => H IH_H nHGA coGA solG; have [_ sHG _] := and3P nHGA.
by rewrite (stable_factor_cent _ nHGA) ?IH_H ?(solvableS sHG) ?(coprimeSg sHG).
Qed.

Proposition coprime_nil_faithful_cent_stab gT (A G : {group gT}) :
     A \subset 'N(G) -> coprime #|G| #|A| -> nilpotent G ->
  let C := 'C_G(A) in 'C_G(C) \subset C -> A \subset 'C(G).
Proof.
move=> nGA coGA nilG C; rewrite subsetI subsetIl centsC /= -/C => cCA.
pose N := 'N_G(C); have sNG: N \subset G by rewrite subsetIl.
have sCG: C \subset G by rewrite subsetIl.
suffices cNA : A \subset 'C(N).
  rewrite centsC (sameP setIidPl eqP) -(nilpotent_sub_norm nilG sCG) //= -/C.
  by rewrite subsetI subsetIl centsC.
have{nilG} solN: solvable N by rewrite (solvableS sNG) ?nilpotent_sol.
rewrite (stable_factor_cent cCA) ?(coprimeSg sNG) /stable_factor //= -/N -/C.
rewrite subcent_normal subsetI (subset_trans (commSg A sNG)) ?commg_subl //=.
rewrite comm_norm_cent_cent 1?centsC ?subsetIr // normsI // !norms_norm //.
by rewrite cents_norm 1?centsC ?subsetIr.
Qed.

Theorem coprime_odd_faithful_Ohm1 gT p (A G : {group gT}) :
    p.-group G -> A \subset 'N(G) -> coprime #|G| #|A| -> odd #|G| ->
  A \subset 'C('Ohm_1(G)) -> A \subset 'C(G).
Proof.
move=> pG nGA coGA oddG; rewrite !(centsC A) => cAG1.
have [-> | ntG] := eqsVneq G 1; first exact: sub1G.
have{oddG ntG} [p_pr oddp]: prime p /\ odd p.
  have [p_pr p_dv_G _] := pgroup_pdiv pG ntG.
  by rewrite !odd_2'nat in oddG *; rewrite pnatE ?(pgroupP oddG).
without loss defR: G pG nGA coGA cAG1 / [~: G, A] = G.
  move=> IH; have solG := pgroup_sol pG.
  rewrite -(coprime_cent_prod nGA) ?mul_subG ?subsetIr //=.
  have sRG: [~: G, A] \subset G by rewrite commg_subl.
  rewrite IH ?coprime_commGid ?(pgroupS sRG) ?commg_normr ?(coprimeSg sRG) //.
  by apply: subset_trans cAG1; apply: OhmS.
have [|[defPhi defG'] defC] := abelian_charsimple_special pG coGA defR.
  apply/bigcupsP=> H /andP[chH abH]; have sHG := char_sub chH.
  have nHA := char_norm_trans chH nGA.
  rewrite centsC coprime_abelian_faithful_Ohm1 ?(coprimeSg sHG) //.
  by rewrite centsC (subset_trans (OhmS 1 sHG)).
have abelZ: p.-abelem 'Z(G) by apply: center_special_abelem.
have cAZ: {in 'Z(G), centralised A} by apply/centsP; rewrite -defC subsetIr.
have cGZ: {in 'Z(G), centralised G} by apply/centsP; rewrite subsetIr.
have defG1: 'Ohm_1(G) = 'Z(G).
  apply/eqP; rewrite eqEsubset -{1}defC subsetI Ohm_sub cAG1 /=.
  by rewrite -(Ohm1_id abelZ) OhmS ?center_sub.
rewrite (subset_trans _ (subsetIr G _)) // defC -defG1 -{1}defR gen_subG /=.
apply/subsetP=> _ /imset2P[x a Gx Aa ->]; rewrite commgEl.
set u := x^-1; set v := x ^ a; pose w := [~ v, u].
have [Gu Gv]: u \in G /\ v \in G by rewrite groupV memJ_norm ?(subsetP nGA).
have Zw: w \in 'Z(G) by rewrite -defG' mem_commg.
rewrite (OhmE 1 pG) mem_gen // !inE expn1 groupM //=.
rewrite expMg_Rmul /commute ?(cGZ w) // bin2odd // expgM.
case/(abelemP p_pr): abelZ => _ /(_ w)-> //.
rewrite expg1n mulg1 expgVn -conjXg (sameP commgP eqP) cAZ // -defPhi.
by rewrite (Phi_joing pG) joingC mem_gen // inE (Mho_p_elt 1) ?(mem_p_elt pG).
Qed.

Corollary coprime_odd_faithful_cent_abelem gT p (A G E : {group gT}) :
    E \in 'E_p(G) -> p.-group G ->
    A \subset 'N(G) -> coprime #|G| #|A| -> odd #|G| ->
  A \subset 'C('Ldiv_p('C_G(E))) -> A \subset 'C(G).
Proof.
case/pElemP=> sEG abelE pG nGA coGA oddG cCEA.
have [-> | ntG] := eqsVneq G 1; first by rewrite cents1.
have [p_pr _ _] := pgroup_pdiv pG ntG.
have{cCEA} cCEA: A \subset 'C('Ohm_1('C_G(E))).
  by rewrite (OhmE 1 (pgroupS _ pG)) ?subsetIl ?cent_gen.
apply: coprime_nil_faithful_cent_stab (pgroup_nil pG) _ => //.
rewrite subsetI subsetIl centsC /=; set CC := 'C_G(_).
have sCCG: CC \subset G := subsetIl _ _; have pCC := pgroupS sCCG pG.
rewrite (coprime_odd_faithful_Ohm1 pCC) ?(coprimeSg sCCG) ?(oddSg sCCG) //.
  by rewrite !(normsI, norms_cent, normG).
rewrite (subset_trans cCEA) // centS // OhmS // setIS // centS //.
rewrite subsetI sEG /= centsC (subset_trans cCEA) // centS //.
have cEE: abelian E := abelem_abelian abelE.
by rewrite -{1}(Ohm1_id abelE) OhmS // subsetI sEG.
Qed.

Theorem critical_odd  gT p (G : {group gT}) :
    p.-group G -> odd #|G| -> G :!=: 1 ->
  {H : {group gT} |
     [/\ H \char G, [~: H, G] \subset 'Z(H), nil_class H <= 2, exponent H = p
       & p.-group 'C(H | [Aut G])]}.
Proof.
move=> pG oddG ntG; have [H krH]:= Thompson_critical pG.
have [chH sPhiZ sGH_Z scH] := krH; have clH := critical_class2 krH.
have sHG := char_sub chH; set D := 'Ohm_1(H)%G; exists D.
have chD: D \char G := char_trans (Ohm_char 1 H) chH.
have sDH: D \subset H := Ohm_sub 1 H.
have sDG_Z: [~: D, G] \subset 'Z(D).
  rewrite subsetI commg_subl char_norm // commGC.
  apply: subset_trans (subset_trans sGH_Z _); first by rewrite commgS.
  by rewrite subIset // orbC centS.
rewrite nil_class2 !(subset_trans (commgS D _) sDG_Z) ?(char_sub chD) {sDH}//.
have [p_pr p_dv_G _] := pgroup_pdiv pG ntG; have odd_p := dvdn_odd p_dv_G oddG.
split=> {chD sDG_Z}//.
  apply/prime_nt_dvdP=> //; last by rewrite exponent_Ohm1_class2 ?(pgroupS sHG).
  rewrite -dvdn1 -trivg_exponent /= Ohm1_eq1; apply: contraNneq ntG => H1.
  by rewrite -(setIidPl (cents1 G)) -{1}H1 scH H1 center1.
apply/pgroupP=> q q_pr /Cauchy[] //= f.
rewrite astab_ract => /setIdP[Af cDf] ofq; apply: wlog_neg => p'q.
suffices: f \in 'C(H | [Aut G]).
  move/(mem_p_elt (critical_p_stab_Aut krH pG))/pnatP=> -> //.
  by rewrite ofq.
rewrite astab_ract inE Af; apply/astabP=> x Hx; rewrite /= /aperm /=.
rewrite nil_class2 in clH; have pH := pgroupS sHG pG.
have /p_natP[i ox]: p.-elt x by apply: mem_p_elt Hx.
have{ox}: x ^+ (p ^ i) = 1 by rewrite -ox expg_order.
elim: i x Hx => [|[|i] IHi] x Hx xp1.
- by rewrite [x]xp1 -(autmE Af) morph1.
- by apply: (astabP cDf); rewrite (OhmE 1 pH) mem_gen // !inE Hx xp1 eqxx.
have expH': {in H &, forall y z, [~ y, z] ^+ p = 1}.
  move=> y z Hy Hz; apply/eqP.
  have /setIP[_ cHyz]: [~ y, z] \in 'Z(H) by rewrite (subsetP clH) // mem_commg.
  rewrite -commXg; last exact/commute_sym/(centP cHyz).
  suffices /setIP[_ cHyp]: y ^+ p \in 'Z(H) by apply/commgP/(centP cHyp).
  rewrite (subsetP sPhiZ) // (Phi_joing pH) mem_gen // inE orbC.
  by rewrite (Mho_p_elt 1) ?(mem_p_elt pH).
have Hfx: f x \in H.
  case/charP: chH => _ /(_ _ (injm_autm Af) (im_autm Af)) <-.
  by rewrite -{1}(autmE Af) mem_morphim // (subsetP sHG).
set y := x^-1 * f x; set z := [~ f x, x^-1].
have Hy: y \in H by rewrite groupM ?groupV.
have /centerP[_ Zz]: z \in 'Z(H) by rewrite (subsetP clH) // mem_commg ?groupV.
have fy: f y = y.
  apply: (IHi); first by rewrite groupM ?groupV.
  rewrite expMg_Rmul; try by apply: commute_sym; apply: Zz; rewrite ?groupV.
  rewrite -/z bin2odd ?odd_exp // {3}expnS -mulnA expgM expH' ?groupV //.
  rewrite expg1n mulg1 expgVn -(autmE Af) -morphX ?(subsetP sHG) //= autmE.
  rewrite IHi ?mulVg ?groupX // {2}expnS expgM -(expgM x _ p) -expnSr.
  by rewrite xp1 expg1n.
have /eqP: (f ^+ q) x = x * y ^+ q.
  elim: (q) => [|j IHj]; first by rewrite perm1 mulg1.
  rewrite expgSr permM {}IHj -(autmE Af).
  rewrite morphM ?morphX ?groupX ?(subsetP sHG) //= autmE.
  by rewrite fy expgS mulgA mulKVg.
rewrite -{1}ofq expg_order perm1 eq_mulVg1 mulKg -order_dvdn.
case: (primeP q_pr) => _ dv_q /dv_q; rewrite order_eq1 -eq_mulVg1.
case/pred2P=> // oyq; case/negP: p'q.
by apply: (pgroupP pH); rewrite // -oyq order_dvdG.
Qed.

Section CoprimeQuotientPgroup.

Variables (gT : finGroupType) (p : nat) (T M G : {group gT}).
Hypothesis pT : p.-group T.
Hypotheses (nMT : T \subset 'N(M)) (coMT : coprime #|M| #|T|).

Lemma coprime_norm_quotient_pgroup : 'N(T / M) = 'N(T) / M.
Proof.
have [-> | ntT] := eqsVneq T 1; first by rewrite quotient1 !norm1 quotientT.
have [p_pr _ [m oMpm]] := pgroup_pdiv pT ntT.
apply/eqP; rewrite eqEsubset morphim_norms // andbT; apply/subsetP=> Mx.
case: (cosetP Mx) => x Nx ->{Mx} nTqMx.
have sylT: p.-Sylow(M <*> T) T.
  rewrite /pHall pT -divgS joing_subr //= norm_joinEr ?coprime_cardMg //.
  rewrite mulnK // ?p'natE -?prime_coprime // coprime_sym.
  by rewrite -(@coprime_pexpr m.+1) -?oMpm.
have sylTx: p.-Sylow(M <*> T) (T :^ x).
  have nMTx: x \in 'N(M <*> T).
    rewrite norm_joinEr // inE -quotientSK ?conj_subG ?mul_subG ?normG //.
    by rewrite quotientJ // quotientMidl (normP nTqMx).
  by rewrite pHallE /= -{1}(normP nMTx) conjSg cardJg -pHallE.
have{sylT sylTx} [ay] := Sylow_trans sylT sylTx.
rewrite /= joingC norm_joinEl //; case/imset2P=> a y Ta.
rewrite -groupV => My ->{ay} defTx; rewrite -(coset_kerr x My).
rewrite mem_morphim //; first by rewrite groupM // (subsetP (normG M)).
by rewrite inE !(conjsgM, defTx) conjsgK conjGid.
Qed.

Lemma coprime_cent_quotient_pgroup : 'C(T / M) = 'C(T) / M.
Proof.
symmetry; rewrite -quotientInorm -quotientMidl -['C(T / M)]cosetpreK.
congr (_ / M); set Cq := _ @*^-1 _; set C := 'N_('C(T))(M).
suffices <-: 'N_Cq(T) = C.
  rewrite setIC group_modl ?sub_cosetpre //= -/Cq; apply/setIidPr.
  rewrite -quotientSK ?subsetIl // cosetpreK.
  by rewrite -coprime_norm_quotient_pgroup cent_sub.
apply/eqP; rewrite eqEsubset subsetI -sub_quotient_pre ?subsetIr //.
rewrite quotientInorm quotient_cents //= andbC subIset ?cent_sub //=.
have nMC': 'N_Cq(T) \subset 'N(M) by rewrite subIset ?subsetIl.
rewrite subsetI nMC' andbT (sameP commG1P trivgP) /=.
rewrite -(coprime_TIg coMT) subsetI commg_subr subsetIr andbT.
by rewrite -quotient_cents2 ?sub_quotient_pre ?subsetIl.
Qed.

Hypothesis sMG : M \subset G.

Lemma coprime_subnorm_quotient_pgroup : 'N_(G / M)(T / M) = 'N_G(T) / M.
Proof. by rewrite quotientGI -?coprime_norm_quotient_pgroup. Qed.

Lemma coprime_subcent_quotient_pgroup : 'C_(G / M)(T / M) = 'C_G(T) / M.
Proof. by rewrite quotientGI -?coprime_cent_quotient_pgroup. Qed.

End CoprimeQuotientPgroup.

Section Constrained.

Variables (gT : finGroupType) (p : nat) (G : {group gT}).

Proposition solvable_p_constrained : solvable G -> p.-constrained G.
Proof.
move=> solG P sylP; have [sPO pP _] := and3P sylP; pose K := 'O_p^'(G).
have nKG: G \subset 'N(K) by rewrite normal_norm ?pcore_normal.
have nKC: 'C_G(P) \subset 'N(K) by rewrite subIset ?nKG.
rewrite -(quotientSGK nKC) //; last first.
  by rewrite /= -pseries1 (pseries_sub_catl [::_]).
apply: subset_trans (quotient_subcent _ _ _) _; rewrite /= -/K.
suffices ->: P / K = 'O_p(G / K).
  rewrite quotient_pseries2 -Fitting_eq_pcore ?trivg_pcore_quotient // -/K.
  by rewrite cent_sub_Fitting ?morphim_sol.
apply/eqP; rewrite eqEcard -(part_pnat_id (pcore_pgroup _ _)).
have sylPK: p.-Sylow('O_p(G / K)) (P / K).
  rewrite -quotient_pseries2 morphim_pHall //.
  exact: subset_trans (subset_trans sPO (pseries_sub _ _)) nKG.
by rewrite -(card_Hall sylPK) leqnn -quotient_pseries2 quotientS.
Qed.

Proposition p_stable_abelian_constrained :
  p.-constrained G -> p.-stable G -> p.-abelian_constrained G.
Proof.
move=> constrG stabG P A sylP cAA /andP[sAP nAP].
have [sPG pP _] := and3P sylP; have sAG := subset_trans sAP sPG.
set K2 := 'O_{p^', p}(G); pose K1 := 'O_p^'(G); pose Q := P :&: K2.
have sQG: Q \subset G by rewrite subIset ?sPG.
have nK1G: G \subset 'N(K1) by rewrite normal_norm ?pcore_normal.
have nsK2G: K2 <| G := pseries_normal _ _; have [sK2G nK2G] := andP nsK2G.
have sylQ: p.-Sylow(K2) Q by rewrite /Q setIC (Sylow_setI_normal nsK2G).
have defK2: K1 * Q = K2.
  have sK12: K1 \subset K2 by rewrite /K1 -pseries1 (pseries_sub_catl [::_]).
  apply/eqP; rewrite eqEsubset mulG_subG /= sK12 subsetIr /=.
  rewrite -quotientSK ?(subset_trans sK2G) //= quotientIG //= -/K1 -/K2.
  rewrite subsetI subxx andbT quotient_pseries2.
  by rewrite pcore_sub_Hall // morphim_pHall // ?(subset_trans sPG).
have{cAA} rQAA_1: [~: Q, A, A] = 1.
  by apply/commG1P; apply: subset_trans cAA; rewrite commg_subr subIset // nAP.
have nK2A := subset_trans sAG nK2G.
have sAN: A \subset 'N_G(Q) by rewrite subsetI sAG normsI // normsG.
have{stabG rQAA_1 defK2 sQG} stabA: A / 'C_G(Q) \subset 'O_p('N_G(Q) / 'C_G(Q)).
  apply: stabG; rewrite //= /psubgroup -/Q ?sAN ?(pgroupS _ pP) ?subsetIl //.
  by rewrite defK2 pseries_normal.
rewrite -quotient_sub1 //= -/K2 -(setIidPr sAN).
have nK2N: 'N_G(Q) \subset 'N(K2) by rewrite subIset ?nK2G.
rewrite -[_ / _](morphim_restrm nK2N); set qK2 := restrm _ _.
have{constrG} fqKp: 'ker (coset 'C_G(Q)) \subset 'ker qK2.
  by rewrite ker_restrm !ker_coset subsetI subcent_sub constrG.
rewrite -(morphim_factm fqKp (subcent_norm _ _)) -(quotientE A _).
apply: subset_trans {stabA}(morphimS _ stabA) _.
apply: subset_trans (morphim_pcore _ _ _) _.
rewrite morphim_factm morphim_restrm setIid -quotientE.
rewrite /= -quotientMidl /= -/K2 (Frattini_arg _ sylQ) ?pseries_normal //.
by rewrite -quotient_pseries //= (pseries_rcons_id [::_]) trivg_quotient.
Qed.

End Constrained.

Proposition p'core_cent_pgroup gT p (G R : {group gT}) :
  p.-subgroup(G) R -> solvable G -> 'O_p^'('C_G(R)) \subset 'O_p^'(G).
Proof.
case/andP=> sRG pR solG.
without loss p'G1: gT G R sRG pR solG / 'O_p^'(G) = 1.
  have nOG_CR: 'C_G(R) \subset 'N('O_p^'(G)) by rewrite subIset ?gFnorm.
  move=> IH; rewrite -quotient_sub1 ?gFsub_trans //.
  apply: subset_trans (morphimF _ _ nOG_CR) _; rewrite /= -quotientE.
  rewrite -(coprime_subcent_quotient_pgroup pR) ?pcore_sub //; first 1 last.
  - by rewrite (subset_trans sRG) ?gFnorm.
  - by rewrite coprime_sym (pnat_coprime _ (pcore_pgroup _ _)).
  have p'Gq1 : 'O_p^'(G / 'O_p^'(G)) = 1 := trivg_pcore_quotient p^' G.
  by rewrite -p'Gq1 IH ?morphimS ?morphim_pgroup ?morphim_sol.
set M := 'O_p^'('C_G(R)); pose T := 'O_p(G).
have /subsetIP[sMG cMR]: M \subset 'C_G(R) by apply: pcore_sub.
have [p'M pT]: p^'.-group M /\ p.-group T by rewrite !pcore_pgroup.
have nRT: R \subset 'N(T) by rewrite (subset_trans sRG) ?gFnorm.
have pRT: p.-group (R <*> T).
  rewrite -(pquotient_pgroup pT) ?join_subG ?nRT ?normG //=.
  by rewrite norm_joinEl // quotientMidr morphim_pgroup.
have nRT_M: M \subset 'N(R <*> T).
  by rewrite normsY ?(cents_norm cMR) // (subset_trans sMG) ?gFnorm.
have coRT_M: coprime #|R <*> T| #|M| := pnat_coprime pRT p'M.
have cMcR: 'C_(R <*> T)(R) \subset 'C(M).
  apply/commG1P; apply/trivgP; rewrite -(coprime_TIg coRT_M) subsetI commg_subr.
  rewrite (subset_trans (commSg _ (subsetIl _ _))) ?commg_subl //= -/M.
  by apply: subset_trans (gFnorm _ _); rewrite setSI // join_subG sRG pcore_sub.
have cRT_M: M \subset 'C(R <*> T).
  rewrite coprime_nil_faithful_cent_stab ?(pgroup_nil pRT) //= -/M.
  rewrite subsetI subsetIl (subset_trans _ cMcR) // ?setIS ?centS //.
  by rewrite subsetI joing_subl centsC.
have sMT: M \subset T.
  have defT: 'F(G) = T := Fitting_eq_pcore p'G1.
  rewrite -defT (subset_trans _ (cent_sub_Fitting solG)) // defT subsetI sMG.
  by rewrite (subset_trans cRT_M) // centY subsetIr.
by rewrite -(setIidPr sMT) p'G1 coprime_TIg // (pnat_coprime pT).
Qed.

Proposition coprime_abelian_gen_cent gT (A G : {group gT}) :
   abelian A -> A \subset 'N(G) -> coprime #|G| #|A| ->
  <<\bigcup_(B : {group gT} | cyclic (A / B) && (B <| A)) 'C_G(B)>> = G.
Proof.
move=> abelA nGA coGA; symmetry; move: {2}_.+1 (ltnSn #|G|) => n.
elim: n gT => // n IHn gT in A G abelA nGA coGA *; rewrite ltnS => leGn.
without loss nilG: G nGA coGA leGn / nilpotent G.
  move=> {IHn} IHn; apply/eqP; rewrite eqEsubset gen_subG.
  apply/andP; split; last by apply/bigcupsP=> B _; apply: subsetIl.
  pose T := [set P : {group gT} | Sylow G P & A \subset 'N(P)].
  rewrite -{1}(@Sylow_transversal_gen _ T G) => [|P | p _]; first 1 last.
  - by rewrite inE -!andbA; case/and4P.
  - have [//|P sylP nPA] := sol_coprime_Sylow_exists p (abelian_sol abelA) nGA.
    by exists P; rewrite ?inE ?(p_Sylow sylP).
  rewrite gen_subG; apply/bigcupsP=> P {T}/setIdP[/SylowP[p _ sylP] nPA].
  have [sPG pP _] := and3P sylP.
  rewrite (IHn P) ?(pgroup_nil pP) ?(coprimeSg sPG) ?genS //.
    by apply/bigcupsP=> B cycBq; rewrite (bigcup_max B) ?setSI.
  by rewrite (leq_trans (subset_leq_card sPG)).
apply/eqP; rewrite eqEsubset gen_subG.
apply/andP; split; last by apply/bigcupsP=> B _; apply: subsetIl.
have [Z1 | ntZ] := eqsVneq 'Z(G) 1.
  by rewrite (TI_center_nil _ (normal_refl G)) ?Z1 ?(setIidPr _) ?sub1G.
have{ntZ} [M /= minM] := minnormal_exists ntZ (gFnorm_trans _ nGA).
rewrite subsetI centsC => /andP[sMG /cents_norm nMG].
have coMA := coprimeSg sMG coGA; have{nilG} solG := nilpotent_sol nilG.
have [nMA ntM abelM] := minnormal_solvable minM sMG solG.
set GC := <<_>>; have sMGC: M \subset GC.
  rewrite sub_gen ?(bigcup_max 'C_A(M)%G) //=; last first.
    by rewrite subsetI sMG centsC subsetIr.
  case/is_abelemP: abelM => p _ abelM; rewrite -(rker_abelem abelM ntM nMA).
  rewrite rker_normal -(setIidPl (quotient_abelian _ _)) ?center_kquo_cyclic //.
  exact/abelem_mx_irrP.
rewrite -(quotientSGK nMG sMGC).
have: A / M \subset 'N(G / M) by rewrite morphim_norms.
move/IHn->; rewrite ?morphim_abelian ?coprime_morph {IHn}//; first 1 last.
  by rewrite (leq_trans _ leGn) ?ltn_quotient.
rewrite gen_subG; apply/bigcupsP=> Bq; rewrite andbC => /andP[].
have: M :&: A = 1 by rewrite coprime_TIg.
move/(quotient_isom nMA); case/isomP=> /=; set qM := restrm _ _ => injqM <-.
move=> nsBqA; have sBqA := normal_sub nsBqA.
rewrite -(morphpreK sBqA) /= -/qM; set B := qM @*^-1 Bq.
move: nsBqA; rewrite -(morphpre_normal sBqA) ?injmK //= -/B => nsBA.
rewrite -(morphim_quotm _ nsBA) /= -/B injm_cyclic ?injm_quotm //= => cycBA.
rewrite morphim_restrm -quotientE morphpreIdom -/B; have sBA := normal_sub nsBA.
rewrite -coprime_quotient_cent ?(coprimegS sBA, subset_trans sBA) //= -/B.
by rewrite quotientS ?sub_gen // (bigcup_max [group of B]) ?cycBA.
Qed.

Proposition coprime_abelian_gen_cent1 gT (A G : {group gT}) :
   abelian A -> ~~ cyclic A -> A \subset 'N(G) -> coprime #|G| #|A| ->
  <<\bigcup_(a in A^#) 'C_G[a]>> = G.
Proof.
move=> abelA ncycA nGA coGA.
apply/eqP; rewrite eq_sym eqEsubset /= gen_subG.
apply/andP; split; last by apply/bigcupsP=> B _; apply: subsetIl.
rewrite -{1}(coprime_abelian_gen_cent abelA nGA) ?genS //.
apply/bigcupsP=> B; have [-> | /trivgPn[a Ba n1a]] := eqsVneq B 1.
  by rewrite injm_cyclic ?coset1_injm ?norms1 ?(negbTE ncycA).
case/and3P=> _ sBA _; rewrite (bigcup_max a) ?inE ?n1a ?(subsetP sBA) //.
by rewrite setIS // -cent_set1 centS // sub1set.
Qed.

Section Focal_Subgroup.

Variables (gT : finGroupType) (G S : {group gT}) (p : nat).
Hypothesis sylS : p.-Sylow(G) S.

Import finalg FiniteModule GRing.Theory.

Theorem focal_subgroup_gen :
  S :&: G^`(1) = <<[set [~ x, u] | x in S, u in G & x ^ u \in S]>>.
Proof.
set K := <<_>>; set G' := G^`(1); have [sSG coSiSG] := andP (pHall_Hall sylS).
apply/eqP; rewrite eqEsubset gen_subG andbC; apply/andP; split.
  apply/subsetP=> _ /imset2P[x u Sx /setIdP[Gu Sxu] ->].
  by rewrite inE groupM ?groupV // mem_commg // (subsetP sSG).
apply/subsetP=> g /setIP[Sg G'g]; have Gg := subsetP sSG g Sg.
have nKS: S \subset 'N(K).
  rewrite norms_gen //; apply/subsetP=> y Sy; rewrite inE.
  apply/subsetP=> _ /imsetP[_ /imset2P[x u Sx /setIdP[Gu Sxu] ->] ->].
  have Gy: y \in G := subsetP sSG y Sy.
  by rewrite conjRg mem_imset2 ?groupJ // inE -conjJg /= 2?groupJ.
set alpha := restrm_morphism nKS (coset_morphism K).
have alphim: (alpha @* S) = (S / K) by rewrite morphim_restrm setIid.
have abelSK : abelian (alpha @* S).
  rewrite alphim sub_der1_abelian // genS //.
  apply/subsetP=> _ /imset2P[x y Sx Sy ->].
  by rewrite mem_imset2 // inE (subsetP sSG) ?groupJ.
set ker_trans := 'ker (transfer G abelSK).
have G'ker : G' \subset ker_trans.
  rewrite gen_subG; apply/subsetP=> h; case/imset2P=> h1 h2 Gh1 Gh2 ->{h}.
  by rewrite !inE groupR // morphR //; apply/commgP; apply: addrC.
have transg0: transfer G abelSK g = 0%R.
  by move/kerP: (subsetP G'ker g G'g); apply.
have partX := rcosets_cycle_partition sSG Gg.
have trX := transversalP partX; set X := transversal _ _ in trX.
have /and3P[_ sXG _] := trX.
have gGSeq0: (fmod abelSK (alpha g) *+ #|G : S| = 0)%R.
  rewrite -transg0 (transfer_cycle_expansion sSG abelSK Gg trX).
  rewrite -(sum_index_rcosets_cycle sSG Gg trX) -sumrMnr /restrm.
  apply: eq_bigr=> x Xx; rewrite -[(_ *+ _)%R]morphX ?mem_morphim //=.
  rewrite -morphX //= /restrm; congr fmod.
  apply/rcoset_kercosetP; rewrite /= -/K.
  - by rewrite (subsetP nKS) ?groupX.
  - rewrite (subsetP nKS) // conjgE invgK mulgA -mem_rcoset.
    exact: mulg_exp_card_rcosets.
  rewrite mem_rcoset -{1}[g ^+ _]invgK -conjVg -commgEl mem_gen ?mem_imset2 //.
    by rewrite groupV groupX.
  rewrite inE conjVg !groupV (subsetP sXG) //= conjgE invgK mulgA -mem_rcoset.
  exact: mulg_exp_card_rcosets.
move: (congr_fmod gGSeq0).
rewrite fmval0 morphX ?inE //= fmodK ?mem_morphim // /restrm /=.
move/((congr1 (expgn^~ (expg_invn (S / K) #|G : S|))) _).
rewrite expg1n expgK ?mem_quotient ?coprime_morphl // => Kg1.
by rewrite coset_idr ?(subsetP nKS).
Qed.

Theorem Burnside_normal_complement :
  'N_G(S) \subset 'C(S) -> 'O_p^'(G) ><| S = G.
Proof.
move=> cSN; set K := 'O_p^'(G); have [sSG pS _] := and3P sylS.
have /andP[sKG nKG]: K <| G by apply: pcore_normal.
have{nKG} nKS := subset_trans sSG nKG.
have p'K: p^'.-group K by apply: pcore_pgroup.
have{pS p'K} tiKS: K :&: S = 1 by rewrite setIC coprime_TIg ?(pnat_coprime pS).
suffices{tiKS nKS} hallK: p^'.-Hall(G) K.
  rewrite sdprodE //= -/K; apply/eqP; rewrite eqEcard ?mul_subG //=.
  by rewrite TI_cardMg //= (card_Hall sylS) (card_Hall hallK) mulnC partnC.
pose G' := G^`(1); have nsG'G : G' <| G by rewrite der_normalS.
suffices{K sKG} p'G': p^'.-group G'.
  have nsG'K: G' <| K by rewrite (normalS _ sKG) ?pcore_max.
  rewrite -(pquotient_pHall p'G') -?pquotient_pcore //= -/G'.
  by rewrite nilpotent_pcore_Hall ?abelian_nil ?der_abelian.
suffices{nsG'G} tiSG': S :&: G' = 1.
  have sylG'S : p.-Sylow(G') (G' :&: S) by rewrite (Sylow_setI_normal _ sylS).
  rewrite /pgroup -[#|_|](partnC p) ?cardG_gt0 // -{sylG'S}(card_Hall sylG'S).
  by rewrite /= setIC tiSG' cards1 mul1n part_pnat.
apply/trivgP; rewrite /= focal_subgroup_gen ?(p_Sylow sylS) // gen_subG.
apply/subsetP=> _ /imset2P[x u Sx /setIdP[Gu Sxu] ->].
have cSS y: y \in S -> S \subset 'C_G[y].
  rewrite subsetI sSG -cent_set1 centsC sub1set; apply: subsetP.
  by apply: subset_trans cSN; rewrite subsetI sSG normG.
have{cSS} [v]: exists2 v, v \in 'C_G[x ^ u | 'J] & S :=: (S :^ u) :^ v.
  have sylSu : p.-Sylow(G) (S :^ u) by rewrite pHallJ.
  have [sSC sCG] := (cSS _ Sxu, subsetIl G 'C[x ^ u]).
  rewrite astab1J; apply: (@Sylow_trans p); apply: pHall_subl sCG _ => //=.
  by rewrite -conjg_set1 normJ -(conjGid Gu) -conjIg conjSg cSS.
rewrite in_set1 -conjsgM => /setIP[Gv /astab1P cx_uv] nSuv.
apply/conjg_fixP; rewrite -cx_uv /= -conjgM; apply: astabP Sx.
by rewrite astabJ (subsetP cSN) // !inE -nSuv groupM /=.
Qed.

Corollary cyclic_Sylow_tiVsub_der1 :
  cyclic S -> S :&: G^`(1) = 1 \/ S \subset G^`(1).
Proof.
move=> cycS; have [sSG pS _] := and3P sylS.
have nsSN: S <| 'N_G(S) by rewrite normalSG.
have hallSN: Hall 'N_G(S) S.
  by apply: pHall_Hall (pHall_subl _ _ sylS); rewrite ?subsetIl ?normal_sub.
have /splitsP[K /complP[tiSK /= defN]] := SchurZassenhaus_split hallSN nsSN.
have sKN: K \subset 'N_G(S) by rewrite -defN mulG_subr.
have [sKG nSK] := subsetIP sKN.
have coSK: coprime #|S| #|K|.
  by case/andP: hallSN => sSN; rewrite -divgS //= -defN TI_cardMg ?mulKn.
have:= coprime_abelian_cent_dprod nSK coSK (cyclic_abelian cycS).
case/(cyclic_pgroup_dprod_trivg pS cycS) => [[_ cSK]|[_ <-]]; last first.
  by right; rewrite commgSS.
have cSN: 'N_G(S) \subset 'C(S).
  by rewrite -defN mulG_subG -abelianE cyclic_abelian // centsC -cSK subsetIr.
have /sdprodP[_ /= defG _ _] := Burnside_normal_complement cSN.
set Q := 'O_p^'(G) in defG; have nQG: G \subset 'N(Q) := gFnorm _ _.
left; rewrite coprime_TIg ?(pnat_coprime pS) //.
apply: pgroupS (pcore_pgroup _ G); rewrite /= -/Q.
rewrite -quotient_sub1 ?gFsub_trans ?quotientR //= -/Q.
rewrite -defG quotientMidl (sameP trivgP commG1P) -abelianE.
by rewrite morphim_abelian ?cyclic_abelian.
Qed.

End Focal_Subgroup.

Corollary Zgroup_der1_Hall gT (G : {group gT}) :
  Zgroup G -> Hall G G^`(1).
Proof.
move=> ZgG; set G' := G^`(1).
rewrite /Hall der_sub coprime_sym coprime_pi' ?cardG_gt0 //=.
apply/pgroupP=> p p_pr pG'; have [P sylP] := Sylow_exists p G.
have cycP: cyclic P by have:= forallP ZgG P; rewrite (p_Sylow sylP).
case: (cyclic_Sylow_tiVsub_der1 sylP cycP) => [tiPG' | sPG'].
  have: p.-Sylow(G') (P :&: G').
    by rewrite setIC (Sylow_setI_normal _ sylP) ?gFnormal.
  move/card_Hall/eqP; rewrite /= tiPG' cards1 eq_sym.
  by rewrite partn_eq1 ?cardG_gt0 // p'natE ?pG'.
rewrite inE /= mem_primes p_pr indexg_gt0 -?p'natE // -partn_eq1 //.
have sylPq: p.-Sylow(G / G') (P / G') by rewrite morphim_pHall ?normsG.
rewrite -card_quotient ?gFnorm // -(card_Hall sylPq) -trivg_card1.
by rewrite /= -quotientMidr mulSGid ?trivg_quotient.
Qed.

Lemma cyclic_pdiv_normal_complement gT (S G : {group gT}) :
  (pdiv #|G|).-Sylow(G) S -> cyclic S -> exists H : {group gT}, H ><| S = G.
Proof.
set p := pdiv _ => sylS cycS; have cSS := cyclic_abelian cycS.
exists 'O_p^'(G)%G; apply: Burnside_normal_complement => //.
have [-> | ntS] := eqsVneq S 1; first apply: cents1.
have [sSG pS p'iSG] := and3P sylS; have [pr_p _ _] := pgroup_pdiv pS ntS.
rewrite -['C(S)]mulg1 -ker_conj_aut -morphimSK ?subsetIr // setIC morphimIdom.
set A_G := _ @* _; pose A := Aut S.
have [_ [_ [cAA _ oAp' _]] _] := cyclic_pgroup_Aut_structure pS cycS ntS.
have{cAA cSS p'iSG} /setIidPl <-: A_G \subset 'O_p^'(A).
  rewrite pcore_max -?sub_abelian_normal ?Aut_conj_aut //=.
  apply: pnat_dvd p'iSG; rewrite card_morphim ker_conj_aut /= setIC.
  have sSN: S \subset 'N_G(S) by rewrite subsetI sSG normG.
  by apply: dvdn_trans (indexSg sSN (subsetIl G 'N(S))); apply: indexgS.
rewrite coprime_TIg ?sub1G // coprime_morphl // coprime_sym coprime_pi' //.
apply/pgroupP=> q pr_q q_dv_G; rewrite !inE mem_primes gtnNdvd ?andbF // oAp'.
by rewrite prednK ?prime_gt0 ?pdiv_min_dvd ?prime_gt1.
Qed.

Lemma Zgroup_metacyclic gT (G : {group gT}) : Zgroup G -> metacyclic G.
Proof.
elim: {G}_.+1 {-2}G (ltnSn #|G|) => // n IHn G; rewrite ltnS => leGn ZgG.
have{n IHn leGn} solG: solvable G.
  have [-> | ntG] := eqsVneq G 1; first apply: solvable1.
  have [S sylS] := Sylow_exists (pdiv #|G|) G.
  have cycS: cyclic S := forall_inP ZgG S (p_Sylow sylS).
  have [H defG] := cyclic_pdiv_normal_complement sylS cycS.
  have [nsHG _ _ _ _] := sdprod_context defG; rewrite (series_sol nsHG) andbC.
  rewrite -(isog_sol (sdprod_isog defG)) (abelian_sol (cyclic_abelian cycS)).
  rewrite metacyclic_sol ?IHn ?(ZgroupS _ ZgG) ?normal_sub //.
  rewrite (leq_trans _ leGn) // -(sdprod_card defG) ltn_Pmulr // cardG_gt1.
  by rewrite -rank_gt0 (rank_Sylow sylS) p_rank_gt0 pi_pdiv cardG_gt1.
pose K := 'F(G)%G; apply/metacyclicP; exists K.
have nsKG: K <| G := Fitting_normal G; have [sKG nKG] := andP nsKG.
have cycK: cyclic K by rewrite nil_Zgroup_cyclic ?Fitting_nil ?(ZgroupS sKG).
have cKK: abelian K := cyclic_abelian cycK.
have{solG cKK} defK: 'C_G(K) = K.
  by apply/setP/subset_eqP; rewrite cent_sub_Fitting // subsetI sKG.
rewrite cycK nil_Zgroup_cyclic ?morphim_Zgroup ?abelian_nil //.
rewrite -defK -ker_conj_aut (isog_abelian (first_isog_loc _ _)) //.
exact: abelianS (Aut_conj_aut K G) (Aut_cyclic_abelian cycK).
Qed.

Theorem Maschke_abelem gT p (G V U : {group gT}) :
  p.-abelem V -> p^'.-group G -> U \subset V ->
    G \subset 'N(V) -> G \subset 'N(U) ->
  exists2 W : {group gT}, U \x W = V & G \subset 'N(W).
Proof.
move=> pV p'G sUV nVG nUG.
have splitU: [splits V, over U] := abelem_splits pV sUV.
case/and3P: pV => pV abV; have cUV := subset_trans sUV abV.
have sVVG := joing_subl V G.
have{nUG} nUVG: U <| V <*> G.
  by rewrite /(U <| _) join_subG (subset_trans sUV) // cents_norm // centsC.
rewrite -{nUVG}(Gaschutz_split nUVG) ?(abelianS sUV) // in splitU; last first.
  rewrite -divgS ?joing_subl //= norm_joinEr //.
  have coVG: coprime #|V| #|G| := pnat_coprime pV p'G.
  by rewrite coprime_cardMg // mulnC mulnK // (coprimeSg sUV).
case/splitsP: splitU => WG /complP[tiUWG /= defVG].
exists (WG :&: V)%G.
  rewrite dprodE; last by rewrite setIA tiUWG (setIidPl _) ?sub1G.
    by rewrite group_modl // defVG (setIidPr _).
  by rewrite subIset // orbC centsC cUV.
rewrite (subset_trans (joing_subr V _)) // -defVG mul_subG //.
   by rewrite cents_norm ?(subset_trans cUV) ?centS ?subsetIr.
rewrite normsI ?normG // (subset_trans (mulG_subr U _)) //.
by rewrite defVG join_subG normG.
Qed.

Section Plength1.

Variables (gT : finGroupType) (p : nat).
Implicit Types G H : {group gT}.

Lemma plength1_1 : p.-length_1 (1 : {set gT}).
Proof. by rewrite -[_ 1]subG1 pseries_sub. Qed.

Lemma plength1_p'group G : p^'.-group G -> p.-length_1 G.
Proof.
move=> p'G; rewrite [p.-length_1 G]eqEsubset pseries_sub /=.
by rewrite -{1}(pcore_pgroup_id p'G) -pseries1 pseries_sub_catl.
Qed.

Lemma plength1_nonprime G : ~~ prime p -> p.-length_1 G.
Proof.
move=> not_p_pr; rewrite plength1_p'group // p'groupEpi mem_primes.
by rewrite (negPf not_p_pr).
Qed.

Lemma plength1_pcore_quo_Sylow G (Gb := G / 'O_p^'(G)) :
  p.-length_1 G = p.-Sylow(Gb) 'O_p(Gb).
Proof.
rewrite /plength_1 eqEsubset pseries_sub /=.
rewrite (pseries_rcons _ [:: _; _]) -sub_quotient_pre ?gFnorm //=.
rewrite /pHall pcore_sub pcore_pgroup /= -card_quotient ?gFnorm //=.
rewrite -quotient_pseries2 /= {}/Gb -(pseries1 _ G).
rewrite (card_isog (third_isog _ _ _)) ?pseries_normal ?pseries_sub_catl //.
apply/idP/idP=> p'Gbb; last by rewrite (pcore_pgroup_id p'Gbb).
exact: pgroupS p'Gbb (pcore_pgroup _ _).
Qed.

Lemma plength1_pcore_Sylow G :
  'O_p^'(G) = 1 -> p.-length_1 G = p.-Sylow(G) 'O_p(G).
Proof.
move=> p'G1; rewrite plength1_pcore_quo_Sylow -quotient_pseries2.
by rewrite p'G1 pseries_pop2 // pquotient_pHall ?normal1 ?pgroup1.
Qed.

Lemma plength1_pseries2_quo G : p.-length_1 G = p^'.-group (G / 'O_{p^', p}(G)).
Proof.
rewrite /plength_1 eqEsubset pseries_sub lastI pseries_rcons /=.
rewrite -sub_quotient_pre ?gFnorm //.
by apply/idP/idP=> pl1G; rewrite ?pcore_pgroup_id ?(pgroupS pl1G) ?pcore_pgroup.
Qed.

Lemma plength1S G H : H \subset G -> p.-length_1 G -> p.-length_1 H.
Proof.
rewrite /plength_1 => sHG pG1; rewrite eqEsubset pseries_sub.
by apply: subset_trans (pseriesS _ sHG); rewrite (eqP pG1) (setIidPr _).
Qed.

Lemma plength1_quo G H : p.-length_1 G -> p.-length_1 (G / H).
Proof.
rewrite /plength_1 => pG1; rewrite eqEsubset pseries_sub.
by rewrite -{1}(eqP pG1) morphim_pseries.
Qed.

Lemma p'quo_plength1 G H :
  H <| G -> p^'.-group H -> p.-length_1 (G / H) = p.-length_1 G.
Proof.
rewrite /plength_1 => nHG p'H; apply/idP/idP; last exact: plength1_quo.
move=> pGH1; rewrite eqEsubset pseries_sub.
have nOG: 'O_{p^'}(G) <| G by apply: pseries_normal.
rewrite -(quotientSGK (normal_norm nOG)) ?(pseries_sub_catl [:: _]) //.
have [|f f_inj im_f] := third_isom _ nHG nOG.
  by rewrite /= pseries1 pcore_max.
rewrite (quotient_pseries_cat [:: _]) -{}im_f //= -injmF //.
rewrite {f f_inj}morphimS // pseries1 -pquotient_pcore // -pseries1 /=.
by rewrite -quotient_pseries_cat /= (eqP pGH1).
Qed.

Lemma pquo_plength1 G H :
    H <| G -> p.-group H -> 'O_p^'(G / H) = 1->
  p.-length_1 (G / H) = p.-length_1 G.
Proof.
rewrite /plength_1 => nHG pH trO; apply/idP/idP; last exact: plength1_quo.
rewrite (pseries_pop _ trO) => pGH1; rewrite eqEsubset pseries_sub /=.
rewrite pseries_pop //; last first.
  apply/eqP; rewrite -subG1; have <-: H :&: 'O_p^'(G) = 1.
    by apply: coprime_TIg; apply: pnat_coprime (pcore_pgroup _ _).
  rewrite setIC subsetI subxx -quotient_sub1.
    by rewrite -trO morphim_pcore.
  exact/gFsub_trans/normal_norm.
have nOG: 'O_{p}(G) <| G by apply: pseries_normal.
rewrite -(quotientSGK (normal_norm nOG)) ?(pseries_sub_catl [:: _]) //.
have [|f f_inj im_f] := third_isom _ nHG nOG.
  by rewrite /= pseries1 pcore_max.
rewrite (quotient_pseries [::_]) -{}im_f //= -injmF //.
rewrite {f f_inj}morphimS // pseries1 -pquotient_pcore // -(pseries1 p) /=.
by rewrite -quotient_pseries /= (eqP pGH1).
Qed.

Canonical p_elt_gen_group A : {group gT} :=
  Eval hnf in [group of p_elt_gen p A].

Lemma p_elt_gen_normal G : p_elt_gen p G <| G.
Proof.
apply/normalP; split=> [|x Gx].
  by rewrite gen_subG; apply/subsetP=> x; rewrite inE; case/andP.
rewrite -genJ; congr <<_>>; apply/setP=> y; rewrite mem_conjg !inE.
by rewrite p_eltJ -mem_conjg conjGid.
Qed.

Lemma p_elt_gen_length1 G :
  p.-length_1 G = p^'.-Hall(p_elt_gen p G) 'O_p^'(p_elt_gen p G).
Proof.
rewrite /pHall pcore_sub pcore_pgroup pnatNK /= /plength_1.
have nUG := p_elt_gen_normal G; have [sUG nnUG]:= andP nUG.
apply/idP/idP=> [p1G | pU].
  apply: (@pnat_dvd _ #|p_elt_gen p G : 'O_p^'(G)|).
    by rewrite -[#|_ : 'O_p^'(G)|]indexgI indexgS ?pcoreS.
  apply: (@pnat_dvd _ #|'O_p(G / 'O_{p^'}(G))|); last exact: pcore_pgroup.
  rewrite -card_quotient; last first.
    by rewrite (subset_trans sUG) // normal_norm ?pcore_normal.
  rewrite -quotient_pseries pseries1 cardSg ?morphimS //=.
  rewrite gen_subG; apply/subsetP=> x; rewrite inE; case/andP=> Gx p_x.
  have nOx: x \in 'N('O_{p^',p}(G)).
    by apply: subsetP Gx; rewrite normal_norm ?pseries_normal.
  rewrite coset_idr //; apply/eqP; rewrite -[coset _ x]expg1 -order_dvdn.
  rewrite [#[_]](@pnat_1 p) //; first exact: morph_p_elt.
  apply: mem_p_elt (pcore_pgroup _ (G / _)) _.
  by rewrite /= -quotient_pseries /= (eqP p1G); apply/morphimP; exists x.
have nOG: 'O_{p^', p}(G) <| G by apply: pseries_normal.
rewrite eqEsubset pseries_sub.
rewrite -(quotientSGK (normal_norm nOG)) ?(pseries_sub_catl [:: _; _]) //=.
rewrite (quotient_pseries [::_; _]) pcore_max //.
rewrite /pgroup card_quotient ?normal_norm //.
apply: pnat_dvd (indexgS G (_ : p_elt_gen p G \subset _)) _; last first.
  case p_pr: (prime p); last by rewrite p'natEpi // mem_primes p_pr.
  rewrite -card_quotient // p'natE //; apply/negP=> /Cauchy[] // Ux.
  case/morphimP=> x Nx Gx -> /= oUx_p; have:= prime_gt1 p_pr.
  rewrite -(part_pnat_id (pnat_id p_pr)) -{1}oUx_p {oUx_p} -order_constt.
  rewrite -morph_constt //= coset_id ?order1 //.
  by rewrite mem_gen // inE groupX // p_elt_constt.
have nOU: p_elt_gen p G \subset 'N('O_{p^'}(G)).
  by rewrite (subset_trans sUG) // normal_norm ?pseries_normal.
rewrite -(quotientSGK nOU) ?(pseries_sub_catl [:: _]) //=.
rewrite (quotient_pseries [::_]) pcore_max ?morphim_normal //.
rewrite /pgroup card_quotient //= pseries1; apply: pnat_dvd pU.
by apply: indexgS; rewrite pcore_max ?pcore_pgroup // gFnormal_trans.
Qed.

End Plength1.

Lemma quo2_plength1 gT p (G H K : {group gT}) :
  H <| G -> K <| G -> H :&: K = 1 ->
     p.-length_1 (G / H) && p.-length_1 (G / K) = p.-length_1 G.
Proof.
move=> nHG nKG trHK.
have [p_pr | p_nonpr] := boolP (prime p); last by rewrite !plength1_nonprime.
apply/andP/idP=> [[pH1 pK1] | pG1]; last by rewrite !plength1_quo.
pose U := p_elt_gen p G; have nU : U <| G by apply: p_elt_gen_normal.
have exB (N : {group gT}) :
   N <| G -> p.-length_1 (G / N) ->
     exists B : {group gT},
       [/\ U \subset 'N(B),
           forall x, x \in B -> #[x] = p -> x \in N
         & forall Q : {group gT}, p^'.-subgroup(U) Q -> Q \subset B].
- move=> nsNG; have [sNG nNG] := andP nsNG.
  rewrite p_elt_gen_length1 // (_ : p_elt_gen _ _ = U / N); last first.
    rewrite /quotient morphim_gen -?quotientE //; last first.
      by rewrite setIdE subIset ?nNG.
    congr <<_>>; apply/setP=> Nx; rewrite inE setIdE quotientGI // inE.
    apply: andb_id2l => /morphimP[x NNx Gx ->{Nx}] /=.
    apply/idP/idP=> [pNx | /morphimP[y NNy]]; last first.
      by rewrite inE => p_y ->; apply: morph_p_elt.
    rewrite -(constt_p_elt pNx) -morph_constt // mem_morphim ?groupX //.
    by rewrite inE p_elt_constt.
  have nNU: U \subset 'N(N) := subset_trans (normal_sub nU) nNG.
  have nN_UN: U <*> N \subset 'N(N) by rewrite gen_subG subUset normG nNU.
  case/(inv_quotientN _): (pcore_normal p^' [group of U <*> N / N]) => /= [|B].
    by rewrite /normal sub_gen ?subsetUr.
  rewrite /= quotientYidr //= /U => defB sNB; case/andP=> sB nB hallB.
  exists B; split=> [| x Ux p_x | Q /andP[sQU p'Q]].
  - by rewrite (subset_trans (sub_gen _) nB) ?subsetUl.
  - have nNx: x \in 'N(N) by rewrite (subsetP nN_UN) ?(subsetP sB).
    apply: coset_idr => //; rewrite -[coset N x](consttC p).
    rewrite !(constt1P _) ?mulg1 // ?p_eltNK.
      by rewrite morph_p_elt // /p_elt p_x pnat_id.
    have: coset N x \in B / N by apply/morphimP; exists x.
    by apply: mem_p_elt; rewrite /= -defB pcore_pgroup.
  rewrite -(quotientSGK (subset_trans sQU nNU) sNB).
  by rewrite -defB (sub_Hall_pcore hallB) ?quotientS ?quotient_pgroup.
have{pH1} [A [nAU pA p'A]] := exB H nHG pH1.
have{pK1 exB} [B [nBU pB p'B]] := exB K nKG pK1.
rewrite p_elt_gen_length1 //; apply: normal_max_pgroup_Hall (pcore_normal _ _).
apply/maxgroupP; split; first by rewrite /psubgroup pcore_sub pcore_pgroup.
move=> Q p'Q sOQ; apply/eqP; rewrite eqEsubset sOQ andbT.
apply: subset_trans (_ : U :&: (A :&: B) \subset _); last rewrite /U.
  by rewrite !subsetI p'A ?p'B //; case/andP: p'Q => ->.
apply: pcore_max; last by rewrite /normal subsetIl !normsI ?normG.
rewrite /pgroup p'natE //.
apply/negP=> /Cauchy[] // x /setIP[_ /setIP[Ax Bx]] oxp.
suff: x \in 1%G by move/set1P=> x1; rewrite -oxp x1 order1 in p_pr.
by rewrite /= -trHK inE pA ?pB.
Qed.

Lemma logn_quotient_cent_abelem gT p (A E : {group gT}) :
    A \subset 'N(E) -> p.-abelem E -> logn p #|E| <= 2 ->
  logn p #|A : 'C_A(E)| <= 1.
Proof.
move=> nEA abelE maxdimE; have [-> | ntE] := eqsVneq E 1.
  by rewrite (setIidPl (cents1 _)) indexgg logn1.
pose rP := abelem_repr abelE ntE nEA.
have [p_pr _ _] := pgroup_pdiv (abelem_pgroup abelE) ntE.
have ->: 'C_A(E) = 'ker (reprGLm rP) by rewrite ker_reprGLm rker_abelem.
rewrite -card_quotient ?ker_norm // (card_isog (first_isog _)).
apply: leq_trans (dvdn_leq_log _ _ (cardSg (subsetT _))) _ => //.
rewrite logn_card_GL_p ?(dim_abelemE abelE) //.
by case: logn maxdimE; do 2?case.
Qed.

End BGsection1.

Section PuigSeriesGroups.

Implicit Type gT : finGroupType.

Canonical Puig_succ_group gT (D E : {set gT}) := [group of 'L_[D](E)].

Fact Puig_at_group_set n gT D : @group_set gT 'L_{n}(D).
Proof. by case: n => [|n]; apply: groupP. Qed.

Canonical Puig_at_group n gT D := Group (@Puig_at_group_set n gT D).
Canonical Puig_inf_group gT (D : {set gT}) := [group of 'L_*(D)].
Canonical Puig_group gT (D : {set gT}) := [group of 'L(D)].

End PuigSeriesGroups.

Notation "''L_[' G ] ( L )" := (Puig_succ_group G L) : Group_scope.
Notation "''L_{' n } ( G )" := (Puig_at_group n G)
  (at level 8, format "''L_{' n } ( G )") : Group_scope.
Notation "''L_*' ( G )" := (Puig_inf_group G) : Group_scope.
Notation "''L' ( G )" := (Puig_group G) : Group_scope.

Section PuigBasics.

Variable gT : finGroupType.
Implicit Types (D E : {set gT}) (G H : {group gT}).

Lemma Puig0 D : 'L_{0}(D) = 1. Proof. by []. Qed.
Lemma PuigS n D : 'L_{n.+1}(D) = 'L_[D]('L_{n}(D)). Proof. by []. Qed.
Lemma Puig_recE n D : Puig_rec n D = 'L_{n}(D). Proof. by []. Qed.
Lemma Puig_def D : 'L(D) = 'L_[D]('L_*(D)). Proof. by []. Qed.

Local Notation "D --> E" := (generated_by (norm_abelian D) E)
  (at level 70, no associativity) : group_scope.

Lemma Puig_gen D E : E --> 'L_[D](E).
Proof. by apply/existsP; exists (subgroups D). Qed.

Lemma Puig_max G D E : D --> E -> E \subset G -> E \subset 'L_[G](D).
Proof.
case/existsP=> gE /eqP <-{E}; rewrite !gen_subG.
move/bigcupsP=> sEG; apply/bigcupsP=> A gEA; have [_ abnA]:= andP gEA.
by rewrite sub_gen // bigcup_sup // inE sEG.
Qed.

Lemma norm_abgenS D1 D2 E : D1 \subset D2 -> D2 --> E -> D1 --> E.
Proof.
move=> sD12 /exists_eqP[gE <-{E}].
apply/exists_eqP; exists [set A in gE | norm_abelian D2 A].
congr <<_>>; apply: eq_bigl => A; rewrite !inE.
apply: andb_idr => /and3P[_ nAD cAA].
by apply/andP; rewrite (subset_trans sD12).
Qed.

Lemma Puig_succ_sub G D : 'L_[G](D) \subset G.
Proof. by rewrite gen_subG; apply/bigcupsP=> A /andP[]; rewrite inE. Qed.

Lemma Puig_at_sub n G : 'L_{n}(G) \subset G.
Proof. by case: n => [|n]; rewrite ?sub1G ?Puig_succ_sub. Qed.

Lemma Puig_inf_sub G : 'L_*(G) \subset G.
Proof. exact: Puig_at_sub. Qed.

Lemma Puig_sub G : 'L(G) \subset G.
Proof. exact: Puig_at_sub. Qed.

Lemma Puig1 G : 'L_{1}(G) = G.
Proof.
apply/eqP; rewrite eqEsubset Puig_at_sub; apply/subsetP=> x Gx.
rewrite -cycle_subG sub_gen // -[<[x]>]/(gval _) bigcup_sup //=.
by rewrite inE cycle_subG Gx /= /norm_abelian cycle_abelian sub1G.
Qed.

End PuigBasics.

Fact Puig_at_cont n : GFunctor.iso_continuous (Puig_at n).
Proof.
elim: n => [|n IHn] aT rT G f injf; first by rewrite morphim1.
have IHnS := Puig_at_sub n; pose func_n := [igFun by IHnS & !IHn].
rewrite !PuigS sub_morphim_pre ?Puig_succ_sub // gen_subG; apply/bigcupsP=> A.
rewrite inE => /and3P[sAG nAL cAA]; rewrite -sub_morphim_pre ?sub_gen //.
rewrite -[f @* A]/(gval _) bigcup_sup // inE morphimS // /norm_abelian.
rewrite morphim_abelian // -['L_{n}(_)](injmF func_n injf) //=.
by rewrite morphim_norms.
Qed.

Canonical Puig_at_igFun n := [igFun by Puig_at_sub^~ n & !Puig_at_cont n].

Fact Puig_inf_cont : GFunctor.iso_continuous Puig_inf.
Proof.
by move=> aT rT G f injf; rewrite /Puig_inf card_injm // Puig_at_cont.
Qed.

Canonical Puig_inf_igFun := [igFun by Puig_inf_sub & !Puig_inf_cont].

Fact Puig_cont : GFunctor.iso_continuous Puig.
Proof. by move=> aT rT G f injf; rewrite /Puig card_injm // Puig_at_cont. Qed.

Canonical Puig_igFun := [igFun by Puig_sub & !Puig_cont].