type DummyPlanet <: Planet
    id::Int
end

@testset "Ephemeris" begin
    ref = [-27566632.25908574, 132361428.30119616, 57418647.27316907, -29.78494750, -5.02975383, -2.18064505]
    @test state(Earth, TDBEpoch(2000,1,1,12)) ≈ ref
    @test_throws KeyError state(DummyPlanet(9999999), TDBEpoch(2000,1,1))
end
