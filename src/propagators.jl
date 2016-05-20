abstract Propagator

type Kepler <: Propagator
    iteration_limit::Int
    points::Int
    rtol::Float64
end

function Kepler(;iteration_limit::Int=50, points::Int=100, rtol::Float64=sqrt(eps()))
    return Kepler(iteration_limit, points, rtol)
end

type ODE <: Propagator
end

function propagate(s0, tend, p::Kepler, output=:orbit)
end
