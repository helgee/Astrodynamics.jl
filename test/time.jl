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
        dt = DateTime(2000, 1, 1, 12, 0, 0.0)
        tt = Epoch(TT, 2000, 1, 1, 12, 0, 0.0)
        @test string(tt) == "2000-01-01T12:00:00.000 TT"
        tdb = TDBEpoch(tt)
        tcb = TCBEpoch(tt)
        tcg = TCGEpoch(tt)
        tai = TAIEpoch(tt)
        utc = UTCEpoch(tt)
        ut1 = UT1Epoch(tt)

        ref = Epoch(TDB, 2013, 3, 18, 12)
        @test UT1Epoch(ref) == UT1Epoch("2013-03-18T11:58:52.994")
        @test UTCEpoch(ref) == UTCEpoch("2013-03-18T11:58:52.814")
        @test TAIEpoch(ref) == TAIEpoch("2013-03-18T11:59:27.814")
        @test TTEpoch(ref) == TTEpoch("2013-03-18T11:59:59.998")
        @test TCBEpoch(ref) == TCBEpoch("2013-03-18T12:00:17.718")
        @test TCGEpoch(ref) == TCGEpoch("2013-03-18T12:00:00.795")
        @test ref == TDBEpoch(UT1Epoch("2013-03-18T11:58:52.994"))
        @test ref == TDBEpoch(UTCEpoch("2013-03-18T11:58:52.814"))
        @test ref == TDBEpoch(TAIEpoch("2013-03-18T11:59:27.814"))
        @test ref == TDBEpoch(TTEpoch("2013-03-18T11:59:59.998"))
        @test ref == TDBEpoch(TCBEpoch("2013-03-18T12:00:17.718"))
        @test ref == TDBEpoch(TCGEpoch("2013-03-18T12:00:00.795"))

        @test tt ≈ TTEpoch(dt)
        @test dt == DateTime(tt)

        @test Epoch(TT, J2000) ≈ tt
        @test jd2000(tt) ≈ 0
        @test jd1950(Epoch(TT, 1950, 1, 1, 12)) ≈ 0
        @test centuries(Epoch(TT, 2100, 1, 1, 12)) == 1
        @test days(Epoch(TT, 2000, 1, 2, 12)) == 1

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
    @testset "Leap Seconds" begin
        for year = 1970:2016
            @test leapseconds(DateTime(year, 4, 1)) == eraDat(year, 4, 1, 0.0)
        end
    end
end
