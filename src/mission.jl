export @vary, AbstractConstraint

abstract AbstractConstraint

include("mission/boundaries.jl")
include("mission/arc.jl")
include("mission/segments.jl")
include("mission/constraints.jl")
include("mission/solvers.jl")

type Mission
    sequences::Dict{Symbol, Vector{Segment}}
end

macro vary(args...)
    params = Dict{Symbol,Dict{Symbol,Float64}}()
    for ex in args[1:end-1]
        if !(ex.head in (:comparison, :(=), :kw)
             || ex.head == :call && ex.args[1] in (:(<=), :(>=)))
            throw(ArgumentError("Expression '$ex' is neither a comparison nor an assignment."))
        end
        if ex.head == :call
            op, sym, value = ex.args
            if op in (:(<=), :(<))
                key = :upper
            elseif op in (:(>=), :(>))
                key = :lower
            end
        elseif length(ex.args) == 3
            println(ex.head)
            println(ex.args)
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
