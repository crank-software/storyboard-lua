---V 0.1 – Phase 1. Last Updated 03/12/21

--- This file directs all of the calls of certain layouts to the correct scripts.
-- TODO: (Phase 2) Add in the fill and best fit options

local grid_layout = require('layout_manager.grid_layout')

local layout_manager = {}

--- This function sets up the grid layout
-- @function setup_grid_layout
-- @tparam #table inc_params, the parameters of the grid layout
-- @return a table of positions header, footer, and items if applicable
function layout_manager:setup_grid_layout(inc_params)
    return grid_layout:setup(inc_params)
end

return layout_manager