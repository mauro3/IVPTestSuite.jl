resDASSL = Dict{Symbol,Any}()

function DASSLsuites(totest,testsolvers,abstols)
  reltols = abstols

  for (n,tc) in totest
      for solverfn in testsolvers
          if haskey(Solvers.DASSLsolvers,solverfn)
              solver = Solvers.DASSLsolvers[solverfn]
              suite = TestSuite(tc, dassl, abstols, reltols, [NaN])
              resDASSL[n] = run_ode_testsuite(suite)
          end
      end
  end

end
