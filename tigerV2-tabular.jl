### POMDPS.jl
# The following may be performed prior and separately by own JuliaCommand.jl
importall POMDPs
POMDPs.add("QMDP")                  # Design Under Uncertainty 6.4.1
POMDPs.add("SARSOP")                  # Design Under Uncertainty 6.4.1
using QMDP
using SARSOP
using POMDPToolbox
using POMDPModels


# write out the matrix forms

# REWARDS
R = [-1. -100 10; -1 10 -100] # |S|x|A| state-action pair rewards

# TRANSITIONS
T = zeros(2,3,2) # |S|x|A|x|S|, T[s', a, s] = p(s'|a,s)
T[:,:,1] = [1. 0.5 0.5; 0 0.5 0.5]
T[:,:,2] = [0. 0.5 0.5; 1 0.5 0.5]

# OBSERVATIONS
O = zeros(2,3,2) # |O|x|A|x|S|, O[o, a, s] = p(o|a,s)
O[:,:,1] = [0.85 0.5 0.5; 0.15 0.5 0.5]
O[:,:,2] = [0.15 0.5 0.5; 0.85 0.5 0.5]

discount = 0.95
cat_dp = DiscretePOMDP(T, R, O, discount)

# solve the POMDP the same way
# solver = QMDPSolver()
# policy = solve(solver, pomdp)


############################################## QPMD

### SOLVER: QMDP
@requirements_info QMDPSolver() cat_dp

qmdp_policy = solve(QMDPSolver(max_iterations=50, tolerance=1e-3), cat_dp, verbose=true)
println("QMDP_POLICY: \n", qmdp_policy)
qmdp_belief_updater = updater(qmdp_policy)
println("QMDP_UPDATE_BELIEF: \n", qmdp_belief_updater)

### POLICY: QMDP
print("QMDP_POLICY_ALPHAS: \n", qmdp_policy.alphas, "\n\n")
qmdp_belief_test = DiscreteBelief(2); # initial uniform over two states
qmdp_action_test = action(qmdp_policy, qmdp_belief_test)
println("QMDP_TEST_BELIEF=", qmdp_belief_test, " ==> ACTION=", qmdp_action_test, "\n")

### SIMULATION: QMDP
# simulate{S,A,O,B}(simulator::Simulator, problem::POMDP{S,A,O}, policy::Policy{B}, updater::Updater{B}, initial_belief::B)
# simulate{S,A}(simulator::Simulator, problem::MDP{S,A}, policy::Policy, initial_state::S)
# http://juliapomdp.github.io/POMDPs.jl/latest/api/#POMDPs.simulate
qmdp_history_simulator = HistoryRecorder(max_steps=14)  # , rng=MersenneTwister(1)
qmdp_simulated_history = simulate(qmdp_history_simulator, cat_dp, qmdp_policy, qmdp_belief_updater, POMDPs.initial_state_distribution(cat_dp))


############################################## SIMULATE
t=1
for (s, b, a, r, sp, o) in qmdp_simulated_history
    println("t=",t, "\t", "s=$s, b=$(b.b), a=$a, o=$o, r=$r", "\n")
    #state = state_name[s]
    #println("\t(b,s) believe_where[L,R]=$(b.b) <==> actually_where=", s)
    t+=1
    #println("t=",t)
    #println("\t(a)=", a)
    #println("\t(o)=", o)
end

