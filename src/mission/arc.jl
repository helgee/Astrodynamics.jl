export Arc, ThrustArc, Coast

abstract Arc

type ThrustArc <: Arc
    alpha::ParameterArray
    beta::ParameterArray
end

type Coast <: Arc
end
