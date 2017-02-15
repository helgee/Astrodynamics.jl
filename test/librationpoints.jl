@testset "Libration Points" begin
    l1ref = 0.15093428265127021
    l2ref = 0.16783274367911588
    l3ref = 0.99291206108848129
    @test libration_dist(μ(EARTH), μ(MOON), :L1) == l1ref
    @test libration_dist(μ(EARTH), μ(MOON), :L2) == l2ref
    @test libration_dist(μ(EARTH), μ(MOON), :L3) == l3ref

    rv = ones(6)
    rv[1:3] *= 1000
    epoch = TDBEpoch(2000,1,1)
    ref = [-1.1717170062386328, -1.1212220608364672E-003, 1.6674369835388907E-003,
           -1.6420893636515004, -0.45661886467983320, 0.68484198823320419]
    rv_lib = gcrf_to_libration_norm(rv, epoch, EARTH, MOON, :L2)
    @test rv_lib ≈ ref
    rv_eci = libration_norm_to_gcrf(rv_lib, epoch, EARTH, MOON, :L2)
    @test rv_eci ≈ rv
end
