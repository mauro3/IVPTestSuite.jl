# First, document and link test case

export vdpol

vdpol = let
    tcname = :vdpol
    T = Float64 # the datatype used
    Tarr = Matrix
    dof = 2 # degrees of freedom
    dae=0
    # stiffness of system, one of the three constants
    stiffness = [nonstiff, mildlystiff, stiff][3]

    mu = 1e3
    eps = 1/mu^2 # rescaled parameter
    function fn!(t,y,dydt)
        # the ode function dydt = f(t,y)
        dydt[1] = y[2]
        prod = 
        dydt[2] = ( (1.0 - y[1]^2)*y[2] - y[1]) / eps
        return nothing
    end
    fn!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_)
    
    function jac!(t,y,dfdy)
        # the Jacobian of f
        #
        # Set to nothing if it is not known
        dfdy[1,1] = 0.0
        dfdy[1,2] = 1.0
        dfdy[2,1] = (-2.0 * y[1]*y[2]-1.0)/eps
        dfdy[2,2] = (1.0 - y[1]^2)/eps
        return nothing
    end
    jac!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_,dof_)  # if the problem is large better return an appropriate sparse matrix

    mass! = nothing
    ic = T[2, 0] # vector of initial conditions
    tspan = T[0, 2] # integration interval
    refsol = T[0.1706167732170483e1, -0.8928097010247975e0] # reference solution at tspan[2]
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

