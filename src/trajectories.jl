export Trajectory

type Trajectory{T<:Frame, S<:Timescale}
    states::Array{State{T,S}, 1}
end
