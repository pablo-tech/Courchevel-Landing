######################################################
############ TRICK OR TREAT? LILY MEETS CAT
######################################################

############
# QUESTION 4
############

### Given facts
reward_if_answer = 1
probability_being_home = 0.85 # light is on

### Theta
# defined in Q1, maximum likelihood calculation Q2
theta = 0.29

### Probability of answer
# Function of Theta, and iteration number
function probability_of_answer(t)
    if t==0
        return theta
    end
    return (1-theta)^t * theta
end

### Discounted utility
function discounted_utility(utility_table, t, discount_factor)
    if t==1
        return 0    # before first time increment, utility is 0
    end
    return discount_factor * utility_table[t-1]
end

### POLICY ITERATION
function policy_utility(discount_factor, number_of_increments)
    utility_table = fill(0., number_of_increments)    # dynamic programming; and track it over time
    for t = 1:number_of_increments
        instant_reward = probability_being_home * probability_of_answer(t) * reward_if_answer
        println("t=", t, " instant_reward: ", instant_reward)
        utility_table[t] = instant_reward + discounted_utility(utility_table, t, discount_factor)
    end
    return utility_table
end

############ PART 4a: policy to wait for eternity at house with light (discounted utility)
### Facts
discount_factor = 0.9           # given
number_of_increments = 100      # Run for eternity

## utility over infinite time converges to zero, due to discounting
utility = policy_utility(discount_factor, number_of_increments)

println("UTILITY OVER TIME: ", utility)

## instant reward over time, with decreasing probability of answer
#t=1 instant_reward: 0.20589999999999997
#t=2 instant_reward: 0.14618899999999999
#t=3 instant_reward: 0.10379418999999997
#t=4 instant_reward: 0.07369387489999998
#t=5 instant_reward: 0.052322651178999986
#t=6 instant_reward: 0.03714908233708998
#t=7 instant_reward: 0.02637584845933389
#t=8 instant_reward: 0.01872685240612706
#t=9 instant_reward: 0.013296065208350211
#t=10 instant_reward: 0.00944020629792865

# UTILITY OVER TIME (converges to zero): [0.2059, 0.331499, 0.402143, 0.435623, 0.444383, 0.437094, 0.41976, 0.396511, 0.370156, 0.342581, 0.315025,
#0.288282, 0.262832, 0.238948, 0.216756, 0.19629, 0.17752, 0.160377, 0.144772, 0.130602, 0.11776, 0.106139, 0.0956353, 0.0861498,
#0.0775903, 0.0698706, 0.0629115, 0.0566402, 0.0509903, 0.0459012, 0.0413182, 0.0371914, 0.0334759, 0.0301308, 0.0271196, 0.0244089,
#0.0219689, 0.0197727, 0.0177959, 0.0160166, 0.0144152, 0.0129738, 0.0116765, 0.010509, 0.00945814, 0.00851236, 0.00766116, 0.00689506,
#0.00620557, 0.00558503, 0.00502653, 0.00452388, 0.0040715, 0.00366435, 0.00329792, 0.00296813, 0.00267132, 0.00240418, 0.00216377,
#0.00194739, 0.00175265, 0.00157739, 0.00141965, 0.00127768, 0.00114992, 0.00103492, 0.000931431, 0.000838288, 0.000754459, 0.000679013,
#0.000611112, 0.000550001, 0.000495001, 0.000445501, 0.000400951, 0.000360856, 0.00032477, 0.000292293, 0.000263064, 0.000236757,
#0.000213082, 0.000191773, 0.000172596, 0.000155337, 0.000139803, 0.000125823, 0.00011324, 0.000101916, 9.17247e-5, 8.25522e-5,
#7.4297e-5, 6.68673e-5, 6.01805e-5, 5.41625e-5, 4.87462e-5, 4.38716e-5, 3.94845e-5, 3.5536e-5, 3.19824e-5, 2.87842e-5]

############ PART 4b: policy to wait for eternity at house with light (no discounting)
### Facts
discount_factor = 1.0           # given
number_of_increments = 100      # Run for eternity

## utility over infinite time converges to zero, due to discounting
utility = policy_utility(discount_factor, number_of_increments)

println("UTILITY OVER TIME: ", utility)
# UTILITY OVER TIME (converges to >0): [0.2059, 0.352089, 0.455883, 0.529577, 0.5819, 0.619049, 0.645425, 0.664151, 0.677448,
#0.686888, 0.69359, 0.698349, 0.701728, 0.704127, 0.70583, 0.707039, 0.707898, 0.708508, 0.70894, 0.709248, 0.709466, 0.709621,
#0.709731, 0.709809, 0.709864, 0.709904, 0.709932, 0.709951, 0.709966, 0.709976, 0.709983, 0.709988, 0.709991, 0.709994, 0.709996,
#0.709997, 0.709998, 0.709998, 0.709999, 0.709999, 0.709999, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71,
#0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71,
#0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71,
#0.71, 0.71, 0.71]


############ PART 4c: policy to wait for 1 minute at house with light (no discounting)
### Facts
discount_factor = 1.0           # given
number_of_increments = 6        # Run for eternity

## utility over infinite time converges to zero, due to discounting
utility = policy_utility(discount_factor, number_of_increments)

println("UTILITY OVER TIME: ", utility)
# UTILITY OVER TIME (converges to >0 about same as infinite wait): [0.2059, 0.352089, 0.455883, 0.529577, 0.5819, 0.619049]


############
# QUESTION 5
############

############ Part 5a: policy to wait up to eternity at set of houses (no discounting)
### Facts
discount_factor = 1.0           # given
theta = 0.5                     # given

number_of_increments = 18       # Run for eternity; if get candy go to next house

## utility over infinite time converges to zero, due to discounting
utility = policy_utility(discount_factor, number_of_increments)

println("UTILITY OVER TIME: ", utility)
# UTILITY OVER TIME (converges to >0 about same as infinite wait): [0.2059, 0.352089, 0.455883, 0.529577, 0.5819, 0.619049]


