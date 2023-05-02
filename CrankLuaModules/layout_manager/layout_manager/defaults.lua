---V 0.1 – Phase 1. Last Updated 03/12/21

local defaults = {}

local sizing_defaults = {
	control_size = 192,
	padding = 10
}

local layout_defaults = {
	alignment = 'left',
	orientation = 'vertical',
	max_col = 4,
	max_row = 2,
	item_amount = 25
}

local header_defaults = {
	padding_top = 5,
	padding_bot = 10
}

function defaults:get_sizing_defaults()
	return sizing_defaults
end

function defaults:get_layout_defaults()
	return layout_defaults
end

function defaults:get_header_defaults()
	return header_defaults
end


return defaults
