export Parameter, ParameterArray, getparameters, isparameter, push!
export lower, upper, initial, value

import Base: +, *, -, /, promote_rule, convert, push!

type Parameter
    value::Float64
    initial::Float64
    lower::Float64
    upper::Float64
    variable::Bool
end

Parameter(v) = Parameter(v, v, -Inf, Inf, true)
Parameter(v, lower, upper) = Parameter(v, v, lower, upper, true)
isparameter(par::Parameter) = par.variable
lower(par::Parameter) = par.lower
upper(par::Parameter) = par.upper
initial(par::Parameter) = par.initial
value(par::Parameter) = par.value

function push!(par::Parameter, v)
    par.value = v
    return par
end

convert{T<:Real}(::Type{Parameter}, v::T) = Parameter(v, v, 0.0, 0.0, false)
promote_rule(::Type{Parameter}, ::Type{Float64}) = Parameter

typealias ParameterArray Array{Parameter,1}
isparameter(arr::ParameterArray) = Bool[p.variable for p in arr]

getparameters(par::Parameter) = par.variable ? [par] : []
getparameters(arr::ParameterArray) = arr.array[isparameter(data)]
function getparameters(arr::AbstractArray)
    params = Parameter[]
    for el in arr
        append!(params, getparameters(el))
    end
    return params
end
function getparameters(val)
    params = Parameter[]
    fields = fieldnames(val)
    if length(fields) != 0
        for field in fields
            append!(params, getparameters(getfield(val, field)))
        end
    end
    return params
end
