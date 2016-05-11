@testset "Euler" begin
    ex = [1.0; 0.0; 0.0]
    @test euler_dcm(321, π/2, π/2, π/2)*ex ≈ rotate_x(π/2)*rotate_y(π/2)*rotate_z(π/2)*ex
    @test euler_dcm(121, π/2, π/2, π/2)*ex ≈ rotate_x(π/2)*rotate_y(π/2)*rotate_x(π/2)*ex
    @test euler_dcm(123, π/2, π/2, π/2)*ex ≈ rotate_z(π/2)*rotate_y(π/2)*rotate_x(π/2)*ex
    @test euler_dcm(131, π/2, π/2, π/2)*ex ≈ rotate_x(π/2)*rotate_z(π/2)*rotate_x(π/2)*ex
    @test euler_dcm(132, π/2, π/2, π/2)*ex ≈ rotate_y(π/2)*rotate_z(π/2)*rotate_x(π/2)*ex
    @test euler_dcm(212, π/2, π/2, π/2)*ex ≈ rotate_y(π/2)*rotate_x(π/2)*rotate_y(π/2)*ex
    @test euler_dcm(213, π/2, π/2, π/2)*ex ≈ rotate_z(π/2)*rotate_x(π/2)*rotate_y(π/2)*ex
    @test euler_dcm(231, π/2, π/2, π/2)*ex ≈ rotate_x(π/2)*rotate_z(π/2)*rotate_y(π/2)*ex
    @test euler_dcm(232, π/2, π/2, π/2)*ex ≈ rotate_y(π/2)*rotate_z(π/2)*rotate_y(π/2)*ex
    @test euler_dcm(312, π/2, π/2, π/2)*ex ≈ rotate_y(π/2)*rotate_x(π/2)*rotate_z(π/2)*ex
    @test euler_dcm(313, π/2, π/2, π/2)*ex ≈ rotate_z(π/2)*rotate_x(π/2)*rotate_z(π/2)*ex
    @test euler_dcm(323, π/2, π/2, π/2)*ex ≈ rotate_z(π/2)*rotate_y(π/2)*rotate_z(π/2)*ex
end
