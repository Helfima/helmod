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
-- @param #prototype prototype
--
-- @return boolean
--
function RecipeSelector.methods:checkFilter(prototype)
  Logging:trace(self:classname(), "checkFilter()")
  local recipe_prototype = RecipePrototype.load(prototype)
  local filter_prototype = self:getFilter()
  local filter_prototype_product = self:getProductFilter()
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
    
  local find = false
  Logging:debug(self:classname(), "filter_prototype", filter_prototype)
  if filter_prototype ~= nil and filter_prototype ~= "" then
    local elements = recipe_prototype.getProducts()
    if filter_prototype_product ~= true then
      elements = recipe_prototype.getIngredients()
    end

    for key, element in pairs(elements) do
      local search = element.name:lower():gsub("[-]"," ")
      if string.find(search, filter_prototype) then
        find = true
      end
    end
  else
    find = true
  end
  return find and (RecipePrototype.getEnabled() == true or filter_show_disable == true) and (RecipePrototype.getHidden() == false or filter_show_hidden == true)
end

-------------------------------------------------------------------------------
-- Prepare groups
--
-- @function [parent=#RecipeSelector] prepareGroups
--
function RecipeSelector.methods:prepareGroups()
  Logging:debug(self:classname(), "prepareGroups()")
  self.list_group = {}
  self.list_subgroup = {}
  self.list_prototype = {}
  for key, recipe in pairs(Player.getRecipes()) do
    self:appendGroups(recipe.name, "recipe")
  end
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(fluid.name, "fluid")
  end
  for key, resource in pairs(Player.getResources()) do
    self:appendGroups(resource.name, "resource")
  end
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#RecipeSelector] appendGroups2
--
-- @param #string name
-- @param #string type
--
function RecipeSelector.methods:appendGroups(name, type)
  Logging:trace(self:classname(), "appendGroups()", name, type)
  RecipePrototype.load(name, type)
  local lua_recipe = RecipePrototype.native()
  local group_name = lua_recipe.group.name
  local subgroup_name = lua_recipe.subgroup.name
  
  if firstGroup == nil then firstGroup = group_name end
  self.list_group[group_name] = lua_recipe.group
  self.list_subgroup[subgroup_name] = lua_recipe.subgroup
  if self.list_prototype[group_name] == nil then self.list_prototype[group_name] = {} end
  if self.list_prototype[group_name][subgroup_name] == nil then self.list_prototype[group_name][subgroup_name] = {} end
  table.insert(self.list_prototype[group_name][subgroup_name], {name=name, type=type, order=lua_recipe.order})
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
  return ElementGui.getTooltipRecipe(prototype)
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#RecipeSelector] buildPrototypeIcon
--
-- @param #table prototype
-- 
function RecipeSelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  local recipe_prototype = RecipePrototype.load(prototype)
  local type = RecipePrototype.type()
  local prototype_name = RecipePrototype.native().name
  local prototype_localised_name = RecipePrototype.getLocalisedName()
  local color = nil
  if RecipePrototype.getCategory() == "crafting-handonly" then
    color = "yellow"
  elseif RecipePrototype.getEnabled() == false then
    color = "red"
  end
  local element = ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID="..type.."=", Player.getRecipeIconType(RecipePrototype.native()), prototype_name, prototype_localised_name, tooltip, color)
  return element.name,prototype_name,type
end
