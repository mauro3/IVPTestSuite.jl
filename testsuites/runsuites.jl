# Runs all test suites
#import Winston # needs current master (30 Jan 2015)
#const W = Winston
import PyPlot
const Py = PyPlot
using IVPTestSuite

abstols = 10.0.^(-5:-1:-10)
reltols = abstols
ntsteps = [10.^(1:5); 500_000]

totest = IVPTestSuite.tc_all
# totest = similar(totest)
# totest[:rober] = IVPTestSuite.tc_all[:rober]

#include("suite_Sundials.jl")
#include("suite_DASSL.jl")
include("suite_ODE.jl")
include("suite_ODE_fixedstep.jl")



## plot results
#include("plot_suites.jl")
#include("plot_suites_ODE_fixed.jl")
include("plot_suites_ODE_adaptive.jl")
