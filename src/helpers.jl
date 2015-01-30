@doc """Checks whether a solver is applicable to a test case""" ->
function isapplicable(s::Solver, tc::TestCaseExplicit)
    out = _isapplicable(s,tc)
    if hasmass(tc)
        out = out && s.eq_type>=explicit_mass_eq
    end
    return out
end
function _isapplicable(s::Solver, tc::TestCase)
    out = true
    # stiffness
    out = out && s.stiff >= tc.stiff
    # dae
    out = out && s.dae>=tc.dae
    return out
end
isapplicable(tc::TestCaseExplicit, s::Solver) = isapplicable(s,tc)

# test whether a self consistent test-run:
isconsistent(tr::TestRunAdapt) = isapplicable(tr.solver, tr.tc) && isadaptive(tr)
isconsistent(tr::TestRunFixedStep) = isapplicable(tr.solver, tr.tc) && !isadaptive(tr)
isconsistent(ts::TestSuite) = isapplicable(ts.solver, ts.tc)

# ###
# # saving to files

# function save(res::TestResults)...

# function save(tc::
