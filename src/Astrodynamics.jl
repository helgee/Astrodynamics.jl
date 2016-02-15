module Astrodynamics

#= using Base.Dates =#
#= using Dopri =#
#=  =#
#= export State =#
#= export JulianDate, JD2000, JD1950, MJD, jd2000, jd1950, mjd =#
#= export ecctomean, meantoecc, ecctotrue, truetoecc =#
#= export propagate =#
#= export planets =#

include("time.jl")
include("planets.jl")
include("frames.jl")
include("states.jl")
include("math.jl")
include("kepler.jl")
include("propagator.jl")

#= iss = State([8.59072560e+02, -4.13720368e+03, 5.29556871e+03, 7.37289205e+00, 2.08223573e+00, 4.39999794e-01], =#
#=     DateTime(2013,3,18,12,0,0), "eci", "earth") =#

end
