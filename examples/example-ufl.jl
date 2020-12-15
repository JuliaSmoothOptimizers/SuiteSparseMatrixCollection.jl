using SuiteSparseMatrixCollection

# real rectangular matrices
rect = ssmc[(100 .≤ ssmc.nrows .≤ 1000) .& (100 .≤ ssmc.ncols .≤ 1000) .& (ssmc.nrows .!= ssmc.ncols) .& (ssmc.real .== true), :]

# all symmetric positive definite matrices
posdef = ssmc[(ssmc.numerical_symmetry .== 1) .& (ssmc.positive_definite .== true) .& (ssmc.real .== true), :]

# small symmetric positive definite matrices
posdef_small = ssmc[(ssmc.numerical_symmetry .== 1) .& (ssmc.positive_definite .== true) .& (ssmc.real .== true) .& (ssmc.nrows .≤ 200), :]

fetch_ssmc(posdef_small, format="MM")
