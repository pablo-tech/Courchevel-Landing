########
#PROBLEM: WORLD
########
## JULIA
include("courchevel-agent.jl");
## PYTHON
using PyCall
@pyimport imp
@pyimport re
# training gym
filename = abspath(joinpath(dirname(@__FILE__),"traininggym.py"))
@printf("filename: %s\n", filename)

(path,name) = dirname(filename), basename(filename)
#(name,ext) = re.split('.', name)
#(file, filename, data) =
@printf("here: %s", imp.find_module(name,[path]))
#module = imp.load_module(name,file,filename,data)

#@pyimport traininggym
#@printf("Pycall: %f", math.sin(math.pi / 4) - sin(pi / 4))

# stateSpace = CarState[numStates]
#dp = CourchevelWorld(getJackpot(), getData(), CarState[], getDiscount())

### PYCALL
#gym.run()
