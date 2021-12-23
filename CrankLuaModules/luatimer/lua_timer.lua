---
-- Copyright 2020, Crank Software Inc.
-- All Rights Reserved.
-- For more information email info@cranksoftware.com
--
-- Based this pure lua heap timer implementation on this: https://gist.github.com/starwing/1757443a1bd295653c39
--
-- It should be known that this simple timer implementation uses gre.thread_create to create a timer thread.
-- Given that Lua has minimal thread synchronization, this should not be used when heavy timer usage is expected.
--

-- thread id and timer heap
local thread_start = false
local timers = {}

-- get time in milliseconds
local get_mstime = gre.mstime

-- timer thread function, implemented below
local timer_thread

-- use usleep for the sleep function
local use_usleep = true

---
-- Spin and sleep for a time in milliseconds
-- @param time - Time to sleep in ms
local function sleep(time)
  if (use_usleep) then
    -- us os.usleep
    os.usleep(time * 1000)
  else
    -- otherwise loop until sleep is complete
    local ntime = get_mstime() + time
    repeat until get_mstime() > ntime
  end
end

---
-- Start the timer thread if needed
-- 
local function start_timer_thread()
  if (thread_start == false) then
    gre.thread_create(timer_thread)
  end
end

---
-- Insert a new timer
-- @param t - The new timer to insert
-- @return the newly added timer
local function insert_timer(t)
  local index = #timers + 1
  t.index = index
  timers[index] = t
  while index > 1 do
    local parent = math.floor(index/2)
    if timers[parent].expire <= t.expire then
      break
    end
    
    timers[index], timers[parent] = timers[parent], timers[index]
    timers[index].index = index
    timers[parent].index = parent
    index = parent
  end
  
  start_timer_thread()
  
  return t
end

---
-- Remove a timer
-- @param t - The timer to remove
local function remove_timer(t)
  if (timers[t.index] ~= t) then
    return
  end
  
  local index = t.index
  local heap_size = #timers
  if (index == heap_size) then
    timers[heap_size] = nil
    return
  end
  
  timers[index] = timers[heap_size]
  timers[index].index = index
  timers[heap_size] = nil
  
  while true do
    local left, right = math.floor(index*2), math.floor(index*2)+1
    local newindex = right
    if not timers[left] then
      break
    end
    
    if timers[index].expire >= timers[left].expire then
      if not timers[right] or timers[left].expire < timers[right].expire then
        newindex = left
      end
    elseif not timers[right] or timers[index].expire <= timers[right].expire then
      break
    end
    timers[left], timers[newindex] = timers[newindex], timers[index]
    timers[index].index = index
    timers[newindex].index = newindex
    index = newindex  
  end
end

---
-- Timer is expired, fire callback and re-insert timer if a interval timer
-- @param t - The timer to fire
-- 
local function timer_fire(t) 
  remove_timer(t)
  
  local cb = t.cb
  if cb and type(cb) == "function" then
    cb()
  end
  
  if (t.interval > 0) then
    local time = get_mstime()
    t.start = time
    t.expire = t.start + t.interval
  
    insert_timer(t)
  end
end

---
-- Check for any expired timers
-- 
local function check_timers()
  local time = get_mstime()
  local t = timers[1]
  while t and time >= t.expire do
    timer_fire(t)
    t = timers[1]
  end
end

---
-- Timer thread implementation
-- 
timer_thread = function()
  thread_start = true
  
  while(timers[1] ~= nil) do
    local next_time = timers[1] and timers[1].expire
    local time = get_mstime()
    if (next_time > time) then
      sleep(next_time - time)
    end
    check_timers()
  end
  
  thread_start = false
end

---
-- Mock gre function to clear a interval timers
-- @param t - The timer to clear
-- 
local function lua_timer_clear_interval(t)
  remove_timer(t)
end

---
-- Mock gre function to clear a timeout timer
-- @param t - The timer to clear
-- 
local function lua_timer_clear_timeout(t)
  remove_timer(t)
end

---
-- Mock gre function to set a interval timer
-- @param cb - Callback function
-- @param interval - Interval time
-- @return the new timer
local function lua_timer_set_interval(cb, interval)
  local t = {}
  t.start = get_mstime()
  t.expire = t.start + interval
  t.interval = interval
  t.cb = cb
  
  return insert_timer(t)
end

---
-- Mock gre function to set a timeout timer
-- @param cb - Callback function
-- @param interval - Timeout time
-- @return the new timer
local function lua_timer_set_timeout(cb, timeout)
  local t = {}
  t.start = get_mstime()
  t.expire = t.start + timeout
  t.interval = 0
  t.cb = cb
  
  return insert_timer(t)
end

-- replace the gre timer functions with our mock ones
gre.timer_clear_interval  = lua_timer_clear_interval
gre.timer_clear_timeout   = lua_timer_clear_timeout
gre.timer_set_interval    = lua_timer_set_interval
gre.timer_set_timeout     = lua_timer_set_timeout