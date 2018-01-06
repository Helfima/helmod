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
    if event.parameters ~= nil then
      if string.lower(event.parameters) == "help" then
        Player.print("Valid arguments: help | close | ExportData | UnitTest")
      end
      if string.lower(event.parameters) == "close" then
        Controller.onGuiClick({player_index=Player.native().index, element = {valid=true, name="HMController=CLOSE"}})
      end
      if string.lower(event.parameters) == "unittest" then
        UnitTest.run(event)
      end
      if string.lower(event.parameters) == "exportdata" then
        Logging.limit = level or 10
        game.write_file("helmod\\data.json", Logging:objectToString(global), false)
        Player.print("Data exported!")
      end
    end
  end
end

return Command
