using Documenter, SuiteSparseMatrixCollection

makedocs(
  modules = [SuiteSparseMatrixCollection],
  doctest = true,
  linkcheck = true,
  strict = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
  ),
  sitename = "SuiteSparseMatrixCollection.jl",
  pages = ["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl.git",
  devbranch = "main",
)
