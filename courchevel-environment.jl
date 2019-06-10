### INCLUDE

# RENDER: sample taxi
#+---------+
#|R: | : :G|
#| : : : : |
#| : : : : |
#| | : |_: |
#|Y| : |B: |
#+---------+

# RENDER: sample ice lake
#SFFF
#FHFH
#FFFH
#HFFG

### CODE NUMBER
EMPTY_CELL = 0
UNKNOWN_CELL = 1
ALLY_CELL = 777
ENEMY_CELL = 666
ALLY_AND_ENEMY_CELL = 999
# environment range
CORNER_BOUNDARY_CELL = 90
HORIZONTAL_BOUNDARY_CELL = 91
VERTICAL_BOUNDARY_CELL = 92
# operating range
FLOOR_CELL = 80
CEILING_CELL = 81
LEFT_BOUNDARY_CELL = 82
RIGHT_BOUNDARY_CELL = 83

### CODE LETTER
function code_view(code)
    letter = "U"    # unknown
    if code==EMPTY_CELL
        letter = "."
    end
    if code==VERTICAL_BOUNDARY_CELL
        letter = "-"
    end
    if code==HORIZONTAL_BOUNDARY_CELL
        letter = "|"
    end
    if code==CORNER_BOUNDARY_CELL
        letter = "+"
    end
    if code==ALLY_CELL
        letter = "A"
    end
    if code==ENEMY_CELL
        letter = "@"
    end
    if code==ALLY_AND_ENEMY_CELL
        letter = "B"
    end
    if code==FLOOR_CELL
        letter = "^"
    end
    if code==CEILING_CELL
        letter = "~"
    end
    if code==LEFT_BOUNDARY_CELL
        letter = ">"
    end
    if code==RIGHT_BOUNDARY_CELL
        letter = "<"
    end
    return letter
end

function init_grid(num_rows::Int64, num_columns::Int64)
    ## init and reset
    state_grid = Matrix{EnvironmentState}(num_columns, num_rows)
    for i = 1:num_columns
        for j = 1:num_rows
            state_grid[i,j] = EnvironmentState(EMPTY_CELL)
        end
    end

    ## vertical boundary
    j = 1
    for i = 1:num_columns
        state_grid[i,j] = EnvironmentState(VERTICAL_BOUNDARY_CELL)
    end
    j = num_rows
    for i = 1:num_columns
        state_grid[i,j] = EnvironmentState(VERTICAL_BOUNDARY_CELL)
    end

    ## horizontal boundary
    i = 1
    for j = 1:num_rows
        state_grid[i,j] = EnvironmentState(HORIZONTAL_BOUNDARY_CELL)
    end
    i = num_columns
    for j = 1:num_rows
        state_grid[i,j] = EnvironmentState(HORIZONTAL_BOUNDARY_CELL)
    end

    ## corner boundary
    # right
    state_grid[num_columns,1] = EnvironmentState(CORNER_BOUNDARY_CELL)
    state_grid[num_columns, num_rows] = EnvironmentState(CORNER_BOUNDARY_CELL)
    # left
    state_grid[1,1] = EnvironmentState(CORNER_BOUNDARY_CELL)
    state_grid[1,num_rows] = EnvironmentState(CORNER_BOUNDARY_CELL)

    return state_grid
end

function row_count(state_grid)
    return size(state_grid,1)
end

function col_count(state_grid)
    return size(state_grid,2)
end

### COURCHEVEL RENDER

# view of cell
# TODO: environment should be a color not a symbol
function cell_view(environment_state, ally_state, enemy_state, row, col, num_rows, num_columns)
    environment_cell = environment_state[row,col]
    ally_cell = ally_state[row,col]
    enemy_cell = enemy_state[row,col]

    # prioritized display
    view = code_view(environment_cell.theatre_code)
    if enemy_cell.status_code==ENEMY_CELL
        view = code_view(enemy_cell.status_code)
    end
    if ally_cell.status_code==ALLY_CELL
        view = code_view(ally_cell.status_code)
    end

    # TODO: need th decisio problem to see list of ally/enemy locations
    # combatants overlayed
    #if grid_state.has_enemy
    #    view = code_view(ENEMY_CELL)
    #end
    #if grid_state.has_ally
    #    view = code_view(ALLY_CELL)
    #end
    #if grid_state.has_enemy && grid_state.has_ally
    #    view = code_view(ALLY_AND_ENEMY_CELL)
    #end
    # end of line
    if row==num_columns
        view = view * "\n"
    end
    # println("v=", view)
    return view
end


# represent
function render_game(environment_state, ally_state, enemy_state, num_rows::Int64, num_columns::Int64)
    view_grid = ""
    for j = 1:num_rows
        view_line = ""
        for i = 1:num_columns
            view_line = view_line * cell_view(environment_state, ally_state, enemy_state, i,j, num_rows, num_columns)
        end
        view_grid = view_grid * view_line
        # println("LINE: ", view_line)
    end
    return view_grid
end
