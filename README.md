# IVPTestSuite

[![Build Status](https://travis-ci.org/mauro3/IVPTestSuite.jl.svg?branch=master)](https://travis-ci.org/mauro3/IVPTestSuite.jl)

This package implements a bunch of initial value problems (IPV) to
test solvers of ordinary differential equations (ODE) and algebraic
differential equations (DAE).  The idea is to test different solvers
with problems which have well established solutions to see how they
fare in terms of accuracy and speed.  IPV tests have a long tradition
and this package builds on
[Hairer and Wanner's testset](http://www.unige.ch/~hairer/testset/testset.html),
the [Bari IVP testset](http://www.dm.uniba.it/~testset/testsetivpsolvers/),
and the
Octave package [OdePkg](http://octave.sourceforge.net/odepkg/overview.html).

## Test cases

Non-stiff:

- *threebody*: three body problem adapted from
[Hairer et al 1992 p.129](http://scholar.google.ch/scholar?cluster=5155355070846611936&hl=en&as_sdt=0,5)

Stiff:

- *hires*: [HIRES](http://www.dm.uniba.it/~testset/problems/hires.php)
- *rober*: [Robertson's equations](http://www.dm.uniba.it/~testset/problems/rober.php)
- *bruss1d*: [1D Brusselator](http://www.unige.ch/~hairer/testset/testset.html)
- *vdpol*: [Van der Pol's equation](http://www.dm.uniba.it/~testset/problems/vdpol.php)

DAE:

- *chemakzo*: [Chemical Akzo Nobel](http://www.dm.uniba.it/~testset/problems/chemakzo.php)

## Implemented solvers

The following solvers are implemented:

- all of [ODE.jl](https://github.com/JuliaLang/ODE.jl)
- [Sundials.jl](https://github.com/JuliaLang/Sundials.jl), both their
  high-level and low-level interface.  Analytic Jacobians are not supported.
- [DASSL.jl](https://github.com/pwl/DASSL.jl)

Adding support for other solvers is straightforward, see instructions below.

## Results

[Results](results/results.md) for all test cases and solvers are
available and can be run with [sample_runsuite_script.jl](testsuites/sample_runsuite_script.jl).

## Manual

### Running suites using bencmark tools

Benchmark tools have been provided for users who would like to run quick
test suites of certain solvers against certain test cases. This is done using
the `runsuite()` function.

`runsuite()` returns the results of the a configured testsuite, configured with the following keyword arguments
- `testsolvers`: selects which solvers to test. Defaulted to `allsolverfns`
- `testcases`: selects which test problem to run. Defaulted to `[:all]`
- `testabstols`: Range of `abstols` to run adaptive solvers with. Defaulted to `10.0.^(-5:-1:-11)`
- `testntsteps`: Range of `ntsteps` to run adaptive solvers with. Defaulted to `ntsteps = vcat(collect(10.^(1:5)), 500_000)`
- `verbose`: prints out detailed information about accuracy (in scd), walltime and memory usage at each `abstol` or `ntsteps` value for a suite of a given solver on a given test case. Defaulted to `false`
- `progressmeter`: uses ProgressMeter.jl to display progress of a suite of a given solver on a given test case. Defaulted to `false`

We list a few example runs:

Example 1:
```
solvers = [ODE.ode45]
cases = [:plei]
ntsteps = vcat(collect(10.^(1:3)))
abstol = 10.0.^(-5:-1:-8)
results = runsuite(testsolvers = solvers, testcases = cases, testabstols = abstol, testntstepts = ntsteps);
```
Example 2:
```
solvers = allsolverfns
cases = [:all]
abstol = 10.0.^(-5:-1:-10)
results = runsuite(testsolvers = solvers, testcases = cases, testabstols = abstol);
```
Example 3:
```
solvers = [Sundials.idasol, DASSL.dasslSolve, ODE.ode23s]
results = runsuite(testsolvers = solvers, progressmeter = true);
```
Example 4:
```
results = runsuite(testcases = [:plei], verbose = true);
```

The results of these suite cane be easily plotted by calling
```
plotsuite(results)
```

### Running implemented test-cases with supported solvers via the lower interface

[ex1.jl](examples/ex1.jl) shows how to run a single TestCase with a particular solver:
```julia
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

###
# make a TestRun which combines a TestCase with a Solver + some extras:
abstol = 1e-7
reltol = abstol
dt0 = NaN # size of first step
tr = TestRunAdapt(tc, solver, Dict{Symbol,Any}(), abstol, reltol, dt0)
# For fixed step solvers use TestRunFixedStep instead.

# run it and display results:
re = IVPTestSuite.run_ode_test_throwerror(tr) # this returns a TestResults instance
re = IVPTestSuite.run_ode_test_throwerror(tr) # Run it twice to get accurate timings
show(re)
```

Running this should display something similar to:
```
IVPTestSuite/examples >> julia ex1.jl
Results of TestCase "threebody" solved with ode45_dp,
an adaptive solver using abstol = 1.0e-7 and reltol = 1.0e-7

Significant digits: 3.321
Walltime:           0.005 s
Memory allocated:   37.535 MB
```

A suite of runs can be done like shown in [ex2.jl](examples/ex2.jl):
```julia
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

###
# make a TestRun which combines a TestCase with a Solver + some extras:
abstols = 10.0.^(-5:-1:-10)
reltols = abstols
dt0 = NaN # size of first step
suite = TestSuite(tc, solver, abstols, reltols, [NaN])

# running it will display results:
res = run_ode_testsuite(suite)
```
with output:
```
IVPTestSuite/examples >> julia ex2.jl

Running test case threebody with solver ode45_dp
Running test 1 of 6: sig. digits= 1.5646028036079895, walltime= 0.002070255s, memory= 2MB
Running test 2 of 6: sig. digits= 2.6852521523928883, walltime= 0.003092923s, memory= 3MB
Running test 3 of 6: sig. digits= 3.3205562619239024, walltime= 0.004576154s, memory= 4MB
Running test 4 of 6: sig. digits= 4.183658114157622, walltime= 0.029370115s, memory= 6MB
Running test 5 of 6: sig. digits= 5.116400610921819, walltime= 0.009836836s, memory= 10MB
Running test 6 of 6: sig. digits= 6.075275133643523, walltime= 0.016467959s, memory= 18MB
```

Note that errors are caught, ignored and the next test is run.

### Implementing new test-cases

When implementing a new test case a new instance of
`TestCaseExplicit` needs to be created.  Follow the example in
[src/testcases/sample_testcase.jl](src/testcases/sample_testcase.jl)
and the already implemented test cases in
[src/testcases](src/testcases). `sample_testcase.jl`:

```julia
# create an instance of TestCaseExplicit:
mytest = let
    tcname = ...::Symbol # name should be same as variable name (except for upper/lower case)

    T = ... # the datatype used, probably Float64
    Tarr = [Matrix, SparseMatrixCSC][1] # the container datatype used
                                        # for the Jacobian and mass
                                        # matrix, probably Matrix
                                        # (default) or
                                        # SparseMatrixCSC.
    dof = ...::Int # degrees of freedom
    dae = ...::Int  # index of DAE, ==0 for ODE
    # stiffness of system, one of the three constants
    stiffness = [nonstiff, mildlystiff, stiff][...]

    ## the problem function
    function fn!(t::T,y::Vector{T},dydt::Vector{T})
        # The ode function dydt = f(t,y) modifying dydt in-place.
        # Note that all indices of dydt need to be written!
        ...
        return nothing
    end
    # initializes storage for y:
    fn!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_)

    # NOTE, using keyword arguments more intuitively like:
    # fn!( ; T::Type=T, dof=dof) = zeros(T,dof)
    # does not work: https://github.com/JuliaLang/julia/issues/9948

    ## Jacobian of fn
    function jac!(t::T,y::Vector{T},dfdy::Tarr)
        # the Jacobian of fn, inplace
        #
        # Set jac=nothing if it is not known.
        #
        # Note that jac! should write all indices of given in
        # jpattern.
        ...
        return nothing
    end
    # Returns a matrix which can hold the Jacobian of selected
    # type, initialized to zero.  Can also be used to make a
    # Matlab-style JPattern matrix with jac!(Bool)
    jac!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_,dof_)  # if the problem is large better return an appropriate sparse matrix

    ## Mass matrix
    function mass!(t::T,y::Vector{T},m::Tarr)
        # mass matrix:  M(t,y) * dydt = f(t,y)
        #
        # Set to nothing if it is I, i.e. mass=nothing
        ...
        return nothing
    end
    # Returns a matrix which can hold the mass matrix.
    # Can also be used to make a Matlab-style MvPattern matrix with mass!(Bool)
    mass!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_,dof_)  # if the problem is large better return an appropriate sparse matrix

    ic = T[...] # vector of initial conditions
    tspan = T[start, stop] # integration interval
    refsol = T[...] # reference solution at tspan[2]

    refsolinds = trues(dof)   # if refsol does not contain all indices
                              # then specify which indices of the
                              # solution are to be compared to refsol

    scd_absinds = Int[]       # set where refsol is very small or
                              # zero. To avoid it dominating the
                              # relative error

    tc = TestCaseExplicit{tcname, T, Tarr}(
                             stiffness,
                             dae,
                             dof,
                             fn!,
                             jac!,
                             mass!,
                             ic,
                             tspan,
                             refsol,
                             refsolinds,
                             scd_absinds)

    # put into the right buckets
    tc_all[tcname] = tc
    tc_stiff[tcname] = tc
    # Note that the return-result of the last statement of the let
    # block needs to be tc!
    tc
end
```

### Adding new solvers

When implementing a new test case a new instance of
`Solver` needs to be created.  Follow the example in
[src/solvers/sample_solver.jl](src/solvers/sample_solver.jl)
and the already implemented solvers in
[src/solvers](src/solvers). `sample_solver.jl`:

```julia
# Fill in the ...
function wrapped_solver(tr::TestRun)
    # Wraps the specific MyPkg.mysolver such that it works within
    # IVPTestSuite setup.
    tc = tr.tc
    so = tr.solver
    ###
    # 0) Wrap tc.fn!, tc.jac!, tc.mass! if necessary

    ###
    # 1) Make call signature

    args = ...
    kwargs = ...

    ###
    # 2) Call solver, if it does not succeed throw an error (if that
    # is not done anyway)
    out = so.solverfn(args...; kwargs...)  
    # (probably no need to modify this section)

    ###
    # 3) Transform output to conform to standard:
    # tend -- end time reached
    # yend -- solution at tend
    # stats -- statistics, if available: (steps_total,steps_accepted, fn_evals, jac_evals, linear_solves)
    #                         otherwise  (-1, -1, -1, -1, -1)
    ...
    return tend, yend, stats
end

solverfn = ...::Function # the actual solver function, for example ODE.ode23s.
# choose from
typ =  [:ex, :im, :imex][2]                    # Typ: :ex (explicit method), :im (implicit method), :imex (IMEX method)
stiffness = [nonstiff, mildlystiff, stiff][1]  # stiff, mildly stiff or non-stiff solver
adaptive = [true, false][1]                    # is the solver adaptive
daeindex = 0                                   # maximum index of DAE it can solve, ==0 for ODE only
eq_type = [ explicit_eq, explicit_mass_eq, implicit_eq][1] # [dy/dt=F(t,y); M(t,y)*dy/dt=F(t,y); F(t,y,dy/dt)=0]

solverfn = MyPkg.myode
solverpkg = MyPkg

myodesolver = Solver{typ}(solverfn, solverpkg, wrapped_solver, stiffness, adaptive, daeindex, explicit_eq)

push!(allsolvers, myodesolver)
```

# TODO
- check implementation of test-case functions wrt globals

# Licence

IVPTestSuite is under a GNU GENERAL PUBLIC LICENSE Version 2 as parts
were copied from
[OdePkg](http://octave.sourceforge.net/odepkg/overview.html).  If
someone would prefer a MIT/BSD licence, just re-implement the OdePkg
derived files and I will update the licence.
