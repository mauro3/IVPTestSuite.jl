# This is a sample setup for a test case with an explicit QDE/DAE
# function.  Fill in the ...

# First , document the test case here!

export mytest

# create an instance of TestCaseExplicit by filling in the ...:
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
    
