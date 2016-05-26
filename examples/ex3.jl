using IVPTestSuite  # imports ODE, DASSL and Sundials
const S = Solvers # for convenience

# choose test-case (all of them are in IVPTestSuite.tc_all)
tc_name = [:vdpol
           :rober
           :threebody
           :bruss1d
           :chemakzo
           :hires][3]
tc = IVPTestSuite.tc_all[tc_name]

# Pick a solver.  S.allsolvers is the list of all solvers.  Generally
# each family of solvers also has a list.
solver = S.ode_imp_ab

###
# make a TestRun which combines a TestCase with a Solver + some extras:
#Example protocol for Fixed step solvers
tsteps = tc.tspan
tr = TestRunFixedStep(tc, solver, Dict{Symbol,Any}(), tsteps)
# For adaptive solvers use TestRunAdapt instead. See ex1.jl for such a case.

# run it and display results:
re = IVPTestSuite.run_ode_test_throwerror(tr) # This returns a TestResults instance
re = IVPTestSuite.run_ode_test_throwerror(tr) # Run it twice to get accurate timings
show(re)
