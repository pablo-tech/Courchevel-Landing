########
# WORLD: application of OpenAi Gym/Universe environments and own ones
# To be solved as a Markov Decision Process, or Partially-Observable Markov Decision Process
########

### INCLUDE
include("courchevel-config.jl");
include("courchevel-state.jl");
include("courchevel-action.jl");
include("courchevel-agent.jl");
include("courchevel-environment.jl");

### POMDPS.jl
# The following may be performed prior and separately by own JuliaCommand.jl
# using POMDPs
importall POMDPs
POMDPs.add("QMDP")                  # Design Under Uncertainty 6.4.1
POMDPs.add("SARSOP")
using QMDP
using SARSOP
using POMDPToolbox
using POMDPModels


############################################ WORLD

type CourchevelDp <: POMDP{TheatreState, PilotAction, PilotObservation}
    is_game_over::Bool
    game_config::GameConfig
    state_space::TheatreState                   # actual state
    action_space::Array{PilotAction}            # actions
    observation_space::TheatreState             # observation of state
    qTable::Matrix{Float64}
end


# game factory
function CourchevelDp(game_config::GameConfig)
    # basic
    is_game_over=false
    # State, Action, Observation
    state_space = TheatreState(game_config)
    action_space = get_action_space()
    observation_space = TheatreState(game_config)
    # Learning
    qTable = Matrix{Float64}(game_config.num_columns*game_config.num_rows,
                    size(action_space, 1))

    return CourchevelDp(is_game_over, game_config,
            state_space, action_space, observation_space,
            qTable)
end

# TODO: observation starts as state?

############################################ STATE TRANSITIONS
function get_state_prime(decision_problem::CourchevelDp, state_of_war::TheatreState, pilot_action::PilotAction)
    allies = state_of_war.ally_state
    for i in 1:decision_problem.game_config.num_columns
        for j in 1:decision_problem.game_config.num_rows

            if allies[i,j].status_code == ALLY_CELL
                # SPACE
                next_y = j
                if pilot_action.action_code == :Up
                    if j > 2
                        next_y = j-1
                    end
                end
                if pilot_action.action_code == :Down
                    if j < decision_problem.game_config.num_rows-1
                        next_y = j+1
                    end
                end

                # TIME
                next_x = i+1
                if next_x > decision_problem.game_config.num_columns-1
                    decision_problem.is_game_over = true
                else
                    allies[next_x,next_y].status_code = ALLY_CELL
                    allies[i,j].status_code = EMPTY_CELL
                    # println("ALLY@ ", i, ",", j)
                end

                return state_of_war
            end
        end
    end
    return state_of_war
end;


### OBSERVATION
function get_current_observation(decision_problem::CourchevelDp, state_of_war::TheatreState)
    # obtain correct observation a % of the time
    # if state_at_door.cat_is_here
    #    # noise impedes listenting
    #    probability = decision_problem.probability_of_listening_correctly
    ## else
    #     probability = 1.0 - decision_problem.probability_of_listening_correctly
    # end
    # door_observation = ObservationAtDoor(state_at_door.door_name, state_at_door.cat_is_here)
    # return ObservationPosteriorDistribution(door_observation, probability)
    return PilotObservation(UNKNOWN_CELL)
 end;


### REWARD
function get_war_reward(decision_problem::CourchevelDp, state_of_war::TheatreState, user_action::PilotAction)

    unit_time_reward = -0.1                     # -0.1 default
    unit_distance_conventional_reward = +100    # +100 default

    unit_distance_nuclear_reward = +10      # TBD

    allies = state_of_war.ally_state

    instant_reward = unit_time_reward

    # TODO: encode lcoation in user_action so iteration is not necessary
    allie_i,allie_j = get_ally_location(decision_problem.state_space)

    # Bomb
    if is_bomb(user_action)
        vertical_distance = decision_problem.game_config.enemy_y - allie_j
        if is_conventional(user_action)
            instant_reward +=  vertical_distance * unit_distance_conventional_reward
        #else
        #    instant_reward +=  vertical_distance^2 * unit_distance_nuclear_reward
        #    #println("NUCLEAR BOMB: ", vertical_distance)
        #    if allie_j == decision_problem.game_config.ceiling_y
        #        decision_problem.is_game_over = true
        #        println("***NUCLEAR GAME OVER: ", vertical_distance)
        #    end
        end
    end

    # Missile
    if is_missile(user_action)
        vertical_distance = allie_j - decision_problem.game_config.enemy_y
        if is_conventional(user_action)
            instant_reward +=  vertical_distance * unit_distance_conventional_reward
        #else
        #    instant_reward +=  vertical_distance^2 * unit_distance_nuclear_reward
        #    println("NUCLEAR MISSILE: ", vertical_distance)
        #    if allie_j == decision_problem.game_config.floor_y
        #        decision_problem.is_game_over = true
        #        println("***NUCLEAR GAME OVER: ", vertical_distance)
        #    end
        end
    end

    if allie_j==decision_problem.game_config.ceiling_y || allie_j==decision_problem.game_config.floor_y
        #decision_problem.is_game_over = true
    end

    ### QLEARNING
    # TODO: use world's algo of choice; move this line to test

    allie_next_j = allie_j
    if allie_j>2 && user_action.action_code == :Up
        allie_next_j = allie_j-1
    end
    if allie_j<decision_problem.game_config.num_rows-1 && user_action.action_code==:Down
        allie_next_j = allie_j+1
    end

    #println("THIS/NEXT COORDINATES: (", allie_i, ",", allie_j, ") => (", allie_i, ",", allie_next_j, ")", " FOR ACTION ", user_action.action_code)

    ### qIndex
    next_state_qindex = q_index(allie_i, allie_next_j,
                                    decision_problem.game_config.num_rows, decision_problem.game_config.num_columns)
    this_state_qindex = q_index(allie_i, allie_j,
                                    decision_problem.game_config.num_rows, decision_problem.game_config.num_columns)

    #println("THIS/NEXT QINDEX: ", this_state_qindex, " => ", next_state_qindex)

    ### next state argmax value
    next_state_bellman_action_index = get_bellman_action_index(decision_problem.qTable, allie_i, allie_next_j,
                                    decision_problem.game_config.num_rows, decision_problem.game_config.num_columns)
    optimal_future_value = decision_problem.qTable[next_state_qindex, next_state_bellman_action_index]

    #println("OPTIMAL FUTURE VALUE: ", optimal_future_value)

    ### factors
    #println("LEARNING/DISCOUNT FACTORS ", decision_problem.game_config.discount_factor, ", ", decision_problem.game_config.learning_rate)
    #println("TRYTHIS ", instant_reward)
    #println("SIZE OF TABLE: ", size(decision_problem.qTable, 1), ", ", size(decision_problem.qTable,2))
    #println("ANDTHIS ", decision_problem.qTable[this_state_qindex, get_action_index(user_action)])

    ### value mix
    learned_value_mix = (decision_problem.game_config.learning_rate) * (instant_reward + decision_problem.game_config.discount_factor * optimal_future_value)
    previous_value_mix = (1-decision_problem.game_config.learning_rate) * (decision_problem.qTable[this_state_qindex, get_action_index(user_action)])

    #println("MIX VALUES: ", learned_value_mix, " WITH ", previous_value_mix)

    ###
    decision_problem.qTable[this_state_qindex, get_action_index(user_action)] =  previous_value_mix + learned_value_mix

    #println(instant_reward, " REWARD UPON ", user_action, " AT (", allie_i, ",", allie_j, ") QLEARNED ", decision_problem.qTable[this_state_qindex, get_action_index(user_action)],  " FROM LEARNED_VALUE ", learned_value_mix, " AND PREVIOUS VALUE ", previous_value_mix)

    return instant_reward
end


### ITERATION
function get_state_observation_reward(decision_problem::CourchevelDp, state_of_war::TheatreState, pilot_action::PilotAction, random_number_generator::AbstractRNG)
    state_prime = get_state_prime(decision_problem, state_of_war, pilot_action)
    observation_on_war = get_current_observation(decision_problem, state_of_war)
    state_action_reward = get_war_reward(decision_problem, state_of_war, pilot_action)
    # println("CURRENT == get_state_observation_reward ", "s=",state_of_war, " a=", pilot_action, " NEXT?==>> ", "sp=", state_of_war, " o=", observation_on_war, observation_on_war, " r= ", state_action_reward)
    (state_prime, observation_on_war, state_action_reward)
end

