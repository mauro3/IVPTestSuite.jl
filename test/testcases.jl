# Running all testcases and checking their performance

#using Compat
using ODE
using DASSL
const S = Solvers

# Test that test-cases produce the same result.  A bit fiddly as
# failures can come from both this package as well as the used ODE
# solver.

atols = [1e-6]
rtols = atols

typealias TestDict Dict{Symbol, Dict{Solver, Float64}}
tests = TestDict()
# need at least one entry for each IVPTestSuite.tc_all
tests[:hires]     = Dict(S.allsolvers[ODE.ode23s] => 3.3206089)
tests[:vdpol]     = Dict(S.allsolvers[ODE.ode23s] =>  4.610889958728395)
tests[:threebody] = Dict(S.allsolvers[ODE.ode45_dp]  => 2.3352306868067383) # there was a regression at some point, used to be:  2.6330632171040236)
tests[:rober]     = Dict(S.allsolvers[ODE.ode23s] => 0.8920654209711261) # there was a regression at some point, used to be: 1.4917671146318976)
tests[:bruss1d]   = Dict(S.allsolvers[ODE.ode23s] => 4.068350511153728)
tests[:chemakzo]  = Dict(S.allsolvers[DASSL.dasslSolve]  => 4.352199985825764)
tests[:plei]  = Dict(S.allsolvers[ODE.ode45_dp] => 0)

#@test length(tests)==length(IVPTestSuite.tc_all)

for (name,tc) in IVPTestSuite.tc_all
    println(name)
    for (solver,scd) in tests[name]
        println(solver)
        suite = TestSuite(tc, solver, atols, rtols, [NaN])
        tr = collect(suite)[1]
        re = IVPTestSuite.run_ode_test_throwerror(tr)
        @test abs(re.scd-scd)<1e-3 # pass if less than 0.1% change
    end
end
