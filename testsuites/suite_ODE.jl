resODE = Dict{Symbol,Dict}()
const S = Solvers

for (n,tc) in IVPTestSuite.tc_all
    res = Dict{Solver,Any}()
    for solver in S.ODEsolvers
        if isapplicable(solver, tc) && isadaptive(solver)
            suite = TestSuite(tc, solver, abstols, reltols, [NaN])
            res[solver] = run_ode_testsuite(suite)
        end
    end
    resODE[n] = res
end
