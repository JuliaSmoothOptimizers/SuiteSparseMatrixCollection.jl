module SuiteSparseMatrixCollection
__precompile__(false)

using JuliaDB
using Dates

export fetch_ssmc, group_path, matrix_path, ssmc, ssmc_dir, ssmc_formats

const colnames = [
  "id",
  "group",
  "name",
  "rows",
  "cols",
  "nonzeros",
  "structuralFullRankQ",
  "structuralRank",
  "blocks",
  "comps",
  "explicitZeros",
  "nonzeroPatternSym",
  "numericalSym",
  "type",
  "structure",
  "CholeskyCandidate",
  "posDef",
  "author",
  "editor",
  "date",
  "kind",
  "notes",
]

const colparsers = [
  Int,
  String,
  String,
  Int,
  Int,
  Int,
  String, #Bool,
  String, #Int,
  String, #Int,
  Int,
  Int,
  String,
  String,
  String,
  String,
  String, #Bool,
  String, #Bool,
  String,
  String,
  Date,
  String,
  String,
]

"Main SuiteSparseMatrixCollection database."
const ssmc = loadtable(joinpath(@__DIR__, "SSMCdata.dat"), delim='`', header_exists=false,
                       colnames=colnames, colparsers=colparsers, nastrings=["unknown"])

"Folder where matrices are stored."
const ssmc_dir = joinpath(@__DIR__, "..", "data")

"Formats in which matrices are available."
const ssmc_formats = ("MM", "RB", "mat")

const ssmc_url = "https://sparse.tamu.edu"

"""
    group_path(matrix; format="MM")

Return the path where `matrix`'s group will be or was downloaded.
"""
function group_path(matrix; format="MM")
  format ∈ ssmc_formats || error("unknown format $format")
  joinpath(ssmc_dir, format, matrix.group)
end

"""
    matrix_path(matrix; format="MM")

Return the path where `matrix` will be or was downloaded.
"""
matrix_path(matrix; format="MM") = joinpath(group_path(matrix; format=format), matrix.name)

"""
    fetch_ssmc(matrices; format="MM")

Download matrices from the SuiteSparseMatrixCollection.
Each matrix will be stored in `matrix_path(matrix; format=format)`.
"""
function fetch_ssmc(matrices; format="MM")
  format ∈ ssmc_formats || error("unknown format $format")
  for matrix in matrices
    ext = format == "mat" ? "mat" : "tar.gz"
    url = "$ssmc_url/$format/$(matrix.group)/$(matrix.name).$(ext)"
    g_path = group_path(matrix, format=format)
    mkpath(g_path)
    fname = joinpath(g_path, "$(matrix.name).$(ext)")
    isfile(fname) || download(url, fname)
  end
end

end
