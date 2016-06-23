import Dierckx: evaluate

export evaluate
export DeltaV

type DeltaV <: AbstractConstraint
    target::Float64
end
DeltaV() = DeltaV(0.0)

function evaluate(con::DeltaV, r::SegmentResult)
    dv = 0.0
    for discontinuity in r.segment.propagator.discontinuities
        if isa(discontinuity.update, ImpulsiveManeuver)
            dv += deltav(discontinuity.update)
        end
    end
    return dv - con.target
end

type SemiMajorAxis <: AbstractConstraint
    target::Float64
end
SemiMajorAxis() = SemiMajorAxis(0.0)

function evaluate(con::SemiMajorAxis, r::SegmentResult)
    semimajoraxis(r.propagation.trajectory.s1) - con.target
end

type Eccentricity <: AbstractConstraint
    target::Float64
end
Eccentricity() = Eccentricity(0.0)

function evaluate(con::Eccentricity, r::SegmentResult)
    eccentricity(r.propagation.trajectory.s1) - con.target
end

type Inclination <: AbstractConstraint
    target::Float64
end
Inclination() = Inclination(0.0)

function evaluate(con::Inclination, r::SegmentResult)
    inclination(r.propagation.trajectory.s1) - con.target
end

type AscendingNode <: AbstractConstraint
    target::Float64
end
AscendingNode() = AscendingNode(0.0)

function evaluate(con::AscendingNode, r::SegmentResult)
    ascendingnode(r.propagation.trajectory.s1) - con.target
end

type ArgumentOfPericenter <: AbstractConstraint
    target::Float64
end
ArgumentOfPericenter() = ArgumentOfPericenter(0.0)

function evaluate(con::ArgumentOfPericenter, r::SegmentResult)
    argumentofpericenter(r.propagation.trajectory.s1) - con.target
end

type TrueAnomaly <: AbstractConstraint
    target::Float64
end
TrueAnomaly() = TrueAnomaly(0.0)

function evaluate(con::TrueAnomaly, r::SegmentResult)
    trueanomaly(r.propagation.trajectory.s1) - con.target
end

const KEPLERIAN_CONSTRAINTS = Dict(
    :sma => SemiMajorAxis,
    :ecc => Eccentricity,
    :inc => Inclination,
    :node => AscendingNode,
    :peri => ArgumentOfPericenter,
    :ano => TrueAnomaly,
)
