local function find_element(element, predicate)
 if predicate(element) then return element end
 for _, child in pairs(element.children) do
  local result = find_element(child, predicate)
  if result then return result end
 end
end
local function click(element, player)
 assert(element, "GUI control exists")
 EventController.onGuiClickButton{player_index=player.index, element=element, button=defines.mouse_button_type.left}
 assert(not Player.getLastError(), "Helmod GUI event failed")
 game.tick_paused=false
end

script.on_nth_tick(60, function(event)
 local player = game.players[1]
 if not player then return end
 Player.set(player)
 Controller:getViews()
 if not storage.orbit_ui_step then
  local model=Model.newModel()
  local block,recipe=ModelBuilder.addRecipeIntoProductionBlock(model,model.block_root,"automation-science-pack","orbit")
  ModelCompute.update(model)
  block.products["orbit/automation-science-pack#normal"].input=60
  ModelCompute.update(model)
  User.setParameterObjects("HMProductionPanel",model.id,block.id,recipe.id)
  Controller:send("on_gui_open",{name="OPEN",item1=model.id,item2=block.id},"HMProductionPanel")
  game.tick_paused=false
  storage.orbit_ui_step=1
  storage.orbit_ui_model=model.id
  storage.orbit_ui_block=block.id
 elseif storage.orbit_ui_step==1 then
  game.take_screenshot{player=player,resolution={1600,1000},show_gui=true,path="orbit-panel.png"}
  storage.orbit_ui_step=2
 elseif storage.orbit_ui_step==2 then
  click(find_element(player.gui.screen, function(element)
   return element.name:find("HMOrbitSelector", 1, true) and element.name:find("OPEN", 1, true)
  end), player)
  game.tick_paused=false
  storage.orbit_ui_step=3
 elseif storage.orbit_ui_step==3 then
  game.take_screenshot{player=player,resolution={1600,1000},show_gui=true,path="orbit-selector.png"}
  assert(player.gui.screen.HMOrbitSelector, "orbit selector exists")
  assert(not Player.getLastError(), "Helmod GUI error")
  click(find_element(player.gui.screen.HMOrbitSelector, function(element)
   return element.name:find("element-select",1,true) and element.tags.name == "firearm-magazine"
  end), player)
  local model=storage.models[storage.orbit_ui_model]
  local found=false
  for _, recipe in pairs(model.block_root.children) do
   if recipe.name=="firearm-magazine" and recipe.type=="orbit" then found=true end
  end
  assert(found, "selector added orbital recipe")
  Controller:getView("HMOrbitSelector"):close()
  storage.orbit_ui_step=4
 elseif storage.orbit_ui_step==4 then
  game.take_screenshot{player=player,resolution={1600,1000},show_gui=true,path="orbit-selected.png"}
  for _, element in pairs(player.gui.screen.children) do
   local control=find_element(element, function(child)
    return child.name:find("HMRecipeEdition",1,true) and child.name:find("OPEN",1,true)
   end)
   if control then click(control,player) break end
  end
  storage.orbit_ui_step=5
 elseif storage.orbit_ui_step==5 then
  game.take_screenshot{player=player,resolution={1600,1000},show_gui=true,path="orbit-edition.png"}
  assert(not Player.getLastError(), "Helmod GUI error")
  assert(player.gui.screen.HMRecipeEdition, "recipe editor exists")
  local target=find_element(player.gui.screen.HMRecipeEdition, function(element) return element.name=="orbit-value=speed-required" end)
  assert(target and target.caption=="5.57 (+456.59%)", "target bonus uses normal silo base speed")
  click(find_element(player.gui.screen.HMRecipeEdition, function(element)
   return element.name:find("factory-quality-select",1,true) and element.name:find("legendary",1,true)
  end), player)
  click(find_element(player.gui.screen.HMRecipeEdition, function(element)
   return element.name:find("factory-module-select",1,true) and element.tags.name=="productivity-module-3"
  end), player)
  storage.orbit_ui_step=6
 elseif storage.orbit_ui_step==6 then
  game.take_screenshot{player=player,resolution={1600,1000},show_gui=true,path="orbit-configured.png"}
  local model=storage.models[storage.orbit_ui_model]
  local recipe=model.block_root.children.R1
  assert(recipe.factory.quality=="legendary", "quality click updates silo")
  assert(recipe.factory.effects.productivity>0, "module click updates silo")
  assert(not Player.getLastError(), "Helmod GUI error")
  assert(not find_element(player.gui.screen.HMRecipeEdition, function(element) return element.name=="orbit-launch-limit" end), "no success indicator below target")
  model.parameters.effects.speed=10
  ModelCompute.update(model)
  Controller:send("on_gui_update",{item1=model.id,item2=storage.orbit_ui_block,item3=recipe.id},"HMRecipeEdition")
  game.tick_paused=false
  storage.orbit_ui_step=7
 elseif storage.orbit_ui_step==7 then
  local success=find_element(player.gui.screen.HMRecipeEdition, function(element) return element.name=="orbit-launch-limit" end)
  assert(success and success.sprite=="utility/check_mark_green", "success indicator at launch limit")
  assert(success.tooltip[1]=="helmod_orbit.target-reached", "success explanation")
  local target=find_element(player.gui.screen.HMRecipeEdition, function(element) return element.name=="orbit-value=speed-required" end)
  assert(target and target.caption=="7.46 (+198.33%)", "target bonus uses legendary silo base speed")
  game.take_screenshot{player=player,resolution={1600,1000},show_gui=true,path="orbit-target-reached.png"}
  storage.orbit_ui_step=8
 elseif storage.orbit_ui_step==8 then
  local model=storage.models[storage.orbit_ui_model]
  model.parameters.effects.speed=0
  ModelCompute.update(model)
  Controller:send("on_gui_update",{item1=model.id,item2=storage.orbit_ui_block,item3="R1"},"HMRecipeEdition")
  game.tick_paused=false
  assert(not find_element(player.gui.screen.HMRecipeEdition, function(element) return element.name=="orbit-launch-limit" end), "success indicator clears below target")
  assert(not Player.getLastError(), "Helmod GUI error")
  log("ORBIT UI SMOKE PASSED")
  storage.orbit_ui_step=9
 end
end)
