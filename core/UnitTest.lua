---
-- Description of the module.
-- @module UnitTest
-- 
local UnitTest = {
  -- single-line comment
  classname = "HMUnitTest"
}

local event_binded = false
local unittest_running = false
local stage = 1

-------------------------------------------------------------------------------
-- Run
--
-- @function [parent=#UnitTest] run
--
-- @param #LuaEvent event
-- 
function UnitTest.run(event)
  Logging:trace(UnitTest.classname, "run()")
  if event_binded == false then
    Event.pcallEvent("on_tick", defines.events.on_tick, UnitTest.onTick)
  end
  Player.print("Unit Test running!")
  stage = 1
  unittest_running = true
end

-------------------------------------------------------------------------------
-- On tick
--
-- @function [parent=#UnitTest] onTick
-- 
-- @param #LuaEvent event
--
function UnitTest.onTick(event)
  if event.tick % 100 == 0 and unittest_running then
    UnitTest.execute(stage)
    stage = stage + 1
  end
end

-------------------------------------------------------------------------------
-- execute
--
-- @function [parent=#UnitTest] execute
-- 
-- @param #number stage
--
function UnitTest.execute(stage)
  if UnitTest.stage[stage] ~= nil then
    Player.print(UnitTest.stage[stage].description)
    UnitTest.stage[stage].test()
    Player.print("Stage "..stage.." completed")
  end
end

UnitTest.stage = {}
table.insert(UnitTest.stage, {description = "Open main panel", test = function()
  Controller.onGuiClick({player_index=Player.native().index, element = {valid=true, name="HMController=CLOSE"}})
  Controller.onGuiClick({player_index=Player.native().index, element = {valid=true, name="HMMainPanel=OPEN"}})
  Controller.sendEvent(nil, "HMMainTab", "change-tab", "HMProductionLineTab")
end})

table.insert(UnitTest.stage, {description = "Test help", test = function()
  Controller.sendEvent(nil, "HMHelpPanel", "OPEN")
  Controller.sendEvent(nil, "HMHelpPanel", "next-page")
end})

table.insert(UnitTest.stage, {description = "Test recipe selector", test = function()
  Controller.sendEvent(nil, "HMRecipeSelector", "OPEN")
  Controller.sendEvent(nil, "HMRecipeSelector", "recipe-group", "production")
end})

table.insert(UnitTest.stage, {description = "Test recipe selected", test = function()
  Controller.sendEvent(nil, "HMRecipeSelector", "element-select", "recipe", "assembling-machine-2")
end})

table.insert(UnitTest.stage, {description = "Test technology selector", test = function()
  Controller.sendEvent(nil, "HMTechnologySelector", "OPEN")
  Controller.sendEvent(nil, "HMTechnologySelector", "recipe-group", "infinite")
end})

table.insert(UnitTest.stage, {description = "Test container selector", test = function()
  Controller.sendEvent(nil, "HMContainerSelector", "OPEN")
  Controller.sendEvent(nil, "HMContainerSelector", "recipe-group", "other")
end})

table.insert(UnitTest.stage, {description = "Test energy tab", test = function()
  Controller.sendEvent(nil, "HMMainTab", "change-tab", "HMEnergyTab")
end})

table.insert(UnitTest.stage, {description = "Test resource tab", test = function()
  Controller.sendEvent(nil, "HMMainTab", "change-tab", "HMResourceTab")
end})

table.insert(UnitTest.stage, {description = "Test summary tab", test = function()
  Controller.sendEvent(nil, "HMMainTab", "change-tab", "HMSummaryTab")
end})

table.insert(UnitTest.stage, {description = "Test statistic tab", test = function()
  Controller.sendEvent(nil, "HMMainTab", "change-tab", "HMStatisticTab")
end})

table.insert(UnitTest.stage, {description = "Test admin tab", test = function()
  Controller.sendEvent(nil, "HMMainTab", "change-tab", "HMAdminTab")
end})

table.insert(UnitTest.stage, {description = "Test properties tab", test = function()
  Controller.sendEvent(nil, "HMMainTab", "change-tab", "HMPropertiesTab")
end})

table.insert(UnitTest.stage, {description = "Close main panel", test = function()
  Controller.onGuiClick({player_index=Player.native().index, element = {valid=true, name="HMController=CLOSE"}})
end})

return UnitTest