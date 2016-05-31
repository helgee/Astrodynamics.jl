@testset "Propagators" begin
    @testset "Kepler Propagator" begin
        r0 = [1131.340, -2282.343, 6672.423]
        v0 = [-5.64305, 4.30333, 2.42879]
        Δt = 40*60
        Δe = EpochDelta(seconds=Δt)
        ep = Epoch(TT, now())
        s0 = State(ep, r0, v0)
        r1 = [-4219.7527, 4363.0292, -3958.7666]
        v1 = [3.689866, -1.916735, -6.112511]
        s1 = state(s0, Δt, Kepler())
        s2 = state(s0, Δt/4, Kepler())
        @test s1.rv ≈ [r1; v1]
        s1 = state(s0, Δe, Kepler())
        @test s1.rv ≈ [r1; v1]
        tra = trajectory(s0, Δt, Kepler())
        s1 = tra[Δt]
        @test s1.rv ≈ [r1; v1]
        tra = trajectory(s0, Δe, Kepler())
        s1 = tra[ep+Δe]
        @test s1.rv ≈ [r1; v1]
        @test tra[Δt/4] ≈ s2
        @test_throws ErrorException tra[Δt+1]
        tra = trajectory(s0, Kepler())
        @test tra[end] ≈ State(ep+EpochDelta(seconds=period(s0)), r0, v0)
    end
    @testset "ODE Propagator" begin
        r0 = [1131.340, -2282.343, 6672.423]
        v0 = [-5.64305, 4.30333, 2.42879]
        Δt = 40*60
        Δe = EpochDelta(seconds=Δt)
        ep = Epoch(TT, now())
        s0 = State(ep, r0, v0)
        r1 = [-4219.7527, 4363.0292, -3958.7666]
        v1 = [3.689866, -1.916735, -6.112511]
        ode = ODE(maxstep=10)
        s2 = state(s0, Δt/4, ode)
        s1 = state(s0, Δt, ode)
        @test s1.rv ≈ [r1; v1]
        s1 = state(s0, Δe, ode)
        @test s1.rv ≈ [r1; v1]
        tra = trajectory(s0, Δe, ode)
        s1 = tra[ep+Δe]
        @test s1.rv ≈ [r1; v1]
        @test tra[Δt/4] ≈ s2
    end
end
