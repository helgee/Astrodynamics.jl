export Discontinuity
export Event, detect, haspassed, gettime
export PericenterEvent, ApocenterEvent, StartEvent, EndEvent, ImpactEvent
export Update, apply!
export ImpulsiveManeuver, Stop
export PropagatorAbort, Abort

abstract Event
abstract Update

type PropagatorAbort <: Exception
    msg::AbstractString
end
Base.show(io::IO, err::PropagatorAbort) = print(io, err.msg)

type Discontinuity
    event::Event
    update::Update
end

gettime(::Event) = Nullable{Float64}()

type StartEvent <: Event; end
gettime(::StartEvent) = Nullable(0.0)

type EndEvent <: Event; end
gettime(::EndEvent) = Nullable(-1.0)

type PericenterEvent <: Event; end

function haspassed(::PericenterEvent, told, t, yold, y, p)
    new = keplerian(y, μ(p.center))[6]
    old = keplerian(yold, μ(p.center))[6]
    sign(new-π) != sign(old-π) && (old < π/2 < new || new < π/2 < old)
end

function detect(t, contd, p, ::PericenterEvent)
    y = state(t, 6, contd)
    ano = keplerian(y, μ(p.center))[6]
    ano = ano > π ? ano - 2π : ano
    return ano
end

type ApocenterEvent <: Event; end

function haspassed(::ApocenterEvent, told, t, yold, y, p)
    new = keplerian(y, μ(p.center))[6]
    old = keplerian(yold, μ(p.center))[6]
    sign(new-π) != sign(old-π) && new > π/2 && old > π/2
end

function detect(t, contd, p, ::ApocenterEvent)
    y = state(t, 6, contd)
    ano = keplerian(y, μ(p.center))[6]
    return ano - π
end

type ImpactEvent <: Event; end

function haspassed(::ImpactEvent, told, t, yold, y, p)
    r = norm(y[1:3]) - mean_radius(p.center)
    r <= 0.0
end

function detect(t, contd, p, ::ImpactEvent)
    y = state(t, 3, contd)
    norm(y[1:3]) - mean_radius(p.center)
end

type ImpulsiveManeuver <: Update
    Δv::Vector{Parameter}
end

ImpulsiveManeuver(;radial=0.0, along=0.0, cross=0.0) = ImpulsiveManeuver([radial, along, cross])
deltav(man::ImpulsiveManeuver) = norm(man.Δv)

function apply!(man::ImpulsiveManeuver, t, y, params, propagator)
    m = rotation_matrix(RAC, propagator.frame, y)
    y[4:6] += m*man.Δv
end

type Stop <: Update
end

function apply!(::Stop, t, y, params, propagator)
    params.stop = true
end

type Abort <: Update
    msg::AbstractString
end

Abort() = Abort("Propagation aborted.")

function apply!(ab::Abort, t, y, params, propagator)
    throw(PropagatorAbort("$(ab.msg)\nt=$t."))
end
