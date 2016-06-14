import Dierckx: evaluate

export Constraint, evaluate
export DeltaV

type DeltaV <: Constraint
end

function evaluate(::DeltaV, r::SegmentResult)
    dv = 0.0
    for discontinuity in r.segment.propagator.discontinuities
        if isa(discontinuity.update, ImpulsiveManeuver)
            dv += deltav(discontinuity.update)
        end
    end
    return dv
end
