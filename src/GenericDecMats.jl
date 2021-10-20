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
julia> mat = generic_decomposition_matrix("B2d2" )
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

julia> show( stdout, "text/latex", mat )
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
using Oscar

import Base.show

export generic_decomposition_matrix,
       generic_decomposition_matrices_overview

# The data files are stored in this directory.
const _datadir = abspath(@__DIR__, "..", "data")

mutable struct GenericDecompositionMatrix
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
    # dec. matrix and its entries
    R::Union{MPolyRing{fmpz}, FlintIntegerRing}
    vars::Union{Vector{fmpz_mpoly}, Vector{fmpz}}
    decmat::Union{AbstractAlgebra.Generic.MatSpaceElem{fmpz_mpoly},fmpz_mat}
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
function generic_decomposition_matrix(name::String)
    filename = _datadir*"/"*name*".json"
    isfile(filename) || return nothing
    str = read(filename, String)
    prs = JSON.parse(str; dicttype = Dict{Symbol,Any})

    if haskey(prs, :indets)
      R, vars = PolynomialRing(ZZ, Vector{String}(prs[:indets]))
    else
      R, vars = (ZZ, fmpz[])
    end

    m = length(prs[:ordinary])
    n = length(prs[:hc_series])
    list = prs[:decmat]
    for i in 1:length(list)
      if isa(list[i], Vector)
        cfs = list[i][2:2:end]
        exp = Vector{Int64}[]
        for j in 1:2:(length(list[i])-1)
          monexp = zeros(Int64, length(vars))
          for k in 1:2:(length(list[i][j])-1)
            monexp[list[i][j][k]] = list[i][j][k+1]
          end
          push!(exp, monexp)
        end
        list[i] = R(cfs, exp)
      end
    end
    decmat = matrix(R, m, n, list)

    obj = GenericDecompositionMatrix(
      prs[:type],
      prs[:n],
      prs[:d],
      prs[:ordinary],
      prs[:hc_series],
      [Tuple{String, String, Int}(x) for x in prs[:blocks]],
      prs[:blocklabels],
      R,
      vars,
      decmat,
      prs[:condition],
      prs[:origin],
    )
end

zero_repl_string(str::String) = (str == "0" ? "." : str)

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
    )

    # Create strings from the matrix entries.
    strmat = [zero_repl_string(string(decmat.decmat[i,j]))
              for i in rowindices, j in colindices]

    # Print the labelled matrix.
    labelled_matrix_formatted(ioc, strmat)
end

"""
    generic_decomposition_matrices_overview()

Show an overview of the available generic decomposition matrices.
"""
function generic_decomposition_matrices_overview()
    files = readdir(_datadir)
    names = [x[1:findfirst('.', x)-1] for x in files]
    mx = maximum(map(length, names)) + 1
    ncol = div(displaysize(stdout)[2] - 4, mx)
    i = 0
    print( "  " );
    for name in names
      print(lpad(name, mx))
      i = i + 1
      if i == ncol
        print( "\n  " );
        i = 0
      end
    end
end

end # module
