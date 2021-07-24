using SuiteSparseMatrixCollection

using Test

@testset "fetch test" begin
  ssmc = ssmc_db()
  matrices = ssmc[
    (ssmc.numerical_symmetry .== 1) .& (ssmc.positive_definite .== false) .& (ssmc.real .== true) .& (ssmc.nrows .≤ 10),
    :,
  ]
  @test size(matrices, 1) == 3
  for (group, name) ∈ zip(matrices.group, matrices.name)
    for format ∈ SuiteSparseMatrixCollection.ssmc_formats
      path = fetch_ssmc(group, name, format = format)
      @test isdir(path)
      ext = format == "MM" ? "mtx" : "rb"
      @test isfile(joinpath(path, "$(name).$(ext)"))
    end
  end
end

@testset "select test" begin
  ssmc = ssmc_db()
  bcsstk = ssmc_matrices(ssmc, "bcsstk")
  @test size(bcsstk, 1) == 40

  bcsstk_small = bcsstk[bcsstk.nrows .≤ 100, :]
  @test size(bcsstk_small, 1) == 2

  hb_bcsstk = ssmc_matrices(ssmc, "HB", "bcsstk")
  @test size(hb_bcsstk, 1) == 33

  hb_matrices = ssmc_matrices(ssmc, "HB", "")
  @test size(hb_matrices, 1) == 292
end

@testset "fetch by name test" begin
  ssmc = ssmc_db()
  subset = ssmc_matrices(ssmc, "Belcastro", "")
  @test size(subset, 1) == 3
  matrices = ssmc_matrices(ssmc, "Belcastro", "")
  for (group, name) ∈ zip(matrices.group, matrices.name)
    for format ∈ SuiteSparseMatrixCollection.ssmc_formats
      path = fetch_ssmc(group, name, format = format)
      @test isdir(path)
      ext = format == "MM" ? "mtx" : "rb"
      @test isfile(joinpath(path, "$(name).$(ext)"))
    end
  end
end
