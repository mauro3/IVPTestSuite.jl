# Robertson chemical reaction:
#
# Adapted from
# http://www.unige.ch/~hairer/testset/testset.html
# reference solution from
# http://www.dm.uniba.it/~testset/problems/rober.php
#
# See also:
# http://octave.sourceforge.net/odepkg/function/odepkg_testsuite_robertson.html
#
# Note that this runs over large tspan = [0,1e11] with the first step being < 1!

export rober

rober = let
    tcname = :rober
    T = Float64 # the datatype used
    Tarr = Matrix
    dof = 3 # degrees of freedom
    dae=0
    # stiffness of system, one of the three constants
    stiffness = [nonstiff, mildlystiff, stiff][3] 
    function fn!(t,y,dydt)
        # the ode function
        dydt[1] = -0.04*y[1] + 1.0e4*y[2]*y[3]
        dydt[3] = 3.0e7 *y[2]*y[2]
        dydt[2] = -dydt[1]-dydt[3]
        nothing
    end
    # initializes storage for y:
    fn!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_)
    
    function jac!(t,y,dfdy)
        # the Jacobian of f
        prod1 = 1.0e4*y[2]
        prod2 = 1.0e4*y[3]
        prod3 = 6.0e7*y[2]
        dfdy[1,1] = -0.04
        dfdy[1,2] = prod2
        dfdy[1,3] = prod1
        dfdy[2,1] = 0.04
        dfdy[2,2] = -prod2-prod3
        dfdy[2,3] = -prod1
        dfdy[3,1] = 0.0
        dfdy[3,2] = prod3
        dfdy[3,3] = 0.0
        return nothing
    end
    jac!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_,dof_)  # if the problem is large better return an appropriate sparse matrix

    # mass matrix M(t,y) dydt = f(t,y)
    mass! = nothing
    
    ic = T[1,0,0] # vector of initial conditions
    tspan = T[0, 1e11] # integration interval
    refsol = T[0.2083340149701255e-07,
               0.8333360770334713e-13,
               0.9999999791665050] # reference solution at tspan[2]
    refsolinds = trues(dof)
    scd_absinds = falses(dof)
    
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

    tc_all[tcname] = tc
    tc_stiff[tcname] = tc
end
    
