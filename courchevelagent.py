import numpy

# TODO: get from world
epsilon = 0.5

def get_action(qTable, this_observation, env, is_explorer):
    if is_explorer:
        if numpy.random.rand() > epsilon:   # Epsilon greedy
            return env.action_space.sample()
    return numpy.argmax(qTable[this_observation])     # Bellman action
