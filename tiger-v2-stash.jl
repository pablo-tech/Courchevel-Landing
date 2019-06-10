### REFERENCES
# POMDPs.jl API http://juliapomdp.github.io/POMDPs.jl/latest/api/#POMDPs.state_index
# Tutorial Tiger POMDP http://nbviewer.jupyter.org/github/sisl/POMDPs.jl/blob/master/examples/Tiger.ipynb
# Explicit POMDP http://juliapomdp.github.io/POMDPs.jl/latest/explicit/
# Tiger problem PDF https://www.cs.rutgers.edu/%7Emlittman/papers/aij98-pomdp.pdf
# Tiger problem PPT https://www.techfak.uni-bielefeld.de/~skopp/Lehre/STdKI_SS10/POMDP_tutorial.pdf
# POMDP Simulator https://github.com/JuliaPOMDP/POMDPToolbox.jl

### POMDPS.jl
# The following may be performed prior and separately by own JuliaCommand.jl
importall POMDPs
POMDPs.add("QMDP")                  # Design Under Uncertainty 6.4.1
using QMDP
using SARSOP
using POMDPToolbox

# TODO: remove
# Pkg.clone("https://github.com/sisl/POMDPs.jl.git")
# Pkg.add("POMDPs")
# using POMDPs
# Pkg.add("SARSOP")
# POMDPs.add("QMDP")                  # Design Under Uncertainty 6.4.1
# POMDPs.add("POMDPToolbox")        # implements discrete belief updating
# Pkg.add("Distributions")
# importall POMDPs
# using SARSOP
# using POMDPToolbox


### PROBLEM
# In the tiger POMDP, the agent is tasked with escaping from a room. There are two doors leading out of the room.
# Behind one of the doors is a tiger, and behind the other is sweet, sweet freedom.
# If the agent opens the door and finds the tiger, it gets eaten (and receives a reward of -100).
# If the agent opens the other door, it escapes and receives a reward of 10.
# The agent can also listen. Listening gives a noisy measurement of which door the tiger is hiding behind.
# Listening gives the agent the correct location of the tiger 85% of the time.
# The agent receives a reward of -1 for listening.


### PARTIALLY OBSERVABLE MARKOV DECISION PROBLEM
# definition:
# S: State
# A: Action
# Omega: Observation space
# O: Observation function
# T: Transition
# R: Reward


### WORLD: class
# class
type CatPOMDP <: POMDP{Bool, Symbol, Bool}          # inherits typed POMDP{State, Action, Observation}
    reward_for_listening::Float64                       # -1.0
    reward_for_killed_by_tiger::Float64                 # -100
    reward_for_evading_tiger::Float64                   # 10
    probability_of_listening_correctly::Float64         # 0.85
    discount_factor::Float64                            # 0.95
end

### WORLD: object
# create the world
cat_dp = CatPOMDP(-1.0, -100.0, 10.0, 0.85, 0.95)
POMDPs.discount(pomdp::CatPOMDP) = pomdp.discount_factor


### DISTRIBUTION: probability distribution function
# For a discrete problem, this function returns the state/observation probability
# For policy from SARSOP and QMDP solvers, there is no need to implement a sampling function.
# However, to simulate the policy, the following must be implemented:

## STATE: distribution
type CatStateDistribution
    iterator::Vector{Bool}              # vector with a single state
    probability::Float64                # probability of cat being here
end

# iterator
POMDPs.iterator(state_distribution::CatStateDistribution) = state_distribution.iterator

# probability distribution function
function POMDPs.pdf(state_distro::CatStateDistribution, is_here::Bool)
    if is_here
        return state_distro.probability         # by definition
    else
        return 1.0 - state_distro.probability
    end
end;

# sample generation: assign fixed value
POMDPs.rand(random_number_generator::AbstractRNG, state_distro::CatStateDistribution) = rand(random_number_generator) <= state_distro.probability;

## OBSERVATION: distribution
# type
type CatObservationDistribution
    iterator::Vector{Bool}                  # vector with a single observation
    probability::Float64                    # probability of cat being observed
end

# iterator
POMDPs.iterator(observation_distribution::CatObservationDistribution) = observation_distribution.iterator

# probability distribution function
function POMDPs.pdf(observation_distro::CatObservationDistribution, heard_here::Bool)

    if heard_here
        return observation_distro.probability       # by definition
    else
        return 1.0 - observation_distro.probability
    end
end;

# sample generation: assign fixed value
POMDPs.rand(random_number_generator::AbstractRNG, observation_distro::CatObservationDistribution) = rand(random_number_generator) <= observation_distro.probability;


### STATE SPACE
# http://juliapomdp.github.io/POMDPs.jl/latest/api/#POMDPs.states
# the tiger is either behind the left door or behind the right door.

# state is true, the tiger is behind the left door. If its false, the tiger is behind the right door.
is_left_not_right = true
is_right_not_left = !is_left_not_right
state_space = [is_left_not_right, is_right_not_left]
POMDPs.n_states(::CatPOMDP) = length(state_space)
POMDPs.states(::CatPOMDP) = state_space;

#index
#function POMDPs.state_index(::CatPOMDP, cat_state::Bool)
#    if cat_state.hidden_here  # TODO left/right hidden/not?
#        return 1
#    else
#        return 2
#    end
#end;


### ACTION SPACE
# There are three possible actions our agent can take: open the left door, open the right door, and listen.

# set/get
action_space = [:open_left_door, :open_right_door, :listen_to_doors]
POMDPs.actions(::CatPOMDP) = action_space
POMDPs.n_actions(::CatPOMDP) = length(action_space)
# set/get for a state
POMDPs.actions(pomdp::CatPOMDP, state::Bool) = POMDPs.actions(pomdp)

function POMDPs.action_index(::CatPOMDP, action::Symbol)
    if action==:open_left_door
        return 1
    end
    if action==:open_right_door
        return 2
    end
    return 3    # action==:listen_to_doors
end;

# For own beliefs and update schemes check out https://github.com/JuliaPOMDP/POMDPToolbox.jl


### TRANSITION MODEL: across episodes
# The location of the tiger doesn't change when the agent listens.
# After the agent opens the door, the game episode terminates, and no further reward is earned. (***)

# Resets the problem after opening door; does nothing while playing/listening
function POMDPs.transition(pomdp::CatPOMDP, cat_is_here::Bool, action::Symbol)
    if action==:open_left_door || action==:open_right_door
        probability = 0.5   # reset to uniform/random after game termination: door was opened
    elseif cat_is_here
        probability = 1.0   # here=100% probable
    else
        probability = 0.0
    end
    CatStateDistribution(probability, state_space)
end;



### OBSERVATION SPACE
# The observation space looks similar to the state space.
# State is the truth about our system. observation is potentially false information received about the state.

# There are two possible observations: the agent either hears the tiger behind the left door or behind the right door.
heard_left_not_right = true
heard_right_not_left = !heard_left_not_right
observation_space = [heard_left_not_right, heard_right_not_left]
POMDPs.n_observations(::CatPOMDP) = length(observation_space);

# set/get
POMDPs.observations(::CatPOMDP) = observation_space;
# set/get for a state
POMDPs.observations(pomdp::CatPOMDP, state::Bool) = observations(pomdp);

# index
#function POMDPs.obs_index(::CatPOMDP, obs::Symbol)  # TODO: CatObservation instead of Symbol
#    if obs==:tiger_is_behind_left_door
#        return 1
#    elseif obs==:tiger_is_behind_right_door
#        return 2
#    end
#    error("invalid CatPOMDP observation index: $state")
#end;


### OBSERVATION FUNCTION
# TODO: parametrize
# The observation model captures the uncertaintiy in the agent's listening ability.
# When we listen, we receive a noisy measurement of the tiger's location.
function POMDPs.observation(pomdp::CatPOMDP, cat_state::Bool, action::Symbol)
    if action==:listen_to_doors
        if cat_state.hidden_here
            probability = pomdp.probability_of_listening_correctly
        else
            probability = 1.0 - pomdp.probability_of_listening_correctly
        end
    else
        probability = 0.5   # random/uniform while not listening
    end
    CatObservationDistribution(probability, observation_space)
end;


### REWARD
# -1 for listening at the door
# -100 for encountering the tiger
# +10 for escaping

function POMDPs.reward(pomdp::CatPOMDP, cat_state::Bool, action::Symbol)
    reward = 0.0
    if action==:listen_to_doors
        reward+=pomdp.reward_for_listening
    end
    if action==:open_left_door || action==:open_right_door
        if cat_state.hidden_here
            reward += pomdp.reward_for_killed_by_tiger
        else
            reward += pomdp.reward_for_evading_tiger
        end
    end
    return reward
end

# set/get
POMDPs.reward(pomdp::CatPOMDP, this_state::Bool, action::Symbol, state_prime::Bool) = reward(pomdp, this_state, action);


### BELIEF
# Solvers perform the belief updating.
# All you need to do is define a function that returns an initial distribution over states.
# This distribution needs to support pdf and rand function.

prior_distribution = CatStateDistribution(0.5, state_space)
POMDPs.initial_state_distribution(pomdp::CatPOMDP) = prior_distribution;


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
qmdp_history_simulator = HistoryRecorder(max_steps=14, rng=MersenneTwister(1))
qmdp_simulated_history = simulate(qmdp_history_simulator, cat_dp, qmdp_policy, qmdp_belief_updater, POMDPs.initial_state_distribution(cat_dp))


