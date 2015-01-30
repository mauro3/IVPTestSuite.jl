# Running all testcases and checking their performance

using Compat
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
@compat tests[:hires]     = Dict(S.ode23s => 3.320608915041069)
@compat tests[:vdpol]     = Dict(S.ode23s => 4.611005687023889)
@compat tests[:threebody] = Dict(S.ode45_dp  => 2.6852521523928883) 
@compat tests[:rober]     = Dict(S.ode23s => 1.4917671146318976) # this only works with https://github.com/JuliaLang/ODE.jl/pull/53#issuecomment-72027658
@compat tests[:bruss1d]   = Dict(S.ode23s => 4.069117831988047)
@compat tests[:chemakzo]  = Dict(S.dassl  => 4.352199985825764)

#@test length(tests)==length(IVPTestSuite.tc_all)

for (name,tc) in IVPTestSuite.tc_all
    for (solver,scd) in tests[name]
        suite = TestSuite(tc, solver, atols, rtols, [NaN])
        tr = collect(suite)[1]
        re = IVPTestSuite.run_ode_test_throwerror(tr)
        @test_approx_eq re.scd scd
    end
end
