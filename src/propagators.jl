using Dopri
import Roots: fzero

export Propagator, Kepler, ODE
export state, trajectory
export rhs!

import Base: show

abstract Propagator
abstract AbstractModel

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
    s1 = State(s0.epoch + EpochDelta(seconds=times[end]),
        x[end], y[end], z[end], vx[end], vy[end], vz[end],
        s0.frame, s0.body)
    Trajectory(typeof(p), s0, s1, times, x, y, z, vx, vy, vz)
end

trajectory(s0::State, tend::EpochDelta, p::Kepler) = trajectory(s0, seconds(tend), p::Kepler)
trajectory(s0::State, p::Kepler) = trajectory(s0, period(s0), p)

type ODE{F<:Frame,C<:CelestialBody,E<:Event} <: Propagator
    bodies::Vector{DataType}
    center::Type{C}
    frame::Type{F}
    gravity::AbstractModel
    integrator::Function
    maxstep::Real
    numstep::Int
    events::Vector{E}
end

function ODE{F<:Frame,E<:Event}(;
    bodies=DataType[],
    frame::Type{F}=GCRF,
    integrator::Function=dop853,
    gravity::AbstractModel=UniformGravity(Earth),
    maxstep::Real=0.0,
    numstep::Int=100_000,
    events::Vector{E}=Vector{Event}(),
)
    ODE(
        bodies,
        gravity.center,
        frame,
        gravity,
        integrator,
        maxstep,
        numstep,
        events,
    )
end

show(io::IO, ::Type{ODE}) = print(io, "ODE")

type ODEParameters
    propagator::ODE
    s0::State
    tend::Float64
    events::Vector{Nullable{Float64}}
    stop::Bool
end

function propagate(s0::State, tend, propagator::ODE, output::Symbol)
    events = map(x -> gettime(x), propagator.events)
    params = ODEParameters(propagator, s0, tend, events, false)
    y = s0.rv
    t0 = 0.0
    times = [t0]
    states = Vector{Vector{Float64}}()
    push!(states, copy(y))
    for (i, event) in enumerate(params.events)
        if isnull(event)
            tout, yout = propagator.integrator(rhs!, y, [t0, tend],
                solout=solout!,
                points=:last,
                params=params,
                maxstep=propagator.maxstep,
                numstep=propagator.numstep,
            )
            if isnull(params.events[i])
                println(tout[end])
                error("Event $i could not be detected.")
            end
            t1 = get(params.events[i])
        else
            t1 = get(event)
        end
        if t1 != 0.0
            tout, yout = propagator.integrator(rhs!, y, [t0, t1],
                solout=solout!,
                points=output,
                params=params,
                maxstep=propagator.maxstep,
                numstep=propagator.numstep,
            )
            t0 = t1
            y = yout[end]
            if output == :all
                append!(times, tout[2:end])
                append!(states, yout[2:end])
            end
        end
    end
    if !params.stop && t0 != tend
        tout, yout = propagator.integrator(rhs!, y, [t0, tend],
            solout=solout!,
            points=output,
            params=params,
            maxstep=propagator.maxstep,
            numstep=propagator.numstep,
        )
        t0 = tend
        y = yout[end]
        if output == :all
            append!(times, tout[2:end])
            append!(states, yout[2:end])
        end
    end
    if output == :last
        push!(times, t0)
        push!(states, y)
    end
    return times, states
end

function state(s0::State, tend, p::ODE)
    s0 = State(s0, frame=p.frame, body=p.center)
    tout, yout = propagate(s0, tend, p, :last)
    State(s0.epoch + EpochDelta(seconds=tout[end]), yout[end], p.frame, p.center)
end

state(s0::State, tend::EpochDelta, p::ODE) = state(s0, seconds(tend), p)
state(s0::State, p::ODE) = state(s0, period(s0), p)

function trajectory(s0::State, tend, p::ODE)
    s0 = State(s0, frame=p.frame, body=p.center)
    tout, yout = propagate(s0, tend, p, :all)
    x = map(v -> v[1], yout)
    y = map(v -> v[2], yout)
    z = map(v -> v[3], yout)
    vx = map(v -> v[4], yout)
    vy = map(v -> v[5], yout)
    vz = map(v -> v[6], yout)
    s1 = State(s0.epoch + EpochDelta(seconds=tout[end]), yout[end], p.frame, p.center)
    Trajectory(typeof(p), s0, s1, tout, x, y, z, vx, vy, vz)
end

trajectory(s0::State, tend::EpochDelta, p::ODE) = trajectory(s0, seconds(tend), p)
trajectory(s0::State, p::ODE) = trajectory(s0, period(s0), p)

function rhs!(f::Vector{Float64}, t::Float64, y::Vector{Float64}, p::ODEParameters)
    fill!(f, 0.0)
    gravity!(f, y, p.propagator.gravity)
    if !isempty(p.propagator.bodies)
        thirdbody!(f, t, y, p)
    end
end

function solout!(told, t, y, contd, params)
    firststep = t == told
    if !firststep
        yold = Float64[contd(i, told) for i = 1:length(y)]
    end
    code = :nominal
    for ((i, tevt), event) in zip(enumerate(params.events), params.propagator.events)
        if !isnull(tevt) && get(tevt) == t
            apply!(event.update, t, y, params)
            code = :altered
            if params.stop
                code = :abort
            end
        elseif !isnull(tevt) && get(tevt) == -1 && (params.stop || t == params.tend)
            apply!(event.update, t, y, params)
        elseif !firststep && isnull(tevt) && haspassed(event, told, t, yold, y, params.propagator)
            f(t) = detect(t, contd, params.propagator, event)
            te = fzero(f, told, t)
            params.events[i] = Nullable(te)
            return dopricode[:abort]
        end
    end
    return dopricode[code]
end
