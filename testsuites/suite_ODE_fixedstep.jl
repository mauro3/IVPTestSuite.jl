function runsuite_ODEfixed(test_ODEsolvers,totest,ntsteps)
    for (n,tc) in totest
        res = Dict{Solver,Any}()
        tstepss = [linspace(tc.tspan[1], tc.tspan[2], n) for n in ntsteps]
        for (solverfn,solver) in test_ODEsolvers
            if isapplicable(solver, tc) && !isadaptive(solver)
                if name(tc)==:bruss1d
                    # 10^5 steps take more than 10 min to run, skip:
                    suite = TestSuite(tc, solver, tstepss[ntsteps.<50_000])
                else
                    suite = TestSuite(tc, solver, tstepss)
                end
                res[solver] = run_ode_testsuite(suite)
            end
        end
        resODEfixed[n] = res
    end
end
