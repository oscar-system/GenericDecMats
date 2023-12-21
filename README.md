# GenericDecMats

This repository gives access to the generic decomposition matrices of various groups of Lie type.

Currently the following use cases are supported.

- The [Chevie.jl](https://github.com/jmichel7/Chevie.jl) package provides functionality for generic decomposition matrices.

- The generic decomposition matrices can be read into [Oscar.jl](https://github.com/oscar-system/Oscar.jl), its matrices and polynomials are used then.

- There is also a [GAP 4](https://www.gap-system.org/) interface, read `init.g` into a GAP session in order to provide functions for loading, displaying, and testing the matrices.

The interfaces to Chevie.jl and Oscar.jl can be used in the same Julia session.

There is [a preliminary printout version of the data](https://www.math.rwth-aachen.de/~Thomas.Breuer/GenericDecMats); both the location and the format will be changed.

The data (in the `data` subdirectory) have been provided by [Gunter Malle](https://www.mathematik.uni-kl.de/~malle/de/index.html).


# References

\[[CDR20](http://www.ams.org/mathscinet-getitem?mr=4127942)\] **Craven, D. A., Dudas, O. and Rouquier, R.**, [Brauer trees of unipotent blocks](https://doi.org/10.4171/jems/978), J. Eur. Math. Soc. (JEMS), *22* (9) (2020), 2821–2877.

\[[Dud13](http://www.ams.org/mathscinet-getitem?mr=3061694)\] **Dudas, O.**, [A note on decomposition numbers for groups of Lie type of small rank](https://doi.org/10.1016/j.jalgebra.2013.04.030), J. Algebra, *388* (2013), 364–373.

\[[DM15](http://www.ams.org/mathscinet-getitem?mr=3356813)\] **Dudas, O. and Malle, G.**, [Decomposition matrices for low-rank unitary groups](https://doi.org/10.1112/plms/pdv008), Proc. Lond. Math. Soc. (3), *110* (6) (2015), 1517–1557.

\[[DM16](http://www.ams.org/mathscinet-getitem?mr=3414409)\] **Dudas, O. and Malle, G.**, [Decomposition matrices for exceptional groups at d=4](https://doi.org/10.1016/j.jpaa.2015.08.009), J. Pure Appl. Algebra, *220* (3) (2016), 1096–1121.

\[[DM19](http://www.ams.org/mathscinet-getitem?mr=3937335)\] **Dudas, O. and Malle, G.**, [Bounding Harish-Chandra series](https://doi.org/10.1090/tran/7600), Trans. Amer. Math. Soc., *371* (9) (2019), 6511–6530.

\[DM\] **Dudas, O. and Malle, G.**, [Decomposition matrices for groups of Lie type in non-defining characteristic](https://arxiv.org/abs/2001.06395), arXiv:2001.06395.

\[[DR14](http://www.ams.org/mathscinet-getitem?mr=3230819)\] **Dudas, O. and Rouquier, R.**, [Coxeter orbits and Brauer trees III](https://doi.org/10.1090/S0894-0347-2014-00791-8), J. Amer. Math. Soc., *27* (4) (2014), 1117–1145.

\[[FS84](http://www.ams.org/mathscinet-getitem?mr=753422)\] **Fong, P. and Srinivasan, B.**, [Brauer trees in GL(n,q)](https://doi.org/10.1007/BF01163168), Math. Z., *187* (1) (1984), 81–88.

\[[FS90](http://www.ams.org/mathscinet-getitem?mr=1055005)\] **Fong, P. and Srinivasan, B.**, [Brauer trees in classical groups](https://doi.org/10.1016/0021-8693(90)90172-K), J. Algebra, *131* (1) (1990), 179–225.

\[[Gec91](http://www.ams.org/mathscinet-getitem?mr=1135627)\] **Geck, M.**, [Generalized Gelʹfand-Graev characters for Steinberg's triality groups and their applications](https://doi.org/10.1080/00927879108824318), Comm. Algebra, *19* (12) (1991), 3249–3269.

\[[GH97](http://www.ams.org/mathscinet-getitem?mr=1429874)\] **Geck, M. and Hiss, G.**, Modular representations of finite groups of Lie type in non-defining characteristic, in Finite reductive groups (Luminy, 1994), Birkhäuser Boston, Boston, MA, Progr. Math., *141* (1997), 195–249.

\[[GHM94](http://www.ams.org/mathscinet-getitem?mr=1289097)\] **Geck, M., Hiss, G. and Malle, G.**, [Cuspidal unipotent Brauer characters](https://doi.org/10.1006/jabr.1994.1226), J. Algebra, *168* (1) (1994), 182–220.

\[[HN14](http://www.ams.org/mathscinet-getitem?mr=3216598)\] **Himstedt, F. and Noeske, F.**, [Decomposition numbers of SO_7(q) and Sp_6(q)](https://doi.org/10.1016/j.jalgebra.2014.04.020), J. Algebra, *413* (2014), 15–40.

\[[HL98](http://www.ams.org/mathscinet-getitem?mr=1487449)\] **Hiss, G. and Lübeck, F.**, [The Brauer trees of the exceptional Chevalley groups of types F_4 and ^2E_6](https://doi.org/10.1007/s000130050159), Arch. Math. (Basel), *70* (1) (1998), 16–21.

\[[HLM95](http://www.ams.org/mathscinet-getitem?mr=1329444)\] **Hiss, G., Lübeck, F. and Malle, G.**, [The Brauer trees of the exceptional Chevalley groups of type E_6](https://doi.org/10.1007/BF02570465), Manuscripta Math., *87* (1) (1995), 131–144.

\[[Jam90](http://www.ams.org/mathscinet-getitem?mr=1031453)\] **James, G.**, [The decomposition matrices of GL_n(q) for n ≤ 10](https://doi.org/10.1112/plms/s3-60.2.225), Proc. London Math. Soc. (3), *60* (2) (1990), 225–265.

\[Mal\] **Malle, G.**, Computed directly (in principle known from MR1031453 [Jam90]).

\[[Miy08](http://www.ams.org/mathscinet-getitem?mr=2397469)\] **Miyachi, H.**, [Rouquier blocks in Chevalley groups of type E](https://doi.org/10.1016/j.aim.2007.12.004), Adv. Math., *217* (6) (2008), 2841–2871.

\[[OW98](http://www.ams.org/mathscinet-getitem?mr=1489925)\] **Okuyama, T. and Waki, K.**, [Decomposition numbers of Sp(4,q)](https://doi.org/10.1006/jabr.1997.7189), J. Algebra, *199* (2) (1998), 544–555.

\[[OW02](http://www.ams.org/mathscinet-getitem?mr=1935498)\] **Okuyama, T. and Waki, K.**, [Decomposition numbers of SU(3,q^2)](https://doi.org/10.1016/S0021-8693(02)00160-6), J. Algebra, *255* (2) (2002), 258–270.

\[[Sha89](http://www.ams.org/mathscinet-getitem?mr=1000493)\] **Shamash, J.**, [Brauer trees for blocks of cyclic defect in the groups G_2(q) for primes dividing q^2 ± q + 1](https://doi.org/10.1016/0021-8693(89)90052-5), J. Algebra, *123* (2) (1989), 378–396.
