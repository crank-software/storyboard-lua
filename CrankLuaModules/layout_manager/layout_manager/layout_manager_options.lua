---V 0.1 – Phase 1. Last Updated 03/12/21

--- This file contains a lot of the options and string literals as variables to make sure spelling errors are not a thing
-- Do not set values in here, it is only for referencing.

local layout_manager_options = {}

--- Generic Strings used within this file and the manager code
local generic_strings = {
	left = 'left',
	right = 'right',
	center = 'center',
	vertical = 'vertical',
	horizontal = 'horizontal',
	width = 'width',
	height = 'height',
	number = 'number',
	table = 'table',
	alignment = 'alignment'
}

layout_manager_options.utility = {
	number = generic_strings.number,
	table = generic_strings.table,
	width = generic_strings.width,
	height = generic_strings.height
}

layout_manager_options.alignment = {
	left = generic_strings.left,
	center = generic_strings.center,
	justify = 'justify',
}

layout_manager_options.orientation = {
	vertical = generic_strings.vertical,
	horizontal = generic_strings.horizontal
}

layout_manager_options.control_size = {
	width = generic_strings.width,
	height = generic_strings.height
}

layout_manager_options.padding = {
	vertical = generic_strings.vertical,
	horizontal = generic_strings.horizontal,
	left = generic_strings.left,
	right = generic_strings.right,
	top = 'top',
	bot = 'bot'
}

layout_manager_options.dynamic_resize = {
	steps = 'steps',
	multiplier = 'multiplier'
}

layout_manager_options.header_and_footer = {
	alignment = generic_strings.alignment,
	width = generic_strings.width,
	col_width = 'col_width',
	fill = 'fill',
	height = generic_strings.height,
	left = generic_strings.left,
	right = generic_strings.right,
	first_column = 'first_column',
	base_size = 'base_size',
	match = 'match'
}

layout_manager_options.grid_layout_params = {
	max_col = 'max_col',
	max_row = 'max_row',
	alignment = generic_strings.alignment,
	orientation = 'orientation',
	control_size = 'control_size',
	padding = 'padding',
	layer = 'layer',
	item_amount = 'item_amount',
	dynamic_resize = 'dynamic_resize',
	header = 'header',
	footer = 'footer'
}

return layout_manager_options