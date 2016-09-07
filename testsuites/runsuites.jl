"
Benchmarker:
A Test Suite Module
------------------------------------------------------------
# This module, plugs into IVPTestSuite and allows you to:
#
#  1 - Select test cases to use
#      Ex: `cases = selectcases(:all)`
#      Ex: `cases = selectcases(:bruss1d)`
#      Ex: `cases = selectcases(:vdpol,:plei)`
#
#  2 - Set tolerancs and step sizes for tests
#      Ex: `abstols = 10.0.^(-5:-1:-10)`
#      Ex: `ntsteps = vcat(collect(10.^(1:5)), 500_000)`
#
#  3 - Select solvers to use
#      Ex: `solvers = allsolvers`
#      Ex: `solvers = [ODE.ode78, Sundials.cvode]`
#
#  4 - Run configured test
#      Ex: `runsuites()`
#      Ex: `runsuites(testcases=cases, testntsteps = ntsteps)`
#
#  5 - Plot the results
#      Ex: `plotsuites()`
----------------------------------------------------------
"
module Benchmarker
    using IVPTestSuite
    using Sundials
    using DASSL

    function selectcases(casestuple::Symbol...=:all)
        if casestuple[1] == :all
            cases = IVPTestSuite.tc_all
        else
            cases = similar(IVPTestSuite.tc_all)
            for case in casestuple
                cases[case] = IVPTestSuite.tc_all[case]
            end
        end
        return cases
    end

    allsolvers = collect(keys(Solvers.allsolvers))

    # for running a configured test suite

    max_runtime = 2*60 # 10 minutes
    function runsuites(;testsolvers = collect(keys(Solvers.allsolvers)),
                                    testcases = IVPTestSuite.tc_all,
                                    testabstol = 10.0.^(-5:-1:-10),
                                    testntsteps = vcat(collect(10.^(1:5)), 500_000))
        ODEsuites(testcases,testsolvers,testabstol)
        ODEfixedsuites(testcases,testsolvers,testntsteps)
        sundialsuites(testcases,testsolvers,testabstol)
        DASSLsuites(testcases,testsolvers,testabstol)
        totest = testcases
    end
    runsuites(solvers,cases,abstol,ntsteps) = runsuites(testsolvers = solvers,
                                                        testcases = cases,
                                                        testabstol = abstol,
                                                        testntsteps = ntsteps)

    # suites for each solver type
    include("suite_Sundials.jl")
    include("suite_DASSL.jl")
    include("suite_ODE_adaptive.jl")
    include("suite_ODE_fixedstep.jl")

    # plotting script
    include("plot_suites.jl")

    # functions and variables for configuring benchmarks
    export selectcases, allsolvers
    # functions for running benchmarks
    export runsuites, ODEsuites, ODEfixedsuites, sundialsuites, DASSLsuites
    # functions for plotting benchmarks
    export plotsuites, plotfixedsuites, plotadaptivesuites
    export totest
end
