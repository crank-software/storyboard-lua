local lu = require('luaunit')
local temperature = require('sb_temperature')
-- class Test

TestTemperature = {} --class
function TestTemperature:setUp()
  temperature.new()
end

function TestTemperature:tearDown()

end

function TestTemperature:test_system_of_measurement_output()
  temperature:init()
  local output = temperature:get_system_of_measurement_output()
  lu.assertEquals(output, temperature.system_type.METRIC)

  temperature:set_system_of_measurement_output(temperature.system_type.METRIC)
  local output = temperature:get_system_of_measurement_output()
  lu.assertEquals(output, temperature.system_type.METRIC)
  
  temperature:set_system_of_measurement_output(temperature.system_type.IMPERIAL)
  local output = temperature:get_system_of_measurement_output()
  lu.assertEquals(output, temperature.system_type.IMPERIAL)
  
    temperature:set_system_of_measurement_output(5)
  local output = temperature:get_system_of_measurement_output()
  lu.assertNotEquals(output, 5)
end 

function TestTemperature:test_system_of_measurement_input()
  temperature:init()
  local input = temperature:get_system_of_measurement_input()
  lu.assertEquals(input, temperature.system_type.METRIC)

  temperature:set_system_of_measurement_input(temperature.system_type.METRIC)
  local input = temperature:get_system_of_measurement_input()
  lu.assertEquals(input, temperature.system_type.METRIC)
  
  temperature:set_system_of_measurement_input(temperature.system_type.IMPERIAL)
  local input = temperature:get_system_of_measurement_input()
  lu.assertEquals(input, temperature.system_type.IMPERIAL)
  
    temperature:set_system_of_measurement_input(5)
  local input = temperature:get_system_of_measurement_input()
  lu.assertNotEquals(input, 5)
end 

function  TestTemperature:test_conversion_metric_to_imperial()
  local temp = temperature:convert_temperature_to_imperial(0)
  lu.assertEquals(temp, 32)
  temp = temperature:convert_temperature_to_imperial(100)
  lu.assertEquals(temp, 212)
  temp = temperature:convert_temperature_to_imperial(-40)
  lu.assertEquals(temp, -40)
end 

function  TestTemperature:test_conversion_imperial_to_metric()
  local temp = temperature:convert_temperature_to_metric(32)
  lu.assertEquals(temp, 0)
  temp = temperature:convert_temperature_to_metric(212)
  lu.assertEquals(temp, 100)
  temp = temperature:convert_temperature_to_metric(-40)
  lu.assertEquals(temp, -40)
end 

function  TestTemperature:test_conversion_automatic()
 -- self:set_up()
  temperature:set_system_of_measurement_output(temperature.system_type.IMPERIAL)
  temperature:set_system_of_measurement_input(temperature.system_type.METRIC)
  local temp = temperature:convert_temperature(0)
  lu.assertEquals(temp, 32)
  temp = temperature:convert_temperature(100)
  lu.assertEquals(temp, 212)
  
  temperature:set_system_of_measurement_output(temperature.system_type.METRIC)
  temp = temperature:convert_temperature(0)
  lu.assertEquals(temp, 0)
  
  temperature:set_system_of_measurement_input(temperature.system_type.IMPERIAL)
  temp = temperature:convert_temperature(0)
  lu.assertAlmostEquals(temp, -18, 0.5)
  
end 

