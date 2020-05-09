using JANAF, Test 

# Test import and functions
@testset "Import and Thermo Functions" begin
    path = "./"
    specie = ["H2O"]
    testT = 400

    @test isa(JanafDict(path,specie),Dict)
    @test isa(Cp(JanafDict(path,specie),specie[1],testT),Number)
    @test isa(S(JanafDict(path,specie),specie[1],testT),Number)
    @test isa(Hs(JanafDict(path,specie),specie[1],testT),Number)
    @test isa(Hf(JanafDict(path,specie),specie[1],testT),Number)
    @test isa(Gf(JanafDict(path,specie),specie[1],testT),Number)
    @test isa(Kf(JanafDict(path,specie),specie[1],testT),Number)

end
