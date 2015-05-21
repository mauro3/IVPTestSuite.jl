# Astronomy example from Hairer et al 1992 p.129 (see also Szebehely
# 1967): the orbit of a satellite in planet-moon system.  This system
# has know periodic solutions, so called “Arenstorf orbits”
# (Arenstorf, 1963); one of which is used as a test-case.
#
# This is a non-stiff problem.  Adaptive solvers will fare much better
# as there are three regions where the satellite experiences very
# strong acceleration interspersed with regions of very small
# acceleration.

export threebody

threebody = let
    tcname = :threebody
    T = Float64 # the datatype used
    Tarr = Matrix
    dof = 4 # degrees of freedom
    dae=0  # index of DAE, ==0 for ODE
    # stiffness of system, one of the three constants
    stiffness = [nonstiff, mildlystiff, stiff][1] 

    # parameters
    μ = 0.012277471
    μ′ = 1-μ
    
    function fn!(t,y,dydt)
        # the ode function
        
        y1, y2, y1′, y2′ = y[:] # this allocates memory... but less than below
        D1 = ((y1+μ )^2 + y2^2)^(3/2)
        D2 = ((y1-μ′)^2 + y2^2)^(3/2)
        y1″ = y1 + 2*y2′ - μ′*(y1+μ)/D1 - μ*(y1-μ′)/D2
        y2″ = y2 - 2*y1′ - μ′*y2/D1     - μ*y2/D2
        dydt[:] = [y1′, y2′, y1″, y2″] # this allocates memory...
        return nothing
    end
    fn!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_)
    
    jac! = nothing
    mass! = nothing
    
    ic = T[0.994, 0.0, 0.0, -2.00158510637908252240537862224] # vector of initial conditions
    tspan = T[0, 17.0652165601579625588917206249] # integration interval
    refsol = ic # reference solution at tspan[2]
    refsolinds = trues(dof)
    scd_absinds = ic.==0.0
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
    tc_nonstiff[tcname] = tc
end
