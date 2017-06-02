require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module ItemSelector
-- @extends #AbstractSelector
--

ItemSelector = setclass("HMItemSelector", AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#ItemSelector] getCaption
--
-- @param #Controller parent parent controller
--
function ItemSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.item-title"}
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#ItemSelector] updateGroups
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {groupList, prototypeGroups}
--
function ItemSelector.methods:updateGroups(player, item, item2, item3)
  Logging:trace(self:classname(), "on_update():", item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  -- recuperation recipes
  local prototypeGroups = {}
  local groupList = {}
  local prototypeFilter = self:getFilter()
  local prototypeFilterProduct = self:getProductFilter()

  local firstGroup = nil
  for key, prototype in spairs(self.player:getItemPrototypes(),function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
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

      local filter_show_hidden = self.player:getGlobalSettings(player, "filter_show_hidden")
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
-- @function [parent=#ItemSelector] getItemList
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ItemSelector.methods:getItemList(player, item, item2, item3)
  Logging:trace(self:classname(), "getItemList():", item, item2, item3)
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
-- @function [parent=#ItemSelector] buildPrototypeTooltip
--
-- @param #LuaPlayer player
-- @param #LuaPrototype prototype
--
function ItemSelector.methods:buildPrototypeTooltip(player, prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(player, prototype):",player, prototype)
  -- initalize tooltip
  local tooltip = self.player:getLocalisedName(player, prototype)
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#ItemSelector] buildPrototypeIcon
--
-- @param #LuaPlayer player
--
function ItemSelector.methods:buildPrototypeIcon(player, guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
  self:addGuiButtonSelectSprite(guiElement, self:classname().."=item-select=ID=", self.player:getItemIconType(prototype), prototype.name, prototype.name, tooltip)
end



