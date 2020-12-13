# SuiteSparseMatrixCollection.jl

[![CI](https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/workflows/CI/badge.svg?branch=master)](https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/actions)
[![Build Status](https://api.cirrus-ci.com/github/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl.svg)](https://cirrus-ci.com/github/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl)
[![documentation](https://img.shields.io/badge/docs-latest-3f51b5.svg)](https://JuliaSmoothOptimizers.github.io/SuiteSparseMatrixCollection.jl/latest)
[![codecov](https://codecov.io/gh/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/SuiteSparseMatrixCollection.jl)

A straightforward interface to the [SuiteSparse Matrix Collection](https://sparse.tamu.edu/).

## How to install

```julia
pkg> add SuiteSparseMatrixCollection
pkg> test SuiteSparseMatrixCollection
```

## Example

```julia
julia> using SuiteSparseMatrixCollection  # the database is named ssmc

julia> # name-based selection can be done with `ssmc_matrices()`
julia> ssmc_matrices("HB", "bcsstk")  # all matrices whose group contains "HB" and name contains "bcsstk"
julia> ssmc_matrices("", "bcsstk")    # all matrices whose name contains "bcsstk"
julia> ssmc_matrices("HB", "")        # all matrices whose group contains "HB"

julia> # select symmetric positive definite matrices with ≤ 100 rows and columns
julia> tiny = ssmc[(ssmc.structure .== "symmetric") .& (ssmc.posDef .== "yes") .& (ssmc.type .== "real") .& (ssmc.rows .≤ 100), :]

julia> # fetch the matrices selects in MatrixMarket format
julia> fetch_ssmc(tiny, format="MM")

julia> for matrix in tiny
         println(matrix_path(matrix, format="MM"))  # matrices are stored here
       end
```

Matrices are available in formats:

* `"RB"`: the [Rutherford-Boeing format](https://www.cise.ufl.edu/research/sparse/matrices/DOC/rb.pdf);
* `"mat"`: Matlab's [MAT-file format](https://www.mathworks.com/help/pdf_doc/matlab/matfile_format.pdf);
* `"MM"`: the [MatrixMarket format](http://math.nist.gov/MatrixMarket/formats.html#MMformat).

Use `DataFrames` syntax to further examine a list of selected matrices:
```julia
julia> tiny[!, [:name, :rows, :cols, :posDef, :kind])
10×5 DataFrames.DataFrame
│ Row │ name     │ rows  │ cols  │ posDef │ kind                                 │
│     │ String   │ Int64 │ Int64 │ String │ String                               │
├─────┼──────────┼───────┼───────┼────────┼──────────────────────────────────────┤
│ 1   │ bcsstk01 │ 48    │ 48    │ yes    │ structural problem                   │
│ 2   │ bcsstk02 │ 66    │ 66    │ yes    │ structural problem                   │
│ 3   │ bcsstm02 │ 66    │ 66    │ yes    │ structural problem                   │
│ 4   │ nos4     │ 100   │ 100   │ yes    │ structural problem                   │
│ 5   │ ex5      │ 27    │ 27    │ yes    │ computational fluid dynamics problem │
│ 6   │ mesh1e1  │ 48    │ 48    │ yes    │ structural problem                   │
│ 7   │ mesh1em1 │ 48    │ 48    │ yes    │ structural problem                   │
│ 8   │ mesh1em6 │ 48    │ 48    │ yes    │ structural problem                   │
│ 9   │ LF10     │ 18    │ 18    │ yes    │ model reduction problem              │
│ 10  │ LFAT5    │ 14    │ 14    │ yes    │ model reduction problem              │
```

Matrices in Rutherford-Boeing format can be opened with [`HarwellRutherfordBoeing.jl`](https://github.com/JuliaSparse/HarwellRutherfordBoeing.jl):
```julia
pkg> add HarwellRutherfordBoeing

julia> using HarwellRutherfordBoeing

julia> matrix = filter(p -> p.name == "bcsstk01", tiny)[1]
(id = 23, group = "HB", name = "bcsstk01", rows = 48, cols = 48, nonzeros = 400, structuralFullRankQ = "yes", structuralRank = "48", blocks = "1", comps = 1, explicitZeros = 0, nonzeroPatternSym = "symmetric", numericalSym = "symmetric", type = "real", structure = "symmetric", CholeskyCandidate = "yes", posDef = "yes", author = "J. Lewis", editor = "I. Duff, R. Grimes, J. Lewis", date = 1982-01-01, kind = "structural problem", notes = "")

julia> mtx_path = matrix_path(matrix, format="RB")
"/Users/dpo/dev/julia/JSO/SuiteSparseMatrixCollection.jl/src/../data/RB/HB/bcsstk01"

julia> A = RutherfordBoeingData(joinpath(mtx_path, "$(matrix.name).rb"))
Rutherford-Boeing data 23 of type rsa
48 rows, 48 cols, 224 nonzeros
```

Matrices in MAT format can be opened with [`MAT.jl`](https://github.com/JuliaIO/MAT.jl).

Matrices in MM format can be opened with [`MatrixMarket.jl`](https://github.com/JuliaSparse/MatrixMarket.jl).

