using SuiteSparseMatrixCollection

using Test

function test_fetch()
  two_square = filter(p -> p.structure == "symmetric" && p.posDef == "no" && p.type == "real" && p.rows ≤ 100, ssmc)
  @test length(two_square) == 2
  for format in SuiteSparseMatrixCollection.ssmc_formats
    fetch_ssmc(two_square, format=format)
    for matrix in two_square
      g_path = group_path(matrix, format=format)
      @test isdir(g_path)
      mtx_path = matrix_path(matrix, format=format)
      ext = format == "mat" ? "mat" : (format == "MM" ? "mtx" : "rb")
      if ext == "mat"
        @test isfile(joinpath(g_path, "$(matrix.name).$(ext)"))
      else
        @test isdir(mtx_path)
        @test isfile(joinpath(mtx_path, "$(matrix.name).$(ext)"))
      end
    end
  end
end

function test_select()
  bcsstk = ssmc_matrices("", "bcsstk")
  @test length(bcsstk) == 39

  bcsstk_small = filter(p -> p.rows ≤ 100, bcsstk)
  @test length(bcsstk_small) == 2

  hb_bcsstk = ssmc_matrices("HB", "bcsstk")
  @test length(hb_bcsstk) == 33

  hb_matrices = ssmc_matrices("HB", "")
  @test length(hb_matrices) == 292
end

function test_fetch_by_name()
  arenas = ssmc_matrices("Arenas", "")
  @test length(arenas) == 4
  fetch_ssmc("Arenas", "")
  for matrix in arenas
    g_path = group_path(matrix)
    @test isdir(g_path)
    mtx_path = matrix_path(matrix)
    @test isdir(mtx_path)
    @test isfile(joinpath(mtx_path, "$(matrix.name).mtx"))
  end
end

test_fetch()
test_select()
test_fetch_by_name()
