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
    totest = IVPTestSuite.tc_all
    resODE = Dict{Symbol,Dict}()
    resODEfixed = Dict{Symbol,Dict}()
    resSun = Dict{Symbol,Dict}()
    resDASSL = Dict{Symbol,Any}()

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

        resODE = Dict{Symbol,Dict}()
        resODEfixed = Dict{Symbol,Dict}()
        resSun = Dict{Symbol,Dict}()
        resDASSL = Dict{Symbol,Any}()

        resSun = runsuite_sundials(test_sundialsolvers,totest, abstols, reltols)
        resDASSL = runsuite_DASSL(test_DASSLsolvers,totest, abstols, reltols)
        resODE = runsuite_ODEadaptive(test_ODEsolvers,totest, abstols, reltols)
        resODEfixed = runsuite_ODEfixed(test_ODEsolvers,totest,ntsteps)
    end

    # Example run
    # runtestsuite(ODEsolverfns = [ODE.ode1,ODE.ode23s],sundialsolverfns= [],DASSLsolverfns = [])

    ################################################################################
    ## Plot results with plottestsuite() defined in following file
    ################################################################################
    # plots the suites ran with runsuites.jl and saves plots to output/
    function plottestsuite(;totest = IVPTestSuite.tc_all)
        #TODO: Use ColorMaps to get arbritary number of well spaced colors
        print("Good so far")
        cols = split("ymcrgbk","")
        push!(cols, )
        nc = length(cols)

        function make_legend!(leg, res)
            str = string(name(res[1].testrun.solver))
            str = replace(str, "_", "\\_")
            push!(leg, str)
        end

        ## Adaptive steppers
        # significant digits (scd) vs walltime
        for (n,tc) in totest
            leg = AbstractString[]
            id = Py.figure(figsize=(50,50),dpi=130)
            colind = 1
            p = 1
            maxscd = 0.0

            # DASSL.jl
            if !isempty(QuickSuites.resDASSL)
                res = resDASSL[n]
                scd = getfield_vec(res, :scd)
                maxscd = max(maxscd, maximum(scd))
                wt = getfield_vec(res, :walltime)
                p2 = Py.semilogy(scd, wt, "-x"*cols[colind])
                make_legend!(leg, res)
                colind +=1
            end

            # ODE.jl
            if !isempty(QuickSuites.resODE)
                rode = resODE[n]
                for (s,res) in rode
                    scd = getfield_vec(res, :scd)
                    if all(isnan(scd))
                        continue
                    end
                    maxscd = max(maxscd, maximum(scd))
                    wt = getfield_vec(res, :walltime)
                    p2 = Py.plot(scd, wt, "-o"*cols[rem1(colind,nc)])
                    make_legend!(leg, res)
                    colind +=1
                end
            end

            #Sundials
            if !isempty(QuickSuites.resSun)
                rsun = resSun[n]
                for (s,res) in rsun
                    scd = getfield_vec(res, :scd)
                    if all(isnan(scd))
                        continue
                    end
                    maxscd = max(maxscd, maximum(scd))
                    wt = getfield_vec(res, :walltime)
                    @show cols[rem1(colind,nc)]
                    p = Py.plot(scd, wt, "-d"*cols[rem1(colind,nc)])
                    make_legend!(leg, res)
                    colind +=1
                end
            end

            if colind==1
                Py.close(id) # no plots were made
            else
                Py.legend(leg, loc="upper left")
                Py.title("$n")
                Py.xlabel("significant digits")
                Py.ylabel("Walltime (s)")
                Py.display(id)
                Py.savefig(Pkg.dir()*"/IVPTestSuite/testsuites/output/adaptive-scd-vs-walltime-$n.png")
                #Py.close(id)
            end
        end

        ## Fixed step solvers
        # significant digits (scd) vs walltime
        if !isempty(QuickSuites.resODEfixed)
            for (n,tc) in totest

                leg = AbstractString[]
                id = Py.figure(figsize=(50,50),dpi=130)
                colind = 1
                p = 1
                p2 = 1
                maxscd = 0.0


                # # ODE.jl
                rode = resODEfixed[n]
                if length(rode)==0
                    Py.close(id)
                    continue
                end
                fst = true
                for (s,res) in rode
                    scd = getfield_vec(res, :scd)
                    if all(isnan(scd))
                        continue
                    end
                    maxscd = max(maxscd, maximum(scd))
                    wt = getfield_vec(res, :walltime)
                    if fst
                        p2 = Py.semilogy(scd, wt, "-o"*cols[colind])
                        fst = false
                    else
                        p2 = Py.plot(scd, wt, "-o"*cols[colind],hold = true)

                    end
                    make_legend!(leg, res)
                    colind +=1
                end

                Py.legend(leg)
                Py.title("$n (fixed step)")
                Py.xlabel("significant digits")
                Py.ylabel("Walltime (s)")

                Py.display(id)
                Py.savefig(Pkg.dir()*"/IVPTestSuite/testsuites/output/fixedstep-scd-vs-walltime-$n.png")
                #Py.close(id)
            end
        end
    end
end
