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
    leg = String[]
    id = W.figure()
    #W.hold(true)
    colind = 1
    p = 1
    maxscd = 0.0
    
    # DASSL.jl
    res = resDASSL[n]
    scd = getfield_vec(res, :scd)
    maxscd = max(maxscd, maximum(scd))
    wt = getfield_vec(res, :walltime)
    p = W.semilogy(scd, wt, "x"*cols[colind])
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
        p = W.oplot(scd, wt, "o"*cols[rem1(colind,nc)])
        make_legend!(leg, res)
        colind +=1
    end

    # Sundials
    rsun = resSun[n]
    for (s,res) in rsun
        scd = getfield_vec(res, :scd)
        if all(isnan(scd))
            continue
        end
        maxscd = max(maxscd, maximum(scd))
        wt = getfield_vec(res, :walltime)
        p = W.oplot(scd, wt, "d"*cols[rem1(colind,nc)])
        make_legend!(leg, res)
        colind +=1
    end
    

    W.legend(leg)

    # And again because otherwise legend doesn't work
    # https://github.com/nolta/Winston.jl/issues/198  (TODO)
    
    # DASSL.jl
    colind = 1
    res = resDASSL[n]
    scd = getfield_vec(res, :scd)
    maxscd = max(maxscd, maximum(scd))
    wt = getfield_vec(res, :walltime)
    p = W.oplot(scd, wt, "-"*cols[colind])
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
        p = W.oplot(scd, wt, "-"*cols[rem1(colind,nc)])
        colind +=1
    end

    # Sundials
    rsun = resSun[n]
    for (s,res) in rsun
        scd = getfield_vec(res, :scd)
        if all(isnan(scd))
            continue
        end
        maxscd = max(maxscd, maximum(scd))
        wt = getfield_vec(res, :walltime)
        p = W.oplot(scd, wt, "-"*cols[rem1(colind,nc)])
        colind +=1
    end

    # tidy up
    # xl = W.xlim() # https://github.com/nolta/Winston.jl/issues/196
#    W.xlim(0,maxscd)
    W.title("$n")
    W.xlabel("significant digits")
    W.ylabel("Walltime (s)")
           
    #W.display(p)
    W.savefig("output/scd-vs-walltime-$n.png")
    W.closefig(id)
end

## Fixed step solvers
# significant digits (scd) vs walltime
for (n,tc) in totest
    leg = String[]
    id = W.figure()
    #W.hold(true)
    colind = 1
    p = 1
    maxscd = 0.0
    

    # # ODE.jl
    rode = resODEfixed[n]
    if length(rode)==0
        W.closefig(id)
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
            p = W.semilogy(scd, wt, "o"*cols[colind])
            fst = false
        else
            p = W.oplot(scd, wt, "o"*cols[rem1(colind,nc)])
        end
        make_legend!(leg, res)
        colind +=1
    end

    W.legend(leg)

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

    W.title("$n (fixed step)")
    W.xlabel("significant digits")
    W.ylabel("Walltime (s)")
           
    #W.display(p)
    W.savefig("output/fixedstep-scd-vs-walltime-$n.png")
    W.closefig(id)
end
