--- 
-- Copyright 2019, Crank Software Inc.
-- All Rights Reserved.
-- For more information email info@cranksoftware.com
-- 
local logger = require('sb_logging')

---
-- @module temperature
--  This class contains functions to convert measurements between metric and imperial 
sb_temperature = {}
sb_temperature.__index = sb_temperature

--- System of measurement types 
-- @field metric system of measurement is metric
-- @field imperial system of measurement is imperial 
-- @table constants
sb_temperature.system_type = {
    METRIC = 0, 
    IMPERIAL = 1
}

--- 
-- Create a new measurement instance 
function sb_temperature.new()
  local self = setmetatable({}, sb_temperature)
  self:init()
  logger.new("sb_temperature")
  return self
end 

---
-- Initialize the module
-- @param input the incoming system of measurement of the backend system
-- @param output default system of measurement 
function sb_temperature:init()
  self.system_of_measurement_out = self.system_type.METRIC
  self.system_of_measurement_in = self.system_type.METRIC
end 

---
-- Set the system of measurement for output (Displayed to user) 
-- @param value output system of measurement 
function sb_temperature:set_system_of_measurement_output(value)
  if (value  ~= self.system_type.IMPERIAL and value  ~= self.system_type.METRIC) then 
    -- TODO replace with logging class. 
    logger:log_error("set_system_of_measurement: value out of range")
    return
  end 
  self.system_of_measurement_out = value 
end

---
-- Get the system of measurement for output
function sb_temperature:get_system_of_measurement_output()
  return self.system_of_measurement_out
end 

---
-- Set the input system of measurement 
-- @param value input the incoming system of measurement of the backend system
function sb_temperature:set_system_of_measurement_input(value)
  if (value  ~= self.system_type.IMPERIAL and value  ~= self.system_type.METRIC) then 
    -- TODO replace with logging class. 
    logger:log_error("set_system_of_measurement: value out of range")
    return
  end 
  self.system_of_measurement_in = value 
end 

---
-- Get the input system of measurement 
function sb_temperature:get_system_of_measurement_input()
  return self.system_of_measurement_in
end 

---
-- Convert temperature to metric from imperial
-- @param temperature in metric 
function sb_temperature:convert_temperature_to_metric(temperature)
  return (temperature -32)*5/9
end 

---
-- Convert temperature to imperial to metric
-- @param temperature in imperial 
function sb_temperature:convert_temperature_to_imperial(temperature)
  return (temperature * 9/5) + 32
end 

---
-- Convert temperature to metric from imperial
-- @param temperature in metric 
function sb_temperature:convert_temperature(temperature)
  local output_temperature = temperature
  if (self.system_of_measurement_in == self.system_type.METRIC and  
      self.system_of_measurement_out == self.system_type.IMPERIAL) then 
      output_temperature = self:convert_temperature_to_imperial(temperature)
  elseif (self.system_of_measurement_in == self.system_type.IMPERIAL and 
     self.system_of_measurement_out == self.system_type.METRIC) then
     output_temperature = self: convert_temperature_to_metric(temperature)
  end 
  return output_temperature
end 


-- Create and return singlton instance
return sb_temperature.new()