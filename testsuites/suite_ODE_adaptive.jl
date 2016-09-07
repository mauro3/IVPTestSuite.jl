
function ODEsuites(totest,testsolvers,abstols)
  resODE = Dict{Symbol,Dict}()
  reltols = abstols
  for (n,tc) in totest
      res = Dict{Solver,Any}()
      for solverfn in testsolvers
          if haskey(Solvers.ODEsolvers, solverfn)
              solver = Solvers.ODEsolvers[solverfn]
              if isapplicable(solver, tc) && isadaptive(solver)
                  suite = TestSuite(tc, solver, abstols, reltols, [NaN])
                  res[solver] = run_ode_testsuite(suite)
              end
          end
      end
      resODE[n] = res
  end
return resODE
end
