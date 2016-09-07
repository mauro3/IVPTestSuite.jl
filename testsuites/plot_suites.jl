################################################################################
# Test Suite: Plot results from last test suite run
################################################################################
import PyPlot
const Py = PyPlot
totest = IVPTestSuite.tc_all

function plotsuites()
    plotadaptivesuites()
    plotfixedsuites()
end

#TODO: Use ColorMaps to get arbritary number of well spaced colors
cols = split("ymcrgbk","")
#push!(cols, )
nc = length(cols)


function make_legend!(leg, res)
    str = string(name(res[1].testrun.solver))
    str = replace(str, "_", "\\_")
    push!(leg, str)
end

# plots the suites ran with runsuites.jl and saves plots to output/

function plotadaptivesuites()

    ## Adaptive steppers
    # significant digits (scd) vs walltime
    for (n,tc) in totest
        #id = Py.figure(figsize=(50,50),dpi=130)
        leg = AbstractString[]
        id = Py.figure()
        colind = 1
        p = 1
        maxscd = 0.0

        # DASSL.jl
        if haskey(resDASSL,n)
            res = resDASSL[n]
            scd = getfield_vec(res, :scd)
            maxscd = max(maxscd, maximum(scd))
            wt = getfield_vec(res, :walltime)
            p2 = Py.semilogy(scd, wt, "-x"*cols[colind])
            make_legend!(leg, res)
            colind +=1
        end

        # ODE.jl
        if haskey(resODE,n)
            rode = resODE[n]
            for (s,res) in rode
                scd = getfield_vec(res, :scd)
                if all(isnan(scd))
                    continue
                end
                maxscd = max(maxscd, maximum(scd))
                wt = getfield_vec(res, :walltime)
                p2 = Py.semilogy(scd, wt, "-o"*cols[rem1(colind,nc)])
                make_legend!(leg, res)
                colind +=1
            end
        end

        #Sundials
        if haskey(resSun,n)
            rsun = resSun[n]
            for (s,res) in rsun
                scd = getfield_vec(res, :scd)
                if all(isnan(scd))
                    continue
                end
                maxscd = max(maxscd, maximum(scd))
                wt = getfield_vec(res, :walltime)
                @show cols[rem1(colind,nc)]
                p = Py.semilogy(scd, wt, "-d"*cols[rem1(colind,nc)])
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
            #Py.display(id)
            Py.savefig(Pkg.dir()*"/IVPTestSuite/testsuites/output/adaptive-scd-vs-walltime-$n.png")
            #Py.close(id)
        end
    end

end

function plotfixedsuites()

    ## Fixed step solvers
    # significant digits (scd) vs walltime
    if isdefined(:resODEfixed)
        for (n,tc) in totest
            if haskey(resODEfixed,n)
                leg = AbstractString[]
                id2 = Py.figure(dpi=130)
                colind = 1
                p = 1
                p2 = 1
                maxscd = 0.0


                # # ODE.jl
                rode = resODEfixed[n]
                if length(rode)==0
                    Py.close(id2)
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
                        p2 = Py.semilogy(scd, wt, "-o"*cols[colind],hold = true)
                    end
                    make_legend!(leg, res)
                    colind +=1
                end
            end
            Py.legend(leg)
            Py.title("$n (fixed step)")
            Py.xlabel("significant digits")
            Py.ylabel("Walltime (s)")
            #Py.display(id2)
            Py.savefig(Pkg.dir()*"/IVPTestSuite/testsuites/output/fixedstep-scd-vs-walltime-$n.png")
            #Py.close(id2)
        end
    end
end
