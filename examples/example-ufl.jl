using SuiteSparseMatrixCollection

# real rectangular matrices
# probs = filter(p -> 100 ≤ p.rows ≤ 1000 && 100 ≤ p.cols ≤ 1000 && p.structure == "rectangular" && p.type == "real", ufl)

# all symmetric positive definite matrices
ufl_posdef = filter(p -> p.structure == "symmetric" && p.posDef == "yes" && p.type == "real", ssmc)

# small symmetric positive definite matrices
ufl_posdef_small = filter(p -> p.structure == "symmetric" && p.posDef == "yes" && p.type == "real" && p.rows ≤ 2_000, ssmc)

# tiny symmetric positive definite matrices
ufl_posdef_tiny = filter(p -> p.structure == "symmetric" && p.posDef == "yes" && p.type == "real" && p.rows ≤ 100, ssmc)

format = "MM"  # MatrixMarket
# format = "RB"  # RutherfordBoeing

fetch_ssmc(ufl_posdef_tiny, format=format)
