import Astrodynamics.rotation_axes, Astrodynamics.rotation_axis

@testset "Rotations" begin
    @test_throws ArgumentError rotation_axes("XYP")
    @test_throws ArgumentError rotation_axes("XY1")
    @test_throws ArgumentError rotation_axes("124")
    @test_throws ArgumentError rotation_axes("1231")
    @test_throws ArgumentError rotation_axes("XYZX")
    @test_throws ArgumentError rotation_axes("XXZ")
    @test_throws ArgumentError rotation_axes("ZXX")
    @test rotation_axes("XYZ") == [1,2,3]
    @test rotation_axes("xyz") == [1,2,3]
    @test rotation_axes("123") == [1,2,3]

    @test rotation_axis("X") == 1
    @test rotation_axis("Y") == 2
    @test rotation_axis("Z") == 3
    @test_throws ArgumentError rotation_axis("B")
    @test_throws ArgumentError rotation_axis("XY")

    @test_throws ArgumentError rotation_matrix("4", 0.0)
end
