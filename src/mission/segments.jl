export Segment, resetparameters!, setparameters!

type Segment
    parameters::ParameterArray
    dt::Parameter
    start::Boundary
    stop::Boundary
    arc::Arc
    propagator::Propagator
    constraints::Vector{Constraint}
end

type SegmentResult
    segment::Segment
    trajectory::Trajectory
    discontinuities::Dict{Symbol,Any}
    events::Dict{Symbol,Any}
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
    arc = Coast(),
    propagator = ODE(),
    constraints = Constraint[],
)
    Segment(params, dt, start, stop, arc, propagator, constraints)
end

function setparameters!(seg::Segment, x)
    for (par, val) in zip(seg.parameters, x)
        push!(par, val)
    end
    return seg
end

resetparameters!(seg::Segment) = foreach(reset!, seg.parameters)
lowerbounds(seg::Segment) = map(lower, seg.parameters)
upperbounds(seg::Segment) = map(lower, seg.parameters)

function propagate(seg::Segment)
    s0 = seg.start.state
    SegmentResult(seg, trajectory(s0, seg.dt, seg.propagator)...)
end

function obj_gradient!(g, seg::Segment)
    n = length(seg.parameters)
end

function gradient!(x, idx, seg::Segment, con::Constraint)
    dx = sqrt(eps()) * (1.0 + abs(x[idx]))
    push!(seg.parameters[idx], x+dx)
    res = propagate(seg)
    val = evaluate(con, res)
    reset!(seg.parameters[idx])
    return val
end
