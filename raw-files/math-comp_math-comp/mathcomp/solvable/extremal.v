
From mathcomp Require Import ssreflect ssrbool ssrfun eqtype ssrnat seq div.
From mathcomp Require Import choice fintype bigop finset prime binomial.
From mathcomp Require Import fingroup morphism perm automorphism presentation.
From mathcomp Require Import quotient action commutator gproduct gfunctor.
From mathcomp Require Import ssralg finalg zmodp cyclic pgroup center gseries.
From mathcomp Require Import nilpotent sylow abelian finmodule matrix maximal.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Local Open Scope ring_scope.
Import GroupScope GRing.Theory.

Reserved Notation "''Mod_' m" (at level 8, m at level 2, format "''Mod_' m").
Reserved Notation "''D_' m" (at level 8, m at level 2, format "''D_' m").
Reserved Notation "''SD_' m" (at level 8, m at level 2, format "''SD_' m").
Reserved Notation "''Q_' m" (at level 8, m at level 2, format "''Q_' m").

Module Extremal.

Section Construction.

Variables q p e : nat.
Let a : 'Z_p := Zp1.
Let b : 'Z_q := Zp1.
Local Notation B := <[b]>.

Definition aut_of :=
  odflt 1 [pick s in Aut B | p > 1 & (#[s] %| p) && (s b == b ^+ e)].

Lemma aut_dvdn : #[aut_of] %| #[a].
Proof.
rewrite order_Zp1 /aut_of; case: pickP => [s | _]; last by rewrite order1.
by case/and4P=> _ p_gt1 p_s _; rewrite Zp_cast.
Qed.

Definition act_morphism := eltm_morphism aut_dvdn.

Definition base_act := ([Aut B] \o act_morphism)%gact.

Lemma act_dom : <[a]> \subset act_dom base_act.
Proof.
rewrite cycle_subG 2!inE cycle_id /= eltm_id /aut_of.
by case: pickP => [op /andP[] | _] //=; rewrite group1.
Qed.

Definition gact := (base_act \ act_dom)%gact.
Fact gtype_key : unit. Proof. by []. Qed.
Definition gtype := locked_with gtype_key (sdprod_groupType gact).

Hypotheses (p_gt1 : p > 1) (q_gt1 : q > 1).

Lemma card : #|[set: gtype]| = (p * q)%N.
Proof.
rewrite [gtype]unlock -(sdprod_card (sdprod_sdpair _)).
rewrite !card_injm ?injm_sdpair1 ?injm_sdpair2 //.
by rewrite mulnC -!orderE !order_Zp1 !Zp_cast.
Qed.

Lemma Grp : (exists s, [/\ s \in Aut B, #[s] %| p & s b = b ^+ e]) ->
  [set: gtype] \isog Grp (x : y : (x ^+ q, y ^+ p, x ^ y = x ^+ e)).
Proof.
rewrite [gtype]unlock => [[s [AutBs dvd_s_p sb]]].
have memB: _ \in B by move=> c; rewrite -Zp_cycle inE.
have Aa: a \in <[a]> by rewrite !cycle_id.
have [oa ob]: #[a] = p /\ #[b] = q by rewrite !order_Zp1 !Zp_cast.
have def_s: aut_of = s.
  rewrite /aut_of; case: pickP => /= [t | ]; last first.
    by move/(_ s); case/and4P; rewrite sb.
  case/and4P=> AutBt _ _ tb; apply: (eq_Aut AutBt) => // b_i.
  case/cycleP=> i ->; rewrite -(autmE AutBt) -(autmE AutBs) !morphX //=.
  by rewrite !autmE // sb (eqP tb).
apply: intro_isoGrp => [|gT G].
  apply/existsP; exists (sdpair1 _ b, sdpair2 _ a); rewrite /= !xpair_eqE.
  rewrite -!morphim_cycle ?norm_joinEr ?im_sdpair ?im_sdpair_norm ?eqxx //=.
  rewrite -!order_dvdn !order_injm ?injm_sdpair1 ?injm_sdpair2 // oa ob !dvdnn.
  by rewrite -sdpair_act // [act _ _ _]apermE /= eltm_id -morphX // -sb -def_s.
case/existsP=> -[x y] /= /eqP[defG xq1 yp1 xy].
have fxP: #[x] %| #[b] by rewrite order_dvdn ob xq1.
have fyP: #[y] %| #[a] by rewrite order_dvdn oa yp1.
have fP: {in <[b]> & <[a]>, morph_act gact 'J (eltm fxP) (eltm fyP)}.
  move=> bj ai; case/cycleP=> j ->{bj}; case/cycleP=> i ->{ai}.
  rewrite /= !eltmE def_s gactX ?groupX // conjXg morphX //=; congr (_ ^+ j).
  rewrite /autact /= apermE; elim: i {j} => /= [|i IHi].
    by rewrite perm1 eltm_id conjg1.
  rewrite !expgS permM sb -(autmE (groupX i AutBs)) !morphX //= {}IHi.
  by rewrite -conjXg -xy -conjgM.
apply/homgP; exists (xsdprod_morphism fP).
rewrite im_xsdprodm !morphim_cycle //= !eltm_id -norm_joinEr //.
by rewrite norms_cycle xy mem_cycle.
Qed.

End Construction.

End Extremal.

Section SpecializeExtremals.

Import Extremal.

Variable m : nat.
Let p := pdiv m.
Let q := m %/ p.

Definition modular_gtype := gtype q p (q %/ p).+1.
Definition dihedral_gtype := gtype q 2 q.-1.
Definition semidihedral_gtype := gtype q 2 (q %/ p).-1.
Definition quaternion_kernel :=
  <<[set u | u ^+ 2 == 1] :\: [set u ^+ 2 | u in [set: gtype q 4 q.-1]]>>.
Definition quaternion_gtype :=
  locked_with gtype_key (coset_groupType quaternion_kernel).

End SpecializeExtremals.

Notation "''Mod_' m" := (modular_gtype m) : type_scope.
Notation "''Mod_' m" := [set: gsort 'Mod_m] : group_scope.
Notation "''Mod_' m" := [set: gsort 'Mod_m]%G : Group_scope.

Notation "''D_' m" := (dihedral_gtype m) : type_scope.
Notation "''D_' m" := [set: gsort 'D_m] : group_scope.
Notation "''D_' m" := [set: gsort 'D_m]%G : Group_scope.

Notation "''SD_' m" := (semidihedral_gtype m) : type_scope.
Notation "''SD_' m" := [set: gsort 'SD_m] : group_scope.
Notation "''SD_' m" := [set: gsort 'SD_m]%G : Group_scope.

Notation "''Q_' m" := (quaternion_gtype m) : type_scope.
Notation "''Q_' m" := [set: gsort 'Q_m] : group_scope.
Notation "''Q_' m" := [set: gsort 'Q_m]%G : Group_scope.

Section ExtremalTheory.

Implicit Types (gT : finGroupType) (p q m n : nat).

Lemma cyclic_pgroup_Aut_structure gT p (G : {group gT}) :
    p.-group G -> cyclic G -> G :!=: 1 ->
  let q := #|G| in let n := (logn p q).-1 in
  let A := Aut G in let P := 'O_p(A) in let F := 'O_p^'(A) in
  exists m : {perm gT} -> 'Z_q,
  [/\ [/\ {in A & G, forall a x, x ^+ m a = a x},
          m 1 = 1%R /\ {in A &, {morph m : a b / a * b >-> (a * b)%R}},
          {in A &, injective m} /\ image m A =i GRing.unit,
          forall k, {in A, {morph m : a / a ^+ k >-> (a ^+ k)%R}}
        & {in A, {morph m : a / a^-1 >-> (a^-1)%R}}],
      [/\ abelian A, cyclic F, #|F| = p.-1
        & [faithful F, on 'Ohm_1(G) | [Aut G]]]
    & if n == 0%N then A = F else
      exists t, [/\ t \in A, #[t] = 2, m t = - 1%R
      & if odd p then
        [/\ cyclic A /\ cyclic P,
           exists s, [/\ s \in A, #[s] = (p ^ n)%N, m s = p.+1%:R & P = <[s]>]
         & exists s0, [/\ s0 \in A, #[s0] = p, m s0 = (p ^ n).+1%:R
                        & 'Ohm_1(P) = <[s0]>]]
   else if n == 1%N then A = <[t]>
   else exists s,
        [/\ s \in A, #[s] = (2 ^ n.-1)%N, m s = 5%:R, <[s]> \x <[t]> = A
      & exists s0, [/\ s0 \in A, #[s0] = 2, m s0 = (2 ^ n).+1%:R,
                       m (s0 * t) = (2 ^ n).-1%:R & 'Ohm_1(<[s]>) = <[s0]>]]]].
Proof.
move=> pG cycG ntG q n0 A P F; have [p_pr p_dvd_G [n oG]] := pgroup_pdiv pG ntG.
have [x0 defG] := cyclicP cycG; have Gx0: x0 \in G by rewrite defG cycle_id.
rewrite {1}/q oG pfactorK //= in n0 *; rewrite {}/n0.
have [p_gt1 min_p] := primeP p_pr; have p_gt0 := ltnW p_gt1.
have q_gt1: q > 1 by rewrite cardG_gt1.
have cAA: abelian A := Aut_cyclic_abelian cycG; have nilA := abelian_nil cAA.
have oA: #|A| = (p.-1 * p ^ n)%N.
  by rewrite card_Aut_cyclic // oG totient_pfactor.
have [sylP hallF]: p.-Sylow(A) P /\ p^'.-Hall(A) F.
  by rewrite !nilpotent_pcore_Hall.
have [defPF tiPF]: P * F = A /\ P :&: F = 1.
  by case/dprodP: (nilpotent_pcoreC p nilA).
have oP: #|P| = (p ^ n)%N.
  by rewrite (card_Hall sylP) oA p_part logn_Gauss ?coprimenP ?pfactorK.
have oF: #|F| = p.-1.
  apply/eqP; rewrite -(@eqn_pmul2l #|P|) ?cardG_gt0 // -TI_cardMg // defPF.
  by rewrite oA oP mulnC.
have [m' [inj_m' defA def_m']]: exists m' : {morphism units_Zp q >-> {perm gT}},
  [/\ 'injm m', m' @* setT = A & {in G, forall x u, m' u x = x ^+ val u}].
- rewrite /A /q defG; exists (Zp_unit_morphism x0).
  by have [->]:= isomP (Zp_unit_isom x0); split=> // y Gy u; rewrite permE Gy.
pose m (a : {perm gT}) : 'Z_q := val (invm inj_m' a).
have{def_m'} def_m: {in A & G, forall a x, x ^+ m a = a x}.
  by move=> a x Aa Gx /=; rewrite -{2}[a](invmK inj_m') ?defA ?def_m'.
have m1: m 1 = 1%R by rewrite /m morph1.
have mM: {in A &, {morph m : a b / a * b >-> (a * b)%R}}.
  by move=> a b Aa Ab; rewrite /m morphM ?defA.
have mX k: {in A, {morph m : a / a ^+ k >-> (a ^+ k)%R}}.
  by elim: k => // k IHk a Aa; rewrite expgS exprS mM ?groupX ?IHk.
have inj_m: {in A &, injective m}.
  apply: can_in_inj (fun u => m' (insubd (1 : {unit 'Z_q}) u)) _ => a Aa.
  by rewrite valKd invmK ?defA.
have{defA} im_m: image m A =i GRing.unit.
  move=> u; apply/imageP/idP=> [[a Aa ->]| Uu]; first exact: valP.
  exists (m' (Sub u Uu)) => /=; first by rewrite -defA mem_morphim ?inE.
  by rewrite /m invmE ?inE.
have mV: {in A, {morph m : a / a^-1 >-> (a^-1)%R}}.
  move=> a Aa /=; rewrite -div1r; apply: canRL (mulrK (valP _)) _.
  by rewrite -mM ?groupV ?mulVg.
have inv_m (u : 'Z_q) : coprime q u -> {a | a \in A & m a = u}.
  rewrite -?unitZpE // natr_Zp -im_m => m_u.
  by exists (iinv m_u); [apply: mem_iinv | rewrite f_iinv].
have [cycF ffulF]: cyclic F /\ [faithful F, on 'Ohm_1(G) | [Aut G]].
  have Um0 a: ((m a)%:R : 'F_p) \in GRing.unit.
    have: m a \in GRing.unit by apply: valP.
    by rewrite -{1}[m a]natr_Zp unitFpE ?unitZpE // {1}/q oG coprime_pexpl.
  pose fm0 a := FinRing.unit 'F_p (Um0 a).
  have natZqp u: (u%:R : 'Z_q)%:R = u %:R :> 'F_p.
    by rewrite val_Zp_nat // -Fp_nat_mod // modn_dvdm ?Fp_nat_mod.
  have m0M: {in A &, {morph fm0 : a b / a * b}}.
    move=> a b Aa Ab; apply: val_inj; rewrite /= -natrM mM //.
    by rewrite -[(_ * _)%R]Zp_nat natZqp.
  pose m0 : {morphism A >-> {unit 'F_p}} := Morphism m0M.
  have im_m0: m0 @* A = [set: {unit 'F_p}].
    apply/setP=> [[/= u Uu]]; rewrite in_setT morphimEdom; apply/imsetP.
    have [|a Aa m_a] := inv_m u%:R.
      by rewrite {1}[q]oG coprime_pexpl // -unitFpE // natZqp natr_Zp.
    by exists a => //; apply: val_inj; rewrite /= m_a natZqp natr_Zp.
  have [x1 defG1]: exists x1, 'Ohm_1(G) = <[x1]>.
    by apply/cyclicP; apply: cyclicS (Ohm_sub _ _) cycG.
  have ox1: #[x1] = p by rewrite orderE -defG1 (Ohm1_cyclic_pgroup_prime _ pG).
  have Gx1: x1 \in G by rewrite -cycle_subG -defG1 Ohm_sub.
  have ker_m0: 'ker m0 = 'C('Ohm_1(G) | [Aut G]).
    apply/setP=> a; rewrite inE in_setI; apply: andb_id2l => Aa.
    rewrite 3!inE /= -2!val_eqE /= val_Fp_nat // [1 %% _]modn_small // defG1.
    apply/idP/subsetP=> [ma1 x1i | ma1].
      case/cycleP=> i ->{x1i}; rewrite inE gactX // -[_ a]def_m //.
      by rewrite -(expg_mod_order x1) ox1 (eqP ma1).
    have:= ma1 x1 (cycle_id x1); rewrite inE -[_ a]def_m //.
    by rewrite (eq_expg_mod_order x1 _ 1) ox1 (modn_small p_gt1).
  have card_units_Fp: #|[set: {unit 'F_p}]| = p.-1.
    by rewrite card_units_Zp // pdiv_id // (@totient_pfactor p 1) ?muln1.
  have ker_m0_P: 'ker m0 = P.
    apply: nilpotent_Hall_pcore nilA _.
    rewrite pHallE -(card_Hall sylP) oP subsetIl /=.
    rewrite -(@eqn_pmul2r #|m0 @* A|) ?cardG_gt0 //; apply/eqP.
    rewrite -{1}(card_isog (first_isog _)) card_quotient ?ker_norm //.
    by rewrite Lagrange ?subsetIl // oA im_m0 mulnC card_units_Fp.
  have inj_m0: 'ker_F m0 \subset [1] by rewrite setIC ker_m0_P tiPF.
  split; last by rewrite /faithful -ker_m0.
  have isogF: F \isog [set: {unit 'F_p}].
    have sFA: F \subset A by apply: pcore_sub.
    apply/isogP; exists (restrm_morphism sFA m0); first by rewrite ker_restrm.
    apply/eqP; rewrite eqEcard subsetT card_injm ?ker_restrm //= oF.
    by rewrite card_units_Fp.
  rewrite (isog_cyclic isogF) pdiv_id // -ox1 (isog_cyclic (Zp_unit_isog x1)).
  by rewrite Aut_prime_cyclic // -orderE ox1.
exists m; split=> {im_m mV}//; have [n0 | n_gt0] := posnP n.
  by apply/eqP; rewrite eq_sym eqEcard pcore_sub oF oA n0 muln1 /=.
have [t At mt]: {t | t \in A & m t = -1}.
  apply: inv_m; rewrite /= Zp_cast // coprime_modr modn_small // subn1.
  by rewrite coprimenP // ltnW.
have ot: #[t] = 2.
  apply/eqP; rewrite eqn_leq order_gt1 dvdn_leq ?order_dvdn //=.
    apply/eqP; move/(congr1 m); apply/eqP; rewrite mt m1 eq_sym -subr_eq0.
    rewrite opprK -val_eqE /= Zp_cast ?modn_small // /q oG ltnW //.
    by rewrite (leq_trans (_ : 2 ^ 2 <= p ^ 2)) ?leq_sqr ?leq_exp2l.
  by apply/eqP; apply: inj_m; rewrite ?groupX ?group1 ?mX // mt -signr_odd.
exists t; split=> //.
case G4: (~~ odd p && (n == 1%N)).
  case: (even_prime p_pr) G4 => [p2 | -> //]; rewrite p2 /=; move/eqP=> n1.
  rewrite n1 /=; apply/eqP; rewrite eq_sym eqEcard cycle_subG At /=.
  by rewrite -orderE oA ot p2 n1.
pose e0 : nat := ~~ odd p.
have{inv_m} [s As ms]: {s | s \in A & m s = (p ^ e0.+1).+1%:R}.
  apply: inv_m; rewrite val_Zp_nat // coprime_modr /q oG coprime_pexpl //.
  by rewrite -(@coprime_pexpl e0.+1) // coprimenS.
have lt_e0_n: e0 < n.
  by rewrite /e0; case: (~~ _) G4 => //=; rewrite ltn_neqAle eq_sym => ->.
pose s0 := s ^+ (p ^ (n - e0.+1)).
have [ms0 os0]: m s0 = (p ^ n).+1%:R /\ #[s0] = p.
  have m_se e:
    exists2 k, k = 1 %[mod p] & m (s ^+ (p ^ e)) = (k * p ^ (e + e0.+1)).+1%:R.
  - elim: e => [|e [k k1 IHe]]; first by exists 1%N; rewrite ?mul1n.
    rewrite expnSr expgM mX ?groupX // {}IHe -natrX -(add1n (k * _)).
    rewrite expnDn -(prednK p_gt0) 2!big_ord_recl /= prednK // !exp1n bin1.
    rewrite bin0 muln1 mul1n mulnCA -expnS (addSn e).
    set f := (e + _)%N; set sum := (\sum_i _)%N.
    exists (sum %/ p ^ f.+2 * p + k)%N; first by rewrite modnMDl.
    rewrite -(addnC k) mulnDl -mulnA -expnS divnK // {}/sum.
    apply big_ind => [||[i _] /= _]; [exact: dvdn0 | exact: dvdn_add |].
    rewrite exp1n mul1n /bump !add1n expnMn mulnCA dvdn_mull // -expnM.
    case: (ltnP f.+1 (f * i.+2)) => [le_f_fi|].
      by rewrite dvdn_mull ?dvdn_exp2l.
    rewrite {1}mulnS -(addn1 f) leq_add2l {}/f addnS /e0.
    case: i e => [] // [] //; case odd_p: (odd p) => //= _.
    by rewrite bin2odd // mulnAC dvdn_mulr.
  have [[|d]] := m_se (n - e0.+1)%N; first by rewrite mod0n modn_small.
  move/eqP; rewrite -/s0 eqn_mod_dvd ?subn1 //=; case/dvdnP=> f -> {d}.
  rewrite subnK // mulSn -mulnA -expnS -addSn natrD natrM -oG char_Zp //.
  rewrite mulr0 addr0 => m_s0; split => //.
  have [d _] := m_se (n - e0)%N; rewrite -subnSK // expnSr expgM -/s0.
  rewrite addSn subnK // -oG  mulrS natrM char_Zp // {d}mulr0 addr0.
  move/eqP; rewrite -m1 (inj_in_eq inj_m) ?group1 ?groupX // -order_dvdn.
  move/min_p; rewrite order_eq1; case/predU1P=> [s0_1 | ]; last by move/eqP.
  move/eqP: m_s0; rewrite eq_sym s0_1 m1 -subr_eq0 mulrSr addrK -val_eqE /=.
  have pf_gt0: p ^ _ > 0 by move=> e; rewrite expn_gt0 p_gt0.
  by rewrite val_Zp_nat // /q oG [_ == _]pfactor_dvdn // pfactorK ?ltnn.
have os: #[s] = (p ^ (n - e0))%N.
  have: #[s] %| p ^ (n - e0).
    by rewrite order_dvdn -subnSK // expnSr expgM -order_dvdn os0.
  case/dvdn_pfactor=> // d; rewrite leq_eqVlt.
  case/predU1P=> [-> // | lt_d os]; case/idPn: (p_gt1); rewrite -os0.
  by rewrite order_gt1 negbK -order_dvdn os dvdn_exp2l // -ltnS -subSn.
have p_s: p.-elt s by rewrite /p_elt os pnat_exp ?pnat_id.
have defS1: 'Ohm_1(<[s]>) = <[s0]>.
  apply/eqP; rewrite eq_sym eqEcard cycle_subG -orderE os0.
  rewrite (Ohm1_cyclic_pgroup_prime _ p_s) ?cycle_cyclic ?leqnn ?cycle_eq1 //=.
    rewrite (OhmE _ p_s) mem_gen ?groupX //= !inE mem_cycle //.
    by rewrite -order_dvdn os0 ?dvdnn.
  by apply/eqP=> s1; rewrite -os0 /s0 s1 expg1n order1 in p_gt1.
case: (even_prime p_pr) => [p2 | oddp]; last first.
  rewrite {+}/e0 oddp subn0 in s0 os0 ms0 os ms defS1 *.
  have [f defF] := cyclicP cycF; have defP: P = <[s]>.
    apply/eqP; rewrite eq_sym eqEcard -orderE oP os leqnn andbT.
    by rewrite cycle_subG (mem_normal_Hall sylP) ?pcore_normal.
  rewrite defP; split; last 1 [by exists s | by exists s0; rewrite ?groupX].
  rewrite -defPF defP defF -cycleM ?cycle_cyclic // /order.
    by red; rewrite (centsP cAA) // -cycle_subG -defF pcore_sub.
  by rewrite -defF -defP (pnat_coprime (pcore_pgroup _ _) (pcore_pgroup _ _)).
rewrite {+}/e0 p2 subn1 /= in s0 os0 ms0 os ms G4 defS1 lt_e0_n *.
rewrite G4; exists s; split=> //; last first.
  exists s0; split; rewrite ?groupX //; apply/eqP; rewrite mM ?groupX //.
  rewrite ms0 mt eq_sym mulrN1 -subr_eq0 opprK -natrD -addSnnS.
  by rewrite prednK ?expn_gt0 // addnn -mul2n -expnS -p2 -oG char_Zp.
suffices TIst: <[s]> :&: <[t]> = 1.
  rewrite dprodE //; last by rewrite (sub_abelian_cent2 cAA) ?cycle_subG.
  apply/eqP; rewrite eqEcard mulG_subG !cycle_subG As At oA.
  by rewrite TI_cardMg // -!orderE os ot p2 mul1n /= -expnSr prednK.
rewrite setIC; apply: prime_TIg; first by rewrite -orderE ot.
rewrite cycle_subG; apply/negP=> St.
have: t \in <[s0]>.
  by rewrite -defS1 (OhmE _ p_s) mem_gen // !inE St -order_dvdn ot p2.
have ->: <[s0]> = [set 1; s0].
  apply/eqP; rewrite eq_sym eqEcard subUset !sub1set group1 cycle_id /=.
  by rewrite -orderE cards2 eq_sym -order_gt1 os0.
rewrite !inE -order_eq1 ot /=; move/eqP; move/(congr1 m); move/eqP.
rewrite mt ms0 eq_sym -subr_eq0 opprK -mulrSr.
rewrite -val_eqE [val _]val_Zp_nat //= /q oG p2 modn_small //.
by rewrite -addn3 expnS mul2n -addnn leq_add2l (ltn_exp2l 1).
Qed.

Definition extremal_generators gT (A : {set gT}) p n xy :=
  let: (x, y) := xy in
  [/\ #|A| = (p ^ n)%N, x \in A, #[x] = (p ^ n.-1)%N & y \in A :\: <[x]>].

Lemma extremal_generators_facts gT (G : {group gT}) p n x y :
    prime p -> extremal_generators G p n (x, y) ->
  [/\ p.-group G, maximal <[x]> G, <[x]> <| G,
      <[x]> * <[y]> = G & <[y]> \subset 'N(<[x]>)].
Proof.
move=> p_pr [oG Gx ox] /setDP[Gy notXy].
have pG: p.-group G by rewrite /pgroup oG pnat_exp pnat_id.
have maxX: maximal <[x]> G.
  rewrite p_index_maximal -?divgS ?cycle_subG // -orderE oG ox.
  case: (n) oG => [|n' _]; last by rewrite -expnB ?subSnn ?leqnSn ?prime_gt0.
  move/eqP; rewrite -trivg_card1; case/trivgPn.
  by exists y; rewrite // (group1_contra notXy).
have nsXG := p_maximal_normal pG maxX; split=> //.
  by apply: mulg_normal_maximal; rewrite ?cycle_subG.
by rewrite cycle_subG (subsetP (normal_norm nsXG)).
Qed.

Section ModularGroup.

Variables p n : nat.
Let m := (p ^ n)%N.
Let q := (p ^ n.-1)%N.
Let r := (p ^ n.-2)%N.

Hypotheses (p_pr : prime p) (n_gt2 : n > 2).
Let p_gt1 := prime_gt1 p_pr.
Let p_gt0 := ltnW p_gt1.
Let def_n := esym (subnKC n_gt2).
Let def_p : pdiv m = p. Proof. by rewrite /m def_n pdiv_pfactor. Qed.
Let def_q : m %/ p = q. Proof. by rewrite /m /q def_n expnS mulKn. Qed.
Let def_r : q %/ p = r. Proof. by rewrite /r /q def_n expnS mulKn. Qed.
Let ltqm : q < m. Proof. by rewrite ltn_exp2l // def_n. Qed.
Let ltrq : r < q. Proof. by rewrite ltn_exp2l // def_n. Qed.
Let r_gt0 : 0 < r. Proof. by rewrite expn_gt0 ?p_gt0. Qed.
Let q_gt1 : q > 1. Proof. exact: leq_ltn_trans r_gt0 ltrq. Qed.

Lemma card_modular_group : #|'Mod_(p ^ n)| = (p ^ n)%N.
Proof. by rewrite Extremal.card def_p ?def_q // -expnS def_n. Qed.

Lemma Grp_modular_group :
  'Mod_(p ^ n) \isog Grp (x : y : (x ^+ q, y ^+ p, x ^ y = x ^+ r.+1)).
Proof.
rewrite /modular_gtype def_p def_q def_r; apply: Extremal.Grp => //.
set B := <[_]>; have Bb: Zp1 \in B by apply: cycle_id.
have oB: #|B| = q by rewrite -orderE order_Zp1 Zp_cast.
have cycB: cyclic B by rewrite cycle_cyclic.
have pB: p.-group B by rewrite /pgroup oB pnat_exp ?pnat_id.
have ntB: B != 1 by rewrite -cardG_gt1 oB.
have [] := cyclic_pgroup_Aut_structure pB cycB ntB.
rewrite oB pfactorK //= -/B -(expg_znat r.+1 Bb) oB => mB [[def_mB _ _ _ _] _].
rewrite {1}def_n /= => [[t [At ot mBt]]].
have [p2 | ->] := even_prime p_pr; last first.
  by case=> _ _ [s [As os mBs _]]; exists s; rewrite os -mBs def_mB.
rewrite {1}p2 /= -2!eqSS -addn2 -2!{1}subn1 -subnDA subnK 1?ltnW //.
case: eqP => [n3 _ | _ [_ [_ _ _ _ [s [As os mBs _ _]{t At ot mBt}]]]].
  by exists t; rewrite At ot -def_mB // mBt /q /r p2 n3.
by exists s; rewrite As os -def_mB // mBs /r p2.
Qed.

Definition modular_group_generators gT (xy : gT * gT) :=
  let: (x, y) := xy in #[y] = p /\ x ^ y = x ^+ r.+1.

Lemma generators_modular_group gT (G : {group gT}) :
    G \isog 'Mod_m ->
  exists2 xy, extremal_generators G p n xy & modular_group_generators xy.
Proof.
case/(isoGrpP _ Grp_modular_group); rewrite card_modular_group // -/m => oG.
case/existsP=> -[x y] /= /eqP[defG xq yp xy].
rewrite norm_joinEr ?norms_cycle ?xy ?mem_cycle // in defG.
have [Gx Gy]: x \in G /\ y \in G.
  by apply/andP; rewrite -!cycle_subG -mulG_subG defG.
have notXy: y \notin <[x]>.
  apply: contraL ltqm; rewrite -cycle_subG -oG -defG; move/mulGidPl->.
  by rewrite -leqNgt dvdn_leq ?(ltnW q_gt1) // order_dvdn xq.
have oy: #[y] = p by apply: nt_prime_order (group1_contra notXy).
exists (x, y) => //=; split; rewrite ?inE ?notXy //.
apply/eqP; rewrite -(eqn_pmul2r p_gt0) -expnSr -{1}oy (ltn_predK n_gt2) -/m.
by rewrite -TI_cardMg ?defG ?oG // setIC prime_TIg ?cycle_subG // -orderE oy.
Qed.

Lemma modular_group_structure gT (G : {group gT}) x y :
    extremal_generators G p n (x, y) ->
    G \isog 'Mod_m -> modular_group_generators (x, y) ->
  let X := <[x]> in
  [/\ [/\ X ><| <[y]> = G, ~~ abelian G
        & {in X, forall z j, z ^ (y ^+ j) = z ^+ (j * r).+1}],
      [/\ 'Z(G) = <[x ^+ p]>, 'Phi(G) = 'Z(G) & #|'Z(G)| = r],
      [/\ G^`(1) = <[x ^+ r]>, #|G^`(1)| = p & nil_class G = 2],
      forall k, k > 0 -> 'Mho^k(G) = <[x ^+ (p ^ k)]>
    & if (p, n) == (2, 3) then 'Ohm_1(G) = G else
      forall k, 0 < k < n.-1 ->
         <[x ^+ (p ^ (n - k.+1))]> \x <[y]> = 'Ohm_k(G)
      /\ #|'Ohm_k(G)| = (p ^ k.+1)%N].
Proof.
move=> genG isoG [oy xy] X.
have [oG Gx ox /setDP[Gy notXy]] := genG; rewrite -/m -/q in ox oG.
have [pG _ nsXG defXY nXY] := extremal_generators_facts p_pr genG.
have [sXG nXG] := andP nsXG; have sYG: <[y]> \subset G by rewrite cycle_subG.
have n1_gt1: n.-1 > 1 by [rewrite def_n]; have n1_gt0 := ltnW n1_gt1.
have def_n1 := prednK n1_gt0.
have def_m: (q * p)%N = m by rewrite -expnSr /m def_n.
have notcxy: y \notin 'C[x].
  apply: contraL (introT eqP xy); move/cent1P=> cxy.
  rewrite /conjg -cxy // eq_mulVg1 expgS !mulKg -order_dvdn ox.
  by rewrite pfactor_dvdn ?expn_gt0 ?p_gt0 // pfactorK // -ltnNge prednK.
have tiXY: <[x]> :&: <[y]> = 1.
  rewrite setIC prime_TIg -?orderE ?oy //; apply: contra notcxy.
  by rewrite cycle_subG; apply: subsetP; rewrite cycle_subG cent1id.
have notcGG: ~~ abelian G.
  by rewrite -defXY abelianM !cycle_abelian cent_cycle cycle_subG.
have cXpY: <[y]> \subset 'C(<[x ^+ p]>).
  rewrite cent_cycle cycle_subG cent1C (sameP cent1P commgP) /commg conjXg xy.
  by rewrite -expgM mulSn expgD mulKg -expnSr def_n1 -/q -ox expg_order.
have oxp: #[x ^+ p] = r by rewrite orderXdiv ox ?dvdn_exp //.
have [sZG nZG] := andP (center_normal G).
have defZ: 'Z(G) = <[x ^+ p]>.
  apply/eqP; rewrite eq_sym eqEcard subsetI -{2}defXY centM subsetI cent_cycle.
  rewrite 2!cycle_subG !groupX ?cent1id //= centsC cXpY /= -orderE oxp leqNgt.
  apply: contra notcGG => gtZr; apply: cyclic_center_factor_abelian.
  rewrite (dvdn_prime_cyclic p_pr) // card_quotient //.
  rewrite -(dvdn_pmul2l (cardG_gt0 'Z(G))) Lagrange // oG -def_m dvdn_pmul2r //.
  case/p_natP: (pgroupS sZG pG) gtZr => k ->.
  by rewrite ltn_exp2l // def_n1; apply: dvdn_exp2l.
have Zxr: x ^+ r \in 'Z(G) by rewrite /r def_n expnS expgM defZ mem_cycle.
have rxy: [~ x, y] = x ^+ r by rewrite /commg xy expgS mulKg.
have defG': G^`(1) = <[x ^+ r]>.
  case/setIP: Zxr => _; rewrite -rxy -defXY -(norm_joinEr nXY).
  exact: der1_joing_cycles.
have oG': #|G^`(1)| = p.
  by rewrite defG' -orderE orderXdiv ox /q -def_n1 ?dvdn_exp2l // expnS mulnK.
have sG'Z: G^`(1) \subset 'Z(G) by rewrite defG' cycle_subG.
have nil2_G: nil_class G = 2.
  by apply/eqP; rewrite eqn_leq andbC ltnNge nil_class1 notcGG nil_class2.
have XYp: {in X & <[y]>, forall z t,
   (z * t) ^+ p \in z ^+ p *: <[x ^+ r ^+ 'C(p, 2)]>}.
- move=> z t Xz Yt; have Gz := subsetP sXG z Xz; have Gt := subsetP sYG t Yt.
  have Rtz: [~ t, z] \in G^`(1) by apply: mem_commg.
  have cGtz: [~ t, z] \in 'C(G) by case/setIP: (subsetP sG'Z _ Rtz).
  rewrite expMg_Rmul /commute ?(centP cGtz) //.
  have ->: t ^+ p = 1 by apply/eqP; rewrite -order_dvdn -oy order_dvdG.
  rewrite defG' in Rtz; case/cycleP: Rtz => i ->.
  by rewrite mem_lcoset mulg1 mulKg expgAC mem_cycle.
have defMho: 'Mho^1(G) = <[x ^+ p]>.
  apply/eqP; rewrite eqEsubset cycle_subG (Mho_p_elt 1) ?(mem_p_elt pG) //.
  rewrite andbT (MhoE 1 pG) gen_subG -defXY; apply/subsetP=> ztp.
  case/imsetP=> zt; case/imset2P=> z t Xz Yt -> -> {zt ztp}.
  apply: subsetP (XYp z t Xz Yt); case/cycleP: Xz => i ->.
  by rewrite expgAC mul_subG ?sub1set ?mem_cycle //= -defZ cycle_subG groupX.
split=> //; try exact: extend_cyclic_Mho.
- rewrite sdprodE //; split=> // z; case/cycleP=> i ->{z} j.
  rewrite conjXg -expgM mulnC expgM actX; congr (_ ^+ i).
  elim: j {i} => //= j ->; rewrite conjXg xy -!expgM mulnS mulSn addSn.
  rewrite addnA -mulSn -addSn expgD mulnCA (mulnC j).
  rewrite {3}/r def_n expnS mulnA -expnSr def_n1 -/q -ox -mulnA expgM.
  by rewrite expg_order expg1n mulg1.
- by rewrite (Phi_joing pG) defMho -defZ (joing_idPr _) ?defZ.
have G1y: y \in 'Ohm_1(G).
  by rewrite (OhmE _ pG) mem_gen // !inE Gy -order_dvdn oy /=.
case: eqP => [[p2 n3] | notG8 k]; last case/andP=> k_gt0 lt_k_n1.
  apply/eqP; rewrite eqEsubset Ohm_sub -{1}defXY mulG_subG !cycle_subG.
  rewrite G1y -(groupMr _ G1y) /= (OhmE _ pG) mem_gen // !inE groupM //.
  rewrite /q /r p2 n3 in oy ox xy *.
  by rewrite expgS -mulgA -{1}(invg2id oy) -conjgE xy -expgS -order_dvdn ox.
have le_k_n2: k <= n.-2 by rewrite -def_n1 in lt_k_n1.
suffices{lt_k_n1} defGk: <[x ^+ (p ^ (n - k.+1))]> \x <[y]> = 'Ohm_k(G).
  split=> //; case/dprodP: defGk => _ <- _ tiXkY; rewrite expnSr TI_cardMg //.
  rewrite -!orderE oy (subnDA 1) subn1 orderXdiv ox ?dvdn_exp2l ?leq_subr //.
  by rewrite /q -{1}(subnK (ltnW lt_k_n1)) expnD mulKn // expn_gt0 p_gt0.
suffices{k k_gt0 le_k_n2} defGn2: <[x ^+ p]> \x <[y]> = 'Ohm_(n.-2)(G).
  have:= Ohm_dprod k defGn2; have p_xp := mem_p_elt pG (groupX p Gx).
  rewrite (Ohm_p_cycle _ p_xp) (Ohm_p_cycle _ (mem_p_elt pG Gy)) oxp oy.
  rewrite pfactorK ?(pfactorK 1) // (eqnP k_gt0) expg1 -expgM -expnS.
  rewrite -subSn // -subSS def_n1 def_n => -> /=; rewrite subnSK // subn2.
  by apply/eqP; rewrite eqEsubset OhmS ?Ohm_sub //= -{1}Ohm_id OhmS ?Ohm_leq.
rewrite dprodEY //=; last by apply/trivgP; rewrite -tiXY setSI ?cycleX.
apply/eqP; rewrite eqEsubset join_subG !cycle_subG /= {-2}(OhmE _ pG) -/r.
rewrite def_n (subsetP (Ohm_leq G (ltn0Sn _))) // mem_gen /=; last first.
  by rewrite !inE -order_dvdn oxp groupX /=.
rewrite gen_subG /= cent_joinEr // -defXY; apply/subsetP=> uv; case/setIP.
case/imset2P=> u v Xu Yv ->{uv}; rewrite /r inE def_n expnS expgM.
case/lcosetP: (XYp u v Xu Yv) => _ /cycleP[j ->] ->.
case/cycleP: Xu => i ->{u}; rewrite -!(expgM, expgD) -order_dvdn ox.
rewrite (mulnC r) /r {1}def_n expnSr mulnA -mulnDl -mulnA -expnS.
rewrite subnSK  // subn2 /q -def_n1 expnS dvdn_pmul2r // dvdn_addl.
  by case/dvdnP=> k ->; rewrite mulnC expgM mem_mulg ?mem_cycle.
case: (ltngtP n 3) => [|n_gt3|n3]; first by rewrite ltnNge n_gt2.
  by rewrite -subnSK // expnSr mulnA dvdn_mull.
case: (even_prime p_pr) notG8 => [-> | oddp _]; first by rewrite n3.
by rewrite bin2odd // -!mulnA dvdn_mulr.
Qed.

End ModularGroup.

Section DihedralGroup.

Variable q : nat.
Hypothesis q_gt1 : q > 1.
Let m := q.*2.

Let def2 : pdiv m = 2.
Proof.
apply/eqP; rewrite /m -mul2n eqn_leq pdiv_min_dvd ?dvdn_mulr //.
by rewrite prime_gt1 // pdiv_prime // (@leq_pmul2l 2 1) ltnW.
Qed.

Let def_q : m %/ pdiv m = q. Proof. by rewrite def2 divn2 half_double. Qed.

Section Dihedral_extension.

Variable p : nat.
Hypotheses (p_gt1 : p > 1) (even_p : 2 %| p).
Local Notation ED := [set: gsort (Extremal.gtype q p q.-1)].

Lemma card_ext_dihedral : #|ED| = (p./2 * m)%N.
Proof. by rewrite Extremal.card // /m -mul2n -divn2 mulnA divnK. Qed.

Lemma Grp_ext_dihedral : ED \isog Grp (x : y : (x ^+ q, y ^+ p, x ^ y = x^-1)).
Proof.
suffices isoED: ED \isog Grp (x : y : (x ^+ q, y ^+ p, x ^ y = x ^+ q.-1)).
  move=> gT G; rewrite isoED.
  apply: eq_existsb => [[x y]] /=; rewrite !xpair_eqE.
  congr (_ && _); apply: andb_id2l; move/eqP=> xq1; congr (_ && (_ == _)).
  by apply/eqP; rewrite eq_sym eq_invg_mul -expgS (ltn_predK q_gt1) xq1.
have unitrN1 : - 1 \in GRing.unit by move=> R; rewrite unitrN unitr1.
pose uN1 := FinRing.unit ('Z_#[Zp1 : 'Z_q]) (unitrN1 _).
apply: Extremal.Grp => //; exists (Zp_unitm uN1).
rewrite Aut_aut order_injm ?injm_Zp_unitm ?in_setT //; split=> //.
  by rewrite (dvdn_trans _ even_p) // order_dvdn -val_eqE /= mulrNN.
apply/eqP; rewrite autE ?cycle_id // eq_expg_mod_order /=.
by rewrite order_Zp1 !Zp_cast // !modn_mod (modn_small q_gt1) subn1.
Qed.

End Dihedral_extension.

Lemma card_dihedral : #|'D_m| = m.
Proof. by rewrite /('D_m)%type def_q card_ext_dihedral ?mul1n. Qed.

Lemma Grp_dihedral : 'D_m \isog Grp (x : y : (x ^+ q, y ^+ 2, x ^ y = x^-1)).
Proof. by rewrite /('D_m)%type def_q; apply: Grp_ext_dihedral. Qed.

Lemma Grp'_dihedral : 'D_m \isog Grp (x : y : (x ^+ 2, y ^+ 2, (x * y) ^+ q)).
Proof.
move=> gT G; rewrite Grp_dihedral; apply/existsP/existsP=> [] [[x y]] /=.
  case/eqP=> <- xq1 y2 xy; exists (x * y, y); rewrite !xpair_eqE /= eqEsubset.
  rewrite !join_subG !joing_subr !cycle_subG -{3}(mulgK y x) /=.
  rewrite 2?groupM ?groupV ?mem_gen ?inE ?cycle_id ?orbT //= -mulgA expgS.
  by rewrite {1}(conjgC x) xy -mulgA mulKg -(expgS y 1) y2 mulg1 xq1 !eqxx.
case/eqP=> <- x2 y2 xyq; exists (x * y, y); rewrite !xpair_eqE /= eqEsubset.
rewrite !join_subG !joing_subr !cycle_subG -{3}(mulgK y x) /=.
rewrite 2?groupM ?groupV ?mem_gen ?inE ?cycle_id ?orbT //= xyq y2 !eqxx /=.
by rewrite eq_sym eq_invg_mul !mulgA mulgK -mulgA -!(expgS _ 1) x2 y2 mulg1.
Qed.

End DihedralGroup.

Lemma involutions_gen_dihedral gT (x y : gT) :
    let G := <<[set x; y]>> in
  #[x] = 2 -> #[y] = 2 -> x != y -> G \isog 'D_#|G|.
Proof.
move=> G ox oy ne_x_y; pose q := #[x * y].
have q_gt1: q > 1 by rewrite order_gt1 -eq_invg_mul invg_expg ox.
have homG: G \homg 'D_q.*2.
  rewrite Grp'_dihedral //; apply/existsP; exists (x, y); rewrite /= !xpair_eqE.
  by rewrite joing_idl joing_idr -{1}ox -oy !expg_order !eqxx.
suff oG: #|G| = q.*2 by rewrite oG isogEcard oG card_dihedral ?leqnn ?andbT.
have: #|G| %| q.*2  by rewrite -card_dihedral ?card_homg.
have Gxy: <[x * y]> \subset G.
  by rewrite cycle_subG groupM ?mem_gen ?set21 ?set22.
have[k oG]: exists k, #|G| = (k * q)%N by apply/dvdnP; rewrite cardSg.
rewrite oG -mul2n dvdn_pmul2r ?order_gt0 ?dvdn_divisors // !inE /=.
case/pred2P=> [k1 | -> //]; case/negP: ne_x_y.
have cycG: cyclic G.
  apply/cyclicP; exists (x * y); apply/eqP.
  by rewrite eq_sym eqEcard Gxy oG k1 mul1n leqnn.
have: <[x]> == <[y]>.
  by rewrite (eq_subG_cyclic cycG) ?genS ?subsetUl ?subsetUr -?orderE ?ox ?oy.
by rewrite eqEcard cycle_subG /= cycle2g // !inE -order_eq1 ox; case/andP.
Qed.

Lemma Grp_2dihedral n : n > 1 ->
  'D_(2 ^ n) \isog Grp (x : y : (x ^+ (2 ^ n.-1), y ^+ 2, x ^ y = x^-1)).
Proof.
move=> n_gt1; rewrite -(ltn_predK n_gt1) expnS mul2n /=.
by apply: Grp_dihedral; rewrite (ltn_exp2l 0) // -(subnKC n_gt1).
Qed.

Lemma card_2dihedral n : n > 1 -> #|'D_(2 ^ n)| = (2 ^ n)%N.
Proof.
move=> n_gt1; rewrite -(ltn_predK n_gt1) expnS mul2n /= card_dihedral //.
by rewrite (ltn_exp2l 0) // -(subnKC n_gt1).
Qed.

Lemma card_semidihedral n : n > 3 -> #|'SD_(2 ^ n)| = (2 ^ n)%N.
Proof.
move=> n_gt3.
rewrite /('SD__)%type -(subnKC (ltnW (ltnW n_gt3))) pdiv_pfactor //.
by rewrite // !expnS !mulKn -?expnS ?Extremal.card //= (ltn_exp2l 0).
Qed.

Lemma Grp_semidihedral n : n > 3 ->
  'SD_(2 ^ n) \isog
     Grp (x : y : (x ^+ (2 ^ n.-1), y ^+ 2, x ^ y = x ^+ (2 ^ n.-2).-1)).
Proof.
move=> n_gt3.
rewrite /('SD__)%type -(subnKC (ltnW (ltnW n_gt3))) pdiv_pfactor //.
rewrite !expnS !mulKn // -!expnS /=; set q := (2 ^ _)%N.
have q_gt1: q > 1 by rewrite (ltn_exp2l 0).
apply: Extremal.Grp => //; set B := <[_]>.
have oB: #|B| = q by rewrite -orderE order_Zp1 Zp_cast.
have pB: 2.-group B by rewrite /pgroup oB pnat_exp.
have ntB: B != 1 by rewrite -cardG_gt1 oB.
have [] := cyclic_pgroup_Aut_structure pB (cycle_cyclic _) ntB.
rewrite oB /= pfactorK //= -/B => m [[def_m _ _ _ _] _].
rewrite -{1 2}(subnKC n_gt3) => [[t [At ot _ [s [_ _ _ defA]]]]].
case/dprodP: defA => _ defA cst _.
have{cst defA} cAt: t \in 'C(Aut B).
  rewrite -defA centM inE -sub_cent1 -cent_cycle centsC cst /=.
  by rewrite cent_cycle cent1id.
case=> s0 [As0 os0 _ def_s0t _]; exists (s0 * t).
rewrite -def_m ?groupM ?cycle_id // def_s0t !Zp_expg !mul1n valZpK Zp_nat.
rewrite order_dvdn expgMn /commute 1?(centP cAt) // -{1}os0 -{1}ot.
by rewrite !expg_order mul1g.
Qed.

Section Quaternion.

Variable n : nat.
Hypothesis n_gt2 : n > 2.
Let m := (2 ^ n)%N.
Let q := (2 ^ n.-1)%N.
Let r := (2 ^ n.-2)%N.
Let GrpQ := 'Q_m \isog Grp (x : y : (x ^+ q, y ^+ 2 = x ^+ r, x ^ y = x^-1)).
Let defQ :  #|'Q_m| = m /\ GrpQ.
Proof.
have q_gt1 : q > 1 by rewrite (ltn_exp2l 0) // -(subnKC n_gt2).
have def_m : (2 * q)%N = m by rewrite -expnS (ltn_predK n_gt2).
have def_q : m %/ pdiv m = q
  by rewrite /m -(ltn_predK n_gt2) pdiv_pfactor // expnS mulKn.
have r_gt1 : r > 1 by rewrite (ltn_exp2l 0) // -(subnKC n_gt2).
have def2r : (2 * r)%N = q by rewrite -expnS /q -(subnKC n_gt2).
rewrite /GrpQ [@quaternion_gtype _]unlock /quaternion_kernel {}def_q.
set B := [set: _]; have: B \homg Grp (u : v : (u ^+ q, v ^+ 4, u ^ v = u^-1)).
  by rewrite -Grp_ext_dihedral ?homg_refl.
have: #|B| = (q * 4)%N by rewrite card_ext_dihedral // mulnC -muln2 -mulnA.
rewrite {}/B; move: (Extremal.gtype q 4 _) => gT.
set B := [set: gT] => oB; set K := _ :\: _.
case/existsP=> -[u v] /= /eqP[defB uq v4 uv].
have nUV: <[v]> \subset 'N(<[u]>) by rewrite norms_cycle uv groupV cycle_id.
rewrite norm_joinEr // in defB.
have le_ou: #[u] <= q by rewrite dvdn_leq ?expn_gt0 // order_dvdn uq.
have le_ov: #[v] <= 4 by rewrite dvdn_leq // order_dvdn v4.
have tiUV: <[u]> :&: <[v]> = 1 by rewrite cardMg_TI // defB oB leq_mul.
have{le_ou le_ov} [ou ov]: #[u] = q /\ #[v] = 4.
  have:= esym (leqif_mul (leqif_eq le_ou) (leqif_eq le_ov)).2.
  by rewrite -TI_cardMg // defB -oB eqxx eqn0Ngt cardG_gt0; do 2!case: eqP=> //.
have sdB: <[u]> ><| <[v]> = B by rewrite sdprodE.
have uvj j: u ^ (v ^+ j) = (if odd j then u^-1 else u).
  elim: j => [|j IHj]; first by rewrite conjg1.
  by rewrite expgS conjgM uv conjVg IHj (fun_if invg) invgK if_neg.
have sqrB i j: (u ^+ i * v ^+ j) ^+ 2 = (if odd j then v ^+ 2 else u ^+ i.*2).
  rewrite expgS; case: ifP => odd_j.
    rewrite {1}(conjgC (u ^+ i)) conjXg uvj odd_j expgVn -mulgA mulKg.
    rewrite -expgD addnn -(odd_double_half j) odd_j doubleD addnC /=.
    by rewrite -(expg_mod _ v4) -!muln2 -mulnA modnMDl.
  rewrite {2}(conjgC (u ^+ i)) conjXg uvj odd_j mulgA -(mulgA (u ^+ i)).
  rewrite -expgD addnn -(odd_double_half j) odd_j -2!mul2n mulnA.
  by rewrite expgM v4 expg1n mulg1 -expgD addnn.
pose w := u ^+ r * v ^+ 2.
have Kw: w \in K.
  rewrite !inE sqrB /= -mul2n def2r uq eqxx andbT -defB.
  apply/imsetP=> [[_]] /imset2P[_ _ /cycleP[i ->] /cycleP[j ->] ->].
  apply/eqP; rewrite sqrB; case: ifP => _.
    rewrite eq_mulgV1 mulgK -order_dvdn ou pfactor_dvdn ?expn_gt0 ?pfactorK //.
    by rewrite -ltnNge -(subnKC n_gt2).
  rewrite (canF_eq (mulKg _)); apply/eqP=> def_v2.
  suffices: v ^+ 2 \in <[u]> :&: <[v]> by rewrite tiUV inE -order_dvdn ov.
  by rewrite inE {1}def_v2 groupM ?groupV !mem_cycle.
have ow: #[w] = 2.
  case/setDP: Kw; rewrite inE -order_dvdn dvdn_divisors // !inE /= order_eq1.
  by case/orP=> /eqP-> // /imsetP[]; exists 1; rewrite ?inE ?expg1n.
have defK: K = [set w].
  apply/eqP; rewrite eqEsubset sub1set Kw andbT subDset setUC.
  apply/subsetP=> uivj; have: uivj \in B by rewrite inE.
  rewrite -{1}defB => /imset2P[_ _ /cycleP[i ->] /cycleP[j ->] ->] {uivj}.
  rewrite !inE sqrB -{-1}[j]odd_double_half.
  case: (odd j); rewrite -order_dvdn ?ov // ou -def2r -mul2n dvdn_pmul2l //.
  case/dvdnP=> k ->{i}; apply/orP.
  rewrite add0n -[j./2]odd_double_half addnC doubleD -!muln2 -mulnA.
  rewrite -(expg_mod_order v) ov modnMDl; case: (odd _); last first.
    right; rewrite mulg1 /r -(subnKC n_gt2) expnSr mulnA expgM.
    by apply: mem_imset; rewrite inE.
  rewrite (inj_eq (mulIg _)) -expg_mod_order ou -[k]odd_double_half.
  rewrite addnC -muln2 mulnDl -mulnA def2r modnMDl -ou expg_mod_order.
  case: (odd k); [left | right]; rewrite ?mul1n ?mul1g //.
  by apply/imsetP; exists v; rewrite ?inE.
have nKB: 'N(<<K>>) = B.
  apply/setP=> b; rewrite !inE -genJ genS // {1}defK conjg_set1 sub1set.
  have:= Kw; rewrite !inE -!order_dvdn orderJ ow !andbT; apply: contra.
  case/imsetP=> z _ def_wb; apply/imsetP; exists (z ^ b^-1); rewrite ?inE //.
  by rewrite -conjXg -def_wb conjgK.
rewrite -im_quotient card_quotient // nKB -divgS ?subsetT //.
split; first by rewrite oB defK -orderE ow (mulnA q 2 2) mulnK // mulnC.
apply: intro_isoGrp => [|rT H].
  apply/existsP; exists (coset _ u, coset _ v); rewrite /= !xpair_eqE.
  rewrite -!morphX -?morphJ -?morphV /= ?nKB ?in_setT // uq uv morph1 !eqxx.
  rewrite -/B -defB -norm_joinEr // quotientY ?nKB ?subsetT //= andbT.
  rewrite !quotient_cycle /= ?nKB ?in_setT ?eqxx //=.
  by rewrite -(coset_kerl _ (mem_gen Kw)) -mulgA -expgD v4 mulg1.
case/existsP=> -[x y] /= /eqP[defH xq y2 xy].
have ox: #[x] %| #[u] by rewrite ou order_dvdn xq.
have oy: #[y] %| #[v].
  by rewrite ov order_dvdn (expgM y 2 2) y2 -expgM mulnC def2r xq.
have actB: {in <[u]> & <[v]>, morph_act 'J 'J (eltm ox) (eltm oy)}.
  move=> _ _ /cycleP[i ->] /cycleP[j ->] /=.
  rewrite conjXg uvj fun_if if_arg fun_if expgVn morphV ?mem_cycle //= !eltmE.
  rewrite -expgVn -if_arg -fun_if conjXg; congr (_ ^+ i).
  rewrite -{2}[j]odd_double_half addnC expgD -mul2n expgM y2.
  rewrite -expgM conjgM (conjgE x) commuteX // mulKg.
  by case: (odd j); rewrite ?conjg1.
pose f := sdprodm sdB actB.
have Kf: 'ker (coset <<K>>) \subset 'ker f.
  rewrite ker_coset defK cycle_subG /= ker_sdprodm.
  apply/imset2P; exists (u ^+ r) (v ^+ 2); first exact: mem_cycle.
    by rewrite inE mem_cycle /= !eltmE y2.
  by apply: canRL (mulgK _) _; rewrite -mulgA -expgD v4 mulg1.
have Df: 'dom f \subset 'dom (coset <<K>>) by rewrite /dom nKB subsetT.
apply/homgP; exists (factm_morphism Kf Df); rewrite morphim_factm /= -/B.
rewrite -{2}defB morphim_sdprodm // !morphim_cycle ?cycle_id //= !eltm_id.
by rewrite -norm_joinEr // norms_cycle xy groupV cycle_id.
Qed.

Lemma card_quaternion : #|'Q_m| = m. Proof. by case defQ. Qed.
Lemma Grp_quaternion : GrpQ. Proof. by case defQ. Qed.

End Quaternion.

Lemma eq_Mod8_D8 : 'Mod_8 = 'D_8. Proof. by []. Qed.

Section ExtremalStructure.

Variables (gT : finGroupType) (G : {group gT}) (n : nat).
Implicit Type H : {group gT}.

Let m := (2 ^ n)%N.
Let q := (2 ^ n.-1)%N.
Let q_gt0: q > 0. Proof. by rewrite expn_gt0. Qed.
Let r := (2 ^ n.-2)%N.
Let r_gt0: r > 0. Proof. by rewrite expn_gt0. Qed.

Let def2qr : n > 1 -> [/\ 2 * q = m, 2 * r = q, q < m & r < q]%N.
Proof. by rewrite /q /m /r; move/subnKC=> <-; rewrite !ltn_exp2l ?expnS. Qed.

Lemma generators_2dihedral :
    n > 1 -> G \isog 'D_m ->
  exists2 xy, extremal_generators G 2 n xy
           & let: (x, y) := xy in #[y] = 2 /\ x ^ y = x^-1.
Proof.
move=> n_gt1; have [def2q _ ltqm _] := def2qr n_gt1.
case/(isoGrpP _ (Grp_2dihedral n_gt1)); rewrite card_2dihedral // -/ m => oG.
case/existsP=> -[x y] /=; rewrite -/q => /eqP[defG xq y2 xy].
have{defG} defG: <[x]> * <[y]> = G.
  by rewrite -norm_joinEr // norms_cycle xy groupV cycle_id.
have notXy: y \notin <[x]>.
  apply: contraL ltqm => Xy; rewrite -leqNgt -oG -defG mulGSid ?cycle_subG //.
  by rewrite dvdn_leq // order_dvdn xq.
have oy: #[y] = 2 by apply: nt_prime_order (group1_contra notXy).
have ox: #[x] = q.
  apply: double_inj; rewrite -muln2 -oy -mul2n def2q -oG -defG TI_cardMg //.
  by rewrite setIC prime_TIg ?cycle_subG // -orderE oy.
exists (x, y) => //=.
by rewrite oG ox !inE notXy -!cycle_subG /= -defG  mulG_subl mulG_subr.
Qed.

Lemma generators_semidihedral :
    n > 3 -> G \isog 'SD_m ->
  exists2 xy, extremal_generators G 2 n xy
           & let: (x, y) := xy in #[y] = 2 /\ x ^ y = x ^+ r.-1.
Proof.
move=> n_gt3; have [def2q _ ltqm _] := def2qr (ltnW (ltnW n_gt3)).
case/(isoGrpP _ (Grp_semidihedral n_gt3)).
rewrite card_semidihedral // -/m => oG.
case/existsP=> -[x y] /=; rewrite -/q -/r => /eqP[defG xq y2 xy].
have{defG} defG: <[x]> * <[y]> = G.
  by rewrite -norm_joinEr // norms_cycle xy mem_cycle.
have notXy: y \notin <[x]>.
  apply: contraL ltqm => Xy; rewrite -leqNgt -oG -defG mulGSid ?cycle_subG //.
  by rewrite dvdn_leq // order_dvdn xq.
have oy: #[y] = 2 by apply: nt_prime_order (group1_contra notXy).
have ox: #[x] = q.
  apply: double_inj; rewrite -muln2 -oy -mul2n def2q -oG -defG TI_cardMg //.
  by rewrite setIC prime_TIg ?cycle_subG // -orderE oy.
exists (x, y) => //=.
by rewrite oG ox !inE notXy -!cycle_subG /= -defG  mulG_subl mulG_subr.
Qed.

Lemma generators_quaternion :
    n > 2 -> G \isog 'Q_m ->
  exists2 xy, extremal_generators G 2 n xy
           & let: (x, y) := xy in [/\ #[y] = 4, y ^+ 2 = x ^+ r & x ^ y = x^-1].
Proof.
move=> n_gt2; have [def2q def2r ltqm _] := def2qr (ltnW n_gt2).
case/(isoGrpP _ (Grp_quaternion n_gt2)); rewrite card_quaternion // -/m => oG.
case/existsP=> -[x y] /=; rewrite -/q -/r => /eqP[defG xq y2 xy].
have{defG} defG: <[x]> * <[y]> = G.
  by rewrite -norm_joinEr // norms_cycle xy groupV cycle_id.
have notXy: y \notin <[x]>.
  apply: contraL ltqm => Xy; rewrite -leqNgt -oG -defG mulGSid ?cycle_subG //.
  by rewrite dvdn_leq // order_dvdn xq.
have ox: #[x] = q.
  apply/eqP; rewrite eqn_leq dvdn_leq ?order_dvdn ?xq //=.
  rewrite -(leq_pmul2r (order_gt0 y)) mul_cardG defG oG -def2q mulnAC mulnC.
  rewrite leq_pmul2r // dvdn_leq ?muln_gt0 ?cardG_gt0 // order_dvdn expgM.
  by rewrite -order_dvdn order_dvdG //= inE {1}y2 !mem_cycle.
have oy2: #[y ^+ 2] = 2 by rewrite y2 orderXdiv ox -def2r ?dvdn_mull ?mulnK.
exists (x, y) => /=; last by rewrite (orderXprime oy2).
by rewrite oG !inE notXy -!cycle_subG /= -defG  mulG_subl mulG_subr.
Qed.

Variables x y : gT.
Implicit Type M : {group gT}.

Let X := <[x]>.
Let Y := <[y]>.
Let yG := y ^: G.
Let xyG := (x * y) ^: G.
Let My := <<yG>>.
Let Mxy := <<xyG>>.


Theorem dihedral2_structure :
    n > 1 -> extremal_generators G 2 n (x, y) -> G \isog 'D_m ->
  [/\ [/\ X ><| Y = G, {in G :\: X, forall t, #[t] = 2}
        & {in X & G :\: X, forall z t, z ^ t = z^-1}],
      [/\ G ^`(1) = <[x ^+ 2]>, 'Phi(G) = G ^`(1), #|G^`(1)| = r
        & nil_class G = n.-1],
      'Ohm_1(G) = G /\ (forall k, k > 0 -> 'Mho^k(G) = <[x ^+ (2 ^ k)]>),
      [/\ yG :|: xyG = G :\: X, [disjoint yG & xyG]
        & forall M, maximal M G = pred3 X My Mxy M]
    & if n == 2 then (2.-abelem G : Prop) else
  [/\ 'Z(G) = <[x ^+ r]>, #|'Z(G)| = 2,
       My \isog 'D_q, Mxy \isog 'D_q
     & forall U, cyclic U -> U \subset G -> #|G : U| = 2 -> U = X]].
Proof.
move=> n_gt1 genG isoG; have [def2q def2r ltqm ltrq] := def2qr n_gt1.
have [oG Gx ox X'y] := genG; rewrite -/m -/q -/X in oG ox X'y.
case/extremal_generators_facts: genG; rewrite -/X // => pG maxX nsXG defXY nXY.
have [sXG nXG]:= andP nsXG; have [Gy notXy]:= setDP X'y.
have ox2: #[x ^+ 2] = r by rewrite orderXdiv ox -def2r ?dvdn_mulr ?mulKn.
have oxr: #[x ^+ r] = 2 by rewrite orderXdiv ox -def2r ?dvdn_mull ?mulnK.
have [[u v] [_ Gu ou U'v] [ov uv]] := generators_2dihedral n_gt1 isoG.
have defUv: <[u]> :* v = G :\: <[u]>.
  apply: rcoset_index2; rewrite -?divgS ?cycle_subG //.
  by rewrite oG -orderE ou -def2q mulnK.
have invUV: {in <[u]> & <[u]> :* v, forall z t, z ^ t = z^-1}.
  move=> z t; case/cycleP=> i ->; case/rcosetP=> z'; case/cycleP=> j -> ->{z t}.
  by rewrite conjgM {2}/conjg commuteX2 // mulKg conjXg uv expgVn.
have oU': {in <[u]> :* v, forall t, #[t] = 2}.
  move=> t Uvt; apply: nt_prime_order => //; last first.
    by case: eqP Uvt => // ->; rewrite defUv !inE group1.
  case/rcosetP: Uvt => z Uz ->{t}; rewrite expgS {1}(conjgC z) -mulgA.
  by rewrite invUV ?rcoset_refl // mulKg -(expgS v 1) -ov expg_order.
have defU: n > 2 -> {in G, forall z, #[z] = q -> <[z]> = <[u]>}.
  move=> n_gt2 z Gz oz; apply/eqP; rewrite eqEcard -!orderE oz cycle_subG.
  apply: contraLR n_gt2; rewrite ou leqnn andbT -(ltn_predK n_gt1) => notUz.
  by rewrite ltnS -(@ltn_exp2l 2) // -/q -oz oU' // defUv inE notUz.
have n2_abelG: (n > 2) || 2.-abelem G.
  rewrite ltn_neqAle eq_sym n_gt1; case: eqP => //= n2.
  apply/abelemP=> //; split=> [|z Gz].
    by apply: (p2group_abelian pG); rewrite oG pfactorK ?n2.
  case Uz: (z \in <[u]>); last by rewrite -expg_mod_order oU' // defUv inE Uz.
  apply/eqP; rewrite -order_dvdn (dvdn_trans (order_dvdG Uz)) // -orderE.
  by rewrite ou /q n2.
have{oU'} oX': {in G :\: X, forall t, #[t] = 2}.
  have [n_gt2 | abelG] := orP n2_abelG; first by rewrite [X]defU // -defUv.
  move=> t /setDP[Gt notXt]; apply: nt_prime_order (group1_contra notXt) => //.
  by case/abelemP: abelG => // _ ->.
have{invUV} invXX': {in X & G :\: X, forall z t, z ^ t = z^-1}.
  have [n_gt2 | abelG] := orP n2_abelG; first by rewrite [X]defU // -defUv.
  have [//|cGG oG2] := abelemP _ abelG.
  move=> t z Xt /setDP[Gz _]; apply/eqP; rewrite eq_sym eq_invg_mul.
  by rewrite /conjg -(centsP cGG z) // ?mulKg ?[t * t]oG2 ?(subsetP sXG).
have nXiG k: G \subset 'N(<[x ^+ k]>).
  apply: char_norm_trans nXG.
  by rewrite cycle_subgroup_char // cycle_subG mem_cycle.
have memL i: x ^+ (2 ^ i) \in 'L_i.+1(G).
  elim: i => // i IHi; rewrite -groupV expnSr expgM invMg.
  by rewrite -{2}(invXX' _ y) ?mem_cycle ?cycle_id ?mem_commg.
have defG': G^`(1) = <[x ^+ 2]>.
  apply/eqP; rewrite eqEsubset cycle_subG (memL 1%N) ?der1_min //=.
  rewrite (p2group_abelian (quotient_pgroup _ pG)) ?card_quotient //=.
  rewrite -divgS ?cycle_subG ?groupX // oG -orderE ox2.
  by rewrite -def2q -def2r mulnA mulnK.
have defG1: 'Mho^1(G) = <[x ^+ 2]>.
  apply/eqP; rewrite (MhoE _ pG) eqEsubset !gen_subG sub1set andbC.
  rewrite mem_gen; last exact: mem_imset.
  apply/subsetP=> z2; case/imsetP=> z Gz ->{z2}.
  case Xz: (z \in X); last by rewrite -{1}(oX' z) ?expg_order ?group1 // inE Xz.
  by case/cycleP: Xz => i ->; rewrite expgAC mem_cycle.
have defPhi: 'Phi(G) = <[x ^+ 2]>.
  by rewrite (Phi_joing pG) defG' defG1 (joing_idPl _).
have def_tG: {in G :\: X, forall t, t ^: G = <[x ^+ 2]> :* t}.
  move=> t X't; have [Gt notXt] := setDP X't.
  have defJt: {in X, forall z, t ^ z = z ^- 2 * t}.
    move=> z Xz; rewrite /= invMg -mulgA (conjgC _ t).
    by rewrite (invXX' _ t) ?groupV ?invgK.
  have defGt: X * <[t]> = G by rewrite (mulg_normal_maximal nsXG) ?cycle_subG.
  apply/setP=> tz; apply/imsetP/rcosetP=> [[t'z] | [z]].
    rewrite -defGt -normC ?cycle_subG ?(subsetP nXG) //.
    case/imset2P=> _ z /cycleP[j ->] Xz -> -> {tz t'z}.
    exists (z ^- 2); last by rewrite conjgM {2}/conjg commuteX // mulKg defJt.
    case/cycleP: Xz => i ->{z}.
    by rewrite groupV -expgM mulnC expgM mem_cycle.
  case/cycleP=> i -> -> {z tz}; exists (x ^- i); first by rewrite groupV groupX.
  by rewrite defJt ?groupV ?mem_cycle // expgVn invgK expgAC.
have defMt: {in G :\: X, forall t, <[x ^+ 2]> ><| <[t]> = <<t ^: G>>}.
  move=> t X't; have [Gt notXt] := setDP X't.
  rewrite sdprodEY ?cycle_subG ?(subsetP (nXiG 2)) //; first 1 last.
    rewrite setIC prime_TIg -?orderE ?oX' // cycle_subG.
    by apply: contra notXt; apply: subsetP; rewrite cycleX.
  apply/eqP; have: t \in <<t ^: G>> by rewrite mem_gen ?class_refl.
  rewrite def_tG // eqEsubset join_subG !cycle_subG !gen_subG => tGt.
  rewrite tGt -(groupMr _ tGt) mem_gen ?mem_mulg ?cycle_id ?set11 //=.
  by rewrite mul_subG ?joing_subl // -gen_subG joing_subr.
have oMt: {in G :\: X, forall t, #|<<t ^: G>>| = q}.
  move=> t X't /=; rewrite -(sdprod_card (defMt t X't)) -!orderE ox2 oX' //.
  by rewrite mulnC.
have sMtG: {in G :\: X, forall t, <<t ^: G>> \subset G}.
  by move=> t; case/setDP=> Gt _; rewrite gen_subG class_subG.
have maxMt: {in G :\: X, forall t, maximal <<t ^: G>> G}.
  move=> t X't /=; rewrite p_index_maximal -?divgS ?sMtG ?oMt //.
  by rewrite oG -def2q mulnK.
have X'xy: x * y \in G :\: X by rewrite !inE !groupMl ?cycle_id ?notXy.
have ti_yG_xyG: [disjoint yG & xyG].
  apply/pred0P=> t; rewrite /= /yG /xyG !def_tG //; apply/andP=> [[yGt]].
  rewrite rcoset_sym (rcoset_eqP yGt) mem_rcoset mulgK; move/order_dvdG.
  by rewrite -orderE ox2 ox gtnNdvd.
have s_tG_X': {in G :\: X, forall t, t ^: G \subset G :\: X}.
  by move=> t X't /=; rewrite class_sub_norm // normsD ?normG.
have defX': yG :|: xyG = G :\: X.
  apply/eqP; rewrite eqEcard subUset !s_tG_X' //= -(leq_add2l q) -{1}ox orderE.
  rewrite -/X -{1}(setIidPr sXG) cardsID oG -def2q mul2n -addnn leq_add2l.
  rewrite -(leq_add2r #|yG :&: xyG|) cardsUI disjoint_setI0 // cards0 addn0.
  by rewrite /yG /xyG !def_tG // !card_rcoset addnn -mul2n -orderE ox2 def2r.
split.
- by rewrite ?sdprodE // setIC // prime_TIg ?cycle_subG // -orderE ?oX'.
- rewrite defG'; split=> //.
  apply/eqP; rewrite eqn_leq (leq_trans (nil_class_pgroup pG)); last first.
    by rewrite oG pfactorK // geq_max leqnn -(subnKC n_gt1).
  rewrite -(subnKC n_gt1) subn2 ltnNge.
  rewrite (sameP (lcn_nil_classP _ (pgroup_nil pG)) eqP).
  by apply/trivgPn; exists (x ^+ r); rewrite ?memL // -order_gt1 oxr.
- split; last exact: extend_cyclic_Mho.
  have sX'G1: {subset G :\: X <= 'Ohm_1(G)}.
    move=> t X't; have [Gt _] := setDP X't.
    by rewrite (OhmE 1 pG) mem_gen // !inE Gt -(oX' t) //= expg_order.
  apply/eqP; rewrite eqEsubset Ohm_sub -{1}defXY mulG_subG !cycle_subG.
  by rewrite -(groupMr _ (sX'G1 y X'y)) !sX'G1.
- split=> //= H; apply/idP/idP=> [maxH |]; last first.
    by case/or3P=> /eqP->; rewrite ?maxMt.
  have [sHG nHG]:= andP (p_maximal_normal pG maxH).
  have oH: #|H| = q.
    apply: double_inj; rewrite -muln2 -(p_maximal_index pG maxH) Lagrange //.
    by rewrite oG -mul2n.
  rewrite !(eq_sym (gval H)) -eq_sym !eqEcard oH -orderE ox !oMt // !leqnn.
  case sHX: (H \subset X) => //=; case/subsetPn: sHX => t Ht notXt.
  have: t \in yG :|: xyG by rewrite defX' inE notXt (subsetP sHG).
  rewrite !andbT !gen_subG /yG /xyG.
  by case/setUP; move/class_eqP <-; rewrite !class_sub_norm ?Ht ?orbT.
rewrite eqn_leq n_gt1; case: leqP n2_abelG => //= n_gt2 _.
have ->: 'Z(G) = <[x ^+ r]>.
  apply/eqP; rewrite eqEcard andbC -orderE oxr -{1}(setIidPr (center_sub G)).
  rewrite cardG_gt1 /= meet_center_nil ?(pgroup_nil pG) //; last first.
    by rewrite -cardG_gt1 oG (leq_trans _ ltqm).
  apply/subsetP=> t; case/setIP=> Gt cGt.
  case X't: (t \in G :\: X).
    move/eqP: (invXX' _ _ (cycle_id x) X't).
    rewrite /conjg -(centP cGt) // mulKg eq_sym eq_invg_mul -order_eq1 ox2.
    by rewrite (eqn_exp2l _ 0) // -(subnKC n_gt2).
  move/idPn: X't; rewrite inE Gt andbT negbK => Xt.
  have:= Ohm_p_cycle 1 (mem_p_elt pG Gx); rewrite ox pfactorK // subn1 => <-.
  rewrite (OhmE _ (pgroupS sXG pG)) mem_gen // !inE Xt /=.
  by rewrite -eq_invg_mul -(invXX' _ y) // /conjg (centP cGt) // mulKg.
have isoMt: {in G :\: X, forall t, <<t ^: G>> \isog 'D_q}.
  have n1_gt1: n.-1 > 1 by rewrite -(subnKC n_gt2).
  move=> t X't /=; rewrite isogEcard card_2dihedral ?oMt // leqnn andbT.
  rewrite Grp_2dihedral //; apply/existsP; exists (x ^+ 2, t) => /=.
  have [_ <- nX2T _] := sdprodP (defMt t X't); rewrite norm_joinEr //.
  rewrite -/q -/r !xpair_eqE eqxx -expgM def2r -ox -{1}(oX' t X't).
  by rewrite !expg_order !eqxx /= invXX' ?mem_cycle.
rewrite !isoMt //; split=> // C; case/cyclicP=> z ->{C} sCG iCG.
rewrite [X]defU // defU -?cycle_subG //.
by apply: double_inj; rewrite -muln2 -iCG Lagrange // oG -mul2n.
Qed.

Theorem quaternion_structure :
    n > 2 -> extremal_generators G 2 n (x, y) -> G \isog 'Q_m ->
  [/\ [/\ pprod X Y = G, {in G :\: X, forall t, #[t] = 4}
        & {in X & G :\: X, forall z t, z ^ t = z^-1}],
      [/\ G ^`(1) = <[x ^+ 2]>, 'Phi(G) = G ^`(1), #|G^`(1)| = r
        & nil_class G = n.-1],
      [/\ 'Z(G) = <[x ^+ r]>, #|'Z(G)| = 2,
          forall u, u \in G -> #[u] = 2 -> u = x ^+ r,
          'Ohm_1(G) = <[x ^+ r]> /\ 'Ohm_2(G) = G
         & forall k, k > 0 -> 'Mho^k(G) = <[x ^+ (2 ^ k)]>],
      [/\ yG :|: xyG = G :\: X /\ [disjoint yG & xyG]
        & forall M, maximal M G = pred3 X My Mxy M]
    & n > 3 ->
     [/\ My \isog 'Q_q, Mxy \isog 'Q_q
       & forall U, cyclic U -> U \subset G -> #|G : U| = 2 -> U = X]].
Proof.
move=> n_gt2 genG isoG; have [def2q def2r ltqm ltrq] := def2qr (ltnW n_gt2).
have [oG Gx ox X'y] := genG; rewrite -/m -/q -/X in oG ox X'y.
case/extremal_generators_facts: genG; rewrite -/X // => pG maxX nsXG defXY nXY.
have [sXG nXG]:= andP nsXG; have [Gy notXy]:= setDP X'y.
have oxr: #[x ^+ r] = 2 by rewrite orderXdiv ox -def2r ?dvdn_mull ?mulnK.
have ox2: #[x ^+ 2] = r by rewrite orderXdiv ox -def2r ?dvdn_mulr ?mulKn.
have [[u v] [_ Gu ou U'v] [ov v2 uv]] := generators_quaternion n_gt2 isoG.
have defUv: <[u]> :* v = G :\: <[u]>.
  apply: rcoset_index2; rewrite -?divgS ?cycle_subG //.
  by rewrite oG -orderE ou -def2q mulnK.
have invUV: {in <[u]> & <[u]> :* v, forall z t, z ^ t = z^-1}.
  move=> z t; case/cycleP=> i ->; case/rcosetP=> ?; case/cycleP=> j -> ->{z t}.
  by rewrite conjgM {2}/conjg commuteX2 // mulKg conjXg uv expgVn.
have U'2: {in <[u]> :* v, forall t, t ^+ 2 = u ^+ r}.
  move=> t; case/rcosetP=> z Uz ->; rewrite expgS {1}(conjgC z) -mulgA.
  by rewrite invUV ?rcoset_refl // mulKg -(expgS v 1) v2.
have our: #[u ^+ r] = 2 by rewrite orderXdiv ou -/q -def2r ?dvdn_mull ?mulnK.
have def_ur: {in G, forall t, #[t] = 2 -> t = u ^+ r}.
  move=> t Gt /= ot; case Ut: (t \in <[u]>); last first.
    move/eqP: ot; rewrite eqn_dvd order_dvdn -order_eq1 U'2 ?our //.
    by rewrite defUv inE Ut.
  have p2u: 2.-elt u by rewrite /p_elt ou pnat_exp.
  have: t \in 'Ohm_1(<[u]>).
    by rewrite (OhmE _ p2u) mem_gen // !inE Ut -order_dvdn ot.
  rewrite (Ohm_p_cycle _ p2u) ou pfactorK // subn1 -/r cycle_traject our !inE.
  by rewrite -order_eq1 ot /= mulg1; move/eqP.
have defU: n > 3 -> {in G, forall z, #[z] = q -> <[z]> = <[u]>}.
  move=> n_gt3 z Gz oz; apply/eqP; rewrite eqEcard -!orderE oz cycle_subG.
  rewrite ou leqnn andbT; apply: contraLR n_gt3 => notUz.
  rewrite -(ltn_predK n_gt2) ltnS -(@ltn_exp2l 2) // -/q -oz.
  by rewrite (@orderXprime _ 2 2) // U'2 // defUv inE notUz.
have def_xr: x ^+ r = u ^+ r by apply: def_ur; rewrite ?groupX.
have X'2: {in G :\: X, forall t, t ^+ 2 = u ^+ r}.
  case: (ltngtP n 3) => [|n_gt3|n3 t]; first by rewrite ltnNge n_gt2.
    by rewrite /X defU // -defUv.
  case/setDP=> Gt notXt.
  case Ut: (t \in <[u]>); last by rewrite U'2 // defUv inE Ut.
  rewrite [t ^+ 2]def_ur ?groupX //.
  have:= order_dvdG Ut; rewrite -orderE ou /q n3 dvdn_divisors ?inE //=.
  rewrite order_eq1 (negbTE (group1_contra notXt)) /=.
  case/pred2P=> oz; last by rewrite orderXdiv oz.
  by rewrite [t]def_ur // -def_xr mem_cycle in notXt.
have oX': {in G :\: X, forall z, #[z] = 4}.
  by move=> t X't /=; rewrite (@orderXprime _ 2 2) // X'2.
have defZ: 'Z(G) = <[x ^+ r]>.
  apply/eqP; rewrite eqEcard andbC -orderE oxr -{1}(setIidPr (center_sub G)).
  rewrite cardG_gt1 /= meet_center_nil ?(pgroup_nil pG) //; last first.
    by rewrite -cardG_gt1 oG (leq_trans _ ltqm).
  apply/subsetP=> z; case/setIP=> Gz cGz; have [Gv _]:= setDP U'v.
  case Uvz: (z \in <[u]> :* v).
    move/eqP: (invUV _ _ (cycle_id u) Uvz).
    rewrite /conjg -(centP cGz) // mulKg eq_sym eq_invg_mul -(order_dvdn _ 2).
    by rewrite ou pfactor_dvdn // -(subnKC n_gt2).
  move/idPn: Uvz; rewrite defUv inE Gz andbT negbK def_xr => Uz.
  have p_u: 2.-elt u := mem_p_elt pG Gu.
  suff: z \in 'Ohm_1(<[u]>) by rewrite (Ohm_p_cycle 1 p_u) ou pfactorK // subn1.
  rewrite (OhmE _ p_u) mem_gen // !inE Uz /= -eq_invg_mul.
  by rewrite -(invUV _ v) ?rcoset_refl // /conjg (centP cGz) ?mulKg.
have{invUV} invXX': {in X & G :\: X, forall z t, z ^ t = z^-1}.
  case: (ltngtP n 3) => [|n_gt3|n3 t z Xt]; first by rewrite ltnNge n_gt2.
    by rewrite /X defU // -defUv.
  case/setDP=> Gz notXz; rewrite /q /r n3 /= in oxr ox.
  suff xz: x ^ z = x^-1 by case/cycleP: Xt => i ->; rewrite conjXg xz expgVn.
  have: x ^ z \in X by rewrite memJ_norm ?cycle_id ?(subsetP nXG).
  rewrite invg_expg /X cycle_traject ox !inE /= !mulg1 -order_eq1 orderJ ox /=.
  case/or3P; move/eqP=> //; last by move/(congr1 order); rewrite orderJ ox oxr.
  move/conjg_fixP; rewrite (sameP commgP cent1P) cent1C -cent_cycle -/X => cXz.
  have defXz: X * <[z]> = G by rewrite (mulg_normal_maximal nsXG) ?cycle_subG.
  have: z \in 'Z(G) by rewrite inE Gz -defXz centM inE cXz cent_cycle cent1id.
  by rewrite defZ => Xr_z; rewrite (subsetP (cycleX x r)) in notXz.
have nXiG k: G \subset 'N(<[x ^+ k]>).
  apply: char_norm_trans nXG.
  by rewrite cycle_subgroup_char // cycle_subG mem_cycle.
have memL i: x ^+ (2 ^ i) \in 'L_i.+1(G).
  elim: i => // i IHi; rewrite -groupV expnSr expgM invMg.
  by rewrite -{2}(invXX' _ y) ?mem_cycle ?cycle_id ?mem_commg.
have defG': G^`(1) = <[x ^+ 2]>.
  apply/eqP; rewrite eqEsubset cycle_subG (memL 1%N) ?der1_min //=.
  rewrite (p2group_abelian (quotient_pgroup _ pG)) ?card_quotient //=.
  rewrite -divgS ?cycle_subG ?groupX // oG -orderE ox2.
  by rewrite -def2q -def2r mulnA mulnK.
have defG1: 'Mho^1(G) = <[x ^+ 2]>.
  apply/eqP; rewrite (MhoE _ pG) eqEsubset !gen_subG sub1set andbC.
  rewrite mem_gen; last exact: mem_imset.
  apply/subsetP=> z2; case/imsetP=> z Gz ->{z2}.
  case Xz: (z \in X).
    by case/cycleP: Xz => i ->; rewrite -expgM mulnC expgM mem_cycle.
  rewrite (X'2 z) ?inE ?Xz // -def_xr.
  by rewrite /r -(subnKC n_gt2) expnS expgM mem_cycle.
have defPhi: 'Phi(G) = <[x ^+ 2]>.
  by rewrite (Phi_joing pG) defG' defG1 (joing_idPl _).
have def_tG: {in G :\: X, forall t, t ^: G = <[x ^+ 2]> :* t}.
  move=> t X't; have [Gt notXt] := setDP X't.
  have defJt: {in X, forall z, t ^ z = z ^- 2 * t}.
    move=> z Xz; rewrite /= invMg -mulgA (conjgC _ t).
    by rewrite (invXX' _ t) ?groupV ?invgK.
  have defGt: X * <[t]> = G by rewrite (mulg_normal_maximal nsXG) ?cycle_subG.
  apply/setP=> tz; apply/imsetP/rcosetP=> [[t'z] | [z]].
    rewrite -defGt -normC ?cycle_subG ?(subsetP nXG) //.
    case/imset2P=> t' z; case/cycleP=> j -> Xz -> -> {tz t'z t'}.
    exists (z ^- 2); last by rewrite conjgM {2}/conjg commuteX // mulKg defJt.
    case/cycleP: Xz => i ->{z}.
    by rewrite groupV -expgM mulnC expgM mem_cycle.
  case/cycleP=> i -> -> {z tz}; exists (x ^- i); first by rewrite groupV groupX.
  by rewrite defJt ?groupV ?mem_cycle // expgVn invgK -!expgM mulnC.
have defMt: {in G :\: X, forall t, <[x ^+ 2]> <*> <[t]> = <<t ^: G>>}.
  move=> t X't; have [Gt notXt] := setDP X't.
  apply/eqP; have: t \in <<t ^: G>> by rewrite mem_gen ?class_refl.
  rewrite def_tG // eqEsubset join_subG !cycle_subG !gen_subG => tGt.
  rewrite tGt -(groupMr _ tGt) mem_gen ?mem_mulg ?cycle_id ?set11 //=.
  by rewrite mul_subG ?joing_subl // -gen_subG joing_subr.
have sMtG: {in G :\: X, forall t, <<t ^: G>> \subset G}.
  by move=> t; case/setDP=> Gt _; rewrite gen_subG class_subG.
have oMt: {in G :\: X, forall t, #|<<t ^: G>>| = q}.
  move=> t X't; have [Gt notXt] := setDP X't.
  rewrite -defMt // -(Lagrange (joing_subl _ _)) -orderE ox2 -def2r mulnC.
  congr (_ * r)%N; rewrite -card_quotient /=; last first.
    by rewrite defMt // (subset_trans _ (nXiG 2)) ?sMtG.
  rewrite joingC quotientYidr ?(subset_trans _ (nXiG 2)) ?cycle_subG //.
  rewrite quotient_cycle ?(subsetP (nXiG 2)) //= -defPhi.
  rewrite -orderE (abelem_order_p (Phi_quotient_abelem pG)) ?mem_quotient //.
  apply: contraNneq notXt; move/coset_idr; move/implyP=> /=.
  by rewrite defPhi ?(subsetP (nXiG 2)) //; apply: subsetP; apply: cycleX.
have maxMt: {in G :\: X, forall t, maximal <<t ^: G>> G}.
  move=> t X't; rewrite /= p_index_maximal -?divgS ?sMtG ?oMt //.
  by rewrite oG -def2q mulnK.
have X'xy: x * y \in G :\: X by rewrite !inE !groupMl ?cycle_id ?notXy.
have ti_yG_xyG: [disjoint yG & xyG].
  apply/pred0P=> t; rewrite /= /yG /xyG !def_tG //; apply/andP=> [[yGt]].
  rewrite rcoset_sym (rcoset_eqP yGt) mem_rcoset mulgK; move/order_dvdG.
  by rewrite -orderE ox2 ox gtnNdvd.
have s_tG_X': {in G :\: X, forall t, t ^: G \subset G :\: X}.
  by move=> t X't /=; rewrite class_sub_norm // normsD ?normG.
have defX': yG :|: xyG = G :\: X.
  apply/eqP; rewrite eqEcard subUset !s_tG_X' //= -(leq_add2l q) -{1}ox orderE.
  rewrite -/X -{1}(setIidPr sXG) cardsID oG -def2q mul2n -addnn leq_add2l.
  rewrite -(leq_add2r #|yG :&: xyG|) cardsUI disjoint_setI0 // cards0 addn0.
  by rewrite /yG /xyG !def_tG // !card_rcoset addnn -mul2n -orderE ox2 def2r.
rewrite pprodE //; split=> // [|||n_gt3].
- rewrite defG'; split=> //; apply/eqP; rewrite eqn_leq.
  rewrite (leq_trans (nil_class_pgroup pG)); last first.
    by rewrite oG pfactorK // -(subnKC n_gt2).
  rewrite -(subnKC (ltnW n_gt2)) subn2 ltnNge.
  rewrite (sameP (lcn_nil_classP _ (pgroup_nil pG)) eqP).
  by apply/trivgPn; exists (x ^+ r); rewrite ?memL // -order_gt1 oxr.
- rewrite {2}def_xr defZ; split=> //; last exact: extend_cyclic_Mho.
  split; apply/eqP; last first.
    have sX'G2: {subset G :\: X <= 'Ohm_2(G)}.
      move=> z X'z; have [Gz _] := setDP X'z.
      by rewrite (OhmE 2 pG) mem_gen // !inE Gz -order_dvdn oX'.
    rewrite eqEsubset Ohm_sub -{1}defXY mulG_subG !cycle_subG.
    by rewrite -(groupMr _ (sX'G2 y X'y)) !sX'G2.
  rewrite eqEsubset (OhmE 1 pG) cycle_subG gen_subG andbC.
  rewrite mem_gen ?inE ?groupX -?order_dvdn ?oxr //=.
  apply/subsetP=> t; case/setIP=> Gt; rewrite inE -order_dvdn /=.
  rewrite dvdn_divisors ?inE //= order_eq1.
  case/pred2P=> [->|]; first exact: group1.
  by move/def_ur=> -> //; rewrite def_xr cycle_id.
- split=> //= H; apply/idP/idP=> [maxH |]; last first.
    by case/or3P=> /eqP->; rewrite ?maxMt.
  have [sHG nHG]:= andP (p_maximal_normal pG maxH).
  have oH: #|H| = q.
    apply: double_inj; rewrite -muln2 -(p_maximal_index pG maxH) Lagrange //.
    by rewrite oG -mul2n.
  rewrite !(eq_sym (gval H)) -eq_sym !eqEcard oH -orderE ox !oMt // !leqnn.
  case sHX: (H \subset X) => //=; case/subsetPn: sHX => z Hz notXz.
  have: z \in yG :|: xyG by rewrite defX' inE notXz (subsetP sHG).
  rewrite !andbT !gen_subG /yG /xyG.
  by case/setUP=> /class_eqP <-; rewrite !class_sub_norm ?Hz ?orbT.
have isoMt: {in G :\: X, forall z, <<z ^: G>> \isog 'Q_q}.
  have n1_gt2: n.-1 > 2 by rewrite -(subnKC n_gt3).
  move=> z X'z /=; rewrite isogEcard card_quaternion ?oMt // leqnn andbT.
  rewrite Grp_quaternion //; apply/existsP; exists (x ^+ 2, z) => /=.
  rewrite defMt // -/q -/r !xpair_eqE -!expgM def2r -order_dvdn ox dvdnn.
  rewrite -expnS prednK; last by rewrite -subn2 subn_gt0.
  by rewrite X'2 // def_xr !eqxx /= invXX' ?mem_cycle.
rewrite !isoMt //; split=> // C; case/cyclicP=> z ->{C} sCG iCG.
rewrite [X]defU // defU -?cycle_subG //.
by apply: double_inj; rewrite -muln2 -iCG Lagrange // oG -mul2n.
Qed.

Theorem semidihedral_structure :
    n > 3 -> extremal_generators G 2 n (x, y) -> G \isog 'SD_m -> #[y] = 2 ->
  [/\ [/\ X ><| Y = G, #[x * y] = 4
        & {in X & G :\: X, forall z t, z ^ t = z ^+ r.-1}],
      [/\ G ^`(1) = <[x ^+ 2]>, 'Phi(G) = G ^`(1), #|G^`(1)| = r
        & nil_class G = n.-1],
      [/\ 'Z(G) = <[x ^+ r]>, #|'Z(G)| = 2,
          'Ohm_1(G) = My /\ 'Ohm_2(G) = G
         & forall k, k > 0 -> 'Mho^k(G) = <[x ^+ (2 ^ k)]>],
      [/\ yG :|: xyG = G :\: X /\ [disjoint yG & xyG]
        & forall H, maximal H G = pred3 X My Mxy H]
    & [/\ My \isog 'D_q, Mxy \isog 'Q_q
       & forall U, cyclic U -> U \subset G -> #|G : U| = 2 -> U = X]].
Proof.
move=> n_gt3 genG isoG oy.
have [def2q def2r ltqm ltrq] := def2qr (ltnW (ltnW n_gt3)).
have [oG Gx ox X'y] := genG; rewrite -/m -/q -/X in oG ox X'y.
case/extremal_generators_facts: genG; rewrite -/X // => pG maxX nsXG defXY nXY.
have [sXG nXG]:= andP nsXG; have [Gy notXy]:= setDP X'y.
have ox2: #[x ^+ 2] = r by rewrite orderXdiv ox -def2r ?dvdn_mulr ?mulKn.
have oxr: #[x ^+ r] = 2 by rewrite orderXdiv ox -def2r ?dvdn_mull ?mulnK.
have [[u v] [_ Gu ou U'v] [ov uv]] := generators_semidihedral n_gt3 isoG.
have defUv: <[u]> :* v = G :\: <[u]>.
  apply: rcoset_index2; rewrite -?divgS ?cycle_subG //.
  by rewrite oG -orderE ou -def2q mulnK.
have invUV: {in <[u]> & <[u]> :* v, forall z t, z ^ t = z ^+ r.-1}.
  move=> z t; case/cycleP=> i ->; case/rcosetP=> ?; case/cycleP=> j -> ->{z t}.
  by rewrite conjgM {2}/conjg commuteX2 // mulKg conjXg uv -!expgM mulnC.
have [vV yV]: v^-1 = v /\ y^-1 = y by rewrite !invg_expg ov oy.
have defU: {in G, forall z, #[z] = q -> <[z]> = <[u]>}.
  move=> z Gz /= oz; apply/eqP; rewrite eqEcard -!orderE oz ou leqnn andbT.
  apply: contraLR (n_gt3) => notUz; rewrite -leqNgt -(ltn_predK n_gt3) ltnS.
  rewrite -(@dvdn_Pexp2l 2) // -/q -{}oz order_dvdn expgM (expgS z).
  have{Gz notUz} [z' Uz' ->{z}]: exists2 z', z' \in <[u]> & z = z' * v.
    by apply/rcosetP; rewrite defUv inE -cycle_subG notUz Gz.
  rewrite {2}(conjgC z') invUV ?rcoset_refl // mulgA -{2}vV mulgK -expgS.
  by rewrite prednK // -expgM mulnC def2r -order_dvdn /q -ou order_dvdG.
have{invUV} invXX': {in X & G :\: X, forall z t, z ^ t = z ^+ r.-1}.
  by rewrite /X defU -?defUv.
have xy2: (x * y) ^+ 2 = x ^+ r.
  rewrite expgS {2}(conjgC x) invXX' ?cycle_id // mulgA -{2}yV mulgK -expgS.
  by rewrite prednK.
have oxy: #[x * y] = 4 by rewrite (@orderXprime _ 2 2) ?xy2.
have r_gt2: r > 2 by rewrite (ltn_exp2l 1) // -(subnKC n_gt3).
have coXr1: coprime #[x] (2 ^ (n - 3)).-1.
  rewrite ox coprime_expl // -(@coprime_pexpl (n - 3)) ?coprimenP ?subn_gt0 //.
  by rewrite expn_gt0.
have def2r1: (2 * (2 ^ (n - 3)).-1).+1 = r.-1.
  rewrite -!subn1 mulnBr -expnS [_.+1]subnSK ?(ltn_exp2l 0) //.
  by rewrite /r -(subnKC n_gt3).
have defZ: 'Z(G) = <[x ^+ r]>.
  apply/eqP; rewrite eqEcard andbC -orderE oxr -{1}(setIidPr (center_sub G)).
  rewrite cardG_gt1 /= meet_center_nil ?(pgroup_nil pG) //; last first.
    by rewrite -cardG_gt1 oG (leq_trans _ ltqm).
  apply/subsetP=> z /setIP[Gz cGz].
  case X'z: (z \in G :\: X).
    move/eqP: (invXX' _ _ (cycle_id x) X'z).
    rewrite /conjg -(centP cGz) // mulKg -def2r1 eq_mulVg1 expgS mulKg mulnC.
    rewrite -order_dvdn Gauss_dvdr // order_dvdn -order_eq1.
    by rewrite ox2 -(subnKC r_gt2).
  move/idPn: X'z; rewrite inE Gz andbT negbK => Xz.
  have:= Ohm_p_cycle 1 (mem_p_elt pG Gx); rewrite ox pfactorK // subn1 => <-.
  rewrite (OhmE _ (mem_p_elt pG Gx)) mem_gen // !inE Xz /=.
  rewrite -(expgK coXr1 Xz) -!expgM mulnCA -order_dvdn dvdn_mull //.
  rewrite mulnC order_dvdn -(inj_eq (mulgI z)) -expgS mulg1 def2r1.
  by rewrite -(invXX' z y) // /conjg (centP cGz) ?mulKg.
have nXiG k: G \subset 'N(<[x ^+ k]>).
  apply: char_norm_trans nXG.
  by rewrite cycle_subgroup_char // cycle_subG mem_cycle.
have memL i: x ^+ (2 ^ i) \in 'L_i.+1(G).
  elim: i => // i IHi; rewrite -(expgK coXr1 (mem_cycle _ _)) groupX //.
  rewrite -expgM expnSr -mulnA expgM -(mulKg (x ^+ (2 ^ i)) (_ ^+ _)).
  by rewrite -expgS def2r1 -(invXX' _ y) ?mem_cycle ?mem_commg.
have defG': G^`(1) = <[x ^+ 2]>.
  apply/eqP; rewrite eqEsubset cycle_subG (memL 1%N) ?der1_min //=.
  rewrite (p2group_abelian (quotient_pgroup _ pG)) ?card_quotient //=.
  rewrite -divgS ?cycle_subG ?groupX // oG -orderE ox2.
  by rewrite -def2q -def2r mulnA mulnK.
have defG1: 'Mho^1(G) = <[x ^+ 2]>.
  apply/eqP; rewrite (MhoE _ pG) eqEsubset !gen_subG sub1set andbC.
  rewrite mem_gen; last exact: mem_imset.
  apply/subsetP=> z2; case/imsetP=> z Gz ->{z2}.
  case Xz: (z \in X).
    by case/cycleP: Xz => i ->; rewrite -expgM mulnC expgM mem_cycle.
  have{Xz Gz} [xi Xxi ->{z}]: exists2 xi, xi \in X & z = xi * y.
    have Uvy: y \in <[u]> :* v by rewrite defUv -(defU x).
    apply/rcosetP; rewrite /X defU // (rcoset_eqP Uvy) defUv.
    by rewrite inE -(defU x) ?Xz.
  rewrite expn1 expgS {2}(conjgC xi) -{2}[y]/(y ^+ 2.-1) -{1}oy -invg_expg.
  rewrite mulgA mulgK invXX' // -expgS prednK // /r -(subnKC n_gt3) expnS.
  by case/cycleP: Xxi => i ->; rewrite -expgM mulnCA expgM mem_cycle.
have defPhi: 'Phi(G) = <[x ^+ 2]>.
  by rewrite (Phi_joing pG) defG' defG1 (joing_idPl _).
have def_tG: {in G :\: X, forall t, t ^: G = <[x ^+ 2]> :* t}.
  move=> t X't; have [Gt notXt] := setDP X't.
  have defJt: {in X, forall z, t ^ z = z ^+ r.-2 * t}.
    move=> z Xz /=; rewrite -(mulKg z (z ^+ _)) -expgS -subn2.
    have X'tV: t^-1 \in G :\: X by rewrite inE !groupV notXt.
    by rewrite subnSK 1?ltnW // subn1 -(invXX' _ t^-1) // -mulgA -conjgCV.
  have defGt: X * <[t]> = G by rewrite (mulg_normal_maximal nsXG) ?cycle_subG.
  apply/setP=> tz; apply/imsetP/rcosetP=> [[t'z] | [z]].
    rewrite -defGt -normC ?cycle_subG ?(subsetP nXG) //.
    case/imset2P=> t' z; case/cycleP=> j -> Xz -> -> {t' t'z tz}.
    exists (z ^+ r.-2); last first.
      by rewrite conjgM {2}/conjg commuteX // mulKg defJt.
    case/cycleP: Xz => i ->{z}.
    by rewrite -def2r1 -expgM mulnCA expgM mem_cycle.
  case/cycleP=> i -> -> {z tz}.
  exists (x ^+ (i * expg_invn X (2 ^ (n - 3)).-1)); first by rewrite groupX.
  rewrite defJt ?mem_cycle // -def2r1 -!expgM.
  by rewrite mulnAC mulnA mulnC muln2 !expgM expgK ?mem_cycle.
have defMt: {in G :\: X, forall t, <[x ^+ 2]> <*> <[t]> = <<t ^: G>>}.
  move=> t X't; have [Gt notXt] := setDP X't.
  apply/eqP; have: t \in <<t ^: G>> by rewrite mem_gen ?class_refl.
  rewrite def_tG // eqEsubset join_subG !cycle_subG !gen_subG => tGt.
  rewrite tGt -(groupMr _ tGt) mem_gen ?mem_mulg ?cycle_id ?set11 //=.
  by rewrite mul_subG ?joing_subl // -gen_subG joing_subr.
have sMtG: {in G :\: X, forall t, <<t ^: G>> \subset G}.
  by move=> t; case/setDP=> Gt _; rewrite gen_subG class_subG.
have oMt: {in G :\: X, forall t, #|<<t ^: G>>| = q}.
  move=> t X't; have [Gt notXt] := setDP X't.
  rewrite -defMt // -(Lagrange (joing_subl _ _)) -orderE ox2 -def2r mulnC.
  congr (_ * r)%N; rewrite -card_quotient /=; last first.
    by rewrite defMt // (subset_trans _ (nXiG 2)) ?sMtG.
  rewrite joingC quotientYidr ?(subset_trans _ (nXiG 2)) ?cycle_subG //.
  rewrite quotient_cycle ?(subsetP (nXiG 2)) //= -defPhi -orderE.
  rewrite (abelem_order_p (Phi_quotient_abelem pG)) ?mem_quotient //.
  apply: contraNneq notXt; move/coset_idr; move/implyP=> /=.
  by rewrite /= defPhi (subsetP (nXiG 2)) //; apply: subsetP; apply: cycleX.
have maxMt: {in G :\: X, forall t, maximal <<t ^: G>> G}.
  move=> t X't /=; rewrite p_index_maximal -?divgS ?sMtG ?oMt //.
  by rewrite oG -def2q mulnK.
have X'xy: x * y \in G :\: X by rewrite !inE !groupMl ?cycle_id ?notXy.
have ti_yG_xyG: [disjoint yG & xyG].
  apply/pred0P=> t; rewrite /= /yG /xyG !def_tG //; apply/andP=> [[yGt]].
  rewrite rcoset_sym (rcoset_eqP yGt) mem_rcoset mulgK; move/order_dvdG.
  by rewrite -orderE ox2 ox gtnNdvd.
have s_tG_X': {in G :\: X, forall t, t ^: G \subset G :\: X}.
  by move=> t X't /=; rewrite class_sub_norm // normsD ?normG.
have defX': yG :|: xyG = G :\: X.
  apply/eqP; rewrite eqEcard subUset !s_tG_X' //= -(leq_add2l q) -{1}ox orderE.
  rewrite -/X -{1}(setIidPr sXG) cardsID oG -def2q mul2n -addnn leq_add2l.
  rewrite -(leq_add2r #|yG :&: xyG|) cardsUI disjoint_setI0 // cards0 addn0.
  by rewrite /yG /xyG !def_tG // !card_rcoset addnn -mul2n -orderE ox2 def2r.
split.
- by rewrite sdprodE // setIC prime_TIg ?cycle_subG // -orderE oy.
- rewrite defG'; split=> //.
  apply/eqP; rewrite eqn_leq (leq_trans (nil_class_pgroup pG)); last first.
    by rewrite oG pfactorK // -(subnKC n_gt3).
  rewrite -(subnKC (ltnW (ltnW n_gt3))) subn2 ltnNge.
  rewrite (sameP (lcn_nil_classP _ (pgroup_nil pG)) eqP).
  by apply/trivgPn; exists (x ^+ r); rewrite ?memL // -order_gt1 oxr.
- rewrite defZ; split=> //; last exact: extend_cyclic_Mho.
  split; apply/eqP; last first.
    have sX'G2: {subset G :\: X <= 'Ohm_2(G)}.
      move=> t X't; have [Gt _] := setDP X't; rewrite -defX' in X't.
      rewrite (OhmE 2 pG) mem_gen // !inE Gt -order_dvdn.
      by case/setUP: X't; case/imsetP=> z _ ->; rewrite orderJ ?oy ?oxy.
    rewrite eqEsubset Ohm_sub -{1}defXY mulG_subG !cycle_subG.
    by rewrite -(groupMr _ (sX'G2 y X'y)) !sX'G2.
  rewrite eqEsubset andbC gen_subG class_sub_norm ?gFnorm //.
  rewrite (OhmE 1 pG) mem_gen ?inE ?Gy -?order_dvdn ?oy // gen_subG /= -/My.
  apply/subsetP=> t; rewrite !inE; case/andP=> Gt t2.
  have pX := pgroupS sXG pG.
  case Xt: (t \in X).
    have: t \in 'Ohm_1(X) by rewrite (OhmE 1 pX) mem_gen // !inE Xt.
    apply: subsetP; rewrite (Ohm_p_cycle 1 pX) ox pfactorK //.
    rewrite -(subnKC n_gt3) expgM (subset_trans (cycleX _ _)) //.
    by rewrite /My -defMt ?joing_subl.
  have{Xt}: t \in yG :|: xyG by rewrite defX' inE Xt.
  case/setUP; first exact: mem_gen.
  by case/imsetP=> z _ def_t; rewrite -order_dvdn def_t orderJ oxy in t2.
- split=> //= H; apply/idP/idP=> [maxH |]; last first.
    by case/or3P=> /eqP->; rewrite ?maxMt.
  have [sHG nHG]:= andP (p_maximal_normal pG maxH).
  have oH: #|H| = q.
    apply: double_inj; rewrite -muln2 -(p_maximal_index pG maxH) Lagrange //.
    by rewrite oG -mul2n.
  rewrite !(eq_sym (gval H)) -eq_sym !eqEcard oH -orderE ox !oMt // !leqnn.
  case sHX: (H \subset X) => //=; case/subsetPn: sHX => t Ht notXt.
  have: t \in yG :|: xyG by rewrite defX' inE notXt (subsetP sHG).
  rewrite !andbT !gen_subG /yG /xyG.
  by case/setUP=> /class_eqP <-; rewrite !class_sub_norm ?Ht ?orbT.
have n1_gt2: n.-1 > 2 by [rewrite -(subnKC n_gt3)]; have n1_gt1 := ltnW n1_gt2.
rewrite !isogEcard card_2dihedral ?card_quaternion ?oMt // leqnn !andbT.
have invX2X': {in G :\: X, forall t, x ^+ 2 ^ t == x ^- 2}.
  move=> t X't; rewrite /= invXX' ?mem_cycle // eq_sym eq_invg_mul -expgS.
  by rewrite prednK // -order_dvdn ox2.
  rewrite Grp_2dihedral ?Grp_quaternion //; split=> [||C].
- apply/existsP; exists (x ^+ 2, y); rewrite /= defMt // !xpair_eqE.
  by rewrite -!expgM def2r -!order_dvdn ox oy dvdnn eqxx /= invX2X'.
- apply/existsP; exists (x ^+ 2, x * y); rewrite /= defMt // !xpair_eqE.
  rewrite -!expgM def2r -order_dvdn ox xy2 dvdnn eqxx invX2X' //=.
  by rewrite andbT /r -(subnKC n_gt3).
case/cyclicP=> z ->{C} sCG iCG; rewrite [X]defU // defU -?cycle_subG //.
by apply: double_inj; rewrite -muln2 -iCG Lagrange // oG -mul2n.
Qed.

End ExtremalStructure.

Section ExtremalClass.

Variables (gT : finGroupType) (G : {group gT}).

Inductive extremal_group_type :=
  ModularGroup | Dihedral | SemiDihedral | Quaternion | NotExtremal.

Definition index_extremal_group_type c :=
  match c with
  | ModularGroup => 0
  | Dihedral => 1
  | SemiDihedral => 2
  | Quaternion => 3
  | NotExtremal => 4
  end%N.

Definition enum_extremal_groups :=
  [:: ModularGroup; Dihedral; SemiDihedral; Quaternion].

Lemma cancel_index_extremal_groups :
  cancel index_extremal_group_type (nth NotExtremal enum_extremal_groups).
Proof. by case. Qed.
Local Notation extgK := cancel_index_extremal_groups.

Import choice.

Definition extremal_group_eqMixin := CanEqMixin extgK.
Canonical extremal_group_eqType := EqType _ extremal_group_eqMixin.
Definition extremal_group_choiceMixin := CanChoiceMixin extgK.
Canonical extremal_group_choiceType := ChoiceType _ extremal_group_choiceMixin.
Definition extremal_group_countMixin := CanCountMixin extgK.
Canonical extremal_group_countType := CountType _ extremal_group_countMixin.
Lemma bound_extremal_groups (c : extremal_group_type) : pickle c < 6.
Proof. by case: c. Qed.
Definition extremal_group_finMixin := Finite.CountMixin bound_extremal_groups.
Canonical extremal_group_finType :=
  FinType extremal_group_type extremal_group_finMixin.

Definition extremal_class (A : {set gT}) :=
  let m := #|A| in let p := pdiv m in let n := logn p m in
  if (n > 1) && (A \isog 'D_(2 ^ n)) then Dihedral else
  if (n > 2) && (A \isog 'Q_(2 ^ n)) then Quaternion else
  if (n > 3) && (A \isog 'SD_(2 ^ n)) then SemiDihedral else
  if (n > 2) && (A \isog 'Mod_(p ^ n)) then ModularGroup else
  NotExtremal.

Definition extremal2 A := extremal_class A \in behead enum_extremal_groups.

Lemma dihedral_classP :
  extremal_class G = Dihedral <-> (exists2 n, n > 1 & G \isog 'D_(2 ^ n)).
Proof.
rewrite /extremal_class; split=> [ | [n n_gt1 isoG]].
  by move: (logn _ _) => n; do 4?case: ifP => //; case/andP; exists n.
rewrite (card_isog isoG) card_2dihedral // -(ltn_predK n_gt1) pdiv_pfactor //.
by rewrite pfactorK // (ltn_predK n_gt1) n_gt1 isoG.
Qed.

Lemma quaternion_classP :
  extremal_class G = Quaternion <-> (exists2 n, n > 2 & G \isog 'Q_(2 ^ n)).
Proof.
rewrite /extremal_class; split=> [ | [n n_gt2 isoG]].
  by move: (logn _ _) => n; do 4?case: ifP => //; case/andP; exists n.
rewrite (card_isog isoG) card_quaternion // -(ltn_predK n_gt2) pdiv_pfactor //.
rewrite pfactorK // (ltn_predK n_gt2) n_gt2 isoG.
case: andP => // [[n_gt1 isoGD]].
have [[x y] genG [oy _ _]]:= generators_quaternion n_gt2 isoG.
have [_ _ _ X'y] := genG.
by case/dihedral2_structure: genG oy => // [[_ ->]].
Qed.

Lemma semidihedral_classP :
  extremal_class G = SemiDihedral <-> (exists2 n, n > 3 & G \isog 'SD_(2 ^ n)).
Proof.
rewrite /extremal_class; split=> [ | [n n_gt3 isoG]].
  by move: (logn _ _) => n; do 4?case: ifP => //; case/andP; exists n.
rewrite (card_isog isoG) card_semidihedral //.
rewrite -(ltn_predK n_gt3) pdiv_pfactor // pfactorK // (ltn_predK n_gt3) n_gt3.
have [[x y] genG [oy _]]:= generators_semidihedral n_gt3 isoG.
have [_ Gx _ X'y]:= genG.
case: andP => [[n_gt1 isoGD]|_].
  have [[_ oxy _ _] _ _ _]:= semidihedral_structure n_gt3 genG isoG oy.
  case: (dihedral2_structure n_gt1 genG isoGD) oxy => [[_ ->]] //.
  by rewrite !inE !groupMl ?cycle_id in X'y *.
case: andP => // [[n_gt2 isoGQ]|]; last by rewrite isoG.
by case: (quaternion_structure n_gt2 genG isoGQ) oy => [[_ ->]].
Qed.

Lemma odd_not_extremal2 : odd #|G| -> ~~ extremal2 G.
Proof.
rewrite /extremal2 /extremal_class; case: logn => // n'.
case: andP => [[n_gt1 isoG] | _].
  by rewrite (card_isog isoG) card_2dihedral ?odd_exp.
case: andP => [[n_gt2 isoG] | _].
  by rewrite (card_isog isoG) card_quaternion ?odd_exp.
case: andP => [[n_gt3 isoG] | _].
  by rewrite (card_isog isoG) card_semidihedral ?odd_exp.
by case: ifP.
Qed.

Lemma modular_group_classP :
  extremal_class G = ModularGroup
     <-> (exists2 p, prime p &
          exists2 n, n >= (p == 2) + 3 & G \isog 'Mod_(p ^ n)).
Proof.
rewrite /extremal_class; split=> [ | [p p_pr [n n_gt23 isoG]]].
  move: (pdiv _) => p; set n := logn p _; do 4?case: ifP => //.
  case/andP=> n_gt2 isoG _ _; rewrite ltnW //= => not_isoG _.
  exists p; first by move: n_gt2; rewrite /n lognE; case (prime p).
  exists n => //; case: eqP => // p2; rewrite ltn_neqAle; case: eqP => // n3.
  by case/idP: not_isoG; rewrite p2 -n3 in isoG *.
have n_gt2 := leq_trans (leq_addl _ _) n_gt23; have n_gt1 := ltnW n_gt2.
have n_gt0 := ltnW n_gt1; have def_n := prednK n_gt0.
have [[x y] genG mod_xy] := generators_modular_group p_pr n_gt2 isoG.
case/modular_group_structure: (genG) => // _ _ [_ _ nil2G] _ _.
have [oG _ _ _] := genG; have [oy _] := mod_xy.
rewrite oG -def_n pdiv_pfactor // def_n pfactorK // n_gt1 n_gt2 {}isoG /=.
case: (ltngtP p 2) => [|p_gt2|p2]; first by rewrite ltnNge prime_gt1.
  rewrite !(isog_sym G) !isogEcard card_2dihedral ?card_quaternion //= oG.
  rewrite leq_exp2r // leqNgt p_gt2 !andbF; case: and3P=> // [[n_gt3 _]].
  by rewrite card_semidihedral // leq_exp2r // leqNgt p_gt2.
rewrite p2 in genG oy n_gt23; rewrite n_gt23.
have: nil_class G <> n.-1.
  by apply/eqP; rewrite neq_ltn -ltnS nil2G def_n n_gt23.
case: ifP => [isoG | _]; first by case/dihedral2_structure: genG => // _ [].
case: ifP => [isoG | _]; first by case/quaternion_structure: genG => // _ [].
by case: ifP => // isoG; case/semidihedral_structure: genG => // _ [].
Qed.

End ExtremalClass.

Theorem extremal2_structure (gT : finGroupType) (G : {group gT}) n x y :
  let cG := extremal_class G in
  let m := (2 ^ n)%N in let q := (2 ^ n.-1)%N in let r := (2 ^ n.-2)%N in
  let X := <[x]> in let yG := y ^: G in let xyG := (x * y) ^: G in
  let My := <<yG>> in let Mxy := <<xyG>> in
     extremal_generators G 2 n (x, y) ->
     extremal2 G -> (cG == SemiDihedral) ==> (#[y] == 2) ->
 [/\ [/\ (if cG == Quaternion then pprod X <[y]> else X ><| <[y]>) = G,
         if cG == SemiDihedral then #[x * y] = 4 else
           {in G :\: X, forall z, #[z] = (if cG == Dihedral then 2 else 4)},
         if cG != Quaternion then True else
         {in G, forall z, #[z] = 2 -> z = x ^+ r}
       & {in X & G :\: X, forall t z,
            t ^ z = (if cG == SemiDihedral then t ^+ r.-1 else t^-1)}],
      [/\ G ^`(1) = <[x ^+ 2]>, 'Phi(G) = G ^`(1), #|G^`(1)| = r
        & nil_class G = n.-1],
      [/\ if n > 2 then 'Z(G) = <[x ^+ r]> /\ #|'Z(G)| = 2 else 2.-abelem G,
          'Ohm_1(G) = (if cG == Quaternion then <[x ^+ r]> else
                       if cG == SemiDihedral then My else G),
          'Ohm_2(G) = G
        & forall k, k > 0 -> 'Mho^k(G) = <[x ^+ (2 ^ k)]>],
     [/\ yG :|: xyG = G :\: X, [disjoint yG & xyG]
       & forall H : {group gT}, maximal H G = (gval H \in pred3 X My Mxy)]
   & if n <= (cG == Quaternion) + 2 then True else
     [/\ forall U, cyclic U -> U \subset G -> #|G : U| = 2 -> U = X,
         if cG == Quaternion then My \isog 'Q_q else My \isog 'D_q,
         extremal_class My = (if cG == Quaternion then cG else Dihedral),
         if cG == Dihedral then Mxy \isog 'D_q else Mxy \isog 'Q_q
       & extremal_class Mxy = (if cG == Dihedral then cG else Quaternion)]].
Proof.
move=> cG m q r X yG xyG My Mxy genG; have [oG _ _ _] := genG.
have logG: logn (pdiv #|G|) #|G| = n by rewrite oG pfactorKpdiv.
rewrite /extremal2 -/cG; do [rewrite {1}/extremal_class /= {}logG] in cG *.
case: ifP => [isoG | _] in cG * => [_ _ /=|].
  case/andP: isoG => n_gt1 isoG.
  have:= dihedral2_structure n_gt1 genG isoG; rewrite -/X -/q -/r -/yG -/xyG.
  case=> [[defG oX' invXX'] nilG [defOhm defMho] maxG defZ].
  rewrite eqn_leq n_gt1 andbT add0n in defZ *; split=> //.
    split=> //; first by case: leqP defZ => // _ [].
    by apply/eqP; rewrite eqEsubset Ohm_sub -{1}defOhm Ohm_leq.
  case: leqP defZ => // n_gt2 [_ _ isoMy isoMxy defX].
  have n1_gt1: n.-1 > 1 by rewrite -(subnKC n_gt2).
  by split=> //; apply/dihedral_classP; exists n.-1.
case: ifP => [isoG | _] in cG * => [_ _ /=|].
  case/andP: isoG => n_gt2 isoG; rewrite n_gt2 add1n.
  have:= quaternion_structure n_gt2 genG isoG; rewrite -/X -/q -/r -/yG -/xyG.
  case=> [[defG oX' invXX'] nilG [defZ oZ def2 [-> ->] defMho]].
  case=> [[-> ->] maxG] isoM; split=> //.
  case: leqP isoM => // n_gt3 [//|isoMy isoMxy defX].
  have n1_gt2: n.-1 > 2 by rewrite -(subnKC n_gt3).
  by split=> //; apply/quaternion_classP; exists n.-1.
do [case: ifP => [isoG | _]; last by case: ifP] in cG * => /= _; move/eqnP=> oy.
case/andP: isoG => n_gt3 isoG; rewrite (leqNgt n) (ltnW n_gt3) /=.
have n1_gt2: n.-1 > 2 by rewrite -(subnKC n_gt3).
have:= semidihedral_structure n_gt3 genG isoG oy.
rewrite -/X -/q -/r -/yG -/xyG -/My -/Mxy.
case=> [[defG oxy invXX'] nilG [defZ oZ [-> ->] defMho] [[defX' tiX'] maxG]].
case=> isoMy isoMxy defX; do 2!split=> //.
  by apply/dihedral_classP; exists n.-1; first apply: ltnW.
by apply/quaternion_classP; exists n.-1.
Qed.

Lemma maximal_cycle_extremal gT p (G X : {group gT}) :
    p.-group G -> ~~ abelian G -> cyclic X -> X \subset G -> #|G : X| = p ->
  (extremal_class G == ModularGroup) || (p == 2) && extremal2 G.
Proof.
move=> pG not_cGG cycX sXG iXG; rewrite /extremal2; set cG := extremal_class G.
have [|p_pr _ _] := pgroup_pdiv pG.
  by case: eqP not_cGG => // ->; rewrite abelian1.
have p_gt1 := prime_gt1 p_pr; have p_gt0 := ltnW p_gt1.
have [n oG] := p_natP pG; have n_gt2: n > 2.
  apply: contraR not_cGG; rewrite -leqNgt => n_le2.
  by rewrite (p2group_abelian pG) // oG pfactorK.
have def_n := subnKC n_gt2; have n_gt1 := ltnW n_gt2; have n_gt0 := ltnW n_gt1.
pose q := (p ^ n.-1)%N; pose r := (p ^ n.-2)%N.
have q_gt1: q > 1 by rewrite (ltn_exp2l 0) // -(subnKC n_gt2).
have r_gt0: r > 0 by rewrite expn_gt0 p_gt0.
have def_pr: (p * r)%N = q by rewrite /q /r -def_n.
have oX: #|X| = q by rewrite -(divg_indexS sXG) oG iXG /q -def_n mulKn.
have ntX: X :!=: 1 by rewrite -cardG_gt1 oX.
have maxX: maximal X G by rewrite p_index_maximal ?iXG.
have nsXG: X <| G := p_maximal_normal pG maxX; have [_ nXG] := andP nsXG.
have cXX: abelian X := cyclic_abelian cycX.
have scXG: 'C_G(X) = X.
  apply/eqP; rewrite eqEsubset subsetI sXG -abelianE cXX !andbT.
  apply: contraR not_cGG; case/subsetPn=> y; case/setIP=> Gy cXy notXy.
  rewrite -!cycle_subG in Gy notXy; rewrite -(mulg_normal_maximal nsXG _ Gy) //.
  by rewrite abelianM cycle_abelian cyclic_abelian ?cycle_subG.
have [x defX] := cyclicP cycX; have pX := pgroupS sXG pG.
have Xx: x \in X by [rewrite defX cycle_id]; have Gx := subsetP sXG x Xx.
have [ox p_x]: #[x] = q /\ p.-elt x by rewrite defX in pX oX.
pose Z := <[x ^+ r]>.
have defZ: Z = 'Ohm_1(X) by rewrite defX (Ohm_p_cycle _ p_x) ox subn1 pfactorK.
have oZ: #|Z| = p by rewrite -orderE orderXdiv ox -def_pr ?dvdn_mull ?mulnK.
have cGZ: Z \subset 'C(G).
  have nsZG: Z <| G by rewrite defZ gFnormal_trans.
  move/implyP: (meet_center_nil (pgroup_nil pG) nsZG).
  rewrite -cardG_gt1 oZ p_gt1 setIA (setIidPl (normal_sub nsZG)).
  by apply: contraR; move/prime_TIg=> -> //; rewrite oZ.
have X_Gp y: y \in G -> y ^+ p \in X.
  move=> Gy; have nXy: y \in 'N(X) := subsetP nXG y Gy.
  rewrite coset_idr ?groupX // morphX //; apply/eqP.
  by rewrite -order_dvdn -iXG -card_quotient // order_dvdG ?mem_quotient.
have [y X'y]: exists2 y, y \in G :\: X &
  (p == 2) + 3 <= n /\ x ^ y = x ^+ r.+1 \/ p = 2 /\ x * x ^ y \in Z.
- have [y Gy notXy]: exists2 y, y \in G & y \notin X.
    by apply/subsetPn; rewrite proper_subn ?(maxgroupp maxX).
  have nXy: y \in 'N(X) := subsetP nXG y Gy; pose ay := conj_aut X y.
  have oay: #[ay] = p.
    apply: nt_prime_order => //.
      by rewrite -morphX // mker // ker_conj_aut (subsetP cXX) ?X_Gp.
    rewrite (sameP eqP (kerP _ nXy)) ker_conj_aut.
    by apply: contra notXy => cXy; rewrite -scXG inE Gy.
  have [m []]:= cyclic_pgroup_Aut_structure pX cycX ntX.
  set Ap := 'O_p(_); case=> def_m [m1 _] [m_inj _] _ _ _.
  have sylAp: p.-Sylow(Aut X) Ap.
    by rewrite nilpotent_pcore_Hall // abelian_nil // Aut_cyclic_abelian.
  have Ap1ay: ay \in 'Ohm_1(Ap).
    rewrite (OhmE _ (pcore_pgroup _ _)) mem_gen // !inE -order_dvdn oay dvdnn.
    rewrite (mem_normal_Hall sylAp) ?pcore_normal ?Aut_aut //.
    by rewrite /p_elt oay pnat_id.
  rewrite {1}oX pfactorK // -{1}def_n /=.
  have [p2 | odd_p] := even_prime p_pr; last first.
    rewrite (sameP eqP (prime_oddPn p_pr)) odd_p n_gt2.
    case=> _ [_ _ _] [_ _ [s [As os m_s defAp1]]].
    have [j def_s]: exists j, s = ay ^+ j.
      apply/cycleP; rewrite -cycle_subG subEproper eq_sym eqEcard -!orderE.
      by rewrite -defAp1 cycle_subG Ap1ay oay os leqnn .
    exists (y ^+ j); last first.
      left; rewrite -(norm_conj_autE _ Xx) ?groupX // morphX // -def_s.
      by rewrite -def_m // m_s expg_znat // oX pfactorK ?eqxx.
    rewrite -scXG !inE groupX //= andbT -ker_conj_aut !inE morphX // -def_s.
    rewrite andbC -(inj_in_eq m_inj) ?group1 // m_s m1 oX pfactorK // -/r.
    rewrite mulrSr -subr_eq0 addrK -val_eqE /= val_Zp_nat //.
    by rewrite [_ == 0%N]dvdn_Pexp2l // -def_n ltnn.
  rewrite {1}p2 /= => [[t [At ot m_t]]]; rewrite {1}oX pfactorK // -{1}def_n.
  rewrite eqSS subn_eq0 => defA; exists y; rewrite ?inE ?notXy //.
  rewrite p2 -(norm_conj_autE _ Xx) //= -/ay -def_m ?Aut_aut //.
  case Tay: (ay \in <[t]>).
    rewrite cycle2g // !inE -order_eq1 oay p2 /= in Tay.
    by right; rewrite (eqP Tay) m_t expg_zneg // mulgV group1.
  case: leqP defA => [_ defA|le3n [a [Aa _ _ defA [s [As os m_s m_st defA1]]]]].
    by rewrite -defA Aut_aut in Tay.
  have: ay \in [set s; s * t].
    have: ay \in 'Ohm_1(Aut X) := subsetP (OhmS 1 (pcore_sub _ _)) ay Ap1ay.
    case/dprodP: (Ohm_dprod 1 defA) => _ <- _ _.
    rewrite defA1 (@Ohm_p_cycle _ _ 2) /p_elt ot //= expg1 cycle2g //.
    by rewrite mulUg mul1g inE Tay cycle2g // mulgU mulg1 mulg_set1.
  case/set2P=> ->; [left | right].
    by rewrite ?le3n m_s expg_znat // oX pfactorK // -p2.
  by rewrite m_st expg_znat // oX pfactorK // -p2 -/r -expgS prednK ?cycle_id.
have [Gy notXy] := setDP X'y; have nXy := subsetP nXG y Gy.
have defG j: <[x]> <*> <[x ^+ j * y]> = G.
  rewrite -defX -genM_join.
  by rewrite (mulg_normal_maximal nsXG) ?cycle_subG ?groupMl ?groupX ?genGid.
have[i def_yp]: exists i, y ^- p = x ^+ i.
  by apply/cycleP; rewrite -defX groupV X_Gp.
have p_i: p %| i.
  apply: contraR notXy; rewrite -prime_coprime // => co_p_j.
  have genX: generator X (y ^- p).
    by rewrite def_yp defX generator_coprime ox coprime_expl.
  rewrite -scXG (setIidPl _) // centsC ((X :=P: _) genX) cycle_subG groupV.
  rewrite /= -(defG 0%N) mul1g centY inE -defX (subsetP cXX) ?X_Gp //.
  by rewrite (subsetP (cycle_abelian y)) ?mem_cycle.
case=> [[n_gt23 xy] | [p2 Z_xxy]].
  suffices ->: cG = ModularGroup by []; apply/modular_group_classP.
  exists p => //; exists n => //; rewrite isogEcard card_modular_group //.
  rewrite oG leqnn andbT Grp_modular_group // -/q -/r.
  have{i def_yp p_i} [i def_yp]: exists i, y ^- p = x ^+ i ^+ p.
    by case/dvdnP: p_i => j def_i; exists j; rewrite -expgM -def_i.
  have Zyx: [~ y, x] \in Z.
    by rewrite -groupV invg_comm commgEl xy expgS mulKg cycle_id.
  have def_yxj j: [~ y, x ^+ j] = [~ y, x] ^+ j.
    by rewrite commgX /commute ?(centsP cGZ _ Zyx).
  have Zyxj j: [~ y, x ^+ j] \in Z by rewrite def_yxj groupX.
  have x_xjy j: x ^ (x ^+ j * y) = x ^+ r.+1.
    by rewrite conjgM {2}/conjg commuteX //= mulKg.
  have [cyxi | not_cyxi] := eqVneq ([~ y, x ^+ i] ^+ 'C(p, 2)) 1.
    apply/existsP; exists (x, x ^+ i * y); rewrite /= !xpair_eqE.
    rewrite defG x_xjy -order_dvdn ox dvdnn !eqxx andbT /=.
    rewrite expMg_Rmul /commute ?(centsP cGZ _ (Zyxj _)) ?groupX // cyxi.
    by rewrite -def_yp -mulgA mulKg.
  have [p2 | odd_p] := even_prime p_pr; last first.
    by rewrite -order_dvdn bin2odd ?dvdn_mulr // -oZ order_dvdG in not_cyxi.
  have def_yxi: [~ y, x ^+ i] = x ^+ r.
    have:= Zyxj i; rewrite /Z cycle_traject orderE oZ p2 !inE mulg1.
    by case/pred2P=> // cyxi; rewrite cyxi p2 eqxx in not_cyxi.
  apply/existsP; exists (x, x ^+ (i + r %/ 2) * y); rewrite /= !xpair_eqE.
  rewrite defG x_xjy -order_dvdn ox dvdnn !eqxx andbT /=.
  rewrite expMg_Rmul /commute ?(centsP cGZ _ (Zyxj _)) ?groupX // def_yxj.
  rewrite -expgM mulnDl addnC !expgD (expgM x i) -def_yp mulgKV.
  rewrite -def_yxj def_yxi p2 mulgA -expgD in n_gt23 *.
  rewrite -expg_mod_order ox /q /r p2 -(subnKC n_gt23) mulnC !expnS mulKn //.
  rewrite addnn -mul2n modnn mul1g -order_dvdn dvdn_mulr //.
  by rewrite -p2 -oZ order_dvdG.
have{i def_yp p_i} Zy2: y ^+ 2 \in Z.
  rewrite defZ (OhmE _ pX) -groupV -p2 def_yp mem_gen // !inE groupX //= p2.
  rewrite expgS -{2}def_yp -(mulKg y y) -conjgE -conjXg -conjVg def_yp conjXg.
  rewrite -expgMn //; last by apply: (centsP cXX); rewrite ?memJ_norm.
  by rewrite -order_dvdn (dvdn_trans (order_dvdG Z_xxy)) ?oZ.
rewrite !cycle_traject !orderE oZ p2 !inE !mulg1 /= in Z_xxy Zy2 *.
rewrite -eq_invg_mul eq_sym -[r]prednK // expgS (inj_eq (mulgI _)) in Z_xxy.
case/pred2P: Z_xxy => xy; last first.
  suffices ->: cG = SemiDihedral by []; apply/semidihedral_classP.
  have n_gt3: n > 3.
    case: ltngtP notXy => // [|n3]; first by rewrite ltnNge n_gt2.
    rewrite -scXG inE Gy defX cent_cycle; case/cent1P; red.
    by rewrite (conjgC x) xy /r p2 n3.
  exists n => //; rewrite isogEcard card_semidihedral // oG p2 leqnn andbT.
  rewrite Grp_semidihedral //; apply/existsP=> /=.
  case/pred2P: Zy2 => y2; [exists (x, y) | exists (x, x * y)].
    by rewrite /= -{1}[y]mul1g (defG 0%N) y2 xy -p2 -/q -ox expg_order.
  rewrite /= (defG 1%N) conjgM {2}/conjg mulKg -p2 -/q -ox expg_order -xy.
  rewrite !xpair_eqE !eqxx /= andbT p2 expgS {2}(conjgC x) xy mulgA -(mulgA x).
  rewrite [y * y]y2 -expgS -expgD addSnnS prednK // addnn -mul2n -p2 def_pr.
  by rewrite -ox expg_order.
case/pred2P: Zy2 => y2.
  suffices ->: cG = Dihedral by []; apply/dihedral_classP.
  exists n => //; rewrite isogEcard card_2dihedral // oG p2 leqnn andbT.
  rewrite Grp_2dihedral //; apply/existsP; exists (x, y) => /=.
  by rewrite /= -{1}[y]mul1g (defG 0%N) y2 xy -p2 -/q -ox expg_order.
suffices ->: cG = Quaternion by []; apply/quaternion_classP.
exists n => //; rewrite isogEcard card_quaternion // oG p2 leqnn andbT.
rewrite Grp_quaternion //; apply/existsP; exists (x, y) => /=.
by rewrite /= -{1}[y]mul1g (defG 0%N) y2 xy -p2 -/q -ox expg_order.
Qed.

Lemma cyclic_SCN gT p (G U : {group gT}) :
    p.-group G -> U \in 'SCN(G) -> ~~ abelian G -> cyclic U ->
    [/\ p = 2, #|G : U| = 2 & extremal2 G]
\/ exists M : {group gT},
   [/\ M :=: 'C_G('Mho^1(U)), #|M : U| = p, extremal_class M = ModularGroup,
       'Ohm_1(M)%G \in 'E_p^2(G) & 'Ohm_1(M) \char G].
Proof.
move=> pG /SCN_P[nsUG scUG] not_cGG cycU; have [sUG nUG] := andP nsUG.
have [cUU pU] := (cyclic_abelian cycU, pgroupS sUG pG).
have ltUG: ~~ (G \subset U).
  by apply: contra not_cGG => sGU; apply: abelianS cUU.
have ntU: U :!=: 1.
  by apply: contraNneq ltUG => U1; rewrite -scUG subsetIidl U1 cents1.
have [p_pr _ [n oU]] := pgroup_pdiv pU ntU.
have p_gt1 := prime_gt1 p_pr; have p_gt0 := ltnW p_gt1.
have [u defU] := cyclicP cycU; have Uu: u \in U by rewrite defU cycle_id.
have Gu := subsetP sUG u Uu; have p_u := mem_p_elt pG Gu.
have defU1: 'Mho^1(U) = <[u ^+ p]> by rewrite defU (Mho_p_cycle _ p_u).
have modM1 (M : {group gT}):
    [/\ U \subset M, #|M : U| = p & extremal_class M = ModularGroup] ->
  M :=: 'C_M('Mho^1(U)) /\ 'Ohm_1(M)%G \in 'E_p^2(M).
- case=> sUM iUM /modular_group_classP[q q_pr {n oU}[n n_gt23 isoM]].
  have n_gt2: n > 2 by apply: leq_trans (leq_addl _ _) n_gt23.
  have def_n: n = (n - 3).+3 by rewrite -{1}(subnKC n_gt2).
  have oM: #|M| = (q ^ n)%N by rewrite (card_isog isoM) card_modular_group.
  have pM: q.-group M by rewrite /pgroup oM pnat_exp pnat_id.
  have def_q: q = p; last rewrite {q q_pr}def_q in oM pM isoM n_gt23.
    by apply/eqP; rewrite eq_sym [p == q](pgroupP pM) // -iUM dvdn_indexg.
  have [[x y] genM modM] := generators_modular_group p_pr n_gt2 isoM.
  case/modular_group_structure: genM => // _ [defZ _ oZ] _ defMho.
  have ->: 'Mho^1(U) = 'Z(M).
    apply/eqP; rewrite eqEcard oZ defZ -(defMho 1%N) ?MhoS //= defU1 -orderE.
    suff ou: #[u] = (p * p ^ n.-2)%N by rewrite orderXdiv ou ?dvdn_mulr ?mulKn.
    by rewrite orderE -defU -(divg_indexS sUM) iUM oM def_n mulKn.
  case: eqP => [[p2 n3] | _ defOhm]; first by rewrite p2 n3 in n_gt23.
  have{defOhm} [|defM1 oM1] := defOhm 1%N; first by rewrite def_n.
  split; rewrite ?(setIidPl _) //; first by rewrite centsC subsetIr.
  rewrite inE oM1 pfactorK // andbT inE Ohm_sub abelem_Ohm1 //.
  exact: (card_p2group_abelian p_pr oM1).
have ou: #[u] = (p ^ n.+1)%N by rewrite defU in oU.
pose Gs := G / U; have pGs: p.-group Gs by rewrite quotient_pgroup.
have ntGs: Gs != 1 by rewrite -subG1 quotient_sub1.
have [_ _ [[|k] oGs]] := pgroup_pdiv pGs ntGs.
  have iUG: #|G : U| = p by rewrite -card_quotient ?oGs.
  case: (predU1P (maximal_cycle_extremal _ _ _ _ iUG)) => // [modG | ext2G].
    by right; exists G; case: (modM1 G) => // <- ->; rewrite Ohm_char.
  by left; case: eqP ext2G => // <-.
pose M := 'C_G('Mho^1(U)); right; exists [group of M].
have sMG: M \subset G by apply: subsetIl.
have [pM nUM] := (pgroupS sMG pG, subset_trans sMG nUG).
have sUM: U \subset M by rewrite subsetI sUG sub_abelian_cent ?Mho_sub.
pose A := Aut U; have cAA: abelian A by rewrite Aut_cyclic_abelian.
have sylAp: p.-Sylow(A) 'O_p(A) by rewrite nilpotent_pcore_Hall ?abelian_nil.
have [f [injf sfGsA fG]]: exists f : {morphism Gs >-> {perm gT}},
   [/\ 'injm f, f @* Gs \subset A & {in G, forall y, f (coset U y) u = u ^ y}].
- have [] := first_isom_loc [morphism of conj_aut U] nUG.
  rewrite ker_conj_aut scUG /= -/Gs => f injf im_f.
  exists f; rewrite im_f ?Aut_conj_aut //.
  split=> // y Gy; have nUy := subsetP nUG y Gy.
  suffices ->: f (coset U y) = conj_aut U y by rewrite norm_conj_autE.
  by apply: set1_inj; rewrite -!morphim_set1 ?mem_quotient // im_f ?sub1set.
have cGsGs: abelian Gs by rewrite -(injm_abelian injf) // (abelianS sfGsA).
have p_fGs: p.-group (f @* Gs) by rewrite morphim_pgroup.
have sfGsAp: f @* Gs \subset 'O_p(A) by rewrite (sub_Hall_pcore sylAp).
have [a [fGa oa au n_gt01 cycGs]]: exists a,
  [/\ a \in f @* Gs, #[a] = p, a u = u ^+ (p ^ n).+1, (p == 2) + 1 <= n
    & cyclic Gs \/ p = 2 /\ (exists2 c, c \in f @* Gs & c u = u^-1)].
- have [m [[def_m _ _ _ _] _]] := cyclic_pgroup_Aut_structure pU cycU ntU.
  have ->: logn p #|U| = n.+1 by rewrite oU pfactorK.
  rewrite /= -/A; case: posnP => [_ defA | n_gt0 [c [Ac oc m_c defA]]].
    have:= cardSg sfGsAp; rewrite (card_Hall sylAp) /= -/A defA card_injm //.
    by rewrite oGs (part_p'nat (pcore_pgroup _ _)) pfactor_dvdn // logn1.
  have [p2 | odd_p] := even_prime p_pr; last first.
    case: eqP => [-> // | _] in odd_p *; rewrite odd_p in defA.
    have [[cycA _] _ [a [Aa oa m_a defA1]]] := defA.
    exists a; rewrite -def_m // oa m_a expg_znat //.
    split=> //; last by left; rewrite -(injm_cyclic injf) ?(cyclicS sfGsA).
    have: f @* Gs != 1 by rewrite morphim_injm_eq1.
    rewrite -cycle_subG; apply: contraR => not_sfGs_a.
    by rewrite -(setIidPl sfGsAp) TI_Ohm1 // defA1 setIC prime_TIg -?orderE ?oa.
  do [rewrite {1}p2 /= eqn_leq n_gt0; case: leqP => /= [_ | n_gt1]] in defA.
    have:= cardSg sfGsAp; rewrite (card_Hall sylAp) /= -/A defA -orderE oc p2.
    by rewrite card_injm // oGs p2 pfactor_dvdn // p_part.
  have{defA} [s [As os _ defA [a [Aa oa m_a _ defA1]]]] := defA; exists a.
  have fGs_a: a \in f @* Gs.
    suffices: f @* Gs :&: <[s]> != 1.
      apply: contraR => not_fGs_a; rewrite TI_Ohm1 // defA1 setIC.
      by rewrite prime_TIg -?orderE ?oa // cycle_subG.
    have: (f @* Gs) * <[s]> \subset A by rewrite mulG_subG cycle_subG sfGsA.
    move/subset_leq_card; apply: contraL; move/eqP; move/TI_cardMg->.
    rewrite -(dprod_card defA) -ltnNge mulnC -!orderE ltn_pmul2r // oc.
    by rewrite card_injm // oGs p2 (ltn_exp2l 1%N).
  rewrite -def_m // oa m_a expg_znat // p2; split=> //.
  rewrite abelian_rank1_cyclic // (rank_pgroup pGs) //.
  rewrite -(injm_p_rank injf) // p_rank_abelian 1?morphim_abelian //= p2 -/Gs.
  case: leqP => [|fGs1_gt1]; [by left | right].
  split=> //; exists c; last by rewrite -def_m // m_c expg_zneg.
  have{defA1} defA1: <[a]> \x <[c]> = 'Ohm_1(Aut U).
    by rewrite -(Ohm_dprod 1 defA) defA1 (@Ohm_p_cycle 1 _ 2) /p_elt oc.
  have def_fGs1: 'Ohm_1(f @* Gs) = 'Ohm_1(A).
    apply/eqP; rewrite eqEcard OhmS // -(dprod_card defA1) -!orderE oa oc.
    by rewrite dvdn_leq ?(@pfactor_dvdn 2 2) ?cardG_gt0.
  rewrite (subsetP (Ohm_sub 1 _)) // def_fGs1 -cycle_subG.
  by case/dprodP: defA1 => _ <- _ _; rewrite mulG_subr.
have n_gt0: n > 0 := leq_trans (leq_addl _ _) n_gt01.
have [ys Gys _ def_a] := morphimP fGa.
have oys: #[ys] = p by rewrite -(order_injm injf) // -def_a oa.
have defMs: M / U = <[ys]>.
  apply/eqP; rewrite eq_sym eqEcard -orderE oys cycle_subG; apply/andP; split.
    have [y nUy Gy /= def_ys] := morphimP Gys.
    rewrite def_ys mem_quotient //= inE Gy defU1 cent_cycle cent1C.
    rewrite (sameP cent1P commgP) commgEl conjXg -fG //= -def_ys -def_a au.
    by rewrite -expgM mulSn expgD mulKg -expnSr -ou expg_order.
  rewrite card_quotient // -(setIidPr sUM) -scUG setIA (setIidPl sMG).
  rewrite defU cent_cycle index_cent1 -(card_imset _ (mulgI u^-1)) -imset_comp.
  have <-: #|'Ohm_1(U)| = p.
    rewrite defU (Ohm_p_cycle 1 p_u) -orderE (orderXexp _ ou) ou pfactorK //.
    by rewrite subKn.
  rewrite (OhmE 1 pU) subset_leq_card ?sub_gen //.
  apply/subsetP=> _ /imsetP[z /setIP[/(subsetP nUG) nUz cU1z] ->].
  have Uv' := groupVr Uu; have Uuz: u ^ z \in U by rewrite memJ_norm.
  rewrite !inE groupM // expgMn /commute 1?(centsP cUU u^-1) //= expgVn -conjXg.
  by rewrite (sameP commgP cent1P) cent1C -cent_cycle -defU1.
have iUM: #|M : U| = p by rewrite -card_quotient ?defMs.
have not_cMM: ~~ abelian M.
  apply: contraL p_pr => cMM; rewrite -iUM -indexgI /= -/M.
  by rewrite (setIidPl _) ?indexgg // -scUG subsetI sMG sub_abelian_cent.
have modM: extremal_class M = ModularGroup.
  have sU1Z: 'Mho^1(U) \subset 'Z(M).
    by rewrite subsetI gFsub_trans // centsC subsetIr.
  have /maximal_cycle_extremal/predU1P[] //= := iUM; rewrite -/M.
  case/andP=> /eqP-p2 ext2M; rewrite p2 add1n in n_gt01.
  suffices{sU1Z}: #|'Z(M)| = 2.
    move/eqP; rewrite eqn_leq leqNgt (leq_trans _ (subset_leq_card sU1Z)) //.
    by rewrite defU1 -orderE (orderXexp 1 ou) subn1 p2 (ltn_exp2l 1).
  move: ext2M; rewrite /extremal2 !inE orbC -orbA; case/or3P; move/eqP.
  - case/semidihedral_classP=> m m_gt3 isoM.
    have [[x z] genM [oz _]] := generators_semidihedral m_gt3 isoM.
    by case/semidihedral_structure: genM => // _ _ [].
  - case/quaternion_classP=> m m_gt2 isoM.
    have [[x z] genM _] := generators_quaternion m_gt2 isoM.
    by case/quaternion_structure: genM => // _ _ [].
  case/dihedral_classP=> m m_gt1 isoM.
  have [[x z] genM _] := generators_2dihedral m_gt1 isoM.
  case/dihedral2_structure: genM not_cMM => // _ _ _ _.
  by case: (m == 2) => [|[]//]; move/abelem_abelian->.
split=> //.
  have [//|_] := modM1 [group of M]; rewrite !inE -andbA /=.
  by case/andP=> /subset_trans->.
have{cycGs} [cycGs | [p2 [c fGs_c u_c]]] := cycGs.
  suffices ->: 'Ohm_1(M) = 'Ohm_1(G) by apply: Ohm_char.
  suffices sG1M: 'Ohm_1(G) \subset M.
    by apply/eqP; rewrite eqEsubset -{2}(Ohm_id 1 G) !OhmS.
  rewrite -(quotientSGK _ sUM) ?(subset_trans (Ohm_sub _ G)) //= defMs.
  suffices ->: <[ys]> = 'Ohm_1(Gs) by rewrite morphim_Ohm.
  apply/eqP; rewrite eqEcard -orderE cycle_subG /= {1}(OhmE 1 pGs) /=.
  rewrite mem_gen ?inE ?Gys -?order_dvdn oys //=.
  rewrite -(part_pnat_id (pgroupS (Ohm_sub _ _) pGs)) p_part (leq_exp2l _ 1) //.
  by rewrite -p_rank_abelian -?rank_pgroup -?abelian_rank1_cyclic.
suffices charU1: 'Mho^1(U) \char G^`(1).
  by rewrite gFchar_trans // subcent_char ?(char_trans charU1) ?gFchar.
suffices sUiG': 'Mho^1(U) \subset G^`(1).
  have /cyclicP[zs cycG']: cyclic G^`(1) by rewrite (cyclicS _ cycU) ?der1_min.
  by rewrite cycG' in sUiG' *; apply: cycle_subgroup_char.
rewrite defU1 cycle_subG p2 -groupV invMg -{2}u_c.
by have [_ _ /morphimP[z _ Gz ->] ->] := morphimP fGs_c; rewrite fG ?mem_commg.
Qed.

Lemma normal_rank1_structure gT p (G : {group gT}) :
    p.-group G -> (forall X : {group gT}, X <| G -> abelian X -> cyclic X) ->
  cyclic G \/ [&& p == 2, extremal2 G & (#|G| >= 16) || (G \isog 'Q_8)].
Proof.
move=> pG dn_G_1.
have [cGG | not_cGG] := boolP (abelian G); first by left; rewrite dn_G_1.
have [X maxX]: {X | [max X | X <| G & abelian X]}.
  by apply: ex_maxgroup; exists 1%G; rewrite normal1 abelian1.
have cycX: cyclic X by rewrite dn_G_1; case/andP: (maxgroupp maxX).
have scX: X \in 'SCN(G) := max_SCN pG maxX.
have [[p2 _ cG] | [M [_ _ _]]] := cyclic_SCN pG scX not_cGG cycX; last first.
  rewrite 2!inE -andbA => /and3P[sEG abelE dimE_2] charE.
  have:= dn_G_1 _ (char_normal charE) (abelem_abelian abelE).
  by rewrite (abelem_cyclic abelE) (eqP dimE_2).
have [n oG] := p_natP pG; right; rewrite p2 cG /= in oG *.
rewrite oG (@leq_exp2l 2 4) //.
rewrite /extremal2 /extremal_class oG pfactorKpdiv // in cG.
case: andP cG => [[n_gt1 isoG] _ | _]; last first.
  by rewrite leq_eqVlt; case: (3 < n); case: eqP => //= <-; do 2?case: ifP.
have [[x y] genG _] := generators_2dihedral n_gt1 isoG.
have [_ _ _ [_ _ maxG]] := dihedral2_structure n_gt1 genG isoG.
rewrite 2!ltn_neqAle n_gt1 !(eq_sym _ n).
case: eqP => [_ abelG| _]; first by rewrite (abelem_abelian abelG) in not_cGG.
case: eqP => // -> [_ _ isoY _ _]; set Y := <<_>> in isoY.
have nxYG: Y <| G by rewrite (p_maximal_normal pG) // maxG !inE eqxx orbT.
have [// | [u v] genY _] := generators_2dihedral _ isoY.
case/dihedral2_structure: (genY) => //= _ _ _ _ abelY.
have:= dn_G_1 _ nxYG (abelem_abelian abelY).
by rewrite (abelem_cyclic abelY); case: genY => ->.
Qed.

Lemma odd_pgroup_rank1_cyclic gT p (G : {group gT}) :
  p.-group G -> odd #|G| -> cyclic G = ('r_p(G) <= 1).
Proof.
move=> pG oddG; rewrite -rank_pgroup //; apply/idP/idP=> [cycG | dimG1].
  by rewrite -abelian_rank1_cyclic ?cyclic_abelian.
have [X nsXG cXX|//|] := normal_rank1_structure pG; last first.
  by rewrite (negPf (odd_not_extremal2 oddG)) andbF.
by rewrite abelian_rank1_cyclic // (leq_trans (rankS (normal_sub nsXG))).
Qed.

Lemma prime_Ohm1P gT p (G : {group gT}) :
    p.-group G -> G :!=: 1 ->
  reflect (#|'Ohm_1(G)| = p)
          (cyclic G || (p == 2) && (extremal_class G == Quaternion)).
Proof.
move=> pG ntG; have [p_pr p_dvd_G _] := pgroup_pdiv pG ntG.
apply: (iffP idP) => [|oG1p].
  case/orP=> [cycG|]; first exact: Ohm1_cyclic_pgroup_prime.
  case/andP=> /eqP p2 /eqP/quaternion_classP[n n_gt2 isoG].
  rewrite p2; have [[x y]] := generators_quaternion n_gt2 isoG.
  by case/quaternion_structure=> // _ _ [<- oZ _ [->]].
have [X nsXG cXX|-> //|]:= normal_rank1_structure pG.
  have [sXG _] := andP nsXG; have pX := pgroupS sXG pG.
  rewrite abelian_rank1_cyclic // (rank_pgroup pX) p_rank_abelian //.
  rewrite -{2}(pfactorK 1 p_pr) -{3}oG1p dvdn_leq_log ?cardG_gt0 //.
  by rewrite cardSg ?OhmS.
case/and3P=> /eqP p2; rewrite p2 (orbC (cyclic G)) /extremal2.
case cG: (extremal_class G) => //; case: notF.
  case/dihedral_classP: cG => n n_gt1 isoG.
  have [[x y] genG _] := generators_2dihedral n_gt1 isoG.
  have [oG _ _ _] := genG; case/dihedral2_structure: genG => // _ _ [defG1 _] _.
  by case/idPn: n_gt1; rewrite -(@ltn_exp2l 2) // -oG -defG1 oG1p p2.
case/semidihedral_classP: cG => n n_gt3 isoG.
have [[x y] genG [oy _]] := generators_semidihedral n_gt3 isoG.
case/semidihedral_structure: genG => // _ _ [_ _ [defG1 _] _] _ [isoG1 _ _].
case/idPn: (n_gt3); rewrite -(ltn_predK n_gt3) ltnS -leqNgt -(@leq_exp2l 2) //.
rewrite -card_2dihedral //; last by rewrite -(subnKC n_gt3).
by rewrite -(card_isog isoG1) /= -defG1 oG1p p2.
Qed.

Theorem symplectic_type_group_structure gT p (G : {group gT}) :
    p.-group G -> (forall X : {group gT}, X \char G -> abelian X -> cyclic X) ->
  exists2 E : {group gT}, E :=: 1 \/ extraspecial E
  & exists R : {group gT},
    [/\ cyclic R \/ [/\ p = 2, extremal2 R & #|R| >= 16],
        E \* R = G
      & E :&: R = 'Z(E)].
Proof.
move=> pG sympG; have [H [charH]] := Thompson_critical pG.
have sHG := char_sub charH; have pH := pgroupS sHG pG.
set U := 'Z(H) => sPhiH_U sHG_U defU; set Z := 'Ohm_1(U).
have sZU: Z \subset U by rewrite Ohm_sub.
have charU: U \char G := gFchar_trans _ charH.
have cUU: abelian U := center_abelian H.
have cycU: cyclic U by apply: sympG.
have pU: p.-group U := pgroupS (char_sub charU) pG.
have cHU: U \subset 'C(H) by rewrite subsetIr.
have cHsHs: abelian (H / Z).
  rewrite sub_der1_abelian //= (OhmE _ pU) genS //= -/U.
  apply/subsetP=> _ /imset2P[h k Hh Hk ->].
  have Uhk: [~ h, k] \in U by rewrite (subsetP sHG_U) ?mem_commg ?(subsetP sHG).
  rewrite inE Uhk inE -commXg; last by red; rewrite -(centsP cHU).
  apply/commgP; red; rewrite (centsP cHU) // (subsetP sPhiH_U) //.
  by rewrite (Phi_joing pH) mem_gen // inE orbC (Mho_p_elt 1) ?(mem_p_elt pH).
have nsZH: Z <| H by rewrite sub_center_normal.
have [K /=] := inv_quotientS nsZH (Ohm_sub 1 (H / Z)); fold Z => defKs sZK sKH.
have nsZK: Z <| K := normalS sZK sKH nsZH; have [_ nZK] := andP nsZK.
have abelKs: p.-abelem (K / Z) by rewrite -defKs Ohm1_abelem ?quotient_pgroup.
have charK: K \char G.
  have charZ: Z \char H := gFchar_trans _ (center_char H).
  rewrite (char_trans _ charH) // (char_from_quotient nsZK) //.
  by rewrite -defKs Ohm_char.
have cycZK: cyclic 'Z(K) by rewrite sympG ?center_abelian ?gFchar_trans.
have [cKK | not_cKK] := orP (orbN (abelian K)).
  have defH: U = H.
    apply: center_idP; apply: cyclic_factor_abelian (Ohm_sub 1 _) _.
    rewrite /= -/Z abelian_rank1_cyclic //.
    have cKsKs: abelian (K / Z) by rewrite -defKs (abelianS (Ohm_sub 1 _)).
    have cycK: cyclic K by rewrite -(center_idP cKK).
    by rewrite -rank_Ohm1 defKs -abelian_rank1_cyclic ?quotient_cyclic.
  have scH: H \in 'SCN(G) by apply/SCN_P; rewrite defU char_normal.
  have [cGG | not_cGG] := orP (orbN (abelian G)).
    exists 1%G; [by left | exists G; rewrite cprod1g (setIidPl _) ?sub1G //].
    by split; first left; rewrite ?center1 // sympG ?char_refl.
  have cycH: cyclic H by rewrite -{}defH.
  have [[p2 _ cG2]|[M [_ _ _]]] := cyclic_SCN pG scH not_cGG cycH; last first.
    do 2![case/setIdP] => _ abelE dimE_2 charE.
    have:= sympG _ charE (abelem_abelian abelE).
    by rewrite (abelem_cyclic abelE) (eqP dimE_2).
  have [n oG] := p_natP pG; rewrite p2 in oG.
  have [n_gt3 | n_le3] := ltnP 3 n.
    exists 1%G; [by left | exists G; rewrite cprod1g (setIidPl _) ?sub1G //].
    by split; first right; rewrite ?center1 // oG (@leq_exp2l 2 4).
  have esG: extraspecial G.
    by apply: (p3group_extraspecial pG); rewrite // p2 oG pfactorK.
  exists G; [by right | exists ('Z(G))%G; rewrite cprod_center_id setIA setIid].
  by split=> //; left; rewrite prime_cyclic; case: esG.
have ntK: K :!=: 1 by apply: contra not_cKK => /eqP->; apply: abelian1.
have [p_pr _ _] := pgroup_pdiv (pgroupS sKH pH) ntK.
have p_gt1 := prime_gt1 p_pr; have p_gt0 := ltnW p_gt1.
have oZ: #|Z| = p.
  apply: Ohm1_cyclic_pgroup_prime => //=; apply: contra ntK; move/eqP.
  by move/(trivg_center_pgroup pH)=> GH; rewrite -subG1 -GH.
have sZ_ZK: Z \subset 'Z(K).
  by rewrite subsetI sZK gFsub_trans // subIset ?centS ?orbT.
have sZsKs: 'Z(K) / Z \subset K / Z by rewrite quotientS ?center_sub.
have [Es /= splitKs] := abelem_split_dprod abelKs sZsKs.
have [_ /= defEsZs cEsZs tiEsZs] := dprodP splitKs.
have sEsKs: Es \subset K / Z by rewrite -defEsZs mulG_subr.
have [E defEs sZE sEK] := inv_quotientS nsZK sEsKs; rewrite /= -/Z in defEs sZE.
have [nZE nZ_ZK] := (subset_trans sEK nZK, subset_trans (center_sub K) nZK).
have defK: 'Z(K) * E = K.
  rewrite -(mulSGid sZ_ZK) -mulgA -quotientK ?mul_subG ?quotientMl //.
  by rewrite -defEs defEsZs quotientGK.
have defZE: 'Z(E) = Z.
  have cEZK: 'Z(K) \subset 'C(E) by rewrite subIset // orbC centS.
  have cE_Z: E \subset 'C(Z) by rewrite centsC (subset_trans sZ_ZK).
  apply/eqP; rewrite eqEsubset andbC subsetI sZE centsC cE_Z /=.
  rewrite -quotient_sub1 ?subIset ?nZE //= -/Z -tiEsZs subsetI defEs.
  rewrite !quotientS ?center_sub //= subsetI subIset ?sEK //=.
  by rewrite -defK centM setSI // centsC.
have sEH := subset_trans sEK sKH; have pE := pgroupS sEH pH.
have esE: extraspecial E.
  split; last by rewrite defZE oZ.
  have sPhiZ: 'Phi(E) \subset Z.
    rewrite -quotient_sub1 ?gFsub_trans ?(quotient_Phi pE) //.
    rewrite subG1 (trivg_Phi (quotient_pgroup _ pE)) /= -defEs.
    by rewrite (abelemS sEsKs) //= -defKs Ohm1_abelem ?quotient_pgroup.
  have sE'Phi: E^`(1) \subset 'Phi(E) by rewrite (Phi_joing pE) joing_subl.
  have ntE': E^`(1) != 1.
    rewrite (sameP eqP commG1P) -abelianE; apply: contra not_cKK => cEE.
    by rewrite -defK mulGSid ?center_abelian // -(center_idP cEE) defZE.
  have defE': E^`(1) = Z.
    apply/eqP; rewrite eqEcard (subset_trans sE'Phi) //= oZ.
    have [_ _ [n ->]] := pgroup_pdiv (pgroupS (der_sub _ _) pE) ntE'.
    by rewrite (leq_exp2l 1) ?prime_gt1.
  by split; rewrite defZE //; apply/eqP; rewrite eqEsubset sPhiZ -defE'.
have [spE _] := esE; have [defPhiE defE'] := spE.
have{defE'} sEG_E': [~: E, G] \subset E^`(1).
  rewrite defE' defZE /Z (OhmE _ pU) commGC genS //.
  apply/subsetP=> _ /imset2P[g e Gg Ee ->].
  have He: e \in H by rewrite (subsetP sKH) ?(subsetP sEK).
  have Uge: [~ g, e] \in U by rewrite (subsetP sHG_U) ?mem_commg.
  rewrite inE Uge inE -commgX; last by red; rewrite -(centsP cHU).
  have sZ_ZG: Z \subset 'Z(G).
    have charZ: Z \char G := gFchar_trans _ charU.
    have/implyP:= meet_center_nil (pgroup_nil pG) (char_normal charZ).
    rewrite -cardG_gt1 oZ prime_gt1 //=; apply: contraR => not_sZ_ZG.
    by rewrite prime_TIg ?oZ.
  have: e ^+ p \in 'Z(G).
    rewrite (subsetP sZ_ZG) // -defZE -defPhiE (Phi_joing pE) mem_gen //.
    by rewrite inE orbC (Mho_p_elt 1) ?(mem_p_elt pE).
  by case/setIP=> _ /centP cGep; apply/commgP; red; rewrite cGep.
have sEG: E \subset G := subset_trans sEK (char_sub charK).
set R := 'C_G(E).
have{sEG_E'} defG: E \* R = G by apply: (critical_extraspecial pG).
have [_ defER cRE] := cprodP defG.
have defH: E \* 'C_H(E) = H by rewrite -(setIidPr sHG) setIAC (cprod_modl defG).
have{defH} [_ defH cRH_E] := cprodP defH.
have cRH_RH: abelian 'C_H(E).
  have sZ_ZRH: Z \subset 'Z('C_H(E)).
    rewrite subsetI -{1}defZE setSI //= (subset_trans sZU) // centsC.
    by rewrite subIset // centsC cHU.
  rewrite (cyclic_factor_abelian sZ_ZRH) //= -/Z.
  have defHs: Es \x ('C_H(E) / Z) = H / Z.
    rewrite defEs dprodE ?quotient_cents // -?quotientMl ?defH -?quotientGI //=.
    by rewrite setIA (setIidPl sEH) ['C_E(E)]defZE trivg_quotient.
  have:= Ohm_dprod 1 defHs; rewrite /= defKs (Ohm1_id (abelemS sEsKs abelKs)).
  rewrite dprodC; case/dprodP=> _ defEsRHs1 cRHs1Es tiRHs1Es.
  have sRHsHs: 'C_H(E) / Z \subset H / Z by rewrite quotientS ?subsetIl.
  have cRHsRHs: abelian ('C_H(E) / Z) by apply: abelianS cHsHs.
  have pHs: p.-group (H / Z) by rewrite quotient_pgroup.
  rewrite abelian_rank1_cyclic // (rank_pgroup (pgroupS sRHsHs pHs)).
  rewrite p_rank_abelian // -(leq_add2r (logn p #|Es|)) -lognM ?cardG_gt0 //.
  rewrite -TI_cardMg // defEsRHs1 /= -defEsZs TI_cardMg ?lognM ?cardG_gt0 //.
  by rewrite leq_add2r -abelem_cyclic ?(abelemS sZsKs) // quotient_cyclic.
have{cRH_RH} defRH: 'C_H(E) = U.
  apply/eqP; rewrite eqEsubset andbC setIS ?centS // subsetI subsetIl /=.
  by rewrite -{2}defH centM subsetI subsetIr.
have scUR: 'C_R(U) = U by rewrite -setIA -{1}defRH -centM defH.
have sUR: U \subset R by rewrite -defRH setSI.
have tiER: E :&: R = 'Z(E) by rewrite setIA (setIidPl (subset_trans sEH sHG)).
have [cRR | not_cRR] := boolP (abelian R).
  exists E; [by right | exists [group of R]; split=> //; left].
  by rewrite /= -(setIidPl (sub_abelian_cent cRR sUR)) scUR.
have{scUR} scUR: [group of U] \in 'SCN(R).
  by apply/SCN_P; rewrite (normalS sUR (subsetIl _ _)) // char_normal.
have pR: p.-group R := pgroupS (subsetIl _ _) pG.
have [R_le_3 | R_gt_3] := leqP (logn p #|R|) 3.
  have esR: extraspecial R := p3group_extraspecial pR not_cRR R_le_3.
  have esG: extraspecial G := cprod_extraspecial pG defG tiER esE esR.
  exists G; [by right | exists ('Z(G))%G; rewrite cprod_center_id setIA setIid].
  by split=> //; left; rewrite prime_cyclic; case: esG.
have [[p2 _ ext2R] | [M []]] := cyclic_SCN pR scUR not_cRR cycU.
  exists E; [by right | exists [group of R]; split=> //; right].
  by rewrite dvdn_leq ?(@pfactor_dvdn 2 4) ?cardG_gt0 // -{2}p2.
rewrite /= -/R => defM iUM modM _ _; pose N := 'C_G('Mho^1(U)).
have charZN2: 'Z('Ohm_2(N)) \char G by rewrite !(gFchar_trans, subcent_char).
have:= sympG _ charZN2 (center_abelian _).
rewrite abelian_rank1_cyclic ?center_abelian // leqNgt; case/negP.
have defN: E \* M = N.
  rewrite defM (cprod_modl defG) // centsC gFsub_trans //= -/U.
  by rewrite -defRH subsetIr.
case/modular_group_classP: modM => q q_pr [n n_gt23 isoM].
have{n_gt23} n_gt2 := leq_trans (leq_addl _ _) n_gt23.
have n_gt1 := ltnW n_gt2; have n_gt0 := ltnW n_gt1.
have [[x y] genM modM] := generators_modular_group q_pr n_gt2 isoM.
have{q_pr} defq: q = p; last rewrite {q}defq in genM modM isoM.
  have: p %| #|M| by rewrite -iUM dvdn_indexg.
  by have [-> _ _ _] := genM; rewrite Euclid_dvdX // dvdn_prime2 //; case: eqP.
have [oM Mx ox X'y] := genM; have [My _] := setDP X'y; have [oy _] := modM.
have [sUM sMR]: U \subset M /\ M \subset R.
  by rewrite defM subsetI sUR subsetIl centsC gFsub_trans.
have oU1: #|'Mho^1(U)| = (p ^ n.-2)%N.
  have oU: #|U| = (p ^ n.-1)%N.
    by rewrite -(divg_indexS sUM) iUM oM -subn1 expnB.
  case/cyclicP: cycU pU oU => u -> p_u ou.
  by rewrite (Mho_p_cycle 1 p_u) -orderE (orderXexp 1 ou) subn1.
have sZU1: Z \subset 'Mho^1(U).
  rewrite -(cardSg_cyclic cycU) ?gFsub // oZ oU1.
  by rewrite -(subnKC n_gt2) expnS dvdn_mulr.
case/modular_group_structure: genM => // _ [defZM _ oZM] _ _.
have:= n_gt2; rewrite leq_eqVlt eq_sym !xpair_eqE andbC.
case: eqP => [n3 _ _ | _ /= n_gt3 defOhmM].
  have eqZU1: Z = 'Mho^1(U) by apply/eqP; rewrite eqEcard sZU1 oZ oU1 n3 /=.
  rewrite (setIidPl _) in defM; first by rewrite -defM oM n3 pfactorK in R_gt_3.
  by rewrite -eqZU1 subIset ?centS ?orbT.
have{defOhmM} [|defM2 _] := defOhmM 2; first by rewrite -subn1 ltn_subRL.
do [set xpn3 := x ^+ _; set X2 := <[_]>] in defM2.
have oX2: #|X2| = (p ^ 2)%N.
  by rewrite -orderE (orderXexp _ ox) -{1}(subnKC n_gt2) addSn addnK.
have sZX2: Z \subset X2.
  have cycXp: cyclic <[x ^+ p]> := cycle_cyclic _.
  rewrite -(cardSg_cyclic cycXp) /=; first by rewrite oZ oX2 dvdn_mull.
    rewrite -defZM subsetI (subset_trans (Ohm_sub _ _)) //=.
    by rewrite (subset_trans sZU1) // centsC defM subsetIr.
  by rewrite /xpn3 -subnSK //expnS expgM cycleX.
have{defM2} [_ /= defM2 cYX2 tiX2Y] := dprodP defM2.
have{defN} [_ defN cME] := cprodP defN.
have cEM2: E \subset 'C('Ohm_2(M)).
  by rewrite centsC (subset_trans _ cME) ?centS ?Ohm_sub.
have [cEX2 cYE]: X2 \subset 'C(E) /\ E \subset 'C(<[y]>).
 by apply/andP; rewrite centsC -subsetI -centM defM2.
have pN: p.-group N := pgroupS (subsetIl _ _) pG.
have defN2: (E <*> X2) \x <[y]> = 'Ohm_2(N).
  rewrite dprodE ?centY ?subsetI 1?centsC ?cYE //=; last first.
    rewrite -cycle_subG in My; rewrite joingC cent_joinEl //= -/X2.
    rewrite -(setIidPr My) setIA -group_modl ?cycle_subG ?groupX //.
    by rewrite mulGSid // (subset_trans _ sZX2) // -defZE -tiER setIS.
  apply/eqP; rewrite cent_joinEr // -mulgA defM2 eqEsubset mulG_subG.
  rewrite OhmS ?andbT; last by rewrite -defN mulG_subr.
  have expE: exponent E %| p ^ 2 by rewrite exponent_special ?(pgroupS sEG).
  rewrite /= (OhmE 2 pN) sub_gen /=; last 1 first.
    by rewrite subsetI -defN mulG_subl sub_LdivT expE.
  rewrite -cent_joinEl // -genM_join genS // -defN.
  apply/subsetP=> _ /setIP[/imset2P[e z Ee Mz ->]].
  rewrite inE expgMn; last by red; rewrite -(centsP cME).
  rewrite (exponentP expE) // mul1g => zp2; rewrite mem_mulg //=.
  by rewrite (OhmE 2 (pgroupS sMR pR)) mem_gen // !inE Mz.
have{defN2} defZN2: X2 \x <[y]> = 'Z('Ohm_2(N)).
  rewrite -[X2](mulSGid sZX2) /= -/Z -defZE -(center_dprod defN2).
  do 2!rewrite -{1}(center_idP (cycle_abelian _)) -/X2; congr (_ \x _).
  by case/cprodP: (center_cprod (cprodEY cEX2)).
have{defZN2} strZN2: \big[dprod/1]_(z <- [:: xpn3; y]) <[z]> = 'Z('Ohm_2(N)).
  by rewrite unlock /= dprodg1.
rewrite -size_abelian_type ?center_abelian //.
have pZN2: p.-group 'Z('Ohm_2(N)) by rewrite (pgroupS _ pN) // subIset ?Ohm_sub.
rewrite (perm_size (abelian_type_pgroup pZN2 strZN2 _)) //= !inE.
rewrite !(eq_sym 1) -!order_eq1 oy orderE oX2.
by rewrite (eqn_exp2l 2 0) // (eqn_exp2l 1 0).
Qed.

End ExtremalTheory.