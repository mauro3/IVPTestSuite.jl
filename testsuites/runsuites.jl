################################################################################
# Test Suite: Run all test suites
################################################################################

import PyPlot
const Py = PyPlot
using IVPTestSuite

################################################################################
## Select test cases to use
################################################################################
# totest = IVPTestSuite.tc_all
# totest = similar(totest)
# totest[:plei] = IVPTestSuite.tc_all[:plei]

################################################################################
## Set Tolerancs and step sizes for tests
################################################################################
# For adaptive solvers
#abstols = 10.0.^(-5:-1:-10)
#reltols = abstols

# For fixed step solvers
#ntsteps = vcat(collect(10.^(1:5)), 500_000)

################################################################################
## Exclude specific solvers
################################################################################
## The best way to exclude specific solvers or include solvers not included
## in release version of a given package, is to comment it out or include it in
## the dictionary of allsolvers (see src/solvers)
################################################################################
## Include suite to be run
################################################################################
include("suite_Sundials.jl")
include("suite_DASSL.jl")
include("suite_ODE_adaptive.jl")
include("suite_ODE_fixedstep.jl")

################################################################################
## Plot results
################################################################################
#include("plot_suites.jl")
