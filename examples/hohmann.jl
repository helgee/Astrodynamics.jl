using Astrodynamics

s0 = State(
    Epoch(TAI, 2000, 1, 1, 12),
    [7100, 0, 1300],
    [0, 7.35, 1],
)

toi = @vary(
    toi = 1e-4,
    toi >= 0.0,
    toi <= pi,
    ImpulsiveManeuver(along=toi)
)
goi = @vary(
    goi = 0,
    goi >= 0.0,
    goi <= pi,
    ImpulsiveManeuver(along=goi)
)

ode = ODE(
    gravity=J2Gravity(Earth),
    maxstep=2700,
    discontinuities = [
        Discontinuity(PericenterEvent(), toi),
        Discontinuity(ApocenterEvent(), goi),
    ],
)

seg = Segment(
    dt=86400,
    start = InitialOrbit(s0),
    stop = TargetOrbit(
        sma = 42165.0,
        ecc = 0.0,
    ),
    propagator = ode,
)

res = minimize(seg, DeltaV(), NLoptSolver(dx=1e-6))
println(res.after.propagation.trajectory.s1)
