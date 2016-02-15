using Dopri

abstract AbstractEvent

type Event <: AbstractEvent
    update::Function
    detect::Function
    t::Nullable{Float64}
    passed::Bool
    function Event(update, detect)
        return new(update, detect, Nullable{Float64}(), false)
    end
end

type TimedEvent <: AbstractEvent
    update::Function
    t::Float64
    passed::Bool
    function TimedEvent(update, t)
        return new(update, t, false)
    end
end

haspassed(evt::AbstractEvent) = evt.passed
haspassed(v::Vector{AbstractEvent}) = map(haspassed, v)
time(evt::TimedEvent) = evt.t
time(evt::Event) = get(evt.t, NaN)

type Propagator
    events::Vector{AbstractEvent}
    tend::Float64
    stop::Function
end

function signchange(f::Function, s1::AbstractState, s2::AbstractState)
    return sign(f(s1)) != sign(f(s2))
end

function afterstep!(told, t, y, contd, p)
    state = p.state(t, y...) 

    for event in p.events[haspassed(p.events)]
    end
end

function rhs!(f, t, y, params)
end

function propagate(s0::AbstractState, stop::Function; events::Vector{AbstractEvent}=AbstractEvent[])
end

function propagate(s0::AbstractState, dt; events::Vector{AbstractEvent}=AbstractEvent[])
    tout, yout = dop853(rhs!, y0, tspan, params=XXX, points=:last, solout=afterstep!)
end

#= function propagate(s::State; method::String="kepler") =#
#=    mu = planets[s.body]["mu"]  =#
#=    if method == "kepler" =#
#=        ele = elements(s.rv, mu) =#
#=        tend = period(ele[1], mu) =#
#=        dt = [0:tend] =#
#=        return cartesian(kepler(ele, dt, mu), mu) =#
#=    end =#
#= end =#

