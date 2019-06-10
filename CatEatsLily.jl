######################################################
############ TRICK OR TREAT? CAT EATS LILY
######################################################
############ THE HUNGRY CAT NEAR DOOR WAITS
############ WITH TEETH GUARDING HOLY GATES
############ ADORNED IN MASTER'S LOVE SHE SMILES
############ BEEN WAITING TO EAT LILY FOR MILES
######################################################

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
POMDPs.add("SARSOP")
using QMDP
using SARSOP
using POMDPToolbox
using POMDPModels

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

############################################## WORLD
### WORLD: state
# one state behind each door
struct StateDoor
    door_name::Symbol
    cat_is_here::Bool
end

# constructor for simulator?
#StateDoor(cat_is_here) = StateDoor("", cat_is_here)
#StateDoor() = StateDoor("", false)
#function StateDoor(state_doors::Vector{StateDoor})
#    state_length = length(state_doors)
#    door_probability = fill(uniform_random_probability, state_length) # vector with 0.5 probability
#    StateDistribution(state_doors, door_probability)
#end

### WORLD: observation
struct ObservationDoor
    door_name::Symbol
    cat_heard_here::Bool
end


### WORLD: class
# class
type CatPOMDP <: POMDP{StateDoor, Symbol, ObservationDoor}          # inherits typed POMDP{State, Action, Observation}
    reward_for_listening::Float64                       # -1.0
    reward_for_killed_by_tiger::Float64                 # -100
    reward_for_evading_tiger::Float64                   # 10
    probability_of_listening_correctly::Float64         # 0.85
    discount_factor::Float64                            # 0.95
end

### WORLD: object
# create the world, default constructor necessary by simmulator
CatPOMDP() = CatPOMDP(-1.0, -100.0, 10.0, 0.85, 0.95)
cat_dp = CatPOMDP()
POMDPs.discount(pomdp::CatPOMDP) = pomdp.discount_factor


# TEST
test_state=StateDoor(:left,true)
test_obs=ObservationDoor(:right,false)
println("STATE: ", test_state)
println("OBSERVATION: ", test_obs)
println("WORLD: ", cat_dp)

############################################## DISTRIBUTION

### STATE DISTRIBUTION: probability distribution function
# For a discrete problem, this function returns the state/observation probability
# For policy from SARSOP and QMDP solvers, there is no need to implement a sampling function.
# However, to simulate the policy, the following must be implemented:

## STATE: distribution
type StateDistribution
    iterator::Vector{StateDoor}          # vector of doors where cat states
    probability::Vector{Float64}         # probability of cat being at door
end

uniform_random_probability = 0.5  # TODO: should be random/uniform with respect to any number of states/observations

# default constructors for simulation
function StateDistribution(state_doors::Vector{StateDoor})
    state_length = length(state_doors)
    door_probability = fill(uniform_random_probability, state_length) # vector with 0.5 probability
    StateDistribution(state_doors, door_probability)
end


# iterator
POMDPs.iterator(state_distribution::StateDistribution) = state_distribution.iterator

# get probability from probability distribution function
function POMDPs.pdf(state_distro::StateDistribution, state_door::StateDoor)
    println("STATE_DISTRO in STATE PDF: ", state_distro)
    doors = state_distro.iterator
    for i = 1:length(doors)
        if state_door.door_name==doors[i].door_name
            probability = state_distro.probability[i]
            println(state_door, " DOOR STATE PROBABILITY ", probability)
            return probability
        end
    end
end;

function POMDPs.pdf(state_distro::StateDistribution, observation_door::ObservationDoor)
    return 0.0 # ObservationDoor are not entries in the state distribution
end

# sample generation: assign fixed value
POMDPs.rand(random_number_generator::AbstractRNG, state_distro::StateDistribution) = rand(random_number_generator) <= uniform_random_probability;

# TEST
test_state_probability = 0.44
test_state_probabilities = [test_state_probability]
test_states=[test_state]
test_state_dist = StateDistribution(test_states, test_state_probabilities)
println("StateDistribution: ", test_state_dist)
println("State PDF: ", POMDPs.pdf(test_state_dist, test_state))


## OBSERVATION DISTRIBUTION: probability distribution function
# type
type ObservationDistribution
    iterator::Vector{ObservationDoor}                 # doors where cat observed
    probability::Vector{Float64}                      # probability of cat being observed at door
end


# iterator
POMDPs.iterator(observation_distribution::ObservationDistribution) = observation_distribution.iterator

# get probability from probability distribution function
function POMDPs.pdf(observation_distro::ObservationDistribution, observation_door::ObservationDoor)
    doors = observation_distro.iterator
    for i = 1:length(doors)
        if observation_door.door_name==doors[i].door_name
            probability = observation_distro.probability[i]
            println(observation_door, " DOOR OBSERVATION PROBABILITY ", probability)
            return probability
        end
    end
end;

# sample generation: assign fixed value
POMDPs.rand(random_number_generator::AbstractRNG, observation_distro::ObservationDistribution) = rand(random_number_generator) <= observation_distro.probability;

# TEST
test_obs_probability = 0.22
test_obs_probabilities = [test_obs_probability]
test_observations=[test_obs]
test_obs_dist = ObservationDistribution(test_observations, test_obs_probabilities)
println("ObservationDistribution: ", test_obs_dist)
println("Observation PDF: ", POMDPs.pdf(test_obs_dist, test_obs))

############################################## STATE

### STATE SPACE
# http://juliapomdp.github.io/POMDPs.jl/latest/api/#POMDPs.states
# the tiger is either behind the left door or behind the right door.
# Our state space is simply an array of the states in the problem.

# list
state_space = [StateDoor(:left, false), StateDoor(:right, false)]   # initially no cat
POMDPs.states(::CatPOMDP) = state_space;
POMDPs.n_states(::CatPOMDP) = length(state_space)

# prior distribution of state
function StatePriorDistribution()
    distribution_length = length(state_space)
    uniform_proability = 1/distribution_length
    distribution_vector = Vector{Float64}(distribution_length)
    for i = 1:distribution_length
        distribution_vector[i]=uniform_proability
    end
    prior_distribution_function = StateDistribution(state_space, distribution_vector)
    println("UNIFORM_STATE_DISTRIBUTION: ", prior_distribution_function)
    return prior_distribution_function
end

# prior distribution of state
function StatePosteriorDistribution(cat_state::StateDoor, probability::Float64)
    probability_remainder = 1 - probability
    others_count = length(state_space) - 1
    others_probability_each = probability_remainder/others_count

    distribution_length = length(state_space)
    distribution_vector = Vector{Float64}(distribution_length)

    for i = 1:distribution_length
        if cat_state.door_name==state_space[i].door_name
           distribution_vector[i]=probability               # main recipient
        else
           distribution_vector[i]=others_probability_each
        end
    end
    posterior_distribution_function = StateDistribution(state_space, distribution_vector)
    println("POSTERIOR_STATE_DISTRIBUTION: ", posterior_distribution_function)
    return posterior_distribution_function
end

#index
function POMDPs.state_index(::CatPOMDP, state_door::StateDoor)
    for i = 1:length(state_space)
        if state_door.door_name==state_space[i].door_name
            println(i, " FOUND: ", state_door, " STATE INDEX TO? ", state_space[i])
            return i
        end
    end
    println("STATE NOT FOUND IN STATE SPACE: ", cat_state, "\t", state_space)
    return 1
end;

# TEST
println("CAT WORLD PRIOR STATE PDF: ", StatePriorDistribution())
println("CAT WORLD POSTERIOR STATE PDF: ", StatePosteriorDistribution(state_space[1], 0.68))
println("STATE INDEX: ", POMDPs.state_index(cat_dp, test_state))

############################################## ACTION

### ACTION SPACE
# There are three possible actions our agent can take: open the left door, open the right door, and listen.

# space
action_space = [:open_left_door, :open_right_door, :listen_to_doors]
POMDPs.actions(::CatPOMDP) = action_space
POMDPs.n_actions(::CatPOMDP) = length(action_space)
# set/get for a stte
POMDPs.actions(pomdp::CatPOMDP, state::StateDoor) = POMDPs.actions(pomdp)

function POMDPs.action_index(::CatPOMDP, action::Symbol)
    for i = 1:length(action_space)
        if action==action_space[i]
            println(i, " FOUND: ", action, " ACTION INDEX TO? ", action_space[i])
            return i
        end
    end
    println("ACTION NOT FOUND IN ACTION SPACE: ", action)
    return 1
end;


# For own beliefs and update schemes check out https://github.com/JuliaPOMDP/POMDPToolbox.jl


# TEST
println("CAT WORLD ACTION SPACE: ", action_space)
println("ACTION INDEX: ", POMDPs.action_index(cat_dp, :listen_to_doors))

############################################## TRANSITION

### TRANSITION MODEL: across episodes
# The location of the tiger doesn't change when the agent listens.
# After the agent opens the door, the game episode terminates, and no further reward is earned. (***)

# Resets the problem after opening door; does nothing while playing/listening
function POMDPs.transition(pomdp::CatPOMDP, cat_state::StateDoor, action::Symbol)
    if action==:open_left_door || action==:open_right_door
        # TODO: move the cat randomly?
        return StatePriorDistribution()                     # game termination, back to prior: door was opened
    end
    if cat_state.cat_is_here
        return StatePosteriorDistribution(cat_state, 1.0)
    end
    return StatePosteriorDistribution(cat_state, 0.0)
end;

# TEST
println("TRANSITION @TERMINATION: ", POMDPs.transition(cat_dp, test_state, :listen_to_doors))
println("TRANSITION @TERMINATION: ", POMDPs.transition(cat_dp, test_state, :open_right_door))


############################################## OBSERVATION

### OBSERVATION SPACE
# The observation space looks similar to the state space.
# State is the truth about our system. observation is potentially false information received about the state.

# There are two possible observations: the agent either hears the tiger behind the left door or behind the right door.
observation_space = [ObservationDoor(:left, false), ObservationDoor(:right, false)]     # initially no observation
POMDPs.n_observations(::CatPOMDP) = length(observation_space);

# set/get
POMDPs.observations(::CatPOMDP) = observation_space;
# set/get for a state
POMDPs.observations(pomdp::CatPOMDP, state_door::StateDoor) = observations(pomdp);

# index
function POMDPs.obs_index(::CatPOMDP, observation_door::ObservationDoor)
    for i = 1:length(observation_space)
        if observation_door.door_name==observation_space[i].door_name
            println(i, " FOUND: ", observation_door, " OBSERVATION INDEX TO? ", observation_space[i])
            return i
        end
    end
    println("STATE NOT FOUND IN STATE SPACE: ", observation_door, "\t", state_space)
    return 1
end;

# prior distribution of observation
function ObservationPriorDistribution()
    distribution_length = length(observation_space)
    uniform_proability = 1/distribution_length
    distribution_vector = Vector{Float64}(distribution_length)
    for i = 1:distribution_length
        distribution_vector[i]=uniform_proability
    end
    prior_distribution_function = ObservationDistribution(observation_space, distribution_vector)
    println("UNIFORM_OBSERVATION_DISTRIBUTION: ", prior_distribution_function)
    return prior_distribution_function
end

# prior distribution of state
function ObservationPosteriorDistribution(cat_observation::ObservationDoor, probability::Float64)
    probability_remainder = 1 - probability
    others_count = length(state_space) - 1
    others_probability_each = probability_remainder/others_count

    distribution_length = length(state_space)
    distribution_vector = Vector{Float64}(distribution_length)

    for i = 1:distribution_length
        if cat_observation.door_name==observation_space[i].door_name
           distribution_vector[i]=probability               # main recipient
        else
           distribution_vector[i]=others_probability_each
        end
    end
    posterior_distribution_function = ObservationDistribution(observation_space, distribution_vector)
    println("POSTERIOR_OBSERVATION_DISTRIBUTION: ", posterior_distribution_function)
    return posterior_distribution_function
end

### OBSERVATION FUNCTION
# The observation model captures the uncertaintiy in the agent's listening ability.
# When we listen, we receive a noisy measurement of the tiger's location.

function POMDPs.observation(pomdp::CatPOMDP, observation_door::ObservationDoor, action::Symbol)
    # obtain correct observation a % of the time
    if action==:listen_to_doors
        if observation_door.cat_is_here
            probability = pomdp.probability_of_listening_correctly          # noise
        else
            probability = 1.0 - pomdp.probability_of_listening_correctly
        end
        return ObservationPosteriorDistribution(observation_door, probability)
    end
    return ObservationPriorDistribution()
end;

# Return the observation distribution for a state (this method can only be implemented when the observation does not depend on the action)
function POMDPs.observation(pomdp::CatPOMDP, state_door::StateDoor)
    return StateDistribution([state_door], [0.0])
end;


# TEST
println("CAT WORLD PRIOR OBSERVATION PDF: ", ObservationPriorDistribution())
println("CAT WORLD POSTERIOR STATE PDF: ", ObservationPosteriorDistribution(observation_space[1], 0.68))
# println("OBSERVATION INDEX: ", POMDPs.state_index(cat_dp, test_state))

############################################## REWARD

### REWARD
# -1 for listening at the door
# -100 for encountering the tiger
# +10 for escaping

function POMDPs.reward(pomdp::CatPOMDP, door_state::StateDoor, action::Symbol)
    reward = 0.0
    if action==:listen_to_doors
        reward+=pomdp.reward_for_listening
    end
    if action==:open_left_door || action==:open_right_door
        if door_state.cat_is_here
            reward += pomdp.reward_for_killed_by_tiger
        else
            reward += pomdp.reward_for_evading_tiger
        end
    end
    return reward
end

# set/get
POMDPs.reward(pomdp::CatPOMDP, this_state::StateDoor, action::Symbol, state_prime::StateDoor) = reward(pomdp, this_state, action);

# TEST
println("REWARD: ", POMDPs.reward(cat_dp, state_space[1], action_space[1]))


############################################## BELIEF
# In general terms, a belief is something that is mapped to an action using a POMDP policy

### BELIEF
# Solvers perform the belief updating.
# All you need to do is define a function that returns an initial distribution over states.
# This distribution needs to support pdf and rand function.

POMDPs.initial_state_distribution(pomdp::CatPOMDP) = StatePriorDistribution();


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

############################################## SIMULATE: QMDP

### SIMULATION: QMDP
# simulate{S,A,O,B}(simulator::Simulator, problem::POMDP{S,A,O}, policy::Policy{B}, updater::Updater{B}, initial_belief::B)
# simulate{S,A}(simulator::Simulator, problem::MDP{S,A}, policy::Policy, initial_state::S)
# http://juliapomdp.github.io/POMDPs.jl/latest/api/#POMDPs.simulate
qmdp_history_simulator = HistoryRecorder(max_steps=14, rng=MersenneTwister(1))
# removed per Zachary: POMDPs.initial_state_distribution(cat_dp)
# debug here: /Users/pablo/.julia/v0.6/POMDPToolbox/src/simulators/history_recorder.jl
qmdp_simulated_history = simulate(qmdp_history_simulator, cat_dp, qmdp_policy, qmdp_belief_updater, StatePriorDistribution())
# println("Total reward: $(discounted_reward(qmdp_simulated_history)) \n")



############################################## SARSOP: all time favorite, only care about belief states reachable by optimal policy (up to 10k states)

### SOLVER: SARSOP
# No requirements specified
@requirements_info SARSOPSolver() CatPOMDP()

# sarsop_policy = solve(SARSOPSolver(), cat_dp)   # SARSOP Discrete Bayesian Filter http://bigbird.comp.nus.edu.sg/pmwiki/farm/appl/
# println(sarsop_policy)

# sarsop_history_recorder = HistoryRecorder(max_steps=14, rng=MersenneTwister(1))                # history recorder that keeps track of states, observations and beliefs
# belief_updater = updater(sarsop_policy)
# sarsop_simulated_history = simulate(sarsop_history_recorder, cat_dp, qmdp_policy, belief_updater, prior_distribution)

# print("POLICY ALPHAS: \n", policy.alphas, "\n\n")
# sarsop_belief_test = DiscreteBelief(2); # the initial prior
# sarsop_action_test = action(sarsop_policy, sarsop_belief_test)
# println("TEST: BELIEF=", sarsop_belief_test, " ==> ACTION=", sarsop_action_test, "\n")

#println("Total reward: $(discounted_reward(hist)) \n")


############################################## SIMULATE

### SIMULATE
#t=1
#for (s, b, a, r, sp, o) in qmdp_simulated_history
#    println("t=",t, "\t", "s=$s, b=$(b.b), a=$a, o=$o, r=$r", "\n")
#    state = state_name[s]
#    println("\t(b,s) believe_where[L,R]=$(b.b) <==> actually_where=", s)
#    t+=1
#    println("t=",t)
#    println("\t(a)=", a)
#    println("\t(o)=", o)
#end



#for (s, a, o, r) in stepthrough(cat_dp, policy, "s,a,o,r", max_steps=10)
#    println("in state $s")
#    println("took action $o")
#    println("received observation $o and reward $r")
#end




#policy = RandomPolicy(cat_dp)
