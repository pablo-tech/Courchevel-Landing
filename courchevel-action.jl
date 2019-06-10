


############################################ ACTION

mutable struct PilotAction
    action_code::Symbol
end


function get_action_space()
    [PilotAction(:Hold), PilotAction(:Up), PilotAction(:Down),
    PilotAction(:ConventionalBomb), PilotAction(:NuclearBomb),
    PilotAction(:ConventionalMissile), PilotAction(:NuclearMissile)]
end

function get_action_index(pilot_action::PilotAction)
    action_index = 1
    for space_action in get_action_space()
        if pilot_action.action_code == space_action.action_code
            return action_index
        end
        action_index+=1
    end
end

function is_bomb(pilot_action::PilotAction)
    if pilot_action.action_code==:ConventionalBomb || pilot_action.action_code==:NuclearBomb
        return true
    end
    return false
end

function is_missile(pilot_action::PilotAction)
    if pilot_action.action_code==:ConventionalMissile || pilot_action.action_code==:NuclearMissile
        return true
    end
    return false
end

function is_conventional(pilot_action::PilotAction)
    if pilot_action.action_code==:ConventionalBomb || pilot_action.action_code==:ConventionalMissile
        return true
    end
    return false
end

function is_nuclear(pilot_action::PilotAction)
    if pilot_action.action_code==:NuclearBomb || pilot_action.action_code==:NuclearMissile
        return true
    end
    return false
end

function is_fire(pilot_action::PilotAction)
    return is_bomb(pilot_action) || is_fire(pilot_action)
end


### TEST
user_actions = get_action_space()
for test_action in user_actions
    # println(test_action, " ACTION ", " is bomb? ", is_bomb(test_action))
end

