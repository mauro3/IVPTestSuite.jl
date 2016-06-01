# Here the different standard solvers in the ODE packages are setup.
module Solvers
using Requires
using IVPTestSuite

const adaptive = true
const nonadaptive = false

const allsolvers = Dict{Any,Solver}() # to hold all solvers

# helper
function nonmod_fn{N,T}(tc::TestCase{N,T})
    fn(t,y) = (out = tc.fn!(); tc.fn!(t,y,out); out)
    return fn
end
function nonmod_jac{N,T}(tc::TestCase{N,T})
    jac(t,y) = (out = tc.jac!(); tc.jac!(t,y,out); out)
    return jac
end
function nonmod_mass{N,T}(tc::TestCase{N,T})
    mass(t,y) = (out = tc.mass!(); tc.mass!(t,y,out); out)
    return mass
end


#include("ODE.jl")
include("ODE_pwl.jl")
include("DASSL.jl")
include("Sundials.jl")

end # module
