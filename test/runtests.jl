using SuiteSparseMatrixCollection

using Test

function test_fetch()
  matrices = ssmc[(ssmc.numerical_symmetry .== 1)    .&
                  (ssmc.positive_definite .== false) .&
                  (ssmc.real .== true)               .&
                  (ssmc.nrows .≤ 10), :]
  @test size(matrices, 1) == 3
  for (group, name) ∈ zip(matrices.group, matrices.name)
    for format ∈ SuiteSparseMatrixCollection.ssmc_formats
      path = fetch_ssmc(group, name, format=format)
      @test isdir(path)
      ext = format == "MM" ? "mtx" : "rb"
      @test isfile(joinpath(path, "$(name).$(ext)"))
    end
  end
end

function test_select()
  bcsstk = ssmc_matrices("bcsstk")
  @test size(bcsstk, 1) == 40

  bcsstk_small = bcsstk[bcsstk.nrows .≤ 100, :]
  @test size(bcsstk_small, 1) == 2

  hb_bcsstk = ssmc_matrices("HB", "bcsstk")
  @test size(hb_bcsstk, 1) == 33

  hb_matrices = ssmc_matrices("HB", "")
  @test size(hb_matrices, 1) == 292
end

function test_fetch_by_name()
  subset = ssmc_matrices("Belcastro", "")
  @test size(subset, 1) == 3
  matrices = ssmc_matrices("Belcastro", "")
  for (group, name) ∈ zip(matrices.group, matrices.name)
    for format ∈ SuiteSparseMatrixCollection.ssmc_formats
      path = fetch_ssmc(group, name, format=format)
      @test isdir(path)
      ext = format == "MM" ? "mtx" : "rb"
      @test isfile(joinpath(path, "$(name).$(ext)"))
    end
  end
end

test_fetch()
test_select()
test_fetch_by_name()
