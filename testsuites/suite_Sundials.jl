# this eats memory
resSun = Dict{Symbol,Dict}()
const S = Solvers

function runsuite_sundials(test_sundialsolvers,totest,abstols, reltols)
    for (n,tc) in totest
        res = Dict{Solver,Any}()
        for (solverfn,solver) in test_sundialsolvers
            if solverfn==Sundials.idasol || solverfn==Sundials.cvode
                continue
            end
            if isapplicable(solver, tc) && isadaptive(solver)
                suite = TestSuite(tc, solver, abstols, reltols, [NaN])
                res[solver] = run_ode_testsuite(suite)
            end
        end
        resSun[n] = res
    end
end
