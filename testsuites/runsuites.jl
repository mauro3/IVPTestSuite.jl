################################################################################
# Test Suite: Run all test suites
################################################################################

import PyPlot
const Py = PyPlot
using IVPTestSuite

################################################################################
## Exclude specific solvers
################################################################################
## The simplies way to exclude specific solvers or include solvers not included
## in release version of a given package, is to comment it out or include it in
## the dictionary of allsolvers (see src/solvers)

## You can also do the following

################################################################################
## Include suite to be run
################################################################################
function runtestsuite(;ODE_solverfns = Solvers.ODE_solverfns,
                       sundial_solverfns = Solvers.sundial_solverfns,
                       DASSL_solverfns = Solvers.DASSL_solverfns,
                       abstols = 10.0.^(-5:-1:-10),
                       reltols = abstols,
                       ntsteps = vcat(collect(10.^(1:5)), 500_000),
                       totest = IVPTestSuite.tc_all
                       )


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
     # abstols = 10.0.^(-5:-1:-10)
     # reltols = abstols

     # For fixed step solvers
     # ntsteps = vcat(collect(10.^(1:5)), 500_000)

     ################################################################################
     ## Run suite for selected solvers
     ################################################################################

     test_ODEsolvers = Dict{Any,Solver}()
     test_sundialsolvers = Dict{Any,Solver}()
     test_DASSLsolvers = Dict{Any,Solver}()

    for solverfn in ODE_solverfns
        test_ODEsolvers[solverfn] = Solvers.ODEsolvers[solverfn]
    end
    for solverfn in sundial_solverfns
        test_sundialsolvers[solverfn] = Solvers.ODEsolvers[solverfn]
    end
    for solverfn in DASSL_solverfns
        test_DASSLsolvers[solverfn] = Solvers.ODEsolvers[solverfn]
    end

    include(Pkg.dir()*"/IVPTestSuite/testsuites/suite_Sundials.jl")
    include(Pkg.dir()*"/IVPTestSuite/testsuites/suite_DASSL.jl")
    include(Pkg.dir()*"/IVPTestSuite/testsuites/suite_ODE_adaptive.jl")
    include(Pkg.dir()*"/IVPTestSuite/testsuites/suite_ODE_fixedstep.jl")

    runsuite_sundials(test_sundialsolvers,totest, abstols, reltols)
    runsuite_DASSL(test_DASSLsolvers,totest, abstols, reltols)
    runsuite_ODEadaptive(test_ODEsolvers,totest, abstols, reltols)
    runsuite_ODEfixed(test_ODEsolvers,totest,ntsteps)
end

runtestsuite(ODE_solverfns = [ODE.ode1],sundial_solverfns= [],DASSL_solverfns = [])
################################################################################
## Plot results
################################################################################
function plottestsuite()
  include(Pkg.dir()*"/IVPTestSuite/testsuites/plot_suites.jl")
end

plottestsuite()
