
Require Import mathcomp.ssreflect.ssreflect.
From mathcomp
Require Import ssrfun ssrbool eqtype ssrnat seq choice fintype path fingraph.
From mathcomp
Require Import bigop ssralg ssrnum ssrint.
From fourcolor
Require Import hypermap geometry quiztree part discharge.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Inductive hubcap :=
  | Hubcap0
  | Hubcap1 of nat & int & hubcap
  | Hubcap2 of nat & nat & int & hubcap.

Module HubcapSyntax.

Notation "$" := Hubcap0 (at level 8).
Notation "$[ j1 ] <= b h" := (Hubcap1 j1.-1 b%:Z h)
  (at level 8, j1, b at level 0, h at level 9,
   format "$[ j1 ] <= b  h").
Notation "$[ j1 ] <= ( - b ) h" := (Hubcap1 j1.-1 (- b%:Z) h)
  (at level 8, j1, b at level 0, h at level 9,
   format "$[ j1 ] <= ( - b )  h").
Notation "$[ j1 , j2 ] <= b h" := (Hubcap2 j1.-1 j2.-1 b%:Z h)
  (at level 8, j1, j2, b at level 0, h at level 9,
   format "$[ j1 , j2 ] <= b  h").
Notation "$[ j1 , j2 ] <= ( - b ) h" :=
     (Hubcap2 j1.-1 j2.-1 (- b%:Z) h)
  (at level 8, j1, j2, b at level 0, h at level 9,
   format "$[ j1 , j2 ] <= ( - b )  h").

End HubcapSyntax.

Section Hubcap.

Variables (nhub : nat) (redp : part -> bool) (rf : drule_fork nhub).
Let rs0 := source_drules rf.
Let rt0 := target_drules rf.

Variable G : hypermap.
Hypothesis geoG : plain_cubic_pentagonal G.
Let pentaG : pentagonal G := geoG.
Hypothesis redpP : forall (x : G) p, redp p -> ~~ exact_fitp x p.

Fixpoint check_dbound1_rec (p : part) (rs : drules) ns m {struct m} : bool :=
  if m is m'.+1 then
    if rs is r :: rs' then
      if size rs' < ns then true else
      let p' := meet_part p r in
      (let: SortDrules dns rs'' := sort_drules p' rs' in
       if ns - dns is ns'.+1 then check_dbound1_rec p' rs'' ns' m' else redp p')
      && check_dbound1_rec p rs' ns m'
    else true
  else false.

Definition check_dbound1 p ns :=
  let: DruleFork rs _ _ := rf in check_dbound1_rec p rs ns (size rs + 1).

Lemma check_dbound1P (x : G) p ns :
  arity x = nhub -> exact_fitp x p -> check_dbound1 p ns -> dbound1 rs0 x <= ns.
Proof.
move=> nFx; rewrite /check_dbound1 /rs0 /source_drules.
case: rf => rs _ _; move: (size rs + 1) => m.
elim: m ns rs p => // m IHm ns [|r rs] //= p fit_xp.
case: ifP => [/(leq_trans _)-> //| _ /andP[]].
  by rewrite -add1n leq_add ?leq_b1 ?count_size.
case fit_xr: (fitp x r); last by clear 1; apply: IHm => //=; rewrite fit_xr.
set p1 := meet_part p r.
have Efit_p1: exact_fitp x p1 by apply: exact_fitp_meet.
have [_ /sort_drulesP[dns rs1]] := andP Efit_p1.
case Dns1: (ns - dns) => [|ns1]; first by move/redpP/negP/(_ Efit_p1).
have dns_lt_ns: dns < ns by rewrite -subn_gt0 Dns1.
move=> bound_p1 _; rewrite -(subnKC (ltnW dns_lt_ns)) Dns1 /=.
by rewrite addnCA leq_add2l ltnS; apply: IHm bound_p1.
Qed.

Fixpoint check_unfit (p : part) (ru : drules) : bool :=
  if ru is r :: ru' then
    if cmp_part p r is Psubset then true else check_unfit p ru'
  else false.

Lemma check_unfitP (x : G) p :
  fitp x p -> forall ru, dbound1 ru x = 0 -> check_unfit p ru = false.
Proof.
move=> fit_xp; elim=> //= r ru IHru; case fit_xr: (fitp x r) => // /IHru->.
by move: fit_xr; rewrite (fitp_cmp fit_xp); case: (cmp_part p r).
Qed.

Fixpoint check_dbound2_rec (p : part) (rt rs ru : drules) nt m {struct m} :=
  if m isn't m'.+1 then false else
  if rt isn't r :: rt' then true else
  if size rt' < nt then true else
  let p' := meet_part p r in
  [&& if check_unfit p' ru then true else
      let: SortDrules dnt rt'' := sort_drules p' rt' in
      let: SortDrules dns rs' := sort_drules p' rs in
      if dns + nt - dnt isn't nt'.+1 then redp p' else
      check_dbound2_rec p' rt'' rs' ru nt' m'
    & check_dbound2_rec p rt' rs (r :: ru) nt m'].

Definition check_dbound2 p b :=
  let: DruleFork rs rt _ := rf in
  let: SortDrules dnt rt' := sort_drules p rt in
  let: SortDrules dns rs' := sort_drules p rs in
  if (dns%:Z - dnt%:Z + b)%R isn't Posz nt then false else
  check_dbound2_rec p rt' rs' [::] nt (size rt' + 2).

Import GRing.Theory Num.Theory.

Lemma check_dbound2P (x : G) p b :
    arity x = nhub -> exact_fitp x p -> check_dbound2 p b ->
  (dbound2 rt0 rs0 x <= b)%R.
Proof.
move=> nFx Exp; rewrite /check_dbound2 /dbound2; have [_ fit_xp] := andP Exp.
rewrite /rs0 /rt0 /source_drules /target_drules; case: rf => rs rt _.
set ru : drules := [::]; have bound_ru: dbound1 ru x = 0 by [].
have{rt} [dnt rt] := sort_drulesP fit_xp rt; move: (size rt + 2) => m.
have{rs fit_xp} [dns rs] := sort_drulesP fit_xp rs.
rewrite ler_subl_addl addrAC !PoszD [rhs in (_ <= rhs)%R]addrAC.
rewrite -ler_subr_addl [rhs in (_ <= rhs)%R]addrAC.
case: {dns dnt b}(_ - _)%R => // [nt]; rewrite -PoszD lez_nat.
elim: m nt rt => // m IHm nt [|r rt] //= in rs (ru) bound_ru p Exp *.
case: ifP => [lt_rt_nt _ | _ /andP[]].
  apply: leq_trans (leq_addr _ _); apply: leq_trans lt_rt_nt.
  by rewrite -add1n leq_add ?leq_b1 ?count_size.
case fit_xr: (fitp x r); last by move=> _ /IHm-> //=; rewrite fit_xr.
set p1 := meet_part p r; have Exp1: exact_fitp x p1 by apply: exact_fitp_meet.
have [_ fit_xp1] := andP Exp1; rewrite (check_unfitP fit_xp1) //.
have [dnt] := sort_drulesP fit_xp1 rt; have [dns] := sort_drulesP fit_xp1 rs.
move=> {rs rt fit_xp1} rs rt bound_p1 _.
case Dnt1: (_ - dnt) => [|nt1] in bound_p1.
  by case/idPn: Exp1; apply: redpP.
have le_dnt: dnt <= dns + nt by rewrite ltnW // -subn_gt0 Dnt1.
rewrite add1n addnCA addnA -ltn_subRL addnC -addnBA // Dnt1 addnC addSn ltnS.
exact: IHm bound_p1.
Qed.

Fixpoint check_2dbound2_rec
          p1 p2 (rt1 rs1 ru1 rt2 rs2 ru2 : drules) i nt m {struct m} : bool :=
  if m isn't m'.+1 then false else
  if rt1 isn't r :: rt1' then
    if rt2 is [::] then true else
    check_2dbound2_rec p2 p1 rt2 rs2 ru2 rt1 rs1 ru1 (nhub - i) nt m'
  else if size rt1' + size rt2 < nt then true else
  let p1' := meet_part p1 r in let p2' := rot_part i p1' in
  [&& if check_unfit p1' ru1 || check_unfit p2' ru2 then true else
      let: SortDrules dnt1 rt1'' := sort_drules p1' rt1' in
      let: SortDrules dns1 rs1' := sort_drules p1' rs1 in
      let: SortDrules dnt2 rt2' := sort_drules p2' rt2 in
      let: SortDrules dns2 rs2' := sort_drules p2' rs2 in
      if dns1 + (dns2 + nt) - (dnt1 + dnt2) isn't nt'.+1 then redp p1' else
      check_2dbound2_rec p1' p2' rt1'' rs1' ru1 rt2' rs2' ru2 i nt' m'
    & check_2dbound2_rec p1 p2 rt1' rs1 (r :: ru1) rt2 rs2 ru2 i nt m'].

Definition check_2dbound2 p1 i b :=
  let p2 := rot_part i p1 in
  let: DruleFork rs rt _ := rf in
  let: SortDrules dnt1 rt1 := sort_drules p1 rt in
  let: SortDrules dns1 rs1 := sort_drules p1 rs in
  let: SortDrules dnt2 rt2 := sort_drules p2 rt in
  let: SortDrules dns2 rs2 := sort_drules p2 rs in
  if ((dns1 + dns2)%:Z - (dnt1 + dnt2)%:Z + b)%R isn't Posz nt then false else
  let m := size rt1 + (size rt2 + 3) in
  check_2dbound2_rec p1 p2 rt1 rs1 [::] rt2 rs2 [::] i nt m.

Lemma check_2dbound2P (x : G) p i b :
    arity x = nhub -> exact_fitp x p -> i <= nhub -> check_2dbound2 p i b ->
  (dbound2 rt0 rs0 x + dbound2 rt0 rs0 (iter i face x) <= b)%R.
Proof.
move: x p => x1 p1 nFx1 Exp1 ub_i; rewrite /check_2dbound2 /dbound2.
rewrite /rs0 /rt0 /source_drules /target_drules; case: rf => rs rt _.
set ru : drules := [::]; have b1ru (x : G): dbound1 ru x = 0 by [].
set p2 := rot_part i p1; set x2 := iter i face x1.
move: ru {2 4}ru {b1ru}(b1ru x1) (b1ru x2) => ru1 ru2 b1ru1 b1ru2.
have [/eqP Ep1 fit_p1] := andP Exp1; rewrite nFx1 in Ep1.
have Exp2: exact_fitp x2 p2 by rewrite /x2 /p2 -fitp_rot -?Ep1.
have [dnt1 rt1] := sort_drulesP fit_p1 rt.
have{fit_p1 Ep1} [dns1 rs1] := sort_drulesP fit_p1 rs.
have [_ fit_p2] := andP Exp2.
have{rt} [dnt2 rt2] := sort_drulesP fit_p2 rt; move: (size rt1 + _) => m.
have{fit_p2} [dns2 rs2] := sort_drulesP fit_p2 rs; rewrite !PoszD => b2p.
rewrite addrACA -opprD addrACA [rhs in (- rhs)%R]addrACA opprD addrACA.
rewrite -ler_subr_addl opprB [rhs in (_ <= rhs)%R]addrC ler_subl_addl.
case: {dns1 dns2 dnt1 dnt2 b}(_ + b)%R b2p => // nt; rewrite lez_nat.
move: @x2 rt2 rs2 ru2 p2 b1ru2 Exp2 => /=.
elim: m rt1 => // m IHm [|r rt1]/= in nt x1 i nFx1 ub_i rs1 ru1 p1 b1ru1 Exp1 *.
  set x2 := iter i face x1; set i1 := nhub - i.
  case=> // r rt; move: {r rt}(r :: rt) => rt2 rs2 ru2 p2 b1ru2 Exp2.
  rewrite ![_ + dbound1 _ x2]addnC -[0]/(dbound1 [::] x1).
  move: rs1 ru1 p1 b1ru1 Exp1.
  have <-: iter i1 face x2 = x1.
    by rewrite -iter_add subnK // -nFx1 iter_face_arity.
  by apply: IHm => //; rewrite ?arity_iter_face ?leq_subr.
set x2 := iter i face x1 => rt2 rs2 ru2 p2 b1ru2 Exp2.
case: ifP => [lt_rt_nt _ | _ /andP[]].
  apply: leq_trans (leq_addl _ _); apply: leq_trans lt_rt_nt.
  by rewrite -add1n addnA !leq_add ?leq_b1 ?count_size.
case fit_r: (fitp x1 r); last by clear 1; apply: IHm; rewrite //= fit_r.
set p11 := meet_part p1 r; set p21 := rot_part i p11.
have Exp11: exact_fitp x1 p11 by apply: exact_fitp_meet.
have [/eqP Ep11 fit_p11] := andP Exp11; rewrite nFx1 in Ep11.
have Exp21: exact_fitp x2 p21 by rewrite -fitp_rot -?Ep11.
have [_ fit_p21] := andP Exp21 => check_p _; move: check_p.
rewrite (check_unfitP fit_p11) // (check_unfitP fit_p21) //=.
have{rt1} [dnt1 rt1] := sort_drulesP fit_p11 rt1.
have{rs1 fit_p11} [dns1 rs1] := sort_drulesP fit_p11 rs1.
have{rt2} [dnt2 rt2] := sort_drulesP fit_p21 rt2.
have{rs2 fit_p21} [dns2 rs2] := sort_drulesP fit_p21 rs2.
case Dnt1: (_ - _) => [|nt1]; first by move/redpP/negP/(_ Exp11).
have le_dn: dnt1 + dnt2 <= dns1 + (dns2 + nt) by rewrite ltnW // -subn_gt0 Dnt1.
move=> check_m; rewrite -addnA addnACA (addnACA dns1) add1n -ltn_subRL.
rewrite -addnA addnCA -[_ + nt]addnA -addnBA // Dnt1 addnS ltnS.
exact: IHm check_m.
Qed.

Fixpoint tally_hubcap (hc : hubcap) :=
  match hc with
  | Hubcap1 i _ hc' => incr_nth (tally_hubcap hc') i
  | Hubcap2 i j _ hc' => incr_nth (incr_nth (tally_hubcap hc') i) j
  | _ => [::]
  end.

Fixpoint hubcap_cover_rec (v : seq nat) (b : int) (hc : hubcap) : bool :=
  match hc with
  | Hubcap1 i b' hc' =>
    (nth 0 v i == 1) && hubcap_cover_rec v (b' *+ 2 + b) hc'
  | Hubcap2 i j b' hc' =>
    let n_i := nth 0 v i in let n_j := nth 0 v j in
    [&& n_i == n_j, n_i <= 2 & hubcap_cover_rec v (b' *+ (n_i == 1).+1 + b) hc']
  | Hubcap0 =>
    ~~ (0 < b)%R
  end.

Definition hubcap_cover hc :=
  let b := (dboundK nhub *+ 2 - 1)%R in
  let v := tally_hubcap hc in
  [&& size v == nhub, 0 \notin v & hubcap_cover_rec v b hc].

Definition hubcap_rot j := rot_part (if j is j'.+2 then j' else nhub + j - 2).

Lemma fit_hubcap_rot (x : G) p :
    arity x = nhub -> exact_fitp x p -> forall j, j < nhub ->
  exact_fitp (iter j face (inv_face2 x)) (hubcap_rot j p).
Proof.
move=> nFx fit_xp; have n_gt1: 1 < nhub by rewrite -nFx 3?ltnW ?pentaG.
have [/eqP Ep _] := andP fit_xp; rewrite nFx in Ep.
case=> [|[|j]] ltjn; rewrite -?iterSr.
- rewrite -(iter_face_arity x) nFx -(subnKC n_gt1) /hubcap_rot addn0.
  by rewrite /inv_face2 /= !faceK -fitp_rot -?Ep ?leq_subr.
- rewrite -(iter_face_arity x) nFx -(subnKC (ltnW n_gt1)) /hubcap_rot addn1.
  by rewrite subSS /inv_face2 /= nodeK faceK -fitp_rot -?Ep ?leq_subr.
by rewrite /hubcap_rot !iterSr !nodeK -fitp_rot -?Ep // 3?ltnW.
Qed.

Definition hub_subn i j := (if j <= i then i else i + nhub) - j.

Lemma hub_subn_hub i j : i < nhub -> hub_subn i j <= nhub.
Proof.
move=> ltin; rewrite leq_subLR ltnW //.
by have [leji | ltij] := leqP j i; rewrite (ltn_add2r, ltn_addl).
Qed.

Lemma iter_hub_subn i j :
     j < nhub -> forall x : G, arity x = nhub ->
  iter (hub_subn i j) face (iter j face x) = iter i face x.
Proof.
move=> ltjn x nFx; rewrite -iter_add subnK //; last first.
  by case: ifP => // _; rewrite ltnW ?ltn_addl.
by case: ifP => _ //;  rewrite iter_add -nFx iter_face_arity.
Qed.

Fixpoint hubcap_fit (p : part) (hc : hubcap) : bool :=
  match hc with
  | Hubcap1 j b hc' =>
    check_dbound2 (hubcap_rot j p) b && hubcap_fit p hc'
  | Hubcap2 j1 j2 b hc' =>
    check_2dbound2 (hubcap_rot j1 p) (hub_subn j2 j1) b && hubcap_fit p hc'
  | Hubcap0 =>
    true
  end.

Lemma hubcap_fit_bound (x : G) p hc :
    size_part p = nhub -> (0 < dscore x)%R ->
    hubcap_cover hc && hubcap_fit p hc ->
  ~~ exact_fitp x p.
Proof.
rewrite -!andbA; set v := tally_hubcap hc; set b0 := dboundK nhub.
move=> Ep pos_x /and4P[/eqP-Ev v'0 hc_v hc_p]; apply: contraL pos_x => Exp.
pose x1 := inv_face2 x; have x1Fx: cface x1 x by rewrite 2!cface1 !nodeK.
have nFx: arity x = nhub by rewrite -Ep; have [/eqP] := andP Exp.
have nFx1: arity x1 = nhub by rewrite (arity_cface x1Fx).
pose b (y : G) m := (dbound2 rt0 rs0 y *+ m)%R.
pose db2 w y (i := findex face x1 y) (w_i := nth 0 w i) (v_i := nth 0 v i) :=
  b y (if w_i > 1 then 2 else if w_i < 1 then 0 else (v_i == 1).+1).
pose sum_db2 w := (\sum_(y in cface x1) db2 w y)%R.
have{v'0} db2v: {in cface x1, forall y1, db2 v y1 = b y1 2}%R.
  move=> y x1Fy; congr (_ *+ _)%R; set i := findex face x1 y.
  have ltin: i < nhub by rewrite -nFx1 findex_max.
  by case: ltngtP; rewrite // ltnNge lt0n (memPn v'0) ?mem_nth ?Ev.
suffices{db2v}: ~~ (0 < b0 *+ 2 - 1 + sum_db2 v)%R.
  apply: contra => /(dscore_cap2 rf geoG nFx); rewrite -/rs0 -/rt0 -/b0.
  rewrite [sum_db2 _](eq_bigr _ db2v) sumrMnl (eq_bigl _ _ (same_cface x1Fx)).
  by rewrite addrAC subr_gt0 -mulrnDl -!lez_add1r (ler_muln2r 2 1%:Z).
pose vb w := forall i, nth 0 w i <= nth 0 v i.
have vb_inc w i : vb (incr_nth w i) -> nth 0 w i < nth 0 v i /\ vb w.
  move=> vb_w; split=> [|j]; first by have:= vb_w i; rewrite nth_incr_nth eqxx.
  by apply: leq_trans (vb_w j); rewrite nth_incr_nth leq_addl.
have db2_inc w i (v_i := nth 0 v i) (w' := incr_nth w i) :
    vb w' -> i < nhub -> v_i <= 2 ->
  sum_db2 w' = (b (iter i face x1) (v_i == 1)%N.+1 + sum_db2 w)%R.
- case/vb_inc; set w_i := nth 0 w i => lt_wvi _ ltin /(leq_trans lt_wvi)ub_wi.
  have ltix1: i < arity x1 by rewrite nFx1.
  rewrite 2![sum_db2 _](bigD1 _ (fconnect_iter _ i _)) addrA /= -mulrnDr.
  congr (_ *+ _ + _)%R; first rewrite findex_iter // nth_incr_nth eqxx /= -/w_i.
    by do [rewrite -/v_i; case: eqP w_i => [->|_] [|[|?]]] in lt_wvi ub_wi *.
  apply: eq_bigr => y /andP[x1Fy x1i'y]; congr (_ *+ _)%R; rewrite nth_incr_nth.
  by have [Di | //] := i =P _; rewrite Di iter_findex ?eqxx in x1i'y.
have: vb v by []; rewrite /v -ltr_subl_addl sub0r -lerNgt; clearbody v.
elim: hc {b0}(_ - 1)%R hc_v hc_p => /= [|i b1 hc IHhc|j i b1 hc IHhc] b0.
- by rewrite -lerNgt -oppr_ge0 [sum_db2 _]big1 // => y _; rewrite /db2 nth_nil.
- case/andP=> /eqP-Dvi v_hc /andP[p_b1 p_hc] vb_hci.
  have /vb_inc[_ vb_hc] := vb_hci.
  have [ltin | leni] := ltnP i nhub; last by rewrite nth_default ?Ev in Dvi.
  rewrite {}db2_inc ?Dvi {vb_hci}//= -ler_subr_addl -opprD addrC.
  apply: {IHhc vb_hc v_hc p_hc}(ler_trans (IHhc _ v_hc p_hc vb_hc)).
  rewrite ler_opp2 ler_add2r ler_pmuln2r //.
  by apply: check_dbound2P p_b1; rewrite ?arity_iter_face ?fit_hubcap_rot.
set vj := nth 0 v j => /and3P[/eqP-Dvi vj_le2] v_hc /andP[p_b1 p_hc] vb_hcij.
have /vb_inc[_ vb_hcj] := vb_hcij; have /vb_inc[vj_gt vb_hc] := vb_hcj.
have{vj_gt} vj_gt0: 0 < vj by apply: leq_trans vj_gt.
have [ltin | ?] := ltnP i nhub; last by rewrite Dvi nth_default ?Ev in vj_gt0.
have [ltjn | ?] := ltnP j nhub; last by rewrite [vj]nth_default ?Ev in vj_gt0.
rewrite !{}db2_inc -?Dvi {vb_hcij vb_hcj}//= addrA -ler_subr_addl -opprD -/vj.
apply: {IHhc v_hc p_hc vb_hc}(ler_trans (IHhc _ v_hc p_hc vb_hc)).
rewrite ler_opp2 addrC ler_add2r -mulrnDl ler_pmuln2r //.
rewrite addrC -(iter_hub_subn i ltjn) //.
apply: check_2dbound2P p_b1; rewrite ?arity_iter_face ?hub_subn_hub //.
by rewrite fit_hubcap_rot.
Qed.

End Hubcap.