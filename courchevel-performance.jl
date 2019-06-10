### INCLUDE
include("courchevel-config.jl");
include("courchevel-state.jl");
include("courchevel-action.jl");
include("courchevel-environment.jl");
include("courchevel-world.jl");
include("courchevel-agent.jl");
include("courchevel-iteration.jl");


log_header=["Season#", "RunTag",
            "Reward/Episode", "GrandReward", "EpisodesBeforeDone", "Fleet"]


function get_performance(game_config::GameConfig, run_tag, num_seasons, num_episodes)

    # accounting
    grand_reward = 0.0
    total_episodes = 0
    gameover_episodes = 0

    # logging
    log_to_file = ""
    for item in log_header
        log_to_file = string(log_to_file, log_header[1], ",")
    end
    log_to_file = string(log_to_file, ",", to_header(game_config), "\n")
    # TODO: header println(log_to_file)

    for season_count in 1:num_seasons

        courchevel_dp = CourchevelDp(game_config)

        (season_reward, season_gameover_episodes, season_episodes) = iterate_season(courchevel_dp)
        grand_reward += season_reward
        gameover_episodes += season_gameover_episodes
        total_episodes += season_episodes

        if is_print(season_count)
            log_stdout = ""
            # seaseason_count, run_tag
            log_stdout = string(log_stdout, log_header[1], "=", season_count, "=", log_header[2], run_tag, "\n\t")
            log_to_file = string(log_to_file, season_count, ",", run_tag, ",")
            # reward_per_episode
            reward_per_episode = grand_reward/total_episodes
            log_stdout = string(log_stdout, log_header[3], "=", reward_per_episode, " ")
            log_to_file = string(log_to_file, season_count, ",", run_tag, ",")
            # grand_reward
            log_stdout = string(log_stdout, log_header[4], "=", grand_reward, " ")
            log_to_file = string(log_to_file, grand_reward, ",")
            # gameover_episodes = gameover_episodes/total_episodes
            log_stdout = string(log_stdout, log_header[5], "=", gameover_episodes, "\n\t")
            log_to_file = string(log_to_file, gameover_episodes, ",")
            # config
            log_stdout = string(log_stdout, to_log(game_config))
            log_to_file = string(log_to_file, to_log(game_config), ",")
            # pilot_fleet
            log_stdout = string(log_stdout, log_header[6], "=", pilot_fleet, " ")
            log_to_file = string(log_to_file, pilot_fleet, ",")
            # output
            println(log_stdout)
            # TODO: content to file
            println(log_to_file)
        end
    end

    println("========================= END SEASONS =====================")

end


#################
### DEFAULT: CONFIG
#################

# size
num_rows = 10
num_columns=25     # 25 default
# learning
learning_rate = 0.005   # 0.005 default w/bias, 0.05 for recon
discount_factor = 0.99  # 0.99 default w/bias, 0.80 for recon
epsilon_greedy = 0.075 # 0.075 default for both
# rewards
reward_per_time = -0.1
reward_per_distance = 100

default_config = GameConfig(num_rows, num_columns,
                learning_rate, discount_factor, epsilon_greedy,
                reward_per_time, reward_per_distance)

#################
### CONFIG: FLEET
#################
recon_fleet = [CourchevelAgent(default_config, :Recon, 1)]
biased_fleet = [CourchevelAgent(default_config, :Bomber, 2), CourchevelAgent(default_config, :Fighter, 3)]
pilot_fleet = biased_fleet
#pilot_fleet = recon_fleet

#################
### RUNS: OVERALL
#################
num_settings = 3
num_seasons = 100
num_episodes = 500

#################
### RUNS: GAME SIZE
#################
### Number of Rows
rows_config = copy(default_config)
rows_multiple = 2
rows_tag = "NumberOfRows"
rows_config.num_rows = 10
# run
for i = 1:num_settings
    get_performance(rows_config,
        string(rows_tag, "=", rows_config.num_rows),
        num_seasons, num_episodes)
    rows_config.num_rows = rows_config.num_rows*rows_multiple
end
### Number of columns
columns_config = copy(default_config)
columns_multiple = 2
columns_tag = "NumberOfColumns"
columns_config.num_columns = 10
# run
for i = 1:num_settings
    get_performance(columns_config,
        string(columns_tag, "=", columns_config.num_columns),
        num_seasons, num_episodes)
    columns_config.num_columns = columns_config.num_columns*columns_multiple
end

#################
### RUNS: HYPERPARAMETERS
#################
### Learning Rate
learningrate_config = copy(default_config)
learningrate_multiple = 10
learningrate_tag = "LearningRate"
learningrate_config.learning_rate = 0.005
# run
for i = 1:num_settings
    get_performance(learningrate_config,
        string(learningrate_tag, "=", learningrate_config.learning_rate),
        num_seasons, num_episodes)
    learningrate_config.learning_rate = learningrate_config.learning_rate*learningrate_multiple
end
### Discount Rate
discountfactor_config = copy(default_config)
discountfactor_multiple = 0.95
discountfactor_tag = "DiscountRate"
discountfactor_config.discount_factor = 0.99
# run
for i = 1:num_settings
    get_performance(discountfactor_config,
        string(discountfactor_tag, "=", discountfactor_config.discount_factor),
        num_seasons, num_episodes)
    discountfactor_config.learning_rate = discountfactor_config.discount_factor*discountfactor_multiple
end
### Epsilon Greedy
epsilongreedy_config = copy(default_config)
epsilongreedy_multiple = 0.33
epsilongreedy_tag = "EpsilonGreedy"
epsilongreedy_config.epsilon_greedy = 0.25
# run
for i = 1:num_settings
    get_performance(epsilongreedy_config,
        string(epsilongreedy_tag, "=", epsilongreedy_config.epsilon_greedy),
        num_seasons, num_episodes)
    epsilongreedy_config.epsilon_greedy = epsilongreedy_config.epsilon_greedy*epsilongreedy_multiple
end


#################
### RUNS: GAME REWARDS
#################
### Unit of Time Rewards
unitoftime_config = copy(default_config)
unitoftime_multiple = 10
unitoftime_tag = "RewardPerUnitOfTime"
unitoftime_config.reward_per_time = -0.1
# run
for i = 1:num_settings
    get_performance(unitoftime_config,
        string(unitoftime_tag, "=", unitoftime_config.reward_per_time),
        num_seasons, num_episodes)
    unitoftime_config.reward_per_time = unitoftime_config.reward_per_time*unitoftime_multiple
end
### Unit of Distance Reward
unitofdistance_config = copy(default_config)
unitofdistance_multiple = 10
unitofdistance_tag = "RewardPerUnitOfDistance"
unitofdistance_config.reward_per_distance = 10
# run
for i = 1:num_settings
    get_performance(unitofdistance_config,
        string(unitofdistance_tag, "=", unitofdistance_config.reward_per_distance),
        num_seasons, num_episodes)
    unitofdistance_config.reward_per_distance = unitofdistance_config.reward_per_distance*unitofdistance_multiple
end
