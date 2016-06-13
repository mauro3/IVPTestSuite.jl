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
    id = Py.figure()
    colind = 1
    p = 1
    maxscd = 0.0

    # DASSL.jl
    res = resDASSL[n]
    scd = getfield_vec(res, :scd)
    maxscd = max(maxscd, maximum(scd))
    wt = getfield_vec(res, :walltime)
    p2 = Py.semilogy(scd, wt, "-x"*cols[colind])
    make_legend!(leg, res)
    colind +=1

    # # ODE.jl
    rode = resODE[n]
    for (s,res) in rode
        scd = getfield_vec(res, :scd)
        if all(isnan(scd))
            continue
        end
        maxscd = max(maxscd, maximum(scd))
        wt = getfield_vec(res, :walltime)
        p2 = Py.plot(scd, wt, "-o"*cols[rem1(colind,nc)])#
        make_legend!(leg, res)
        colind +=1
    end

    #= Currently, Sundials seems to be deprecated and not working
    #Sundials
    rsun = resSun[n]
    for (s,res) in rsun
        scd = getfield_vec(res, :scd)
        if all(isnan(scd))
            continue
        end
        maxscd = max(maxscd, maximum(scd))
        wt = getfield_vec(res, :walltime)
        #p = W.oplot(scd, wt, "d"*cols[rem1(colind,nc)])#
        p = Py.oplot(scd, wt, "d"*cols[rem1(colind,nc)])#
        make_legend!(leg, res)
        colind +=1
    end
    =#

    Py.legend(leg) #

    # tidy up
    # xl = Py.xlim() # https://github.com/nolta/Winston.jl/issues/196
#    Py.xlim(0,maxscd)

    Py.title("$n")
    Py.xlabel("significant digits")
    Py.ylabel("Walltime (s)")

    Py.display(id)
    Py.savefig(Pkg.dir()*"/IVPTestSuite/testsuites/output/scd-vs-walltime-$n.png")
    Py.close(id)
end

## Fixed step solvers
# significant digits (scd) vs walltime
for (n,tc) in totest
  if tc == totest[:threebody]

    leg = AbstractString[]
    id = Py.figure()
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

    #=
    # And again because otherwise legend doesn't work
    # https://github.com/nolta/Winston.jl/issues/198  (TODO)
    # # ODE.jl
    colind =1
    rode = resODEfixed[n]
    for (s,res) in rode
        scd = getfield_vec(res, :scd)
        if all(isnan(scd))
            continue
        end
        maxscd = max(maxscd, maximum(scd))
        wt = getfield_vec(res, :walltime)
        p = W.oplot(scd, wt, "-"*cols[rem1(colind,nc)])
        colind +=1
    end
    =#
    Py.title("$n (fixed step)")
    Py.xlabel("significant digits")
    Py.ylabel("Walltime (s)")

    Py.display(id)
    Py.savefig(Pkg.dir()*"/IVPTestSuite/testsuites/output/fixedstep-scd-vs-walltime-$n.png")
    Py.close(id)
end
