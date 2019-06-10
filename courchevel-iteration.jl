#include("courchevel-agent.jl");


# (state_of_war, agent_action) => (state_of_war_prime, observation, reward)
function iterate_timestep(decision_problem::CourchevelDp, pilot_agent, state_of_war, time)

     agent_base_action = get_base_action(pilot_agent, decision_problem.qTable, decision_problem.game_config.epsilon_greedy, state_of_war,
                                decision_problem.game_config.num_rows, decision_problem.game_config.num_columns)
     agent_biased_action = get_biased_action(pilot_agent, agent_base_action)

     (state_of_war_prime, observation, instant_reward) = get_state_observation_reward(decision_problem, state_of_war, agent_biased_action, MersenneTwister(1))
     # println("sp=", state_prime, " o=", observation, " r=", instant_reward)

     #state_of_war = state_of_war_prime
     #grand_reward += instant_reward

     # TODO: observation

     # render & log
     #rendition = render_game(decision_problem.state_space.environment_state, decision_problem.state_space.ally_state, decision_problem.state_space.enemy_state,
     #                            decision_problem.game_config.num_rows, decision_problem.game_config.num_columns)
     #print(rendition)
     #println("season_count=", season_count, " episode=", episode_count, " time=",  time, " instant_reward=", instant_reward, " grand_reward=", grand_reward, "\n")

     return (state_of_war_prime, instant_reward)

end


function iterate_episode(decision_problem::CourchevelDp, pilot_agent, state_of_war, time)

        episode_reward = 0.0

        while !decision_problem.is_game_over

            (state_of_war_prime, instant_reward) = iterate_timestep(decision_problem, pilot_agent, state_of_war, time)
            episode_reward += instant_reward

             time +=1

        end

        return (time, episode_reward)
end

function iterate_season(decision_problem::CourchevelDp)

    season_reward = 0.
    season_gameover_episodes = 0
    season_episodes = 0

    # restart across chapters,, but keep configuration across episodes
    for episode_count in 0:num_episodes

        time = 1

        state_of_war = decision_problem.state_space

        #observation = state_of_war

        pilot_agent = pilot_fleet[rand(1:length(pilot_fleet))]

        (time, episode_reward) = iterate_episode(decision_problem, pilot_agent, state_of_war, time)
        season_reward += episode_reward

        if decision_problem.is_game_over
                 season_gameover_episodes+=episode_count
                 #println("===GAME OVER== on episode ", episode_count)
        end

        season_episodes+=1
    end

    return (season_reward, season_gameover_episodes, season_episodes)

end