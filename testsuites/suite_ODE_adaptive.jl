function runsuite_ODEadaptive(test_ODEsolvers,totest,abstols, reltols)
    for (n,tc) in totest
        res = Dict{Solver,Any}()
        for (solverfn,solver) in test_ODEsolvers
            if isapplicable(solver, tc) && isadaptive(solver)
                suite = TestSuite(tc, solver, abstols, reltols, [NaN])
                res[solver] = run_ode_testsuite(suite)
            end
        end
        resODE[n] = res
    end
end
