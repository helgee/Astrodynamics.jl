using Astrodynamics
using BenchmarkTools
#= using ProfileView =#

r0 = [1131.340, -2282.343, 6672.423]
v0 = [-5.64305, 4.30333, 2.42879]
#= Δt = 86400 =#
Δt = 86400*365*600
Δe = EpochDelta(seconds=Δt)
ep = Epoch(TT, now())
s0 = State(ep, r0, v0)
r1 = [-4219.7527, 4363.0292, -3958.7666]
v1 = [3.689866, -1.916735, -6.112511]
#= ode = ODE(maxstep=86400) =#
ode = ODE(bodies=[Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune], gravity=J2Gravity(Earth))
#= ode = ODE(gravity=J2Gravity(Earth)) =#
#= ode = ODE() =#
b1 = @benchmark s1 = state(s0, Δt, ode)
println(b1)
#= b2 = @benchmark tra = trajectory(s0, Δe, ode) =#
#= println(b2) =#
#= s1 = state(s0, 1.0, ode) =#
#= n = 1_000 =#
#= @profile for i=1:n; state(s0, Δt, ode); end =#
@profile state(s0, Δt, ode)
Profile.print()
