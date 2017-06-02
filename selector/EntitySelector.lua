require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module EntitySelector
-- @extends #AbstractSelector
--

EntitySelector = setclass("HMEntitySelector", AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#EntitySelector] getCaption
--
-- @param #Controller parent parent controller
--
function EntitySelector.methods:getCaption(parent)
  return {"helmod_selector-panel.entity-title"}
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#EntitySelector] updateGroups
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {groupList, prototypeGroups}
--
function EntitySelector.methods:updateGroups(player, item, item2, item3)
  Logging:trace(self:classname(), "on_update():", item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  -- recuperation recipes
  local prototypeGroups = {}
  local groupList = {}
  local prototypeFilter = self:getFilter()
  local prototypeFilterProduct = self:getProductFilter()

  local firstGroup = nil
  for key, prototype in spairs(self.player:getEntityPrototypes(),function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
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
-- @function [parent=#EntitySelector] getItemList
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EntitySelector.methods:getItemList(player, item, item2, item3)
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
-- @function [parent=#EntitySelector] buildPrototypeTooltip
--
-- @param #LuaPlayer player
-- @param #LuaPrototype prototype
--
function EntitySelector.methods:buildPrototypeTooltip(player, prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(player, prototype):",player, prototype)
  -- initalize tooltip
  local tooltip = self.player:getLocalisedName(player, prototype)
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#EntitySelector] buildPrototypeIcon
--
-- @param #LuaPlayer player
--
function EntitySelector.methods:buildPrototypeIcon(player, guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
  self:addGuiButtonSelectSprite(guiElement, self:classname().."=entity-select=ID=", self.player:getEntityIconType(prototype), prototype.name, prototype.name, tooltip)
end



