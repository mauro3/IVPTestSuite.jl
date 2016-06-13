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
solver = S.allsolvers[ODE.ode45_dp]

###
# make a TestRun which combines a TestCase with a Solver + some extras:
abstols = 10.0.^(-5:-1:-10)
reltols = abstols
dt0 = NaN # size of first step
suite = TestSuite(tc, solver, abstols, reltols, [NaN])

# running it will display some results:
res = run_ode_testsuite(suite)
