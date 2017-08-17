require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module TechnologySelector
-- @extends #AbstractSelector
--

TechnologySelector = setclass("HMTechnologySelector", AbstractSelector)

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#TechnologySelector] after_init
--
function TechnologySelector.methods:after_init()
  self.disable_option = true
end

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
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {groupList, prototypeGroups}
--
function TechnologySelector.methods:updateGroups(item, item2, item3)
  Logging:trace(self:classname(), "on_update():", item, item2, item3)
  local globalPlayer = Player.getGlobal()
  -- recuperation recipes
  local prototypeGroups = {}
  local groupList = {}
  local prototypeFilter = self:getFilter()
  local prototypeFilterProduct = self:getProductFilter()

  local firstGroup = nil
  for key, prototype in spairs(Player.getTechnologies(),function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
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

   local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
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
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function TechnologySelector.methods:getItemList(item, item2, item3)
  Logging:trace(self:classname(), "getItemList():",item, item2, item3)
  local globalPlayer = Player.getGlobal()
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
-- @param #LuaPrototype prototype
--
function TechnologySelector.methods:buildPrototypeTooltip(prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(prototype):", prototype)
  -- initalize tooltip
  local tooltip = {"tooltip.technology-info"}
  -- insert __1__ value
  table.insert(tooltip, Player.getTechnologyLocalisedName(prototype))

  -- insert __2__ value
  table.insert(tooltip, prototype.level)

  -- insert __3__ value
  table.insert(tooltip, prototype.research_unit_count_formula or "")

  -- insert __4__ value
  local lastTooltip = tooltip
  for _,element in pairs(prototype.research_unit_ingredients) do
    local count = Product.getElementAmount(element)
    local name = Player.getLocalisedName(element)
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
function TechnologySelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID=technology=", "technology", prototype.name, prototype.name, tooltip)
end


