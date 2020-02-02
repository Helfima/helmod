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
      User.reset()
      Player.print("User UI are reseted!")
    elseif string.lower(event.parameters) == "resetuserexplorer" then
      User.setParameter("explore_recipe", nil)
      User.setParameter("explore_recipe_id", nil)
      Player.print("User Explorer are reseted!")
    elseif string.lower(event.parameters) == "resetuserallui" then
      User.resetAll()
      Player.print("All User UIs are reseted!")
    elseif string.lower(event.parameters) == "resetcaches" then
      Cache.reset()
      for _,user_data in pairs(global["users"]) do
        user_data["cache"] = nil
      end
      Player.print("Caches are reseted!")
    elseif string.lower(event.parameters) == "resettranslate" then
      User.resetTranslate()
      Player.print("User translate are reseted!")
    elseif string.lower(event.parameters) == "exportdata" then
      Logging.limit = 10
      game.write_file("helmod\\data.json", Logging:objectToString(global), false)
      Player.print("Data exported!")
    elseif string.lower(event.parameters) == "exportmodel" then
      Logging.limit = 10
      game.write_file("helmod\\model.json", Logging:objectToString(Model.getModel()), false)
      Player.print("Model exported!")
    elseif string.lower(event.parameters) == "exporttranslate" then
      Logging.limit = 10
      game.write_file("helmod\\translate.json", Logging:objectToString(User.get("translated")), false)
      Player.print("Translate exported!")
    elseif string.lower(event.parameters) == "exportdatauser" then
      Logging.limit = 10
      game.write_file("helmod\\data_user.json", Logging:objectToString(User.get()), false)
      Player.print("Data UI exported!")
    elseif string.lower(event.parameters) == "exportcache" then
      Logging.limit = 10
      game.write_file("helmod\\cache.json", Logging:objectToString(Cache.getData()), false)
      Player.print("Cache exported!")
    else
      Player.print("Valid arguments: close | ExportData | ExportModel | ExportTranslate | ExportDataUser | ResetCaches | ResetUserUI | ResetTranslate")
    end
  end
end

return Command
