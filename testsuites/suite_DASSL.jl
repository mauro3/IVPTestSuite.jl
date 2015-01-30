resDASSL = Dict{Symbol,Any}()

dassl = IVPTestSuite.Solvers.dassl
for (n,tc) in IVPTestSuite.tc_all
    suite = TestSuite(tc, dassl, abstols, reltols, [NaN])
    resDASSL[n] = run_ode_testsuite(suite)
end
