require "planner/plannerAbstractEdition"

-------------------------------------------------------------------------------
-- Classe to build recipe edition dialog
--
-- @module PlannerEnergyEdition
-- @extends #PlannerDialog
--

PlannerEnergyEdition = setclass("HMPlannerEnergyEdition", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerEnergyEdition] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerEnergyEdition.methods:on_init(parent)
	self.panelCaption = ({"helmod_energy-edition-panel.title"})
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerEnergyEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerEnergyEdition.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create generator panel
--
-- @function [parent=#PlannerEnergyEdition] getGeneratorPanel
--
-- @param #LuaPlayer player
--
function PlannerEnergyEdition.methods:getGeneratorPanel(player)
  local panel = self:getPanel(player)
  if panel["generator"] ~= nil and panel["generator"].valid then
    return panel["generator"]
  end
  return self:addGuiFlowH(panel, "generator", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerEnergyEdition] getGeneratorInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerEnergyEdition.methods:getGeneratorInfoPanel(player)
  local panel = self:getGeneratorPanel(player)
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return self:addGuiFrameV(panel, "info", "helmod_frame_recipe_factory", ({"helmod_common.generator"}))
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#PlannerEnergyEdition] getGeneratorSelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerEnergyEdition.methods:getGeneratorSelectorPanel(player)
  local panel = self:getGeneratorPanel(player)
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return self:addGuiFrameV(panel, "selector", "helmod_frame_recipe_factory", ({"helmod_common.generator"}))
end

-------------------------------------------------------------------------------
-- Build generator panel
--
-- @function [parent=#PlannerEnergyEdition] buildGeneratorPanel
--
-- @param #LuaPlayer player
--
function PlannerEnergyEdition.methods:buildGeneratorPanel(player)
  Logging:debug("PlannerEnergyEdition:buildGeneratorPanel():",player)
  self:getGeneratorInfoPanel(player)
  self:getGeneratorSelectorPanel(player)
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#PlannerEnergyEdition] getObject
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerEnergyEdition.methods:getObject(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
  if  model.blocks[item] ~= nil and model.blocks[item].recipes[item2] ~= nil then
    -- return recipe
    return model.blocks[item].recipes[item2]
  end
  return nil
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerEnergyEdition] on_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerEnergyEdition.methods:on_open(player, element, action, item, item2, item3)
	Logging:debug("PlannerRecipeSelector:on_open():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
  local close = true
  model.generatorGroupSelected = nil
  
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerEnergyEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerEnergyEdition.methods:on_close(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerEnergyEdition] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerEnergyEdition.methods:after_open(player, element, action, item, item2, item3)
  Logging:debug("PlannerEnergyEdition:after_open():",player, element, action, item, item2, item3)
  self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
  self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
  self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
  
  self:buildGeneratorPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerEnergyEdition] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerEnergyEdition.methods:on_update(player, element, action, item, item2, item3)
  self:updateGenerator(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update beacon
--
-- @function [parent=#PlannerEnergyEdition] updateGenerator
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerEnergyEdition.methods:updateGenerator(player, element, action, item, item2, item3)
  Logging:debug("PlannerEnergyEdition:updateGenerator():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  self:updateGeneratorSelector(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update selector
--
-- @function [parent=#PlannerEnergyEdition] updateGeneratorSelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerEnergyEdition.methods:updateGeneratorSelector(player, element, action, item, item2, item3)
  Logging:debug("PlannerEnergyEdition:updateGeneratorSelector():",player, element, action, item, item2, item3)
  local globalSettings = self.player:getGlobal(player, "settings")
  local selectorPanel = self:getGeneratorSelectorPanel(player)
  local model = self.model:getModel(player)

  if selectorPanel["scroll-generator"] ~= nil and selectorPanel["scroll-generator"].valid then
    selectorPanel["scroll-generator"].destroy()
  end
  local scrollPanel = self:addGuiScrollPane(selectorPanel, "scroll-generator", "helmod_scroll_recipe_factories", "auto", "auto")

  local object = self:getObject(player, element, action, item, item2, item3)

  local groupsPanel = self:addGuiTable(scrollPanel, "generator-groups", 2)
  
  local category = "module-beacon"
  if globalSettings.model_filter_beacon ~= nil and globalSettings.model_filter_beacon == false then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = self.player:getGenerators()
  Logging:debug("factories:",factories)


  if category == nil then
    local subgroups = {}
    for key, factory in pairs(factories) do
      local subgroup = factory.subgroup.name
      if subgroup ~= nil then
        if subgroups[subgroup] == nil then
          subgroups[subgroup] = 1
        else
          subgroups[subgroup] = subgroups[subgroup] + 1
        end
      end
    end

    for group, count in pairs(subgroups) do
      -- set le groupe
      if model.generatorGroupSelected == nil then model.generatorGroupSelected = group end
      -- ajoute les icons de groupe
      local action = self:addGuiButton(groupsPanel, self:classname().."=generator-group=ID="..item.."="..object.name.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = self:addGuiTable(scrollPanel, "generator-table", 5)
  --Logging:debug("factories:",self.player:getProductions())
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.generatorGroupSelected) then
      local localised_name = element.localised_name
      if globalSettings.real_name == true then
        localised_name = element.name
      end
      self:addGuiButtonSelectSprite(tablePanel, self:classname().."=generator-select=ID=", "item", element.name, element.name, localised_name)
    end
  end
end
