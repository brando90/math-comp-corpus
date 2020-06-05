
From mathcomp Require Import ssreflect ssrbool ssrfun eqtype ssrnat seq div.
From mathcomp Require Import fintype bigop prime finset fingroup morphism.
From mathcomp Require Import perm automorphism quotient gproduct ssralg.
From mathcomp Require Import finalg zmodp poly.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Import GroupScope GRing.Theory.

Section Cyclic.

Variable gT : finGroupType.
Implicit Types (a x y : gT) (A B : {set gT}) (G K H : {group gT}).

Definition cyclic A := [exists x, A == <[x]>].

Lemma cyclicP A : reflect (exists x, A = <[x]>) (cyclic A).
Proof. exact: exists_eqP. Qed.

Lemma cycle_cyclic x : cyclic <[x]>.
Proof. by apply/cyclicP; exists x. Qed.

Lemma cyclic1 : cyclic [1 gT].
Proof. by rewrite -cycle1 cycle_cyclic. Qed.

Section Zpm.

Variable a : gT.

Definition Zpm (i : 'Z_#[a]) := a ^+ i.

Lemma ZpmM : {in Zp #[a] &, {morph Zpm : x y / x * y}}.
Proof.
rewrite /Zpm; case: (eqVneq a 1) => [-> | nta] i j _ _.
  by rewrite !expg1n ?mulg1.
by rewrite /= {3}Zp_cast ?order_gt1 // expg_mod_order expgD.
Qed.

Canonical Zpm_morphism := Morphism ZpmM.

Lemma im_Zpm : Zpm @* Zp #[a] = <[a]>.
Proof.
apply/eqP; rewrite eq_sym eqEcard cycle_subG /= andbC morphimEdom.
rewrite (leq_trans (leq_imset_card _ _)) ?card_Zp //= /Zp order_gt1.
case: eqP => /= [a1 | _]; first by rewrite imset_set1 morph1 a1 set11.
by apply/imsetP; exists 1%R; rewrite ?expg1 ?inE.
Qed.

Lemma injm_Zpm : 'injm Zpm.
Proof.
apply/injmP/dinjectiveP/card_uniqP.
rewrite size_map -cardE card_Zp //= {7}/order -im_Zpm morphimEdom /=.
by apply: eq_card => x; apply/imageP/imsetP=> [] [i Zp_i ->]; exists i.
Qed.

Lemma eq_expg_mod_order m n : (a ^+ m == a ^+ n) = (m == n %[mod #[a]]).
Proof.
have [->|] := eqVneq a 1; first by rewrite order1 !modn1 !expg1n eqxx.
rewrite -order_gt1 => lt1a; have ZpT: Zp #[a] = setT by rewrite /Zp lt1a.
have: injective Zpm by move=> i j; apply (injmP injm_Zpm); rewrite /= ZpT inE.
move/inj_eq=> eqZ; symmetry; rewrite -(Zp_cast lt1a).
by rewrite -[_ == _](eqZ (inZp m) (inZp n)) /Zpm /= Zp_cast ?expg_mod_order.
Qed.

Lemma Zp_isom : isom (Zp #[a]) <[a]> Zpm.
Proof. by apply/isomP; rewrite injm_Zpm im_Zpm. Qed.

Lemma Zp_isog : isog (Zp #[a]) <[a]>.
Proof. exact: isom_isog Zp_isom. Qed.

End Zpm.

Lemma cyclic_abelian A : cyclic A -> abelian A.
Proof. by case/cyclicP=> a ->; apply: cycle_abelian. Qed.

Lemma cycleMsub a b :
  commute a b -> coprime #[a] #[b] -> <[a]> \subset <[a * b]>.
Proof.
move=> cab co_ab; apply/subsetP=> _ /cycleP[k ->].
apply/cycleP; exists (chinese #[a] #[b] k 0); symmetry.
rewrite expgMn // -expg_mod_order chinese_modl // expg_mod_order.
by rewrite /chinese addn0 -mulnA mulnCA expgM expg_order expg1n mulg1.
Qed.

Lemma cycleM a b :
  commute a b -> coprime #[a] #[b] -> <[a * b]> = <[a]> * <[b]>.
Proof.
move=> cab co_ab; apply/eqP; rewrite eqEsubset -(cent_joinEl (cents_cycle cab)).
rewrite join_subG {3}cab !cycleMsub // 1?coprime_sym //.
by rewrite -genM_join cycle_subG mem_gen // mem_imset2 ?cycle_id.
Qed.

Lemma cyclicM A B :
    cyclic A -> cyclic B -> B \subset 'C(A) -> coprime #|A| #|B| ->
  cyclic (A * B).
Proof.
move=> /cyclicP[a ->] /cyclicP[b ->]; rewrite cent_cycle cycle_subG => cab coab.
by rewrite -cycleM ?cycle_cyclic //; apply/esym/cent1P.
Qed.

Lemma cyclicY K H :
    cyclic K -> cyclic H -> H \subset 'C(K) -> coprime #|K| #|H| ->
  cyclic (K <*> H).
Proof. by move=> cycK cycH cKH coKH; rewrite cent_joinEr // cyclicM. Qed.

Lemma order_dvdn a n : #[a] %| n = (a ^+ n == 1).
Proof. by rewrite (eq_expg_mod_order a n 0) mod0n. Qed.

Lemma order_inf a n : a ^+ n.+1 == 1 -> #[a] <= n.+1.
Proof. by rewrite -order_dvdn; apply: dvdn_leq. Qed.

Lemma order_dvdG G a : a \in G -> #[a] %| #|G|.
Proof. by move=> Ga; apply: cardSg; rewrite cycle_subG. Qed.

Lemma expg_cardG G a : a \in G -> a ^+ #|G| = 1.
Proof. by move=> Ga; apply/eqP; rewrite -order_dvdn order_dvdG. Qed.

Lemma expg_znat G x k : x \in G -> x ^+ (k%:R : 'Z_(#|G|))%R = x ^+ k.
Proof.
case: (eqsVneq G 1) => [-> /set1P-> | ntG Gx]; first by rewrite !expg1n.
apply/eqP; rewrite val_Zp_nat ?cardG_gt1 // eq_expg_mod_order.
by rewrite modn_dvdm ?order_dvdG.
Qed.

Lemma expg_zneg G x (k : 'Z_(#|G|)) : x \in G -> x ^+ (- k)%R = x ^- k.
Proof.
move=> Gx; apply/eqP; rewrite eq_sym eq_invg_mul -expgD.
by rewrite -(expg_znat _ Gx) natrD natr_Zp natr_negZp subrr.
Qed.

Lemma nt_gen_prime G x : prime #|G| -> x \in G^# -> G :=: <[x]>.
Proof.
move=> Gpr /setD1P[]; rewrite -cycle_subG -cycle_eq1 => ntX sXG.
apply/eqP; rewrite eqEsubset sXG andbT.
by apply: contraR ntX => /(prime_TIg Gpr); rewrite (setIidPr sXG) => ->.
Qed.

Lemma nt_prime_order p x : prime p -> x ^+ p = 1 -> x != 1 -> #[x] = p.
Proof.
move=> p_pr xp ntx; apply/prime_nt_dvdP; rewrite ?order_eq1 //.
by rewrite order_dvdn xp.
Qed.

Lemma orderXdvd a n : #[a ^+ n] %| #[a].
Proof. by apply: order_dvdG; apply: mem_cycle. Qed.

Lemma orderXgcd a n : #[a ^+ n] = #[a] %/ gcdn #[a] n.
Proof.
apply/eqP; rewrite eqn_dvd; apply/andP; split.
  rewrite order_dvdn -expgM -muln_divCA_gcd //.
  by rewrite expgM expg_order expg1n.
have [-> | n_gt0] := posnP n; first by rewrite gcdn0 divnn order_gt0 dvd1n.
rewrite -(dvdn_pmul2r n_gt0) divn_mulAC ?dvdn_gcdl // dvdn_lcm.
by rewrite order_dvdn mulnC expgM expg_order eqxx dvdn_mulr.
Qed.

Lemma orderXdiv a n : n %| #[a] -> #[a ^+ n] = #[a] %/ n.
Proof. by case/dvdnP=> q defq; rewrite orderXgcd {2}defq gcdnC gcdnMl. Qed.

Lemma orderXexp p m n x : #[x] = (p ^ n)%N -> #[x ^+ (p ^ m)] = (p ^ (n - m))%N.
Proof.
move=> ox; have [n_le_m | m_lt_n] := leqP n m.
  rewrite -(subnKC n_le_m) subnDA subnn expnD expgM -ox.
  by rewrite expg_order expg1n order1.
rewrite orderXdiv ox ?dvdn_exp2l ?expnB ?(ltnW m_lt_n) //.
by have:= order_gt0 x; rewrite ox expn_gt0 orbC -(ltn_predK m_lt_n).
Qed.

Lemma orderXpfactor p k n x :
  #[x ^+ (p ^ k)] = n -> prime p -> p %| n -> #[x] = (p ^ k * n)%N.
Proof.
move=> oxp p_pr dv_p_n.
suffices pk_x: p ^ k %| #[x] by rewrite -oxp orderXdiv // mulnC divnK.
rewrite pfactor_dvdn // leqNgt; apply: contraL dv_p_n => lt_x_k.
rewrite -oxp -p'natE // -(subnKC (ltnW lt_x_k)) expnD expgM.
rewrite (pnat_dvd (orderXdvd _ _)) // -p_part // orderXdiv ?dvdn_part //.
by rewrite -{1}[#[x]](partnC p) // mulKn // part_pnat.
Qed.

Lemma orderXprime p n x :
  #[x ^+ p] = n -> prime p -> p %| n -> #[x] = (p * n)%N.
Proof. exact: (@orderXpfactor p 1). Qed.

Lemma orderXpnat m n x : #[x ^+ m] = n -> \pi(n).-nat m -> #[x] = (m * n)%N.
Proof.
move=> oxm n_m; have [m_gt0 _] := andP n_m.
suffices m_x: m %| #[x] by rewrite -oxm orderXdiv // mulnC divnK.
apply/dvdn_partP=> // p; rewrite mem_primes => /and3P[p_pr _ p_m].
have n_p: p \in \pi(n) by apply: (pnatP _ _ n_m).
have p_oxm: p %| #[x ^+ (p ^ logn p m)].
  apply: dvdn_trans (orderXdvd _ m`_p^'); rewrite -expgM -p_part ?partnC //.
  by rewrite oxm; rewrite mem_primes in n_p; case/and3P: n_p.
by rewrite (orderXpfactor (erefl _) p_pr p_oxm) p_part // dvdn_mulr.
Qed.

Lemma orderM a b :
  commute a b -> coprime #[a] #[b] -> #[a * b] = (#[a] * #[b])%N.
Proof. by move=> cab co_ab; rewrite -coprime_cardMg -?cycleM. Qed.

Definition expg_invn A k := (egcdn k #|A|).1.

Lemma expgK G k :
  coprime #|G| k -> {in G, cancel (expgn^~ k) (expgn^~ (expg_invn G k))}.
Proof.
move=> coGk x /order_dvdG Gx; apply/eqP.
rewrite -expgM (eq_expg_mod_order _ _ 1) -(modn_dvdm 1 Gx).
by rewrite -(chinese_modl coGk 1 0) /chinese mul1n addn0 modn_dvdm.
Qed.

Lemma cyclic_dprod K H G :
  K \x H = G -> cyclic K -> cyclic H -> cyclic G = coprime #|K| #|H| .
Proof.
case/dprodP=> _ defKH cKH tiKH cycK cycH; pose m := lcmn #|K| #|H|.
apply/idP/idP=> [/cyclicP[x defG] | coKH]; last by rewrite -defKH cyclicM.
rewrite /coprime -dvdn1 -(@dvdn_pmul2l m) ?lcmn_gt0 ?cardG_gt0 //.
rewrite muln_lcm_gcd muln1 -TI_cardMg // defKH defG order_dvdn.
have /mulsgP[y z Ky Hz ->]: x \in K * H by rewrite defKH defG cycle_id.
rewrite -[1]mulg1 expgMn; last exact/commute_sym/(centsP cKH).
apply/eqP; congr (_ * _); apply/eqP; rewrite -order_dvdn.
  exact: dvdn_trans (order_dvdG Ky) (dvdn_lcml _ _).
exact: dvdn_trans (order_dvdG Hz) (dvdn_lcmr _ _).
Qed.

Definition generator (A : {set gT}) a := A == <[a]>.

Lemma generator_cycle a : generator <[a]> a.
Proof. exact: eqxx. Qed.

Lemma cycle_generator a x : generator <[a]> x -> x \in <[a]>.
Proof. by move/(<[a]> =P _)->; apply: cycle_id. Qed.

Lemma generator_order a b : generator <[a]> b -> #[a] = #[b].
Proof. by rewrite /order => /(<[a]> =P _)->. Qed.

End Cyclic.

Arguments cyclic {gT} A%g.
Arguments generator {gT} A%g a%g.
Arguments expg_invn {gT} A%g k%N.
Arguments cyclicP {gT A}.
Prenex Implicits cyclic Zpm.

Theorem Euler_exp_totient a n : coprime a n -> a ^ totient n  = 1 %[mod n].
Proof.
case: n => [|[|n']] //; [by rewrite !modn1 | set n := n'.+2] => co_a_n.
have{co_a_n} Ua: coprime n (inZp a : 'I_n) by rewrite coprime_sym coprime_modl.
have: FinRing.unit 'Z_n Ua ^+ totient n == 1.
  by rewrite -card_units_Zp // -order_dvdn order_dvdG ?inE.
by rewrite -2!val_eqE unit_Zp_expg /= -/n modnXm => /eqP.
Qed.

Section Eltm.

Variables (aT rT : finGroupType) (x : aT) (y : rT).

Definition eltm of #[y] %| #[x] := fun x_i => y ^+ invm (injm_Zpm x) x_i.

Hypothesis dvd_y_x : #[y] %| #[x].

Lemma eltmE i : eltm dvd_y_x (x ^+ i) = y ^+ i.
Proof.
apply/eqP; rewrite eq_expg_mod_order.
have [x_le1 | x_gt1] := leqP #[x] 1.
  suffices: #[y] %| 1 by rewrite dvdn1 => /eqP->; rewrite !modn1.
  by rewrite (dvdn_trans dvd_y_x) // dvdn1 order_eq1 -cycle_eq1 trivg_card_le1.
rewrite -(expg_znat i (cycle_id x)) invmE /=; last by rewrite /Zp x_gt1 inE.
by rewrite val_Zp_nat // modn_dvdm.
Qed.

Lemma eltm_id : eltm dvd_y_x x = y. Proof. exact: (eltmE 1). Qed.

Lemma eltmM : {in <[x]> &, {morph eltm dvd_y_x : x_i x_j / x_i * x_j}}.
Proof.
move=> _ _ /cycleP[i ->] /cycleP[j ->].
by apply/eqP; rewrite -expgD !eltmE expgD.
Qed.
Canonical eltm_morphism := Morphism eltmM.

Lemma im_eltm : eltm dvd_y_x @* <[x]> = <[y]>.
Proof. by rewrite morphim_cycle ?cycle_id //= eltm_id. Qed.

Lemma ker_eltm : 'ker (eltm dvd_y_x) = <[x ^+ #[y]]>.
Proof.
apply/eqP; rewrite eq_sym eqEcard cycle_subG 3!inE mem_cycle /= eltmE.
rewrite expg_order eqxx (orderE y) -im_eltm card_morphim setIid -orderE.
by rewrite orderXdiv ?dvdn_indexg //= leq_divRL ?indexg_gt0 ?Lagrange ?subsetIl.
Qed.

Lemma injm_eltm : 'injm (eltm dvd_y_x) = (#[x] %| #[y]).
Proof. by rewrite ker_eltm subG1 cycle_eq1 -order_dvdn. Qed.

End Eltm.

Section CycleSubGroup.

Variable gT : finGroupType.

Lemma cycle_sub_group (a : gT) m :
     m %| #[a] ->
  [set H : {group gT} | H \subset <[a]> & #|H| == m]
     = [set <[a ^+ (#[a] %/ m)]>%G].
Proof.
move=> m_dv_a; have m_gt0: 0 < m by apply: dvdn_gt0 m_dv_a.
have oam: #|<[a ^+ (#[a] %/ m)]>| = m.
  apply/eqP; rewrite [#|_|]orderXgcd -(divnMr m_gt0) muln_gcdl divnK //.
  by rewrite gcdnC gcdnMr mulKn.
apply/eqP; rewrite eqEsubset sub1set inE /= cycleX oam eqxx !andbT.
apply/subsetP=> X; rewrite in_set1 inE -val_eqE /= eqEcard oam.
case/andP=> sXa /eqP oX; rewrite oX leqnn andbT.
apply/subsetP=> x Xx; case/cycleP: (subsetP sXa _ Xx) => k def_x.
have: (x ^+ m == 1)%g by rewrite -oX -order_dvdn cardSg // gen_subG sub1set.
rewrite {x Xx}def_x -expgM -order_dvdn -[#[a]](Lagrange sXa) -oX mulnC.
rewrite dvdn_pmul2r // mulnK // => /dvdnP[i ->].
by rewrite mulnC expgM groupX // cycle_id.
Qed.

Lemma cycle_subgroup_char a (H : {group gT}) : H \subset <[a]> -> H \char <[a]>.
Proof.
move=> sHa; apply: lone_subgroup_char => // J sJa isoJH.
have dvHa: #|H| %| #[a] by apply: cardSg.
have{dvHa} /setP Huniq := esym (cycle_sub_group dvHa).
move: (Huniq H) (Huniq J); rewrite !inE /=.
by rewrite sHa sJa (card_isog isoJH) eqxx => /eqP<- /eqP<-.
Qed.

End CycleSubGroup.

Section MorphicImage.

Variables aT rT : finGroupType.
Variables (D : {group aT}) (f : {morphism D >-> rT}) (x : aT).
Hypothesis Dx : x \in D.

Lemma morph_order : #[f x] %| #[x].
Proof. by rewrite order_dvdn -morphX // expg_order morph1. Qed.

Lemma morph_generator A : generator A x -> generator (f @* A) (f x).
Proof. by move/(A =P _)->; rewrite /generator morphim_cycle. Qed.

End MorphicImage.

Section CyclicProps.

Variables gT : finGroupType.
Implicit Types (aT rT : finGroupType) (G H K : {group gT}).

Lemma cyclicS G H : H \subset G -> cyclic G -> cyclic H.
Proof.
move=> sHG /cyclicP[x defG]; apply/cyclicP.
exists (x ^+ (#[x] %/ #|H|)); apply/congr_group/set1P.
by rewrite -cycle_sub_group /order -defG ?cardSg // inE sHG eqxx.
Qed.

Lemma cyclicJ G x : cyclic (G :^ x) = cyclic G.
Proof.
apply/cyclicP/cyclicP=> [[y /(canRL (conjsgK x))] | [y ->]].
  by rewrite -cycleJ; exists (y ^ x^-1).
by exists (y ^ x); rewrite cycleJ.
Qed.

Lemma eq_subG_cyclic G H K :
  cyclic G -> H \subset G -> K \subset G -> (H :==: K) = (#|H| == #|K|).
Proof.
case/cyclicP=> x -> sHx sKx; apply/eqP/eqP=> [-> //| eqHK].
have def_GHx := cycle_sub_group (cardSg sHx); set GHx := [set _] in def_GHx.
have []: H \in GHx /\ K \in GHx by rewrite -def_GHx !inE sHx sKx eqHK /=.
by do 2!move/set1P->.
Qed.

Lemma cardSg_cyclic G H K :
  cyclic G -> H \subset G -> K \subset G -> (#|H| %| #|K|) = (H \subset K).
Proof.
move=> cycG sHG sKG; apply/idP/idP; last exact: cardSg.
case/cyclicP: (cyclicS sKG cycG) => x defK; rewrite {K}defK in sKG *.
case/dvdnP=> k ox; suffices ->: H :=: <[x ^+ k]> by apply: cycleX.
apply/eqP; rewrite (eq_subG_cyclic cycG) ?(subset_trans (cycleX _ _)) //.
rewrite -orderE orderXdiv orderE ox ?dvdn_mulr ?mulKn //.
by have:= order_gt0 x; rewrite orderE ox; case k.
Qed.

Lemma sub_cyclic_char G H : cyclic G -> (H \char G) = (H \subset G).
Proof.
case/cyclicP=> x ->; apply/idP/idP => [/andP[] //|].
exact: cycle_subgroup_char.
Qed.

Lemma morphim_cyclic rT G H (f : {morphism G >-> rT}) :
  cyclic H -> cyclic (f @* H).
Proof.
move=> cycH; wlog sHG: H cycH / H \subset G.
  by rewrite -morphimIdom; apply; rewrite (cyclicS _ cycH, subsetIl) ?subsetIr.
case/cyclicP: cycH sHG => x ->; rewrite gen_subG sub1set => Gx.
by apply/cyclicP; exists (f x); rewrite morphim_cycle.
Qed.

Lemma quotient_cycle x H : x \in 'N(H) -> <[x]> / H = <[coset H x]>.
Proof. exact: morphim_cycle. Qed.

Lemma quotient_cyclic G H : cyclic G -> cyclic (G / H).
Proof. exact: morphim_cyclic. Qed.

Lemma quotient_generator x G H :
  x \in 'N(H) -> generator G x -> generator (G / H) (coset H x).
Proof. by move=> Nx; apply: morph_generator. Qed.

Lemma prime_cyclic G : prime #|G| -> cyclic G.
Proof.
case/primeP; rewrite ltnNge -trivg_card_le1.
case/trivgPn=> x Gx ntx /(_ _ (order_dvdG Gx)).
rewrite order_eq1 (negbTE ntx) => /eqnP oxG; apply/cyclicP.
by exists x; apply/eqP; rewrite eq_sym eqEcard -oxG cycle_subG Gx leqnn.
Qed.

Lemma dvdn_prime_cyclic G p : prime p -> #|G| %| p -> cyclic G.
Proof.
move=> p_pr pG; case: (eqsVneq G 1) => [-> | ntG]; first exact: cyclic1.
by rewrite prime_cyclic // (prime_nt_dvdP p_pr _ pG) -?trivg_card1.
Qed.

Lemma cyclic_small G : #|G| <= 3 -> cyclic G.
Proof.
rewrite 4!(ltnS, leq_eqVlt) -trivg_card_le1 orbA orbC.
case/predU1P=> [-> | oG]; first exact: cyclic1.
by apply: prime_cyclic; case/pred2P: oG => ->.
Qed.

End CyclicProps.

Section IsoCyclic.

Variables gT rT : finGroupType.
Implicit Types (G H : {group gT}) (M : {group rT}).

Lemma injm_cyclic G H (f : {morphism G >-> rT}) :
  'injm f -> H \subset G -> cyclic (f @* H) = cyclic H.
Proof.
move=> injf sHG; apply/idP/idP; last exact: morphim_cyclic.
by rewrite -{2}(morphim_invm injf sHG); apply: morphim_cyclic.
Qed.

Lemma isog_cyclic G M : G \isog M -> cyclic G = cyclic M.
Proof. by case/isogP=> f injf <-; rewrite injm_cyclic. Qed.

Lemma isog_cyclic_card G M : cyclic G -> isog G M = cyclic M && (#|M| == #|G|).
Proof.
move=> cycG; apply/idP/idP=> [isoGM | ].
  by rewrite (card_isog isoGM) -(isog_cyclic isoGM) cycG /=.
case/cyclicP: cycG => x ->{G} /andP[/cyclicP[y ->] /eqP oy].
by apply: isog_trans (isog_symr _) (Zp_isog y); rewrite /order oy Zp_isog.
Qed.

Lemma injm_generator G H (f : {morphism G >-> rT}) x :
    'injm f -> x \in G -> H \subset G ->
  generator (f @* H) (f x) = generator H x.
Proof.
move=> injf Gx sHG; apply/idP/idP; last exact: morph_generator.
rewrite -{2}(morphim_invm injf sHG) -{2}(invmE injf Gx).
by apply: morph_generator; apply: mem_morphim.
Qed.

End IsoCyclic.

Section Metacyclic.

Variable gT : finGroupType.
Implicit Types (A : {set gT}) (G H : {group gT}).

Definition metacyclic A :=
  [exists H : {group gT}, [&& cyclic H, H <| A & cyclic (A / H)]].

Lemma metacyclicP A :
  reflect (exists H : {group gT}, [/\ cyclic H, H <| A & cyclic (A / H)])
          (metacyclic A).
Proof. exact: 'exists_and3P. Qed.

Lemma metacyclic1 : metacyclic 1.
Proof.
by apply/existsP; exists 1%G; rewrite normal1 trivg_quotient !cyclic1.
Qed.

Lemma cyclic_metacyclic A : cyclic A -> metacyclic A.
Proof.
case/cyclicP=> x ->; apply/existsP; exists (<[x]>)%G.
by rewrite normal_refl cycle_cyclic trivg_quotient cyclic1.
Qed.

Lemma metacyclicS G H : H \subset G -> metacyclic G -> metacyclic H.
Proof.
move=> sHG /metacyclicP[K [cycK nsKG cycGq]]; apply/metacyclicP.
exists (H :&: K)%G; rewrite (cyclicS (subsetIr H K)) ?(normalGI sHG) //=.
rewrite setIC (isog_cyclic (second_isog _)) ?(cyclicS _ cycGq) ?quotientS //.
by rewrite (subset_trans sHG) ?normal_norm.
Qed.

End Metacyclic.

Arguments metacyclic {gT} A%g.
Arguments metacyclicP {gT A}.

Section CyclicAutomorphism.

Variable gT : finGroupType.

Section CycleAutomorphism.

Variable a : gT.

Section CycleMorphism.

Variable n : nat.

Definition cyclem of gT := fun x : gT => x ^+ n.

Lemma cyclemM : {in <[a]> & , {morph cyclem a : x y / x * y}}.
Proof.
by move=> x y ax ay; apply: expgMn; apply: (centsP (cycle_abelian a)).
Qed.

Canonical cyclem_morphism := Morphism cyclemM.

End CycleMorphism.

Section ZpUnitMorphism.

Variable u : {unit 'Z_#[a]}.

Lemma injm_cyclem : 'injm (cyclem (val u) a).
Proof.
apply/subsetP=> x /setIdP[ax]; rewrite !inE -order_dvdn.
case: (eqVneq a 1) => [a1 | nta]; first by rewrite a1 cycle1 inE in ax.
rewrite -order_eq1 -dvdn1; move/eqnP: (valP u) => /= <-.
by rewrite dvdn_gcd {2}Zp_cast ?order_gt1 // order_dvdG.
Qed.

Lemma im_cyclem : cyclem (val u) a @* <[a]> = <[a]>.
Proof.
apply/morphim_fixP=> //; first exact: injm_cyclem.
by rewrite morphim_cycle ?cycle_id ?cycleX.
Qed.

Definition Zp_unitm := aut injm_cyclem im_cyclem.

End ZpUnitMorphism.

Lemma Zp_unitmM : {in units_Zp #[a] &, {morph Zp_unitm : u v / u * v}}.
Proof.
move=> u v _ _; apply: (eq_Aut (Aut_aut _ _)) => [|x a_x].
  by rewrite groupM ?Aut_aut.
rewrite permM !autE ?groupX //= /cyclem -expgM.
rewrite -expg_mod_order modn_dvdm ?expg_mod_order //.
case: (leqP #[a] 1) => [lea1 | lt1a]; last by rewrite Zp_cast ?order_dvdG.
by rewrite card_le1_trivg // in a_x; rewrite (set1P a_x) order1 dvd1n.
Qed.

Canonical Zp_unit_morphism := Morphism Zp_unitmM.

Lemma injm_Zp_unitm : 'injm Zp_unitm.
Proof.
case: (eqVneq a 1) => [a1 | nta].
  by rewrite subIset //= card_le1_trivg ?subxx // card_units_Zp a1 order1.
apply/subsetP=> /= u /morphpreP[_ /set1P/= um1].
have{um1}: Zp_unitm u a == Zp_unitm 1 a by rewrite um1 morph1.
rewrite !autE ?cycle_id // eq_expg_mod_order.
by rewrite -[n in _ == _ %[mod n]]Zp_cast ?order_gt1 // !modZp inE.
Qed.

Lemma generator_coprime m : generator <[a]> (a ^+ m) = coprime #[a] m.
Proof.
rewrite /generator eq_sym eqEcard cycleX -/#[a] [#|_|]orderXgcd /=.
apply/idP/idP=> [le_a_am|co_am]; last by rewrite (eqnP co_am) divn1.
have am_gt0: 0 < gcdn #[a] m by rewrite gcdn_gt0 order_gt0.
by rewrite /coprime eqn_leq am_gt0 andbT -(@leq_pmul2l #[a]) ?muln1 -?leq_divRL.
Qed.

Lemma im_Zp_unitm : Zp_unitm @* units_Zp #[a] = Aut <[a]>.
Proof.
rewrite morphimEdom; apply/setP=> f; pose n := invm (injm_Zpm a) (f a).
apply/imsetP/idP=> [[u _ ->] | Af]; first exact: Aut_aut.
have [a1 | nta] := eqVneq a 1.
  by rewrite a1 cycle1 Aut1 in Af; exists 1; rewrite // morph1 (set1P Af).
have a_fa: <[a]> = <[f a]>.
  by rewrite -(autmE Af) -morphim_cycle ?im_autm ?cycle_id.
have def_n: a ^+ n = f a.
  by rewrite -/(Zpm n) invmK // im_Zpm a_fa cycle_id.
have co_a_n: coprime #[a].-2.+2 n.
  by rewrite {1}Zp_cast ?order_gt1 // -generator_coprime def_n; apply/eqP.
exists (FinRing.unit 'Z_#[a] co_a_n); rewrite ?inE //.
apply: eq_Aut (Af) (Aut_aut _ _) _ => x ax.
rewrite autE //= /cyclem; case/cycleP: ax => k ->{x}.
by rewrite -(autmE Af) morphX ?cycle_id //= autmE -def_n -!expgM mulnC.
Qed.

Lemma Zp_unit_isom : isom (units_Zp #[a]) (Aut <[a]>) Zp_unitm.
Proof. by apply/isomP; rewrite ?injm_Zp_unitm ?im_Zp_unitm. Qed.

Lemma Zp_unit_isog : isog (units_Zp #[a]) (Aut <[a]>).
Proof. exact: isom_isog Zp_unit_isom. Qed.

Lemma card_Aut_cycle : #|Aut <[a]>| = totient #[a].
Proof. by rewrite -(card_isog Zp_unit_isog) card_units_Zp. Qed.

Lemma totient_gen : totient #[a] = #|[set x | generator <[a]> x]|.
Proof.
have [lea1 | lt1a] := leqP #[a] 1.
  rewrite /order card_le1_trivg // cards1 (@eq_card1 _ 1) // => x.
  by rewrite !inE -cycle_eq1 eq_sym.
rewrite -(card_injm (injm_invm (injm_Zpm a))) /= ?im_Zpm; last first.
  by apply/subsetP=> x; rewrite inE; apply: cycle_generator.
rewrite -card_units_Zp // cardsE card_sub morphim_invmE; apply: eq_card => /= d.
by rewrite !inE /= qualifE /= /Zp lt1a inE /= generator_coprime {1}Zp_cast.
Qed.

Lemma Aut_cycle_abelian : abelian (Aut <[a]>).
Proof. by rewrite -im_Zp_unitm morphim_abelian ?units_Zp_abelian. Qed.

End CycleAutomorphism.

Variable G : {group gT}.

Lemma Aut_cyclic_abelian : cyclic G -> abelian (Aut G).
Proof. by case/cyclicP=> x ->; apply: Aut_cycle_abelian. Qed.

Lemma card_Aut_cyclic : cyclic G -> #|Aut G| = totient #|G|.
Proof. by case/cyclicP=> x ->; apply: card_Aut_cycle. Qed.

Lemma sum_ncycle_totient :
  \sum_(d < #|G|.+1) #|[set <[x]> | x in G & #[x] == d]| * totient d = #|G|.
Proof.
pose h (x : gT) : 'I_#|G|.+1 := inord #[x].
symmetry; rewrite -{1}sum1_card (partition_big h xpredT) //=.
apply: eq_bigr => d _; set Gd := finset _.
rewrite -sum_nat_const sum1dep_card -sum1_card (_ : finset _ = Gd); last first.
  apply/setP=> x; rewrite !inE; apply: andb_id2l => Gx.
  by rewrite /eq_op /= inordK // ltnS subset_leq_card ?cycle_subG.
rewrite (partition_big_imset cycle) {}/Gd; apply: eq_bigr => C /=.
case/imsetP=> x /setIdP[Gx /eqP <-] -> {C d}.
rewrite sum1dep_card totient_gen; apply: eq_card => y; rewrite !inE /generator.
move: Gx; rewrite andbC eq_sym -!cycle_subG /order.
by case: eqP => // -> ->; rewrite eqxx.
Qed.

End CyclicAutomorphism.

Lemma sum_totient_dvd n : \sum_(d < n.+1 | d %| n) totient d = n.
Proof.
case: n => [|[|n']]; try by rewrite big_mkcond !big_ord_recl big_ord0.
set n := n'.+2; pose x1 : 'Z_n := 1%R.
have ox1: #[x1] = n by rewrite /order -Zp_cycle card_Zp.
rewrite -[rhs in _ = rhs]ox1 -[#[_]]sum_ncycle_totient [#|_|]ox1 big_mkcond /=.
apply: eq_bigr => d _; rewrite -{2}ox1; case: ifP => [|ndv_dG]; last first.
  rewrite eq_card0 // => C; apply/imsetP=> [[x /setIdP[Gx oxd] _{C}]].
  by rewrite -(eqP oxd) order_dvdG in ndv_dG.
move/cycle_sub_group; set Gd := [set _] => def_Gd.
rewrite (_ : _ @: _ = @gval _ @: Gd); first by rewrite imset_set1 cards1 mul1n.
apply/setP=> C; apply/idP/imsetP=> [| [gC GdC ->{C}]].
  case/imsetP=> x /setIdP[_ oxd] ->; exists <[x]>%G => //.
  by rewrite -def_Gd inE -Zp_cycle subsetT.
have:= GdC; rewrite -def_Gd => /setIdP[_ /eqP <-].
by rewrite (set1P GdC) /= mem_imset // inE eqxx (mem_cycle x1).
Qed.

Section FieldMulCyclic.

Import GRing.Theory.

Variables (gT : finGroupType) (G : {group gT}).

Lemma order_inj_cyclic :
  {in G &, forall x y, #[x] = #[y] -> <[x]> = <[y]>} -> cyclic G.
Proof.
move=> ucG; apply: negbNE (contra _ (negbT (ltnn #|G|))) => ncG.
rewrite -{2}[#|G|]sum_totient_dvd big_mkcond (bigD1 ord_max) ?dvdnn //=.
rewrite -{1}[#|G|]sum_ncycle_totient (bigD1 ord_max) //= -addSn leq_add //.
  rewrite eq_card0 ?totient_gt0 ?cardG_gt0 // => C.
  apply/imsetP=> [[x /setIdP[Gx /eqP oxG]]]; case/cyclicP: ncG.
  by exists x; apply/eqP; rewrite eq_sym eqEcard cycle_subG Gx -oxG /=.
elim/big_ind2: _ => // [m1 n1 m2 n2 | d _]; first exact: leq_add.
set Gd := _ @: _; case: (set_0Vmem Gd) => [-> | [C]]; first by rewrite cards0.
rewrite {}/Gd => /imsetP[x /setIdP[Gx /eqP <-] _ {C d}].
rewrite order_dvdG // (@eq_card1 _ <[x]>) ?mul1n // => C.
apply/idP/eqP=> [|-> {C}]; last by rewrite mem_imset // inE Gx eqxx.
by case/imsetP=> y /setIdP[Gy /eqP/ucG->].
Qed.

Lemma div_ring_mul_group_cyclic (R : unitRingType) (f : gT -> R) :
    f 1 = 1%R -> {in G &, {morph f : u v / u * v >-> (u * v)%R}} ->
    {in G^#, forall x, f x - 1 \in GRing.unit}%R ->
  abelian G -> cyclic G.
Proof.
move=> f1 fM f1P abelG.
have fX n: {in G, {morph f : u / u ^+ n >-> (u ^+ n)%R}}.
  by case: n => // n x Gx; elim: n => //= n IHn; rewrite expgS fM ?groupX ?IHn.
have fU x: x \in G -> f x \in GRing.unit.
  by move=> Gx; apply/unitrP; exists (f x^-1); rewrite -!fM ?groupV ?gsimp.
apply: order_inj_cyclic => x y Gx Gy; set n := #[x] => yn.
apply/eqP; rewrite eq_sym eqEcard -[#|_|]/n yn leqnn andbT cycle_subG /=.
suff{y Gy yn} ->: <[x]> = G :&: [set z | #[z] %| n] by rewrite !inE Gy yn /=.
apply/eqP; rewrite eqEcard subsetI cycle_subG {}Gx /= cardE; set rs := enum _.
apply/andP; split; first by apply/subsetP=> y xy; rewrite inE order_dvdG.
pose P : {poly R} := ('X^n - 1)%R; have n_gt0: n > 0 by apply: order_gt0.
have szP: size P = n.+1 by rewrite size_addl size_polyXn ?size_opp ?size_poly1.
rewrite -ltnS -szP -(size_map f) max_ring_poly_roots -?size_poly_eq0 ?{}szP //.
  apply/allP=> fy /mapP[y]; rewrite mem_enum !inE order_dvdn => /andP[Gy].
  move/eqP=> yn1 ->{fy}; apply/eqP.
  by rewrite !(hornerE, hornerXn) -fX // yn1 f1 subrr.
have: uniq rs by apply: enum_uniq.
have: all (mem G) rs by apply/allP=> y; rewrite mem_enum; case/setIP.
elim: rs => //= y rs IHrs /andP[Gy Grs] /andP[y_rs]; rewrite andbC.
move/IHrs=> -> {IHrs}//; apply/allP=> _ /mapP[z rs_z ->].
have{Grs} Gz := allP Grs z rs_z; rewrite /diff_roots -!fM // (centsP abelG) //.
rewrite eqxx -[f y]mul1r -(mulgKV y z) fM ?groupM ?groupV //=.
rewrite -mulNr -mulrDl unitrMl ?fU ?f1P // !inE.
by rewrite groupM ?groupV // andbT -eq_mulgV1; apply: contra y_rs; move/eqP <-.
Qed.

Lemma field_mul_group_cyclic (F : fieldType) (f : gT -> F) :
    {in G &, {morph f : u v / u * v >-> (u * v)%R}} ->
    {in G, forall x, f x = 1%R <-> x = 1} ->
  cyclic G.
Proof.
move=> fM f1P; have f1 : f 1 = 1%R by apply/f1P.
apply: (div_ring_mul_group_cyclic f1 fM) => [x|].
  case/setD1P=> x1 Gx; rewrite unitfE; apply: contra x1.
  by rewrite subr_eq0 => /eqP/f1P->.
apply/centsP=> x Gx y Gy; apply/commgP/eqP.
apply/f1P; rewrite ?fM ?groupM ?groupV //.
by rewrite mulrCA -!fM ?groupM ?groupV // mulKg mulVg.
Qed.

End FieldMulCyclic.

Lemma field_unit_group_cyclic (F : finFieldType) (G : {group {unit F}}) :
  cyclic G.
Proof.
apply: field_mul_group_cyclic FinRing.uval _ _ => // u _.
by split=> /eqP ?; apply/eqP.
Qed.

Section PrimitiveRoots.

Open Scope ring_scope.
Import GRing.Theory.

Lemma has_prim_root (F : fieldType) (n : nat) (rs : seq F) :
    n > 0 -> all n.-unity_root rs -> uniq rs -> size rs >= n ->
  has n.-primitive_root rs.
Proof.
move=> n_gt0 rsn1 Urs; rewrite leq_eqVlt ltnNge max_unity_roots // orbF eq_sym.
move/eqP=> sz_rs; pose r := val (_ : seq_sub rs).
have rn1 x: r x ^+ n = 1.
  by apply/eqP; rewrite -unity_rootE (allP rsn1) ?(valP x).
have prim_r z: z ^+ n = 1 -> z \in rs.
  by move/eqP; rewrite -unity_rootE -(mem_unity_roots n_gt0).
pose r' := SeqSub (prim_r _ _); pose sG_1 := r' _ (expr1n _ _).
have sG_VP: r _ ^+ n.-1 ^+ n = 1.
  by move=> x; rewrite -exprM mulnC exprM rn1 expr1n.
have sG_MP: (r _ * r _) ^+ n = 1 by move=> x y; rewrite exprMn !rn1 mul1r.
pose sG_V := r' _ (sG_VP _); pose sG_M := r' _ (sG_MP _ _).
have sG_Ag: associative sG_M by move=> x y z; apply: val_inj; rewrite /= mulrA.
have sG_1g: left_id sG_1 sG_M by move=> x; apply: val_inj; rewrite /= mul1r.
have sG_Vg: left_inverse sG_1 sG_V sG_M.
  by move=> x; apply: val_inj; rewrite /= -exprSr prednK ?rn1.
pose sgT := BaseFinGroupType _ (FinGroup.Mixin sG_Ag sG_1g sG_Vg).
pose gT := @FinGroupType sgT sG_Vg.
have /cyclicP[x gen_x]: @cyclic gT setT.
  apply: (@field_mul_group_cyclic gT [set: _] F r) => // x _.
  by split=> [ri1 | ->]; first apply: val_inj.
apply/hasP; exists (r x); first exact: (valP x).
have [m prim_x dvdmn] := prim_order_exists n_gt0 (rn1 x).
rewrite -((m =P n) _) // eqn_dvd {}dvdmn -sz_rs -(card_seq_sub Urs) -cardsT.
rewrite gen_x (@order_dvdn gT) /(_ == _) /= -{prim_x}(prim_expr_order prim_x).
by apply/eqP; elim: m => //= m IHm; rewrite exprS expgS /= -IHm.
Qed.

End PrimitiveRoots.

Section AutPrime.

Variable gT : finGroupType.

Lemma Aut_prime_cycle_cyclic (a : gT) : prime #[a] -> cyclic (Aut <[a]>).
Proof.
move=> pr_a; have inj_um := injm_Zp_unitm a; have eq_a := Fp_Zcast pr_a.
pose fm := cast_ord (esym eq_a) \o val \o invm inj_um.
apply: (@field_mul_group_cyclic _ _ _ fm) => [f g Af Ag | f Af] /=.
  by apply: val_inj; rewrite /= morphM ?im_Zp_unitm //= eq_a.
split=> [/= fm1 |->]; last by apply: val_inj; rewrite /= morph1.
apply: (injm1 (injm_invm inj_um)); first by rewrite /= im_Zp_unitm.
by do 2!apply: val_inj; move/(congr1 val): fm1.
Qed.

Lemma Aut_prime_cyclic (G : {group gT}) : prime #|G| -> cyclic (Aut G).
Proof.
move=> pr_G; case/cyclicP: (prime_cyclic pr_G) (pr_G) => x ->.
exact: Aut_prime_cycle_cyclic.
Qed.

End AutPrime.