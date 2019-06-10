### INCLUDE
include("courchevel-config.jl");
include("courchevel-environment.jl");


############################################ STATE: ENVIRONMENT

mutable struct EnvironmentState
    theatre_code::Int64
end

# descrbies an ally position
mutable struct CombatantState
    status_code::Int64
end

# construct EnvironmentState defaulting to EMPTY_CELL
function EnvironmentState()
    return EnvironmentState(EMPTY_CELL)
end

# construct state with specific theatre code
function EnvironmentState(theatre_code)
    return EnvironmentState(theatre_code)
end


############################################ STATE: ALLY
# enter from left
function init_ally_state(game_config::GameConfig)
    # init & reset
    ally_grid = Matrix{CombatantState}(game_config.num_columns, game_config.num_rows)
    for i in 1:game_config.num_columns
        for j in 1:game_config.num_rows
            ally_grid[i,j] = CombatantState(EMPTY_CELL)
        end
    end
    # add allies: random
    i = 2
    #ally_y = rand(2: game_config.num_rows-1)
    #j = trunc(Int, ally_y)
    # add allies: same as enemy fortification
    j = game_config.enemy_y
    ally_grid[i,j] = CombatantState(ALLY_CELL)
    return ally_grid
end

############################################ STATE: ENEMY
### positioned across an elevation
function init_enemy_state(game_config::GameConfig)
    # init & reset
    enemy_grid = Matrix{CombatantState}(game_config.num_columns, game_config.num_rows)
    for i in 1:game_config.num_columns
        for j in 1:game_config.num_rows
            enemy_grid[i,j] = CombatantState(EMPTY_CELL)
        end
    end
    # add enemies
    j = trunc(Int, game_config.enemy_y)
    for i = 2:game_config.num_columns-1
        enemy_grid[i,j] = CombatantState(ENEMY_CELL)
    end
    return enemy_grid
end


############################################ STATE: INSTANTIATION

function environment_state(game_config::GameConfig)
    ## environment
    environment_state = init_grid(game_config.num_rows, game_config.num_columns)
    # ceiling
    ceiling_y = calculate_ceiling(game_config.num_rows, game_config.num_columns)
    for i = 2:game_config.num_columns-1
        environment_state[i, ceiling_y] = EnvironmentState(CEILING_CELL)
    end
    # floor
    floor_y = calculate_floor(game_config.num_rows, game_config.num_columns)
    for i = 2:game_config.num_columns-1
        environment_state[i, floor_y] = EnvironmentState(FLOOR_CELL)
    end
    return environment_state
end



############################################ STATE: COMBINED

# environment, ally, enemy
mutable struct TheatreState
    environment_state::Matrix{EnvironmentState}  # environment
    ally_state::Matrix{CombatantState}           # allies
    enemy_state::Matrix{CombatantState}          # enemies
end

function TheatreState(game_config::GameConfig)
    return TheatreState(environment_state(game_config),
        init_ally_state(game_config), init_enemy_state(game_config))
end


############################################ OBSERVATION
# TODO
struct PilotObservation
    state_code::Int64
end


### TEST:
# environment = environment_state(GameConfig())
# print("ENVIRONMENT STATE: ", environment)
