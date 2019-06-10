import gymqlearn as qlearn


#if __name__ == '__main__':

#def run():

learning_rate = 0.618 # phi
discount_rate = 1
max_episodes = 1 # 0000
max_steps = 100
render_env = True; False

print("whatsup")

#### TAXI (GRID)
# STATE
# Grid: 5cols X 5rows.  Taxi location.  Pickup location (blue letter).  Dropoff locations (purple letter).
# Yellow square represents the taxi.  Will turn green when it has a passenger aboard
# ACTION
# down (0), up (1), right (2), left (3), pick-up (4), and drop-off (5)
# REWARD
# Receive +20 points for a successful dropoff, 10 point penalty for illegal pick-up and drop-off actions

is_explorer = False

qlearn.run('Taxi-v2', learning_rate, discount_rate, max_episodes, render_env, is_explorer)


#### FROZEN LAKE (GRID): https://gym.openai.com/envs/FrozenLake-v0/
# STATE
# Some tiles of the grid are walkable, and others lead to the agent falling into the water.
# SFFF       (S: starting point, safe)
# FHFH       (F: frozen surface, safe)
# FFFH       (H: hole, fall to your doom)
# HFFG       (G: goal, where the frisbee is located)
# ACTION
# Movement direction of the agent is uncertain and only partially depends on the chosen direction.
# REWARD
# You receive a reward of 1 if you reach the goal, and zero otherwise.
# The agent is rewarded for finding a walkable path to a goal tile.  The episode ends when you reach the goal or fall in a hole.
# FrozenLake-v0 defines "solving" as getting average reward of 0.78 over 100 consecutive trials.

is_explorer = True

qlearn.run('FrozenLake-v0', learning_rate, discount_rate, max_episodes, render_env, is_explorer)



