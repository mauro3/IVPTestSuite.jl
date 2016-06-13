# wraps the solver functions
function ODEjl_wrapper(tr::TestRun)
    tc  = tr.tc
    so = tr.solver
    ###
    # 0) Wrap tc.fn!, tc.jac!, tc.mass! if necessary
    fn = nonmod_fn(tc)
    if hasjacobian(tc)
        jac = nonmod_jac(tc)
    end
    if hasmass(tc)
        error("ODE.jl solvers do not support a mass matrix")
    end

    ###
    # 1) Make call signature
    if isadaptive(so)
        args = (fn, tc.ic, tc.tspan)
        # TODO: also use h0
        kwargs  = ((:reltol, tr.reltol), (:abstol, tr.abstol), (:points, :specified))
        if hasjacobian(tc) && isimplicit(so)
            kwargs  = ((:jacobian, jac), kwargs...)
        end
    else
        args = (fn, tc.ic, tr.tsteps)
        if hasjacobian(tc) && isimplicit(tr.solver)
            kwargs  = ((:jacobian, jac),)
        else
            kwargs  = ()
        end
    end

    ###
    # 2) Call solver, if it does not succeed throw an error (if that
    # is not done anyway)
    (t,y) = so.solverfn(args...; kwargs...)

    ###
    # 3) Transform output to conform to standard:
    # tend -- end time reached
    # yend -- solution at tend
    # stats -- statistics, if available: (steps_total,steps_accepted, fn_evals, jac_evals, linear_solves)
    #                         otherwise  (-1, -1, -1, -1, -1)
    tend = t[end]
    yend = y[end]
    stats = (-1, -1, -1, -1, -1)
    return tend, yend, stats
end

import ODE


##############################################################################
#List of all ODE.jl solvers avaible for testing
##############################################################################
ODE_release =true
ODE_pwl = !ODE_release
if ODE_release
    ## Non-stiff fixed step solvers
    nonstiff_fixedstep= [
               ODE.ode1,
               ODE.ode2_midpoint,
               ODE.ode2_heun,
               ODE.ode4,
               ODE.ode4ms,
               ODE.ode5ms
    #          ODE.ode_imp_ab #Implicit Adam Bashforth under construction
               ]
    ## Non-stiff adaptive step solvers
    nonstiff_adaptive=[
    #          ODE.ode21, # this fails on Travis with 0.4?! TODO revert once fixed.
               ODE.ode23,
               ODE.ode45,
               ODE.ode45_dp,
               ODE.ode45_fe,
               ODE.ode78,
               ODE.ode_ab_adaptive
               ]
    # Stiff fixed-step solvers
    stiff_fixedstep=[
               ODE.ode4s_s,
               ODE.ode4s_kr
               ]
    #Stiff adaptive solvers
    stiff_adaptive = [
               ODE.ode23s
     #          ODE.odeRadauIIA #RADAU methods under construction
               ]
elseif ODE_pwl
    nonstiff_fixedstep= [
               ODE.ode1,
               ODE.ode2_midpoint,
               ODE.ode2_heun,
               ODE.ode4,
               #ODE.ode4ms,
               #ODE.ode5ms
    #          ODE.ode_imp_ab #Implicit Adam Bashforth under construction
               ]

    ## Non-stiff fixed step solvers
    nonstiff_adaptive=[
    #          ODE.ode21, # this fails on Travis with 0.4?! TODO revert once fixed.
               ODE.ode23,
               ODE.ode45,
               ODE.ode45_dp,
               ODE.ode45_fe,
               ODE.ode78
               ]
    # Stiff fixed-step solvers
    stiff_fixedstep=[
               ODE.ode4s_s,
               ODE.ode4s_kr
               ]
    #Stiff adaptive solvers
    stiff_adaptive = [
               ODE.ode23s
     #         ODE.odeRadauIIA #RADAU methods under construction
               ]
end

ode_only = 0 # dae index
pkg = "ODE.jl"
#    ode23s = Solver{:im}(ODE.ode23s, stiff)

ODEsolvers = Dict{Any,Solver}()
sl = 1 # to make it global so it works with eval
# adaptive non-stiff solvers
for fn in nonstiff_adaptive
    sl = Solver{:ex}(fn, ODE, ODEjl_wrapper, nonstiff, adaptive, ode_only, explicit_eq)
    ODEsolvers[fn] = sl
end
# fixed step non-stiff solvers
for fn in nonstiff_fixedstep
    sl = Solver{:ex}(fn, ODE, ODEjl_wrapper, nonstiff, nonadaptive, ode_only, explicit_eq)
    ODEsolvers[fn] = sl
end

# adaptive stiff solvers
for fn in stiff_adaptive
    sl = Solver{:im}(fn, ODE, ODEjl_wrapper, stiff, adaptive, ode_only, explicit_eq)
    ODEsolvers[fn] = sl
end

# fixed step stiff solvers
for fn in stiff_fixedstep
    sl = Solver{:im}(fn, ODE, ODEjl_wrapper, stiff, nonadaptive, ode_only, explicit_eq)
    ODEsolvers[fn] = sl
end
allsolvers = merge(allsolvers, ODEsolvers)
