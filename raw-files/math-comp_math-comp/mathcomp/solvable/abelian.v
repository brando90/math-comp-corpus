
From mathcomp Require Import ssreflect ssrbool ssrfun eqtype ssrnat seq path.
From mathcomp Require Import div fintype finfun bigop finset prime binomial.
From mathcomp Require Import fingroup morphism perm automorphism action.
From mathcomp Require Import quotient gfunctor gproduct ssralg finalg zmodp.
From mathcomp Require Import cyclic pgroup gseries nilpotent sylow.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Import GroupScope.

Section AbelianDefs.

Variable gT : finGroupType.
Implicit Types (x : gT) (A B : {set gT}) (pi : nat_pred) (p n : nat).

Definition Ldiv n := [set x : gT | x ^+ n == 1].

Definition exponent A := \big[lcmn/1%N]_(x in A) #[x].

Definition abelem p A := [&& p.-group A, abelian A & exponent A %| p].

Definition is_abelem A := abelem (pdiv #|A|) A.

Definition pElem p A := [set E : {group gT} | E \subset A & abelem p E].

Definition pnElem p n A := [set E in pElem p A | logn p #|E| == n].

Definition nElem n A :=  \bigcup_(0 <= p < #|A|.+1) pnElem p n A.

Definition pmaxElem p A := [set E | [max E | E \in pElem p A]].

Definition p_rank p A := \max_(E in pElem p A) logn p #|E|.

Definition rank A := \max_(0 <= p < #|A|.+1) p_rank p A.

Definition gen_rank A := #|[arg min_(B < A | <<B>> == A) #|B|]|.

End AbelianDefs.

Arguments exponent {gT} A%g.
Arguments abelem {gT} p%N A%g.
Arguments is_abelem {gT} A%g.
Arguments pElem {gT} p%N A%g.
Arguments pnElem {gT} p%N n%N A%g.
Arguments nElem {gT} n%N A%g.
Arguments pmaxElem {gT} p%N A%g.
Arguments p_rank {gT} p%N A%g.
Arguments rank {gT} A%g.
Arguments gen_rank {gT} A%g.

Notation "''Ldiv_' n ()" := (Ldiv _ n)
  (at level 8, n at level 2, format "''Ldiv_' n ()") : group_scope.

Notation "''Ldiv_' n ( G )" := (G :&: 'Ldiv_n())
  (at level 8, n at level 2, format "''Ldiv_' n ( G )") : group_scope.

Prenex Implicits exponent.

Notation "p .-abelem" := (abelem p)
  (at level 2, format "p .-abelem") : group_scope.

Notation "''E_' p ( G )" := (pElem p G)
  (at level 8, p at level 2, format "''E_' p ( G )") : group_scope.

Notation "''E_' p ^ n ( G )" := (pnElem p n G)
  (at level 8, p, n at level 2, format "''E_' p ^ n ( G )") : group_scope.

Notation "''E' ^ n ( G )" := (nElem n G)
  (at level 8, n at level 2, format "''E' ^ n ( G )") : group_scope.

Notation "''E*_' p ( G )" := (pmaxElem p G)
  (at level 8, p at level 2, format "''E*_' p ( G )") : group_scope.

Notation "''m' ( A )" := (gen_rank A)
  (at level 8, format "''m' ( A )") : group_scope.

Notation "''r' ( A )" := (rank A)
  (at level 8, format "''r' ( A )") : group_scope.

Notation "''r_' p ( A )" := (p_rank p A)
  (at level 8, p at level 2, format "''r_' p ( A )") : group_scope.

Section Functors.

Variables (n : nat) (gT : finGroupType) (A : {set gT}).

Definition Ohm := <<[set x in A | x ^+ (pdiv #[x] ^ n) == 1]>>.

Definition Mho := <<[set x ^+ (pdiv #[x] ^ n) | x in A & (pdiv #[x]).-elt x]>>.

Canonical Ohm_group : {group gT} := Eval hnf in [group of Ohm].
Canonical Mho_group : {group gT} := Eval hnf in [group of Mho].

Lemma pdiv_p_elt (p : nat) (x : gT) : p.-elt x -> x != 1 -> pdiv #[x] = p.
Proof.
move=> p_x; rewrite /order -cycle_eq1.
by case/(pgroup_pdiv p_x)=> p_pr _ [k ->]; rewrite pdiv_pfactor.
Qed.

Lemma OhmPredP (x : gT) :
  reflect (exists2 p, prime p & x ^+ (p ^ n) = 1) (x ^+ (pdiv #[x] ^ n) == 1).
Proof.
have [-> | nt_x] := eqVneq x 1.
  by rewrite expg1n eqxx; left; exists 2; rewrite ?expg1n.
apply: (iffP idP) => [/eqP | [p p_pr /eqP x_pn]].
  by exists (pdiv #[x]); rewrite ?pdiv_prime ?order_gt1.
rewrite (@pdiv_p_elt p) //; rewrite -order_dvdn in x_pn.
by rewrite [p_elt _ _](pnat_dvd x_pn) // pnat_exp pnat_id.
Qed.

Lemma Mho_p_elt (p : nat) x : x \in A -> p.-elt x -> x ^+ (p ^ n) \in Mho.
Proof.
move=> Ax p_x; case: (eqVneq x 1) => [-> | ntx]; first by rewrite groupX.
by apply: mem_gen; apply/imsetP; exists x; rewrite ?inE ?Ax (pdiv_p_elt p_x).
Qed.

End Functors.

Arguments Ohm n%N {gT} A%g.
Arguments Ohm_group n%N {gT} A%g.
Arguments Mho n%N {gT} A%g.
Arguments Mho_group n%N {gT} A%g.
Arguments OhmPredP {n gT x}.

Notation "''Ohm_' n ( G )" := (Ohm n G)
  (at level 8, n at level 2, format "''Ohm_' n ( G )") : group_scope.
Notation "''Ohm_' n ( G )" := (Ohm_group n G) : Group_scope.

Notation "''Mho^' n ( G )" := (Mho n G)
  (at level 8, n at level 2, format "''Mho^' n ( G )") : group_scope.
Notation "''Mho^' n ( G )" := (Mho_group n G) : Group_scope.

Section ExponentAbelem.

Variable gT : finGroupType.
Implicit Types (p n : nat) (pi : nat_pred) (x : gT) (A B C : {set gT}).
Implicit Types E G H K P X Y : {group gT}.

Lemma LdivP A n x : reflect (x \in A /\ x ^+ n = 1) (x \in 'Ldiv_n(A)).
Proof. by rewrite !inE; apply: (iffP andP) => [] [-> /eqP]. Qed.

Lemma dvdn_exponent x A : x \in A -> #[x] %| exponent A.
Proof. by move=> Ax; rewrite (biglcmn_sup x). Qed.

Lemma expg_exponent x A : x \in A -> x ^+ exponent A = 1.
Proof. by move=> Ax; apply/eqP; rewrite -order_dvdn dvdn_exponent. Qed.

Lemma exponentS A B : A \subset B -> exponent A %| exponent B.
Proof.
by move=> sAB; apply/dvdn_biglcmP=> x Ax; rewrite dvdn_exponent ?(subsetP sAB).
Qed.

Lemma exponentP A n :
  reflect (forall x, x \in A -> x ^+ n = 1) (exponent A %| n).
Proof.
apply: (iffP (dvdn_biglcmP _ _ _)) => eAn x Ax.
  by apply/eqP; rewrite -order_dvdn eAn.
by rewrite order_dvdn eAn.
Qed.
Arguments exponentP {A n}.

Lemma trivg_exponent G : (G :==: 1) = (exponent G %| 1).
Proof.
rewrite -subG1.
by apply/subsetP/exponentP=> trG x /trG; rewrite expg1 => /set1P.
Qed.

Lemma exponent1 : exponent [1 gT] = 1%N.
Proof. by apply/eqP; rewrite -dvdn1 -trivg_exponent eqxx. Qed.

Lemma exponent_dvdn G : exponent G %| #|G|.
Proof. by apply/dvdn_biglcmP=> x Gx; apply: order_dvdG. Qed.

Lemma exponent_gt0 G : 0 < exponent G.
Proof. exact: dvdn_gt0 (exponent_dvdn G). Qed.
Hint Resolve exponent_gt0 : core.

Lemma pnat_exponent pi G : pi.-nat (exponent G) = pi.-group G.
Proof.
congr (_ && _); first by rewrite cardG_gt0 exponent_gt0.
apply: eq_all_r => p; rewrite !mem_primes cardG_gt0 exponent_gt0 /=.
apply: andb_id2l => p_pr; apply/idP/idP=> pG.
  exact: dvdn_trans pG (exponent_dvdn G).
by case/Cauchy: pG => // x Gx <-; apply: dvdn_exponent.
Qed.

Lemma exponentJ A x : exponent (A :^ x) = exponent A.
Proof.
rewrite /exponent (reindex_inj (conjg_inj x)).
by apply: eq_big => [y | y _]; rewrite ?orderJ ?memJ_conjg.
Qed.

Lemma exponent_witness G : nilpotent G -> {x | x \in G & exponent G = #[x]}.
Proof.
move=> nilG; have [//=| /= x Gx max_x] := @arg_maxP _ 1 (mem G) order.
exists x => //; apply/eqP; rewrite eqn_dvd dvdn_exponent // andbT.
apply/dvdn_biglcmP=> y Gy; apply/dvdn_partP=> //= p.
rewrite mem_primes => /andP[p_pr _]; have p_gt1: p > 1 := prime_gt1 p_pr.
rewrite p_part pfactor_dvdn // -(leq_exp2l _ _ p_gt1) -!p_part.
rewrite -(leq_pmul2r (part_gt0 p^' #[x])) partnC // -!order_constt.
rewrite -orderM ?order_constt ?coprime_partC // ?max_x ?groupM ?groupX //.
case/dprodP: (nilpotent_pcoreC p nilG) => _ _ cGpGp' _.
have inGp := mem_normal_Hall (nilpotent_pcore_Hall _ nilG) (pcore_normal _ _).
by red; rewrite -(centsP cGpGp') // inGp ?p_elt_constt ?groupX.
Qed.

Lemma exponent_cycle x : exponent <[x]> = #[x].
Proof. by apply/eqP; rewrite eqn_dvd exponent_dvdn dvdn_exponent ?cycle_id. Qed.

Lemma exponent_cyclic X : cyclic X -> exponent X = #|X|.
Proof. by case/cyclicP=> x ->; apply: exponent_cycle. Qed.

Lemma primes_exponent G : primes (exponent G) = primes (#|G|).
Proof.
apply/eq_primes => p; rewrite !mem_primes exponent_gt0 cardG_gt0 /=.
by apply: andb_id2l => p_pr; apply: negb_inj; rewrite -!p'natE // pnat_exponent.
Qed.

Lemma pi_of_exponent G : \pi(exponent G) = \pi(G).
Proof. by rewrite /pi_of primes_exponent. Qed.

Lemma partn_exponentS pi H G :
  H \subset G -> #|G|`_pi %| #|H| -> (exponent H)`_pi = (exponent G)`_pi.
Proof.
move=> sHG Gpi_dvd_H; apply/eqP; rewrite eqn_dvd.
rewrite partn_dvd ?exponentS ?exponent_gt0 //=; apply/dvdn_partP=> // p.
rewrite pi_of_part ?exponent_gt0 // => /andP[_ /= pi_p].
have sppi: {subset (p : nat_pred) <= pi} by move=> q /eqnP->.
have [P sylP] := Sylow_exists p H; have sPH := pHall_sub sylP.
have{sylP} sylP: p.-Sylow(G) P.
  rewrite pHallE (subset_trans sPH) //= (card_Hall sylP) eqn_dvd andbC.
  by rewrite -{1}(partn_part _ sppi) !partn_dvd ?cardSg ?cardG_gt0.
rewrite partn_part ?partn_biglcm //.
apply: (@big_ind _ (dvdn^~ _)) => [|m n|x Gx]; first exact: dvd1n.
  by rewrite dvdn_lcm => ->.
rewrite -order_constt; have p_y := p_elt_constt p x; set y := x.`_p in p_y *.
have sYG: <[y]> \subset G by rewrite cycle_subG groupX.
have [z _ Pyz] := Sylow_Jsub sylP sYG p_y.
rewrite (bigD1 (y ^ z))  ?(subsetP sPH) -?cycle_subG ?cycleJ //=.
by rewrite orderJ part_pnat_id ?dvdn_lcml // (pi_pnat p_y).
Qed.

Lemma exponent_Hall pi G H : pi.-Hall(G) H -> exponent H = (exponent G)`_pi.
Proof.
move=> hallH; have [sHG piH _] := and3P hallH.
rewrite -(partn_exponentS sHG) -?(card_Hall hallH) ?part_pnat_id //.
by apply: pnat_dvd piH; apply: exponent_dvdn.
Qed.

Lemma exponent_Zgroup G : Zgroup G -> exponent G = #|G|.
Proof.
move/forall_inP=> ZgG; apply/eqP; rewrite eqn_dvd exponent_dvdn.
apply/(dvdn_partP _ (cardG_gt0 _)) => p _.
have [S sylS] := Sylow_exists p G; rewrite -(card_Hall sylS).
have /cyclicP[x defS]: cyclic S by rewrite ZgG ?(p_Sylow sylS).
by rewrite defS dvdn_exponent // -cycle_subG -defS (pHall_sub sylS).
Qed.

Lemma cprod_exponent A B G :
  A \* B = G -> lcmn (exponent A) (exponent B) = (exponent G).
Proof.
case/cprodP=> [[K H -> ->{A B}] <- cKH].
apply/eqP; rewrite eqn_dvd dvdn_lcm !exponentS ?mulG_subl ?mulG_subr //=.
apply/exponentP=> _ /imset2P[x y Kx Hy ->].
rewrite -[1]mulg1 expgMn; last by red; rewrite -(centsP cKH).
congr (_ * _); apply/eqP; rewrite -order_dvdn.
  by rewrite (dvdn_trans (dvdn_exponent Kx)) ?dvdn_lcml.
by rewrite (dvdn_trans (dvdn_exponent Hy)) ?dvdn_lcmr.
Qed.

Lemma dprod_exponent A B G :
  A \x B = G -> lcmn (exponent A) (exponent B) = (exponent G).
Proof.
case/dprodP=> [[K H -> ->{A B}] defG cKH _].
by apply: cprod_exponent; rewrite cprodE.
Qed.

Lemma sub_LdivT A n : (A \subset 'Ldiv_n()) = (exponent A %| n).
Proof. by apply/subsetP/exponentP=> eAn x /eAn; rewrite inE => /eqP. Qed.

Lemma LdivT_J n x : 'Ldiv_n() :^ x = 'Ldiv_n().
Proof.
apply/setP=> y; rewrite !inE mem_conjg inE -conjXg.
by rewrite (canF_eq (conjgKV x)) conj1g.
Qed.

Lemma LdivJ n A x : 'Ldiv_n(A :^ x) = 'Ldiv_n(A) :^ x.
Proof. by rewrite conjIg LdivT_J. Qed.

Lemma sub_Ldiv A n : (A \subset 'Ldiv_n(A)) = (exponent A %| n).
Proof. by rewrite subsetI subxx sub_LdivT. Qed.

Lemma group_Ldiv G n : abelian G -> group_set 'Ldiv_n(G).
Proof.
move=> cGG; apply/group_setP.
split=> [|x y]; rewrite !inE ?group1 ?expg1n //=.
case/andP=> Gx /eqP xn /andP[Gy /eqP yn].
by rewrite groupM //= expgMn ?xn ?yn ?mulg1 //; apply: (centsP cGG).
Qed.

Lemma abelian_exponent_gen A : abelian A -> exponent <<A>> = exponent A.
Proof.
rewrite -abelian_gen; set n := exponent A; set G := <<A>> => cGG.
apply/eqP; rewrite eqn_dvd andbC exponentS ?subset_gen //= -sub_Ldiv.
rewrite -(gen_set_id (group_Ldiv n cGG)) genS // subsetI subset_gen /=.
by rewrite sub_LdivT.
Qed.

Lemma abelem_pgroup p A : p.-abelem A -> p.-group A.
Proof. by case/andP. Qed.

Lemma abelem_abelian p A : p.-abelem A -> abelian A.
Proof. by case/and3P. Qed.

Lemma abelem1 p : p.-abelem [1 gT].
Proof. by rewrite /abelem pgroup1 abelian1 exponent1 dvd1n. Qed.

Lemma abelemE p G : prime p -> p.-abelem G = abelian G && (exponent G %| p).
Proof.
move=> p_pr; rewrite /abelem -pnat_exponent andbA -!(andbC (_ %| _)).
by case: (dvdn_pfactor _ 1 p_pr) => // [[k _ ->]]; rewrite pnat_exp pnat_id.
Qed.

Lemma abelemP p G :
    prime p ->
  reflect (abelian G /\ forall x, x \in G -> x ^+ p = 1) (p.-abelem G).
Proof.
by move=> p_pr; rewrite abelemE //; apply: (iffP andP) => [] [-> /exponentP].
Qed.

Lemma abelem_order_p p G x : p.-abelem G -> x \in G -> x != 1 -> #[x] = p.
Proof.
case/and3P=> pG _ eG Gx; rewrite -cycle_eq1 => ntX.
have{ntX} [p_pr p_x _] := pgroup_pdiv (mem_p_elt pG Gx) ntX.
by apply/eqP; rewrite eqn_dvd p_x andbT order_dvdn (exponentP eG).
Qed.

Lemma cyclic_abelem_prime p X : p.-abelem X -> cyclic X -> X :!=: 1 -> #|X| = p.
Proof.
move=> abelX cycX; case/cyclicP: cycX => x -> in abelX *.
by rewrite cycle_eq1; apply: abelem_order_p abelX (cycle_id x).
Qed.

Lemma cycle_abelem p x : p.-elt x || prime p -> p.-abelem <[x]> = (#[x] %| p).
Proof.
move=> p_xVpr; rewrite /abelem cycle_abelian /=.
apply/andP/idP=> [[_ xp1] | x_dvd_p].
  by rewrite order_dvdn (exponentP xp1) ?cycle_id.
split; last exact: dvdn_trans (exponent_dvdn _) x_dvd_p.
by case/orP: p_xVpr => // /pnat_id; apply: pnat_dvd.
Qed.

Lemma exponent2_abelem G : exponent G %| 2 -> 2.-abelem G.
Proof.
move/exponentP=> expG; apply/abelemP=> //; split=> //.
apply/centsP=> x Gx y Gy; apply: (mulIg x); apply: (mulgI y).
by rewrite -!mulgA !(mulgA y) -!(expgS _ 1) !expG ?mulg1 ?groupM.
Qed.

Lemma prime_abelem p G : prime p -> #|G| = p -> p.-abelem G.
Proof.
move=> p_pr oG; rewrite /abelem -oG exponent_dvdn.
by rewrite /pgroup cyclic_abelian ?prime_cyclic ?oG ?pnat_id.
Qed.

Lemma abelem_cyclic p G : p.-abelem G -> cyclic G = (logn p #|G| <= 1).
Proof.
move=> abelG; have [pG _ expGp] := and3P abelG.
case: (eqsVneq G 1) => [-> | ntG]; first by rewrite cyclic1 cards1 logn1.
have [p_pr _ [e oG]] := pgroup_pdiv pG ntG; apply/idP/idP.
  case/cyclicP=> x defG; rewrite -(pfactorK 1 p_pr) dvdn_leq_log ?prime_gt0 //.
  by rewrite defG order_dvdn (exponentP expGp) // defG cycle_id.
by rewrite oG pfactorK // ltnS leqn0 => e0; rewrite prime_cyclic // oG (eqP e0).
Qed.

Lemma abelemS p H G : H \subset G -> p.-abelem G -> p.-abelem H.
Proof.
move=> sHG /and3P[cGG pG Gp1]; rewrite /abelem.
by rewrite (pgroupS sHG) // (abelianS sHG) // (dvdn_trans (exponentS sHG)).
Qed.

Lemma abelemJ p G x : p.-abelem (G :^ x) = p.-abelem G.
Proof. by rewrite /abelem pgroupJ abelianJ exponentJ. Qed.

Lemma cprod_abelem p A B G :
  A \* B = G -> p.-abelem G = p.-abelem A && p.-abelem B.
Proof.
case/cprodP=> [[H K -> ->{A B}] defG cHK].
apply/idP/andP=> [abelG | []].
  by rewrite !(abelemS _ abelG) // -defG (mulG_subl, mulG_subr).
case/and3P=> pH cHH expHp; case/and3P=> pK cKK expKp.
rewrite -defG /abelem pgroupM pH pK abelianM cHH cKK cHK /=.
apply/exponentP=> _ /imset2P[x y Hx Ky ->].
rewrite expgMn; last by red; rewrite -(centsP cHK).
by rewrite (exponentP expHp) // (exponentP expKp) // mul1g.
Qed.

Lemma dprod_abelem p A B G :
  A \x B = G -> p.-abelem G = p.-abelem A && p.-abelem B.
Proof.
move=> defG; case/dprodP: (defG) => _ _ _ tiHK.
by apply: cprod_abelem; rewrite -dprodEcp.
Qed.

Lemma is_abelem_pgroup p G : p.-group G -> is_abelem G = p.-abelem G.
Proof.
rewrite /is_abelem => pG.
case: (eqsVneq G 1) => [-> | ntG]; first by rewrite !abelem1.
by have [p_pr _ [k ->]] := pgroup_pdiv pG ntG; rewrite pdiv_pfactor.
Qed.

Lemma is_abelemP G : reflect (exists2 p, prime p & p.-abelem G) (is_abelem G).
Proof.
apply: (iffP idP) => [abelG | [p p_pr abelG]].
  case: (eqsVneq G 1) => [-> | ntG]; first by exists 2; rewrite ?abelem1.
  by exists (pdiv #|G|); rewrite ?pdiv_prime // ltnNge -trivg_card_le1.
by rewrite (is_abelem_pgroup (abelem_pgroup abelG)).
Qed.

Lemma pElemP p A E : reflect (E \subset A /\ p.-abelem E) (E \in 'E_p(A)).
Proof. by rewrite inE; apply: andP. Qed.
Arguments pElemP {p A E}.

Lemma pElemS p A B : A \subset B -> 'E_p(A) \subset 'E_p(B).
Proof.
by move=> sAB; apply/subsetP=> E; rewrite !inE => /andP[/subset_trans->].
Qed.

Lemma pElemI p A B : 'E_p(A :&: B) = 'E_p(A) :&: subgroups B.
Proof. by apply/setP=> E; rewrite !inE subsetI andbAC. Qed.

Lemma pElemJ x p A E : ((E :^ x)%G \in 'E_p(A :^ x)) = (E \in 'E_p(A)).
Proof. by rewrite !inE conjSg abelemJ. Qed.

Lemma pnElemP p n A E :
  reflect [/\ E \subset A, p.-abelem E & logn p #|E| = n] (E \in 'E_p^n(A)).
Proof. by rewrite !inE -andbA; apply: (iffP and3P) => [] [-> -> /eqP]. Qed.
Arguments pnElemP {p n A E}.

Lemma pnElemPcard p n A E :
  E \in 'E_p^n(A) -> [/\ E \subset A, p.-abelem E & #|E| = p ^ n]%N.
Proof.
by case/pnElemP=> -> abelE <-; rewrite -card_pgroup // abelem_pgroup.
Qed.

Lemma card_pnElem p n A E : E \in 'E_p^n(A) -> #|E| = (p ^ n)%N.
Proof. by case/pnElemPcard. Qed.

Lemma pnElem0 p G : 'E_p^0(G) = [set 1%G].
Proof.
apply/setP=> E; rewrite !inE -andbA; apply/and3P/idP=> [[_ pE] | /eqP->].
  apply: contraLR; case/(pgroup_pdiv (abelem_pgroup pE)) => p_pr _ [k ->].
  by rewrite pfactorK.
by rewrite sub1G abelem1 cards1 logn1.
Qed.

Lemma pnElem_prime p n A E : E \in 'E_p^n.+1(A) -> prime p.
Proof. by case/pnElemP=> _ _; rewrite lognE; case: prime. Qed.

Lemma pnElemE p n A :
  prime p -> 'E_p^n(A) = [set E in 'E_p(A) | #|E| == (p ^ n)%N].
Proof.
move/pfactorK=> pnK; apply/setP=> E; rewrite 3!inE.
case: (@andP (E \subset A)) => //= [[_]] /andP[/p_natP[k ->] _].
by rewrite pnK (can_eq pnK).
Qed.

Lemma pnElemS p n A B : A \subset B -> 'E_p^n(A) \subset 'E_p^n(B).
Proof.
move=> sAB; apply/subsetP=> E.
by rewrite !inE -!andbA => /andP[/subset_trans->].
Qed.

Lemma pnElemI p n A B : 'E_p^n(A :&: B) = 'E_p^n(A) :&: subgroups B.
Proof. by apply/setP=> E; rewrite !inE subsetI -!andbA; do !bool_congr. Qed.

Lemma pnElemJ x p n A E : ((E :^ x)%G \in 'E_p^n(A :^ x)) = (E \in 'E_p^n(A)).
Proof. by rewrite inE pElemJ cardJg !inE. Qed.

Lemma abelem_pnElem p n G :
  p.-abelem G -> n <= logn p #|G| -> exists E, E \in 'E_p^n(G).
Proof.
case: n => [|n] abelG lt_nG; first by exists 1%G; rewrite pnElem0 set11.
have p_pr: prime p by move: lt_nG; rewrite lognE; case: prime.
case/(normal_pgroup (abelem_pgroup abelG)): lt_nG => // E [sEG _ oE].
by exists E; rewrite pnElemE // !inE oE sEG (abelemS sEG) /=.
Qed.

Lemma card_p1Elem p A X : X \in 'E_p^1(A) -> #|X| = p.
Proof. exact: card_pnElem. Qed.

Lemma p1ElemE p A : prime p -> 'E_p^1(A) = [set X in subgroups A | #|X| == p].
Proof.
move=> p_pr; apply/setP=> X; rewrite pnElemE // !inE -andbA; congr (_ && _).
by apply: andb_idl => /eqP oX; rewrite prime_abelem ?oX.
Qed.

Lemma TIp1ElemP p A X Y :
  X \in 'E_p^1(A) -> Y \in 'E_p^1(A) -> reflect (X :&: Y = 1) (X :!=: Y).
Proof.
move=> EpX EpY; have p_pr := pnElem_prime EpX.
have [oX oY] := (card_p1Elem EpX, card_p1Elem EpY).
have [<- |] := altP eqP.
  by right=> X1; rewrite -oX -(setIid X) X1 cards1 in p_pr.
by rewrite eqEcard oX oY leqnn andbT; left; rewrite prime_TIg ?oX.
Qed.

Lemma card_p1Elem_pnElem p n A E :
  E \in 'E_p^n(A) -> #|'E_p^1(E)| = (\sum_(i < n) p ^ i)%N.
Proof.
case/pnElemP=> _ {A} abelE dimE; have [pE cEE _] := and3P abelE.
have [E1 | ntE] := eqsVneq E 1.
  rewrite -dimE E1 cards1 logn1 big_ord0 eq_card0 // => X.
  by rewrite !inE subG1 trivg_card1; case: eqP => // ->; rewrite logn1 andbF.
have [p_pr _ _] := pgroup_pdiv pE ntE; have p_gt1 := prime_gt1 p_pr.
apply/eqP; rewrite -(@eqn_pmul2l (p - 1)) ?subn_gt0 // subn1 -predn_exp.
have groupD1_inj: injective (fun X => (gval X)^#).
  apply: can_inj (@generated_group _) _ => X.
  by apply: val_inj; rewrite /= genD1 ?group1 ?genGid.
rewrite -dimE -card_pgroup // (cardsD1 1 E) group1 /= mulnC.
rewrite -(card_imset _ groupD1_inj) eq_sym.
apply/eqP; apply: card_uniform_partition => [X'|].
  case/imsetP=> X; rewrite pnElemE // expn1 => /setIdP[_ /eqP <-] ->.
  by rewrite (cardsD1 1 X) group1.
apply/and3P; split; last 1 first.
- apply/imsetP=> [[X /card_p1Elem oX X'0]].
  by rewrite -oX (cardsD1 1) -X'0 group1 cards0 in p_pr.
- rewrite eqEsubset; apply/andP; split.
    by apply/bigcupsP=> _ /imsetP[X /pnElemP[sXE _ _] ->]; apply: setSD.
  apply/subsetP=> x /setD1P[ntx Ex].
  apply/bigcupP; exists <[x]>^#; last by rewrite !inE ntx cycle_id.
  apply/imsetP; exists <[x]>%G; rewrite ?p1ElemE // !inE cycle_subG Ex /=.
  by rewrite -orderE (abelem_order_p abelE).
apply/trivIsetP=> _ _ /imsetP[X EpX ->] /imsetP[Y EpY ->]; apply/implyP.
rewrite (inj_eq groupD1_inj) -setI_eq0 -setDIl setD_eq0 subG1.
by rewrite (sameP eqP (TIp1ElemP EpX EpY)) implybb.
Qed.

Lemma card_p1Elem_p2Elem p A E : E \in 'E_p^2(A) -> #|'E_p^1(E)| = p.+1.
Proof. by move/card_p1Elem_pnElem->; rewrite big_ord_recl big_ord1. Qed.

Lemma p2Elem_dprodP p A E X Y :
    E \in 'E_p^2(A) -> X \in 'E_p^1(E) -> Y \in 'E_p^1(E) ->
  reflect (X \x Y = E) (X :!=: Y).
Proof.
move=> Ep2E EpX EpY; have [_ abelE oE] := pnElemPcard Ep2E.
apply: (iffP (TIp1ElemP EpX EpY)) => [tiXY|]; last by case/dprodP.
have [[sXE _ oX] [sYE _ oY]] := (pnElemPcard EpX, pnElemPcard EpY).
rewrite dprodE ?(sub_abelian_cent2 (abelem_abelian abelE)) //.
by apply/eqP; rewrite eqEcard mul_subG //= TI_cardMg // oX oY oE.
Qed.

Lemma nElemP n G E : reflect (exists p, E \in 'E_p^n(G)) (E \in 'E^n(G)).
Proof.
rewrite ['E^n(G)]big_mkord.
apply: (iffP bigcupP) => [[[p /= _] _] | [p]]; first by exists p.
case: n => [|n EpnE]; first by rewrite pnElem0; exists ord0; rewrite ?pnElem0.
suffices lepG: p < #|G|.+1  by exists (Ordinal lepG).
have:= EpnE; rewrite pnElemE ?(pnElem_prime EpnE) // !inE -andbA ltnS.
case/and3P=> sEG _ oE; rewrite dvdn_leq // (dvdn_trans _ (cardSg sEG)) //.
by rewrite (eqP oE) dvdn_exp.
Qed.
Arguments nElemP {n G E}.

Lemma nElem0 G : 'E^0(G) = [set 1%G].
Proof.
apply/setP=> E; apply/nElemP/idP=> [[p] |]; first by rewrite pnElem0.
by exists 2; rewrite pnElem0.
Qed.

Lemma nElem1P G E :
  reflect (E \subset G /\ exists2 p, prime p & #|E| = p) (E \in 'E^1(G)).
Proof.
apply: (iffP nElemP) => [[p pE] | [sEG [p p_pr oE]]].
  have p_pr := pnElem_prime pE; rewrite pnElemE // !inE -andbA in pE.
  by case/and3P: pE => -> _ /eqP; split; last exists p.
exists p; rewrite pnElemE // !inE sEG oE eqxx abelemE // -oE exponent_dvdn.
by rewrite cyclic_abelian // prime_cyclic // oE.
Qed.

Lemma nElemS n G H : G \subset H -> 'E^n(G) \subset 'E^n(H).
Proof.
move=> sGH; apply/subsetP=> E /nElemP[p EpnG_E].
by apply/nElemP; exists p; rewrite // (subsetP (pnElemS _ _ sGH)).
Qed.

Lemma nElemI n G H : 'E^n(G :&: H) = 'E^n(G) :&: subgroups H.
Proof.
apply/setP=> E; apply/nElemP/setIP=> [[p] | []].
  by rewrite pnElemI; case/setIP; split=> //; apply/nElemP; exists p.
by case/nElemP=> p EpnG_E sHE; exists p; rewrite pnElemI inE EpnG_E.
Qed.

Lemma def_pnElem p n G : 'E_p^n(G) = 'E_p(G) :&: 'E^n(G).
Proof.
apply/setP=> E; rewrite inE in_setI; apply: andb_id2l => /pElemP[sEG abelE].
apply/idP/nElemP=> [|[q]]; first by exists p; rewrite !inE sEG abelE.
rewrite !inE -2!andbA => /and4P[_ /pgroupP qE _].
case: (eqVneq E 1%G) => [-> | ]; first by rewrite cards1 !logn1.
case/(pgroup_pdiv (abelem_pgroup abelE)) => p_pr pE _.
by rewrite (eqnP (qE p p_pr pE)).
Qed.

Lemma pmaxElemP p A E :
  reflect (E \in 'E_p(A) /\ forall H, H \in 'E_p(A) -> E \subset H -> H :=: E)
          (E \in 'E*_p(A)).
Proof. by rewrite [E \in 'E*_p(A)]inE; apply: (iffP maxgroupP). Qed.

Lemma pmaxElem_exists p A D :
  D \in 'E_p(A) -> {E | E \in 'E*_p(A) & D \subset E}.
Proof.
move=> EpD; have [E maxE sDE] := maxgroup_exists (EpD : mem 'E_p(A) D).
by exists E; rewrite // inE.
Qed.

Lemma pmaxElem_LdivP p G E :
  prime p -> reflect ('Ldiv_p('C_G(E)) = E) (E \in 'E*_p(G)).
Proof.
move=> p_pr; apply: (iffP (pmaxElemP p G E)) => [[] | defE].
  case/pElemP=> sEG abelE maxE; have [_ cEE eE] := and3P abelE.
  apply/setP=> x; rewrite !inE -andbA; apply/and3P/idP=> [[Gx cEx xp] | Ex].
    rewrite -(maxE (<[x]> <*> E)%G) ?joing_subr //.
      by rewrite -cycle_subG joing_subl.
    rewrite inE join_subG cycle_subG Gx sEG /=.
    rewrite (cprod_abelem _ (cprodEY _)); last by rewrite centsC cycle_subG.
    by rewrite cycle_abelem ?p_pr ?orbT // order_dvdn xp.
  by rewrite (subsetP sEG) // (subsetP cEE) // (exponentP eE).
split=> [|H]; last first.
  case/pElemP=> sHG /abelemP[// | cHH Hp1] sEH.
  apply/eqP; rewrite eqEsubset sEH andbC /= -defE; apply/subsetP=> x Hx.
  by rewrite 3!inE (subsetP sHG) // Hp1 ?(subsetP (centsS _ cHH)) /=.
apply/pElemP; split; first by rewrite -defE -setIA subsetIl.
apply/abelemP=> //; rewrite /abelian -{1 3}defE setIAC subsetIr.
by split=> //; apply/exponentP; rewrite -sub_LdivT setIAC subsetIr.
Qed.

Lemma pmaxElemS p A B :
  A \subset B -> 'E*_p(B) :&: subgroups A \subset 'E*_p(A).
Proof.
move=> sAB; apply/subsetP=> E; rewrite !inE.
case/andP=> /maxgroupP[/pElemP[_ abelE] maxE] sEA.
apply/maxgroupP; rewrite inE sEA; split=> // D EpD.
by apply: maxE; apply: subsetP EpD; apply: pElemS.
Qed.

Lemma pmaxElemJ p A E x : ((E :^ x)%G \in 'E*_p(A :^ x)) = (E \in 'E*_p(A)).
Proof.
apply/pmaxElemP/pmaxElemP=> [] [EpE maxE].
  rewrite pElemJ in EpE; split=> //= H EpH sEH; apply: (act_inj 'Js x).
  by apply: maxE; rewrite ?conjSg ?pElemJ.
rewrite pElemJ; split=> // H; rewrite -(actKV 'JG x H) pElemJ conjSg => EpHx'.
by move/maxE=> /= ->.
Qed.

Lemma grank_min B : 'm(<<B>>) <= #|B|.
Proof.
by rewrite /gen_rank; case: arg_minP => [|_ _ -> //]; rewrite genGid.
Qed.

Lemma grank_witness G : {B | <<B>> = G & #|B| = 'm(G)}.
Proof.
rewrite /gen_rank; case: arg_minP => [|B defG _]; first by rewrite genGid.
by exists B; first apply/eqP.
Qed.

Lemma p_rank_witness p G : {E | E \in 'E_p^('r_p(G))(G)}.
Proof.
have [E EG_E mE]: {E | E \in 'E_p(G) & 'r_p(G) = logn p #|E| }.
  by apply: eq_bigmax_cond; rewrite (cardD1 1%G) inE sub1G abelem1.
by exists E; rewrite inE EG_E -mE /=.
Qed.

Lemma p_rank_geP p n G : reflect (exists E, E \in 'E_p^n(G)) (n <= 'r_p(G)).
Proof.
apply: (iffP idP) => [|[E]]; last first.
  by rewrite inE => /andP[Ep_E /eqP <-]; rewrite (bigmax_sup E).
have [D /pnElemP[sDG abelD <-]] := p_rank_witness p G.
by case/abelem_pnElem=> // E; exists E; apply: (subsetP (pnElemS _ _ sDG)).
Qed.

Lemma p_rank_gt0 p H : ('r_p(H) > 0) = (p \in \pi(H)).
Proof.
rewrite mem_primes cardG_gt0 /=; apply/p_rank_geP/andP=> [[E] | [p_pr]].
  case/pnElemP=> sEG _; rewrite lognE; case: and3P => // [[-> _ pE] _].
  by rewrite (dvdn_trans _ (cardSg sEG)).
case/Cauchy=> // x Hx ox; exists <[x]>%G; rewrite 2!inE [#|_|]ox cycle_subG.
by rewrite Hx (pfactorK 1) ?abelemE // cycle_abelian -ox exponent_dvdn.
Qed.

Lemma p_rank1 p : 'r_p([1 gT]) = 0.
Proof. by apply/eqP; rewrite eqn0Ngt p_rank_gt0 /= cards1. Qed.

Lemma logn_le_p_rank p A E : E \in 'E_p(A) -> logn p #|E| <= 'r_p(A).
Proof. by move=> EpA_E; rewrite (bigmax_sup E). Qed.

Lemma p_rank_le_logn p G : 'r_p(G) <= logn p #|G|.
Proof.
have [E EpE] := p_rank_witness p G.
by have [sEG _ <-] := pnElemP EpE; apply: lognSg.
Qed.

Lemma p_rank_abelem p G : p.-abelem G -> 'r_p(G) = logn p #|G|.
Proof.
move=> abelG; apply/eqP; rewrite eqn_leq andbC (bigmax_sup G) //.
  by apply/bigmax_leqP=> E; rewrite inE => /andP[/lognSg->].
by rewrite inE subxx.
Qed.

Lemma p_rankS p A B : A \subset B -> 'r_p(A) <= 'r_p(B).
Proof.
move=> sAB; apply/bigmax_leqP=> E /(subsetP (pElemS p sAB)) EpB_E.
by rewrite (bigmax_sup E).
Qed.

Lemma p_rankElem_max p A : 'E_p^('r_p(A))(A) \subset 'E*_p(A).
Proof.
apply/subsetP=> E /setIdP[EpE dimE].
apply/pmaxElemP; split=> // F EpF sEF; apply/eqP.
have pF: p.-group F by case/pElemP: EpF => _ /and3P[].
have pE: p.-group E by case/pElemP: EpE => _ /and3P[].
rewrite eq_sym eqEcard sEF dvdn_leq // (card_pgroup pE) (card_pgroup pF).
by rewrite (eqP dimE) dvdn_exp2l // logn_le_p_rank.
Qed.

Lemma p_rankJ p A x : 'r_p(A :^ x) = 'r_p(A).
Proof.
rewrite /p_rank (reindex_inj (act_inj 'JG x)).
by apply: eq_big => [E | E _]; rewrite ?cardJg ?pElemJ.
Qed.

Lemma p_rank_Sylow p G H : p.-Sylow(G) H -> 'r_p(H) = 'r_p(G).
Proof.
move=> sylH; apply/eqP; rewrite eqn_leq (p_rankS _ (pHall_sub sylH)) /=.
apply/bigmax_leqP=> E; rewrite inE => /andP[sEG abelE].
have [P sylP sEP] := Sylow_superset sEG (abelem_pgroup abelE).
have [x _ ->] := Sylow_trans sylP sylH.
by rewrite p_rankJ -(p_rank_abelem abelE) (p_rankS _ sEP).
Qed.

Lemma p_rank_Hall pi p G H : pi.-Hall(G) H -> p \in pi -> 'r_p(H) = 'r_p(G).
Proof.
move=> hallH pi_p; have [P sylP] := Sylow_exists p H.
by rewrite -(p_rank_Sylow sylP) (p_rank_Sylow (subHall_Sylow hallH pi_p sylP)).
Qed.

Lemma p_rank_pmaxElem_exists p r G :
  'r_p(G) >= r -> exists2 E, E \in 'E*_p(G) & 'r_p(E) >= r.
Proof.
case/p_rank_geP=> D /setIdP[EpD /eqP <- {r}].
have [E EpE sDE] := pmaxElem_exists EpD; exists E => //.
case/pmaxElemP: EpE => /setIdP[_ abelE] _.
by rewrite (p_rank_abelem abelE) lognSg.
Qed.

Lemma rank1 : 'r([1 gT]) = 0.
Proof. by rewrite ['r(1)]big1_seq // => p _; rewrite p_rank1. Qed.

Lemma p_rank_le_rank p G : 'r_p(G) <= 'r(G).
Proof.
case: (posnP 'r_p(G)) => [-> //|]; rewrite p_rank_gt0 mem_primes.
case/and3P=> p_pr _ pG; have lepg: p < #|G|.+1 by rewrite ltnS dvdn_leq.
by rewrite ['r(G)]big_mkord (bigmax_sup (Ordinal lepg)).
Qed.

Lemma rank_gt0 G : ('r(G) > 0) = (G :!=: 1).
Proof.
case: (eqsVneq G 1) => [-> |]; first by rewrite rank1 eqxx.
case: (trivgVpdiv G) => [-> | [p p_pr]]; first by case/eqP.
case/Cauchy=> // x Gx oxp ->; apply: leq_trans (p_rank_le_rank p G).
have EpGx: <[x]>%G \in 'E_p(G).
  by rewrite inE cycle_subG Gx abelemE // cycle_abelian -oxp exponent_dvdn.
by apply: leq_trans (logn_le_p_rank EpGx); rewrite -orderE oxp logn_prime ?eqxx.
Qed.

Lemma rank_witness G : {p | prime p & 'r(G) = 'r_p(G)}.
Proof.
have [p _ defmG]: {p : 'I_(#|G|.+1) | true & 'r(G) = 'r_p(G)}.
  by rewrite ['r(G)]big_mkord; apply: eq_bigmax_cond; rewrite card_ord.
case: (eqsVneq G 1) => [-> | ]; first by exists 2; rewrite // rank1 p_rank1.
by rewrite -rank_gt0 defmG p_rank_gt0 mem_primes; case/andP; exists p.
Qed.

Lemma rank_pgroup p G : p.-group G -> 'r(G) = 'r_p(G).
Proof.
move=> pG; apply/eqP; rewrite eqn_leq p_rank_le_rank andbT.
rewrite ['r(G)]big_mkord; apply/bigmax_leqP=> [[q /= _] _].
case: (posnP 'r_q(G)) => [-> // |]; rewrite p_rank_gt0 mem_primes.
by case/and3P=> q_pr _ qG; rewrite (eqnP (pgroupP pG q q_pr qG)).
Qed.

Lemma rank_Sylow p G P : p.-Sylow(G) P -> 'r(P) = 'r_p(G).
Proof.
move=> sylP; have pP := pHall_pgroup sylP.
by rewrite -(p_rank_Sylow sylP) -(rank_pgroup pP).
Qed.

Lemma rank_abelem p G : p.-abelem G -> 'r(G) = logn p #|G|.
Proof.
by move=> abelG; rewrite (rank_pgroup (abelem_pgroup abelG)) p_rank_abelem.
Qed.

Lemma nt_pnElem p n E A : E \in 'E_p^n(A) -> n > 0 -> E :!=: 1.
Proof. by case/pnElemP=> _ /rank_abelem <- <-; rewrite rank_gt0. Qed.

Lemma rankJ A x : 'r(A :^ x) = 'r(A).
Proof. by rewrite /rank cardJg; apply: eq_bigr => p _; rewrite p_rankJ. Qed.

Lemma rankS A B : A \subset B -> 'r(A) <= 'r(B).
Proof.
move=> sAB; rewrite /rank !big_mkord; apply/bigmax_leqP=> p _.
have leAB: #|A| < #|B|.+1 by rewrite ltnS subset_leq_card.
by rewrite (bigmax_sup (widen_ord leAB p)) // p_rankS.
Qed.

Lemma rank_geP n G : reflect (exists E, E \in 'E^n(G)) (n <= 'r(G)).
Proof.
apply: (iffP idP) => [|[E]].
  have [p _ ->] := rank_witness G; case/p_rank_geP=> E.
  by rewrite def_pnElem; case/setIP; exists E.
case/nElemP=> p; rewrite inE => /andP[EpG_E /eqP <-].
by rewrite (leq_trans (logn_le_p_rank EpG_E)) ?p_rank_le_rank.
Qed.

End ExponentAbelem.

Arguments LdivP {gT A n x}.
Arguments exponentP {gT A n}.
Arguments abelemP {gT p G}.
Arguments is_abelemP {gT G}.
Arguments pElemP {gT p A E}.
Arguments pnElemP {gT p n A E}.
Arguments nElemP {gT n G E}.
Arguments nElem1P {gT G E}.
Arguments pmaxElemP {gT p A E}.
Arguments pmaxElem_LdivP {gT p G E}.
Arguments p_rank_geP {gT p n G}.
Arguments rank_geP {gT n G}.

Section MorphAbelem.

Variables (aT rT : finGroupType) (D : {group aT}) (f : {morphism D >-> rT}).
Implicit Types (G H E : {group aT}) (A B : {set aT}).

Lemma exponent_morphim G : exponent (f @* G) %| exponent G.
Proof.
apply/exponentP=> _ /morphimP[x Dx Gx ->].
by rewrite -morphX // expg_exponent // morph1.
Qed.

Lemma morphim_LdivT n : f @* 'Ldiv_n() \subset 'Ldiv_n().
Proof.
apply/subsetP=> _ /morphimP[x Dx xn ->]; rewrite inE in xn.
by rewrite inE -morphX // (eqP xn) morph1.
Qed.

Lemma morphim_Ldiv n A : f @* 'Ldiv_n(A) \subset 'Ldiv_n(f @* A).
Proof.
by apply: subset_trans (morphimI f A _) (setIS _ _); apply: morphim_LdivT.
Qed.

Lemma morphim_abelem p G : p.-abelem G -> p.-abelem (f @* G).
Proof.
case: (eqsVneq G 1) => [-> | ntG] abelG; first by rewrite morphim1 abelem1.
have [p_pr _ _] := pgroup_pdiv (abelem_pgroup abelG) ntG.
case/abelemP: abelG => // abG elemG; apply/abelemP; rewrite ?morphim_abelian //.
by split=> // _ /morphimP[x Dx Gx ->]; rewrite -morphX // elemG ?morph1.
Qed.

Lemma morphim_pElem p G E : E \in 'E_p(G) -> (f @* E)%G \in 'E_p(f @* G).
Proof.
by rewrite !inE => /andP[sEG abelE]; rewrite morphimS // morphim_abelem.
Qed.

Lemma morphim_pnElem p n G E :
  E \in 'E_p^n(G) -> {m | m <= n & (f @* E)%G \in 'E_p^m(f @* G)}.
Proof.
rewrite inE => /andP[EpE /eqP <-].
by exists (logn p #|f @* E|); rewrite ?logn_morphim // inE morphim_pElem /=.
Qed.

Lemma morphim_grank G : G \subset D -> 'm(f @* G) <= 'm(G).
Proof.
have [B defG <-] := grank_witness G; rewrite -defG gen_subG => sBD.
by rewrite morphim_gen ?morphimEsub ?(leq_trans (grank_min _)) ?leq_imset_card.
Qed.

End MorphAbelem.

Section InjmAbelem.

Variables (aT rT : finGroupType) (D G : {group aT}) (f : {morphism D >-> rT}).
Hypotheses (injf : 'injm f) (sGD : G \subset D).
Let defG : invm injf @* (f @* G) = G := morphim_invm injf sGD.

Lemma exponent_injm : exponent (f @* G) = exponent G.
Proof. by apply/eqP; rewrite eqn_dvd -{3}defG !exponent_morphim. Qed.

Lemma injm_Ldiv n A : f @* 'Ldiv_n(A) = 'Ldiv_n(f @* A).
Proof.
apply/eqP; rewrite eqEsubset morphim_Ldiv.
rewrite -[f @* 'Ldiv_n(A)](morphpre_invm injf).
rewrite -sub_morphim_pre; last by rewrite subIset ?morphim_sub.
rewrite injmI ?injm_invm // setISS ?morphim_LdivT //.
by rewrite sub_morphim_pre ?morphim_sub // morphpre_invm.
Qed.

Lemma injm_abelem p : p.-abelem (f @* G) = p.-abelem G.
Proof. by apply/idP/idP; first rewrite -{2}defG; apply: morphim_abelem. Qed.

Lemma injm_pElem p (E : {group aT}) :
  E \subset D -> ((f @* E)%G \in 'E_p(f @* G)) = (E \in 'E_p(G)).
Proof.
move=> sED; apply/idP/idP=> EpE; last exact: morphim_pElem.
by rewrite -defG -(group_inj (morphim_invm injf sED)) morphim_pElem.
Qed.

Lemma injm_pnElem p n (E : {group aT}) :
  E \subset D -> ((f @* E)%G \in 'E_p^n(f @* G)) = (E \in 'E_p^n(G)).
Proof. by move=> sED; rewrite inE injm_pElem // card_injm ?inE. Qed.

Lemma injm_nElem n (E : {group aT}) :
  E \subset D -> ((f @* E)%G \in 'E^n(f @* G)) = (E \in 'E^n(G)).
Proof.
move=> sED; apply/nElemP/nElemP=> [] [p EpE];
 by exists p; rewrite injm_pnElem in EpE *.
Qed.

Lemma injm_pmaxElem p (E : {group aT}) :
  E \subset D -> ((f @* E)%G \in 'E*_p(f @* G)) = (E \in 'E*_p(G)).
Proof.
move=> sED; have defE := morphim_invm injf sED.
apply/pmaxElemP/pmaxElemP=> [] [EpE maxE].
  split=> [|H EpH sEH]; first by rewrite injm_pElem in EpE.
  have sHD: H \subset D by apply: subset_trans (sGD); case/pElemP: EpH.
  by rewrite -(morphim_invm injf sHD) [f @* H]maxE ?morphimS ?injm_pElem.
rewrite injm_pElem //; split=> // fH Ep_fH sfEH; have [sfHG _] := pElemP Ep_fH.
have sfHD : fH \subset f @* D by rewrite (subset_trans sfHG) ?morphimS.
rewrite -(morphpreK sfHD); congr (f @* _).
rewrite [_ @*^-1 fH]maxE -?sub_morphim_pre //.
by rewrite -injm_pElem ?subsetIl // (group_inj (morphpreK sfHD)).
Qed.

Lemma injm_grank : 'm(f @* G) = 'm(G).
Proof. by apply/eqP; rewrite eqn_leq -{3}defG !morphim_grank ?morphimS. Qed.

Lemma injm_p_rank p : 'r_p(f @* G) = 'r_p(G).
Proof.
apply/eqP; rewrite eqn_leq; apply/andP; split.
  have [fE] := p_rank_witness p (f @* G); move: 'r_p(_) => n Ep_fE.
  apply/p_rank_geP; exists (f @*^-1 fE)%G.
  rewrite -injm_pnElem ?subsetIl ?(group_inj (morphpreK _)) //.
  by case/pnElemP: Ep_fE => sfEG _ _; rewrite (subset_trans sfEG) ?morphimS.
have [E] := p_rank_witness p G; move: 'r_p(_) => n EpE.
apply/p_rank_geP; exists (f @* E)%G; rewrite injm_pnElem //.
by case/pnElemP: EpE => sEG _ _; rewrite (subset_trans sEG).
Qed.

Lemma injm_rank : 'r(f @* G) = 'r(G).
Proof.
apply/eqP; rewrite eqn_leq; apply/andP; split.
  by have [p _ ->] := rank_witness (f @* G); rewrite injm_p_rank p_rank_le_rank.
by have [p _ ->] := rank_witness G; rewrite -injm_p_rank p_rank_le_rank.
Qed.

End InjmAbelem.

Section IsogAbelem.

Variables (aT rT : finGroupType) (G : {group aT}) (H : {group rT}).
Hypothesis isoGH : G \isog H.

Lemma exponent_isog : exponent G = exponent H.
Proof. by case/isogP: isoGH => f injf <-; rewrite exponent_injm. Qed.

Lemma isog_abelem p : p.-abelem G = p.-abelem H.
Proof. by case/isogP: isoGH => f injf <-; rewrite injm_abelem. Qed.

Lemma isog_grank : 'm(G) = 'm(H).
Proof. by case/isogP: isoGH => f injf <-; rewrite injm_grank. Qed.

Lemma isog_p_rank p : 'r_p(G) = 'r_p(H).
Proof. by case/isogP: isoGH => f injf <-; rewrite injm_p_rank. Qed.

Lemma isog_rank : 'r(G) = 'r(H).
Proof. by case/isogP: isoGH => f injf <-; rewrite injm_rank. Qed.

End IsogAbelem.

Section QuotientAbelem.

Variables (gT : finGroupType) (p : nat).
Implicit Types E G K H : {group gT}.

Lemma exponent_quotient G H : exponent (G / H) %| exponent G.
Proof. exact: exponent_morphim. Qed.

Lemma quotient_LdivT n H : 'Ldiv_n() / H \subset 'Ldiv_n().
Proof. exact: morphim_LdivT. Qed.

Lemma quotient_Ldiv n A H : 'Ldiv_n(A) / H \subset 'Ldiv_n(A / H).
Proof. exact: morphim_Ldiv. Qed.

Lemma quotient_abelem G H : p.-abelem G -> p.-abelem (G / H).
Proof. exact: morphim_abelem. Qed.

Lemma quotient_pElem G H E : E \in 'E_p(G) -> (E / H)%G \in 'E_p(G / H).
Proof. exact: morphim_pElem. Qed.

Lemma logn_quotient G H : logn p #|G / H| <= logn p #|G|.
Proof. exact: logn_morphim. Qed.

Lemma quotient_pnElem G H n E :
  E \in 'E_p^n(G) -> {m | m <= n & (E / H)%G \in 'E_p^m(G / H)}.
Proof. exact: morphim_pnElem. Qed.

Lemma quotient_grank G H : G \subset 'N(H) -> 'm(G / H) <= 'm(G).
Proof. exact: morphim_grank. Qed.

Lemma p_rank_quotient G H : G \subset 'N(H) -> 'r_p(G) - 'r_p(H) <= 'r_p(G / H).
Proof.
move=> nHG; rewrite leq_subLR.
have [E EpE] := p_rank_witness p G; have{EpE} [sEG abelE <-] := pnElemP EpE.
rewrite -(LagrangeI E H) lognM ?cardG_gt0 //.
rewrite -card_quotient ?(subset_trans sEG) // leq_add ?logn_le_p_rank // !inE.
  by rewrite subsetIr (abelemS (subsetIl E H)).
by rewrite quotientS ?quotient_abelem.
Qed.

Lemma p_rank_dprod K H G : K \x H = G -> 'r_p(K) + 'r_p(H) = 'r_p(G).
Proof.
move=> defG; apply/eqP; rewrite eqn_leq -leq_subLR andbC.
have [_ defKH cKH tiKH] := dprodP defG; have nKH := cents_norm cKH.
rewrite {1}(isog_p_rank (quotient_isog nKH tiKH)) /= -quotientMidl defKH.
rewrite p_rank_quotient; last by rewrite -defKH mul_subG ?normG.
have [[E EpE] [F EpF]] := (p_rank_witness p K, p_rank_witness p H).
have [[sEK abelE <-] [sFH abelF <-]] := (pnElemP EpE, pnElemP EpF).
have defEF: E \x F = E <*> F.
  by rewrite dprodEY ?(centSS sFH sEK) //; apply/trivgP; rewrite -tiKH setISS.
apply/p_rank_geP; exists (E <*> F)%G; rewrite !inE (dprod_abelem p defEF).
rewrite -lognM ?cargG_gt0 // (dprod_card defEF) abelE abelF eqxx.
by rewrite -(genGid G) -defKH genM_join genS ?setUSS.
Qed.

Lemma p_rank_p'quotient G H :
  (p : nat)^'.-group H -> G \subset 'N(H) -> 'r_p(G / H) = 'r_p(G).
Proof.
move=> p'H nHG; have [P sylP] := Sylow_exists p G.
have [sPG pP _] := and3P sylP; have nHP := subset_trans sPG nHG.
have tiHP: H :&: P = 1 := coprime_TIg (p'nat_coprime p'H pP).
rewrite -(p_rank_Sylow sylP) -(p_rank_Sylow (quotient_pHall nHP sylP)).
by rewrite (isog_p_rank (quotient_isog nHP tiHP)).
Qed.

End QuotientAbelem.

Section OhmProps.

Section Generic.

Variables (n : nat) (gT : finGroupType).
Implicit Types (p : nat) (x : gT) (rT : finGroupType).
Implicit Types (A B : {set gT}) (D G H : {group gT}).

Lemma Ohm_sub G : 'Ohm_n(G) \subset G.
Proof. by rewrite gen_subG; apply/subsetP=> x /setIdP[]. Qed.

Lemma Ohm1 : 'Ohm_n([1 gT]) = 1. Proof. exact: (trivgP (Ohm_sub _)). Qed.

Lemma Ohm_id G : 'Ohm_n('Ohm_n(G)) = 'Ohm_n(G).
Proof.
apply/eqP; rewrite eqEsubset Ohm_sub genS //.
by apply/subsetP=> x /setIdP[Gx oxn]; rewrite inE mem_gen // inE Gx.
Qed.

Lemma Ohm_cont rT G (f : {morphism G >-> rT}) :
  f @* 'Ohm_n(G) \subset 'Ohm_n(f @* G).
Proof.
rewrite morphim_gen ?genS //; last by rewrite -gen_subG Ohm_sub.
apply/subsetP=> fx /morphimP[x Gx]; rewrite inE Gx /=.
case/OhmPredP=> p p_pr xpn_1 -> {fx}.
rewrite inE morphimEdom mem_imset //=; apply/OhmPredP; exists p => //.
by rewrite -morphX // xpn_1 morph1.
Qed.

Lemma OhmS H G : H \subset G -> 'Ohm_n(H) \subset 'Ohm_n(G).
Proof.
move=> sHG; apply: genS; apply/subsetP=> x; rewrite !inE => /andP[Hx ->].
by rewrite (subsetP sHG).
Qed.

Lemma OhmE p G : p.-group G -> 'Ohm_n(G) = <<'Ldiv_(p ^ n)(G)>>.
Proof.
move=> pG; congr <<_>>; apply/setP=> x; rewrite !inE; apply: andb_id2l => Gx.
case: (eqVneq x 1) => [-> | ntx]; first by rewrite !expg1n.
by rewrite (pdiv_p_elt (mem_p_elt pG Gx)).
Qed.

Lemma OhmEabelian p G :
  p.-group G -> abelian 'Ohm_n(G) -> 'Ohm_n(G) = 'Ldiv_(p ^ n)(G).
Proof.
move=> pG; rewrite (OhmE pG) abelian_gen => cGGn; rewrite gen_set_id //.
rewrite -(setIidPr (subset_gen 'Ldiv_(p ^ n)(G))) setIA.
by rewrite [_ :&: G](setIidPl _) ?gen_subG ?subsetIl // group_Ldiv ?abelian_gen.
Qed.

Lemma Ohm_p_cycle p x :
  p.-elt x -> 'Ohm_n(<[x]>) = <[x ^+ (p ^ (logn p #[x] - n))]>.
Proof.
move=> p_x; apply/eqP; rewrite (OhmE p_x) eqEsubset cycle_subG mem_gen.
  rewrite gen_subG andbT; apply/subsetP=> y /LdivP[x_y ypn].
  case: (leqP (logn p #[x]) n) => [|lt_n_x].
    by rewrite -subn_eq0 => /eqP->.
  have p_pr: prime p by move: lt_n_x; rewrite lognE; case: (prime p).
  have def_y: <[y]> = <[x ^+ (#[x] %/ #[y])]>.
    apply: congr_group; apply/set1P.
    by rewrite -cycle_sub_group ?cardSg ?inE ?cycle_subG ?x_y /=.
  rewrite -cycle_subG def_y cycle_subG -{1}(part_pnat_id p_x) p_part.
  rewrite -{1}(subnK (ltnW lt_n_x)) expnD -muln_divA ?order_dvdn ?ypn //.
  by rewrite expgM mem_cycle.
rewrite !inE mem_cycle -expgM -expnD addnC -maxnE -order_dvdn.
by rewrite -{1}(part_pnat_id p_x) p_part dvdn_exp2l ?leq_maxr.
Qed.

Lemma Ohm_dprod A B G : A \x B = G -> 'Ohm_n(A) \x 'Ohm_n(B) = 'Ohm_n(G).
Proof.
case/dprodP => [[H K -> ->{A B}]] <- cHK tiHK.
rewrite dprodEY //; last first.
- by apply/trivgP; rewrite -tiHK setISS ?Ohm_sub.
- by rewrite (subset_trans (subset_trans _ cHK)) ?centS ?Ohm_sub.
apply/eqP; rewrite -(cent_joinEr cHK) eqEsubset join_subG /=.
rewrite !OhmS ?joing_subl ?joing_subr //= cent_joinEr //= -genM_join genS //.
apply/subsetP=> _ /setIdP[/imset2P[x y Hx Ky ->] /OhmPredP[p p_pr /eqP]].
have cxy: commute x y by red; rewrite -(centsP cHK).
rewrite ?expgMn // -eq_invg_mul => /eqP def_x.
have ypn1: y ^+ (p ^ n) = 1.
  by apply/set1P; rewrite -[[set 1]]tiHK inE -{1}def_x groupV !groupX.
have xpn1: x ^+ (p ^ n) = 1 by rewrite -[x ^+ _]invgK def_x ypn1 invg1.
by rewrite mem_mulg ?mem_gen // inE (Hx, Ky); apply/OhmPredP; exists p.
Qed.

Lemma Mho_sub G : 'Mho^n(G) \subset G.
Proof.
rewrite gen_subG; apply/subsetP=> _ /imsetP[x /setIdP[Gx _] ->].
exact: groupX.
Qed.

Lemma Mho1 : 'Mho^n([1 gT]) = 1. Proof. exact: (trivgP (Mho_sub _)). Qed.

Lemma morphim_Mho rT D G (f : {morphism D >-> rT}) :
  G \subset D -> f @* 'Mho^n(G) = 'Mho^n(f @* G).
Proof.
move=> sGD; have sGnD := subset_trans (Mho_sub G) sGD.
apply/eqP; rewrite eqEsubset {1}morphim_gen -1?gen_subG // !gen_subG.
apply/andP; split; apply/subsetP=> y.
  case/morphimP=> xpn _ /imsetP[x /setIdP[Gx]].
  set p := pdiv _ => p_x -> -> {xpn y}; have Dx := subsetP sGD x Gx.
  by rewrite morphX // Mho_p_elt ?morph_p_elt ?mem_morphim.
case/imsetP=> _ /setIdP[/morphimP[x Dx Gx ->]].
set p := pdiv _ => p_fx ->{y}; rewrite -(constt_p_elt p_fx) -morph_constt //.
by rewrite -morphX ?mem_morphim ?Mho_p_elt ?groupX ?p_elt_constt.
Qed.

Lemma Mho_cont rT G (f : {morphism G >-> rT}) :
  f @* 'Mho^n(G) \subset 'Mho^n(f @* G).
Proof. by rewrite morphim_Mho. Qed.

Lemma MhoS H G : H \subset G -> 'Mho^n(H) \subset 'Mho^n(G).
Proof.
move=> sHG; apply: genS; apply: imsetS; apply/subsetP=> x.
by rewrite !inE => /andP[Hx]; rewrite (subsetP sHG).
Qed.

Lemma MhoE p G : p.-group G -> 'Mho^n(G) = <<[set x ^+ (p ^ n) | x in G]>>.
Proof.
move=> pG; apply/eqP; rewrite eqEsubset !gen_subG; apply/andP.
do [split; apply/subsetP=> xpn; case/imsetP=> x] => [|Gx ->]; last first.
  by rewrite Mho_p_elt ?(mem_p_elt pG).
case/setIdP=> Gx _ ->; have [-> | ntx] := eqVneq x 1; first by rewrite expg1n.
by rewrite (pdiv_p_elt (mem_p_elt pG Gx) ntx) mem_gen //; apply: mem_imset.
Qed.

Lemma MhoEabelian p G :
  p.-group G -> abelian G -> 'Mho^n(G) = [set x ^+ (p ^ n) | x in G].
Proof.
move=> pG cGG; rewrite (MhoE pG); rewrite gen_set_id //; apply/group_setP.
split=> [|xn yn]; first by apply/imsetP; exists 1; rewrite ?expg1n.
case/imsetP=> x Gx ->; case/imsetP=> y Gy ->.
by rewrite -expgMn; [apply: mem_imset; rewrite groupM | apply: (centsP cGG)].
Qed.

Lemma trivg_Mho G : 'Mho^n(G) == 1 -> 'Ohm_n(G) == G.
Proof.
rewrite -subG1 gen_subG eqEsubset Ohm_sub /= => Gp1.
rewrite -{1}(Sylow_gen G) genS //; apply/bigcupsP=> P.
case/SylowP=> p p_pr /and3P[sPG pP _]; apply/subsetP=> x Px.
have Gx := subsetP sPG x Px; rewrite inE Gx //=.
rewrite (sameP eqP set1P) (subsetP Gp1) ?mem_gen //; apply: mem_imset.
by rewrite inE Gx; apply: pgroup_p (mem_p_elt pP Px).
Qed.

Lemma Mho_p_cycle p x : p.-elt x -> 'Mho^n(<[x]>) = <[x ^+ (p ^ n)]>.
Proof.
move=> p_x.
apply/eqP; rewrite (MhoE p_x) eqEsubset cycle_subG mem_gen; last first.
  by apply: mem_imset; apply: cycle_id.
rewrite gen_subG andbT; apply/subsetP=> _ /imsetP[_ /cycleP[k ->] ->].
by rewrite -expgM mulnC expgM mem_cycle.
Qed.

Lemma Mho_cprod A B G : A \* B = G -> 'Mho^n(A) \* 'Mho^n(B) = 'Mho^n(G).
Proof.
case/cprodP => [[H K -> ->{A B}]] <- cHK; rewrite cprodEY //; last first.
  by rewrite (subset_trans (subset_trans _ cHK)) ?centS ?Mho_sub.
apply/eqP; rewrite -(cent_joinEr cHK) eqEsubset join_subG /=.
rewrite !MhoS ?joing_subl ?joing_subr //= cent_joinEr // -genM_join.
apply: genS; apply/subsetP=> xypn /imsetP[_ /setIdP[/imset2P[x y Hx Ky ->]]].
move/constt_p_elt; move: (pdiv _) => p <- ->.
have cxy: commute x y by red; rewrite -(centsP cHK).
rewrite consttM // expgMn; last exact: commuteX2.
by rewrite mem_mulg ?Mho_p_elt ?groupX ?p_elt_constt.
Qed.

Lemma Mho_dprod A B G : A \x B = G -> 'Mho^n(A) \x 'Mho^n(B) = 'Mho^n(G).
Proof.
case/dprodP => [[H K -> ->{A B}]] defG cHK tiHK.
rewrite dprodEcp; first by apply: Mho_cprod; rewrite cprodE.
by apply/trivgP; rewrite -tiHK setISS ?Mho_sub.
Qed.

End Generic.

Canonical Ohm_igFun i := [igFun by Ohm_sub i & Ohm_cont i].
Canonical Ohm_gFun i := [gFun by Ohm_cont i].
Canonical Ohm_mgFun i := [mgFun by OhmS i].

Canonical Mho_igFun i := [igFun by Mho_sub i & Mho_cont i].
Canonical Mho_gFun i := [gFun by Mho_cont i].
Canonical Mho_mgFun i := [mgFun by MhoS i].

Section char.

Variables (n : nat) (gT rT : finGroupType) (D G : {group gT}).

Lemma Ohm_char : 'Ohm_n(G) \char G. Proof. exact: gFchar. Qed.
Lemma Ohm_normal : 'Ohm_n(G) <| G. Proof. exact: gFnormal. Qed.

Lemma Mho_char : 'Mho^n(G) \char G. Proof. exact: gFchar. Qed.
Lemma Mho_normal : 'Mho^n(G) <| G. Proof. exact: gFnormal. Qed.

Lemma morphim_Ohm (f : {morphism D >-> rT}) :
  G \subset D -> f @* 'Ohm_n(G) \subset 'Ohm_n(f @* G).
Proof. exact: morphimF. Qed.

Lemma injm_Ohm (f : {morphism D >-> rT}) :
  'injm f -> G \subset D -> f @* 'Ohm_n(G) = 'Ohm_n(f @* G).
Proof. by move=> injf; apply: injmF. Qed.

Lemma isog_Ohm (H : {group rT}) : G \isog H -> 'Ohm_n(G) \isog 'Ohm_n(H).
Proof. exact: gFisog. Qed.

Lemma isog_Mho (H : {group rT}) : G \isog H -> 'Mho^n(G) \isog 'Mho^n(H).
Proof. exact: gFisog. Qed.

End char.

Variable gT : finGroupType.
Implicit Types (pi : nat_pred) (p : nat).
Implicit Types (A B C : {set gT}) (D G H E : {group gT}).

Lemma Ohm0 G : 'Ohm_0(G) = 1.
Proof.
apply/trivgP; rewrite /= gen_subG.
by apply/subsetP=> x /setIdP[_]; rewrite inE.
Qed.

Lemma Ohm_leq m n G : m <= n -> 'Ohm_m(G) \subset 'Ohm_n(G).
Proof.
move/subnKC <-; rewrite genS //; apply/subsetP=> y.
by rewrite !inE expnD expgM => /andP[-> /eqP->]; rewrite expg1n /=.
Qed.

Lemma OhmJ n G x : 'Ohm_n(G :^ x) = 'Ohm_n(G) :^ x.
Proof.
rewrite -{1}(setIid G) -(setIidPr (Ohm_sub n G)).
by rewrite -!morphim_conj injm_Ohm ?injm_conj.
Qed.

Lemma Mho0 G : 'Mho^0(G) = G.
Proof.
apply/eqP; rewrite eqEsubset Mho_sub /=.
apply/subsetP=> x Gx; rewrite -[x]prod_constt group_prod // => p _.
exact: Mho_p_elt (groupX _ Gx) (p_elt_constt _ _).
Qed.

Lemma Mho_leq m n G : m <= n -> 'Mho^n(G) \subset 'Mho^m(G).
Proof.
move/subnKC <-; rewrite gen_subG //.
apply/subsetP=> _ /imsetP[x /setIdP[Gx p_x] ->].
by rewrite expnD expgM groupX ?(Mho_p_elt _ _ p_x).
Qed.

Lemma MhoJ n G x : 'Mho^n(G :^ x) = 'Mho^n(G) :^ x.
Proof.
by rewrite -{1}(setIid G) -(setIidPr (Mho_sub n G)) -!morphim_conj morphim_Mho.
Qed.

Lemma extend_cyclic_Mho G p x :
    p.-group G -> x \in G -> 'Mho^1(G) = <[x ^+ p]> ->
  forall k, k > 0 -> 'Mho^k(G) = <[x ^+ (p ^ k)]>.
Proof.
move=> pG Gx defG1 [//|k _]; have pX := mem_p_elt pG Gx.
apply/eqP; rewrite eqEsubset cycle_subG (Mho_p_elt _ Gx pX) andbT.
rewrite (MhoE _ pG) gen_subG; apply/subsetP=> ypk; case/imsetP=> y Gy ->{ypk}.
have: y ^+ p \in <[x ^+ p]> by rewrite -defG1 (Mho_p_elt 1 _ (mem_p_elt pG Gy)).
rewrite !expnS /= !expgM => /cycleP[j ->].
by rewrite -!expgM mulnCA mulnC expgM mem_cycle.
Qed.

Lemma Ohm1Eprime G : 'Ohm_1(G) = <<[set x in G | prime #[x]]>>.
Proof.
rewrite -['Ohm_1(G)](genD1 (group1 _)); congr <<_>>.
apply/setP=> x; rewrite !inE andbCA -order_dvdn -order_gt1; congr (_ && _).
apply/andP/idP=> [[p_gt1] | p_pr]; last by rewrite prime_gt1 ?pdiv_id.
set p := pdiv _ => ox_p; have p_pr: prime p by rewrite pdiv_prime.
by have [_ dv_p] := primeP p_pr; case/pred2P: (dv_p _ ox_p) p_gt1 => ->.
Qed.

Lemma abelem_Ohm1 p G : p.-group G -> p.-abelem 'Ohm_1(G) = abelian 'Ohm_1(G).
Proof.
move=> pG; rewrite /abelem (pgroupS (Ohm_sub 1 G)) //.
case abG1: (abelian _) => //=; apply/exponentP=> x.
by rewrite (OhmEabelian pG abG1); case/LdivP.
Qed.

Lemma Ohm1_abelem p G : p.-group G -> abelian G -> p.-abelem ('Ohm_1(G)).
Proof. by move=> pG cGG; rewrite abelem_Ohm1 ?(abelianS (Ohm_sub 1 G)). Qed.

Lemma Ohm1_id p G : p.-abelem G -> 'Ohm_1(G) = G.
Proof.
case/and3P=> pG cGG /exponentP Gp.
apply/eqP; rewrite eqEsubset Ohm_sub (OhmE 1 pG) sub_gen //.
by apply/subsetP=> x Gx; rewrite !inE Gx Gp /=.
Qed.

Lemma abelem_Ohm1P p G :
  abelian G -> p.-group G -> reflect ('Ohm_1(G) = G) (p.-abelem G).
Proof.
move=> cGG pG.
by apply: (iffP idP) => [| <-]; [apply: Ohm1_id | apply: Ohm1_abelem].
Qed.

Lemma TI_Ohm1 G H : H :&: 'Ohm_1(G) = 1 -> H :&: G = 1.
Proof.
move=> tiHG1; case: (trivgVpdiv (H :&: G)) => // [[p pr_p]].
case/Cauchy=> // x /setIP[Hx Gx] ox.
suffices x1: x \in [1] by rewrite -ox (set1P x1) order1 in pr_p.
by rewrite -{}tiHG1 inE Hx Ohm1Eprime mem_gen // inE Gx ox.
Qed.

Lemma Ohm1_eq1 G : ('Ohm_1(G) == 1) = (G :==: 1).
Proof.
apply/idP/idP => [/eqP G1_1 | /eqP->]; last by rewrite -subG1 Ohm_sub.
by rewrite -(setIid G) TI_Ohm1 // G1_1 setIg1.
Qed.

Lemma meet_Ohm1 G H : G :&: H != 1 -> G :&: 'Ohm_1(H) != 1.
Proof. by apply: contraNneq => /TI_Ohm1->. Qed.

Lemma Ohm1_cent_max G E p : E \in 'E*_p(G) -> p.-group G -> 'Ohm_1('C_G(E)) = E.
Proof.
move=> EpmE pG; have [G1 | ntG]:= eqsVneq G 1.
  case/pmaxElemP: EpmE; case/pElemP; rewrite G1 => /trivgP-> _ _.
  by apply/trivgP; rewrite cent1T setIT Ohm_sub.
have [p_pr _ _] := pgroup_pdiv pG ntG.
by rewrite (OhmE 1 (pgroupS (subsetIl G _) pG)) (pmaxElem_LdivP _ _) ?genGid.
Qed.

Lemma Ohm1_cyclic_pgroup_prime p G :
  cyclic G -> p.-group G -> G :!=: 1 -> #|'Ohm_1(G)| = p.
Proof.
move=> cycG pG ntG; set K := 'Ohm_1(G).
have abelK: p.-abelem K by rewrite Ohm1_abelem ?cyclic_abelian.
have sKG: K \subset G := Ohm_sub 1 G.
case/cyclicP: (cyclicS sKG cycG) => x /=; rewrite -/K => defK.
rewrite defK -orderE (abelem_order_p abelK) //= -/K ?defK ?cycle_id //.
rewrite -cycle_eq1 -defK -(setIidPr sKG).
by apply: contraNneq ntG => /TI_Ohm1; rewrite setIid => ->.
Qed.

Lemma cyclic_pgroup_dprod_trivg p A B C :
    p.-group C -> cyclic C -> A \x B = C ->
  A = 1 /\ B = C \/ B = 1 /\ A = C.
Proof.
move=> pC cycC; case/cyclicP: cycC pC => x ->{C} pC defC.
case/dprodP: defC => [] [G H -> ->{A B}] defC _ tiGH; rewrite -defC.
case: (eqVneq <[x]> 1) => [|ntC].
  move/trivgP; rewrite -defC mulG_subG => /andP[/trivgP-> _].
  by rewrite mul1g; left.
have [pr_p _ _] := pgroup_pdiv pC ntC; pose K := 'Ohm_1(<[x]>).
have prK : prime #|K| by rewrite (Ohm1_cyclic_pgroup_prime _ pC) ?cycle_cyclic.
case: (prime_subgroupVti G prK) => [sKG |]; last first.
  move/TI_Ohm1; rewrite -defC (setIidPl (mulG_subl _ _)) => ->.
  by left; rewrite mul1g.
case: (prime_subgroupVti H prK) => [sKH |]; last first.
  move/TI_Ohm1; rewrite -defC (setIidPl (mulG_subr _ _)) => ->.
  by right; rewrite mulg1.
have K1: K :=: 1 by apply/trivgP; rewrite -tiGH subsetI sKG.
by rewrite K1 cards1 in prK.
Qed.

Lemma piOhm1 G : \pi('Ohm_1(G)) = \pi(G).
Proof.
apply/eq_piP => p; apply/idP/idP; first exact: (piSg (Ohm_sub 1 G)).
rewrite !mem_primes !cardG_gt0 => /andP[p_pr /Cauchy[] // x Gx oxp].
by rewrite p_pr -oxp order_dvdG //= Ohm1Eprime mem_gen // inE Gx oxp.
Qed.

Lemma Ohm1Eexponent p G :
  prime p -> exponent 'Ohm_1(G) %| p -> 'Ohm_1(G) = 'Ldiv_p(G).
Proof.
move=> p_pr expG1p; have pG: p.-group G.
  apply: sub_in_pnat (pnat_pi (cardG_gt0 G)) => q _.
  rewrite -piOhm1 mem_primes; case/and3P=> q_pr _; apply: pgroupP q_pr.
  by rewrite -pnat_exponent (pnat_dvd expG1p) ?pnat_id.
apply/eqP; rewrite eqEsubset {2}(OhmE 1 pG) subset_gen subsetI Ohm_sub.
by rewrite sub_LdivT expG1p.
Qed.

Lemma p_rank_Ohm1 p G : 'r_p('Ohm_1(G)) = 'r_p(G).
Proof.
apply/eqP; rewrite eqn_leq p_rankS ?Ohm_sub //.
apply/bigmax_leqP=> E /setIdP[sEG abelE].
by rewrite (bigmax_sup E) // inE -{1}(Ohm1_id abelE) OhmS.
Qed.

Lemma rank_Ohm1 G : 'r('Ohm_1(G)) = 'r(G).
Proof.
apply/eqP; rewrite eqn_leq rankS ?Ohm_sub //.
by have [p _ ->] := rank_witness G; rewrite -p_rank_Ohm1 p_rank_le_rank.
Qed.

Lemma p_rank_abelian p G : abelian G -> 'r_p(G) = logn p #|'Ohm_1(G)|.
Proof.
move=> cGG; have nilG := abelian_nil cGG; case p_pr: (prime p); last first.
  by apply/eqP; rewrite lognE p_pr eqn0Ngt p_rank_gt0 mem_primes p_pr.
case/dprodP: (Ohm_dprod 1 (nilpotent_pcoreC p nilG)) => _ <- _ /TI_cardMg->.
rewrite mulnC logn_Gauss; last first.
  rewrite prime_coprime // -p'natE // -/(pgroup _ _).
  exact: pgroupS (Ohm_sub _ _) (pcore_pgroup _ _).
rewrite -(p_rank_Sylow (nilpotent_pcore_Hall p nilG)) -p_rank_Ohm1.
rewrite p_rank_abelem // Ohm1_abelem ?pcore_pgroup //.
exact: abelianS (pcore_sub _ _) cGG.
Qed.

Lemma rank_abelian_pgroup p G :
  p.-group G -> abelian G -> 'r(G) = logn p #|'Ohm_1(G)|.
Proof. by move=> pG cGG; rewrite (rank_pgroup pG) p_rank_abelian. Qed.

End OhmProps.

Section AbelianStructure.

Variable gT : finGroupType.
Implicit Types (p : nat) (G H K E : {group gT}).

Lemma abelian_splits x G :
  x \in G -> #[x] = exponent G -> abelian G -> [splits G, over <[x]>].
Proof.
move=> Gx ox cGG; apply/splitsP; move: {2}_.+1 (ltnSn #|G|) => n.
elim: n gT => // n IHn aT in x G Gx ox cGG *; rewrite ltnS => leGn.
have: <[x]> \subset G by [rewrite cycle_subG]; rewrite subEproper.
case/predU1P=> [<-|]; first by exists 1%G; rewrite inE -subG1 subsetIr mulg1 /=.
case/properP=> sxG [y]; elim: {y}_.+1 {-2}y (ltnSn #[y]) => // m IHm y.
rewrite ltnS => leym Gy x'y; case: (trivgVpdiv <[y]>) => [y1 | [p p_pr p_dv_y]].
  by rewrite -cycle_subG y1 sub1G in x'y.
case x_yp: (y ^+ p \in <[x]>); last first.
  apply: IHm (negbT x_yp); rewrite ?groupX ?(leq_trans _ leym) //.
  by rewrite orderXdiv // ltn_Pdiv ?prime_gt1.
have{x_yp} xp_yp: (y ^+ p \in <[x ^+ p]>).
  have: <[y ^+ p]>%G \in [set <[x ^+ (#[x] %/ #[y ^+ p])]>%G].
    by rewrite -cycle_sub_group ?order_dvdG // inE cycle_subG x_yp eqxx.
  rewrite inE -cycle_subG -val_eqE /=; move/eqP->.
  rewrite cycle_subG orderXdiv // divnA // mulnC ox.
  by rewrite -muln_divA ?dvdn_exponent ?expgM 1?groupX ?cycle_id.
have: p <= #[y] by rewrite dvdn_leq.
rewrite leq_eqVlt; case/predU1P=> [{xp_yp m IHm leym}oy | ltpy]; last first.
  case/cycleP: xp_yp => k; rewrite -expgM mulnC expgM => def_yp.
  suffices: #[y * x ^- k] < m.
    by move/IHm; apply; rewrite groupMr // groupV groupX ?cycle_id.
  apply: leq_ltn_trans (leq_trans ltpy leym).
  rewrite dvdn_leq ?prime_gt0 // order_dvdn expgMn.
    by rewrite expgVn def_yp mulgV.
  by apply: (centsP cGG); rewrite ?groupV ?groupX.
pose Y := <[y]>; have nsYG: Y <| G by rewrite -sub_abelian_normal ?cycle_subG.
have [sYG nYG] := andP nsYG; have nYx := subsetP nYG x Gx.
have GxY: coset Y x \in G / Y by rewrite mem_morphim.
have tiYx: Y :&: <[x]> = 1 by rewrite prime_TIg ?indexg1 -?[#|_|]oy ?cycle_subG.
have: #[coset Y x] = exponent (G / Y).
  apply/eqP; rewrite eqn_dvd dvdn_exponent //.
  apply/exponentP=> _ /morphimP[z Nz Gz ->].
  rewrite -morphX // ((z ^+ _ =P 1) _) ?morph1 //.
  rewrite orderE -quotient_cycle ?card_quotient ?cycle_subG // -indexgI /=.
  by rewrite setIC tiYx indexg1 -orderE ox -order_dvdn dvdn_exponent.
case/IHn => // [||Hq]; first exact: quotient_abelian.
  apply: leq_trans leGn; rewrite ltn_quotient // cycle_eq1.
  by apply: contra x'y; move/eqP->; rewrite group1.
case/complP=> /= ti_x_Hq defGq.
have: Hq \subset G / Y by rewrite -defGq mulG_subr.
case/inv_quotientS=> // H defHq sYH sHG; exists H.
have nYX: <[x]> \subset 'N(Y) by rewrite cycle_subG.
rewrite inE -subG1 eqEsubset mul_subG //= -tiYx subsetI subsetIl andbT.
rewrite -{2}(mulSGid sYH) mulgA (normC nYX) -mulgA -quotientSK ?quotientMl //.
rewrite -quotient_sub1 ?(subset_trans (subsetIl _ _)) // quotientIG //= -/Y.
by rewrite -defHq quotient_cycle // ti_x_Hq defGq !subxx.
Qed.

Lemma abelem_splits p G H : p.-abelem G -> H \subset G -> [splits G, over H].
Proof.
elim: {G}_.+1 {-2}G H (ltnSn #|G|) => // m IHm G H.
rewrite ltnS => leGm abelG sHG; case: (eqsVneq H 1) => [-> | ].
  by apply/splitsP; exists G; rewrite inE mul1g -subG1 subsetIl /=.
case/trivgPn=> x Hx ntx; have Gx := subsetP sHG x Hx.
have [_ cGG eGp] := and3P abelG.
have ox: #[x] = exponent G.
  by apply/eqP; rewrite eqn_dvd dvdn_exponent // (abelem_order_p abelG).
case/splitsP: (abelian_splits Gx ox cGG) => K; case/complP=> tixK defG.
have sKG: K \subset G by rewrite -defG mulG_subr.
have ltKm: #|K| < m.
  rewrite (leq_trans _ leGm) ?proper_card //; apply/properP; split=> //.
  exists x => //; apply: contra ntx => Kx; rewrite -cycle_eq1 -subG1 -tixK.
  by rewrite subsetI subxx cycle_subG.
case/splitsP: (IHm _ _ ltKm (abelemS sKG abelG) (subsetIr H K)) => L.
case/complP=> tiHKL defK; apply/splitsP; exists L; rewrite inE.
rewrite -subG1 -tiHKL -setIA setIS; last by rewrite subsetI -defK mulG_subr /=.
by rewrite -(setIidPr sHG) -defG -group_modl ?cycle_subG //= setIC -mulgA defK.
Qed.

Fact abelian_type_subproof G :
  {H : {group gT} & abelian G -> {x | #[x] = exponent G & <[x]> \x H = G}}.
Proof.
case cGG: (abelian G); last by exists G.
have [x Gx ox] := exponent_witness (abelian_nil cGG).
case/splitsP/ex_mingroup: (abelian_splits Gx (esym ox) cGG) => H.
case/mingroupp/complP=> tixH defG; exists H => _.
exists x; rewrite ?dprodE // (sub_abelian_cent2 cGG) ?cycle_subG //.
by rewrite -defG mulG_subr.
Qed.

Fixpoint abelian_type_rec n G :=
  if n is n'.+1 then if abelian G && (G :!=: 1) then
    exponent G :: abelian_type_rec n' (tag (abelian_type_subproof G))
  else [::] else [::].

Definition abelian_type (A : {set gT}) := abelian_type_rec #|A| <<A>>.

Lemma abelian_type_dvdn_sorted A : sorted [rel m n | n %| m] (abelian_type A).
Proof.
set R := SimplRel _; pose G := <<A>>%G.
suffices: path R (exponent G) (abelian_type A) by case: (_ A) => // m t /andP[].
rewrite /abelian_type -/G; elim: {A}#|A| G {2 3}G (subxx G) => // n IHn G M sGM.
simpl; case: ifP => //= /andP[cGG ntG]; rewrite exponentS ?IHn //=.
case: (abelian_type_subproof G) => H /= [//| x _] /dprodP[_ /= <- _ _].
exact: mulG_subr.
Qed.

Lemma abelian_type_gt1 A : all [pred m | m > 1] (abelian_type A).
Proof.
rewrite /abelian_type; elim: {A}#|A| <<A>>%G => //= n IHn G.
case: ifP => //= /andP[_ ntG]; rewrite {n}IHn.
by rewrite ltn_neqAle exponent_gt0 eq_sym -dvdn1 -trivg_exponent ntG.
Qed.

Lemma abelian_type_sorted A : sorted geq (abelian_type A).
Proof.
have:= abelian_type_dvdn_sorted A; have:= abelian_type_gt1 A.
case: (abelian_type A) => //= m t; elim: t m => //= n t IHt m /andP[].
by move/ltnW=> m_gt0 t_gt1 /andP[n_dv_m /IHt->]; rewrite // dvdn_leq.
Qed.

Theorem abelian_structure G :
    abelian G ->
  {b | \big[dprod/1]_(x <- b) <[x]> = G & map order b = abelian_type G}.
Proof.
rewrite /abelian_type genGidG.
elim: {G}#|G| {-2 5}G (leqnn #|G|) => /= [|n IHn] G leGn cGG.
  by rewrite leqNgt cardG_gt0 in leGn.
rewrite {1}cGG /=; case: ifP => [ntG|/eqP->]; last first.
  by exists [::]; rewrite ?big_nil.
case: (abelian_type_subproof G) => H /= [//|x ox xdefG]; rewrite -ox.
have [_ defG cxH tixH] := dprodP xdefG.
have sHG: H \subset G by rewrite -defG mulG_subr.
case/IHn: (abelianS sHG cGG) => [|b defH <-].
  rewrite -ltnS (leq_trans _ leGn) // -defG TI_cardMg // -orderE.
  rewrite ltn_Pmull ?cardG_gt0 // ltn_neqAle order_gt0 eq_sym -dvdn1.
  by rewrite ox -trivg_exponent ntG.
by exists (x :: b); rewrite // big_cons defH xdefG.
Qed.

Lemma count_logn_dprod_cycle p n b G :
    \big[dprod/1]_(x <- b) <[x]> = G ->
  count [pred x | logn p #[x] > n] b = logn p #|'Ohm_n.+1(G) : 'Ohm_n(G)|.
Proof.
have sOn1 := @Ohm_leq gT _ _ _ (leqnSn n).
pose lnO i (A : {set gT}) := logn p #|'Ohm_i(A)|.
have lnO_le H: lnO n H <= lnO n.+1 H.
  by rewrite dvdn_leq_log ?cardG_gt0 // cardSg ?sOn1.
have lnOx i A B H: A \x B = H -> lnO i A + lnO i B = lnO i H.
  move=> defH; case/dprodP: defH (defH) => {A B}[[A B -> ->]] _ _ _ defH.
  rewrite /lnO; case/dprodP: (Ohm_dprod i defH) => _ <- _ tiOAB.
  by rewrite TI_cardMg ?lognM.
rewrite -divgS //= logn_div ?cardSg //= -/(lnO _ _) -/(lnO _ _).
elim: b G => [_ <-|x b IHb G] /=.
  by rewrite big_nil /lnO !(trivgP (Ohm_sub _ _)) subnn.
rewrite /= big_cons => defG; rewrite -!(lnOx _ _ _ _ defG) subnDA.
case/dprodP: defG => [[_ H _ defH] _ _ _] {G}; rewrite defH (IHb _ defH).
symmetry; do 2!rewrite addnC -addnBA ?lnO_le //; congr (_ + _).
pose y := x.`_p; have p_y: p.-elt y by rewrite p_elt_constt.
have{lnOx} lnOy i: lnO i <[x]> = lnO i <[y]>.
  have cXX := cycle_abelian x.
  have co_yx': coprime #[y] #[x.`_p^'] by rewrite !order_constt coprime_partC.
  have defX: <[y]> \x <[x.`_p^']> = <[x]>.
    rewrite dprodE ?coprime_TIg //.
      by rewrite -cycleM ?consttC //; apply: (centsP cXX); apply: mem_cycle.
    by apply: (sub_abelian_cent2 cXX); rewrite cycle_subG mem_cycle.
  rewrite -(lnOx i _ _ _ defX) addnC {1}/lnO lognE.
  case: and3P => // [[p_pr _ /idPn[]]]; rewrite -p'natE //.
  exact: pgroupS (Ohm_sub _ _) (p_elt_constt _ _).
rewrite -logn_part -order_constt -/y !{}lnOy /lnO !(Ohm_p_cycle _ p_y).
case: leqP => [| lt_n_y].
  by rewrite -subn_eq0 -addn1 subnDA => /eqP->; rewrite subnn.
rewrite -!orderE -(subSS n) subSn // expnSr expgM.
have p_pr: prime p by move: lt_n_y; rewrite lognE; case: prime.
set m := (p ^ _)%N; have m_gt0: m > 0 by rewrite expn_gt0 prime_gt0.
suffices p_ym: p %| #[y ^+ m].
  rewrite -logn_div ?orderXdvd // (orderXdiv p_ym) divnA // mulKn //.
  by rewrite logn_prime ?eqxx.
rewrite orderXdiv ?pfactor_dvdn ?leq_subr // -(dvdn_pmul2r m_gt0).
by rewrite -expnS -subSn // subSS divnK pfactor_dvdn ?leq_subr.
Qed.

Lemma abelian_type_pgroup p b G :
    p.-group G -> \big[dprod/1]_(x <- b) <[x]> = G -> 1 \notin b ->
  perm_eq (abelian_type G) (map order b).
Proof.
rewrite perm_sym; move: b => b1 pG defG1 ntb1.
have cGG: abelian G.
  elim: (b1) {pG}G defG1 => [_ <-|x b IHb G]; first by rewrite big_nil abelian1.
  rewrite big_cons; case/dprodP=> [[_ H _ defH]] <-; rewrite defH => cxH _.
  by rewrite abelianM cycle_abelian IHb.
have p_bG b: \big[dprod/1]_(x <- b) <[x]> = G -> all (p_elt p) b.
  elim: b {defG1 cGG}G pG => //= x b IHb G pG; rewrite big_cons.
  case/dprodP=> [[_ H _ defH]]; rewrite defH andbC => defG _ _.
  by rewrite -defG pgroupM in pG; case/andP: pG => p_x /IHb->.
have [b2 defG2 def_t] := abelian_structure cGG.
have ntb2: 1 \notin b2.
  apply: contraL (abelian_type_gt1 G) => b2_1.
  rewrite -def_t -has_predC has_map.
  by apply/hasP; exists 1; rewrite //= order1.
rewrite -{}def_t; apply/allP=> m; rewrite -map_cat => /mapP[x b_x def_m].
have{ntb1 ntb2} ntx: x != 1.
  by apply: contraL b_x; move/eqP->; rewrite mem_cat negb_or ntb1 ntb2.
have p_x: p.-elt x by apply: allP (x) b_x; rewrite all_cat !p_bG.
rewrite -cycle_eq1 in ntx; have [p_pr _ [k ox]] := pgroup_pdiv p_x ntx.
apply/eqnP; rewrite {m}def_m orderE ox !count_map.
pose cnt_p k := count [pred x : gT | logn p #[x] > k].
have cnt_b b: \big[dprod/1]_(x <- b) <[x]> = G ->
  count [pred x | #[x] == p ^ k.+1]%N b = cnt_p k b - cnt_p k.+1 b.
- move/p_bG; elim: b => //= _ b IHb /andP[/p_natP[j ->] /IHb-> {IHb}].
  rewrite eqn_leq !leq_exp2l ?prime_gt1 // -eqn_leq pfactorK //.
  case: ltngtP => // _ {j}; rewrite subSn // add0n; elim: b => //= y b IHb.
  by rewrite leq_add // ltn_neqAle; case: (~~ _).
by rewrite !cnt_b // /cnt_p !(@count_logn_dprod_cycle _ _ _ G).
Qed.

Lemma size_abelian_type G : abelian G -> size (abelian_type G) = 'r(G).
Proof.
move=> cGG; have [b defG def_t] := abelian_structure cGG.
apply/eqP; rewrite -def_t size_map eqn_leq andbC; apply/andP; split.
  have [p p_pr ->] := rank_witness G; rewrite p_rank_abelian //.
  by rewrite -indexg1 -(Ohm0 G) -(count_logn_dprod_cycle _ _ defG) count_size.
case/lastP def_b: b => // [b' x]; pose p := pdiv #[x].
have p_pr: prime p.
  have:= abelian_type_gt1 G; rewrite -def_t def_b map_rcons -cats1 all_cat.
  by rewrite /= andbT => /andP[_]; apply: pdiv_prime.
suffices: all [pred y | logn p #[y] > 0] b.
  rewrite all_count (count_logn_dprod_cycle _ _ defG) -def_b; move/eqP <-.
  by rewrite Ohm0 indexg1 -p_rank_abelian ?p_rank_le_rank.
apply/allP=> y; rewrite def_b mem_rcons inE /= => b_y.
rewrite lognE p_pr order_gt0 (dvdn_trans (pdiv_dvd _)) //.
case/predU1P: b_y => [-> // | b'_y].
have:= abelian_type_dvdn_sorted G; rewrite -def_t def_b.
case/splitPr: b'_y => b1 b2; rewrite -cat_rcons rcons_cat map_cat !map_rcons.
rewrite headI /= cat_path -(last_cons 2) -headI last_rcons.
case/andP=> _ /order_path_min min_y.
apply: (allP (min_y _)) => [? ? ? ? dv|]; first exact: (dvdn_trans dv).
by rewrite mem_rcons mem_head.
Qed.

Lemma mul_card_Ohm_Mho_abelian n G :
  abelian G -> (#|'Ohm_n(G)| * #|'Mho^n(G)|)%N = #|G|.
Proof.
case/abelian_structure => b defG _.
elim: b G defG => [_ <-|x b IHb G].
  by rewrite !big_nil (trivgP (Ohm_sub _ _)) (trivgP (Mho_sub _ _)) !cards1.
rewrite big_cons => defG; rewrite -(dprod_card defG).
rewrite -(dprod_card (Ohm_dprod n defG)) -(dprod_card (Mho_dprod n defG)) /=.
rewrite mulnCA -!mulnA mulnCA mulnA; case/dprodP: defG => [[_ H _ defH] _ _ _].
rewrite defH {b G defH IHb}(IHb H defH); congr (_ * _)%N => {H}.
elim: {x}_.+1 {-2}x (ltnSn #[x]) => // m IHm x; rewrite ltnS => lexm.
case p_x: (p_group <[x]>); last first.
  case: (eqVneq x 1) p_x => [-> |]; first by rewrite cycle1 p_group1.
  rewrite -order_gt1 /p_group -orderE; set p := pdiv _ => ntx p'x.
  have def_x: <[x.`_p]> \x <[x.`_p^']> = <[x]>.
    have ?: coprime #[x.`_p] #[x.`_p^'] by rewrite !order_constt coprime_partC.
    have ?: commute x.`_p x.`_p^' by apply: commuteX2.
    rewrite dprodE ?coprime_TIg -?cycleM ?consttC //.
    by rewrite cent_cycle cycle_subG; apply/cent1P.
  rewrite -(dprod_card (Ohm_dprod n def_x)) -(dprod_card (Mho_dprod n def_x)).
  rewrite mulnCA -mulnA mulnCA mulnA.
  rewrite !{}IHm ?(dprod_card def_x) ?(leq_trans _ lexm) {m lexm}//.
    rewrite /order -(dprod_card def_x) -!orderE !order_constt ltn_Pmull //.
    rewrite p_part -(expn0 p) ltn_exp2l 1?lognE ?prime_gt1 ?pdiv_prime //.
    by rewrite order_gt0 pdiv_dvd.
  rewrite proper_card // properEneq cycle_subG mem_cycle andbT.
  by apply: contra (negbT p'x); move/eqP <-; apply: p_elt_constt.
case/p_groupP: p_x => p p_pr p_x.
rewrite (Ohm_p_cycle n p_x) (Mho_p_cycle n p_x) -!orderE.
set k := logn p #[x]; have ox: #[x] = (p ^ k)%N by rewrite -card_pgroup.
case: (leqP k n) => [le_k_n | lt_n_k].
  rewrite -(subnKC le_k_n) subnDA subnn expg1 expnD expgM -ox.
  by rewrite expg_order expg1n order1 muln1.
rewrite !orderXgcd ox -{-3}(subnKC (ltnW lt_n_k)) expnD.
rewrite gcdnC gcdnMl gcdnC gcdnMr.
by rewrite mulnK ?mulKn ?expn_gt0 ?prime_gt0.
Qed.

Lemma grank_abelian G : abelian G -> 'm(G) = 'r(G).
Proof.
move=> cGG; apply/eqP; rewrite eqn_leq; apply/andP; split.
  rewrite -size_abelian_type //; case/abelian_structure: cGG => b defG <-.
  suffices <-: <<[set x in b]>> = G.
    by rewrite (leq_trans (grank_min _)) // size_map cardsE card_size.
  rewrite -{G defG}(bigdprodWY defG).
  elim: b => [|x b IHb]; first by rewrite big_nil gen0.
  by rewrite big_cons -joingE -joing_idr -IHb joing_idl joing_idr set_cons.
have [p p_pr ->] := rank_witness G; pose K := 'Mho^1(G).
have ->: 'r_p(G) = logn p #|G / K|.
  rewrite p_rank_abelian // card_quotient /= ?gFnorm // -divgS ?Mho_sub //.
  by rewrite -(mul_card_Ohm_Mho_abelian 1 cGG) mulnK ?cardG_gt0.
case: (grank_witness G) => B genB <-; rewrite -genB.
have: <<B>> \subset G by rewrite genB.
elim: {B genB}_.+1 {-2}B (ltnSn #|B|) => // m IHm B; rewrite ltnS.
case: (set_0Vmem B) => [-> | [x Bx]].
  by rewrite gen0 quotient1 cards1 logn1.
rewrite (cardsD1 x) Bx -{2 3}(setD1K Bx); set B' := B :\ x => ltB'm.
rewrite -joingE -joing_idl -joing_idr -/<[x]> join_subG => /andP[Gx sB'G].
rewrite cent_joinEl ?(sub_abelian_cent2 cGG) //.
have nKx: x \in 'N(K) by rewrite -cycle_subG (subset_trans Gx) ?gFnorm.
rewrite quotientMl ?cycle_subG // quotient_cycle //= -/K.
have le_Kxp_1: logn p #[coset K x] <= 1.
  rewrite -(dvdn_Pexp2l _ _ (prime_gt1 p_pr)) -p_part -order_constt.
  rewrite order_dvdn -morph_constt // -morphX ?groupX //= coset_id //.
  by rewrite Mho_p_elt ?p_elt_constt ?groupX -?cycle_subG.
apply: leq_trans (leq_add le_Kxp_1 (IHm _ ltB'm sB'G)).
by rewrite -lognM ?dvdn_leq_log ?muln_gt0 ?cardG_gt0 // mul_cardG dvdn_mulr.
Qed.

Lemma rank_cycle (x : gT) : 'r(<[x]>) = (x != 1).
Proof.
have [->|ntx] := altP (x =P 1); first by rewrite cycle1 rank1.
apply/eqP; rewrite eqn_leq rank_gt0 cycle_eq1 ntx andbT.
by rewrite -grank_abelian ?cycle_abelian //= -(cards1 x) grank_min.
Qed.

Lemma abelian_rank1_cyclic G : abelian G -> cyclic G = ('r(G) <= 1).
Proof.
move=> cGG; have [b defG atypG] := abelian_structure cGG.
apply/idP/idP; first by case/cyclicP=> x ->; rewrite rank_cycle leq_b1.
rewrite -size_abelian_type // -{}atypG -{}defG unlock.
by case: b => [|x []] //= _; rewrite ?cyclic1 // dprodg1 cycle_cyclic.
Qed.

Definition homocyclic A := abelian A && constant (abelian_type A).

Lemma homocyclic_Ohm_Mho n p G :
  p.-group G -> homocyclic G -> 'Ohm_n(G) = 'Mho^(logn p (exponent G) - n)(G).
Proof.
move=> pG /andP[cGG homoG]; set e := exponent G.
have{pG} p_e: p.-nat e by apply: pnat_dvd pG; apply: exponent_dvdn.
have{homoG}: all (pred1 e) (abelian_type G).
  move: homoG; rewrite /abelian_type -(prednK (cardG_gt0 G)) /=.
  by case: (_ && _) (tag _); rewrite //= genGid eqxx.
have{cGG} [b defG <-] := abelian_structure cGG.
move: e => e in p_e *; elim: b => /= [|x b IHb] in G defG *.
  by rewrite -defG big_nil (trivgP (Ohm_sub _ _)) (trivgP (Mho_sub _ _)).
case/andP=> /eqP ox e_b; rewrite big_cons in defG.
rewrite -(Ohm_dprod _ defG) -(Mho_dprod _ defG).
case/dprodP: defG => [[_ H _ defH] _ _ _]; rewrite defH IHb //; congr (_ \x _).
by rewrite -ox in p_e *; rewrite (Ohm_p_cycle _ p_e) (Mho_p_cycle _ p_e).
Qed.

Lemma Ohm_Mho_homocyclic (n p : nat) G :
    abelian G -> p.-group G -> 0 < n < logn p (exponent G) ->
  'Ohm_n(G) = 'Mho^(logn p (exponent G) - n)(G) -> homocyclic G.
Proof.
set e := exponent G => cGG pG /andP[n_gt0 n_lte] eq_Ohm_Mho.
suffices: all (pred1 e) (abelian_type G).
  by rewrite /homocyclic cGG; apply: all_pred1_constant.
case/abelian_structure: cGG (abelian_type_gt1 G) => b defG <-.
elim: b {-3}G defG (subxx G) eq_Ohm_Mho => //= x b IHb H.
rewrite big_cons => defG; case/dprodP: defG (defG) => [[_ K _ defK]].
rewrite defK => defHm cxK; rewrite setIC; move/trivgP=> tiKx defHd.
rewrite -{1}defHm {defHm} mulG_subG cycle_subG ltnNge -trivg_card_le1.
case/andP=> Gx sKG; rewrite -(Mho_dprod _ defHd) => /esym defMho /andP[ntx ntb].
have{defHd} defOhm := Ohm_dprod n defHd.
apply/andP; split; last first.
  apply: (IHb K) => //; have:= dprod_modr defMho (Mho_sub _ _).
  rewrite -(dprod_modr defOhm (Ohm_sub _ _)).
  rewrite !(trivgP (subset_trans (setIS _ _) tiKx)) ?Ohm_sub ?Mho_sub //.
  by rewrite !dprod1g.
have:= dprod_modl defMho (Mho_sub _ _).
rewrite -(dprod_modl defOhm (Ohm_sub _ _)) .
rewrite !(trivgP (subset_trans (setSI _ _) tiKx)) ?Ohm_sub ?Mho_sub //.
move/eqP; rewrite eqEcard => /andP[_].
have p_x: p.-elt x := mem_p_elt pG Gx.
have [p_pr p_dv_x _] := pgroup_pdiv p_x ntx.
rewrite !dprodg1 (Ohm_p_cycle _ p_x) (Mho_p_cycle _ p_x) -!orderE.
rewrite orderXdiv ?leq_divLR ?pfactor_dvdn ?leq_subr //.
rewrite orderXgcd divn_mulAC ?dvdn_gcdl // leq_divRL ?gcdn_gt0 ?order_gt0 //.
rewrite leq_pmul2l //; apply: contraLR.
rewrite eqn_dvd dvdn_exponent //= -ltnNge => lt_x_e.
rewrite (leq_trans (ltn_Pmull (prime_gt1 p_pr) _)) ?expn_gt0 ?prime_gt0 //.
rewrite -expnS dvdn_leq // ?gcdn_gt0 ?order_gt0 // dvdn_gcd.
rewrite pfactor_dvdn // dvdn_exp2l.
  by rewrite -{2}[logn p _]subn0 ltn_sub2l // lognE p_pr order_gt0 p_dv_x.
rewrite ltn_sub2r // ltnNge -(dvdn_Pexp2l _ _ (prime_gt1 p_pr)) -!p_part.
by rewrite !part_pnat_id // (pnat_dvd (exponent_dvdn G)).
Qed.

Lemma abelem_homocyclic p G : p.-abelem G -> homocyclic G.
Proof.
move=> abelG; have [_ cGG _] := and3P abelG.
rewrite /homocyclic cGG (@all_pred1_constant _ p) //.
case/abelian_structure: cGG (abelian_type_gt1 G) => b defG <- => b_gt1.
apply/allP=> _ /mapP[x b_x ->] /=; rewrite (abelem_order_p abelG) //.
  rewrite -cycle_subG -(bigdprodWY defG) ?sub_gen //.
  by rewrite bigcup_seq (bigcup_sup x).
by rewrite -order_gt1 [_ > 1](allP b_gt1) ?map_f.
Qed.

Lemma homocyclic1 : homocyclic [1 gT].
Proof. exact: abelem_homocyclic (abelem1 _ 2). Qed.

Lemma Ohm1_homocyclicP p G : p.-group G -> abelian G ->
  reflect ('Ohm_1(G) = 'Mho^(logn p (exponent G)).-1(G)) (homocyclic G).
Proof.
move=> pG cGG; set e := logn p (exponent G); rewrite -subn1.
apply: (iffP idP) => [homoG | ]; first exact: homocyclic_Ohm_Mho.
case: (ltnP 1 e) => [lt1e | ]; first exact: Ohm_Mho_homocyclic.
rewrite -subn_eq0 => /eqP->; rewrite Mho0 => <-.
exact: abelem_homocyclic (Ohm1_abelem pG cGG).
Qed.

Lemma abelian_type_homocyclic G :
  homocyclic G -> abelian_type G = nseq 'r(G) (exponent G).
Proof.
case/andP=> cGG; rewrite -size_abelian_type // /abelian_type.
rewrite -(prednK (cardG_gt0 G)) /=; case: andP => //= _; move: (tag _) => H.
by move/all_pred1P->; rewrite genGid size_nseq.
Qed.

Lemma abelian_type_abelem p G : p.-abelem G -> abelian_type G = nseq 'r(G) p.
Proof.
move=> abelG; rewrite (abelian_type_homocyclic (abelem_homocyclic abelG)).
case: (eqVneq G 1%G) => [-> | ntG]; first by rewrite rank1.
congr nseq; apply/eqP; rewrite eqn_dvd; have [pG _ ->] := and3P abelG.
have [p_pr] := pgroup_pdiv pG ntG; case/Cauchy=> // x Gx <- _.
exact: dvdn_exponent.
Qed.

Lemma max_card_abelian G :
  abelian G -> #|G| <= exponent G ^ 'r(G) ?= iff homocyclic G.
Proof.
move=> cGG; have [b defG def_tG] := abelian_structure cGG.
have Gb: all (mem G) b.
  apply/allP=> x b_x; rewrite -(bigdprodWY defG); have [b1 b2] := splitPr b_x.
  by rewrite big_cat big_cons /= mem_gen // setUCA inE cycle_id.
have ->: homocyclic G = all (pred1 (exponent G)) (abelian_type G).
  rewrite /homocyclic cGG /abelian_type; case: #|G| => //= n.
  by move: (_ (tag _)) => t; case: ifP => //= _; rewrite genGid eqxx.
rewrite -size_abelian_type // -{}def_tG -{defG}(bigdprod_card defG) size_map.
rewrite unlock; elim: b Gb => //= x b IHb; case/andP=> Gx Gb.
have eGgt0: exponent G > 0 := exponent_gt0 G.
have le_x_G: #[x] <= exponent G by rewrite dvdn_leq ?dvdn_exponent.
have:= leqif_mul (leqif_eq le_x_G) (IHb Gb).
by rewrite -expnS expn_eq0 eqn0Ngt eGgt0.
Qed.

Lemma card_homocyclic G : homocyclic G -> #|G| = (exponent G ^ 'r(G))%N.
Proof.
by move=> homG; have [cGG _] := andP homG; apply/eqP; rewrite max_card_abelian.
Qed.

Lemma abelian_type_dprod_homocyclic p K H G :
    K \x H = G -> p.-group G -> homocyclic G ->
     abelian_type K = nseq 'r(K) (exponent G)
  /\ abelian_type H = nseq 'r(H) (exponent G).
Proof.
move=> defG pG homG; have [cGG _] := andP homG.
have /mulG_sub[sKG sHG]: K * H = G by case/dprodP: defG.
have [cKK cHH] := (abelianS sKG cGG, abelianS sHG cGG).
suffices: all (pred1 (exponent G)) (abelian_type K ++ abelian_type H).
  rewrite all_cat => /andP[/all_pred1P-> /all_pred1P->].
  by rewrite !size_abelian_type.
suffices def_atG: abelian_type K ++ abelian_type H =i abelian_type G.
  rewrite (eq_all_r def_atG); apply/all_pred1P.
  by rewrite size_abelian_type // -abelian_type_homocyclic.
have [bK defK atK] := abelian_structure cKK.
have [bH defH atH] := abelian_structure cHH.
apply/perm_mem; rewrite perm_sym -atK -atH -map_cat.
apply: (abelian_type_pgroup pG); first by rewrite big_cat defK defH.
have: all [pred m | m > 1] (map order (bK ++ bH)).
  by rewrite map_cat all_cat atK atH !abelian_type_gt1.
by rewrite all_map (eq_all (@order_gt1 _)) all_predC has_pred1.
Qed.

Lemma dprod_homocyclic p K H G :
  K \x H = G -> p.-group G -> homocyclic G -> homocyclic K /\ homocyclic H.
Proof.
move=> defG pG homG; have [cGG _] := andP homG.
have /mulG_sub[sKG sHG]: K * H = G by case/dprodP: defG.
have [abtK abtH] := abelian_type_dprod_homocyclic defG pG homG.
by rewrite /homocyclic !(abelianS _ cGG) // abtK abtH !constant_nseq.
Qed.

Lemma exponent_dprod_homocyclic p K H G :
    K \x H = G -> p.-group G -> homocyclic G -> K :!=: 1 ->
  exponent K = exponent G.
Proof.
move=> defG pG homG ntK; have [homK _] := dprod_homocyclic defG pG homG.
have [] := abelian_type_dprod_homocyclic defG pG homG.
by rewrite abelian_type_homocyclic // -['r(K)]prednK ?rank_gt0 => [[]|].
Qed.

End AbelianStructure.

Arguments abelian_type {gT} A%g.
Arguments homocyclic {gT} A%g.

Section IsogAbelian.

Variables aT rT : finGroupType.
Implicit Type (gT : finGroupType) (D G : {group aT}) (H : {group rT}).

Lemma isog_abelian_type G H : isog G H -> abelian_type G = abelian_type H.
Proof.
pose lnO p n gT (A : {set gT}) := logn p #|'Ohm_n.+1(A) : 'Ohm_n(A)|.
pose lni i p gT (A : {set gT}) := \max_(e < logn p #|A| | i < lnO p e _ A) e.+1.
suffices{G} nth_abty gT (G : {group gT}) i:
    abelian G -> i < size (abelian_type G) ->
  nth 1%N (abelian_type G) i = (\prod_(p < #|G|.+1) p ^ lni i p _ G)%N.
- move=> isoGH; case cGG: (abelian G); last first.
    rewrite /abelian_type -(prednK (cardG_gt0 G)) -(prednK (cardG_gt0 H)) /=.
    by rewrite {1}(genGid G) {1}(genGid H) -(isog_abelian isoGH) cGG.
  have cHH: abelian H by rewrite -(isog_abelian isoGH).
  have eq_sz: size (abelian_type G) = size (abelian_type H).
    by rewrite !size_abelian_type ?(isog_rank isoGH).
  apply: (@eq_from_nth _ 1%N) => // i lt_i_G; rewrite !nth_abty // -?eq_sz //.
  rewrite /lni (card_isog isoGH); apply: eq_bigr => p _; congr (p ^ _)%N.
  apply: eq_bigl => e; rewrite /lnO -!divgS ?(Ohm_leq _ (leqnSn _)) //=.
  by have:= card_isog (gFisog _ isoGH) => /= eqF; rewrite !eqF.
move=> cGG.
have (p): path leq 0 (map (logn p) (rev (abelian_type G))).
  move: (abelian_type_gt1 G) (abelian_type_dvdn_sorted G).
  case: abelian_type => //= m t; rewrite rev_cons map_rcons.
  elim: t m => //= n t IHt m /andP[/ltnW m_gt0 nt_gt1].
  rewrite -cats1 cat_path rev_cons map_rcons last_rcons /=.
  by case/andP=> /dvdn_leq_log-> // /IHt->.
have{cGG} [b defG <- b_sorted] := abelian_structure cGG.
rewrite size_map => ltib; rewrite (nth_map 1 _ _ ltib); set x := nth 1 b i.
have Gx: x \in G.
  have: x \in b by rewrite mem_nth.
  rewrite -(bigdprodWY defG); case/splitPr=> bl br.
  by rewrite mem_gen // big_cat big_cons !inE cycle_id orbT.
have lexG: #[x] <= #|G| by rewrite dvdn_leq ?order_dvdG.
rewrite -[#[x]]partn_pi // (widen_partn _ lexG) big_mkord big_mkcond.
apply: eq_bigr => p _; transitivity (p ^ logn p #[x])%N.
  by rewrite -logn_gt0; case: posnP => // ->.
suffices lti_lnO e: (i < lnO p e _ G) = (e < logn p #[x]).
  congr (p ^ _)%N; apply/eqP; rewrite eqn_leq andbC; apply/andP; split.
    by apply/bigmax_leqP=> e; rewrite lti_lnO.
  case: (posnP (logn p #[x])) => [-> // | logx_gt0].
  have lexpG: (logn p #[x]).-1 < logn p #|G|.
    by rewrite prednK // dvdn_leq_log ?order_dvdG.
  by rewrite (@bigmax_sup _ (Ordinal lexpG)) ?(prednK, lti_lnO).
rewrite /lnO -(count_logn_dprod_cycle _ _ defG).
case: (ltnP e _) (b_sorted p) => [lt_e_x | le_x_e].
  rewrite -(cat_take_drop i.+1 b) -map_rev rev_cat !map_cat cat_path.
  case/andP=> _ ordb; rewrite count_cat ((count _ _ =P i.+1) _) ?leq_addr //.
  rewrite -{2}(size_takel ltib) -all_count.
  move: ordb; rewrite (take_nth 1 ltib) -/x rev_rcons all_rcons /= lt_e_x.
  case/andP=> _ /=; move/(order_path_min leq_trans); apply: contraLR.
  rewrite -!has_predC !has_map; case/hasP=> y b_y /= le_y_e; apply/hasP.
  by exists y; rewrite ?mem_rev //=; apply: contra le_y_e; apply: leq_trans.
rewrite -(cat_take_drop i b) -map_rev rev_cat !map_cat cat_path.
case/andP=> ordb _; rewrite count_cat -{1}(size_takel (ltnW ltib)) ltnNge.
rewrite addnC ((count _ _ =P 0) _) ?count_size //.
rewrite eqn0Ngt -has_count; apply/hasPn=> y b_y /=; rewrite -leqNgt.
apply: leq_trans le_x_e; have ->: x = last x (rev (drop i b)).
  by rewrite (drop_nth 1 ltib) rev_cons last_rcons.
rewrite -mem_rev in b_y; case/splitPr: (rev _) / b_y ordb => b1 b2.
rewrite !map_cat cat_path last_cat /=; case/and3P=> _ _.
move/(order_path_min leq_trans); case/lastP: b2 => // b3 x'.
by move/allP; apply; rewrite ?map_f ?last_rcons ?mem_rcons ?mem_head.
Qed.

Lemma eq_abelian_type_isog G H :
  abelian G -> abelian H -> isog G H = (abelian_type G == abelian_type H).
Proof.
move=> cGG cHH; apply/idP/eqP; first exact: isog_abelian_type.
have{cGG} [bG defG <-] := abelian_structure cGG.
have{cHH} [bH defH <-] := abelian_structure cHH.
elim: bG bH G H defG defH => [|x bG IHb] [|y bH] // G H.
  rewrite !big_nil => <- <- _.
  by rewrite isog_cyclic_card ?cyclic1 ?cards1.
rewrite !big_cons => defG defH /= [eqxy eqb].
apply: (isog_dprod defG defH).
  by rewrite isog_cyclic_card ?cycle_cyclic -?orderE ?eqxy /=.
case/dprodP: defG => [[_ G' _ defG]] _ _ _; rewrite defG.
case/dprodP: defH => [[_ H' _ defH]] _ _ _; rewrite defH.
exact: IHb eqb.
Qed.

Lemma isog_abelem_card p G H :
  p.-abelem G -> isog G H = p.-abelem H && (#|H| == #|G|).
Proof.
move=> abelG; apply/idP/andP=> [isoGH | [abelH eqGH]].
  by rewrite -(isog_abelem isoGH) (card_isog isoGH).
rewrite eq_abelian_type_isog ?(@abelem_abelian _ p) //.
by rewrite !(@abelian_type_abelem _ p) ?(@rank_abelem _ p) // (eqP eqGH).
Qed.

Variables (D : {group aT}) (f : {morphism D >-> rT}).

Lemma morphim_rank_abelian G : abelian G -> 'r(f @* G) <= 'r(G).
Proof.
move=> cGG; have sHG := subsetIr D G; apply: leq_trans (rankS sHG).
rewrite -!grank_abelian ?morphim_abelian ?(abelianS sHG) //=.
by rewrite -morphimIdom morphim_grank ?subsetIl.
Qed.

Lemma morphim_p_rank_abelian p G : abelian G -> 'r_p(f @* G) <= 'r_p(G).
Proof.
move=> cGG; have sHG := subsetIr D G; apply: leq_trans (p_rankS p sHG).
have cHH := abelianS sHG cGG; rewrite -morphimIdom /=; set H := D :&: G.
have sylP := nilpotent_pcore_Hall p (abelian_nil cHH).
have sPH := pHall_sub sylP.
have sPD: 'O_p(H) \subset D by rewrite (subset_trans sPH) ?subsetIl.
rewrite -(p_rank_Sylow (morphim_pHall f sPD sylP)) -(p_rank_Sylow sylP) //.
rewrite -!rank_pgroup ?morphim_pgroup ?pcore_pgroup //.
by rewrite morphim_rank_abelian ?(abelianS sPH).
Qed.

Lemma isog_homocyclic G H : G \isog H -> homocyclic G = homocyclic H.
Proof.
move=> isoGH.
by rewrite /homocyclic (isog_abelian isoGH) (isog_abelian_type isoGH).
Qed.

End IsogAbelian.

Section QuotientRank.

Variables (gT : finGroupType) (p : nat) (G H : {group gT}).
Hypothesis cGG : abelian G.

Lemma quotient_rank_abelian : 'r(G / H) <= 'r(G).
Proof. exact: morphim_rank_abelian. Qed.

Lemma quotient_p_rank_abelian : 'r_p(G / H) <= 'r_p(G).
Proof. exact: morphim_p_rank_abelian. Qed.

End QuotientRank.

Section FimModAbelem.

Import GRing.Theory FinRing.Theory.

Lemma fin_lmod_char_abelem p (R : ringType) (V : finLmodType R):
  p \in [char R]%R -> p.-abelem [set: V].
Proof.
case/andP=> p_pr /eqP-pR0; apply/abelemP=> //.
by split=> [|v _]; rewrite ?zmod_abelian // zmodXgE -scaler_nat pR0 scale0r.
Qed.

Lemma fin_Fp_lmod_abelem p (V : finLmodType 'F_p) :
  prime p -> p.-abelem [set: V].
Proof. by move/char_Fp/fin_lmod_char_abelem->. Qed.

Lemma fin_ring_char_abelem p (R : finRingType) :
  p \in [char R]%R -> p.-abelem [set: R].
Proof. exact: fin_lmod_char_abelem [finLmodType R of R^o]. Qed.

End FimModAbelem.