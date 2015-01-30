typealias TCDict Dict{Symbol, TestCase}

# put test cases into buckets
tc_all = TCDict()
tc_nonstiff = TCDict()
tc_stiff = TCDict()
tc_dae = TCDict()
tc_dae1 = TCDict() # index 1
tc_dae2 = TCDict() # index 2
tc_pde = TCDict() # stemming from discretized PDEs
tc_ide = TCDict() # implicit differential equations 

# # problems with implicit equation
# tc_impl_stiff = TCDict()
# tc_impl_dae = TCDict()

# # non-stiff ODEs
include("threebody.jl")

# # stiff odes
include("hires.jl")
include("rober.jl")
include("vdpol.jl")
include("bruss1d.jl")

# # DAEs index 1
include("chemakzo.jl")

