using SuiteSparseMatrixCollection

using Test

function test_fetch()
  two_square = filter(p -> p.structure == "symmetric" && p.posDef == "no" && p.type == "real" && p.rows ≤ 100, ssmc)
  @test size(two_square, 1) == 2
  for format in SuiteSparseMatrixCollection.ssmc_formats
    Sys.iswindows() && format != "mat" && continue
    fetch_ssmc(two_square, format=format)
    g_paths = group_paths(two_square, format=format)
    mtx_paths = matrix_paths(two_square, format=format)
    for (matrix, g_path, mtx_path) in zip(eachrow(two_square), g_paths, mtx_paths)
      @test isdir(g_path)
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
  @test size(bcsstk, 1) == 39

  bcsstk_small = bcsstk[bcsstk.rows .≤ 100, :]
  @test size(bcsstk_small, 1) == 2

  hb_bcsstk = ssmc_matrices("HB", "bcsstk")
  @test size(hb_bcsstk, 1) == 33

  hb_matrices = ssmc_matrices("HB", "")
  @test size(hb_matrices, 1) == 292
end

function test_fetch_by_name()
  subset = ssmc_matrices("Belcastro", "")
  @test size(subset, 1) == 3
  fetch_ssmc("Belcastro", "", format="mat")
  g_paths = group_paths(subset, format="mat")
  mtx_paths = matrix_paths(subset, format = "mat")
  for (matrix, g_path, mtx_path) in zip(eachrow(subset), g_paths, mtx_paths)
    @test isdir(g_path)
    @test isfile(joinpath(g_path, "$(matrix.name).mat"))
  end
end

test_fetch()
test_select()
test_fetch_by_name()
