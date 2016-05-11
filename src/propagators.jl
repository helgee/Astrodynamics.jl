abstract Propagator

type KeplerPropagator <: Propagator
    s0::AbstractState
    t0::Epoch
    body::Body
end

type NumericalPropagator <: Propagator
    s0::AbstractState
    t0::Epoch
    body::Body
end

setinitalstate!(p::Propagator, s0::AbstractState) = p.s0 = s0
setinitalepoch!(p::Propagator, t0::Epoch) = p.t0 = t0

function propagate(p::Propagator, tend::Epoch; steps=false)
end

function start(p::KeplerPropagator)
end

function start(p::KeplerPropagator, s)
end

function done(p::KeplerPropagator, s)
end
