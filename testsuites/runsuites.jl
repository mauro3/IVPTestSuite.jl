# Runs all test suites
import Winston # needs current master (30 Jan 2015)
const W = Winston
using IVPTestSuite

abstols = 10.0.^(-5:-1:-7) #-13)
reltols = abstols
ntsteps = [10.^(1:4)] #5), 500_000]

include("suite_Sundials.jl")
include("suite_DASSL.jl")
include("suite_ODE.jl")
include("suite_ODE_fixedstep.jl")

## plot results
include("plot_suites.jl")
