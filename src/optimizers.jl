export Parameter, ParameterArray

type Parameter
    value::Float64
    upper::Float64
    lower::Float64
    fixed::Bool
end

isfixed(p::Parameter) = p.fixed

Parameter(value) = Parameter(value, 0.0, 0.0, true)
Parameter(value, upper, lower) = Parameter(value, upper, lower, false)

type ParameterArray
    array::Vector{Parameter}
end
