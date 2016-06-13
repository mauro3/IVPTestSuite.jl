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

#@require ODE begin # bug!
import ODE
begin
    ode_only = 0 # dae index
    pkg = "ODE.jl"
#    ode23s = Solver{:im}(ODE.ode23s, stiff)
    # import ODE
    ODEsolvers = Any[]
    sl = 1 # to make it global so it works with eval
    # adaptive non-stiff solvers
    for fn in [:(ODE.ode21),
              :(ODE.ode23),
              :(ODE.ode45_dp),
              :(ODE.ode45_fe),
              :(ODE.ode78),
              :(ODE.ode_ab_adaptive)
              ]
        n = fn.args[2].value
        if fn==:(ODE.ode54)
            stiffness = mildlystiff
        else
            stiffness = nonstiff
        end
        sl = Solver{:ex}(eval(fn), ODE, ODEjl_wrapper, stiffness, adaptive, ode_only, explicit_eq)
        eval(:($n = sl))
        push!(ODEsolvers, sl)
    end
    # fixed step non-stiff solvers
    for fn in [:(ODE.ode4),
              #:(ODE.ode4ms),
              :(ODE.ode_imp_ab) #Implicit Adam Bashforth under construction
              ]
        n = fn.args[2].value
        sl = Solver{:ex}(eval(fn), ODE, ODEjl_wrapper, nonstiff, nonadaptive, ode_only, explicit_eq)
        eval(:($n = sl))
        push!(ODEsolvers, sl)
    end

    # adaptive stiff solvers
    for fn in [#:(ODE.ode23s)
        ]
        n = fn.args[2].value
        fn_str = string(n)
        sl = Solver{:im}(eval(fn), ODE, ODEjl_wrapper, stiff, adaptive, ode_only, explicit_eq)
        eval(:($n = sl))
        push!(ODEsolvers, sl)
    end

    # fixed step stiff solvers
    for fn in [#:(ODE.ode4s),
              #:(ODE.ode4s_s),
              #:(ODE.ode4s_kr)
              ]
        n = fn.args[2].value
        fn_str = string(n)
        sl = Solver{:im}(eval(fn), ODE, ODEjl_wrapper, stiff, nonadaptive, ode_only, explicit_eq)
        eval(:($n = sl))
        push!(ODEsolvers, sl)
    end
    append!(allsolvers, ODEsolvers)
end
