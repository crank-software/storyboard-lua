---V 0.1 – Phase 1. Last Updated 03/12/21

local defaults = require('layout_manager.defaults')
local helpers = require('layout_manager.helpers')
local layout_manager_options = require('layout_manager.layout_manager_options')

local grid_layout = {}

--- This function adds in the defaults to the paramaters that are needed.
-- @function fill_defaults
-- @tparam #table inc_params, the paramaters passed from the user
-- @return filled_defaults, a table filled with the defaults where there are gaps
local function fill_defaults(inc_params)
	local size_defaults = defaults:get_sizing_defaults()
	local layout_defaults = defaults:get_layout_defaults()

	local filled_defaults = {}

	filled_defaults.max_col = inc_params.max_col
	filled_defaults.max_row = inc_params.max_row
	filled_defaults.alignment = inc_params.alignment or layout_defaults.alignment
	filled_defaults.orientation = inc_params.orientation or layout_defaults.orientation
	filled_defaults.control_size = inc_params.control_size or size_defaults.control_size
	filled_defaults.padding = inc_params.padding or size_defaults.padding
	filled_defaults.layer = inc_params.layer
	filled_defaults.item_amount = inc_params.item_amount or layout_defaults.item_amount
	filled_defaults.dynamic_resize = inc_params.dynamic_resize
	filled_defaults.header = inc_params.header
	filled_defaults.footer = inc_params.footer

	if (filled_defaults.max_col == nil and filled_defaults.max_row == nil) then
		filled_defaults.max_col = layout_defaults.max_col
	end

	if (inc_params.max_col  == nil and inc_params.max_row == nil) then
		if (filled_defaults.orientation == layout_manager_options.orientation.horizontal) then
			filled_defaults.max_row = layout_defaults.max_row
		else
			filled_defaults.max_col = layout_defaults.max_col
		end
	end

	return filled_defaults
end

---This function gets the control height if its a table or just a number
--@function get_control_height
--@param inc_control_size. A table or number representing the control size
--@return the control height
local function get_control_height(inc_control_size)
	if (type(inc_control_size) == layout_manager_options.utility.number) then
		return inc_control_size
	elseif (type(inc_control_size) == layout_manager_options.utility.table) then
		return inc_control_size.height
	else
		--TODO: (Phase 2) Logging
		return nil
	end
end

---This function gets the control height if its a table or just a number
--@function get_control_width
--@param inc_control_size. A table or number representing the control size
--@return the control width
local function get_control_width(inc_control_size)
	if (type(inc_control_size) == layout_manager_options.utility.number) then
		return inc_control_size
	elseif (type(inc_control_size) == layout_manager_options.utility.table) then
		return inc_control_size.width
	else
		--TODO: (Phase 2) Logging
		return nil
	end
end

--- This function gets the vertical padding of the control (on the top and bottom)
-- @function get_padding_vertical
-- @param padding, the padding in a table or number format
-- @return the vertical padding of a control, in a table of top and bot
local function get_padding_vertical(padding)
	local padding_table = {}
	if (type(padding) == layout_manager_options.utility.number)then
		padding_table.top = padding
		padding_table.bot = padding
	elseif (type(padding) == layout_manager_options.utility.table)then
		padding_table.top = padding.top or padding.vertical or padding.bot -- or logging
		padding_table.bot = padding.bot or padding.vertical or padding.top -- or logging
	else
		--TODO: (Phase 2) Logging
	end
	return padding_table
end

--- This function gets the horizontal padding of the control (on the left and right)
-- @function get_padding_horizontal
-- @param padding, the padding in a table or number format
-- @return the vertical padding of a control, in a table of left and right
local function get_padding_horizontal(padding)
	local padding_table = {}
	if (type(padding) == layout_manager_options.utility.number) then
		padding_table.left = padding
		padding_table.right = padding
	elseif (type(padding) == layout_manager_options.utility.table) then
		padding_table.left = padding.left or padding.horizontal or padding.right -- or logging
		padding_table.right = padding.right or padding.horizontal or padding.left -- or logging
	else
		--TODO: (Phase 2) Logging
	end
	return padding_table
end

--- This function gets the layer or screen width to center objects along it
-- @function get_layer_width
-- @tparam #string layer_name, the name of the layer
-- @return A number representing the layer width
local function get_layer_width(layer_name)
	if (layer_name) then
		local layer_params = gre.get_layer_attrs(layer_name, layout_manager_options.utility.width)
		if (layer_params[layout_manager_options.utility.width]) then
			return layer_params[layout_manager_options.utility.width]
		else
			return helpers:get_screen_width()
		end
	else
		return helpers:get_screen_width()
	end
end

--- This function gets the layer or screen height to center objects along it
-- @function get_layer_height
-- @tparam #string layer_name, the name of the layer
-- @return A number representing the layer height
local function get_layer_height(layer_name)
	if (layer_name) then
		local layer_params = gre.get_layer_attrs(layer_name, layout_manager_options.utility.height)
		if (layer_params[layout_manager_options.utility.height]) then
			return layer_params[layout_manager_options.utility.height]
		else
			return helpers:get_screen_height()
		end
	else
		return helpers:get_screen_height()
	end
end

--- This function handles getting a specific x position for a control
-- @function get_control_x_position
-- @tparam #table inc_params, the params filled with defaults
-- @tparam #number col, the col number the control is on
-- @tparam #number layer_width, the width of the layer
-- @tparam #number layer_height, the height of the layer
-- @tparam #table control_sizes, the sizes of the control and padding
-- @return a number representing the x_position of a control 
local function get_control_x_position(inc_params, col, layer_width, layer_height, control_sizes)
	local control_size = inc_params.control_size
	local padding = inc_params.padding
	local alignment = inc_params.alignment
	local orientation = inc_params.orientation

	local width, padding_left, padding_right
	width = control_sizes.width

	local padding_table = get_padding_horizontal(padding)
	padding_left = padding_table.left
	padding_right = padding_table.right

	local xpos = (width + padding_left + padding_right) * (col - 1)

	if (orientation == layout_manager_options.orientation.vertical) then
		if (alignment == layout_manager_options.alignment.center) then
			local center_offset = (layer_width/2) - ((inc_params.max_col * (width + padding_left + padding_right)) / 2)
			xpos = xpos + center_offset
		elseif (alignment == layout_manager_options.alignment.justify) then
			--TODO: (Phase 2) Change up based on amounts visible per column
			if (col > 1) then
				local justified_padding = (layer_width - (inc_params.max_col * (width + padding_left + padding_right))) / (inc_params.max_col - 1)
				xpos = xpos + (justified_padding * (col - 1))
			end
			xpos = xpos + padding_left
		else
			xpos = xpos + padding_left
		end
	else
		xpos = xpos + padding_left
	end

	return xpos
end

--- This function handles getting a specific y position for a control
-- @function get_control_x_position
-- @tparam #table inc_params, the params filled with defaults
-- @tparam #number row, the row number the control is on
-- @tparam #number layer_width, the width of the layer
-- @tparam #number layer_height, the height of the layer
-- @tparam #table control_sizes, the sizes of the control and padding
-- @return a number representing the x_position of a control 
local function get_control_y_position(inc_params, row, layer_width, layer_height, control_sizes)
	local control_size = inc_params.control_size
	local padding = inc_params.padding
	local alignment = inc_params.alignment
	local orientation = inc_params.orientation

	local height, padding_top, padding_bot
	height = control_sizes.height

	local padding_table = get_padding_vertical(padding)
	padding_top = padding_table.top
	padding_bot = padding_table.bot

	local ypos = (height + padding_top + padding_bot) * (row - 1)

	if (orientation == layout_manager_options.orientation.horizontal) then
		if (alignment == layout_manager_options.alignment.center) then
			local center_offset = (layer_height/2) - ((inc_params.max_row * (height + padding_top + padding_bot)) / 2)
			ypos = ypos + center_offset
		elseif (alignment == layout_manager_options.alignment.justify) then
			--TODO: (Phase 2) Change up based on amounts visible per column
			if (row > 1) then
				local justified_padding = (layer_height - (inc_params.max_row * (height + padding_top + padding_bot))) / (inc_params.max_row - 1)
				ypos = ypos + (justified_padding * (row - 1))
			end
			ypos = ypos + padding_top
		else
			ypos = ypos + padding_top
		end
	else
		ypos = ypos + padding_top
	end

	return ypos
end

--- This function gets the row and column index that the control is on
-- @function get_row_col
-- @tparam #number inc_row, the current row
-- @tparam #number inc_col, the current column
-- @tparam #table inc_params, the params inputted by the user, filled with defaults
-- @tparam #table inc_control_sizes, the sizes of the controls
-- @return row, col
local function get_row_col(inc_row, inc_col, inc_params, inc_control_sizes)

	local max_row = inc_control_sizes.max_row
	local max_col = inc_control_sizes.max_col
	local orientation = inc_params.orientation
	local row, col

	--for vertical check col number and increase rows. For Horizontal flip that
	--first setup the inital 1,1 position.
	if (inc_row == 0 and inc_col == 0) then
		return 1,1
	end

	if (orientation == layout_manager_options.orientation.vertical) then
		col = inc_col + 1
		if (col > max_col) then
			col = 1
			row = inc_row + 1
			if (max_row and row > max_row) then
				return false, false
			end
		else
			row = inc_row
		end
		return row, col
	else
		row = inc_row + 1
		if(row > max_row)then
			row = 1
			col = inc_col + 1
			if (max_col and col > max_col) then
				return false, false
			end
		else
			col = inc_col
		end
		return row, col
	end
end

--- This function calculates how much the y position must be pushed down to account for the header
-- @function get_header_addition
-- @tparam #table, header. A table of the header options
-- @return A number to push the y position down
local function get_header_addition(header)
	if (header == nil) then
		return 0
	end

	local header_addition = header.height + header.padding_top + header.padding_bot
	return header_addition
end

--- This function gets the positions of a indexed item
-- @function get_positions
-- @tparam #table inc_params, the params, filled by defaults
-- @tparam #table control_sizes, the sizes of the controls, resized if asked for
-- @tparam #table header, the header options, if applicable
local function get_positions(inc_params, control_sizes, header)
	local positions = {}
	local row = 0
	local col = 0

	local layer_width = get_layer_width(inc_params.layer)
	local layer_height = get_layer_height(inc_params.layer)
	local header_addition = get_header_addition(header)

	for i = 1, inc_params.item_amount do
		row, col = get_row_col(row,col,inc_params, control_sizes)
		if (row == false and col == false) then
			break
		end

		local xpos = get_control_x_position(inc_params, col, layer_width, layer_height, control_sizes)
		local ypos = get_control_y_position(inc_params, row, layer_width, layer_height, control_sizes) + header_addition

		local tmp_position_table = {}
		tmp_position_table.index = i
		tmp_position_table.col = col
		tmp_position_table.row = row
		tmp_position_table.xpos = xpos
		tmp_position_table.ypos = ypos
		tmp_position_table.height = control_sizes.height
		tmp_position_table.width = control_sizes.width

		table.insert(positions, tmp_position_table)
	end

	return positions
end

--- This function sets up the sizes of the controls based on the user params
-- @function setup_sizes
-- @tparam #table, inc_params, the paramaters of the layout, filled with defaults.
-- @return a table with the control sizes, max row and col
local function setup_sizes(inc_params)
	local layer_width = get_layer_width(inc_params.layer)
	local layer_height = get_layer_height(inc_params.layer)
	local dynamic_resize_params = inc_params.dynamic_resize

	local control_size = {}
	control_size.width = get_control_width(inc_params.control_size)
	control_size.height = get_control_height(inc_params.control_size)
	control_size.max_col = inc_params.max_col
	control_size.max_row = inc_params.max_row

	local padding_table_horizontal = get_padding_horizontal(inc_params.padding)
	local padding_table_vertical = get_padding_vertical(inc_params.padding)
	local padding_vertical = padding_table_vertical.bot + padding_table_vertical.top
	local padding_horizontal = padding_table_horizontal.left + padding_table_horizontal.right
	control_size.padding_left = padding_table_horizontal.left
	control_size.padding_right = padding_table_horizontal.right
	control_size.padding_top = padding_table_vertical.top
	control_size.padding_bot = padding_table_vertical.bot

	if(inc_params.dynamic_resize)then
		for i = 1, dynamic_resize_params.steps do
			local test_width = (control_size.width + padding_horizontal) * dynamic_resize_params.multiplier
			local test_height = (control_size.height + padding_vertical) * dynamic_resize_params.multiplier
			local amount_col = math.floor(layer_width/ test_width)
			local amount_row = math.floor(layer_height / test_height)
			local amount_fit = amount_col * amount_row
			if (amount_fit < inc_params.item_amount) then
				break
			else
				control_size.width = control_size.width * dynamic_resize_params.multiplier
				control_size.height = control_size.height * dynamic_resize_params.multiplier
				control_size.max_col = amount_col
				control_size.max_row = amount_row
			end
		end
	end
	return control_size
end

--- This function gets the width of the header or footer
-- @function get_header_or_footer_width
-- @tparam #table, options the options for the header or footer
-- @tparam #table, control_sizes, the sizes of the controls
-- @tparam #number, the full width of the controls at max column
-- @tparam #layer_width, the width of the layer or screen
-- @return a number representing the width of the footer or header
local function get_header_or_footer_width(options, control_sizes, full_control_width, layer_width)
	local width
	if (type(options.width) == layout_manager_options.utility.number) then
		width = options.width
	elseif (options.width == layout_manager_options.header_and_footer.col_width) then
		width = (options.col_width * full_control_width)- (control_sizes.padding_left + control_sizes.padding_right)
	elseif (options.width == layout_manager_options.header_and_footer.fill) then
		width = get_layer_width(options.layer)
	else
		width = (control_sizes.max_col * full_control_width) - (control_sizes.padding_left + control_sizes.padding_right)
	end
	return width
end

--- This function gets the height of the header or footer
-- @function get_header_or_footer_height
-- @tparam #table, options the options for the header or footer
-- @tparam #number, base_control-size, the size of the base control, not resized.
-- @tparam #table, control_sizes, the sizes of the controls
-- @return a number representing the height of the footer or header
local function get_header_or_footer_height(options, base_control_size, control_sizes)
	local height
	if (type(options.height) == layout_manager_options.utility.number) then
		height = options.height
	elseif (options.height == layout_manager_options.header_and_footer.base_size) then
		height = get_control_height(base_control_size)
	else
		height = control_sizes.height
	end
	return height
end

--- This function gets the position of the header or footer
-- @function get_header_or_footer_width
-- @tparam #table, options the options for the header or footer
-- @tparam #table, control_sizes, the sizes of the controls
-- @tparam #number header_width, the width of the header
-- @tparam #layer_width, the width of the layer or screen
-- @tparam #number, the full width of the controls at max column
-- @return a number representing the xpos of the footer or header
local function get_header_or_footer_position(options, control_sizes, header_width, layer_width, full_control_width)
	local xpos = {}
	if (options.alignment == layout_manager_options.header_and_footer.left) then
		xpos = 0
	elseif (options.alignment == layout_manager_options.header_and_footer.first_column) then
		xpos = control_sizes.padding_left
	elseif (options.alignment == layout_manager_options.header_and_footer.right) then
		xpos = (full_control_width * control_sizes.max_col) - header_width - control_sizes.padding_right
	else
		xpos = (layer_width/2) - (header_width/2)
	end
	return xpos
end

--- This function sets up the header
-- @function setup_header
-- @tparam #table paramater_table, the paramaters of the header
-- @tparam #table control_sizes, a table of the control sizes
-- @return A table of the header paramaters and positions
local function setup_header(paramater_table, control_sizes)
	local header_defaults = defaults:get_header_defaults()
	local options = paramater_table.header
	local base_control_size = paramater_table.control_size
	if (options == nil) then
		return nil
	end

	local header_params = {}
	local full_control_width = control_sizes.width + control_sizes.padding_left + control_sizes.padding_right
	local layer_width = get_layer_width(options.layer)

	header_params.width = get_header_or_footer_width(options, control_sizes, full_control_width, layer_width)
	header_params.height = get_header_or_footer_height(options, base_control_size, control_sizes)
	header_params.xpos = get_header_or_footer_position(options, control_sizes, header_params.width, layer_width, full_control_width)
	header_params.ypos = options.padding_top or header_defaults.padding_top
	header_params.padding_top = options.padding_top or header_defaults.padding_top
	header_params.padding_bot = options.padding_bot or header_defaults.padding_bot
	return header_params
end

--- This function sets up the header
-- @function setup_header
-- @tparam #table paramater_table, the paramaters of the header
-- @tparam #table control_sizes, a table of the control sizes
-- @tparam #table header, the header paramaters
-- @return A table of the header paramaters and positions
local function setup_footer(paramater_table, control_sizes, header)
	local footer_defaults = defaults:get_header_defaults()
	local options = paramater_table.footer
	local base_control_size = paramater_table.control_size
	if (options == nil) then
		return nil
	end

	local footer_params = {}
	local full_control_width = control_sizes.width + control_sizes.padding_left + control_sizes.padding_right
	local full_control_height = control_sizes.height + control_sizes.padding_top + control_sizes.padding_bot
	local layer_width = get_layer_width(options.layer)

	footer_params.width = get_header_or_footer_width(options, control_sizes, full_control_width, layer_width)
	footer_params.height = get_header_or_footer_height(options, base_control_size, control_sizes)
	footer_params.xpos = get_header_or_footer_position(options, control_sizes, footer_params.width, layer_width, full_control_width)
	footer_params.ypos = (full_control_height * (control_sizes.max_row)) + get_header_addition(header)
	footer_params.padding_top = options.padding_top or footer_defaults.padding_top
	return footer_params
end

--- This function sets up the grid layout
-- @function setup
-- @tparam #table inc_params, the parameters of the grid layout
-- @return a table of positions header, footer, and items if applicable
function grid_layout:setup(inc_params)
	local paramater_table = fill_defaults(inc_params)
	local control_sizes = setup_sizes(paramater_table)
	local header = setup_header(paramater_table, control_sizes)
	local footer = setup_footer(paramater_table, control_sizes, header)
	local items = get_positions(paramater_table, control_sizes, header)
	local positions = {
		header = header,
		footer = footer,
		items = items
	}
	return positions
end

return grid_layout