resODE = Dict{Symbol,Dict}()
const S = Solvers

for (n,tc) in totest
    res = Dict{Solver,Any}()
    for (solverfn,solver) in S.ODEsolvers
        if isapplicable(solver, tc) && isadaptive(solver)
            suite = TestSuite(tc, solver, abstols, reltols, [NaN])
            res[solver] = run_ode_testsuite(suite)
        end
    end
    resODE[n] = res
end
