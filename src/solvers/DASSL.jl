import DASSL  # note this requires current master (Feb 2015)
#@require DASSL begin
begin
    function dassl_wrapper{N,T}(tr::TestRun{N,T})
        # Wraps DASSL.dasslSolve
        tc = tr.tc
        so = tr.solver

        ###
        # 0) Wrap tc.fn!, tc.jac!, tc.mass! if necessary
        if hasmass(tc)
            fn(t,y,dydt) = (m = tc.mass!(); tc.mass!(t,y,m); out = tc.fn!(); tc.fn!(t,y,out); out-m*dydt)
        else
            fn(t,y,dydt) = (out = tc.fn!(); tc.fn!(t,y,out); out-dydt)
        end
        # TODO once DASSL updates interface:
        if hasjacobian(tc)
            Fy(t,y,dydt) = (out = tc.jac!(); tc.jac!(t,y,out); out)
            if hasmass(tc)
                mass = nonmod_mass(tc)
                Fdy(t,y,dydt) = -mass(t,y)
            else
                if issparse(tc)
                    Fdy(t,y,dydt) = -speye(T, tc.dof)
                else
                    Fdy(t,y,dydt) = -eye(T, tc.dof)
                end
             end
            jac(t,y,dydt,a) = Fy(t,y,dydt) + a*Fdy(t,y,dydt)
        end
        ###
        # 1) Make call signature
        args = (fn, tc.ic, tc.tspan)
        if hasjacobian(tc)
            kwargs  = ((:reltol, tr.reltol), (:abstol, tr.abstol), (:jacobian, jac))
        else
            kwargs  = ((:reltol, tr.reltol), (:abstol, tr.abstol))
        end

        ###
        # 2) Call solver, if it does not succeed throw an error (if that
        # is not done anyway)
        (t,y) = so.solverfn(args...; kwargs...)
        # (probably no need to modify this section)

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

    daeindex = 1
    adaptive = true
    dassl = Solver{:im}(DASSL.dasslSolve, DASSL, dassl_wrapper, stiff, adaptive, daeindex, explicit_mass_eq)

    DASSLsolvers = Dict{Any,Solver}()
    DASSLsolvers[DASSL.dasslSolve] = dassl
    
    allsolvers = merge(allsolvers, DASSLsolvers)
end
