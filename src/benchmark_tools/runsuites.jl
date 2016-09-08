###############################################################################
# These functions plugs into IVPTestSuite instances and allows you to:
#
#  1 - Select test cases to use
#      Ex: `cases = [:all]`
#      Ex: `cases = [:bruss1d]`
#      Ex: `cases = [:vdpol,:plei]`
#
#  2 - Set tolerancs and step sizes for tests
#      Ex: `abstols = 10.0.^(-5:-1:-10)`
#      Ex: `ntsteps = vcat(collect(10.^(1:5)), 500_000)`
#
#  3 - Select solvers to use
#      Ex: `solvers = [all]`
#      Ex: `solvers = [ODE.ode78, Sundials.cvode]`
#
#  4 - Run configured test
#      Ex: `runsuite()`
#      Ex: `runsuite(testcases=cases, testntsteps = ntsteps)`
#
#  5 - Plot the results
#      Ex: `plotsuite()`
###############################################################################

# functions for running a configured test suite
"
runsuite(;testsolvers,testcases,testabstol,testntsteps)

function for easily running test suite scripts
"
function runsuite(;testsolvers::Array{Function,1} = [all],
                                testcases = :all,
                                testabstols = 10.0.^(-5:-1:-10),
                                testntsteps = vcat(collect(10.^(1:5)), 500_000),
                                verbose = false,
                                progressmeter = false)

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

    testreltols = testabstols

    #loop over each solver pack (e.g. ODE, Sundials)
    for (solverpack,respack) in resbysolverpack
        ##loop over each test case designated for suite
        for (n,tc) in testcases
            res = Dict{Solver,Any}()
            tstepss = [linspace(tc.tspan[1], tc.tspan[2], n) for n in testntsteps]
            #loop over each solver designated for suites,
            #and select the ones in the current solver package
            for solverfn in testsolvers
                if solverfn == Solvers.Sundials.idasol || solverfn==Solvers.Sundials.cvode
                    continue
                end
                if haskey(solverpack, solverfn)
                    solver = solverpack[solverfn]
                    # run test suite for adaptive or fixed step solver

                    if isapplicable(solver, tc) && isadaptive(solver)
                        suite = TestSuite(tc, solver, testabstols, testreltols, [NaN])
                        res[solver] = run_ode_testsuite(suite,verbose = verbose, progressmeter = progressmeter)
                    elseif isapplicable(solver, tc) && !isadaptive(solver)
                        if name(tc)==:bruss1d
                            # 10^5 steps take more than 10 min to run, skip:
                            suite = TestSuite(tc, solver, tstepss[testntsteps.<50_000])
                        elseif name(tc) == :plei
                          suite = TestSuite(tc, solver, tstepss[testntsteps.<10_000])
                        else
                            suite = TestSuite(tc, solver, tstepss)
                        end
                        res[solver] = run_ode_testsuite(suite,  verbose = verbose, progressmeter = progressmeter)
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


runsuite(solvers,cases,abstols,ntsteps) = runsuite(testsolvers = solvers,
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


# functions for configuring and running benchmarks
export runsuite, selectcases
# functions for plotting benchmarks
export plotsuite, plotfixedsuite, plotadaptivesuite
