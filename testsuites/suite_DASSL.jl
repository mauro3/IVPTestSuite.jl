resDASSL = Dict{Symbol,Any}()

dassl = IVPTestSuite.Solvers.allsolvers[DASSL.dasslSolve]
for (n,tc) in totest
    suite = TestSuite(tc, dassl, abstols, reltols, [NaN])
    resDASSL[n] = run_ode_testsuite(suite)
end
