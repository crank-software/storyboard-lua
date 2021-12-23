local lu = require('luaunit')
local log = require('sb_logging')
-- class Test

--Test the sb_logging 
TestLogging = {} --class

function TestLogging:SetUp()
  print("TestLogging:setUp() called")
  log.new("test")
end

function TestLogging:TearDown()
   print("TestLogging:setDown() called")
end

function TestLogging:test_expected_error_msg()
  log:set_log_level(log.log_levels.GR_LOG_INFO)
  local errorMsg = "Ants in France"
  lu.assertError(sb_logging:log_error(errorMsg))
  lu.assertError(sb_logging:log_warning(errorMsg))
  lu.assertError(sb_logging:log_info(errorMsg))
end 

