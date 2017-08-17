require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module FluidSelector
-- @extends #AbstractSelector
--

FluidSelector = setclass("HMFluidSelector", AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#FluidSelector] getCaption
--
-- @param #Controller parent parent controller
--
function FluidSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.item-title"}
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#FluidSelector] updateGroups
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {groupList, prototypeGroups}
--
function FluidSelector.methods:updateGroups(item, item2, item3)
  Logging:trace(self:classname(), "on_update():", item, item2, item3)
  local globalPlayer = Player.getGlobal()
  -- recuperation recipes
  local prototypeGroups = {}
  local groupList = {}
  local prototypeFilter = self:getFilter()
  local prototypeFilterProduct = self:getProductFilter()

  local firstGroup = nil
  for key, prototype in spairs(Player.getFluidPrototypes(),function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
    -- ne traite pas les entity sans name
    if prototype.name ~= nil then
      local find = false
      if prototypeFilter ~= nil and prototypeFilter ~= "" then
        if prototypeFilterProduct == true then
          local search = prototype.name:lower():gsub("[-]"," ")
          if string.find(search, prototypeFilter) then
            find = true
          end
        end
      else
        find = true
      end

      local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
      if find == true and (prototype.valid == true or filter_show_hidden == true) then
        if firstGroup == nil then firstGroup = prototype.group.name end
        groupList[prototype.group.name] = prototype.group
        if prototypeGroups[prototype.group.name] == nil then prototypeGroups[prototype.group.name] = {} end
        if prototypeGroups[prototype.group.name][prototype.subgroup.name] == nil then prototypeGroups[prototype.group.name][prototype.subgroup.name] = {} end
        table.insert(prototypeGroups[prototype.group.name][prototype.subgroup.name], prototype)
      end
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
-- @function [parent=#FluidSelector] getItemList
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function FluidSelector.methods:getItemList(item, item2, item3)
  Logging:trace(self:classname(), "getItemList():", item, item2, item3)
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
-- @function [parent=#FluidSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function FluidSelector.methods:buildPrototypeTooltip(prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(player, prototype):", prototype)
  -- initalize tooltip
  local tooltip = Player.getLocalisedName(prototype)
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#FluidSelector] buildPrototypeIcon
--
function FluidSelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID=fluid=", Player.getItemIconType(prototype), prototype.name, prototype.name, tooltip)
end



