using Test
using GenericDecMats
using Pkg

# Try to achieve that there is something to be tested.
if !(isdefined(Main, :Oscar) || isdefined(Main, :Chevie))
  # Try to load `Chevie`, and try to install it if it is not yet installed.
  if ! isdefined(Main, :Chevie)
    try import Chevie; catch(e) end
    if ! isdefined(Main, :Chevie)
      Pkg.add(url="https://github.com/jmichel7/Chevie.jl")
      try import Chevie; catch(e) end
    end
  end
  # Try to load Oscar.
  if ! isdefined(Main, :Chevie)
    try import Oscar; catch(e) end
  end
end

if isdefined(Main, :Oscar) || isdefined(Main, :Chevie)
  include("testdisp.jl")
end
if isdefined(Main, :Chevie)
  include("testcons.jl")
end
