export Boundary, Pass, Launch, Rendezvous, Departure, InitialOrbit, TargetOrbit

abstract Boundary

type Pass <: Boundary
end

type Launch <: Boundary
    lat::Float64
    lon::Float64
    alt::Float64
end

type Rendezvous <: Boundary
    target::Symbol
    segment::Int
end

type Departure <: Boundary
    parent::Symbol
    segment::Int
end

type InitialOrbit <: Boundary
    state::State
end

type TargetOrbit <: Boundary
    sma::Nullable{Float64}
    ecc::Nullable{Float64}
    inc::Nullable{Float64}
    node::Nullable{Float64}
    peri::Nullable{Float64}
    ano::Nullable{Float64}
end

function TargetOrbit(;
    sma = Nullable{Float64}(),
    ecc = Nullable{Float64}(),
    inc = Nullable{Float64}(),
    node = Nullable{Float64}(),
    peri = Nullable{Float64}(),
    ano = Nullable{Float64}(),
)
    TargetOrbit(sma, ecc, inc, node, peri, ano)
end
