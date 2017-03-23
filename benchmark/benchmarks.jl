using PkgBenchmark
using Astrodynamics

Astrodynamics.update()

@benchgroup "frames" ["frames", "conversions"] begin
    rv = ones(6)
    ep = TDBEpoch(2000, 1, 1)
    rot = Rotation(IAUEarth, ITRF, ep)
    @bench "multiconv" $rot($rv)
end
