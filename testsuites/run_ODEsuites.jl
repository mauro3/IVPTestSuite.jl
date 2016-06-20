################################################################################
# Test Suite: Run ODE test suites
################################################################################

import PyPlot
const Py = PyPlot
using IVPTestSuite

################################################################################
## Select test cases to use
################################################################################
totest = IVPTestSuite.tc_all

# totest = similar(totest)
# totest[:rober] = IVPTestSuite.tc_all[:rober]

################################################################################
## Set Tolerancs and step sizes for tests
################################################################################
# For adaptive solvers
abstols = 10.0.^(-5:-1:-10)
reltols = abstols

# For fixed step solvers
ntsteps = [10.^(1:5); 500_000]

################################################################################
## Exclude specific solvers/Include nonpackage release solvers
################################################################################

## The best way to exclude specific solvers or include solvers not included
## in release version of a given package, is to comment it out or include it in
## the dictionary of allsolvers (see src/solvers)

################################################################################
## Include suites to be run
################################################################################
include("suite_ODE_adaptive.jl")
#include("suite_ODE_fixedstep.jl")

################################################################################
## Plot results
################################################################################
#include("plot_suites_ODE_fixedstep.jl")
include("plot_suites_ODE_adaptive.jl")
