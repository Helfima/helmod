---
-- Description of the module.
-- @module Remote
-- 
local Remote = {
  -- single-line comment
  classname = "HMRemote"
}

-------------------------------------------------------------------------------
-- Close panel
--
-- @function [parent=#Remote] close
--
-- 
function Remote.close()
  if game.player.admin then
     Controller.onGuiClick({player_index=game.player.index, element = {valid=true, name="HMController=CLOSE"}})
    end
end

-------------------------------------------------------------------------------
-- Close panel
--
-- @function [parent=#Remote] test
--
-- 
function Remote.test()
  if game.player.admin then
     UnitTest.run({player_index=game.player.index})
    end
end

-------------------------------------------------------------------------------
-- Clear panel
--
-- @function [parent=#Remote] clear
--
function Remote.clear()
if game.player.admin then
      for _,player in pairs(game.players) do
        helmod:clear_panel(player)
      end
    end
end

-------------------------------------------------------------------------------
-- Export data
--
-- @function [parent=#Remote] export_data
--
-- @param #number level
-- 
function Remote.export_data(level)
    Logging.limit = level or 10
    game.write_file("helmod\\data.json", Logging:objectToString(global), false)
end

-------------------------------------------------------------------------------
-- cheat
--
-- @function [parent=#Remote] cheat
--
function Remote.cheat(object, object_type)
if game.player.admin and Logging.log > 0 then
      game.player.force.enable_all_recipes()
      game.player.force.enable_all_technologies()
      game.player.force.manual_mining_speed_modifier=100
      game.player.force.manual_crafting_speed_modifier=100
      game.player.cheat_mode=true
      game.player.print("cheat mod!")
    else
      game.player.print("not allowed cheat mod!")
    end
end

return Remote