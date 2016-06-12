export Segment, @vary

abstract Boundary
abstract Arc

type Pass <: Boundary
end

type Launch <: Boundary
    lat::Float64
    lon::Float64
    alt::Float64
end

type Rendezvous <: Boundary
    target::Symbol
    segment::Int
end

type Departure <: Boundary
    parent::Symbol
    segment::Int
end

type InitialOrbit <: Boundary
    state::State
end

type TargetOrbit <: Boundary
    sma::Nullable{Float64}
    ecc::Nullable{Float64}
    inc::Nullable{Float64}
    node::Nullable{Float64}
    peri::Nullable{Float64}
    ano::Nullable{Float64}
end

function TargetOrbit(;
    sma = Nullable{Float64}(),
    ecc = Nullable{Float64}(),
    inc = Nullable{Float64}(),
    node = Nullable{Float64}(),
    peri = Nullable{Float64}(),
    ano = Nullable{Float64}(),
)
    TargetOrbit(sma, ecc, inc, node, peri, ano)
end

type ThrustArc <: Arc
    alpha::ParameterArray
    beta::ParameterArray
end

type Coast <: Arc
end

type Segment
    parameters::ParameterArray
    dt::Parameter
    start::Boundary
    stop::Boundary
    thrust::Arc
    propagator::Propagator
end

function Segment(; kwargs...)
    params = Parameter[]
    for kv in kwargs
        append!(params, getparameters(kv[end]))
    end
    Segment(params; kwargs...)
end

function Segment(params::ParameterArray;
    dt = constant(0.0),
    start = Pass(),
    stop = Pass(),
    thrust = Coast(),
    propagator = ODE(),
)
    Segment(params, dt, start, stop, thrust, propagator)
end

type Mission
    sequences::Dict{Symbol, Vector{Segment}}
end

macro vary(args...)
    params = Dict{Symbol,Dict{Symbol,Float64}}()
    for ex in args[1:end-1]
        if !(ex.head in (:comparison, :(=), :kw))
            throw(ArgumentError("Expression '$ex' is neither a comparison nor an assignment."))
        end
        if length(ex.args) == 3
            sym, op, value = ex.args
            if op in (:(<=), :(<))
                key = :upper
            elseif op in (:(>=), :(>))
                key = :lower
            end
        else
            sym, value = ex.args
            key = :initial
        end
        if !isa(value, Number)
            v = eval(value)
        else
            v = value
        end
        d = Dict(key=>v)
        if !(sym in keys(params))
            merge!(params, Dict(sym=>d))
        else
            merge!(params[sym], d)
        end
    end
    typ = args[end]
    if typ.head != :call
        throw(ArgumentError("The last expression must be a type instantiation."))
    end
    replace_parameters!(typ, params)
    return typ
end

function replace_parameters!(expr, params)
    for (i, ex) in enumerate(expr.args)
        if isa(ex, Expr)
            replace_parameters!(expr.args[i], params)
        elseif isa(ex, Symbol) && ex in keys(params)
            if expr.head != :kw || (expr.head == :kw && i > 1)
                upper = get(params[ex], :upper, Inf)
                lower = get(params[ex], :lower, -Inf)
                initial = get(params[ex], :initial, (upper-lower)/2)
                expr.args[i] = Parameter(initial, lower, upper)
            end
        end
    end
end
