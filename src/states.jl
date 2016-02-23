export State

abstract AbstractState

immutable State{T<:Frame, S<:Timescale} <: AbstractState
    frame::Type{T}
    rv::Vector{Float64}
    epoch::Epoch{S}
    body::Body
end

Base.eltype{T,S}(::Type{State{T,S}}) = T

body(s::State) = s.body
rv(s::State) = s.rv
epoch(s::State) = s.epoch
frame(s::State) = s.frame

type StateSpace <: AbstractState
end

typealias ECEFState State{ECEF}
typealias ECIState State{ECI}

function elements(s::State)
    return elements(rv(s), μ(body(s)))
end

function elements(s::State, deg::Bool)
    ele = elements(s)
    if deg
        ele[3:end] = ele[3:end]*180/pi
        return ele
    else
        return ele
    end
end

