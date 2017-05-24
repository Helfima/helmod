require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module TechnologySelector
-- @extends #AbstractSelector
--

TechnologySelector = setclass("HMTechnologySelector", AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#TechnologySelector] getCaption
--
-- @param #Controller parent parent controller
--
function TechnologySelector.methods:getCaption(parent)
  return {"helmod_selector-panel.technology-title"}
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#TechnologySelector] updateGroups
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {groupList, prototypeGroups}
--
function TechnologySelector.methods:updateGroups(player, element, action, item, item2, item3)
  Logging:trace(self:classname(), "on_update():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  -- recuperation recipes
  local prototypeGroups = {}
  local groupList = {}
  local prototypeFilter = self:getFilter()
  local prototypeFilterProduct = self:getProductFilter()

  local firstGroup = nil
  for key, prototype in spairs(self.player:getTechnologies(player),function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
    local find = false
    if prototypeFilter ~= nil and prototypeFilter ~= "" then
      if prototypeFilterProduct == true then
        local search = prototype.name:lower():gsub("[-]"," ")
        if string.find(search, prototypeFilter) then
          find = true
        end
      else
        local elements = prototype.research_unit_ingredients
        for key, element in pairs(elements) do
          local search = element.name:lower():gsub("[-]"," ")
          if string.find(search, prototypeFilter) then
            find = true
          end
        end
      end
    else
      find = true
    end

   local filter_show_hidden = self.player:getGlobalSettings(player, "filter_show_hidden")
    if find == true and (prototype.enabled == true or filter_show_hidden == true) then
      local group_name = "normal"
      if prototype.research_unit_count_formula ~= nil then group_name = "infinite" end
      if firstGroup == nil then firstGroup = group_name end
      groupList[group_name] = {name = group_name}
      if prototypeGroups[group_name] == nil then prototypeGroups[group_name] = {} end
      if prototypeGroups[group_name]["default"] == nil then prototypeGroups[group_name]["default"] = {} end
      table.insert(prototypeGroups[group_name]["default"], prototype)
    end
  end

  if prototypeGroups[globalPlayer.recipeGroupSelected] == nil then
    globalPlayer.recipeGroupSelected = firstGroup
  end
  return groupList, prototypeGroups
end

-------------------------------------------------------------------------------
-- Get item list
--
-- @function [parent=#TechnologySelector] getItemList
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function TechnologySelector.methods:getItemList(player, element, action, item, item2, item3)
  Logging:trace(self:classname(), "getItemList():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  local list = {}
  local prototypeGroups = self:getPrototypeGroups()
  if prototypeGroups[globalPlayer.recipeGroupSelected] ~= nil then
    list = prototypeGroups[globalPlayer.recipeGroupSelected]
  end
  return list
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#TechnologySelector] buildPrototypeTooltip
--
-- @param #LuaPlayer player
-- @param #LuaPrototype prototype
--
function TechnologySelector.methods:buildPrototypeTooltip(player, prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(player, prototype):",player, prototype)
  -- initalize tooltip
  local tooltip = {"tooltip.technology-info"}
  -- insert __1__ value
  table.insert(tooltip, self.player:getTechnologyLocalisedName(player, prototype))

  -- insert __2__ value
  table.insert(tooltip, prototype.level)

  -- insert __3__ value
  table.insert(tooltip, prototype.research_unit_count_formula or "")

  -- insert __4__ value
  local lastTooltip = tooltip
  for _,element in pairs(prototype.research_unit_ingredients) do
    local count = self.model:getElementAmount(element)
    local name = self.player:getLocalisedName(player,element)
    local currentTooltip = {"tooltip.recipe-info-element", count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#TechnologySelector] buildPrototypeIcon
--
-- @param #LuaPlayer player
--
function TechnologySelector.methods:buildPrototypeIcon(player, guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
  self:addGuiButtonSelectSprite(guiElement, self:classname().."=technology-select=ID=", "technology", prototype.name, prototype.name, tooltip)
end


