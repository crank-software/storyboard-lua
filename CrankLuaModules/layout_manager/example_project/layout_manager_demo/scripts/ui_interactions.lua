--- This is a sample file to show how to call into the layout_manager. It will take all of the params that are inputted and once a layout is generated, generate generic cloned controls and print out all of the positions

--- Our Layout Manager script
local layout_manager = require('layout_manager.layout_manager')
local layout_manager_options = require('layout_manager.layout_manager_options')

---A basic clone_object script for ease of use.
local clone_object = require('other_common_code.clone_object')

---This function sets up a grid layout based on the params inputted.
--@function cb_setup_grid_layout
function cb_setup_grid_layout()
	local params = {
		[layout_manager_options.grid_layout_params.max_col] = nil,--max rows and columns. Is overwritten by a dynamic resize
		[layout_manager_options.grid_layout_params.max_row] = nil,
		[layout_manager_options.grid_layout_params.alignment] = layout_manager_options.alignment.center, -- left, center, justify, works best when given a layer to center or justify within, will default to screen size
		[layout_manager_options.grid_layout_params.orientation] = layout_manager_options.orientation.vertical, --'vertical', 'horizontal', make sure to set the scrolling to the same orientation to scroll if we need to.
		[layout_manager_options.grid_layout_params.control_size] = {
			[layout_manager_options.control_size.width] = 100, 
			[layout_manager_options.control_size.height] = 50
		}, --{width = x, height = x } or = x , for squares can also just be a number
		
		[layout_manager_options.grid_layout_params.padding] = nil, -- {vertical, horizontal or left,right,top,bot}. Like above can be a number across for all 4, or vertical/horizontal or left, right, top, bot
		[layout_manager_options.grid_layout_params.layer] = 'grid_layout', --layer name. Helps for the alignment and for dynamic resize
		[layout_manager_options.grid_layout_params.item_amount] = 15, --item amount for item resize, otherwise gives default amount back (that can be changed)
		[layout_manager_options.grid_layout_params.dynamic_resize] = {
			[layout_manager_options.dynamic_resize.steps] = 10, 
			[layout_manager_options.dynamic_resize.multiplier] = 1.25
		}, --{steps, multiplier}. How many steps the user wants to walk through of resizing, and the multiplier up from the control size as it tries to increase.
		[layout_manager_options.grid_layout_params.header] = {
			[layout_manager_options.header_and_footer.alignment] = layout_manager_options.header_and_footer.first_column, 
			[layout_manager_options.header_and_footer.width] = layout_manager_options.header_and_footer.col_width, 
			[layout_manager_options.header_and_footer.col_width] = 2, 
			[layout_manager_options.header_and_footer.height] = layout_manager_options.header_and_footer.match
		}, --can give specifics for width and height and alignment. Will use the screen to align or the layer depending. Height will b the height of a cell, be careful when dynamically sizing
		[layout_manager_options.grid_layout_params.footer] = {
			[layout_manager_options.header_and_footer.alignment] = layout_manager_options.header_and_footer.first_column,  
			[layout_manager_options.header_and_footer.width] = layout_manager_options.header_and_footer.match,
			[layout_manager_options.header_and_footer.height] = layout_manager_options.header_and_footer.base_size
		},
	}

	--Some small paramaters are above and nicely set up. Or you can comment out the below line and just play around with the settings above.
	local all_positions = layout_manager:setup_grid_layout(params)

	local data = {}

	print('----------  Header Entry  ----------')
	local header_name = clone_object:clone('clone_template', 'grid_layout', 'header')
	local header_params = all_positions.header
	for k,v in pairs(header_params)do
		print(k,v)
	end
	data[string.format('%s.grd_x', header_name)] = header_params.xpos
	data[string.format('%s.grd_y', header_name)] = header_params.ypos
	data[string.format('%s.grd_height', header_name)] = header_params.height
	data[string.format('%s.grd_width', header_name)] = header_params.width
	data[string.format('%s.grd_hidden', header_name)] = 0

	local item_positions = all_positions.items
	for i = 1, #item_positions do
		print('----------  Position Entry  ----------')
		local control_name = clone_object:clone('clone_template', 'grid_layout', 'test_clone')
		for k,v in pairs(item_positions[i]) do
			print(k,v)
		end
		data[string.format('%s.grd_x', control_name)] = item_positions[i].xpos
		data[string.format('%s.grd_y', control_name)] = item_positions[i].ypos
		data[string.format('%s.grd_height', control_name)] = item_positions[i].height
		data[string.format('%s.grd_width', control_name)] = item_positions[i].width
		data[string.format('%s.grd_hidden', control_name)] = 0
	end

	print('----------  Footer Entry  ----------')
	local footer_name = clone_object:clone('clone_template', 'grid_layout', 'header')
	local footer_params = all_positions.footer
	for k,v in pairs(footer_params)do
		print(k,v)
	end
	data[string.format('%s.grd_x', footer_name)] = footer_params.xpos
	data[string.format('%s.grd_y', footer_name)] = footer_params.ypos
	data[string.format('%s.grd_height', footer_name)] = footer_params.height
	data[string.format('%s.grd_width', footer_name)] = footer_params.width
	data[string.format('%s.grd_hidden', footer_name)] = 0
	data[string.format('grid_layout.clone_template.grd_hidden')] = 1
	gre.set_data(data)
end
