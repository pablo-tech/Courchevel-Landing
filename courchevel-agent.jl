########
# AGENT: agent of OpenAi Gym/Universe environments and own ones
########

### INCLUDE
include("courchevel-config.jl");
include("courchevel-state.jl");
include("courchevel-action.jl");

###
using PyCall
@pyimport numpy


############################################ CONFIGURATION

#mutable struct AgentConfig
#end

#function AgentConfig()
#    return AgentConfig(discount_factor, epsilon_greedy)
#end


############################################ AGENT

function get_agent_space()
    return [:Recon, :Bomber, :Fighter]
end

type CourchevelAgent
    is_alive::Bool
    # agent_config::AgentConfig
    agent_type::Symbol
    agent_id::Int64
    # location_y::Int64
end

# class constructor with default values
function CourchevelAgent(game_config::GameConfig, agent_type::Symbol, agent_id)
    return CourchevelAgent(true, # AgentConfig(),
        agent_type, agent_id)
end

############################################ LOCATION

# Allie location in 2 dimensional (row x col) board
function get_ally_location(state_of_war::TheatreState)
    ally_state = state_of_war.ally_state
    # println("ROWSCOLS ", size(ally_state, 2), " ", size(ally_state, 1))
    ally_x = 1
    ally_y = 1
    for i in 1:size(ally_state, 1)
        for j in 1:size(ally_state, 2)
            if ally_state[i,j].status_code == ALLY_CELL
                ally_x = i
                ally_y = j
            end
        end
    end

    return (ally_x, ally_y)
end

# row location in qTable (i/j, action)
function q_index(i, j, num_rows, num_columns)
    the_index = i + j*num_rows
    #println(the_index, " QINDEX @ij=", i, ",", j, " OUT OF ", num_rows, " x ", num_columns)
    return the_index
end


############################################ ACTION

### BELLMAN ACTION
function get_bellman_action_index(qTable::Matrix{Float64},
            i::Int64, j::Int64,
            num_rows::Int64, num_columns::Int64)

    q_table_index =q_index(i, j, num_rows, num_columns)

    choice_action_index = 1
    max_action_value = 0.

    first_value = qTable[q_table_index, choice_action_index]
    action_count = size(qTable,2)

    for act_index in 2:action_count
        if qTable[q_table_index, act_index] > max_action_value
            max_action_value = qTable[q_table_index, act_index]
            choice_action_index = act_index
        end
    end

    #println("BELLMAN ACTION INDEX ", choice_action_index,
    #    " FOR (t,y)=(", i, ",", j,")")

    return choice_action_index
end



### BELLMAN VS EXPLORATORY
function get_base_action(agent_pilot::CourchevelAgent,
    qTable::Matrix{Float64}, epsilon_greedy::Float64,
    state_of_war::TheatreState,
    num_rows::Int64, num_columns::Int64)

    selected_action = PilotAction(:Hold)

    # explore
    if rand() < epsilon_greedy
        random_index = rand(1:length(get_action_space()))
        selected_action = get_action_space()[random_index]

    # exploit
    else
        ally_x,ally_y = get_ally_location(state_of_war)

        bellman_index = get_bellman_action_index(qTable,
                                ally_x, ally_y,
                                num_rows, num_columns)

        selected_action = get_action_space()[bellman_index]
    end

    #println("SELECTED ", selected_action,
    #    " FOR AGENT TYPE ", agent_pilot.agent_type)
    return selected_action
end


### BIAS ACTION
function get_biased_action(agent_pilot::CourchevelAgent,
                selected_action::PilotAction)

    final_action = selected_action

    bomber_up_bias = 0.9  # 0.9 default
    figther_down_bias = 0.9 # 0.9 default

    # bomber biased up
    if agent_pilot.agent_type == :Bomber
        if final_action.action_code == :Down
            if rand() < bomber_up_bias
                final_action = PilotAction(:Up)
            end
        end
    end

    # fighter biased down
    if agent_pilot.agent_type == :Fighter
        if final_action.action_code == :Up
            if rand() < figther_down_bias
                final_action = PilotAction(:Down)
            end
        end
    end

    # recon is unbiased

    return final_action
end

### TEST: AGENT
#recon_agent = CourchevelAgent(config, :Bomber, 999999) # default q learner
#bomber_agent = CourchevelAgent(config, :Bomber, 999998)
#fighter_agent = CourchevelAgent(config, :bomber, 999997)
#println("AGENT TEST ", recon_agent)
