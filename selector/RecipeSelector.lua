require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build recipe selector
--
-- @module RecipeSelector
-- @extends #AbstractSelector
--

RecipeSelector = setclass("HMRecipeSelector", AbstractSelector)

local firstGroup = nil

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#RecipeSelector] afterInit
--
function RecipeSelector.methods:afterInit()
  Logging:debug(self:classname(), "afterInit()")
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
end

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
-- Check filter
--
-- @function [parent=#RecipeSelector] checkFilter
--
-- @param #RecipePrototype recipe_prototype
--
-- @return boolean
--
function RecipeSelector.methods:checkFilter(recipe_prototype)
  Logging:trace(self:classname(), "checkFilter()")
  local prototypeFilter = self:getFilter()
  local prototypeFilterProduct = self:getProductFilter()
  local find = false
  if prototypeFilter ~= nil and prototypeFilter ~= "" then
    local elements = recipe_prototype.getProducts()
    if prototypeFilterProduct ~= true then
      elements = recipe_prototype.getIngredients()
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
  return find
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#RecipeSelector] appendGroups
--
-- @param #string name
-- @param #string type
-- @param #table groupList
-- @param #table prototypeGroups
--
function RecipeSelector.methods:appendGroups(name, type, groupList, prototypeGroups)
  Logging:debug(self:classname(), "appendGroups()", name, type)
  local recipe_prototype = RecipePrototype.load(name, type)
  local find = self:checkFilter(recipe_prototype)
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
  
  if find == true and (recipe_prototype.getEnabled() == true or filter_show_disable == true) and (recipe_prototype.getHidden() == false or filter_show_hidden == true) then
    local group_name = RecipePrototype.native().group.name
    local subgroup_name = RecipePrototype.native().subgroup.name
    
    if firstGroup == nil then firstGroup = group_name end
    groupList[group_name] = RecipePrototype.native().group
    if prototypeGroups[group_name] == nil then prototypeGroups[group_name] = {} end
    if prototypeGroups[group_name][subgroup_name] == nil then prototypeGroups[group_name][subgroup_name] = {} end
    table.insert(prototypeGroups[group_name][subgroup_name], {name=name, type=type})
  end
end
-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#RecipeSelector] updateGroups
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return groupList, prototypeGroups
--
function RecipeSelector.methods:updateGroups(item, item2, item3)
  Logging:debug(self:classname(), "updateGroups():", item, item2, item3)
  local globalPlayer = Player.getGlobal()
  local globalGui = Player.getGlobalGui()
  -- recuperation recipes
  local prototypeGroups = {}
  local groupList = {}

  firstGroup = nil

  for key, recipe in spairs(Player.getRecipes(),function(t,a,b) return t[b]["subgroup"]["order"] > t[a]["subgroup"]["order"] end) do
    self:appendGroups(recipe.name, "recipe", groupList, prototypeGroups)
  end
  if globalGui.currentTab ~= "HMPropertiesTab" then
    for key, fluid in spairs(Player.getFluidPrototypes(),function(t,a,b) return t[b]["subgroup"]["order"] > t[a]["subgroup"]["order"] end) do
      self:appendGroups(fluid.name, "fluid", groupList, prototypeGroups)
    end
    for key, resource in spairs(Player.getResources(),function(t,a,b) return t[b]["subgroup"]["order"] > t[a]["subgroup"]["order"] end) do
      self:appendGroups(resource.name, "resource", groupList, prototypeGroups)
    end
  end

  if prototypeGroups[globalPlayer.recipeGroupSelected] == nil then
    globalPlayer.recipeGroupSelected = firstGroup
  end
  Logging:debug(self:classname(), "groupList", groupList, "prototypeGroups", prototypeGroups)
  return groupList, prototypeGroups
end

-------------------------------------------------------------------------------
-- Get item list
--
-- @function [parent=#RecipeSelector] getItemList
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RecipeSelector.methods:getItemList(item, item2, item3)
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
-- Build recipe tooltip
--
-- @function [parent=#RecipeSelector] buildPrototypeTooltip
--
-- @param #table prototype
-- 
function RecipeSelector.methods:buildPrototypeTooltip(prototype)
  Logging:trace(self:classname(), "buildRecipeTooltip(element):", prototype)
  local recipe_prototype = RecipePrototype.load(prototype)
  -- initalize tooltip
  local tooltip = {"tooltip.recipe-info"}
  -- insert __1__ value
  table.insert(tooltip, recipe_prototype.getLocalisedName())

  -- insert __2__ value
  local lastTooltip = tooltip
  for _,element in pairs(recipe_prototype.getProducts()) do
    local product = Product.load(element)
    local count = Product.getElementAmount(element)
    local name = Product.getLocalisedName()
    local currentTooltip = {"tooltip.recipe-info-element", count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")

  -- insert __3__ value
  local lastTooltip = tooltip
  for _,element in pairs(recipe_prototype.getIngredients()) do
    local product = Product.load(element)
    local count = Product.getElementAmount(element)
    local name = Product.getLocalisedName()
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
-- @param #table prototype
-- 
function RecipeSelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:debug(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, recipe_prototype, tooltip)
  local recipe_prototype = RecipePrototype.load(prototype)
  local type = recipe_prototype.type()
  local prototype_name = recipe_prototype.native().name
  local prototype_localised_name = recipe_prototype.getLocalisedName()
  ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID="..type.."=", Player.getRecipeIconType(recipe_prototype.native()), prototype_name, prototype_localised_name, tooltip)
end
