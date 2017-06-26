using Astrodynamics

s0 = State(
    TAIEpoch(2000, 1, 1, 12),
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
    gravity=J2Gravity(),
    events=[
        Event(detector=Pericenter(), updater=toi),
        Event(detector=Apocenter(), updater=goi),
    ],
)

seg = Segment(
    InitialOrbit(s0),
    KeplerianTargetOrbit(
        sma = 42165.0,
        ecc = 0.0,
    ),
    dt=86400,
    propagator=ode,
)

res = minimize(seg, DeltaV(), NLoptSolver())
