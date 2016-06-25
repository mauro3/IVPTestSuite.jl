module IVPTestSuite
# Differential equation initial value problem test suite

import Base: +, -, *, /, .+, .-, .*, ./,==,>,>=

# to dispose of the @doc macro:
if VERSION<v"0.4"
    macro doc(a...)
        if length(a)>1
            esc(a[end])
        else
            esc(a[1].args[end])
        end
    end
end

using Requires

# modules
export Solvers
# variables
export nonstiff, mildlystiff, stiff, explicit_eq, explicit_mass_eq, implicit_eq #, imex_eq
# types
export Stiff, Solver, TestCase, TestCaseExplicit, TestRun, TestSuite, TestResults, @doc,
       TestRunAdapt, TestRunFixedStep
# functions
export isadaptive, isimplicit, isapplicable, isconsistent
export hasjacobian, hasmass, solvertype, name

# some enumerations
abstract Enum
immutable Stiff <: Enum
    val::Int
    function Stiff(i)
        @assert isa(i, Integer)
        @assert 0<=i<=2
        new(i)
    end
end
const nonstiff = Stiff(0)
const mildlystiff = Stiff(1)
const stiff = Stiff(2)

immutable EqType <: Enum # type of equation a solver can handle
    val::Int
    function EqType(i)
        @assert isa(i, Integer)
        @assert 0<=i<=3
        new(i)
    end
end
const explicit_eq = EqType(0)            # dy/dt = F(t, y)
const explicit_mass_eq = EqType(1)       # M(t,y)*dy/dt = F(t, y)
const implicit_eq = EqType(2)            # 0 = F(t, y, dy/dt)
# const imex_eq = EqType(3)                # G(t,y) = F(t, y, dy/dt)

# common enumeration functions
==(s1::Enum, s2::Enum) = s1.val==s2.val
>(s1::Enum, s2::Enum) = s1.val>s2.val
>=(s1::Enum, s2::Enum) = s1.val>=s2.val


# Holds all the constants for a certain test
# TODO: think about also implementing implicitly defined and
# PETSc-style problems
abstract TestCase{Name, T<:Real, Tarr<:AbstractMatrix}
immutable TestCaseExplicit{Name, T, Tarr} <: TestCase{Name,T,Tarr}  # for explicit ODE/DAE equation
    stiff::Stiff          # how stiff the problem is: nonstiff, mildlystiff, stiff
    dae::Int              # index of DAE, ==0 for ODE
    dof::Int              # degrees of freedom
    fn!::Function          # objective function
    jac!::Union{Function,Void}  # Jacobian of fn, can also initialize an array for the Jacobian
    mass!::Union{Function,Void} # mass matrix, can also initialize an array for the mass matrix
    ic::Vector{T}         # Initial condition
    tspan::Vector{T}      # [t_start, t_end]
    refsol::Vector{T}     # reference solution at t=t_end
    refsolinds::Union{BitVector,Vector{Int}}  # which indices of the solution should compared to refsol
    scd_absinds::Union{BitVector,Vector{Int}}   # components for which to use the absolute
                                                # error instead of relative, c.f. calc_error_scd
end
# TODO make:
# immutable TestCaseImplicit{Name, T} <: TestCase  # for implicit ODE/DAE equation

name{Name}(tc::TestCase{Name}) = Name
hasjacobian(tc::TestCase) = (tc.jac!)==nothing ? false : true
Base.issparse{N,T,Tarr}(tc::TestCase{N,T,Tarr}) = Tarr<:AbstractSparseMatrix
hasmass(tc::TestCaseExplicit) = (tc.mass!)==nothing ? false : true
function Base.show(io::IO, tc::TestCase)
    dae = tc.dae>0 ? "DAE" : "ODE"
    st = tc.stiff> nonstiff ? "stiff" : "non-stiff"
    print(io, "Test case \"$(name(tc))\" ($dae, DOF=$(tc.dof), $st)")
end


@doc "Holds information about a solver" ->
immutable Solver{Typ}    # Typ: :ex (explicit method), :im (implicit method), :imex (IMEX method)
    solverfn::Function   # the actual solver
    package::Module      # the package-module where it is defined
    wrapper::Function    # a function (tr::TestRun) ->
    # capabilities:
    stiff::Stiff         # stiff, mildly stiff or non-stiff solver
    adaptive::Bool
    dae::Int             # maximum index of DAE it can solve, ==0 for ODE only
    eq_type::EqType      # dy/dt=F(t,y); M(t,y)*dy/dt=F(t,y); F(t,y,dy/dt)=0
end
isadaptive(s::Solver) = s.adaptive
solvertype{Typ}(s::Solver{Typ}) = Typ
isimplicit(s::Solver) = (solvertype(s)==:im || solvertype(s)==:imex) ? true : false # i.e. uses an implicit method
name(s::Solver) = s.solverfn
function Base.show(io::IO, s::Solver)
    ad = isadaptive(s) ? "adaptive" : "fixed step"
    im = isimplicit(s) ? "implicit" : "explicit"
    dae = s.dae>0 ? "DAE" : "ODE"
    if s.stiff==nonstiff
        st = "non-stiff"
    elseif s.stiff==mildlystiff
        st = "mildly-stiff"
    else
        st = "stiff"
    end
    print(io, "Solver $(name(s)) ($ad, $dae, $st, $im)")
end

# Holds a few extra bits for a specific test run.
abstract TestRun{Name, T<:Real}
immutable TestRunAdapt{Name, T} <: TestRun{Name, T}
    tc::TestCase{Name,T}
    solver::Solver          # which solver to use
    solverpara::Dict{Symbol,Any}  # extra parameters a solver needs for
                                 # a particular TestCase
    abstol::T               # absolute error tolerance
    reltol::T               # relative error tolerance
    h0::T                   # first time step size
end
isadaptive(::TestRunAdapt) = true
_show(tr::TestRunAdapt) = "an adaptive solver using abstol = $(tr.abstol) and reltol = $(tr.reltol)"
immutable TestRunFixedStep{Name, T} <: TestRun{Name, T}
    tc::TestCase{Name,T}
    solver::Solver          # which solver to use
    solverpara::Dict{Symbol,Any} # extra parameters a solver needs for
                                 # a particular TestCase
    tsteps::Vector{T}       # time steps vector
end
isadaptive(::TestRunFixedStep) = false
_show(tr::TestRunFixedStep) = "a fixed step solver using $(length(tr.tsteps)) time steps"


immutable TestSuite{Name, T<:Real}
    tc::TestCase{Name, T}
    solver::Solver                   # which solver to use
    solverpara::Dict{Symbol,Any}     # extra parameters a solver needs for
                                     # a particular TestCase
    abstols::Vector{T}               # absolute error tolerance
    reltols::Vector{T}               # relative error tolerance
    h0s::Vector{T}                   # first time step size
    tstepss::Vector{Vector{T}}       # for non-adaptive steppers set to the steps
    nruns::Int
    adapt::Bool
    function TestSuite(tc, solver, abstols, reltols, h0s; solverpara=Dict{Symbol,Any}())
        # constructor for adaptive solvers
        if !isadaptive(solver)
            error("Constructor `TestSuite{Name,T}(tc::TestCase{Name,T}, solver, abstols, reltols, h0s)` is for adaptive solvers only")
        end
        len = 1
        for v in Any[abstols, reltols, h0s] # then need to be length==1 or same length
            if length(v)>1
                if len>1 && length(v)!=len
                    error("abstols, reltols, and h0s need to be length==1 or same length")
                else
                    len = length(v)
                end
            end
        end
        new(tc, solver, solverpara, abstols, reltols, h0s, Vector{T}[], len, true)
    end
    function TestSuite(tc, solver, tstepss; solverpara=Dict{Symbol,Any}())
        # constructor for fixed step solvers
        if isadaptive(solver)
            error("Constructor `TestSuite{Name,T}(tc::TestCase{Name,T}, solver, tstepss)` is for fixed step solvers only.")
        end
        len = length(tstepss)
        new(tc, solver, solverpara, T[], T[], T[], tstepss, len, false)
    end

end
TestSuite{Name,T}(tc::TestCase{Name,T}, solver, abstols, reltols, h0s; solverpara=Dict{Symbol,Any}() ) = TestSuite{Name,T}(tc, solver, abstols, reltols, h0s; solverpara=solverpara )
TestSuite{Name,T}(tc::TestCase{Name,T}, solver, tstepss; solverpara=Dict{Symbol,Any}() ) = TestSuite{Name,T}(tc, solver, tstepss; solverpara=solverpara )
isadaptive(ts::TestSuite) = ts.adapt

Base.length(ts::TestSuite) = ts.nruns
# make iterator which returns a TestRun for each member in TestSuite
Base.start(ts::TestSuite) = 1
Base.done(ts::TestSuite, state) = length(ts)+1==state ? true : false
function Base.next(ts::TestSuite, state)
    if isadaptive(ts)
        abstol = length(ts.abstols)>1 ? ts.abstols[state] : ts.abstols[1]
        reltol = length(ts.reltols)>1 ? ts.reltols[state] : ts.reltols[1]
        h0 = length(ts.h0s)>1 ? ts.h0s[state] : ts.h0s[1]
        return TestRunAdapt(ts.tc, ts.solver, ts.solverpara, abstol, reltol, h0), state+1
    else
        tsteps = ts.tstepss[state]
        if tsteps[1]!=ts.tc.tspan[1] ||  tsteps[end]!=ts.tc.tspan[2]
            error("Time interval of tsteps not equal to tspan.")
        end
        return TestRunFixedStep(ts.tc, ts.solver, ts.solverpara, tsteps), state+1
    end
end

@doc "Hold the results from a test run" ->
immutable TestResults{Name,T<:Real}
    testrun::TestRun{Name}
    tend::T   # the returned end-time
    yend::Vector{T}     # the calculated solution.  Needs to be initialized to Array(T,dof)
    steps_total::Int
    steps_accepted::Int
    fn_evals::Int
    jac_evals::Int
    linear_solves::Int
    walltime::Float64 # (s)
    mem::Int # memory allocated (bytes)
    gc_time::Float64 # time used by garbage collode23sector
    scd::Float64  # Error estimate: significant digits, see Mazzia & Magherini p.II-ii
    mescd::Float64  # a variation on scd, see Mazzia & Magherini p.II-ii
    error::Union{Void, Exception} # holds the exception if one occured
end
function Base.show( io::IO, res::TestResults)
    tr = res.testrun
    tc = res.testrun.tc
    so = res.testrun.solver
    scd = round(res.scd, 3)
    wt = round(res.walltime*1000, 3)
    mb = round(res.mem/1e6, 3)
    trdetails = _show(tr)
    print(io,
          """
          Results of TestCase \"$(name(tc))\" solved with $(so.solverfn),
          $trdetails

          Significant digits: $(scd)
          Walltime:           $wt ms
          Memory allocated:   $mb MB
          """)

end


# misc helper functions
name{Name}(t::Union{TestRun{Name}, TestResults{Name}, TestCase{Name}}) = Name

## misc helper funs
include("helpers.jl")

## solvers functions
include("solvers/solvers.jl")

## Running tests
include("running_tests.jl")

## Evaluating tests
include("eval_tests.jl")

## The test cases
include("testcases/testcases.jl")

## Plotting
@require PyPlot include(Pkg.dir()*"/IVPTestSuite/src/plotting.jl") # bug requires full path: https://github.com/one-more-minute/Requires.jl/issues/2

end # module
