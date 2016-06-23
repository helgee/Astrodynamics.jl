export Kepler

type Kepler <: Propagator
    iterations::Int
    points::Int
    rtol::Float64
end

function Kepler(;iteration_limit::Int=50, points::Int=100, rtol::Float64=sqrt(eps()))
    Kepler(iteration_limit, points, rtol)
end

show(io::IO, ::Type{Kepler}) = print(io, "Kepler")

function state(s0::State, tend::EpochDelta, p::Kepler)
    r1, v1 = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], seconds(tend), p.iterations, p.rtol)
    State(s0.epoch + tend, r1, v1, s0.frame, s0.body)
end

function state(s0::State, tend, p::Kepler)
    r1, v1 = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], tend, p.iterations, p.rtol)
    State(s0.epoch + EpochDelta(seconds=tend), r1, v1, s0.frame, s0.body)
end

function trajectory(s0::State, tend, p::Kepler)
    times = linspace(0, tend, p.points)
    x = Vector{Float64}()
    y = Vector{Float64}()
    z = Vector{Float64}()
    vx = Vector{Float64}()
    vy = Vector{Float64}()
    vz = Vector{Float64}()
    for t in times
        r, v = kepler(μ(body(s0)), s0.rv[1:3], s0.rv[4:6], t, p.iterations, p.rtol)
        push!(x, r[1])
        push!(y, r[2])
        push!(z, r[3])
        push!(vx, v[1])
        push!(vy, v[2])
        push!(vz, v[3])
    end
    s1 = State(s0.epoch + EpochDelta(seconds=times[end]),
        x[end], y[end], z[end], vx[end], vy[end], vz[end],
        s0.frame, s0.body)
    Trajectory(s0, s1, times, x, y, z, vx, vy, vz)
end

trajectory(s0::State, tend::EpochDelta, p::Kepler) = trajectory(s0, seconds(tend), p::Kepler)
trajectory(s0::State, p::Kepler) = trajectory(s0, period(s0), p)
