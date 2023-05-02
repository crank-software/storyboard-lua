---V 0.1 – Phase 1. Last Updated 03/12/21

--- A small helper script that will allow us to get simple sizes and values about the app

local helpers = {}

local screen_size = {
	height = nil,
	width = nil
}

--- This function fills the screen_size table
-- @function fill_screen_size_table
local function fill_screen_size_table()
	if(screen_size.width == nil and screen_size.height == nil)then
		local env =
			gre.env(
				{
					'screen_width',
					'screen_height'
				}
			)

		screen_size.width = env.screen_width
		screen_size.height = env.screen_height
	end
end

---@function get_screen_size
--@return a table of the screen_size
function helpers:get_screen_size()
	fill_screen_size_table()
	return screen_size
end

---@function get_screen_height
--@return a number of the screen height
function helpers:get_screen_height()
	fill_screen_size_table()
	return screen_size.height
end

---@function get_screen_width
--@return a number of the screen width
function helpers:get_screen_width()
	fill_screen_size_table()
	return screen_size.width
end

return helpers
