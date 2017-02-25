using Dopri
import Roots: fzero

export ODE

immutable PropagationResult
    trajectory::Trajectory
    discontinuities::Dict{Symbol,Any}
    events::Dict{Symbol,Any}
end

type ODE{F<:Frame,C<:CelestialBody,E<:Event} <: Propagator
    bodies::Vector{DataType}
    center::Type{C}
    frame::Type{F}
    gravity::AbstractModel
    integrator::Symbol
    maxstep::Real
    numstep::Int
    discontinuities::Vector{Discontinuity}
    events::Vector{E}
    abort::Vector{Discontinuity}
    display_warnings::Bool
end

function ODE{F<:Frame}(;
    bodies=DataType[],
    frame::Type{F}=GCRF,
    integrator::Symbol=:dop853,
    gravity::AbstractModel=UniformGravity(Earth),
    maxstep::Real=0.0,
    numstep::Int=100_000,
    discontinuities=Discontinuity[],
    events=Event[],
    abort=[Discontinuity(ImpactEvent(), Abort("Impact detected."))],
    display_warnings=false,
)
    ODE(
        bodies,
        gravity.center,
        frame,
        gravity,
        integrator,
        maxstep,
        numstep,
        discontinuities,
        events,
        abort,
        display_warnings,
    )
end

show(io::IO, ::Type{ODE}) = print(io, "ODE")

type ODEParameters
    s0::State
    tend::Float64
    dindex::Vector{Nullable{Float64}}
    eindex::Vector{Float64}
    events::Vector{Event}
    stop::Bool
    current::Int
end

function propagate(s0::State, tend, propagator::ODE, output::Symbol)
    integrator = eval(propagator.integrator)
    dindex = map(d -> gettime(d.event), propagator.discontinuities)
    stop = false
    current = 0
    params = ODEParameters(s0, tend, dindex, Float64[], Event[], stop, current)
    y = s0.rv
    t0 = 0.0
    times = [t0]
    states = Vector{Vector{Float64}}()
    push!(states, copy(y))
    rhs(f::Vector{Float64}, t::Float64, y::Vector{Float64}) = rhs!(f, t, y, params, propagator)
    detect_discontinuities(told::Float64, t::Float64, y::Vector{Float64}, contd::Function) = detect_discontinuities!(told, t, y, contd, params, propagator)
    handle_events(told::Float64, t::Float64, y::Vector{Float64}, contd::Function) = handle_events!(told, t, y, contd, params, propagator)
    for (i, t) in enumerate(params.dindex)
        # Detect discontinuity
        if isnull(t)
            params.current = i
            tout, yout = integrator(rhs, y, [t0, tend],
                solout=detect_discontinuities,
                points=:last,
                maxstep=propagator.maxstep,
                numstep=propagator.numstep,
            )
            t = params.dindex[i]
            if isnull(t)
                if propagator.display_warnings
                    warn("Event $i could not be detected.")
                end
                continue
            end
        end

        t1 = get(t)
        if t1 != 0.0
            tout, yout = integrator(rhs, y, [t0, t1],
                solout=handle_events,
                points=output,
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
        apply!(propagator.discontinuities[i].update, t, y, params, propagator)
    end
    if !params.stop && t0 != tend
        tout, yout = integrator(rhs, y, [t0, tend],
            solout=handle_events,
            points=output,
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
    discontinuities = Dict(:index=>params.dindex, :events=>propagator.discontinuities)
    events = Dict(:index=>params.eindex, :events=>params.events)
    return times, states, discontinuities, events
end

function state(s0::State, tend, p::ODE)
    s0 = State(s0, frame=p.frame, body=p.center)
    tout, yout, discontinuities, events = propagate(s0, tend, p, :last)
    State(s0.epoch + EpochDelta(seconds=tout[end]), yout[end], p.frame, p.center)
end

state(s0::State, tend::EpochDelta, p::ODE) = state(s0, seconds(tend), p)
state(s0::State, p::ODE) = state(s0, period(s0), p)

function trajectory(s0::State, tend, p::ODE)
    s0 = State(s0, frame=p.frame, body=p.center)
    tout, yout, discontinuities, events = propagate(s0, tend, p, :all)
    x = map(v -> v[1], yout)
    y = map(v -> v[2], yout)
    z = map(v -> v[3], yout)
    vx = map(v -> v[4], yout)
    vy = map(v -> v[5], yout)
    vz = map(v -> v[6], yout)
    s1 = State(s0.epoch + EpochDelta(seconds=tout[end]), yout[end], p.frame, p.center)
    PropagationResult(Trajectory(s0, s1, tout, x, y, z, vx, vy, vz), discontinuities, events)
end

trajectory(s0::State, tend::EpochDelta, p::ODE) = trajectory(s0, seconds(tend), p)
trajectory(s0::State, p::ODE) = trajectory(s0, period(s0), p)

function rhs!(f::Vector{Float64}, t::Float64, y::Vector{Float64}, params::ODEParameters, propagator::ODE)
    fill!(f, 0.0)
    gravity!(f, y, propagator.gravity)
    if !isempty(propagator.bodies)
        thirdbody!(f, t, y, params, propagator)
    end
end

function detect_abort(told::Float64, t::Float64, yold::Vector{Float64}, y::Vector{Float64}, params::ODEParameters, propagator::ODE)
    for discontinuity in propagator.abort
        if haspassed(discontinuity.event, told, t, yold, y, propagator)
            apply!(discontinuity.update, t, y, params, propagator)
        end
    end
end

function detect_discontinuities!(told::Float64, t::Float64, y::Vector{Float64}, contd::Function, params::ODEParameters, propagator::ODE)
    firststep = t == told
    if !firststep
        yold = state(told, length(y), contd)
        detect_abort(told, t, yold, y, params, propagator)
        if params.current != 0
            td = params.dindex[params.current]
            discontinuity = propagator.discontinuities[params.current]
            if isnull(td) && haspassed(discontinuity.event, told, t, yold, y, propagator)
                f(t::Float64) = detect(t, contd, propagator, discontinuity.event)
                params.dindex[params.current] = Nullable(fzero(f, told, t))
                return dopricode[:abort]
            end
        end
    end
    dopricode[:nominal]
end

function handle_events!(told::Float64, t::Float64, y::Vector{Float64}, contd::Function, params::ODEParameters, propagator::ODE)
    firststep = t == told
    if !firststep
        yold = state(told, length(y), contd)
        detect_abort(told, t, yold, y, params, propagator)
        # Detect transient events
        for event in propagator.events
            if haspassed(event, told, t, yold, y, propagator)
                f(t) = detect(t, contd, propagator, event)
                push!(params.eindex, fzero(f, told, t))
                push!(params.events, event)
            end
        end
    end
    dopricode[:nominal]
end

function state(t::Float64, n::Int, contd::Function)
    y = Array(Float64, n)
    for i in eachindex(y)
        y[i] = contd(i, t)
    end
    return y
end
