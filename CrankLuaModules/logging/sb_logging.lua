--- 
-- Copyright 2019, Crank Software Inc.
-- All Rights Reserved.
-- For more information email info@cranksoftware.com
-- 

---
-- @module sb_logging
--  This class contains functions to logging in lua utilizing gre.log routines. 
sb_logging = {}
sb_logging.__index = sb_logging

---
-- Log levels to match the gre.h definitions 
--
sb_logging.log_levels = {
  GR_LOG_ALWAYS = -1,       -- Always go to stdout
    GR_LOG_ERROR = 0,       -- Errors (fatal and non-fatal)
    GR_LOG_WARNING = 1,     -- Warnings
    GR_LOG_INFO = 2,        -- Information, one time, non-repetitive
    GR_LOG_EVENT1 = 3,      -- Event delivery, excluding motion/mtevent/redraws
    GR_LOG_ACTION = 4,      -- Action execution
    GR_LOG_DIAG1 = 5,       -- Storyboard diagnostic informative
    GR_LOG_DIAG2 = 6,       -- Storyboard diagnostic detailed
    GR_LOG_EVENT2 = 7,      -- Motion/mtevent/redraw event delivery
    GR_LOG_TRACE1 = 8,      -- Storyboard minimal tracing
    GR_LOG_TRACE2 = 9,      -- Storyboard maximum tracing
} 

function sb_logging:debug_format_msg(msg, ...)
  local dbg = debug.getinfo(2)
  local msg = string.format(msg, ...)
  local fmt = string.format("[%s:%s:%s:%s] %s", tostring(self.subsystem),  string.match(dbg.short_src, "^.*/(.*).lua$") , tostring(dbg.name), dbg.currentline, tostring(msg))  
  return fmt 
end
--- 
-- Create a new measurement instance 
function sb_logging.new(subsystem)
  local self = setmetatable({}, sb_logging)
  self:init(subsystem)
  return self
end 

---
-- Initialize the module
function sb_logging:init(subsystem)
  self.subsystem = subsystem or ""
end 

---
-- Set the log level of system
-- @param level - log level of type sb_logging.log_levels 
function sb_logging:set_log_level(level)
  local data = {} 
  data.verbosity = level
  gre.send_event_data("sbio.verbosity", "4s1:verbosity", data)
end 

---
-- Log an error message will be desplayed with verbosity of error or higher
-- @param msg format string to log
-- @param varargs arguements to pass informated string 
function sb_logging:log_error(msg, ...)  
  gre.log(self.log_levels.GR_LOG_ERROR, self:debug_format_msg(msg, ...))
end 

---
-- Log an warning message will be desplayed with verbosity of warning or higher
-- @param msg format string to log
-- @param varargs arguements to pass informated string 
function sb_logging:log_warning(msg, ...)
  gre.log(self.log_levels.GR_LOG_WARNING, self:debug_format_msg(msg, ...))
end

---
-- Log an info message will be desplayed with verbosity of info or higher
-- @param msg format string to log
-- @param varargs arguements to pass informated string 
function sb_logging:log_info(msg, ...)
  gre.log(self.log_levels.GR_LOG_INFO, self:debug_format_msg(msg, ...))
end

---
-- Log a traceback, to use for unexpected errors. 
-- @param msg format string to log
-- @param varargs arguements to pass informated string 
function sb_logging:traceback()
   gre.log(self.log_levels.GR_LOG_ERROR, debug.traceback())
end 

return sb_logging