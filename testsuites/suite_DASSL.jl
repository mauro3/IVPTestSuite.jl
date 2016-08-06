resDASSL = Dict{Symbol,Any}()

for (n,tc) in totest
    for (solverfn,solver) in S.DASSLsolvers
        suite = TestSuite(tc, dassl, abstols, reltols, [NaN])
        resDASSL[n] = run_ode_testsuite(suite)
    end
end
