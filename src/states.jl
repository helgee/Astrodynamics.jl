abstract AbstractState

immutable State{T} <: AbstractState
    frame::Type{T}
    rv::Vector{Float64}
    epoch::Epoch
    body::Body
end

type StateSpace <: AbstractState
end

typealias ECEFState State{ECEF}
typealias ECIState State{ECI}

function elements(s::State)
    return elements(s.rv, planets[s.body]["mu"])
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

