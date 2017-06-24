using Astrodynamics

r = [
6068279.27,
-1692843.94,
-2516619.18,
]/1000

v = [
-660.415582,
5495.938726,
-5303.093233,
]/1000

t = UTCEpoch("2016-05-30T12:00:00.000")

iss = State(t, r, v)

tra = propagate(ODE(), iss, period(iss) * 2)
