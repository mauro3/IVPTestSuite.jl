################################################################################
# Test Suite: Run all test suites
################################################################################

import PyPlot
const Py = PyPlot
using IVPTestSuite

################################################################################
## Select test cases to use
################################################################################
totest = IVPTestSuite.tc_all
# totest = IVPTestSuite.tc_all[:plei]

# totest = similar(totest)
# totest[:rober] = IVPTestSuite.tc_all[:rober]

################################################################################
## Set Tolerancs and step sizes for tests
################################################################################
# For adaptive solvers
abstols = 10.0.^(-5:-1:-10)
reltols = abstols

# For fixed step solvers
ntsteps = vcat(collect(10.^(1:5)), 500_000)

################################################################################
## Exclude specific solvers
################################################################################
# N/A

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
include("plot_suites_allsolvers.jl")
