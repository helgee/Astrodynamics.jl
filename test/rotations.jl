@testset "Rotations" begin
    @test_throws ArgumentError rotation_order("XYP")
    @test_throws ArgumentError rotation_order("XY1")
    @test_throws ArgumentError rotation_order("124")
    @test_throws ArgumentError rotation_order("1231")
    @test_throws ArgumentError rotation_order("XYZX")
    @test_throws ArgumentError rotation_order("XXZ")
    @test_throws ArgumentError rotation_order("ZXX")
    @test rotation_order("XYZ") == 123
    @test rotation_order("xyz") == 123
    @test rotation_order("123") == 123
    @test rotation_order(123) == 123
end
