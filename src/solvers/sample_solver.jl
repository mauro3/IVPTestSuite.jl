# Need to create an instance of IVPTestSuite.Solver such that it can
# be called. This includes:
#
# - specify the call signature
# - transform fn!, jac! and mass! such that the solver can use it.

# should have it in a @require block but that doesn't currently work
# https://github.com/one-more-minute/Requires.jl/issues/1

# @require MyOdeSolver begin

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

# end # @require MyOdeSolver begin
