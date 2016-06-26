################################################################################
# Test Suite: Run all test suites
################################################################################
module QuickSuites
    using IVPTestSuite
    import IVPTestSuite.Solvers
    import PyPlot
    import Sundials
    const Py = PyPlot

    # terminal line commands
    export runtestsuite, runalltestsuites, plottestsuite, runsuite_sundials, runsuite_ODEadaptive, runsuite_ODEfixed


    ################################################################################
    ## Test suite files which define testsuite function for different packages
    ################################################################################
    ## test suite files
    include("suite_Sundials.jl")
    include("suite_DASSL.jl")
    include("suite_ODE_adaptive.jl")
    include("suite_ODE_fixedstep.jl")

    ################################################################################
    ## Main function for running suite from Julia Terminal
    ################################################################################
    runalltestsuites(; abstols = 10.0.^(-5:-1:-10),
                                reltols = abstols,
                                ntsteps = vcat(collect(10.^(1:5)), 500_000),
                                totest = IVPTestSuite.tc_all) =  runtestsuite(ODEsolverfns = Solvers.ODEsolverfns,
                           sundialsolverfns = Solvers.sundialsolverfns,
                           DASSLsolverfns = Solvers.DASSLsolverfns,
                           abstols = abstols,
                           reltols = abstols,
                           ntsteps = ntsteps,
                           totest = totest
                           )
    function runtestsuite(;ODEsolverfns = Solvers.ODEsolverfns,
                           sundialsolverfns = [],
                           DASSLsolverfns = [],
                           abstols = 10.0.^(-5:-1:-10),
                           reltols = abstols,
                           ntsteps = vcat(collect(10.^(1:5)), 500_000),
                           totest = IVPTestSuite.tc_all
                           )


        ################################################################################
        ## Select test cases to use, else goes to default
        ################################################################################
        # totest = IVPTestSuite.tc_all
        # totest = similar(totest)
        # totest[:plei] = IVPTestSuite.tc_all[:plei]

        ################################################################################
        ## Set Tolerancs and step sizes for tests, else goes to default
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

        for solverfn in ODEsolverfns
            test_ODEsolvers[solverfn] = Solvers.ODEsolvers[solverfn]
        end
        for solverfn in sundialsolverfns
            test_sundialsolvers[solverfn] = Solvers.sundialssolvers[solverfn]
        end
        for solverfn in DASSLsolverfns
            test_DASSLsolvers[solverfn] = Solvers.DASSLsolvers[solverfn]
        end

        runsuite_sundials(test_sundialsolvers,totest, abstols, reltols)
        runsuite_DASSL(test_DASSLsolvers,totest, abstols, reltols)
        runsuite_ODEadaptive(test_ODEsolvers,totest, abstols, reltols)
        runsuite_ODEfixed(test_ODEsolvers,totest,ntsteps)
    end

    # Example run
    # runtestsuite(ODE_solverfns = [ODE.ode1,ODE.ode23s],sundial_solverfns= [],DASSL_solverfns = [])

    ################################################################################
    ## Plot results with plottestsuite() defined in following file
    ################################################################################
    include("plot_suites.jl")
end
