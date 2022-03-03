using Test
using GenericDecMats
using Pkg

# Try to achieve that there is something to be tested.
if !(isdefined(Main, :Oscar) || isdefined(Main, :Gapjm))
  # Try to load `Gapjm`, and try to install it if it is not yet installed.
  if ! isdefined(Main, :Gapjm)
    try import Gapjm; catch(e) end
    if ! isdefined(Main, :Gapjm)
      Pkg.add(url="https://github.com/jmichel7/Gapjm.jl")
      try import Gapjm; catch(e) end
    end
  end
  # Try to load Oscar.
  if ! isdefined(Main, :Gapjm)
    try import Oscar; catch(e) end
  end
end

if isdefined(Main, :Oscar) || isdefined(Main, :Gapjm)
  include("testdisp.jl")
end
if isdefined(Main, :Gapjm)
  include("testcons.jl")
end
