#if packages not yet install, i.e. run Pkg.add("IVPTestSuite")
using IVPTestSuite
using ODE
using Sundials
using DASSL

solvers = [all]
# You may also select a subsection of solvers to test
# ex: testsolvers = [ODE.ode45, ODE.4ms]

# For fixed step solvers
ntsteps = vcat(collect(10.^(1:4)), 500_000)

# For adaptive solvers
abstols = 10.0.^(-5:-1:-11)

cases = [:all]
# You may also select a subsection of cases to test
# ex: cases = [:plei,:hires]

results = runsuite(testsolvers = solvers, testcases = cases,
                  testabstols = abstols, testntsteps = ntsteps);

PyPlot.svg(true)
plotsuite(results)
