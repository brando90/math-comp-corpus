Require Import Inverse_Image.
From mathcomp Require Import all_ssreflect all_algebra order.
From SsrMultinomials Require Import ssrcomplements freeg mpoly.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Import Monoid GRing.Theory.

Open Scope ring_scope.

Import Order.Def Order.Syntax Order.Theory.

Section Grobner.

Section Ideal.

Variable R : ringType.
Variable n : nat.

Implicit Types p q : {mpoly R[n]}.
Implicit Types m : 'X_{1..n}.

Variable L : seq {mpoly R[n]}.

Definition ideal p :=
  exists (t : (size L).-tuple _), p = \sum_(i < size L) t`_i * L`_i.

Lemma ideal0 : ideal 0.
Proof.
exists (nseq_tuple _ 0).
rewrite big1 // => i /=.
by rewrite nth_nseq if_same mul0r.
Qed.

Lemma idealZ a p : ideal p -> ideal (a *: p).
Proof.
move=> [t ->].
exists [tuple (a *: t`_i) | i < size L] => //.
rewrite scaler_sumr; apply: eq_bigr => i _ /=.
by rewrite (nth_map i) ?size_enum_ord // nth_enum_ord // mpoly_scaleAl.
Qed.

Lemma idealN p : ideal p -> ideal (-p).
Proof.
move=> [t ->].
exists [tuple - t`_i | i < size L] => //.
rewrite -sumrN; apply: eq_bigr => i _ /=.
by rewrite (nth_map i) ?size_enum_ord // nth_enum_ord // -mulNr.
Qed.

Lemma idealD p q : ideal p -> ideal q -> ideal (p + q).
Proof.
move=> [t1 ->] [t2 ->].
exists  [tuple  (t1`_i + t2`_i) | i < size L] => //.
rewrite -big_split; apply: eq_bigr => i _ /=.
by rewrite (nth_map i) ?size_enum_ord // nth_enum_ord // mulrDl.
Qed.

Lemma idealB p q : ideal p -> ideal q -> ideal (p - q).
Proof. by move=> Ip Iq; apply: idealD => //; apply: idealN. Qed.

Lemma idealM p q : ideal q -> ideal (p * q).
Proof.
move=> [t ->].
exists  [tuple  (p * t`_i) | i < size L] => //.
rewrite mulr_sumr; apply: eq_bigr => i _ /=.
by rewrite (nth_map i) ?size_enum_ord //  nth_enum_ord // mulrA.
Qed.

Lemma ideal_mem p : p \in L -> ideal p.
Proof.
move=> Ip.
have Hp : (index p L < size L)%nat by rewrite index_mem.
pose j := Ordinal Hp.
exists  [tuple if i == j then 1 else 0 | i < size L].
rewrite (bigD1 j) //= big1 /= => [|[i /= Hi] /= iDj]; last first.
  rewrite (nth_map j)  ?size_enum_ord //=.
  case: (boolP (_ == _)); last by rewrite mul0r.
  move/eqP/val_eqP; rewrite /= nth_enum_ord => //= HH.
  by case/eqP: iDj; apply/val_eqP => /=.
rewrite (nth_map j)  ?size_enum_ord //=.
case: (boolP (_ == _)); last first.
  by move/eqP/val_eqP; rewrite /= nth_enum_ord // eqxx.
by rewrite nth_index // addr0 mul1r.
Qed.

End Ideal.

Lemma ideal_consr (R : ringType) n l (p q : {mpoly R[n]}) :
   ideal l p -> ideal (q:: l) p.
Proof.
case=> t ->; exists [tuple of 0 :: t] => /=.
by rewrite big_ord_recl /= mul0r add0r.
Qed.

Lemma ideal_consl (R : ringType) n l (p q : {mpoly R[n]}) :
  ideal l p -> ideal (p :: l) q -> ideal l q.
Proof.
case=> [t1] ->; case=> /= t2 ->.
exists [tuple (t2`_0 * t1`_i + t2`_(fintype.lift ord0 i))| i < size l].
rewrite big_ord_recl [X in _ * X + _ = _]/=.
rewrite mulr_sumr -big_split.
apply: eq_bigr => i _ /=.
rewrite (nth_map i); last by rewrite size_enum_ord ltn_ord.
rewrite nth_enum_ord; last by apply: ltn_ord.
by rewrite mulrDl mulrA.
Qed.

Section Order.

Variable R : ringType.
Variable n : nat.

Implicit Types p q : {mpoly R[n]}.
Implicit Types m : 'X_{1..n}.

Definition plt p q :=
        has (fun m2 =>
              [&& m2 \notin (msupp p),
                 all (fun m1 => ((m1 < m2)%O || (m1 \in msupp q))) (msupp p) &
                 all (fun m1 => ((m1 <= m2)%O || (m1 \in msupp p))) (msupp q)])
                 (msupp q).

Local Notation "a < b" := (plt a b).

Lemma pltP p q :
   reflect (exists m,
              [/\ m \in msupp q , m \notin msupp p &
               forall m1, (m < m1)%O -> (m1 \in msupp p) = (m1 \in msupp q)])
           (p < q).
Proof.
apply: (iffP hasP)=> [[m Im /and3P[NIm /allP /=Hq /allP Hp]]|[m [Im NIm HA]]].
  exists m; split=> // m1 Lm.
  have := Hq m1; have := Hp m1; do 2 case: (_ \in _) => //=.
    by rewrite leNgt Lm => /(_ is_true_true).
  by rewrite ltNge [(m <= _)%O]ltW // => _  /(_ is_true_true).
exists m => //; apply/and3P; split=>//; apply/allP=> m1 Im1.
  have [] := boolP (_ < m)%O; rewrite // -leNgt //.
  by rewrite le_eqVlt => /orP[/eqP<-|/HA<-].
by have [] := boolP (_ <= m)%O; rewrite // -ltNge =>/HA->.
Qed.

Lemma plt_mlead p q : (mlead p < mlead q)%O -> (p < q).
Proof.
have [/eqP->|Zq] := boolP (q == 0); first by rewrite mlead0 ltx0.
move=> Lp; apply/pltP; exists (mlead q); split=> [||m1 Lm1].
- by apply: mlead_supp.
- by rewrite mcoeff_msupp negbK mcoeff_gt_mlead.
rewrite !mcoeff_msupp !mcoeff_gt_mlead //.
by apply: lt_trans Lm1.
Qed.

Lemma plt_anti p : p < p = false.
Proof. by apply/idP=> /hasP[x ->]. Qed.

Lemma plt0 p : (0 < p) = (p != 0).
Proof.
apply/pltP/idP=> [[m [Im NIm HA]]|Zp].
  by apply/eqP=> Zp; move: Im; rewrite Zp msupp0 in_nil.
exists (mlead p); rewrite msupp0 ?in_nil; split=> [||m1 HA] //=.
  by apply: mlead_supp.
by rewrite in_nil mcoeff_msupp mcoeff_gt_mlead ?eqxx.
Qed.

Lemma plt0r p : p < 0 = false.
Proof. by case: (boolP (_ < 0)) => // /hasP[m]; rewrite msupp0 // inE. Qed.

Lemma plt_trans : transitive plt.
Proof.
move=> r p q /pltP[m1 [Im1 NIm1 HAm1]] /pltP[m2 [Im2 NIm2 HAm2]].
have [Lm|Lm] := leP m1 m2.
  apply/pltP; exists m2; split=> [||m3 Lm3] //.
    by move: Lm; rewrite le_eqVlt => /orP[/eqP<-//|/HAm1->].
  by rewrite -HAm2 // HAm1 // (le_lt_trans Lm).
apply/pltP; exists m1; split=> [||m3 Lm3] //.
  by rewrite -(HAm2 _ Lm).
by rewrite HAm1 // -HAm2 // (lt_trans Lm).
Qed.

Lemma plt_lead (p q : {mpoly R[n]}) : (mlead p < mlead q)%O -> p < q.
Proof.
have [/eqP->|Zq] := boolP (q == 0); first by rewrite mlead0 ltx0.
move=> H; apply/pltP; exists (mlead q); split=> [||m1 Lm] //.
- by apply: mlead_supp.
- by rewrite mcoeff_msupp mcoeff_gt_mlead ?negbK.
by rewrite !mcoeff_msupp !mcoeff_gt_mlead // (lt_trans _ Lm).
Qed.

Lemma plt_leadE (p q : {mpoly R[n]}) : p != 0 -> (p < q) ->
   (mlead p < mlead q)%O ||
   ((mlead p == mlead q) &&
      (p - p@_(mlead q) *: 'X_[mlead q] < q - q@_(mlead q) *: 'X_[mlead q])).
Proof.
have [/eqP->|Zq] := boolP (q == 0); first by rewrite plt0r.
move=> Zp Lp.
have/pltP[m [Im NIm Lm]] := Lp; apply/orP.
have [/eqP Eq|Dq] := boolP (mlead q == m).
  left; have [/Lm HH|] := boolP (m < mlead p)%O.
    have:= mlead_supp Zp; rewrite HH =>  /msupp_le_mlead.
    rewrite le_eqVlt=> /orP[] // /eqP Ep.
    by case/negP: NIm; rewrite -Eq -Ep mlead_supp.
  rewrite -leNgt le_eqVlt Eq => /orP[/eqP Ep|] //.
  by case/negP: NIm; rewrite -Ep mlead_supp.
right; apply/andP; split; last first.
  apply/pltP; exists m; split=> [||m1 Lm1].
  - rewrite (perm_mem (msupp_rem _ _)) (rem_filter _ (msupp_uniq _)).
    by rewrite mem_filter /= eq_sym Dq /=.
  - rewrite (perm_mem (msupp_rem _ _)) (rem_filter _ (msupp_uniq _)).
    by rewrite mem_filter /= eq_sym Dq.
  rewrite !(perm_mem (msupp_rem _ _)) !(rem_filter _ (msupp_uniq _)).
  by rewrite !mem_filter /= Lm.
have: (mlead q <= mlead p)%O.
  apply: msupp_le_mlead; rewrite Lm ?mlead_supp //.
  by rewrite lt_neqAle eq_sym Dq msupp_le_mlead.
rewrite le_eqVlt => /orP[/eqP->|] // /plt_mlead /(plt_trans Lp).
by rewrite plt_anti.
Qed.

Lemma plt_mlast p q :
   (p < q) ->
  (exists p1 p2, [/\ p = p1 + p2, perm_eq (msupp p1) (rem (mlast q) (msupp q))
                     & p2 < 'X_[mlast q]])
   \/
  (p < q - q@_(mlast q) *: 'X_[mlast q]).
Proof.
have [/eqP->|Zq] := boolP (q == 0); first by rewrite plt0r.
move=> /pltP[m [Im NIm Lm]].
have [/eqP Eq|Dq] := boolP (mlast q == m); last first.
  right; apply/pltP; exists m; split=> [||m3 Im3]//.
    rewrite (perm_mem (msupp_rem _ _)) rem_filter ?msupp_uniq //.
    by rewrite mem_filter ?msupp_uniq //= eq_sym Dq.
  rewrite (perm_mem (msupp_rem _ _)) rem_filter ?msupp_uniq //.
  rewrite mem_filter ?msupp_uniq /=.
  rewrite Lm // andbC ; case: (boolP (_ \in _)) => //=.
  have: (mlast q < m3)%O.
    by apply: le_lt_trans Im3; apply: mlast_lemc.
  by rewrite lt_neqAle [_ == m3]eq_sym => /andP[->].
pose p1 :=  \sum_(i <- msupp p | (m < i)%O) p@_i *: 'X_[i].
pose p2 :=  \sum_(i <- msupp p | (i < m)%O) p@_i *: 'X_[i].
left; exists p1; exists p2; split=> //.
- rewrite [p]mpolyE (bigID (fun i => (m < i)%O)) /=; congr (_ + _).
  rewrite  big_seq_cond  [p2]big_seq_cond.
  apply: eq_bigl=> // m1.
  rewrite -leNgt le_eqVlt.
  by have [/eqP->|] := boolP (_ == _); first by rewrite (negPf NIm).
- apply: uniq_perm=> [||m1]; first by apply: msupp_uniq.
    by apply/rem_uniq/msupp_uniq.
  rewrite (rem_filter _ (msupp_uniq _)).
  rewrite mem_filter /= (perm_mem (msupp_sum _ _ _))=>
         [||m2 m3 Im2 Im3 Dm2m3 m4 /=].
  - apply/flattenP/andP=>[[m2 /mapP[m3]]|[Dm LL]].
      rewrite mem_filter => /andP[H1 H2] -> /msuppZ_le.
      rewrite mcoeff_msupp mcoeffX.
      have [/eqP<- _|] := boolP (_ == m1); last by rewrite eqxx.
      split; last by rewrite -Lm.
      have: (mlast q < m3)%O by rewrite (le_lt_trans (mlast_lemc _) H1).
      by rewrite eq_sym lt_neqAle; case/andP.
    exists [::m1]; last by rewrite inE.
    apply/mapP; exists m1.
      rewrite mem_filter ?LL.
      suff F : (m < m1)%O by rewrite F Lm.
      by have := mlast_lemc LL; rewrite le_eqVlt eq_sym (negPf Dm) Eq.
    by rewrite msuppMCX // -mcoeff_msupp Lm // lt_neqAle -Eq eq_sym Dm mlast_lemc.
  - by apply: msupp_uniq.
  rewrite !msuppMCX -?mcoeff_msupp // !inE.
  by case: (boolP (_ == m2)) => // /eqP->; rewrite (negPf Dm2m3).
apply/pltP; exists (mlast q); split=> //.
- by rewrite msuppX inE.
- apply/negP=> /msupp_sum_le /flattenP[p3 /mapP[m1]].
  rewrite mem_filter =>/andP[H1 H2] ->.
  rewrite !msuppMCX -?mcoeff_msupp // inE => /eqP Eq1.
  by case/negP: NIm; rewrite -Eq Eq1.
move=> m1 Lm1.
rewrite msuppX inE.
have: m1 \notin msupp p2.
apply/negP=> /msupp_sum_le /flatten_mapP[m2].
rewrite mem_filter=> /andP[H1 H2].
rewrite msuppMCX -?mcoeff_msupp // inE => /eqP Em1.
have : (m2 < m1)%O.
by rewrite (lt_trans H1) // -Eq.
by  rewrite Em1 ltxx.
move/negPf->.
by move: Lm1; rewrite eq_sym lt_neqAle => /andP[/negPf->].
Qed.

Lemma mlast_ind P :
  P 0 -> (forall q, P (q - q@_(mlast q) *: 'X_[mlast q]) -> P q)
  -> (forall p, P p).
Proof.
move=> HP IH p.
elim: {p}(size (msupp p)) {-2}p (eqxx (size (msupp p)))=> [p Ls| n1 IH1 p ES].
  suff /eqP->: p == 0 by [].
  by rewrite -msupp_eq0; case: msupp Ls.
apply/IH/IH1.
rewrite (perm_size (msupp_rem _ _)) size_rem ?(eqP H) //.
  by rewrite (eqP ES).
by apply/mlast_supp; rewrite -msupp_eq0; case: msupp ES.
Qed.

Lemma plt_msuppl (p q r : {mpoly R[n]}) :
   perm_eq (msupp p) (msupp q) -> (p < r) = (q < r).
Proof.
move=> HS; apply/pltP/pltP.
  case=> m [H1 H2 H3]; exists m; split => //; first by rewrite -(perm_mem HS).
  by move=> m1 Lm1; rewrite -(perm_mem HS) H3.
case=> m [H1 H2 H3]; exists m; split => //; first by rewrite (perm_mem HS).
by move=> m1 Lm1; rewrite (perm_mem HS) H3.
Qed.

Lemma plt_msuppr (p q r : {mpoly R[n]}) :
   perm_eq (msupp p) (msupp q) -> (r < p) = (r < q).
Proof.
move=> HS; apply/pltP/pltP.
  case=> m [H1 H2 H3]; exists m; split => //; first by rewrite -(perm_mem HS).
  by move=> m1 Lm1; rewrite -(perm_mem HS) H3.
case=> m [H1 H2 H3]; exists m; split => //; first by rewrite (perm_mem HS).
by move=> m1 Lm1; rewrite (perm_mem HS) H3.
Qed.

Lemma plt_wf : well_founded plt.
Proof.
move=> p; apply: Acc_intro.
move: p; apply: mlast_ind => [q|q].
  by rewrite plt0r.
move: {1}(mlast q) (eqxx (mlast q))=> a; move: a q.
apply: (well_founded_induction (@ltom_wf n))=> /= m IH q Em H q1.
move=> /plt_mlast [[/= p1 [p2 [-> H1 H2]]]|]; last by apply: H.
have HA : Acc (fun p q0 : mpoly n R => p < q0) p1.
  apply: Acc_intro=> q2 Lq2.
  have: q2 < (q - q@_(mlast q) *: 'X_[(mlast q)]).
    rewrite (plt_msuppr _ (_ : perm_eq _ (msupp p1))) //.
    by rewrite (perm_trans (msupp_rem _ _)) // perm_sym.
  by apply: H.
move: p2 H2; apply: mlast_ind => [_|q2 IH1 Lq2].
  by rewrite addr0.
have [/eqP->|Zq2] := boolP (q2 == 0).
  by rewrite addr0.
have Lp1 : forall m1, m1 \in msupp p1 -> (mlast q < m1)%O.
  move=> m1; rewrite (perm_mem H1) (rem_filter _ (msupp_uniq _)) mem_filter.
  by case/andP=> /= HH /mlast_lemc; rewrite le_eqVlt eq_sym (negPf HH).
have Lp2 : forall m1, m1 \in msupp q2 -> (m1 < mlast q)%O.
  move=> m1 Lm2.
  case/pltP : Lq2 => m2 [].
  rewrite msuppX !inE => /eqP-> Lq HH.
  have Dm1 : mlast q != m1 by apply: contra Lq => /eqP->.
  rewrite ltNge le_eqVlt negb_or Dm1.
  apply/negP=> //.
  by move=>/HH; rewrite Lm2 inE eq_sym (negPf Dm1).
have F0 : mlast q2 \in msupp q2.
   by apply: mlast_supp.
have F1 : mlast q2 \notin msupp p1.
  apply/negP=> HH;
  suff: (mlast q < mlast q)%O by rewrite ltxx.
  by apply: lt_trans (Lp1 _ _) (Lp2 _ F0).
have F2 : (mlast q2 < m)%O by rewrite (eqP Em) Lp2.
have F3 : mlast (p1 + q2) = mlast q2.
  apply: mlastE=> [|m1 /msuppD_le].
    rewrite (perm_mem (msuppD _)) ?mem_cat ?mlast_supp ?orbT //.
    move=> m1; apply/negP=> /andP[/Lp1 O1 /Lp2 O2].
    suff: (m1 < m1)%O by rewrite ltxx.
    by apply: lt_trans O1.
  rewrite mem_cat=> /orP[/Lp1 O1|/mlast_lemc//].
  by apply: ltW; apply: lt_trans O1; rewrite -(eqP Em).
have F4 : (p1 + q2)@_(mlast q2) = q2@_(mlast q2).
  have [/eqP->|Zp1] := boolP (p1 == 0); first by rewrite add0r.
  rewrite mcoeffD mcoeff_lt_mlast ?add0r //.
  by apply: lt_trans F2 _; rewrite (eqP Em) (Lp1 _ (mlast_supp _)).
apply: Acc_intro => q3.
apply: (IH _ F2)=> [|q4]; first by rewrite F3 eqxx.
rewrite F3 F4 -addrA.
suff: Acc (fun p q0 : mpoly n R => p < q0) (p1 + (q2 - q2@_(mlast q2) *: 'X_[(mlast q2)]) ).
case=> JJ; apply: JJ.
apply: IH1.
apply/pltP; exists (mlast q); split=> //=.
- by rewrite msuppX inE eqxx.
- rewrite (perm_mem (msupp_rem _ _)) mem_rem_uniq ?msupp_uniq // !inE negb_and.
  by rewrite mcoeff_msupp !negbK  mcoeff_gt_mlead ?eqxx ?orbT // Lp2 // mlead_supp.
move=> m1 Lm1.
rewrite msuppX inE (perm_mem (msupp_rem _ _)) mem_rem_uniq ?msupp_uniq // !inE.
have [/Lp2|] := boolP (m1 \in msupp q2); first by rewrite ltNge ltW.
by move: Lm1; rewrite andbF lt_neqAle eq_sym => /andP[/negPf->].
Qed.

End Order.

Section OrderIDomain.

Variable R : idomainType.
Variable n : nat.

Implicit Types p q : {mpoly R[n]}.
Implicit Types m : 'X_{1..n}.

Local Notation "p < q" := (plt p q).

Lemma plt_scalerl : forall a p q, a != 0 -> (a *: p < q) = (p < q).
Proof.
move=> a p q Za; apply/pltP/pltP=> [] [m [Im NIm H]]; exists m; split=>//.
- by rewrite -(perm_mem (msuppZ _ Za)).
- by move=> m1 /H; rewrite (perm_mem (msuppZ _ Za)).
- by rewrite (perm_mem (msuppZ _ Za)).
by move=> m1 /H; rewrite (perm_mem (msuppZ _ Za)).
Qed.

Lemma plt_scalerr : forall a p q, a != 0 -> (p < a *: q) = (p < q).
Proof.
move=> a p q Za; apply/pltP/pltP=> [] [m [Im NIm H]]; exists m; split=>//.
- by rewrite -(perm_mem (msuppZ _ Za)).
- by move=> m1 /H; rewrite (perm_mem (msuppZ _ Za)).
- by rewrite (perm_mem (msuppZ _ Za)).
by move=> m1 /H; rewrite (perm_mem (msuppZ _ Za)).
Qed.

End OrderIDomain.

Section Main.

Variable R : fieldType.
Variable n : nat.

Implicit Types p q : {mpoly R[n]}.
Implicit Types m : 'X_{1..n}.

Local Notation "p < q" := (plt p q).

Variable L : seq {mpoly R[n]}.

Definition mdiv m p q := p - (p@_m/ mleadc q) *: 'X_[m - mlead q] * q.

Lemma mdiv_not_supp m p q :
 q != 0 -> (mlead q <= m)%MM -> m \notin msupp (mdiv m p q).
Proof.
move=> Zq Lq; rewrite mcoeff_msupp negbK mcoeffB -scalerAl mcoeffZ.
by rewrite -{3}(submK Lq) [_ * q]mulrC mcoeffMX divfK ?mleadc_eq0 // subrr.
Qed.

Lemma mdiv_not_supp_id m p q : m \notin msupp p -> mdiv m p q = p.
Proof.
by rewrite /mdiv => /memN_msupp_eq0->; rewrite mul0r scale0r mul0r subr0.
Qed.

Lemma mdiv_coef_id m p q : q != 0 -> (mlead q <= m)%MM -> (mdiv m p q)@_m = 0.
Proof.
move=> Zq Lq.
rewrite /mdiv -scalerAl mcoeffB mcoeffZ.
by rewrite -{3}(submK Lq) [_ * q]mulrC mcoeffMX divfK ?mleadc_eq0 // subrr.
Qed.

Lemma mdiv_coef_more m p q m1 :
  (mlead q <= m)%MM -> (m < m1)%O -> (mdiv m p q)@_m1 = p@_m1.
Proof.
move=> Lq Lm.
rewrite /mdiv -scalerAl mcoeffB !mcoeffZ [_ * q]mulrC.
rewrite [X in _ - _ * X = _]mcoeff_gt_mlead.
  by rewrite mulr0 subr0.
have [/eqP->|ZX] := boolP ('X_[(m - mlead q)] == 0 :> {mpoly R[n]}).
  by rewrite mulr0 mlead0 (le_lt_trans (le0x _) Lm).
have [/eqP->|Zq] := boolP (q == 0).
  by rewrite mul0r mlead0 (le_lt_trans (le0x _) Lm).
by rewrite mleadM // mleadXm mpoly.addmC submK.
Qed.

Lemma mdiv_scalel a m p q : mdiv m (a *: p) q = a *: mdiv m p q.
Proof.
by rewrite /mdiv mcoeffZ -mulrA -scalerA -scalerAl -scalerBr.
Qed.

Lemma mdivX m1 m p q :  q != 0 -> (mlead q <= m)%MM ->
  mdiv (m1 + m)%MM ('X_[m1] * p) q = 'X_[m1] * mdiv m p q.
Proof.
move=> Zq Lq; rewrite /mdiv.
by rewrite [_ * p]mulrC mcoeffMX mulrBr [p * _]mulrC
           -!scalerAl !scalerAr mulrA -mpolyXD addmBA.
Qed.

Lemma mdivB m1 m2 p q1 q2 :
  mdiv m1 p q1 - mdiv m2 p q2 =
   (p@_m2/ mleadc q2) *: 'X_[m2 - mlead q2] * q2 -
   (p@_m1/ mleadc q1) *: 'X_[m1 - mlead q1] * q1.
Proof. by rewrite /mdiv addrAC opprD addrA subrr sub0r opprK. Qed.

Lemma mdiv_lead m p q :
  m \in msupp p -> (mlead q <= m)%MM -> (mlead (mdiv m p q) <= mlead p)%O.
Proof.
move=> Im Lq.
apply: le_trans (mleadB_le _ _) _.
have [/eqP->|Zlp] := boolP (p@_m / mleadc q == 0).
  by rewrite scale0r mul0r mlead0 [max _ _]joinx0 le_refl.
rewrite leEjoin joinAC joinxx joinC -leEjoin.
rewrite -scalerAl mleadZ //.
apply: le_trans (mleadM_le _ _) _.
by rewrite mleadXm submK // msupp_le_mlead.
Qed.

Definition red_key : unit.
Proof. by []. Qed.


Definition mreduce_lock p q :=
     (has (fun m =>
         has (fun r =>
                 [&&  r !=0 , (mlead r <= m)%MM & q == mdiv m p r])
              L)
      (msupp p)).

Definition mreduce := locked_with red_key mreduce_lock.

Notation "a ->_1 b " := (mreduce a b) (at level 52).

Lemma mreduceP p q :
  reflect (exists m, exists r,
            [/\ m \in msupp p, r \in L, r != 0, (mlead r <= m)%MM &
                q = mdiv m p r])
          (p ->_1 q).
Proof.
rewrite [mreduce]unlock.
apply: (iffP hasP)=> [[m Im /hasP[r Ir /and3P[Zr Lm /eqP->]]]|
                      [m [r [Im Ir Zr Lm ->]]]].
  by exists m; exists r; split.
by exists m => //; apply/hasP; exists r; rewrite // Zr Lm /=.
Qed.

Lemma mreduce_mdiv m p q :
  m \in msupp p -> q \in L -> q != 0 -> (mlead q <= m)%MM -> p ->_1 mdiv m p q.
Proof.
by move=> Im Iq Zq Lq; apply/mreduceP; exists m; exists q; rewrite // Zq Lq /=.
Qed.

Lemma mreduce_lt p q : p ->_1 q -> q < p.
Proof.
move=>/mreduceP[m [r [Im Ir Zr Lm ->]]].
apply/pltP; exists m; split=> [||m1 Lm1] //.
  by rewrite mcoeff_msupp negbK mdiv_coef_id.
by rewrite !mcoeff_msupp mdiv_coef_more.
Qed.

Lemma mreduce_lead p q : p ->_1 q -> (mlead q <= mlead p)%O.
Proof. by move=> /mreduceP[m [r [Im Ir H1 H2 ->]]]; apply:  mdiv_lead. Qed.

Lemma mreduce_neq0 p q : p ->_1 q -> p != 0.
Proof.
by rewrite  [mreduce]unlock /mreduce_lock -msupp_eq0 /=; case: (msupp p).
Qed.

Lemma mreduce_scale a p q : a != 0 -> p ->_1 q -> a *: p ->_1 a *: q.
Proof.
move=> Za /mreduceP[m [r [Im Ir Zr Lr ->]]].
apply/mreduceP; exists m; exists r; split=> //.
  by rewrite mcoeff_msupp mcoeffZ mulf_neq0 // -mcoeff_msupp.
by rewrite mdiv_scalel.
Qed.

Lemma mreduceXm m p q : p ->_1 q -> 'X_[m] * p ->_1 'X_[m] * q.
Proof.
move=> /mreduceP[m1 [r [Im1 Ir Zr Lr ->]]].
apply/mreduceP; exists (m + m1)%MM; exists r; split=> //; last by rewrite mdivX.
  by rewrite mcoeff_msupp [_ * p]mulrC mcoeffMX -mcoeff_msupp.
by rewrite (lepm_trans Lr) // lem_addl.
Qed.

Lemma mreduce_compatX a m p q : (mlead p < m)%O ->
    p ->_1 q -> (a *: 'X_[m]) + p ->_1 (a *: 'X_[m]) + q.
Proof.
move=> Lp /mreduceP[m1 [r [Im1 Ir Zr Lr ->]]].
have Dmm1 : m != m1.
  move: Im1; rewrite mcoeff_msupp; apply: contra => /eqP<-.
  by apply/eqP/mcoeff_gt_mlead.
apply/mreduceP; exists m1; exists r; split=> //.
  rewrite !mcoeff_msupp mcoeffD mcoeffZ mcoeffX (negPf Dmm1).
  by rewrite mulr0 add0r -mcoeff_msupp.
by rewrite /mdiv mcoeffD mcoeffZ mcoeffX (negPf Dmm1) mulr0 add0r !addrA.
Qed.

Lemma ideal_reduce p q : p ->_1 q -> (ideal L p <-> ideal L q).
Proof.
move=> /mreduceP[m [r [Im Ir Zr Lr ->]]].
rewrite /mdiv; split => H.
  by apply: idealB => //; apply/idealM/ideal_mem.
rewrite -[p](subrK ((p@_m / mleadc r) *: 'X_[(m - mlead r)] * r)).
by apply: idealD => //; apply/idealM/ideal_mem.
Qed.

Definition mreducef p :=
  (let L1 :=  [seq  if  (r != 0) && (mlead r <= m)%MM
                   then Some (mdiv m p r) else None | m <- msupp p, r <- L] in
  nth None L1 (find isSome L1)).

Definition irreducible_lock p := mreducef p == None.
Definition irreducible := locked_with red_key irreducible_lock.

Lemma irreducibleP p : reflect (forall q, ~ p ->_1 q) (irreducible p).
Proof.
rewrite /irreducible unlock /irreducible_lock /mreducef.
set L1 := [seq _ | _ <- _, _ <- _].
apply: (iffP idP)=> [/eqP H1 q /mreduceP[m [r [Im Ir Zr Lr Er]]]|H1].
  suff /(nth_find None) : has isSome L1  by rewrite H1.
  apply/hasP; exists (Some q) => //.
  apply/allpairsP; exists (m,r) => /=.
  by rewrite Im Ir Zr Lr Er.
have : ~~ has isSome L1.
  apply/hasPn => /= [[q|] // /allpairsP[[/= m r [Im Ir]]]].
  case: (boolP (_ == _)) => //= Zr; case: (boolP (_ <= _)%MM) => //= Lr [Er].
  by case: (H1 q); apply/mreduceP; exists m; exists r.
by rewrite has_find -leqNgt => /(nth_default None)->.
Qed.

Lemma irreducible0 : irreducible 0.
Proof. by apply/irreducibleP => m /mreduce_lt; rewrite plt0r. Qed.

Lemma mreducefE p :
   if mreducef p is Some q then p ->_1 q else irreducible p.
Proof.
rewrite /irreducible unlock /irreducible_lock /mreducef /mreduce /=.
set L1 := [seq _ | _ <- _, _ <- _].
have [H|H] := boolP (has isSome L1); last first.
  by move: (H); rewrite has_find -leqNgt=> /(nth_default None)->.
case E: nth (nth_find None H) => [a|] // _.
move: H; rewrite has_find => /(mem_nth None); rewrite E.
move/allpairsP=> [/=[m r]/= [Im Ir]].
case: (boolP (_ == _)) => //= Zr; case: (boolP (_ <= _)%MM) => //= Lr [Er].
by apply/mreduceP; exists m; exists r.
Qed.


Definition mr q p f :=
   (p == q) ||
    let g y :=
       (if y < p as b return ((b -> _) -> _)
       then fun f => f is_true_true
       else fun f => false) (f y) in
    has (fun m =>
         has (fun r =>
                 [&& r != 0, (mlead r <= m)%MM & g (mdiv m p r)])
              L)
      (msupp p).

Lemma mr_ext p q f g : (forall r (H : r < p), f r H = g r H) -> mr q f = mr q g.
Proof.
rewrite /mr => HH; case: (_ == _) => //=.
elim: L => //= a l IH.
apply: eq_in_has => /= m Om; congr ([&& _, _ & _] || _).
  by set a1 := mdiv _ _ _; case: (_ < _) (f a1) (g a1) (HH a1).
apply: eq_in_has => // r Hr; congr [&& _, _ & _].
by set a1 := mdiv _ _ _; case: (_ < _) (f a1) (g a1) (HH a1).
Qed.

Definition mreduceplus p q := Fix (@plt_wf R n) _ (mr q) p.

Notation " a ->_+ b " := (mreduceplus a b) (at level 52).

Lemma mreduceplusP p q :
  reflect (p = q \/ exists2 r, p ->_1 r & r ->_+ q) (p ->_+ q).
Proof.
rewrite {2}/mreduceplus Fix_eq //; last by move=> *; apply: mr_ext.
rewrite {1}/mr.
have [/eqP E1|E1] := boolP (_ == _).
  by apply: (iffP idP) => //=; left.
apply: (iffP hasP) => [/= [m Im]|].
  move=> /hasP[/= r Ir /and3P[Zr Lr]].
  rewrite mreduce_lt => [HH|].
    by right; exists (mdiv m p r) => //; apply/mreduceP; exists m; exists r.
  by apply/mreduceP; exists m; exists r.
case => [/eqP| [r /mreduceP[m [r1 [Im Ir1 Zr1 Lr1 ->]]] HH]].
  by rewrite (negPf E1).
exists m => //; apply/hasP; exists r1 => //=.
rewrite Zr1 Lr1 mreduce_lt //.
by apply/mreduceP; exists m; exists r1.
Qed.

Lemma mreduceplus_ref : reflexive mreduceplus.
Proof. by move=> p; apply/mreduceplusP; left. Qed.

Lemma mreduceplusW p q : p ->_1 q -> p ->_+ q.
Proof.
move=> H; apply/mreduceplusP; right; exists q => //.
by apply: mreduceplus_ref.
Qed.

Lemma mreduceplus_trans : transitive mreduceplus.
Proof.
move=> q p r H1 H2.
move: p H1; apply: (well_founded_induction (@plt_wf R n)) =>
                p IH /mreduceplusP[->//|[r1 H1r1 H2r1]].
apply/mreduceplusP; right; exists r1 => //.
apply: IH => //.
by apply: mreduce_lt.
Qed.

Lemma mreduceplus_scale a p q :  p ->_+ q -> a *: p ->_+ a *: q.
Proof.
have [/eqP->_|Za] := boolP (a == 0).
  by rewrite !scale0r mreduceplus_ref.
move: p q; apply: (well_founded_induction (@plt_wf R n))
                => p IH q /mreduceplusP[<-|[r1]].
  by apply: mreduceplus_ref.
move=> Ra /IH R1a; apply/mreduceplusP; right; exists (a *: r1).
  by apply: mreduce_scale.
by apply: R1a;  apply: mreduce_lt.
Qed.

Lemma mreduceplusXm m p q :  p ->_+ q -> 'X_[m] * p ->_+ 'X_[m] * q.
Proof.
move: p q; apply: (well_founded_induction (@plt_wf R n))
                 => p IH q /mreduceplusP[<-|[r1]].
  by apply: mreduceplus_ref.
move=> Ra /IH R1a; apply/mreduceplusP; right; exists ('X_[m] * r1) => //.
  by apply: mreduceXm.
apply: R1a.
by apply: mreduce_lt.
Qed.

Lemma mreduceplus_compatX a m p q : (mlead p < m)%O ->
    p ->_+ q -> (a *: 'X_[m]) + p ->_+ (a *: 'X_[m]) + q.
Proof.
move: p q; apply: (well_founded_induction (@plt_wf R n)) => p IH q Lm.
case/mreduceplusP=> [<-|[r Rp Rr]].
  by apply:mreduceplus_ref.
apply: mreduceplus_trans (IH r _ _ _ _) => //.
- by apply: mreduceplusW; apply: mreduce_compatX.
- by apply: mreduce_lt.
rewrite ltNge.
apply/negP=> HH.
have: p < p.
  apply: plt_trans (mreduce_lt Rp).
  apply: plt_mlead.
by apply: lt_le_trans HH.
by rewrite plt_anti.
Qed.

Lemma mreduceplus_0_mem p r : r \in L -> p * r ->_+ 0.
Proof.
move=> Ir.
have [/eqP->|Zr] := boolP (r == 0).
  by rewrite mulr0 mreduceplus_ref.
have Zlr : mleadc r != 0 by rewrite mleadc_eq0.
move: p; apply: (well_founded_induction (@plt_wf _ _)) => p IH.
have [/eqP->|Zp] := boolP (p == 0).
  by rewrite mul0r mreduceplus_ref.
pose p1 := p - mleadc p *: 'X_[mlead p].
have /mreduceplus_trans -> //: p * r ->_+ p1 * r.
  apply: mreduceplusW.
  apply/mreduceP; exists (mlead (p * r)); exists r; split=> //.
  - by apply: mlead_supp; rewrite mulf_eq0 negb_or Zp.
  - by rewrite mleadM // lem_addl.
  rewrite /mdiv /p1 mulrBl mleadM_proper; last first.
    by rewrite mulf_neq0 // mleadc_eq0.
  by rewrite mleadcM mulfK // addmK.
apply/IH/pltP; exists (mlead p); split=>[||m1 Lm1].
- by apply: mlead_supp.
- by rewrite mcoeff_msupp mcoeffB mcoeffZ mcoeffX eqxx mulr1 subrr eqxx.
rewrite !mcoeff_msupp mcoeffB mcoeffZ mcoeffX.
rewrite mcoeff_gt_mlead //.
move: Lm1; rewrite lt_neqAle => /andP[/negPf-> _].
by rewrite mulr0 subrr eqxx.
Qed.

Lemma ideal_reduceplus p q : p ->_+ q -> (ideal L p <-> ideal L q).
Proof.
move: p; apply: (well_founded_induction (@plt_wf _ _)) => p1 IH.
move/mreduceplusP=> [->//|[q1 H1 H2]].
have [H3 H4] := IH _ (mreduce_lt H1) H2.
split=> H5; first by apply/H3/(ideal_reduce H1).
by apply/(ideal_reduce H1)/H4.
Qed.

Lemma ideal_reduceplus_0  p : p ->_+ 0 -> ideal L p.
Proof. by move=> /ideal_reduceplus [_ /(_ (ideal0 _))]. Qed.

Lemma reduceB_distr p q r :
  p - q ->_1 r -> exists p1, exists q1,
      [/\ p ->_+ p1 , q ->_+ q1 & r = p1 - q1].
Proof.
move=> /mreduceP[m [r1 [Im Ir1 Zr1 Lr1 ->]]].
have Zmr1 : mleadc r1 != 0.
  by move: Zr1; rewrite mleadc_eq0 /mdiv; case: (_ == _).
exists (if m \in msupp p then mdiv m p r1 else p).
exists (if m \in msupp q then mdiv m q r1 else q); split.
- case: (boolP (_ \in _)) => Imp; last by apply: mreduceplus_ref.
  by apply/mreduceplusW; apply/mreduceP; exists m; exists r1.
- case: (boolP (_ \in _)) => Imq; last by apply: mreduceplus_ref.
  by apply/mreduceplusW; apply/mreduceP; exists m; exists r1.
move/msuppB_le: Im; rewrite /mdiv mem_cat mcoeffB.
have [H1 _|/memN_msupp_eq0-> //= ->] :=  boolP (_ \in _); last first.
  by rewrite sub0r -!scalerAl mulNr scaleNr opprK opprB -!addrA [-_ + _]addrC.
have [H2|/memN_msupp_eq0->] := boolP (_ \in _); last first.
  by rewrite subr0 -!addrA [-_ + _]addrC.
rewrite mulrBl -!scalerAl scalerBl !opprD !opprK.
rewrite !addrA; congr (_ + _); rewrite -!addrA; congr (_ + _).
by rewrite addrC.
Qed.

Lemma reduceplusB_distr p q :
 p - q ->_+ 0 -> exists2 r, p ->_+ r & q ->_+ r.
Proof.
move: (p - q) {2 4}p {2 4}q (eqxx (p -q)).
apply: (well_founded_induction (@plt_wf _ _)) => r1 IH p1 q1 /eqP HH.
move/mreduceplusP => [Zr1|].
  exists p1; first by apply: mreduceplus_ref.
  by rewrite -[p1](subrK q1) -HH Zr1 add0r mreduceplus_ref.
rewrite HH => [[r2 Hr2]].
have FF : r2 < r1 by apply: mreduce_lt; rewrite HH.
move: Hr2 => /reduceB_distr[p2 [q2 [H1 H2 H3]]] H4.
case: (IH r2 _ p2 q2)=> //; first by apply/eqP.
move=> r3 H5 H6; exists r3; first by apply: mreduceplus_trans H5.
by apply: mreduceplus_trans H6.
Qed.

Lemma reduceB_compat p q r :
  p ->_1 q -> exists2 r1, p - r ->_+ r1 & q - r ->_+ r1.
Proof.
move=> /mreduceP[m [r1 [Im Ir1 Zr1 Lr1 Er1]]].
have Zmr1 : mleadc r1 != 0.
  by move: Zr1; rewrite mleadc_eq0 /mdiv; case: (_ == _).
have Zqm : q@_m = 0.
  apply: memN_msupp_eq0.
  by rewrite Er1; apply: mdiv_not_supp.
have [I1m|I1m] := boolP (m \in msupp (p - r)); last first.
  have F : p@_m = r@_m.
    by move: I1m; rewrite !mcoeff_msupp negbK mcoeffB subr_eq0 => /eqP.
  exists (p - r); first apply: mreduceplus_ref.
  apply/mreduceplusW/mreduceP; exists m; exists r1; split=> //.
    by move: Im; rewrite !mcoeff_msupp mcoeffB Zqm sub0r oppr_eq0 F.
  rewrite /mdiv mcoeffB Zqm sub0r Er1 /mdiv -F mulNr scaleNr mulNr opprK.
  by rewrite addrAC subrK.
exists (mdiv m (p - r) r1).
  by apply/mreduceplusW/mreduceP; exists m; exists r1; split.
have [I2m|I2m] := boolP (m \in msupp r); last first.
  suff->: mdiv m (p - r) r1 = q - r by apply: mreduceplus_ref.
  rewrite Er1 /mdiv mcoeffB.
  move: I2m; rewrite mcoeff_msupp negbK => /eqP->.
  by rewrite subr0 addrAC.
suff->: mdiv m (p - r) r1 = mdiv m (q - r) r1.
  apply/mreduceplusW/mreduceP; exists m; exists r1; split=> //.
  by move: I2m; rewrite !mcoeff_msupp mcoeffB Zqm sub0r oppr_eq0.
rewrite /mdiv !mcoeffB Zqm sub0r Er1 /mdiv [_ - _ - r]addrAC.
by rewrite mulrBl scalerBl mulrBl mulNr scaleNr mulNr opprD !opprK -!addrA.
Qed.

Definition mreducestar p q := (p ->_+ q) && irreducible q.

Notation " a ->_* b " := (mreducestar a b) (at level 40).

Definition mfr p f :=
   if mreducef p is Some q then
   (if q < p as b return ((b -> _) -> _)
       then fun f => f is_true_true
       else fun f => 0) (f q)
   else p.

Lemma mfr_ext p f g : (forall r (H : r < p), f r H = g r H) -> mfr f = mfr g.
Proof.
rewrite /mfr => HH; case: mreducef => //= a.
by case: (_ < _) (f a) (g a) (HH a).
Qed.

Definition mreduceplusf p := Fix (@plt_wf _ _) _ mfr p.

Lemma mreducestar0W p : p ->_+ 0 -> p ->_* 0.
Proof.
move=> H;apply/andP; split=> //.
by apply: irreducible0.
Qed.

Lemma mreducestar0 : 0 ->_* 0.
Proof. by apply/mreducestar0W/mreduceplus_ref. Qed.

Lemma mreducestar_trans r p q : p ->_+ r -> r ->_* q -> p ->_* q.
Proof.
move=> H1 /andP[H2 H3]; apply/andP; split => //.
by apply: mreduceplus_trans H2.
Qed.

Lemma mreducestarfE p : p ->_* mreduceplusf p.
Proof.
move: p; apply: (well_founded_induction (@plt_wf _ _)) => p1 IH.
rewrite /mreduceplusf Fix_eq /mfr //=.
  case E: (mreducef p1) (mreducefE p1) => [r|] // Hr; last first.
    by rewrite /mreducestar mreduceplus_ref /=.
  rewrite mreduce_lt /mreducestar //=.
  have/andP[H1 /= ->]:= IH r (mreduce_lt Hr).
  by rewrite (mreduceplus_trans (mreduceplusW Hr)).
move=> p f g H.
case E: (mreducef p) (mreducefE p) => [r|] //= Hr.
by move: (f r) (g r) (H r); rewrite mreduce_lt.
Qed.

Lemma mreduceplusfE p : p ->_+ mreduceplusf p.
Proof. by case/andP: (mreducestarfE p). Qed.

Lemma ideal_reducestar p q : p ->_* q -> (ideal L p <-> ideal L q).
Proof. by move=> /andP[/ideal_reduceplus]. Qed.

Lemma ideal_reducestar_0  p : p ->_* 0 -> ideal L p.
Proof. by move=> /ideal_reducestar [_ /(_ (ideal0 _))]. Qed.


Definition grobner := forall p, ideal L p -> p ->_+ 0.

Definition mconfluent :=
  forall p q r, p ->_* q -> p ->_* r -> q = r.

Lemma mconfluent_grobner: mconfluent -> grobner.
Proof.
move=> HC p [t ->].
have : {subset L <= L}  by [].
elim: {-3}L t => /= [t _ |r L1 IH t HS].
  by rewrite big_ord0 mreduceplus_ref.
rewrite big_ord_recl.
set q := \sum_(_ < _) _.
pose q1 := \sum_(i < size L1) [tuple of behead t]`_i * L1`_i.
have F : q = q1.
  apply: eq_bigr => /= {q q1}i; case: t => [[]] //=.
have F1 : q ->_* 0.
  apply:mreducestar0W.
  rewrite F.
  by apply: IH => m Im; apply: HS; rewrite inE orbC Im.
set p1 := _ * _.
have/reduceplusB_distr[r1 F2 F3]: p1 + q - q ->_+ 0.
  by rewrite addrK mreduceplus_0_mem //= HS // inE eqxx.
apply: mreduceplus_trans F2 _.
suff <-: mreduceplusf r1 = 0 by apply: mreduceplusfE.
apply: HC F1.
apply: mreducestar_trans F3 _.
by exact: mreducestarfE.
Qed.

Definition spoly p q :=
  if p * q == 0 then 0 else
   let m := mlcm (mlead p) (mlead q) in
   mdiv m 'X_[m] p - mdiv m 'X_[m] q.

Lemma spolypp p : spoly p p = 0.
Proof. by rewrite /spoly subrr if_same. Qed.

Lemma spoly_sym p q : spoly p q = - (spoly q p).
Proof.
rewrite /spoly [_ * p]mulrC; case: (_ == _); first by rewrite oppr0.
by rewrite opprB [mlcm _ (mlead p)]mlcmC.
Qed.

Lemma ideal_spoly p q : ideal L p -> ideal L q -> ideal L (spoly p q).
Proof.
move=> Ip Iq; rewrite /spoly.
case: (_ == _); first by exact: ideal0.
by rewrite mdivB; apply/idealB; apply: idealM.
Qed.

Definition spoly_red := (forall p q, p \in L -> q \in L -> spoly p q ->_* 0).

Lemma spoly_red_conf: spoly_red -> mconfluent.
Proof.
move=> HS; apply: (well_founded_induction (@plt_wf _ _)) => p IH q r.
have [Ip|/negP Ip] := boolP (irreducible p).
  case/andP=>
      /mreduceplusP[<- _ /andP[/mreduceplusP[//|[r1 Rr1 _]]]|[r1 Rr1 _] _ _].
    by have /irreducibleP/(_ r1)[] := Ip.
  by have /irreducibleP/(_ r1)[] := Ip.
have Zp : p != 0.
  move/negP: Ip; apply: contra => /eqP->; exact: irreducible0.
case/andP=> /mreduceplusP[<-//|[p1 R1p Rp1] Iq].
case/andP=> /mreduceplusP[<-//|[p2 R2p Rp2] Ir].
suff [p3 R1p1 R1p2]: exists2 p3, p1 ->_* p3 & p2 ->_* p3.
  have->// := IH _ (mreduce_lt R1p) q p3; last by apply/andP; split.
  apply: (IH _ (mreduce_lt R2p)) => //.
  by apply/andP; split.
case/mreduceP : R1p => m1 [r1 [Im1 Ir1 Zr1 Lr1 ->]].
case/mreduceP : R2p => m2 [r2 [Im2 Ir2 Zr2 Lr2 ->]].
wlog: m1 m2 r1 r2 Im1 Zr1 Lr1 Ir1 Im2 Zr2 Lr2 Ir2 / (m2 <= m1)%O => [HW|Lm2].
  have [Lo|Lo] := boolP (m2 <= m1)%O; first by apply: HW.
  case: (HW m2 m1 r2 r1 Im2 Zr2 Lr2 Ir2 Im1 Zr1 Lr1 Ir1) => //.
    by rewrite leNgt ?lt_neqAle ?negb_and ?Lo 1?orbC //.
  by move=> p3 H1 H2; exists p3.
have [/eqP Em1|Em1] := boolP (m1 == mlead p);
       have [/eqP Em2|Em2] := boolP (m2 == mlead p).
- pose m3 := mlcm (mlead r1) (mlead r2).
  have F : (m3 <= mlead p)%MM.
    by rewrite lem_mlcm -{1}Em1 Lr1 -Em2 Lr2.
  have /andP[/(mreduceplusXm (mlead p - m3))
             /(mreduceplus_scale (mleadc p))] := (HS _ _ Ir1 Ir2).
  have<-: mdiv m1 p r1 - mdiv m2 p r2 =
                      (mleadc p) *: ('X_[mlead p - m3] * spoly r1 r2).
    rewrite /spoly !mdivB mulf_eq0 (negPf Zr1) (negPf Zr2) /= -/m3.
    rewrite !mcoeffX eqxx Em1 Em2 !mul1r.
    rewrite mulrBr scalerBr -!scalerAl -!scalerAr !scalerA !mulrA -!mpolyXD.
    by rewrite !addmBA ?submK ?(lem_mlcml _ _) ?(lem_mlcmr _ _).
  rewrite mulr0 scaler0 => /reduceplusB_distr=> [[p4 R1p1 R1p2]] _.
  case/andP: (mreducestarfE p4) => Rp4 Ip4.
  by exists (mreduceplusf p4); apply/andP; split=> //;
     apply: mreduceplus_trans Rp4.
- pose t : {mpoly R[n]} := mleadc p *: 'X_[mlead p].
  pose q1 := p - t.
  pose q2 := q1 - mdiv m1 p r1.
  pose q3 := mdiv m2 p r2 - t.
  have F1 : p ->_1 q1 - q2.
    by rewrite /q2 opprB addrC subrK mreduce_mdiv.
  have F2 : p ->_1 t + q3.
    by rewrite /q3 addrC subrK mreduce_mdiv.
  have F3 : q1 ->_1 q3.
    apply/mreduceP; exists m2; exists r2; split=> //.
      rewrite mcoeff_msupp mcoeffB mcoeffZ mcoeffX.
      by rewrite [_ == m2]eq_sym (negPf Em2) mulr0 subr0 -mcoeff_msupp.
    rewrite /mdiv mcoeffB mcoeffZ mcoeffX [_ == m2]eq_sym (negPf Em2).
    by rewrite mulr0 subr0 addrAC.
  have [q4 F5 F6] : exists2 q4, q1 - q2 ->_+ q4 & q3 - q2 ->_+ q4.
    by apply: reduceB_compat.
  have /andP[F7 F8] := mreducestarfE q4.
  exists (mreduceplusf q4); apply/andP; split => //.
     have->: mdiv m1 p r1 = q1 - q2 by rewrite /q2 opprB addrC subrK.
     by apply: mreduceplus_trans F7.
  suff/mreduceplusW/mreduceplus_trans->/=: mdiv m2 p r2 ->_1 q3 - q2.
  - by [].
  - by apply: mreduceplus_trans F7.
  apply/mreduceP; exists m1; exists r1; split=> //.
    rewrite mcoeff_msupp mcoeffB -scalerAl mcoeffZ.
    rewrite [(_ * _)@_ _]mcoeff_gt_mlead.
      by rewrite mulr0 subr0 -mcoeff_msupp.
    rewrite mleadM //.
      rewrite mleadXm submK //.
      by rewrite lt_neqAle Em1 Em2 -Em1.
    by rewrite -mleadc_eq0 mleadXm mcoeffX eqxx oner_eq0.
  rewrite /q3 /q2 /q1 /= /mdiv /t -Em1.
  rewrite mcoeffB -scalerAl mcoeffZ.
    rewrite [(_ * _)@_ _]mcoeff_gt_mlead; last first.
    rewrite mleadM //.
      rewrite mleadXm submK //.
      by rewrite lt_neqAle Em1 Em2 -Em1.
    by rewrite -mleadc_eq0 mleadXm mcoeffX eqxx oner_eq0.
  rewrite mulr0 subr0.
  rewrite -!addrA; congr (_ + (_ + _)).
  rewrite opprB !addrA opprB !addrA !opprD opprK !addrA addrK.
  by rewrite addNr sub0r.
- case/negP: Em1; rewrite eq_le.
  by rewrite msupp_le_mlead // -Em2 Lm2.
pose t := mleadc p *: 'X_[mlead p].
pose q1 := p - t.
pose q2 := mdiv m1 p r1 - t.
pose q3 := mdiv m2 p r2 - t.
have F1 : q1 ->_1 q2.
  apply/mreduceP; exists m1; exists r1; split => //.
    rewrite mcoeff_msupp mcoeffB mcoeffZ mcoeffX [_ == m1]eq_sym (negPf Em1).
    by rewrite mulr0 subr0 -mcoeff_msupp.
  rewrite /q2 /q1 /mdiv mcoeffB mcoeffZ mcoeffX [_ == m1]eq_sym (negPf Em1).
  by rewrite mulr0 subr0 -!addrA [- _ - _]addrC.
have F2 : q1 ->_1 q3.
  apply/mreduceP; exists m2; exists r2; split => //.
    rewrite mcoeff_msupp mcoeffB mcoeffZ mcoeffX [_ == m2]eq_sym (negPf Em2).
    by rewrite mulr0 subr0 -mcoeff_msupp.
  rewrite /q3 /q1 /mdiv mcoeffB mcoeffZ mcoeffX [_ == m2]eq_sym (negPf Em2).
  by rewrite mulr0 subr0 -!addrA [- _ - _]addrC.
have F3 : (q1 < p).
  apply/pltP; exists (mlead p); split=> [||m3 Lm3]; first by apply: mlead_supp.
    by rewrite mcoeff_msupp negbK mcoeffB mcoeffZ mcoeffX eqxx mulr1 subrr eqxx.
  rewrite !mcoeff_msupp mcoeffB mcoeffZ mcoeffX.
  move: Lm3; rewrite lt_neqAle => /andP[/negPf-> _].
  by rewrite mulr0 subr0.
exists (mreduceplusf(t + mreduceplusf q1)); apply/andP; split.
- have->: mdiv m1 p r1 = t + q2.
    by rewrite /q2 addrCA subrr addr0.
  apply: mreduceplus_trans (mreduceplusfE _).
  apply: mreduceplus_compatX => //.
    apply: le_lt_trans (mreduce_lead F1) _.
    by apply: ltm_mleadD => //; apply: mreduce_neq0 F1.
  have->: mreduceplusf q1 = mreduceplusf q2.
    apply: (IH q1) => //.
      by apply: mreducestarfE.
    apply: mreducestar_trans (mreducestarfE _).
    by apply: mreduceplusW.
  by apply: mreduceplusfE.
- by case/andP: (mreducestarfE (t + mreduceplusf q1)).
- have->: mdiv m2 p r2 = t + q3.
    by rewrite /q3 addrCA subrr addr0.
  apply: mreduceplus_trans (mreduceplusfE _).
  apply: mreduceplus_compatX => //.
    apply: le_lt_trans (mreduce_lead F2) _.
    by apply: ltm_mleadD => //; apply: mreduce_neq0 F1.
  have->: mreduceplusf q1 = mreduceplusf q3.
    apply: (IH q1) => //.
      by apply: mreducestarfE.
    apply: mreducestar_trans (mreducestarfE _).
    by apply: mreduceplusW.
  by apply: mreduceplusfE.
by case/andP: (mreducestarfE (t + mreduceplusf q1)).
Qed.

End Main.

Lemma mreduce_subset (R: fieldType) n l1 l2 (p q : {mpoly R[n]}) :
 {subset l1 <= l2} -> mreduce l1 p q -> mreduce l2 p q.
Proof.
move=> H /mreduceP[m [r [Im Ir Zr Lm ->]]].
apply/mreduceP; exists m; exists r; split => //.
by apply: H.
Qed.

Lemma mreduceplus_subset (R: fieldType) n  l1 l2  (p q : {mpoly R[n]}) :
 {subset l1 <= l2} -> mreduceplus l1 p q -> mreduceplus l2 p q.
Proof.
move=> H; move: p q; apply: (well_founded_induction (@plt_wf _ _)) => p IH q.
move/mreduceplusP => [<-|[r H1 H2]]; first by apply: mreduceplus_ref.
apply: mreduceplus_trans (mreduceplusW _) (IH _ _ _ H2).
  by apply: mreduce_subset H1.
apply: mreduce_lt H1.
Qed.

Lemma mreducestar_subset (R: fieldType) n l1 l2 (p : {mpoly R[n]}) :
 {subset l1 <= l2} -> mreducestar l1 p 0 -> mreducestar l2 p 0.
Proof.
move=> H /andP[/(mreduceplus_subset H) H1 _].
by apply:mreducestar0W.
Qed.

Fixpoint has_r A (R : rel A) (l : seq A) :=
  if l is a :: l1 then has (R^~ a) l1 || has_r R l1
  else false.

Lemma has_r_catr A (R : rel A) l1 l2 :
  has_r R l2 -> has_r R (l1 ++ l2).
Proof. by elim: l1 => //a l1 IH /IH /= ->; case: has. Qed.

Lemma has_r_ins A (R : rel A) l1 l2 l3 :
  has_r R (l1 ++ l3) ->  has_r R (l1 ++ l2 ++ l3).
Proof.
elim: l1 => /= [|a l1 IH /orP[|H1]]; first by exact: has_r_catr.
  by rewrite !has_cat => /orP[] -> //=; rewrite !orbT.
by rewrite IH // orbT.
Qed.

Lemma has_r_map A B (R : rel A) (S : rel B) f l :
 (forall a b, R a b -> S (f a) (f b)) -> has_r R l -> has_r S (map f l).
Proof.
move=> HRS; elim: l => //= a l IH /orP[|/IH->]; last first.
  by rewrite orbT.
by elim: {IH}l => //= => a1 l IH /orP[Raa1|/IH /orP[]->];
   rewrite ?orbT // HRS.
Qed.

Inductive bar A (P : pred (seq A)) (l : seq A) : Prop :=
  | bar_0: P l -> bar P l
  | bar_1: (forall a, bar P (a :: l)) -> bar P l.

Definition bar_r A (R : rel A) := bar (has_r R).

Lemma bar_r_catr A (R : rel A) l1 l2 : bar_r R l2 -> bar_r R (l1 ++ l2).
Proof.
elim: l1 => //= a l1 IH /IH.
elim => [l H|l H1 _] //.
by apply: bar_0 => /=; rewrite H orbT.
Qed.

Lemma bar_r_ins A (R : rel A) l1 l2 l3 :
  bar_r R (l1 ++ l3) -> bar_r R (l1 ++ l2 ++ l3).
Proof.
move=> H.
elim : H {-1}l1 l2 {-1}l3 (refl_equal (l1 ++ l3))
       => {l1 l3}//= [l H l1 l2 l3 lE|l IH H l1 l2 l3 lE].
  by apply/bar_0/has_r_ins; rewrite -lE.
apply: bar_1 => a.
by apply: H (_ : a :: _ = (_ :: _) ++  _); rewrite lE.
Qed.

Lemma bar_r_map A B (R: rel A) (S: rel B) f :
 (forall a b, R a b -> S (f a) (f b)) ->
 (forall b: B, {a: A | b = f a}) ->
 forall l, bar_r R l -> bar_r S (map f l).
Proof.
move=> HRS f_surj l.
elim=> {l}/= [l Hh | l _ HBr]; first by apply/bar_0/(has_r_map HRS Hh).
apply: bar_1 => a.
have [b ->]:= f_surj a.
by apply: HBr.
Qed.

Fixpoint  min  A (lt R : rel A) l :=
  if l is a :: l then
      min lt R l /\ (forall y, lt y a -> bar_r R (y :: l))
  else True.

Lemma open_ind A (lt R : rel A) l :
  well_founded lt ->
  min lt R l -> (forall a, min lt R (a :: l) -> bar_r R (a :: l))
      -> bar_r R l.
Proof.
move=> wflt Hm IH; apply: bar_1.
elim/(well_founded_ind wflt)=> x IH1.
by apply: IH.
Qed.

Section Dickson.

Variables A B : Type.
Variable lt : rel A.
Variable R : rel B.
Variable wfgt: well_founded lt.
Variable wr_R: bar_r R [::].

Local Infix "<" := lt.
Local Notation "a <= b" := (~~ (lt b a)).

Lemma bar_r_prod_nil :
 bar_r [rel a b | (a.1 <= b.1) && R a.2 b.2] [::].
Proof.
set prod := [rel _ _ | _].
have: min [rel a b | a.1 < b.1] prod [::] by [].
pose l1 := [seq x.2 | x <- ([::] : seq (A * B))].
have H1 : bar_r R l1 by [].
have := (refl_equal l1); rewrite {2}/l1.
elim: {l1}H1 {1 2 3}[::] => //= [|l H1 H2 l2 H3 H4].
  elim => //= a l IH Ho [|b l1] //= [J1 J2] [Hmin Hbar].
  have /orP[H | H] := Ho.
    move: H Hmin; rewrite J1 {J1 a l Ho IH Hbar}J2.
    elim: l1 b => //= a l IH b /orP[Rav [Hmin Hbar]|Hh [Hmin Hbar]].
      case: (boolP (b.1 < a.1)) => [aLb|bLa].
        by have := bar_r_ins [::a] (Hbar _ aLb : _ ([::b] ++ l)).
      by apply: bar_0 => /=; rewrite bLa Rav.
    by apply: (bar_r_ins [::a] ((IH _ Hh Hmin) : _ _  ([::b] ++ l))).
  apply: (bar_r_ins [::b] (_ : _ _ ([::] ++ l1))).
  by apply: IH.
apply: open_ind (wf_inverse_image _ _ _  _ wfgt) H4 _ => a /= H5.
by apply: (@H2 a.2) => //=; rewrite H3.
Qed.

End Dickson.

Lemma bar_r_lem_nil n : bar_r (@lem n) [::].
Proof.
elim: n => [|n IH].
  apply: bar_1 => a; apply: bar_1 => b; apply: bar_0 => /=.
  by rewrite !orbF; apply/forallP => /= [[]].
pose f (a : nat * 'X_{1..n}) := [multinom of a.1 :: a.2].
pose R1 := [rel a b | ((~~ (b.1 < a.1)) && (lem a.2 b.2))%N].
rewrite [bar_r _ _]/(bar_r (@lem _)[seq f i | i <- [::]]).
have HR1R a b : R1 _ a b -> @lem _ (f a) (f b).
  case/andP=> aLb /forallP Ht.
  apply/mnm_lepP=> /= [[[|i] Hi]] /=.
    by rewrite /fun_of_multinom /= !(tnth_nth 0%N) /= leqNgt.
  have := Ht (Ordinal (Hi : (i < n)%N)).
  by rewrite /fun_of_multinom !(tnth_nth 0%N) /=.
apply: bar_r_map HR1R _ _ _ => [a|].
  case: a => t; exists (tnth t ord0, [multinom [tuple of behead t]]).
  by apply/val_eqP=> /=; apply/eqP/val_eqP; case: t => /= [[]].
have Hlt a b : (a < b)%N -> (a < b)%coq_nat by move/ssrnat.ltP.
exact: bar_r_prod_nil (Wf_nat.well_founded_lt_compat _ _ _ Hlt) IH.
Qed.

Definition smlt n : rel (seq 'X_{1..n}) :=
  [rel sp sq |
    let p := head 0%MM sp in (sp == p :: sq) && ~~ has ((@lem n) ^~ p) sq].

Lemma wf_smlt n : well_founded (@smlt n).
Proof.
move=> l1.
apply: Acc_intro=> l2 /andP[/eqP-> _].
set x := head _ _.
rewrite -cat1s.
have : ~~ has_r (@lem n) [::x] by [].
have :  bar_r (@lem n) [::x].
  rewrite -[[::x]]cats0; apply: bar_r_catr.
  by apply: bar_r_lem_nil.
elim => [l H /negP[] // |l Hb IH NH] .
apply: Acc_intro => y /andP[/eqP-> Hb1].
apply: IH; rewrite /= negb_or NH andbT.
by apply: contra Hb1; rewrite has_cat =>->.
Qed.

Definition splt n (R : ringType) (lp lq : seq {mpoly R[n]}) :=
  smlt [seq mlead p | p <- lp & p != 0] [seq mlead q | q <- lq & q != 0].

Lemma wf_splt n R : well_founded (@splt n R).
Proof. by apply: wf_inverse_image (@wf_smlt n). Qed.

Section Algo.

Variable R : fieldType.
Variable n : nat.

Implicit Types p q : {mpoly R[n]}.
Implicit Types m : 'X_{1..n}.


Definition psplt (psp1 psp2 : seq {mpoly R[n]} * seq {mpoly R[n]}) :=
  (splt psp1.1 psp2.1) ||
  ((psp1.1 == psp2.1) && (size psp1.2 < size psp2.2)%N).

Lemma wf_ltn : well_founded (ltn : nat -> nat -> bool).
Proof.
elim=> [|n1 [IH]].
  by apply: Acc_intro=> b; rewrite /= ltn0.
apply: Acc_intro => b H; apply: Acc_intro => c H1.
apply: IH.
apply: leq_ltn_trans H1 H.
Qed.

Lemma wf_psplt : well_founded psplt.
Proof.
move=> [].
apply: (well_founded_induction (@wf_splt _ _))=> lp1 IH1.
apply: (well_founded_induction (wf_inverse_image _ _ _ size wf_ltn)) => lp2 IH2.
apply: Acc_intro=> [] [lp3 lp4]; rewrite /psplt /=.
have [H1 _|_ /=] := boolP (splt _ _); first by apply: IH1.
have [/eqP-> H1|//] := boolP (_ == _).
by apply: IH2.
Qed.

Definition pbuch pr f :=
  if pr is (l, p :: r) then
    let p1 := mreduceplusf l p in
    if p1 == 0 then
       let pr1 := (l, r) in
      (if psplt pr1 pr as b return ((b -> _) -> _)
       then fun f => f is_true_true
       else fun f => l) (f pr1)
    else
    let pr1 := (p1 :: l,  [seq (spoly p1 q) | q <- l] ++ r) in
    (if psplt pr1 pr as b return ((b -> _) -> _)
       then fun f => f is_true_true
       else fun f => l) (f pr1)
   else pr.1.

Definition mbuch b c := Fix wf_psplt _ pbuch (b, c).

Lemma pbuch_ext pr f g : (forall pr1 (H : psplt pr1 pr), f pr1 H = g pr1 H) -> pbuch f = pbuch g.
Proof.
rewrite /pbuch /=.
move: pr f g; case=> l [|p r] f g H //=.
  move: (f (l, r)) (g (l, r)) (H (l, r)).
  have->:  psplt (l, r) (l, p :: r).
    by rewrite /psplt /= eqxx orbC /= leqnn.
  move=> f1 g1 H1.
case: (_ == _); first apply: H1.
by set u := (_, _); case: psplt (f u) (g u) (H u).
Qed.

Lemma mbuchE b c:
  mbuch b c =
  if c is p :: c1 then
    let p1 := mreduceplusf b p in
    if p1 == 0 then mbuch b c1 else
    mbuch (p1 :: b) ([seq (spoly p1 q) | q <- b] ++ c1)
  else b.
Proof.
rewrite {1}/mbuch Fix_eq /=; last by exact: pbuch_ext.
case: c=> // p c.
case: (boolP (_ == 0))=> H.
  by rewrite /psplt /= eqxx ltnS leqnn orbC.
rewrite (_: psplt _ _) // /psplt /= (_ : splt _ _) //.
rewrite /splt /smlt /= H eqxx /=.
set p1 := mreduceplusf _ _.
apply/hasPn => m /mapP[q]; rewrite mem_filter => /andP[Zq Lm] ->.
have /andP[_ /irreducibleP/(_ (mdiv (mlead p1) p1 q))/negP]:= mreducestarfE b p.
apply:contra=> H1.
apply: mreduce_mdiv => //.
by apply: mlead_supp.
Qed.

Lemma mbuch_ind P :
  (forall b, P b [::] b) ->
 (forall b p c, let p1 := mreduceplusf b p in
                 let c1 := [seq (spoly p1 q) | q <- b] ++ c in
    p1 != 0 -> P (p1 :: b) c1 (mbuch (p1 :: b) c1) -> P b (p :: c) (mbuch b (p :: c))) ->
  (forall b p c,  mreduceplusf b p == 0 ->
                   P b c (mbuch b c) -> P b (p :: c) (mbuch b (p :: c))) ->
  (forall b c, P b c (mbuch b c)).
Proof.
move=> IH1 IH2 IH3 b c.
pose p := (b,c); rewrite -[b]/p.1 -[c]/p.2; move: p.
apply: (well_founded_induction_type wf_psplt) => {b c}[] [b [|p c]] /= IH.
  by rewrite mbuchE.
have /= IH' := fun b c => IH (b, c).
have [Zp1|Zp1] := boolP (mreduceplusf b p == 0).
  apply: IH3 => //; apply: IH'.
  by rewrite /psplt /= orbC eqxx leqnn.
apply: IH2 => //; apply: IH'.
rewrite /psplt /= // /psplt /= (_ : splt _ _) //.
rewrite /splt /smlt /= Zp1 eqxx /=.
set p1 := mreduceplusf _ _.
apply/hasPn => m /mapP[q]; rewrite mem_filter => /andP[Zq Lm] ->.
have /andP[_ /irreducibleP/(_ (mdiv (mlead p1) p1 q))/negP]:= mreducestarfE b p.
apply:contra=> H1.
apply: mreduce_mdiv => //.
by apply: mlead_supp.
Qed.

Definition same_ideal l1 l2 := (forall p : {mpoly R[n]}, ideal l1 p <-> ideal l2 p).

Lemma same_ideal_id l : same_ideal l l.
Proof. by []. Qed.

Lemma same_ideal_sym l1 l2 : same_ideal l1 l2 -> same_ideal l2 l1.
Proof. by move=> H p; split; case: (H p). Qed.

Lemma same_ideal_trans l1 l2 l3 : same_ideal l1 l3 -> same_ideal l3 l2 -> same_ideal l1 l2.
Proof.
by (move=> H1 H2 p; split; case: (H1 p); case: (H2 p) => P1 P2 P3 P4)=> [/P3|/P2].
Qed.

Lemma mbuch_grobner (b c : seq {mpoly R[n]}) :
 (forall p q, p \in b -> q \in b ->
                spoly p q \notin c -> spoly q p \notin c
                          -> mreducestar b (spoly p q) 0) ->
 (forall p, p \in c -> ideal b p) ->
    same_ideal b (mbuch b c) /\ spoly_red (mbuch b c).
Proof.
apply mbuch_ind=>
   [{b c}b H _|{b c}b p c p1 c1 E IH HS HI|b1 p c1 Em IH1 IH2 IH3].
- by split=> // p q Ip Iq; apply: H.
- rewrite mbuchE /= (negPf E) /= -/p1 -/c1.
  case: IH => [p2 q2|p2|HS1 GB].
  - rewrite !inE => /orP[/eqP->|H1] /orP[/eqP->|H2] H3 H4.
    - by rewrite spolypp mreducestar0.
    - by case/negP: H3; rewrite mem_cat map_f.
    - by case/negP: H4; rewrite mem_cat map_f.
    have [/eqP->|D1s] := boolP (spoly p2 q2 == p).
      apply:mreducestar0W.
      apply: mreduceplus_trans (_ : mreduceplus _ p1 0).
        apply: mreduceplus_subset (mreduceplusfE b p) => m.
        by rewrite inE orbC => ->.
      apply/mreduceplusW/mreduceP; exists (mlead p1); exists p1; split=> //.
      - by apply/mlead_supp.
      - by rewrite inE eqxx.
      - by apply: lepm_refl.
      rewrite /mdiv -{3}(mpoly.add0m (mlead p1)) addmK mpolyX0 divff.
        by rewrite scale1r mul1r subrr.
      by rewrite mleadc_eq0.
    have [/eqP Hp|D2s] := boolP (spoly q2 p2 == p).
      apply:mreducestar0W.
      rewrite -[spoly _ _]opprK -oppr0 -scaleN1r -[-0]scaleN1r.
      apply: mreduceplus_scale.
      rewrite -spoly_sym Hp.
      apply: mreduceplus_trans (_ : mreduceplus _ p1 0).
        apply: mreduceplus_subset (mreduceplusfE b p) => m.
        by rewrite inE orbC => ->.
      apply/mreduceplusW/mreduceP; exists (mlead p1); exists p1; split=> //.
      - by apply/mlead_supp.
      - by rewrite inE eqxx.
      - by apply: lepm_refl.
      rewrite /mdiv -{3}(mpoly.add0m (mlead p1)) addmK mpolyX0 divff.
        by rewrite scale1r mul1r subrr.
      by rewrite mleadc_eq0.
    apply: mreducestar_subset (HS _ _ _ _ _ _)=> [m1||||] //.
    - by rewrite inE orbC=> ->.
    - by move: H3; rewrite inE mem_cat !negb_or D1s => /andP[].
    by move: H4; rewrite inE mem_cat !negb_or D2s => /andP[].
   - rewrite mem_cat => /orP[/mapP[p3 Ip3 ->]|Hp2].
       apply: ideal_spoly; apply: ideal_mem; first by rewrite inE eqxx.
       by rewrite inE orbC Ip3.
     by apply/ideal_consr/HI; rewrite inE orbC Hp2.
   split=> //; apply: same_ideal_trans HS1 => p2; split=> // [H1|H1].
     by apply: ideal_consr.
   apply: ideal_consl H1.
   case: (ideal_reduceplus (mreduceplusfE b p)) => H1 _.
   by apply/H1/HI; rewrite inE eqxx.
rewrite mbuchE /= Em.
apply: IH1=> [p1 q1 Hp1 Hq1 Sp1 Sq1|p1 Ip1].
  have [/eqP->|D1s] := boolP (spoly p1 q1 == p).
    apply:mreducestar0W.
    rewrite -(eqP Em).
    by apply: mreduceplusfE.
  have [/eqP Hp|D2s] := boolP (spoly q1 p1 == p).
    apply:mreducestar0W.
    rewrite -[spoly _ _]opprK -oppr0 -scaleN1r -[-0]scaleN1r.
    apply: mreduceplus_scale.
    rewrite -spoly_sym Hp -(eqP Em).
    by apply: mreduceplusfE.
  by apply: IH2; rewrite // inE negb_or ?D1s ?D2s.
by apply: IH3; rewrite inE Ip1 orbT.
Qed.

Definition mbuch_all l := mbuch l [seq spoly i j | i <- l, j <- l].

Lemma mbuch_all_grobner l : same_ideal l (mbuch_all l) /\ spoly_red (mbuch_all l).
Proof.
apply: mbuch_grobner=> [p q Ip Iq /negP[]|p /allpairsP[[p1 q1 [/=Ip1 Iq2 ->]]]].
  by apply/allpairsP; exists (p,q).
by apply: ideal_spoly; apply: ideal_mem.
Qed.

Definition idealf l p := let l1 := mbuch_all l in mreduceplusf l1 p == 0.

Lemma idealfP p l : reflect (ideal l p) (idealf l p).
Proof.
have [HS HB] := mbuch_all_grobner l.
apply: (iffP idP); rewrite /idealf => H.
  have [_ H1] := HS p; apply: H1.
  apply: ideal_reducestar_0.
  by rewrite -(eqP H); exact: mreducestarfE.
apply/eqP.
apply: (spoly_red_conf HB) (mreducestarfE _  _) _.
apply: mreducestar0W.
apply: (mconfluent_grobner ((spoly_red_conf HB))).
by have [H1 _] := HS p; apply: H1.
Qed.

End Algo.

End Grobner.