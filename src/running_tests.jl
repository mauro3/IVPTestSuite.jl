export run_ode_test, run_ode_testsuite

@doc "Runs one ODE TestRun" ->
function run_ode_test{Name}(tr::TestRun{Name}; verbose=true)
    if !isapplicable(tr.tc, tr.solver)
        println("\nTest case $Name not compatible with solver $(tr.solver.solverfn)")
        return nothing
    end

    out, walltime, mem, gc_time = (1,2,3,4) # try makes a new scope?!
    gc()
    try
        out, walltime, mem, gc_time = @timed tr.solver.wrapper(tr)
    catch e
        if verbose
            println("Error occurred: $e")
        end
        return simple_eval(e, tr)
    end
    tend, yend, stats = out
    return simple_eval(tend, yend, stats, walltime, mem, gc_time, tr)
end

function run_ode_test_throwerror{Name}(tr::TestRun{Name})
    if !isapplicable(tr.tc, tr.solver)
        println("\nTest case $Name not compatible with solver $(tr.solver.solverfn)")
        return nothing
    end
    gc()

    #TODO: Add a time out option
    out, walltime, mem, gc_time = @timed tr.solver.wrapper(tr)
    
    tend, yend, stats = out
    return simple_eval(tend, yend, stats, walltime, mem, gc_time, tr)
end


@doc "Runs a suite of ODE TestRun's" ->
function run_ode_testsuite{Name}(suite::TestSuite{Name}; verbose=true, warmup=true, throwerror=false)
    run_fn = throwerror ? run_ode_test_throwerror : run_ode_test
    if !isapplicable(suite.tc, suite.solver)
        println("\nTest case $Name not compatible with solver $(suite.solver.solverfn)")
        return nothing
    end
    if verbose
        println("\nRunning test case $Name with solver $(suite.solver.solverfn)")
    end
    if warmup
        # warmup compiling the function to get accurate timings
        run_fn(first(suite); verbose=false)
    end

    out = TestResults[]
    tot = length(suite)
    for (i,tr) in enumerate(suite)
        if verbose
            print("Running test $i of $tot:")
        end
        # TODO: add something to time out here if too long
        push!(out, run_fn(tr; verbose=verbose))
        if verbose
            sd = out[end].scd
            wt = out[end].walltime
            mem = out[end].mem
            if mem<1e6
                println(" sig. digits= $sd, walltime= $(wt)s, memory= $(mem)bytes")
            else
                mem = round(mem/1e6)
                println(" sig. digits= $sd, walltime= $(wt)s, memory= $(mem)MB")
            end
        end
    end
    out
end
