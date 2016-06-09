export Parameter, ParameterArray, getparameters, isparameter, push!
export lower, upper, initial, value, values
export +, *, -, /, isequal, isless

import Base: +, *, -, /, promote_rule, convert, push!, isequal, isless, values

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
convert(::Type{Float64}, par::Parameter) = par.value
promote_rule(::Type{Parameter}, ::Type{Float64}) = Parameter

typealias ParameterArray Array{Parameter,1}
isparameter(arr::ParameterArray) = Bool[p.variable for p in arr]
values(arr::ParameterArray) = map(value, arr)

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

(+)(lhs::Parameter, rhs::Number) = lhs.value + rhs
(+)(lhs::Number, rhs::Parameter) = lhs + rhs.value
(+)(lhs::Parameter, rhs::AbstractArray) = lhs.value + rhs
(+)(lhs::AbstractArray, rhs::Parameter) = lhs + rhs.value
(-)(lhs::Parameter, rhs::Number) = lhs.value - rhs
(-)(lhs::Number, rhs::Parameter) = lhs - rhs.value
(-)(lhs::Parameter, rhs::AbstractArray) = lhs.value - rhs
(-)(lhs::AbstractArray, rhs::Parameter) = lhs - rhs.value
(*)(lhs::Parameter, rhs::Number) = lhs.value * rhs
(*)(lhs::Number, rhs::Parameter) = lhs * rhs.value
(*)(lhs::Parameter, rhs::AbstractArray) = lhs.value * rhs
(*)(lhs::AbstractArray, rhs::Parameter) = lhs * rhs.value
(/)(lhs::Parameter, rhs::Number) = lhs.value / rhs
(/)(lhs::Number, rhs::Parameter) = lhs / rhs.value
(/)(lhs::Parameter, rhs::AbstractArray) = lhs.value / rhs
(/)(lhs::AbstractArray, rhs::Parameter) = lhs / rhs.value
isequal(x::Number, y::Parameter) = isequal(x, y.value)
isequal(x::Parameter, y::Number) = isequal(x.value, y)
isless(x::Parameter, y::Parameter) = isless(x.value, y.value)
isless(x::Number, y::Parameter) = isless(x, y.value)
isless(x::Parameter, y::Number) = isless(x.value, y)
const fun = (
    :abs2, :acos, :acosd, :acosh, :acot, :acotd, :acoth, :acsc, :acscd, :acsch, :airy, :airyai,
    :airyaiprime, :airybi, :airybiprime, :airyprime, :asec, :asecd, :asech, :asin, :asind, :asinh,
    :atan, :atand, :atanh, :besselj0, :besselj1, :bessely0, :bessely1, :cbrt, :cos, :cosd, :cosh,
    :cot, :cotd, :coth, :csc, :cscd, :csch, :digamma, :erf, :erfc, :erfi, :exp, :exp2, :expm1, :gamma,
    :inv, :lgamma, :log, :log10, :log1p, :log2, :sec, :secd, :sech, :sin, :sind, :sinh, :sqrt, :tan,
    :tand, :tanh, :trigamma,
)
for f in fun
    @eval begin
        import Base.$f
        export $f
        $f(par::Parameter) = $f(par.value)
    end
end

(+)(lhs::ParameterArray, rhs::Number) = values(lhs) + rhs
(+)(lhs::Number, rhs::ParameterArray) = lhs + values(rhs)
(-)(lhs::ParameterArray, rhs::Number) = values(lhs) - rhs
(-)(lhs::Number, rhs::ParameterArray) = lhs - values(rhs)
(*)(lhs::ParameterArray, rhs::Number) = values(lhs) * rhs
(*)(lhs::Number, rhs::ParameterArray) = lhs * values(rhs)
(/)(lhs::ParameterArray, rhs::Number) = values(lhs) / rhs
(/)(lhs::Number, rhs::ParameterArray) = lhs / values(rhs)
