using Dierckx
#= using PlotlyJS =#
using UnicodePlots

import Base: getindex, endof, show
#= import PlotlyJS: plot =#

export Trajectory, plot

abstract AbstractTrajectory

type Trajectory{
        F<:Frame,
        T<:Timescale,
        C<:CelestialBody,
        P<:Propagator,
    } <: AbstractTrajectory
    propagator::Type{P}
    s0::State{F,T,C}
    s1::State{F,T,C}
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

function Trajectory{
        F<:Frame,
        T<:Timescale,
        C<:CelestialBody,
        P<:Propagator,
    }(p::Type{P},
    s0::State{F,T,C},
    s1::State{F,T,C},
    t, x, y, z, vx, vy, vz)
    Trajectory(
        p,
        s0,
        s1,
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

function show{
        F<:Frame,
        T<:Timescale,
        C<:CelestialBody,
        P<:Propagator,
    }(io::IO, tra::Trajectory{F,T,C,P})
    println(io, "Trajectory{$F, $T, $C, $P}")
    println(io, " Start date: $(tra.s0.epoch)")
    println(io, " End date:   $(tra.s1.epoch)")
    println(io, " Frame: $F")
    println(io, " Body: $C")
    println(io, " Propagator: $P")
    plt = lineplot(tra.x, tra.y, color=:red, title="XY")
    print(io, plt)
    plt = lineplot(tra.x, tra.z, color=:red, title="XZ")
    print(io, plt)
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

#= function plot{F<:Frame, T<:Timescale, C<:CelestialBody}(tra::Trajectory{F,T,C}) =#
#=     re = equatorial_radius(constants(C)) =#
#=     rp = polar_radius(constants(C)) =#
#=     n = 100 =#
#=     θ = linspace(-π/2, π/2, n) =#
#=     ϕ = linspace(0, 2π, n) =#
#=     x = [re * cos(i) * cos(j) for i in θ, j in ϕ] =#
#=     y = [re * cos(i) * sin(j) for i in θ, j in ϕ] =#
#=     z = [rp * sin(i) for i in θ, j in ϕ]; =#
#=     s = surface(x=x, y=y, z=z, colorscale="Blues") =#
#=     p = scatter3d(;x=tra.x, y=tra.y, z=tra.z, mode="lines", line=attr(color="rgb(255,0,0)")) =#
#=     plot([s, p]) =#
#= end =#
