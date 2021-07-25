# SuiteSparseMatrixCollection.jl

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4324340.svg)](https://doi.org/10.5281/zenodo.4324340)
[![CI](https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/workflows/CI/badge.svg?branch=main)](https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/actions)
[![Build Status](https://api.cirrus-ci.com/github/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl.svg)](https://cirrus-ci.com/github/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl)
[![documentation](https://img.shields.io/badge/docs-latest-3f51b5.svg)](https://JuliaSmoothOptimizers.github.io/SuiteSparseMatrixCollection.jl/latest)
[![codecov](https://codecov.io/gh/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/SuiteSparseMatrixCollection.jl)

A straightforward interface to the [SuiteSparse Matrix Collection](https://sparse.tamu.edu/).

## How to Cite

If you use SuiteSparseMatrixCollection.jl in your work, please cite using the format given in [CITATION.bib](https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl/blob/main/CITATION.bib).

## How to install

```julia
pkg> add SuiteSparseMatrixCollection
pkg> test SuiteSparseMatrixCollection
```

## Updating the database

Clone this repository, activate the `utils` environment and run `gen_db.jl` to check if the database needs to be updated.

## Updating `Artifacts.toml`

Clone this repository, activate the `utils` environment and run `gen_artifacts.jl` to check if `Artifacts.toml` needs to be updated.

## Examples

```julia
julia> using SuiteSparseMatrixCollection

julia> # name-based selection can be done with `ssmc_matrices()`
julia> ssmc = ssmc_db()
julia> ssmc_matrices(ssmc, "HB", "bcsstk")  # all matrices whose group contains "HB" and name contains "bcsstk"
julia> ssmc_matrices(ssmc, "", "bcsstk")    # all matrices whose name contains "bcsstk"
julia> ssmc_matrices(ssmc, "HB", "")        # all matrices whose group contains "HB"

julia> # select symmetric positive definite matrices with ≤ 100 rows and columns
julia> tiny = ssmc[(ssmc.numerical_symmetry .== 1) .& (ssmc.positive_definite.== true) .&
                   (ssmc.real .== true) .& (ssmc.nrows .≤ 100), :]

julia> # fetch the matrices selects in MatrixMarket format
julia> paths = fetch_ssmc(tiny, format="MM")   # matrices are downloaded in paths
julia> downloaded_matrices = installed_ssmc()  # name of all downloaded matrices
julia> delete_ssmc("HB", "bcsstk02")           # delete the matrix "bcsstk02" of group "HB"
julia> delete_all_ssmc()                       # delete all matrices from the SuiteSparseMatrixCollection
```

Matrices are available in formats:

* `"RB"`: the [Rutherford-Boeing format](https://www.cise.ufl.edu/research/sparse/matrices/DOC/rb.pdf);
* `"MM"`: the [MatrixMarket format](http://math.nist.gov/MatrixMarket/formats.html#MMformat).

Use `DataFrames` syntax to further examine a list of selected matrices:
```julia
julia> tiny[!, [:name, :nrows, :ncols, :positive_definite, :lower_bandwidth]]
12×5 DataFrame
│ Row │ name          │ nrows │ ncols │ positive_definite │ lower_bandwidth │
│     │ String        │ Int64 │ Int64 │ Bool              │ Int64           │
├─────┼───────────────┼───────┼───────┼───────────────────┼─────────────────┤
│ 1   │ bcsstk01      │ 48    │ 48    │ 1                 │ 35              │
│ 2   │ bcsstk02      │ 66    │ 66    │ 1                 │ 65              │
│ 3   │ bcsstm02      │ 66    │ 66    │ 1                 │ 0               │
│ 4   │ nos4          │ 100   │ 100   │ 1                 │ 13              │
│ 5   │ ex5           │ 27    │ 27    │ 1                 │ 20              │
│ 6   │ mesh1e1       │ 48    │ 48    │ 1                 │ 47              │
│ 7   │ mesh1em1      │ 48    │ 48    │ 1                 │ 47              │
│ 8   │ mesh1em6      │ 48    │ 48    │ 1                 │ 47              │
│ 9   │ LF10          │ 18    │ 18    │ 1                 │ 3               │
│ 10  │ LFAT5         │ 14    │ 14    │ 1                 │ 5               │
│ 11  │ Trefethen_20b │ 19    │ 19    │ 1                 │ 16              │
│ 12  │ Trefethen_20  │ 20    │ 20    │ 1                 │ 16              │
```

Matrices in Rutherford-Boeing format can be opened with [`HarwellRutherfordBoeing.jl`](https://github.com/JuliaSparse/HarwellRutherfordBoeing.jl):
```julia
pkg> add HarwellRutherfordBoeing

julia> using HarwellRutherfordBoeing

julia> matrix = ssmc[ssmc.name .== "bcsstk01", :]
1×30 DataFrame. Omitted printing of 17 columns
│ Row │ group  │ nnzdiag │ nrows │ numerical_symmetry │ amd_vnz │ binary │ structural_rank │ is_nd │ is_graph │ RB_type │ lower_bandwidth │ explicit_zeros │ amd_flops │
│     │ String │ Int64   │ Int64 │ Float64            │ Int64   │ Bool   │ Int64           │ Bool  │ Bool     │ String  │ Int64           │ Int64          │ Float64   │
├─────┼────────┼─────────┼───────┼────────────────────┼─────────┼────────┼─────────────────┼───────┼──────────┼─────────┼─────────────────┼────────────────┼───────────┤
│ 1   │ HB     │ 48      │ 48    │ 1.0                │ 651     │ 0      │ 48              │ 1     │ 0        │ rsa     │ 35              │ 0              │ 6009.0    │

julia> path = fetch_ssmc(matrix, format="RB")
1-element Array{String,1}:
 "/Users/dpo/dev/JSO/SuiteSparseMatrixCollection.jl/src/../data/RB/HB/bcsstk01"

julia> A = RutherfordBoeingData(joinpath(path[1], "$(matrix.name[1]).rb"))
Rutherford-Boeing data 23 of type rsa
48 rows, 48 cols, 224 nonzeros
```

Matrices in MM format can be opened with [`MatrixMarket.jl`](https://github.com/JuliaSparse/MatrixMarket.jl).

