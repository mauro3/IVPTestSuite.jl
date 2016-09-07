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

    # functions for running a configured test suite
    "
    runsuites(;testsolvers,testcases,testabstol,testntsteps)

    function for easily running test suite scripts
    "
    function runsuites(;testsolvers = [all],
                                    testcases = :all,
                                    abstols = 10.0.^(-5:-1:-10),
                                    ntsteps = vcat(collect(10.^(1:5)), 500_000))

        # test all solvers is option is chosen
        if testsolvers == [all]
          testsolvers = collect(keys(Solvers.allsolvers))
        end

        # select the designated test problems
        testcases = selectcases(testcases)

        # script for testing solvers and cases combinations
        ## create dictionaries to hold results
        resODE = Dict{Symbol,Dict}()
        resODEfixed = Dict{Symbol,Dict}()
        resSun = Dict{Symbol,Dict}()
        resDASSL = Dict{Symbol,Any}()

        ## group result dictionaries by solver packages
        resbysolverpack = Dict{}(Solvers.ODEadaptivesolvers => resODE,
                                Solvers.ODEfixedsolvers => resODEfixed,
                                Solvers.sundialssolvers => resSun,
                                Solvers.DASSLsolvers => resDASSL)

        reltols = abstols

        #loop over each solver pack (e.g. ODE, Sundials)
        for (solverpack,respack) in resbysolverpack
            ##loop over each test case designated for suite
            for (n,tc) in testcases
                res = Dict{Solver,Any}()
                #loop over each solver designated for suites,
                #and select the ones in the current solver package
                for solverfn in testsolvers
                    if haskey(solverpack, solverfn)
                        solver = solverpack[solverfn]
                        # run test suite for adaptive or fixed step solver
                        if isapplicable(solver, tc) && isadaptive(solver)
                            suite = TestSuite(tc, solver, abstols, reltols, [NaN])
                            res[solver] = run_ode_testsuite(suite)
                        elseif isapplicable(solver, tc) && !isadaptive(solver)
                            if name(tc)==:bruss1d
                                # 10^5 steps take more than 10 min to run, skip:
                                suite = TestSuite(tc, solver, tstepss[ntsteps.<50_000])
                            else

                                suite = TestSuite(tc, solver, tstepss)
                            end
                            res[solver] = run_ode_testsuite(suite)
                        end
                    end
                end
                #store result of the test case for the solvers in current solver pack
                if !isempty(res)
                  respack[n] = res
                end
            end
        end

        # return results necessary for plotting
        return (testcases, [resODE,resODEfixed,resSun, resDASSL])
    end


    runsuites(solvers,cases,abstols,ntsteps) = runsuites(testsolvers = solvers,
                                                        testcases = cases,
                                                        testabstol = abstols,
                                                        testntsteps = ntsteps)

    "
    selectcases(casesArray)

    Takes in array of symbols specifying test problems, and returns
    a corresponding dictionary of test problem symbols to test problem
    IVPTestSuite instances
    "
    function selectcases(casesArray::Array{Symbol,1}=[:all])
        if casesArray[1] == :all
            cases = IVPTestSuite.tc_all
        else
            cases = similar(IVPTestSuite.tc_all)
            for case in casesArray
                cases[case] = IVPTestSuite.tc_all[case]
            end
        end
        return cases
    end
    selectcases(case::Symbol=:all) = selectcases([case])

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
