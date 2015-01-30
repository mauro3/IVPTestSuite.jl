export simple_eval, getfield_vec, abserror, relerror

abserror(sol, refsol) = abs(sol-refsol)
relerror(sol, refsol) = abs((sol-refsol)./refsol)
abserror(tr::TestResults) = abserror(tr.solution[tr.testrun.tc.refsolinds],
                                     tr.testrun.tc.refsol)
relerror(tr::TestResults) = relerror(tr.solution[tr.testrun.tc.refsolinds],
                                     tr.testrun.tc.refsol)

@doc """Calculates the scd error estimate from Mazzia & Magherini p.II-ii.
        It is the minimum significant correct digits in the solution.
        (Note this is does not work if any component of refsol==0)""" ->
calc_error_scd(sol, refsol) = -log10(norm(relerror(sol,refsol), Inf))

@doc """Same as two argument call but use absolute error instead 
        of relative error at absinds""" ->
function calc_error_scd(sol, refsol, absinds)
    out = relerror(sol,refsol)
    out[absinds] = abserror(sol[absinds],refsol[absinds])
    return -log10(norm(out, Inf))
end
calc_error_scd(sol, tr::TestRun) = calc_error_scd(sol[tr.tc.refsolinds],
                                                 tr.tc.refsol,
                                                 tr.tc.scd_absinds)
calc_error_scd(res::TestResults) = calc_error_scd(res.yend[res.testrun.tc.refsolinds],
                                                 res.testrun.tc.refsol,
                                                 res.testrun.tc.scd_absinds)

@doc """Calculates the mescd error estimate from Mazzia & Magherini p.II-ii. 
        Mixed significant digit of the approximate solution.  (Very similar to 
        the scd error estimate, except when refsol is close to zero?)
        """ ->
function calc_error_mescd(sol, refsol, abstol, reltol)
    -log10( norm( abserror(sol,refsol)./(abstol./reltol + refsol) ,Inf))
end
calc_error_mescd(sol, tr::TestRun) = calc_error_mescd(sol[tr.tc.refsolinds],
                                                      tr.tc.refsol,
                                                      tr.abstol, tr.reltol)
calc_error_mescd(res::TestResults) = calc_error_mescd(res.yend[res.testrun.tc.refsolinds],
                                                     res.testrun.tc.refsol,
                                                     res.testrun.abstol, res.testrun.reltol)

function simple_eval{N,T}(tend::T, yend::Vector{T}, stats, walltime, mem, gc_time, tr::TestRun{N,T})
    tc = tr.tc
    if tend!=tc.tspan[2]
        st = "Integration did not run to specified end time.  tend=$tend but should be $(tc.tspan[2])."
        warn(st)
        e = ErrorException(st)
        return simple_eval(e, tr)
    end
    scd = calc_error_scd(yend, tr)
    #scd = scd<0 ? NaN : scd # return NaN if significant digits less than 0
    if isadaptive(tr)
        mescd = calc_error_mescd(yend, tr)
    else
        mescd = calc_error_mescd(yend[tc.refsolinds], tc.refsol, 1, 1) # 
    end
    #mescd = mescd<0 ? NaN : scd # return NaN if significant digits less than 0
    
    return TestResults(tr, tend, yend, stats..., walltime, mem, gc_time, scd, mescd, nothing)
end
function simple_eval{N,T}(e::Exception, tr::TestRun{N,T})
    return TestResults(tr, tr.tc.tspan[1], T[], -1, -1, -1, -1, -1,     NaN,  -1,    NaN, NaN, NaN, e)
end

@doc """For getting metrics (or any field out of) out of an Vector filled with
        one type having fields""" ->
function getfield_vec(trs::Vector, field::Symbol)
    tr = trs[1]
    out = zeros(typeof(tr.(field)), length(trs))
    for (i,tr) in enumerate(trs)
        out[i] = tr.(field)
    end
    out 
end
