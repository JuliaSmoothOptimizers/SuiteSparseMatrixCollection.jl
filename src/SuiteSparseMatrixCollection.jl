module SuiteSparseMatrixCollection
__precompile__(false)

using JuliaDB
using Dates

export fetch_ssmc, ssmc_matrices, group_path, matrix_path, ssmc, ssmc_dir, ssmc_formats

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

If `matrices` is iterable, download matrices from the SuiteSparseMatrixCollection.
Each matrix will be stored in `matrix_path(matrix; format=format)`.

    fetch_ssmc(name; format="MM")

If `name` is a string, select matrices whose name contain the string
`name` in the collection, and download them.

    fetch_ssmc(group, name; format="MM")

If `group` and `name` are strings, select matrices whose group and name contain the strings
`group` and `name`, respectively, in the collection, and download them.
"""
function fetch_ssmc(matrices; format="MM")
  format ∈ ssmc_formats || error("unknown format $format")
  for matrix in matrices
    ext = format == "mat" ? "mat" : "tar.gz"
    url = "$ssmc_url/$format/$(matrix.group)/$(matrix.name).$(ext)"
    g_path = group_path(matrix, format=format)
    mkpath(g_path)
    fname = joinpath(g_path, "$(matrix.name).$(ext)")
    if !isfile(fname)
      @info "downloading $fname"
      download(url, fname)
    end
    if ext == "tar.gz"
      tar_options = Sys.iswindows() ? "--force-local" : ""
      run(`tar $tar_options -zxf $fname -C $g_path`)
      rm(fname)
    end
  end
end

function fetch_ssmc(group::AbstractString, name::AbstractString; kwargs...)
  matrices = ssmc_matrices(group, name)
  fetch_ssmc(matrices; kwargs...)
  return matrices
end

"""
    ssmc_matrices(group, name)

Return an iterable of matrices whose group contains the string `group` and whose
name contains the string `name`.

    ssmc_matrices("", name)

Return an iterable of matrices whose name contains the string `name`.

    ssmc_matrices(group, "")

Return an iterable of matrices whose group contains the string `group`.

Example: `ssmc_matrices("HB", "bcsstk")`.
"""
function ssmc_matrices(group::AbstractString, name::AbstractString)
  filter(p -> occursin(group, p.group) && occursin(name, p.name), ssmc)
end

end
