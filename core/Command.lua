---
-- Description of the module.
-- @module Command
--
local Command = {
  -- single-line comment
  classname = "HMCommand"
}

-------------------------------------------------------------------------------
-- Start
--
-- @function [parent=#Command] start
--
function Command.start()
  Logging:trace(Command.classname, "start()")
  commands.add_command("helmod","helmod commands", Command.run)
end


-------------------------------------------------------------------------------
-- Run
--
-- @function [parent=#Command] run
--
function Command.run(event)
-- do nothing
end

-------------------------------------------------------------------------------
-- Parse
--
-- @function [parent=#Command] parse
--
-- @param #LuaEvent event
--
function Command.parse(event)
  if event.command == "helmod" then
    if string.lower(event.parameters) == "close" then
      Controller.onGuiClick({player_index=Player.native().index, element = {valid=true, name="HMController=CLOSE"}})
    elseif string.lower(event.parameters) == "unittest" then
      UnitTest.run(event)
    elseif string.lower(event.parameters) == "resetuserui" then
      Player.resetGlobal()
      Player.print("User UI are reseted!")
    elseif string.lower(event.parameters) == "resetcaches" then
      Controller.resetCaches()
      Player.print("Caches are reseted!")
    elseif string.lower(event.parameters) == "exportdata" then
      Logging.limit = 10
      game.write_file("helmod\\data.json", Logging:objectToString(global), false)
      Player.print("Data exported!")
    elseif string.lower(event.parameters) == "exportcache" then
      Logging.limit = 10
      game.write_file("helmod\\cache.json", Logging:objectToString(Cache.getData()), false)
      Player.print("Cache exported!")
    else
      Player.print("Valid arguments: close | ExportData | ResetCaches | ResetUserUI")
    end
  end
end

return Command
