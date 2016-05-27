export Propagator, Kepler
export propagate_state, propagate_trajectory

abstract Propagator

type Kepler <: Propagator
    iterations::Int
    points::Int
    rtol::Float64
end

function Kepler(;iteration_limit::Int=50, points::Int=100, rtol::Float64=sqrt(eps()))
    return Kepler(iteration_limit, points, rtol)
end

function propagate_state(s0::State, tend::EpochDelta, p::Kepler)
    r1, v1 = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], seconds(tend), p.iterations, p.rtol)
    State(s0.epoch + tend, r1, v1, s0.frame, s0.body)
end

function propagate_state(s0::State, tend, p::Kepler)
    r1, v1 = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], tend, p.iterations, p.rtol)
    State(s0.epoch + EpochDelta(seconds=tend), r1, v1, s0.frame, s0.body)
end

function propagate_trajectory(s0::State, tend, p::Kepler)
    times = linspace(0, tend, p.points)
    x = Vector{Float64}()
    y = Vector{Float64}()
    z = Vector{Float64}()
    vx = Vector{Float64}()
    vy = Vector{Float64}()
    vz = Vector{Float64}()
    for t in times
        r, v = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], t, p.iterations, p.rtol)
        push!(x, r[1])
        push!(y, r[2])
        push!(z, r[3])
        push!(vx, v[1])
        push!(vy, v[2])
        push!(vz, v[3])
    end
    return Trajectory(s0, times, x, y, z, vx, vy, vz)
end

propagate_trajectory(s0::State, tend::EpochDelta, p::Kepler) = propagate_trajectory(s0, seconds(tend), p::Kepler)
propagate_trajectory(s0::State, p::Kepler) = propagate_trajectory(s0, period(s0), p)

type ODE <: Propagator
end
