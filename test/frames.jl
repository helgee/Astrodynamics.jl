using Base.Test
using Astrodynamics

mu = 398600.448073446
rv = [8.59072560e+02, -4.13720368e+03, 5.29556871e+03, 7.37289205e+00, 2.08223573e+00, 4.39999794e-01]
rvmat = [rv';rv';rv']
ele = [6.78085866e+03,   1.30546073e-03,   9.00610999e-01, 3.46237544e+00,   6.85258061e-01,   8.13258968e-01]
elemat = [ele';ele';ele']
@test_approx_eq ele rvtokepler(rv, mu)
@test_approx_eq elemat rvtokepler(rvmat, mu)
@test_approx_eq rv keplertorv(ele, mu)
@test_approx_eq rvmat keplertorv(elemat, mu)
