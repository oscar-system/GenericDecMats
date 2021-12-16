@doc Markdown.doc"""
This module gives access to the generic decomposition matrices
of various groups of Lie type.

The data have been provided by Gunter Malle.

Currently one can just load the data into the Julia session,
and show the matrices.

Try
```
julia> generic_decomposition_matrices_overview()
```
to show which cases are available.

# Examples
```
julia> mat = generic_decomposition_matrix("B2d2")
B2, d = 2

   │ps A1 B1 ps B2 .1^2
───┼───────────────────
 2.│ 1  .  .  .  .    .
11.│ 1  1  .  .  .    .
 .2│ 1  .  1  .  .    .
1.1│ .  .  .  1  .    .
 B2│ .  .  .  .  1    .
.11│ 1  1  1  .  2    1

julia> show(IOContext(stdout, :block => 1), "text/plain", mat)
B2, d = 2 (block 1)

   │ps A1 B1 B2 .1^2
───┼────────────────
 2.│ 1  .  .  .    .
11.│ 1  1  .  .    .
 .2│ 1  .  1  .    .
 B2│ .  .  .  1    .
.11│ 1  1  1  2    1

julia> show(stdout, "text/latex", mat)
$B2, d = 2

\begin{array}{r|rrrrrr}
 & ps & A1 & B1 & ps & B2 & .1^2 \\
\hline
2. & 1 & . & . & . & . & . \\
11. & 1 & 1 & . & . & . & . \\
.2 & 1 & . & 1 & . & . & . \\
1.1 & . & . & . & 1 & . & . \\
B2 & . & . & . & . & 1 & . \\
.11 & 1 & 1 & 1 & . & 2 & 1 \\
\end{array}
$
```
"""
module GenericDecMats

using Markdown
using JSON
using Requires

import Base.show

export generic_decomposition_matrix,
       generic_decomposition_matrices_overview

# The data files are stored in this directory.
const _datadir = abspath(@__DIR__, "..", "data")

const _decomposition_matrix_from_list = Dict{Symbol, Function}()

mutable struct GenericDecompositionMatrix
    # store whether the contents belongs to Oscar or Gapjm
    context::Symbol
    # parameters
    type::String
    n::Int
    d::Int
    # row and column labels
    ordinary::Vector{String}
    hc_series::Vector{String}
    # distribution of rows (ordinary) to blocks
    blocks::Vector{Tuple{String, String, Int}}
    blocklabels::Vector{Int}
    # dec. matrix and its entries (no type information)
    vars
    decmat
    # exclude some values of q if necessary
    condition::String
    # bibliographical information
    origin::String
end

"""
    generic_decomposition_matrix(type::String, n::Int, d::Int)
    generic_decomposition_matrix(name::String)

Return the object described by the inputs if it is available,
and `nothing` otherwise.
"""
function generic_decomposition_matrix(type::String, n::Int, d::Int)
    return generic_decomposition_matrix(type*string(n)*"d"*string(d))
end

# load from file if available
function generic_decomposition_matrix(name::String, context::Symbol)
    filename = _datadir*"/"*name*".json"
    isfile(filename) || return nothing
    str = read(filename, String)
    prs = JSON.parse(str; dicttype = Dict{Symbol,Any})

    # Construct the decomposition matrix.
    if haskey(prs, :indets)
      indets = Vector{String}(prs[:indets])
    else
      indets = String[]
    end
    m = length(prs[:ordinary])
    n = length(prs[:hc_series])
    list = prs[:decmat]
    vars, decmat = _decomposition_matrix_from_list[context](list, indets, m, n)

    # Extend the 'blocklabels' list by defect zero characters.
    diff = m - length(prs[:blocklabels])
    if 0 < diff
      mx = maximum(prs[:blocklabels])
      append!(prs[:blocklabels], (mx+1):(mx+diff))
    end

    # Extend the 'blocks' list by defect zero blocks if necessary.
    nam = "$(prs[:type])$(prs[:n])"
    for i in (length(prs[:blocks])+1):maximum(prs[:blocklabels])
      push!(prs[:blocks],
            [nam, prs[:ordinary][findfirst(isequal(i), prs[:blocklabels])], 0])
    end

    # Extend the 'blocklabels' list by defect zero characters.
    diff = m - length(prs[:blocklabels])
    if 0 < diff
      mx = maximum(prs[:blocklabels])
      append!(prs[:blocklabels], (mx+1):(mx+diff))
    end

    # Extend the 'blocks' list by defect zero blocks if necessary.
    nam = "$(prs[:type])$(prs[:n])"
    for i in (length(prs[:blocks])+1):maximum(prs[:blocklabels])
      push!(prs[:blocks],
            [nam, prs[:ordinary][findfirst(isequal(i), prs[:blocklabels])], 0])
    end

    obj = GenericDecompositionMatrix(
      context,
      prs[:type],
      prs[:n],
      prs[:d],
      prs[:ordinary],
      prs[:hc_series],
      [Tuple{String, String, Int}(x) for x in prs[:blocks]],
      prs[:blocklabels],
      vars,
      decmat,
      prs[:condition],
      prs[:origin],
    )
end

# support the one argument version only if the method is unique
function generic_decomposition_matrix(name::String)
    len = length(_decomposition_matrix_from_list)
    len == 0 && error("no method available, try to load Gapjm.jl or Oscar.jl")
    len == 1 ||
      error("please specify one of $(string(keys(_decomposition_matrix_from_list))) as second argument")

    return generic_decomposition_matrix(name,
               collect(_decomposition_matrix_from_list)[1][1])
end

"""
    generic_decomposition_matrices_names()

Return an array of the names of the available matrices.
"""
function generic_decomposition_matrices_names()
    return [x[1:findfirst('.', x)-1] for x in readdir(_datadir)]
end

"""
    generic_decomposition_matrices_overview()

Show an overview of the available generic decomposition matrices.
"""
function generic_decomposition_matrices_overview()
    names = generic_decomposition_matrices_names()
    mx = maximum(map(length, names)) + 1
    ncol = div(displaysize(stdout)[2] - 4, mx)
    i = 0
    print("  ");
    for name in names
      print(lpad(name, mx))
      i = i + 1
      if i == ncol
        print("\n  ");
        i = 0
      end
    end
end

function Base.show(io::IO, ::MIME"text/latex", decmat::GenericDecompositionMatrix)
  print(io, "\$")
  show(IOContext(io, :TeX => true), "text/plain", decmat)
  print(io, "\$")
end

function Base.show(io::IO, ::MIME"text/plain", decmat::GenericDecompositionMatrix)
    name = decmat.type*string(decmat.n)*", d = "*string(decmat.d)

    # Decide whether we want to restrict the output to one block.
    if haskey(io, :block)
      b = io[:block]
      name = name*" (block $b)"
      colindices = filter(j -> decmat.blocklabels[j] == b,
                          1:length(decmat.blocklabels))
      rowindices = filter(i -> ! iszero(decmat.decmat[i, colindices]),
                          1:length(decmat.ordinary))

      hc_series = decmat.hc_series[colindices]
      ordinary = decmat.ordinary[rowindices]
    else
      colindices = 1:length(decmat.blocklabels)
      rowindices = 1:length(decmat.ordinary)
      hc_series = decmat.hc_series
      ordinary = decmat.ordinary
    end

    # Create the IO context.
    ioc = IOContext(io,
      :header => [name, ""],
      :labels_col => hc_series,
      :separators_row => [0],
      :separators_col => [0],
      :labels_row => ordinary,
      :limit => true,
    )

    # Create strings from the matrix entries.
    strmat = [zero_repl_string(decmat.decmat[i,j])
              for i in rowindices, j in colindices]

    # Print the labelled matrix.
    _labelled_matrix_formatted(ioc, strmat)
end

function __init__()
    # If Oscar is available then support a method for its polynomials.
    Requires.@require Oscar = "f1435218-dba5-11e9-1e4d-f1a5fab5fc13" begin
      include("for_oscar.jl")
    end
    # If Gapjm is available then support a method for its polynomials.
    Requires.@require Gapjm = "367f69f0-ca63-11e8-2372-438b29340c1b" begin
      include("MatrixDisplay.jl")
      include("for_gapjm.jl")
    end
end

end # module
