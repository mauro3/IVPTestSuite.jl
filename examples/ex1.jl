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
solver = S.ode45_dp

# make a TestRun which combines a TestCase with a Solver + some extras:
##Example protocol For adaptive solvers
abstol = 1e-7
reltol = abstol
dt0 = NaN # size of first step
tr = TestRunAdapt(tc, solver, Dict{Symbol,Any}(), abstol, reltol, dt0)

# For fixed step solvers use TestRunFixedStep instead. See ex3.jl for such a case.

# run it and display results:
re = IVPTestSuite.run_ode_test_throwerror(tr) # This returns a TestResults instance
re = IVPTestSuite.run_ode_test_throwerror(tr) # Run it twice to get accurate timings
show(re)
