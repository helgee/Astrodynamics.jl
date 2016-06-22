import Base: copy

export Segment, resetparameters!, setparameters!, parameters, copy

type Segment
    #= parameters::ParameterArray =#
    dt::Parameter
    start::Boundary
    stop::Boundary
    arc::Arc
    propagator::Propagator
    constraints::Vector{AbstractConstraint}
end

type SegmentResult
    segment::Segment
    trajectory::Trajectory
    discontinuities::Dict{Symbol,Any}
    events::Dict{Symbol,Any}
end

#= function Segment(; kwargs...) =#
#=     params = Parameter[] =#
#=     for kv in kwargs =#
#=         append!(params, getparameters(kv[end])) =#
#=     end =#
#=     Segment(params; kwargs...) =#
#= end =#

function Segment(#params::ParameterArray;
    ;
    dt = constant(0.0),
    start = Pass(),
    stop = Pass(),
    arc = Coast(),
    propagator = ODE(),
    constraints = AbstractConstraint[],
)
    #= Segment(params, dt, start, stop, arc, propagator, constraints) =#
    Segment(dt, start, stop, arc, propagator, constraints)
end

function setparameters!(seg::Segment, x)
    #= for (par, val) in zip(seg.parameters, x) =#
    for (par, val) in zip(getparameters(seg), x)
        push!(par, val)
    end
    return seg
end

#= resetparameters!(seg::Segment) = foreach(reset!, seg.parameters) =#
#= lowerbounds(seg::Segment) = map(lower, seg.parameters) =#
#= upperbounds(seg::Segment) = map(upper, seg.parameters) =#
#= values(seg::Segment) = map(value, seg.parameters) =#
#= parameters(seg::Segment) = seg.parameters =#

resetparameters!(seg::Segment) = foreach(reset!, getparameters(seg))
lowerbounds(seg::Segment) = map(lower, getparameters(seg))
upperbounds(seg::Segment) = map(upper, getparameters(seg))
values(seg::Segment) = map(value, getparameters(seg))

function propagate(seg::Segment)
    s0 = seg.start.state
    SegmentResult(seg, trajectory(s0, seg.dt, seg.propagator)...)
end
