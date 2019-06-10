### JULIA
## Connection to Python
# TODO: if unset
ENV["PYTHON"] = "/usr/bin/python"
# ENV["PYTHON"] = "/Users/pablo/anaconda/bin/python"
Pkg.build("PyCall")
using PyCall

### PYTHON
@pyimport random
@pyimport numpy as np


@pyimport sys
# #sys.path.append('/module/gym/')
# #sys.path.append('/module/universe/')
@pyimport gym
# @pyimport universe


# ### OWN
# # import courchevelagent as agent
#
#
# function run(env_name, learning_rate, discount_rate, max_episodes, render_env,
#         is_explorer):
#     # INPUT
#     print("Environment {}, learning_rate={}, discount_rate={}, max_episodes={}, render_env={}, is_explorer={}".format(env_name, learning_rate, discount_rate, max_episodes, render_env, is_explorer))
#     # ENVIRONMENT
#     env = gym.make(env_name)
#     print("Environment {} action_space={}, observation_space={}".format(env_name, env.action_space, env.observation_space))
#     # REWARD
#     grand_reward = 0.
#     # TABLE
#     n_states = env.observation_space.n
#     n_actions = env.action_space.n
#     qTable = np.zeros([n_states, n_actions])
#     # LEARNING
#     steps_before_solve = np.zeros([max_episodes])
#     reward_before_solve = np.zeros([max_episodes])
#     episodes_before_solve = np.zeros([max_episodes])
#     end_obs_q = np.zeros([max_episodes, n_actions])
#     # EPISODES
#     for episode_num in range(0,max_episodes):
#         # RESET
#         done = False
#         this_obs = env.reset()
#         episode_reward, this_reward = 0., 0.
#         total_steps = 0
#         # EPISODE
#         while not done:
#         # while total_steps<max_steps:
#         # while this_reward !=20: # episode ends with successful dropoff
#             # ACT: from Observed state
#             action = agent.get_action(qTable, this_obs, env, is_explorer)
#             # print("(o,a)=" + str(this_obs) + "/" + str(n_states) +","+ str(action) + "/" + str(n_actions))
#             # NEXT
#             next_obs, this_reward, done, info = env.step(action)
#             future_value = np.max(qTable[next_obs])    # Bellman value
#             qTable[this_obs,action] += learning_rate*( this_reward + discount_rate*future_value-qTable[this_obs,action] )
#             this_obs = next_obs  # next state
#             # ACCOUNT
#             episode_reward += this_reward
#             # print("(R,r)=" + str(round(episode_reward, 2)) + "," + str(round(this_reward,2)))
#             # print("(step,episode)=" + str(total_steps) + "," + str(episode_num) + "/" + str(max_episodes))
#             if render_env:
#                 env.render()
#             total_steps+=1
#         if done:
#             steps_before_solve[episode_num] = total_steps
#             reward_before_solve[episode_num] = episode_reward
#             grand_reward += episode_reward
#             end_obs_q[episode_num] = qTable[this_obs]
#             episode_num+=1
#         end
#
#         if is_print(episode_num):
#             average_reward = grand_reward/(episode_num+1)
#             print("Environment {}: episode {}, EPISODE_STEPS_BEFORE_SOVE {}, GRAND_REWARD {}, AVERAGE_REWARD {}".format(env_name, episode_num, total_steps, grand_reward, average_reward))
#         end
#     end
#     # RECAP
#     # for episode_num in range(0,max_episodes):
#     #     if is_print(episode_num):
#     #         print "Environment {}, episode {}: qTable[end_obs]= {}".format(env_name, episode_num, end_obs_q[episode_num])
# end
#
#
# # CONFIG
# function is_print(episode_num):
#     if episode_num<=5:
#         if episode_num%2==0:
#             return True
#     if episode_num<=100:
#         if episode_num%25==0:
#             return True
#     if episode_num<=1000:
#         if episode_num%250==0:
#             return True
#     if episode_num<=10000:
#         if episode_num%2500==0:
#             return True
#     if episode_num%10000==0:
#         return True
#     return False
# end