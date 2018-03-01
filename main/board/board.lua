local M = {}

local size_x = 3
local size_y = 3

local ROWS = {3, 4, 3, 4, 3}
--local ROWS = {2, 3, 2}

local OUTER_RADIUS = 93
--local OUTER_RADIUS = 82
local INNER_RADIUS = OUTER_RADIUS * 0.866025404
local node_name = "cell"

local board = {}

local random_numbers = {}

local input_position = vmath.vector3()

local function position_at_cell(x, y)
	local _x = (x + y * 0.5 - math.floor(y/2)) * INNER_RADIUS * 2 - INNER_RADIUS
	local _y = y * OUTER_RADIUS * 1.5 - OUTER_RADIUS * 0.5
	return _x, _y
end

local function spawn_cell_at(x, y, n)
	local pos_x, pos_y = position_at_cell(x, y)
	local entity = gui.clone_tree(gui.get_node(node_name))
	gui.set_position(entity["cell"], vmath.vector3(pos_x, pos_y, 0))
	gui.set_text(entity["cell_text"], n)
	return entity
end

local function create_random_number_list()
	local nums = {4, 2, 2}
	for i=1, 200 do
		table.insert(random_numbers, nums[math.random(#nums)])
	end
end

local function get_next_number()
	if #random_numbers > 0 then
		local n = random_numbers[1]
		table.remove(random_numbers, 1)
		return n
	else
		create_random_number_list()
		return get_next_number()
	end
end

function M.create_board()
	for y, row in pairs(ROWS) do
		for x=1, row do
			local number = get_next_number()
			local entity = spawn_cell_at(x, y, number)
			table.insert(board, {entity = entity, x = x, y = y, number=number})
		end
	end
	return board
end

function M.active_input(cell, action)
	local cell_pos = gui.get_position(cell.entity["cell"])
	local text_node = cell.entity["cell_text"]
	input_position.x = action.x - cell_pos.x
	input_position.y = action.y - cell_pos.y
	gui.set_position(text_node, input_position)
	if M.valid_move(cell, action) then
		gui.set_color(text_node, vmath.vector4(0, 1, 0, 1))
	else
		gui.set_color(text_node, vmath.vector4(1, 1, 1, 1))
	end
end

function M.reset_input(cell)
	gui.set_position(cell.entity["cell_text"], vmath.vector3())
end

local function is_adjacent(cell, neighbour)
	local grids
	if (cell.y % 2 == 0) then
		grids = {
			{cell.x - 1, cell.y},
			{cell.x + 1, cell.y},
			
			{cell.x - 1, cell.y - 1},
			{cell.x, cell.y - 1},

			{cell.x - 1, cell.y + 1},
			{cell.x, cell.y + 1}}
		
	else
		grids = {
			{cell.x + 1, cell.y},
			{cell.x - 1, cell.y},

			{cell.x + 1, cell.y - 1},
			{cell.x , cell.y - 1},

			{cell.x , cell.y + 1},
			{cell.x + 1, cell.y + 1}}
	end
	
	for _, c in pairs(grids) do
		if neighbour.x == c[1] and neighbour.y == c[2] then
			return true
		end
	end
end

function M.valid_move(cell, action)
	for _, entity in pairs(board) do
		if entity ~= cell then
			if gui.pick_node(entity.entity["cell"], action.x, action.y) then
				if is_adjacent(cell, entity) and cell.number == entity.number then
					return entity
				end
			end
		end
	end
end

function M.make_move(cell, valid)
	valid.number = cell.number + valid.number
	cell.number = get_next_number()
	gui.set_text(valid.entity["cell_text"], valid.number)
	gui.set_text(cell.entity["cell_text"], cell.number)
	gui.set_color(cell.entity["cell_text"], vmath.vector4(1, 1, 1, 1))
end

return M