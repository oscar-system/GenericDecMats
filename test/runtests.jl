using Test
using GenericDecMats

# Try to achieve that there is something to be tested.
if ! (isdefined(Main, :Oscar) || isdefined(Main, :Gapjm))
  try import Gapjm; catch(e) end
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
