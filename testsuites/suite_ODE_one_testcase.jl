resODEfixed = Dict{Symbol,Dict}()
const S = Solvers

for (n,tc) in totest
    if tc == totest[:threebody]
    res = Dict{Solver,Any}()
    tstepss = [linspace(tc.tspan[1], tc.tspan[2], n) for n in ntsteps]
    for solver in S.ODEsolvers
        if isapplicable(solver, tc) && !isadaptive(solver)
            suite = TestSuite(tc, solver, tstepss)
            res[solver] = run_ode_testsuite(suite)
        end
    end
    resODEfixed[n] = res
    end
end
