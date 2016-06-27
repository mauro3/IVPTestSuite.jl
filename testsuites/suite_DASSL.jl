function runsuite_DASSL(test_DASSLsolvers,totest,abstols, reltols)
#dassl = IVPTestSuite.Solvers.allsolvers[DASSL.dasslSolve]
    for (solverfn,solver) in test_DASSLsolvers
        for (n,tc) in totest
            suite = TestSuite(tc, dassl, abstols, reltols, [NaN])
            resDASSL[n] = run_ode_testsuite(suite)
        end
    end
end
