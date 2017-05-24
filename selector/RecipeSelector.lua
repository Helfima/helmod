require "selector/AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build recipe selector
--
-- @module RecipeSelector
-- @extends #AbstractSelector
--

RecipeSelector = setclass("HMRecipeSelector", AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#RecipeSelector] getCaption
--
-- @param #Controller parent parent controller
--
function RecipeSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#RecipeSelector] updateGroups
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
-- @return groupList, prototypeGroups
--
function RecipeSelector.methods:updateGroups(player, element, action, item, item2, item3)
  Logging:trace(self:classname(), "updateGroups():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  -- recuperation recipes
  local prototypeGroups = {}
  local groupList = {}
  local prototypeFilter = self:getFilter()
  local prototypeFilterProduct = self:getProductFilter()
  
  local firstGroup = nil
  for key, prototype in spairs(self.player:getRecipes(player, true),function(t,a,b) return t[b]["subgroup"]["order"] > t[a]["subgroup"]["order"] end) do
    local find = false
    if prototypeFilter ~= nil and prototypeFilter ~= "" then
      local elements = prototype.products
      if prototypeFilterProduct ~= true then
        elements = prototype.ingredients
      end

      for key, element in pairs(elements) do
        local search = element.name:lower():gsub("[-]"," ")
        if string.find(search, prototypeFilter) then
          find = true
        end
      end
    else
      find = true
    end

    local filter_show_hidden = self.player:getGlobalSettings(player, "filter_show_hidden")
    if find == true and (prototype.enabled == true or filter_show_hidden == true) then
      if firstGroup == nil then firstGroup = prototype.group.name end
      groupList[prototype.group.name] = prototype.group
      if prototypeGroups[prototype.group.name] == nil then prototypeGroups[prototype.group.name] = {} end
      if prototypeGroups[prototype.group.name][prototype.subgroup.name] == nil then prototypeGroups[prototype.group.name][prototype.subgroup.name] = {} end
      table.insert(prototypeGroups[prototype.group.name][prototype.subgroup.name], prototype)
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
-- @function [parent=#RecipeSelector] getItemList
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RecipeSelector.methods:getItemList(player, element, action, item, item2, item3)
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
-- Build recipe tooltip
--
-- @function [parent=#RecipeSelector] buildPrototypeTooltip
--
-- @param #LuaPlayer player
--
function RecipeSelector.methods:buildPrototypeTooltip(player, recipe)
  Logging:trace(self:classname(), "buildRecipeTooltip(player, element):",player, recipe)
  -- initalize tooltip
  local tooltip = {"tooltip.recipe-info"}
  -- insert __1__ value
  table.insert(tooltip, self.player:getRecipeLocalisedName(player, recipe))

  -- insert __2__ value
  local lastTooltip = tooltip
  for _,element in pairs(recipe.products) do
    local count = self.model:getElementAmount(element)
    local name = self.player:getLocalisedName(player,element)
    local currentTooltip = {"tooltip.recipe-info-element", count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")
  
  -- insert __3__ value
  local lastTooltip = tooltip
  for _,element in pairs(recipe.ingredients) do
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
-- @function [parent=#RecipeSelector] buildPrototypeIcon
--
-- @param #LuaPlayer player
--
function RecipeSelector.methods:buildPrototypeIcon(player, guiElement, prototype, tooltip)
      Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
      self:addGuiButtonSelectSprite(guiElement, self:classname().."=recipe-select=ID=", self.player:getRecipeIconType(player, prototype), prototype.name, prototype.name, tooltip)
end