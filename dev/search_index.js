var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#Home-1",
    "page": "Home",
    "title": "SuiteSparseMatrixCollection.jl documentation",
    "category": "section",
    "text": "A straightforward interface to the SuiteSparse Matrix Collection."
},

{
    "location": "#How-to-install-1",
    "page": "Home",
    "title": "How to install",
    "category": "section",
    "text": "julia> Pkg.clone(\"https://github.com/JuliaSmoothOptimizers/SuiteSparseMatrixCollection.jl\")\njulia> Pkg.test(\"SuiteSparseMatrixCollection\")"
},

{
    "location": "#Example-1",
    "page": "Home",
    "title": "Example",
    "category": "section",
    "text": "julia> using SuiteSparseMatrixCollection  # the database is named ssmc\n\njulia> # fetch symmetric positive definite matrices with ≤ 100 rows and columns\njulia> tiny = filter(p -> p.structure == \"symmetric\" && p.posDef == \"yes\" && p.type == \"real\" && p.rows ≤ 100, ssmc)\njulia> fetch_ssmc(tiny, format=\"MM\")  # download in MatrixMarket format\n\njulia> for matrix in tiny\n         println(matrix_path(matrix, format=\"MM\"))  # matrices are stored here\n       end"
},

{
    "location": "api/#",
    "page": "API",
    "title": "API",
    "category": "page",
    "text": ""
},

{
    "location": "api/#API-1",
    "page": "API",
    "title": "API",
    "category": "section",
    "text": "Pages = [\"api.md\"]"
},

{
    "location": "api/#SuiteSparseMatrixCollection.ssmc",
    "page": "API",
    "title": "SuiteSparseMatrixCollection.ssmc",
    "category": "constant",
    "text": "Main SuiteSparseMatrixCollection database.\n\n\n\n\n\n"
},

{
    "location": "api/#SuiteSparseMatrixCollection.ssmc_dir",
    "page": "API",
    "title": "SuiteSparseMatrixCollection.ssmc_dir",
    "category": "constant",
    "text": "Folder where matrices are stored.\n\n\n\n\n\n"
},

{
    "location": "api/#SuiteSparseMatrixCollection.ssmc_formats",
    "page": "API",
    "title": "SuiteSparseMatrixCollection.ssmc_formats",
    "category": "constant",
    "text": "Formats in which matrices are available.\n\n\n\n\n\n"
},

{
    "location": "api/#Constants-1",
    "page": "API",
    "title": "Constants",
    "category": "section",
    "text": "ssmc\nssmc_dir\nssmc_formats"
},

{
    "location": "api/#SuiteSparseMatrixCollection.matrix_path",
    "page": "API",
    "title": "SuiteSparseMatrixCollection.matrix_path",
    "category": "function",
    "text": "matrix_path(matrix; format=\"MM\")\n\nReturn the path where matrix will be or was downloaded.\n\n\n\n\n\n"
},

{
    "location": "api/#SuiteSparseMatrixCollection.fetch_ssmc",
    "page": "API",
    "title": "SuiteSparseMatrixCollection.fetch_ssmc",
    "category": "function",
    "text": "fetch_ssmc(matrices; format=\"MM\")\n\nDownload matrices from the SuiteSparseMatrixCollection. Each matrix will be stored in matrix_path(matrix; format=format).\n\n\n\n\n\n"
},

{
    "location": "api/#Utilities-1",
    "page": "API",
    "title": "Utilities",
    "category": "section",
    "text": "matrix_path\nfetch_ssmc"
},

{
    "location": "reference/#",
    "page": "Reference",
    "title": "Reference",
    "category": "page",
    "text": ""
},

{
    "location": "reference/#Reference-1",
    "page": "Reference",
    "title": "Reference",
    "category": "section",
    "text": ""
},

]}
