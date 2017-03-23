using PkgBenchmark
using Astrodynamics

Astrodynamics.update()

@benchgroup "frames" ["frames", "conversions"] begin
    rv = ones(6)
    ep = TDBEpoch(2000, 1, 1)
    @bench "gcrf_itrf" Rotation(GCRF, ITRF, $ep)($rv)
    @bench "gcrf_iau" Rotation(GCRF, IAUEarth, $ep)($rv)
    @bench "iau_itrf" Rotation(IAUEarth, ITRF, $ep)($rv)
end
