using Documenter, SuiteSparseMatrixCollection

makedocs(
  modules = [SuiteSparseMatrixCollection],
  doctest = true,
  linkcheck = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
    ansicolor = true,
  ),
  sitename = "SuiteSparseMatrixCollection.jl",
  pages = ["Home" => "index.md", "Reference" => "reference.md"],
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl.git",
  push_preview = true,
  devbranch = "main",
)
