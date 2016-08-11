resDASSL = Dict{Symbol,Any}()
const S = Solvers

for (n,tc) in totest
    for solverfn in testSolvers
        if haskey(S.DASSLsolvers,solverfn)
            solver = S.DASSLsolvers[solverfn]
            suite = TestSuite(tc, dassl, abstols, reltols, [NaN])
            resDASSL[n] = run_ode_testsuite(suite)
        end
    end
end
