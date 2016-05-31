using Dopri

export Propagator, Kepler, ODE
export state, trajectory
export rhs!

import Base: show

abstract Propagator

type Kepler <: Propagator
    iterations::Int
    points::Int
    rtol::Float64
end

function Kepler(;iteration_limit::Int=50, points::Int=100, rtol::Float64=sqrt(eps()))
    Kepler(iteration_limit, points, rtol)
end

show(io::IO, ::Type{Kepler}) = print(io, "Kepler")

function state(s0::State, tend::EpochDelta, p::Kepler)
    r1, v1 = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], seconds(tend), p.iterations, p.rtol)
    State(s0.epoch + tend, r1, v1, s0.frame, s0.body)
end

function state(s0::State, tend, p::Kepler)
    r1, v1 = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], tend, p.iterations, p.rtol)
    State(s0.epoch + EpochDelta(seconds=tend), r1, v1, s0.frame, s0.body)
end

function trajectory(s0::State, tend, p::Kepler)
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
    Trajectory(typeof(p), s0, times, x, y, z, vx, vy, vz)
end

trajectory(s0::State, tend::EpochDelta, p::Kepler) = trajectory(s0, seconds(tend), p::Kepler)
trajectory(s0::State, p::Kepler) = trajectory(s0, period(s0), p)

type ODE <: Propagator
    gravity::Function
    maxstep::Float64
end

function ODE(;gravity::Function=gravity!,
    maxstep::Real=0.0,
)
    ODE(gravity, maxstep)
end

show(io::IO, ::Type{ODE}) = print(io, "ODE")

type ODEParameters
    s0::State
end

function state(s0::State, tend, p::ODE)
    tout, yout = dop853(rhs!, s0.rv, [0, tend],
        points=:last, params=ODEParameters(s0), maxstep=p.maxstep)
    State(s0.epoch + EpochDelta(seconds=tout[end]), yout[end], s0.frame, s0.body)
end

state(s0::State, tend::EpochDelta, p::ODE) = state(s0, seconds(tend), p)

function trajectory(s0::State, tend, p::ODE)
    tout, yout = dop853(rhs!, s0.rv, [0, tend],
        points=:all, params=ODEParameters(s0), maxstep=p.maxstep)
    x = map(v -> v[1], yout)
    y = map(v -> v[2], yout)
    z = map(v -> v[3], yout)
    vx = map(v -> v[4], yout)
    vy = map(v -> v[5], yout)
    vz = map(v -> v[6], yout)
    Trajectory(typeof(p), s0, tout, x, y, z, vx, vy, vz)
end

trajectory(s0::State, tend::EpochDelta, p::ODE) = trajectory(s0, seconds(tend), p)
trajectory(s0::State, p::ODE) = trajectory(s0, period(s0), p)

function rhs!(f::Vector{Float64}, t::Float64, y::Vector{Float64}, params::ODEParameters)
    fill!(f, 0.0)
    gravity!(f, y, mu(params.s0))
end
