using Dopri

type Propagator
    gravity::Function
    solar::Function
    drag::Function
    thirdbody::Function
    other::Vector{Function}
end

function propagate(s0::State)
end

function stepfun
end
