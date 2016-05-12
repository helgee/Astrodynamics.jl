@testset "Rotations" begin
    @test_throws ArgumentError rotation_axes("XYP")
    @test_throws ArgumentError rotation_axes("XY1")
    @test_throws ArgumentError rotation_axes("124")
    @test_throws ArgumentError rotation_axes("1231")
    @test_throws ArgumentError rotation_axes("XYZX")
    @test_throws ArgumentError rotation_axes("XXZ")
    @test_throws ArgumentError rotation_axes("ZXX")
    @test rotation_axes("XYZ") == 123
    @test rotation_axes("xyz") == 123
    @test rotation_axes("123") == 123
    @test rotation_axes(123) == 123

    @test rotation_axes("X") == 1
    @test rotation_axes("Y") == 2
    @test rotation_axes("Z") == 3
    @test rotation_axes(3) == 3
    @test_throws ArgumentError rotation_axes("B")
    @test_throws ArgumentError rotation_axes("4")
    @test_throws ArgumentError rotation_axes("XY")
end
