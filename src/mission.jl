export Segment, @vary

abstract BoundaryCondition

type Launch <: BoundaryCondition
end

type Rendezvous <: BoundaryCondition
end

type Departure <: BoundaryCondition
end

type InitialOrbit <: BoundaryCondition
end

type TargetOrbit <: BoundaryCondition
end

type ThrustArc
    alpha::Float64
    beta::Float64
end

type Segment
    parameters::Vector{Parameter}
    #= start::Nullable{BoundaryCondition} =#
    #= stop::Nullable{BoundaryCondition} =#
    #= thrust::Nullable{ThrustArc} =#
    dt::Nullable{Real}
    test::Vector{Discontinuity}
    #= stop_at::Vector{Event} =#
end

function Segment(; kwargs...)
    params = Parameter[]
    dt = Nullable{Real}(0.0)
    test = Discontinuity[]
    for (key, value) in kwargs
        if key == :dt
            dt = Nullable{Real}(value)
        elseif key == :test
            test = value::Vector{Discontinuity}
        end
        append!(params, getparameters(value))
    end
    Segment(params, dt, test)
end

type Mission
    sequences::Dict{Symbol, Vector{Segment}}
end

macro vary(args...)
    params = Dict{Symbol,Dict{Symbol,Float64}}()
    for ex in args[1:end-1]
        if !(ex.head in (:comparison, :(=)))
            error("Expression '$ex' is neither a comparison nor an assignment.")
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
        d = Dict(key=>value)
        if !(sym in keys(params))
            merge!(params, Dict(sym=>d))
        else
            merge!(params[sym], d)
        end
    end
    seg = args[end]
    if seg.args[1] != :Segment
        throw(ArgumentError("Final argument must be a Segment initialization expression."))
    end
    replace_parameters!(seg, params)
    return seg
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
                expr.args[i] = Parameter(initial, upper, lower, true)
            end
        end
    end
end
