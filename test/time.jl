using Base.Test
using Astrodynamics

@test isapprox(round(dms2rad(-35, -15, -53.63), 7),-0.6154886)
