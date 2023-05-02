---
-- Copyright 2020, Crank Software Inc. All Rights Reserved.
--
-- For more information email info@cranksoftware.com.
--

local clone_object = {}

---
-- Initializes a new instance of this class
function clone_object.new()
	local self = {}
	self.clone_pools = {}
	setmetatable(self, {__index = clone_object})
	return self
end

---
-- Helper function to create a pool
local function create_pool()
	local pool = {}
	pool.used = {}
	pool.free = {}

	return pool
end

---
-- Helper function to get a pool for a template name
-- @param self An instance of the clone_object class
-- @param name The name of the object template to search for
local function get_pool(self, name)
	local pool = self.clone_pools[name]
	if (pool == nil) then
		pool = create_pool()
		self.clone_pools[name] = pool
	end

	return pool
end

---
-- Helper function to get the index for the cloned object in a pool
-- @param pool Pool to search
-- @param name Name to search for
local function get_clone_index(pool, name)
	local index = nil

	for i = 1, #pool do
		if (pool[i] == name) then
			index = i
			break
		end
	end

	return index
end

---
-- Helper function to find the correct pool for a cloned control
-- @param self An instance of the clone_object class
-- @param name The name of the cloned control to search for
local function find_pool_for_clone(self, name)
	local found = nil

	for _, v in pairs(self.clone_pools) do
		local pool = v.used
		if (get_clone_index(pool, name) ~= nil) then
			found = v
			break
		end

		pool = v.free
		if (get_clone_index(pool, name) ~= nil) then
			found = v
			break
		end
	end

	return found
end

local function set_data(clone, data_tbl)
	local data = {}

	for key, value in pairs(data_tbl) do
		local var = string.format('%s.%s', clone, key)
		data[var] = value
	end

	gre.set_data(data)
end

local function generate_unused_name(self, layer, base_name)
	local name
	local num = 1
	while (1) do
		name = string.format('%s%d', base_name, num)
		if (self:does_clone_exist(layer .. '.' .. name) == false) then
			break
		end

		num = num + 1
	end

	return name
end

function clone_object:does_clone_exist(clone)
	if (find_pool_for_clone(self, clone) == nil) then
		return false
	end

	return true
end

---
-- Gets the count of used and free clones for an object
-- @param object The path to the object we're looking for clones of
function clone_object:get_clone_count(object)
	local used = 0
	local free = 0
	local pool = get_pool(self, object)
	if (pool ~= nil) then
		used = #pool.used
		free = #pool.free
	end

	return {used = used, free = free}
end

---
-- Get all the names of the clones for a certain object
-- @param object The object to look for clones of
function clone_object:get_clone_object_names(object)
	local pool = get_pool(self, object)
	local list = {}

	for i = 1, #pool.used do
		table.insert(list, pool.used[i])
	end

	return list
end

---
-- Clones an object. If a free clone is available it will
-- use that instead of creating a new one.
-- @param object The object to clone
-- @param layer The layer to clone to
-- @param name_template The base name to use for the new clone
function clone_object:clone(object, layer, name_template, data)
	local pool = get_pool(self, object)
	local num_unused = #(pool.free)
	local clone_name
	local clone_path

	if (data == nil) then
		data = {}
	end

	data['grd_hidden'] = false

	if (num_unused > 0) then
		clone_path = table.remove(pool.free)
	else
		local num_used = #(pool.used)
		-- find
		--clone_name = string.format("%s%d", name_template, num_used+1)
		clone_name = generate_unused_name(self, layer, name_template)
		clone_path = string.format('%s.%s', layer, clone_name)
		gre.clone_object(object, clone_name, layer)
	end

	set_data(clone_path, data)

	table.insert(pool.used, clone_path)

	return clone_path
end

---
-- Frees a clone, moves a clone from the used list to the free list.
-- @param name The name of the clone to free
-- @param data A list of variable & values to set on the cloned control
function clone_object:free(name, data)
	local pool = find_pool_for_clone(self, name)
	if (pool == nil) then
		return
	end

	local index = get_clone_index(pool.used, name)
	if (index == nil) then
		return
	end

	if (data == nil) then
		data = {}
	end

	local clone = table.remove(pool.used, index)
	data['grd_hidden'] = true
	set_data(clone, data)
	table.insert(pool.free, clone)
end

---
-- Deletes a cloned control
function clone_object:delete(name)
	local clone
	local pool = find_pool_for_clone(self, name)
	if (pool == nil) then
		return
	end

	-- look for clone in the used pool
	local index = get_clone_index(pool.used, name)
	if (index == nil) then
		-- not used, must be free
		index = get_clone_index(pool.free, name)
		if (index == nil) then
			-- clone doesn't exist?????
			return
		end

		clone = table.remove(pool.free, index)
	else
		clone = table.remove(pool.used, index)
	end

	gre.delete_object(clone)
end
---
-- Deletes all clones created though an instance of the clone_object class
function clone_object:delete_all()
	-- iterate through all the clone pools
	for _, pool in pairs(self.clone_pools) do
		-- delete used objects
		for _, v in pairs(pool.used) do
			gre.delete_control(v)
		end
		pool.used = {}

		-- delete free objects
		for _, v in pairs(pool.free) do
			gre.delete_object(v)
		end
		pool.free = {}
	end

	self.clone_pools = {}
end

return clone_object.new()
