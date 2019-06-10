### TEST: WORLD CEILING
function calculate_ceiling(num_rows, num_columns)
    ceiling_fraction = 3
    ceiling_y = trunc(Int, num_rows/ceiling_fraction)
    # print("CEILING ", ceiling_y, " FROM ", num_rows, ",", num_columns)
    min_ceiling = 2
    if ceiling_y>min_ceiling
        return rand(min_ceiling: ceiling_y)
    end
    return min_ceiling
end

### TEST: WORLD FLOOR
function calculate_floor(num_rows, num_columns)
    floor_fraction = 5
    floor_y = trunc(Int, num_rows-num_rows/floor_fraction)
    i = rand(floor_y: num_rows-1)
    return i
end

############################################ CONFIGURATION

# config: class
mutable struct GameConfig
    env_name::String                # openAi/own environment
    num_rows::Int64
    num_columns::Int64
    ceiling_y::Int64
    floor_y::Int64
    enemy_y::Int64
    learning_rate::Float64
    discount_factor::Float64
    epsilon_greedy::Float64
    reward_per_time::Float64
    reward_per_distance::Float64
end

function copy(game_config::GameConfig)
    GameConfig(game_config.env_name, game_config.num_rows, game_config.num_columns,
        game_config.ceiling_y, game_config.floor_y, game_config.enemy_y,
        game_config.learning_rate, game_config.discount_factor, game_config.epsilon_greedy,
        game_config.reward_per_time, game_config.reward_per_distance)
end

# config: constructor
function GameConfig(num_rows, num_columns,
        learning_rate, discount_factor, epsilon_greedy,
        reward_per_time, reward_per_distance)
    env_name="Courchevel-V0"
    # calculated: y coordinates
    ceiling_y = calculate_ceiling(num_rows, num_columns)
    floor_y = calculate_floor(num_rows, num_columns)
    enemy_y = rand(ceiling_y+1: floor_y-1)

    return GameConfig(env_name, num_rows, num_columns,
        ceiling_y, floor_y, enemy_y,
        learning_rate, discount_factor, epsilon_greedy,
        reward_per_time, reward_per_distance)
end

# config: print
function to_string(game_config::GameConfig)
    config = string("name=", game_config.env_name, " ")
    config = string(config, "num_rows=", game_config.num_rows, " ")
    config = string(config, "num_rows=", game_config.num_rows, " ")
    config = string(config, "num_columns=", game_config.num_columns, " ")
    config = string(config, "ceiling_y=", game_config.ceiling_y, " ")
    config = string(config, "floor_y=", game_config.floor_y, " ")
    config = string(config, "enemy_y=", game_config.enemy_y, " ")
    config = string(config, "learning_rate=", game_config.learning_rate, " ")
    config = string(config, "discount_factor=", game_config.discount_factor, " ")
    config = string(config, "epsilon_greedy=", game_config.epsilon_greedy, " ")
    config = string(config, "reward_per_time=", game_config.reward_per_time, " ")
    config = string(config, "reward_per_distance=", game_config.reward_per_distance, " ")
    return config
end

# config: print
function to_header(game_config::GameConfig)
    config = string("name,")
    config = string(config, "num_rows,")
    config = string(config, "num_rows,")
    config = string(config, "num_columns,")
    config = string(config, "ceiling_y,")
    config = string(config, "floor_y,")
    config = string(config, "enemy_y,")
    config = string(config, "learning_rate")
    config = string(config, "discount_factor,")
    config = string(config, "epsilon_greedy,")
    config = string(config, "reward_per_time,")
    config = string(config, "reward_per_distance,")
    return config
end

# config: print
function to_log(game_config::GameConfig)
    config = string(game_config.env_name, ",")
    config = string(config, game_config.num_rows, ",")
    config = string(config, game_config.num_rows, ",")
    config = string(config, game_config.num_columns, ",")
    config = string(config, game_config.ceiling_y, ",")
    config = string(config, game_config.floor_y, ",")
    config = string(config, game_config.enemy_y, ",")
    config = string(config, game_config.learning_rate, ",")
    config = string(config, game_config.discount_factor, ",")
    config = string(config, game_config.epsilon_greedy, ",")
    config = string(config, game_config.reward_per_time, ",")
    config = string(config, game_config.reward_per_distance, ",")
    return config
end

# print
function is_print(loop_count)
    if loop_count<=5
        return true
    end
    if loop_count<=100
        if loop_count%25==0
            return true
        end
    end
    if loop_count<=1000
        if loop_count%250==0
            return true
        end
    end
    if loop_count<=10000
        if loop_count%500==0
            return true
        end
    end
    if loop_count%10000==0
        return true
    end
    return false
end

### TEST: CONFIG
# size
num_rows = 10
num_columns=25
# learning
learning_rate = 0.005
discount_factor = 0.99
epsilon_greedy = 0.075
reward_per_time=-0.1
reward_per_distance=100
test_config = GameConfig(num_rows, num_columns,
                learning_rate, discount_factor, epsilon_greedy,
                reward_per_time, reward_per_distance)
print("GAME TEST CONFIG: ", test_config, "\n")
print("GAME TEST CONFIG: ", to_string(test_config), "\n")
print("GAME TEST CONFIG: ", to_header(test_config), "\n")
print("GAME TEST CONFIG: ", to_log(test_config), "\n")