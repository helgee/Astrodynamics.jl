export Node, Pass, Launch, Rendezvous, Separation, InitialOrbit, TargetOrbit

abstract Node

type Pass <: Node
end

type Launch <: Node
    lat::Float64
    lon::Float64
    alt::Float64
end

type Rendezvous <: Node
    target::Symbol
    segment::Int
end

type Separation <: Node
    parent::Symbol
    segment::Int
end

type InitialOrbit <: Node
    state::State
end

type TargetOrbit <: Node
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
