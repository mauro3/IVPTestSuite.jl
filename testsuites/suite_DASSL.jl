function DASSLsuites(totest,testsolvers,abstols)
  resDASSL = Dict{Symbol,Any}()
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
  return resDASSL
end
