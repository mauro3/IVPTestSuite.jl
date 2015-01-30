# this eats memory 

resSun = Dict{Symbol,Dict}()
const S = Solvers

for (n,tc) in IVPTestSuite.tc_all
    res = Dict{Solver,Any}()
    for solver in S.sundialssolvers
        if solver.solverfn==Sundials.idasol || solver.solverfn==Sundials.cvode
            continue
        end
        if n==:rober # && (solver==Sundials.idasol || solver==Sundials.cvode)
            continue # sundial struggles with rober
        end
        if isapplicable(solver, tc) && isadaptive(solver)
            suite = TestSuite(tc, solver, abstols, reltols, [NaN])
            res[solver] = run_ode_testsuite(suite)
        end
    end
    resSun[n] = res
end
