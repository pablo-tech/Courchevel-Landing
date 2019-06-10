### INCLUDE
include("courchevel-config.jl");
include("courchevel-state.jl");
include("courchevel-action.jl");
include("courchevel-environment.jl");
include("courchevel-world.jl");
include("courchevel-agent.jl");

### TEST
allies = init_ally_state(GameConfig())
print("ALLIES: ", allies)
enemies = init_enemy_state(GameConfig())
print("ENEMIES: ", enemies)

### TEST: WORLD
test_name = "Courchevel-V0"
courchevel_dp = CourchevelDp(config)
# println("env_name: ", courchevel_dp.game_config.env_name)
courchevel_dp.game_config.env_name==test_name? nothing:throw(AssertionError("env_name: "*courchevel_dp.game_config.env_name))

### TEST: RENDER
redition = render_game(courchevel_dp.state_space.environment_state, courchevel_dp.state_space.ally_state, courchevel_dp.state_space.enemy_state,
    courchevel_dp.game_config.num_rows, courchevel_dp.game_config.num_columns)
# println(redition)
# println(courchevel_dp.state_space.environment_state)

### TEST: RANDOM
random_number_generator = MersenneTwister(1)

### == END OF TEST ==
println("\n\n\n\n")

num_seasons=100
num_episodes=100

grand_reward = 0.0
total_episodes = 0
total_gameover_episodes = 0


recon_fleet = [CourchevelAgent(config, :Recon, 1)]
biased_fleet = [CourchevelAgent(config, :Bomber, 2), CourchevelAgent(config, :Fighter, 3)]

# change config across seasons
for season_count in 1:num_seasons

    set_config = GameConfig()
    courchevel_dp = CourchevelDp(set_config)

    # restart, but keep configuration across episodes
    for episode_count in 0:num_episodes

        time = 1

        # problem
        courchevel_dp = CourchevelDp(set_config)
        state_of_war = courchevel_dp.state_space

        #observation = state_of_war

        # agent
        # pilot_fleet = biased_fleet
        pilot_fleet = recon_fleet
        pilot_agent = pilot_fleet[rand(1:length(pilot_fleet))]


        # (state_of_war, agent_action) => (state_of_war_prime, observation, reward)
        while !courchevel_dp.is_game_over

             agent_base_action = get_base_action(pilot_agent, courchevel_dp.qTable, courchevel_dp.game_config.epsilon_greedy, state_of_war,
                                        courchevel_dp.game_config.num_rows, courchevel_dp.game_config.num_columns)
             agent_biased_action = get_biased_action(pilot_agent, agent_base_action)

             (state_of_war_prime, observation, instant_reward) = get_state_observation_reward(courchevel_dp, state_of_war, agent_biased_action, random_number_generator)
             # println("sp=", state_prime, " o=", observation, " r=", instant_reward)

             state_of_war = state_of_war_prime
             grand_reward += instant_reward

             # TODO: observation

             # render & log
             #rendition = render_game(courchevel_dp.state_space.environment_state, courchevel_dp.state_space.ally_state, courchevel_dp.state_space.enemy_state,
             #                            courchevel_dp.game_config.num_rows, courchevel_dp.game_config.num_columns)
             #print(rendition)
             #println("season_count=", season_count, " episode=", episode_count, " time=",  time, " instant_reward=", instant_reward, " grand_reward=", grand_reward, "\n")

             if courchevel_dp.is_game_over
                total_gameover_episodes+=episode_count
                #println("===GAME OVER==")
             end

             # time
             time +=1
        end

        if is_print(episode_count)
            println(episode_count, " GRAND_REWARD ", grand_reward,  " REWARD PER EPISODE: ", grand_reward/total_episodes, " EPISODES BEFORE DONE ", total_gameover_episodes/total_episodes)
        end

        total_episodes+=1
    end

    println(" == END SEASON == ", season_count, " WITH CONFIG ", courchevel_dp.game_config)
end

