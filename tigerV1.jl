# Tutoria Tiger POMDP http://nbviewer.jupyter.org/github/sisl/POMDPs.jl/blob/master/examples/Tiger.ipynb
# Explicit POMDP http://juliapomdp.github.io/POMDPs.jl/latest/explicit/
# Tiger problem PDF https://www.cs.rutgers.edu/%7Emlittman/papers/aij98-pomdp.pdf
# Tiger problem PPT https://www.techfak.uni-bielefeld.de/~skopp/Lehre/STdKI_SS10/POMDP_tutorial.pdf
# Pkg.add("POMDPs")

# Problem Overview
# In the tiger POMDP, the agent is tasked with escaping from a room. There are two doors leading out of the room.
# Behind one of the doors is a tiger, and behind the other is sweet, sweet freedom.
# If the agent opens the door and finds the tiger, it gets eaten (and receives a reward of -100).
# If the agent opens the other door, it escapes and receives a reward of 10.
# The agent can also listen. Listening gives a noisy measurement of which door the tiger is hiding behind.
# Listening gives the agent the correct location of the tiger 85% of the time.
# The agent receives a reward of -1 for listening.

# POMDPs.jl
importall POMDPs
POMDPs.add("QMDP")  # Design Under Uncertainty 6.4.1
using QMDP, POMDPToolbox


type CatPOMDP <: POMDP{Bool, Int64, Bool} # state, action, observation
    discount_factor::Float64
end


### WORLD
CatPOMDP() = CatPOMDP(0.95) # default contructor
discount(pomdp::CatPOMDP) = pomdp.discount_factor


### STATE SPACE
# enum
const CAT_ON_LEFT = true
const CAT_ON_RIGHT = false

# two states, tiger is behind: left/right door
# states are two Bool
state_array = [CAT_ON_LEFT, CAT_ON_RIGHT]
state_name = ["CAT_ON_LEFT", "CAT_ON_RIGHT"]
states(pomdp::CatPOMDP) = state_array

# index

### ACTION SPACE
# enum
const OPEN_LEFT_DOOR = 0
const OPEN_RIGHT_DOOR = 1
const LISTEN_TO_DOORS = 2

# three actions, go: left/right/listen
# actions are each: Int64
action_array = [OPEN_LEFT_DOOR,OPEN_RIGHT_DOOR, LISTEN_TO_DOORS]
action_name = ["OPEN_LEFT_DOOR", "OPEN_RIGHT_DOOR", "LISTEN_TO_DOORS"]
actions(pomdp::CatPOMDP) = action_array

# index
n_actions(pomdp::CatPOMDP) = 3
action_index(::CatPOMDP, a::Int64) = a+1


### OBSERVATION SPACE

const HEARD_CAT_LEFT = true
const HEARD_CAT_RIGHT = false
function observation_name(obs_value::Bool)
    if obs_value==HEARD_CAT_LEFT
        return "HEARD_CAT_LEFT"
    else
        return "HEARD_CAT_RIGHT"
    end
end

# two observations: hear the tiger behind the left/right door
# observations are two Bool
observations(::CatPOMDP) = [HEARD_CAT_LEFT, HEARD_CAT_RIGHT]

# observations are Bool
n_observations(::CatPOMDP) = 2


### DISTRIBUTION
type CatDistribution
    p_cat_there::Float64
end

CatDistribution() = CatDistribution(0.5) # default constructor with prior expectation

iterator(d::CatDistribution) = [true, false]

# returns the probability mass for discrete distributions
function pdf(d::CatDistribution, v::Bool)
    if v
        return d.p_cat_there
    else
        return 1 - d.p_cat_there
    end
end

# sample from the distribution
rand(rng::AbstractRNG, d::CatDistribution) = rand(rng) ≤ d.p_cat_there


### TRANSITION
function transition(pomdp::CatPOMDP, s::Bool, a::Int64)
    d = CatDistribution()
    if a == OPEN_LEFT_DOOR || a == OPEN_RIGHT_DOOR
        d.p_cat_there = 0.5 # reset the tiger's location, which is what QMDP wants
    elseif s == CAT_ON_LEFT
        d.p_cat_there = 1.0 # tiger is on left
    else
        d.p_cat_there = 0.0  # tiger is on right
    end
    d
end


### OBSERVATION
function observation(pomdp::CatPOMDP, a::Int64, sp::Bool)
    distribution = CatDistribution()
    # obtain correct observation 85% of the time
    if a == LISTEN_TO_DOORS
        distribution.p_cat_there = sp == CAT_ON_LEFT ? 0.85 : 0.15
    else
        distribution.p_cat_there = 0.5 # reset the observation - we did not listen
    end
    distribution
end

observation(pomdp::CatPOMDP, s::Bool, a::Int64, sp::Bool) = observation(pomdp, a, sp) # convenience function


### REWARD
# -1 for listening at the door
# -100 for encountering the tiger
# +10 for escaping
function reward(pomdp::CatPOMDP, s::Bool, a::Int64)
    # rewarded for escaping, penalized for listening and getting caught
    r = 0.0
    if a == LISTEN_TO_DOORS
        r -= 1.0 # action penalty
    elseif (a == OPEN_LEFT_DOOR && s == CAT_ON_LEFT) ||
        (a == OPEN_RIGHT_DOOR && s == CAT_ON_RIGHT)
        r -= 100.0 # eaten by tiger
    else
        r += 10.0 # opened the correct door
    end
    r
end
reward(pomdp::CatPOMDP, s::Bool, a::Int64, sp::Bool) = reward(pomdp, s, a) # convenience function


# SOLVER
@requirements_info QMDPSolver() CatPOMDP()


# DO SOLVE
initial_state_distribution(pomdp::CatPOMDP) = CatDistribution(0.5)

cat_dp = CatPOMDP()
solver = QMDPSolver()
policy = solve(solver, cat_dp)
belief_updater = updater(policy) # the default QMDP belief updater (discrete Bayesian filter)

init_dist = initial_state_distribution(cat_dp)

### HISTORY
hist_recorder = HistoryRecorder(max_steps=100) # from POMDPToolbox

# r = simulate(hist_recorder, cat_dp, policy) # run 100 step simulation

### HISTORY REPLAY: stepwise from previously computed history
history = simulate(HistoryRecorder(max_steps=10), cat_dp, policy, belief_updater)

i = 1
for (s, b, a, o) in eachstep(history, "sbao")
    println("t=",i)
    state = state_name[s+1]
    println("\t(b,s) believe_where[L,R]=$b <==> actually_where=", state)
    action = action_name[a+1]
    println("\t(a)=", action)
    observation = observation_name(o)
    println("\t(o)=", observation)
    i+=1
end
println("Discounted reward was $(discounted_reward(history)).")


# t=1
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.5, 0.5]) <==> actually_where=CAT_ON_RIGHT
# (a)=LISTEN_TO_DOORS
# (o)=HEARD_CAT_LEFT
# t=2
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.15, 0.85]) <==> actually_where=CAT_ON_RIGHT
# (a)=LISTEN_TO_DOORS
# (o)=HEARD_CAT_LEFT
# t=3
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.0302013, 0.969799]) <==> actually_where=CAT_ON_RIGHT
# (a)=OPEN_RIGHT_DOOR
# (o)=HEARD_CAT_RIGHT
# t=4
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.5, 0.5]) <==> actually_where=CAT_ON_RIGHT
# (a)=LISTEN_TO_DOORS
# (o)=HEARD_CAT_LEFT
# t=5
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.15, 0.85]) <==> actually_where=CAT_ON_RIGHT
# (a)=LISTEN_TO_DOORS
# (o)=HEARD_CAT_LEFT
# t=6
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.0302013, 0.969799]) <==> actually_where=CAT_ON_RIGHT
# (a)=OPEN_RIGHT_DOOR
# (o)=HEARD_CAT_RIGHT
# t=7
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.5, 0.5]) <==> actually_where=CAT_ON_LEFT
# (a)=LISTEN_TO_DOORS
# (o)=HEARD_CAT_RIGHT
# t=8
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.85, 0.15]) <==> actually_where=CAT_ON_LEFT
# (a)=LISTEN_TO_DOORS
# (o)=HEARD_CAT_RIGHT
# t=9
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.969799, 0.0302013]) <==> actually_where=CAT_ON_LEFT
# (a)=OPEN_LEFT_DOOR
# (o)=HEARD_CAT_LEFT
# t=10
# (b,s) believe_where[L,R]=POMDPToolbox.DiscreteBelief([0.5, 0.5]) <==> actually_where=CAT_ON_LEFT
# (a)=LISTEN_TO_DOORS
# (o)=HEARD_CAT_RIGHT
# Discounted reward was 17.711453841447263.
