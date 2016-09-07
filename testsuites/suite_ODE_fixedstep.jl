function ODEfixedsuites(totest,testsolvers,ntsteps)
  resODEfixed = Dict{Symbol,Dict}()
  for (n,tc) in totest
      res = Dict{Solver,Any}()
      tstepss = [linspace(tc.tspan[1], tc.tspan[2], n) for n in ntsteps]
      for solverfn in testsolvers
          if haskey(Solvers.ODEsolvers, solverfn)
              solver = Solvers.ODEsolvers[solverfn]
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
      end
      resODEfixed[n] = res
  end
  return resODEfixed
end
