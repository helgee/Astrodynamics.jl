abstract Orphan <: Timescale
abstract NoConversion <: UTC

@testset "Time" begin
    @testset "Angles" begin
        @test round(dms2rad(-35, -15, -53.63), 7) == -0.6154886
        d, m, s, = rad2dms(-0.6154886)
        @test d == -35
        @test m == -15
        @test round(s, 2) == -53.64
    end
    @testset "Epoch" begin
        dt = DateTime(2000, 1, 1, 12, 0, 0)
        tt = Epoch(TT, 2000, 1, 1, 12, 0, 0.0, 0, 0.0)
        t1 = TTEpoch(2000, 1, 1, 12, 0, 0.0)
        tdb = TDBEpoch(tt)
        tcb = TCBEpoch(tt)
        tcg = TCGEpoch(tt)
        tai = TAIEpoch(tt)
        utc = UTCEpoch(tt)
        ut1 = UT1Epoch(tt)

        @test t1 ≈ TTEpoch(dt)
        @test dt == DateTime(t1)

        @test leapseconds(tt) == 0
        @test dut1(tt) == 0.0
        @test_throws ErrorException leapseconds(t1)
        @test_throws ErrorException dut1(t1)
        @test Epoch(TT, J2000) ≈ t1
        @test jd2000(tt) ≈ 0
        @test jd1950(Epoch(TT, 1950, 1, 1, 12, 0, 0, 0)) ≈ 0
        @test centuries(Epoch(TT, 2100, 1, 1, 12, 0, 0, 0)) == 1
        @test days(Epoch(TT, 2000, 1, 2, 12, 0, 0, 0)) == 1
        leapseconds!(t1, 0)
        dut1!(t1, 0.0)
        @test tt ≈ t1

        @test tai ≈ TAIEpoch(utc)
        @test utc ≈ UTCEpoch(tai)
        @test utc ≈ UTCEpoch(ut1)
        @test ut1 ≈ UT1Epoch(utc)
        @test tai ≈ TAIEpoch(ut1)
        @test ut1 ≈ UT1Epoch(tai)
        @test tt ≈ TTEpoch(ut1)
        @test ut1 ≈ UT1Epoch(tt)
        @test tt ≈ TTEpoch(tai)
        @test tai ≈ TAIEpoch(tt)
        @test tt ≈ TTEpoch(tcg)
        @test tcg ≈ TCGEpoch(tt)
        @test tt ≈ TTEpoch(tdb)
        @test tdb ≈ TDBEpoch(tt)
        @test tdb ≈ TDBEpoch(tcb)
        @test tcb ≈ TCBEpoch(tdb)

        @test tt ≈ TTEpoch(tcb)
        @test tcb ≈ TCBEpoch(tt)

        @test tt == TTEpoch(tt)

        @test_throws ErrorException Epoch(Orphan, tt)
        @test_throws ErrorException Epoch(NoConversion, tt)

        @test Epoch(TT, 2000, 1, 1) < Epoch(TT, 2000, 1, 2)
    end
    @testset "EpochDelta" begin
        @test EpochDelta(seconds=86400) ≈ EpochDelta(days=1)
        @test EpochDelta(seconds=86400) == EpochDelta(days=1)
        @test Epoch(TT, 2000, 1, 1) + EpochDelta(days=1) ≈ Epoch(TT, 2000, 1, 2)
        @test Epoch(TT, 2000, 1, 1) - EpochDelta(days=1) ≈ Epoch(TT, 1999, 12, 31)
        @test Epoch(TT, 2000, 1, 2) - Epoch(TT, 2000, 1, 1) == EpochDelta(days=1)
        @test Epoch(TT, 2000, 1, 1) - Epoch(TT, 2000, 1, 2) == EpochDelta(days=-1)
        @test seconds(EpochDelta(days=1)) == 86400
    end
end
