resODE = Dict{Symbol,Dict}()
const S = Solvers

for (n,tc) in totest
    res = Dict{Solver,Any}()
    for solverfn in testSolvers
        if haskey(S.ODEsolvers, solverfn)
            solver = S.ODEsolvers[solverfn]
            if isapplicable(solver, tc) && isadaptive(solver)
                suite = TestSuite(tc, solver, abstols, reltols, [NaN])
                res[solver] = run_ode_testsuite(suite)
            end
        end
    end
    resODE[n] = res
end
