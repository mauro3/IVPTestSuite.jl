# plots the suites ran with runsuites.jl and saves plots to output/

cols = split("ymcrgbk","")
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
    #id = W.figure()
    id = Py.figure()
    #W.hold(true)
    colind = 1
    p = 1
    maxscd = 0.0


    # # ODE.jl
    rode = resODE[n]
    for (s,res) in rode
        scd = getfield_vec(res, :scd)
        if all(isnan(scd))
            continue
        end
        maxscd = max(maxscd, maximum(scd))
        wt = getfield_vec(res, :walltime)
        #p = W.oplot(scd, wt, "o"*cols[rem1(colind,nc)])#
        p2 = Py.plot(scd, wt, "-o"*cols[rem1(colind,nc)])#
        make_legend!(leg, res)
        colind +=1
    end

    Py.legend(leg) #


    Py.title("$n")
    Py.xlabel("significant digits")
    Py.ylabel("Walltime (s)")

    Py.display(id)
    Py.savefig(Pkg.dir()*"/IVPTestSuite/testsuites/output/scd-vs-walltime-adaptive-ODE-$n.png")
    #Py.close(id)
end
