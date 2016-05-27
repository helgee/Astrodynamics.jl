using Dierckx

import Base: getindex, endof

export Trajectory

type Trajectory{F<:Frame, T<:Timescale, C<:CelestialBody}
    s0::State{F,T,C}
    t::Vector{Float64}
    x::Vector{Float64}
    y::Vector{Float64}
    z::Vector{Float64}
    vx::Vector{Float64}
    vy::Vector{Float64}
    vz::Vector{Float64}
    xspl::Spline1D
    yspl::Spline1D
    zspl::Spline1D
    vxspl::Spline1D
    vyspl::Spline1D
    vzspl::Spline1D
end

function Trajectory{F<:Frame, T<:Timescale, C<:CelestialBody}(s0::State{F,T,C}, t, x, y, z, vx, vy, vz)
    Trajectory(s0,
        collect(t),
        x, y, z, vx, vy, vz,
        Spline1D(t, x, bc="error"),
        Spline1D(t, y, bc="error"),
        Spline1D(t, z, bc="error"),
        Spline1D(t, vx, bc="error"),
        Spline1D(t, vy, bc="error"),
        Spline1D(t, vz, bc="error"),
    )
end

function interpolate(tra::Trajectory, time)
    if time > tra.t[end] && time ≈ tra.t[end]
        t = tra.t[end]
    else
        t = time
    end
    x = evaluate(tra.xspl, t)
    y = evaluate(tra.yspl, t)
    z = evaluate(tra.zspl, t)
    vx = evaluate(tra.vxspl, t)
    vy = evaluate(tra.vyspl, t)
    vz = evaluate(tra.vzspl, t)
    return x, y, z, vx, vy, vz
end

function getindex{F<:Frame, T<:Timescale, C<:CelestialBody}(tra::Trajectory{F,T,C}, time)
    rv = interpolate(tra, time)
    return State(tra.s0.epoch + EpochDelta(seconds=time), [rv...], F, C)
end

function getindex{F<:Frame, T1<:Timescale, T2<:Timescale, C<:CelestialBody}(tra::Trajectory{F,T1,C}, time::Epoch{T2})
    Δe = Epoch(T1, time) - tra.s0.epoch
    time = seconds(Δe)
    rv = interpolate(tra, time)
    return State(tra.s0.epoch + Δe, [rv...], F, C)
end

endof(tra::Trajectory) = tra.t[end]
