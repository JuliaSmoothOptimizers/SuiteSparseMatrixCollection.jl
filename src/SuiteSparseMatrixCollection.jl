module SuiteSparseMatrixCollection

using DataFrames
using JLD2

export fetch_ssmc, ssmc_matrices, group_paths, matrix_paths, ssmc, ssmc_dir, ssmc_formats

Base.@deprecate group_path group_paths
Base.@deprecate matrix_path matrix_paths

const ssmc_jld2 = joinpath(@__DIR__, "..", "src", "ssmc.jld2")
const ssmc_url = "https://sparse.tamu.edu"

"Folder where matrices are stored."
const ssmc_dir = joinpath(@__DIR__, "..", "data")

"Main database."
global ssmc

function __init__()
  isdir(ssmc_dir) || mkdir(ssmc_dir)
  file = jldopen(ssmc_jld2, "r")
  global ssmc = file["df"]
  last_rev_date = file["last_rev_date"]
  close(file)
  @info "loaded database with revision date" last_rev_date
end

"Formats in which matrices are available."
const ssmc_formats = ("MM", "RB", "mat")

"""
    group_paths(matrices; format="MM")

Return the array of paths where `matrices`'s groups will be or were downloaded.
"""
function group_paths(matrices; format="MM")
  format ∈ ssmc_formats || error("unknown format $format")
  joinpath.(ssmc_dir, format, matrices.group)
end

"""
    matrix_paths(matrices; format="MM")

The argument `matrices` should be a `DataFrame` or `DataFrameRow`.
Return the array of paths where each matrix in `matrices` will be or was downloaded.
"""
matrix_paths(matrices; format="MM") = joinpath.(group_paths(matrices; format=format), matrices.name)

"""
    fetch_ssmc(matrices; format="MM")

Download matrices from the SuiteSparseMatrixCollection.
The argument `matrices` should be a `DataFrame` or `DataFrameRow`.
Each matrix will be stored in `matrix_paths(matrix; format=format)`.

    fetch_ssmc(name; format="MM")

If `name` is a string, select matrices whose name contain the string
`name` in the collection, and download them.

    fetch_ssmc(group, name; format="MM")

If `group` and `name` are strings, select matrices whose group and name contain the strings
`group` and `name`, respectively, in the collection, and download them.
"""
function fetch_ssmc(matrices; format="MM")
  format ∈ ssmc_formats || error("unknown format $format")
  g_paths = group_paths(matrices, format=format)
  for (matrix, g_path) in zip(eachrow(matrices), g_paths)
    ext = format == "mat" ? "mat" : "tar.gz"
    url = "$ssmc_url/$format/$(matrix.group)/$(matrix.name).$(ext)"
    extfile = format == "mat" ? "mat" : (format == "RB" ? "rb" : "mtx")
    mkpath(g_path)
    fname = joinpath(g_path, "$(matrix.name).$(ext)")
    fnamefile = format == "mat" ? joinpath(g_path, "$(matrix.name).$(extfile)") : joinpath(g_path, matrix.name, "$(matrix.name).$(extfile)")
    if !isfile(fnamefile)
      @info "downloading $fname"
      download(url, fname)
      if ext == "tar.gz"
        run(`tar -zxf $fname -C $g_path`)
        rm(fname)
      end
    end
  end
end

fetch_ssmc(name::AbstractString; kwargs...) = fetch_ssmc("", name; kwargs...)

function fetch_ssmc(group::AbstractString, name::AbstractString; kwargs...)
  matrices = ssmc_matrices(group, name)
  fetch_ssmc(matrices; kwargs...)
  return matrices
end

"""
    ssmc_matrices(group, name)

Return a `DataFrame` of matrices whose group contains the string `group` and whose
name contains the string `name`.

    ssma_matrices(name)
    ssmc_matrices("", name)

Return a `DataFrame` of matrices whose name contains the string `name`.

    ssmc_matrices(group, "")

Return a `DataFrame` of matrices whose group contains the string `group`.

Example: `ssmc_matrices("HB", "bcsstk")`.
"""
function ssmc_matrices(group::AbstractString, name::AbstractString)
  ssmc[occursin.(group, ssmc.group) .& occursin.(name, ssmc.name), :]
end

ssmc_matrices(name::AbstractString) = ssmc_matrices("", name)

end
