require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build fluid selector
--
-- @module FluidSelector
-- @extends #AbstractSelector
--

FluidSelector = newclass(AbstractSelector)

local list_group = {}
local list_subgroup = {}
local list_prototype = {}

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#FluidSelector] getCaption
--
-- @param #Controller parent parent controller
--
function FluidSelector:getCaption(parent)
  return {"helmod_selector-panel.fluid-title"}
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#FluidSelector] appendGroups
--
-- @param #string name
-- @param #string type
--
function FluidSelector:appendGroups(name, type)
  Logging:debug(self.classname, "appendGroups()", name, type)
  local fluid_prototype = FluidPrototype(name)
  local find = self:checkFilter(fluid_prototype:native())
  local filter_show_disable = User.getSetting("filter_show_disable")
  local filter_show_hidden = User.getSetting("filter_show_hidden")

  local list_group = Cache.getData(self.classname, "list_group")
  local list_prototype = Cache.getData(self.classname, "list_prototype")
  local list_subgroup = Cache.getData(self.classname, "list_subgroup")
  
  if find == true and (fluid_prototype:getValid() == true or filter_show_disable == true) then
    local group_name = fluid_prototype:native().group.name
    local subgroup_name = fluid_prototype:native().subgroup.name
    
    list_subgroup[subgroup_name] = fluid_prototype:native().subgroup
    
    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
    list_subgroup[subgroup_name] = fluid_prototype:native().subgroup
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    
    local search_products = name
    list_group[group_name].search_products = list_group[group_name].search_products .. search_products
    
    local search_ingredients = name
    list_group[group_name].search_ingredients = list_group[group_name].search_ingredients .. search_ingredients
    
    table.insert(list_prototype[group_name][subgroup_name], {name=name, type=type, order=fluid_prototype:native().order, search_products=search_products, search_ingredients=search_ingredients})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#FluidSelector] updateGroups
--
-- @param #LuaEvent event
--
function FluidSelector:updateGroups(event)
  Logging:trace(self.classname, "updateGroups()", event)

  self:resetGroups()

  for key, recipe in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(recipe.name, "recipe")
  end
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#FluidSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function FluidSelector:buildPrototypeTooltip(prototype)
  Logging:trace(self.classname, "buildPrototypeTooltip(player, prototype)", prototype)
  -- initalize tooltip
  local tooltip = FluidPrototype(prototype):getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#FluidSelector] buildPrototypeIcon
--
function FluidSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self.classname.."=element-select=ID=fluid=", Player.getItemIconType(prototype), prototype.name, prototype.name, tooltip)
end



