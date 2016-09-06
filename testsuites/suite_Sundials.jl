resSun = Dict{Symbol,Dict}()

# this eats memory
function sundialsuites(totest,testsolvers,abstols)
  reltols = abstols

  for (n,tc) in totest
      res = Dict{Solver,Any}()
      for solverfn in testsolvers
          if haskey(Solvers.sundialssolvers, solverfn)
              solver = Solvers.sundialssolvers[solverfn]
              if solverfn==Sundials.idasol || solverfn==Sundials.cvode
                  continue
              end
              if isapplicable(solver, tc) && isadaptive(solver)
                  suite = TestSuite(tc, solver, abstols, reltols, [NaN])
                  res[solver] = run_ode_testsuite(suite)
              end
          end
      end
      resSun[n] = res
  end
end
