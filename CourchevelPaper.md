# Maximizing Exploration/Exploitation ROI 

# Introduction

The Courchevel airport in the French Alps was made famous by the James Bond film "Tomorrow Never Dies.” 
Perched on a cliff, with a very short landing strip (1762ft) at a gradient of 18.5%—it is among the most dangerous altiports in the world. 
This research paper lays the groundwork for autonomous landing at Courchevel under blizzard conditions, applying reinforcement learning.

# Game
Winter is here. You and your friends were tossing around a frisbee at the park when you made a wild throw that left the 
frisbee out in the middle of the lake. The water is mostly frozen, but there are a few holes where the ice has melted. 
If you step into one of those holes, you'll fall into the freezing water. At this time, there's an international frisbee shortage, 
so it's absolutely imperative that you navigate across the lake and retrieve the disc. However, the ice is slippery, 
so you won't always move in the direction you intend.

# Problem

The pilot agent may control movement of the airplane--but while landing in high winds and low visibility, 
the actual movement of the airplane will be uncertain. 

Thus, from a planning point of view, closed-loop model predictive control is expected to fail.

Courchevel has no instrument approach procedure or lighting aids, thus making landing in fog and low clouds unsafe and almost impossible.
There is no go-around procedure for landings, because of the surrounding mountains.

# Approach

The working hypothesis is that open-loop planning could account for uncertainty in the airplane’s state, 
with an agent streaming reactions that result in a safe landing.
  
By applying approximate dynamic programming, the necessary computations may be performed in real-time.

Specifically, the use of Partially Observable Markov Decision Processes is under consideration. 
Thus, the agent’s optimal action would depend on its belief state, and not on executing a precomputed policy that would depend on knowing the actual state.

With approaches that rely on knowing the State Transition Probability Distribution in advance out of the picture, 
it is also likely that the classic Q Learning approach will not work, even though it trains as it evaluates. 

Epsilon Greedy strategies will be evaluated, though their randomness-induced success is expected to be low. 

This project will contribute innovations in: Q Learning, greediness, rewards discounting, and hyper-parameter setting in general.

# Success Metrics

The key metric will be how quickly the algorithm solves the problem: number of Episodes Before Solve. 
Another metric will be the average reward obtained over a consecutive number of episodes.

# Prior Work
One possible way to undertake this project is by generalizing the Frozen Lake environment in OpenAI Gym. 
Turning it into a 3d high-dimension uncertain environment may fairly represent Courchevel. 
The agent would be rewarded for successfully landing on the runway. 
An alternative environment could be the Lunar Lander.

# Environment

## Defined Transition and Reward Probability Distribution
Demonstrated by environments like Taxi-v2, giving a negative reward at each step can be a strong driver of policy convergence.  
Rather quickly the agent starts trying actions with higher qValues.
```
Environment Taxi-v2 action_space=Discrete(6), observation_space=Discrete(500)
Environment Taxi-v2: episode 2, EPISODE_STEPS_BEFORE_SOVE 200, GRAND_REWARD -1066.0, AVERAGE_REWARD -355.333333333
Environment Taxi-v2: episode 4, EPISODE_STEPS_BEFORE_SOVE 200, GRAND_REWARD -2087.0, AVERAGE_REWARD -417.4
Environment Taxi-v2: episode 25, EPISODE_STEPS_BEFORE_SOVE 200, GRAND_REWARD -10427.0, AVERAGE_REWARD -401.038461538
Environment Taxi-v2: episode 50, EPISODE_STEPS_BEFORE_SOVE 200, GRAND_REWARD -15640.0, AVERAGE_REWARD -306.666666667
Environment Taxi-v2: episode 75, EPISODE_STEPS_BEFORE_SOVE 97, GRAND_REWARD -18171.0, AVERAGE_REWARD -239.092105263
Environment Taxi-v2: episode 100, EPISODE_STEPS_BEFORE_SOVE 21, GRAND_REWARD -20591.0, AVERAGE_REWARD -203.871287129
Environment Taxi-v2: episode 250, EPISODE_STEPS_BEFORE_SOVE 11, GRAND_REWARD -26335.0, AVERAGE_REWARD -104.920318725
Environment Taxi-v2: episode 500, EPISODE_STEPS_BEFORE_SOVE 14, GRAND_REWARD -25301.0, AVERAGE_REWARD -50.500998004
Environment Taxi-v2: episode 750, EPISODE_STEPS_BEFORE_SOVE 10, GRAND_REWARD -23346.0, AVERAGE_REWARD -31.086551265
Environment Taxi-v2: episode 1000, EPISODE_STEPS_BEFORE_SOVE 16, GRAND_REWARD -21311.0, AVERAGE_REWARD -21.2897102897
Environment Taxi-v2: episode 2500, EPISODE_STEPS_BEFORE_SOVE 9, GRAND_REWARD -8838.0, AVERAGE_REWARD -3.53378648541
Environment Taxi-v2: episode 5000, EPISODE_STEPS_BEFORE_SOVE 8, GRAND_REWARD 11993.0, AVERAGE_REWARD 2.39812037592
Environment Taxi-v2: episode 7500, EPISODE_STEPS_BEFORE_SOVE 16, GRAND_REWARD 32975.0, AVERAGE_REWARD 4.3960805226
Environment Taxi-v2: episode 10000, EPISODE_STEPS_BEFORE_SOVE 12, GRAND_REWARD 53778.0, AVERAGE_REWARD 5.37726227377
```

## Transition Slippage 
With unknown Transition probability distributions, it can be more challenging to learn.  In Courchevel, as in FrozenLake-v0, the environment is slippery,
and the agent may end up in a state it did not expect to go to.  Transitions only partially depend on the chosen action.  
The agent has to somehow learn how to get to where it wants to go, even though every attempted step/action to get there is unlikely to succeed.

### The Importance of Reward
Specifically for FrozenLake-v0, qLearning does not work at all.  The starting and goal states are fixed, 
and every state transition gives a reward of 0, except the goal state.  Thus the agent will not be able to choose better actions, 
or worse keep trying the same over and over.
```
    # SFFF       (S: starting point, safe)
    # FHFH       (F: frozen surface, safe)
    # FFFH       (H: hole, fall to your doom)
    # HFFG       (G: goal, where the frisbee is located)
```

In fact, a random policy will succeed, but with a very low success rate.


### The Need for Exploration
To determine the value advantage of different actions, a known approach is to introduce an epsilon greedy policy, 
which will return a random actiona set % of the steps.

If random > epsilon:
    action = argmax(Q[state])
else
    action = env.action_space.sample() 

```
Environment FrozenLake-v0, learning_rate=0.618, discount_rate=1, max_episodes=10000, render_env=False, is_explorer=True
Environment FrozenLake-v0 action_space=Discrete(4), observation_space=Discrete(16)
Environment FrozenLake-v0: episode 2, EPISODE_STEPS_BEFORE_SOVE 7, GRAND_REWARD 0.0, AVERAGE_REWARD 0.0
Environment FrozenLake-v0: episode 4, EPISODE_STEPS_BEFORE_SOVE 10, GRAND_REWARD 1.0, AVERAGE_REWARD 0.2
Environment FrozenLake-v0: episode 25, EPISODE_STEPS_BEFORE_SOVE 7, GRAND_REWARD 1.0, AVERAGE_REWARD 0.0384615384615
Environment FrozenLake-v0: episode 50, EPISODE_STEPS_BEFORE_SOVE 8, GRAND_REWARD 2.0, AVERAGE_REWARD 0.0392156862745
Environment FrozenLake-v0: episode 75, EPISODE_STEPS_BEFORE_SOVE 9, GRAND_REWARD 2.0, AVERAGE_REWARD 0.0263157894737
Environment FrozenLake-v0: episode 100, EPISODE_STEPS_BEFORE_SOVE 11, GRAND_REWARD 3.0, AVERAGE_REWARD 0.029702970297
Environment FrozenLake-v0: episode 250, EPISODE_STEPS_BEFORE_SOVE 10, GRAND_REWARD 10.0, AVERAGE_REWARD 0.0398406374502
Environment FrozenLake-v0: episode 500, EPISODE_STEPS_BEFORE_SOVE 5, GRAND_REWARD 21.0, AVERAGE_REWARD 0.0419161676647
Environment FrozenLake-v0: episode 750, EPISODE_STEPS_BEFORE_SOVE 5, GRAND_REWARD 30.0, AVERAGE_REWARD 0.0399467376831
Environment FrozenLake-v0: episode 1000, EPISODE_STEPS_BEFORE_SOVE 6, GRAND_REWARD 47.0, AVERAGE_REWARD 0.046953046953
Environment FrozenLake-v0: episode 2500, EPISODE_STEPS_BEFORE_SOVE 15, GRAND_REWARD 100.0, AVERAGE_REWARD 0.0399840063974
Environment FrozenLake-v0: episode 5000, EPISODE_STEPS_BEFORE_SOVE 20, GRAND_REWARD 175.0, AVERAGE_REWARD 0.0349930013997
Environment FrozenLake-v0: episode 7500, EPISODE_STEPS_BEFORE_SOVE 5, GRAND_REWARD 272.0, AVERAGE_REWARD 0.0362618317558
Environment FrozenLake-v0: episode 10000, EPISODE_STEPS_BEFORE_SOVE 11, GRAND_REWARD 345.0, AVERAGE_REWARD 0.034496550345
```


### 3D ice lake:

### Optimizing Total Rewards

# Courchevel Environment

The battle is played in mountain range, in blind conditions

Parties 
- Allied "A"
- Enemy "N"

Goal
- Maximize grand net Allied Reward over Time 

Reward
- Fire is exchanged between Ally and Enemy, the net Reward is uncertain 
- Allies are penalized for passage of Time

Theatre
- Vertical axis: actual Elevation of the parties
- Horizontal axis: actual passage of Time
- Allied aircraft are depicted as "A", enter from the left, at an uncertain Elevation
- The Enemy has fortified positions "N" in the the mountain terrain, at an uncertain Elevation

Allied Pilot Actions
- Allies send persistent aircraft sorties. Pilot actions Up/Down/Bomb/Missile have uncertain outcome
- Bomb is effective when flying above the Enemy, up to an uncertain elevation Ceiling
- Missile is effective when flying below the Enemy, down to an uncertain elevation Floor

Changing Conditions 
- Conditions are stable over several Episodes, but change over Seasons
- The enemy changes the location of its fortification, adding uncertainty  
- Atmospheric pressure changes, adding Elevation uncertainty  


# References
Courchevel Altiport: https://en.wikipedia.org/wiki/Courchevel_Altiport