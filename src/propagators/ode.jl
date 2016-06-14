using Dopri
import Roots: fzero

export ODE

type ODE{F<:Frame,C<:CelestialBody,E<:Event} <: Propagator
    bodies::Vector{DataType}
    center::Type{C}
    frame::Type{F}
    gravity::AbstractModel
    integrator::Function
    maxstep::Real
    numstep::Int
    discontinuities::Vector{Discontinuity}
    events::Vector{E}
    abort::Vector{Discontinuity}
end

function ODE{F<:Frame}(;
    bodies=DataType[],
    frame::Type{F}=GCRF,
    integrator::Function=dop853,
    gravity::AbstractModel=UniformGravity(Earth),
    maxstep::Real=0.0,
    numstep::Int=100_000,
    discontinuities=Discontinuity[],
    events=Event[],
    abort=[Discontinuity(ImpactEvent(), Abort("Impact detected."))],
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
    )
end

show(io::IO, ::Type{ODE}) = print(io, "ODE")

type ODEParameters
    propagator::ODE
    s0::State
    tend::Float64
    dindex::Vector{Nullable{Float64}}
    eindex::Vector{Float64}
    events::Vector{Event}
    detect::Bool
    stop::Bool
    current::Int
end

function propagate(s0::State, tend, propagator::ODE, output::Symbol)
    dindex = map(d -> gettime(d.event), propagator.discontinuities)
    current = 0
    params = ODEParameters(propagator, s0, tend, dindex, Float64[], Event[], true, false, current)
    y = s0.rv
    t0 = 0.0
    times = [t0]
    states = Vector{Vector{Float64}}()
    push!(states, copy(y))
    for (i, t) in enumerate(params.dindex)
        # Detect discontinuity
        if isnull(t)
            params.current = i
            # Do not detect transient events
            params.detect = false
            tout, yout = propagator.integrator(rhs!, y, [t0, tend],
                solout=solout!,
                points=:last,
                params=params,
                maxstep=propagator.maxstep,
                numstep=propagator.numstep,
            )
            t = params.dindex[i]
            if isnull(t)
                error("Event $i could not be detected.")
            end
            params.detect = true
        end

        t1 = get(t)
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
    discontinuities = Dict(:index=>params.dindex, :events=>propagator.discontinuities)
    events = Dict(:index=>params.eindex, :events=>params.events)
    return times, states, discontinuities, events
end

function state(s0::State, tend, p::ODE)
    s0 = State(s0, frame=p.frame, body=p.center)
    tout, yout, discontinuities, events = propagate(s0, tend, p, :last)
    State(s0.epoch + EpochDelta(seconds=tout[end]), yout[end], p.frame, p.center), discontinuities, events
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
    Trajectory(typeof(p), s0, s1, tout, x, y, z, vx, vy, vz), discontinuities, events
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
        # Detect abort conditions
        for discontinuity in params.propagator.abort
            if haspassed(discontinuity.event, told, t, yold, y, params.propagator)
                apply!(discontinuity.update, t, y, params)
            end
        end
        # Detect transient events
        if params.detect
            for event in params.propagator.events
                if haspassed(event, told, t, yold, y, params.propagator)
                    f(t) = detect(t, contd, params.propagator, event)
                    push!(params.eindex, fzero(f, told, t))
                    push!(params.events, event)
                end
            end
        end
        if params.current != 0
            td = params.dindex[params.current]
            discontinuity = params.propagator.discontinuities[params.current]
            if isnull(td) && haspassed(discontinuity.event, told, t, yold, y, params.propagator)
                f(t) = detect(t, contd, params.propagator, discontinuity.event)
                params.dindex[params.current] = Nullable(fzero(f, told, t))
                return dopricode[:abort]
            end
        end
    end
    code = :nominal
    for (tdisc, discontinuity) in zip(params.dindex, params.propagator.discontinuities)
        if !isnull(tdisc) && get(tdisc) == t
            apply!(discontinuity.update, t, y, params)
            code = :altered
            if params.stop
                code = :abort
            end
        # Handle EndEvents
        elseif !isnull(tdisc) && get(tdisc) == -1 && (params.stop || t == params.tend)
            apply!(discontinuity.update, t, y, params)
        end
    end
    return dopricode[code]
end
