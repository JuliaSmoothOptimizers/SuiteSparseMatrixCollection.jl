using Documenter, SuiteSparseMatrixCollection

makedocs(
  modules = [SuiteSparseMatrixCollection],
  doctest = true,
  linkcheck = true,
  strict = true,
  assets = ["assets/style.css"],
  format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
  sitename = "SuiteSparseMatrixCollection.jl",
  pages = ["Home" => "index.md",
           "API" => "api.md",
           "Reference" => "reference.md",
          ]
)

deploydocs(deps = nothing, make = nothing,
  repo = "github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl.git",
  target = "build",
  devbranch = "master"
)
