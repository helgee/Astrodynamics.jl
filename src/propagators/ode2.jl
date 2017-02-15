import DifferentialEquations: ODEProblem, Vern8, solve, OrdinaryDiffEqAlgorithm

function newton!(t, y, dy, μ)
    r = norm(y[1:3])
    dy[1:3] = y[4:6]
    dy[4:6] = -μ * y[1:3] / (r*r*r)
end

function test()
    r0 = [1131.340, -2282.343, 6672.423]
    v0 = [-5.64305, 4.30333, 2.42879]
    Δt = 86400.0*365
    rv0 = [r0; v0]
    prob = ODEProblem((t, y, dy) -> newton!(t, y, dy, mu(Earth)), rv0, (0.0, Δt))
    alg = Vern8
    print(solve(prob, alg)[end])
end

type ODE2 <: Propagator
    bodies::Vector{CelestialBody}
    center::CelestialBody
    frame::Symbol
    gravity::AbstractModel
    integrator::OrdinaryDiffEqAlgorithm
    discontinuities::Vector{Discontinuity}
    abort::Vector{Discontinuity}
end

function ODE2(;
              bodies = CelestialBody[],
              center = EARTH,
              frame = :GCRF,
              gravity = UniformGravity(Earth),
              discontinuities=discontinuity[],
              events=event[],
              abort=[discontinuity(impactevent(), abort("impact detected."))],
             )
    ODE2(
         bodies,
         center,
         frame,
         gravity,
         discontinuities,
         abort,
        )
end

show(io::IO, ::Type{ODE2}) = print(io, "ODE2")
