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
using Requires

import Base.show

export generic_decomposition_matrix,
       generic_decomposition_matrices_overview

# The data files are stored in this directory.
const _datadir = abspath(@__DIR__, "..", "data")

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

function __init__()
    if isdefined(Main, :Oscar)
      # If Oscar is available then use its polynomials.
      Requires.@require Oscar = "f1435218-dba5-11e9-1e4d-f1a5fab5fc13" begin
        include("for_oscar.jl")
      end
    elseif isdefined(Main, :Gapjm)
      # If Gapjm is available then use its polynomials.
      Requires.@require Gapjm = "367f69f0-ca63-11e8-2372-438b29340c1b" begin
        include("MatrixDisplay.jl")
        include("for_gapjm.jl")
      end
    else
      error("need one of Oscar.jl, Gapjm.jl")
    end
end

end # module
