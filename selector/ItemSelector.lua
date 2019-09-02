require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module ItemSelector
-- @extends #AbstractSelector
--

ItemSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#ItemSelector] getCaption
--
-- @param #Controller parent parent controller
--
function ItemSelector:getCaption(parent)
  return {"helmod_selector-panel.item-title"}
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#ItemSelector] appendGroups
--
-- @param #string name
-- @param #string type
--
function ItemSelector:appendGroups(name, type)
  Logging:debug(self.classname, "appendGroups()", name, type)
  ItemPrototype.load(name, type)
  local find = self:checkFilter(ItemPrototype.native())
  local filter_show_disable = User.getSetting("filter_show_disable")
  local filter_show_hidden = User.getSetting("filter_show_hidden")
  
  local list_group = Cache.getData(self.classname, "list_group")
  local list_prototype = Cache.getData(self.classname, "list_prototype")
  local list_subgroup = Cache.getData(self.classname, "list_subgroup")

  if find == true and (ItemPrototype.getValid() == true or filter_show_disable == true) then
    local group_name = ItemPrototype.native().group.name
    local subgroup_name = ItemPrototype.native().subgroup.name
    
    list_subgroup[subgroup_name] = ItemPrototype.native().subgroup
    
    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
    list_subgroup[subgroup_name] = ItemPrototype.native().subgroup
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    
    local search_products = name
    list_group[group_name].search_products = list_group[group_name].search_products .. search_products
    
    local search_ingredients = name
    list_group[group_name].search_ingredients = list_group[group_name].search_ingredients .. search_ingredients

    table.insert(list_prototype[group_name][subgroup_name], {name=name, type=type, order=ItemPrototype.native().order, search_products=search_products, search_ingredients=search_ingredients})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#ItemSelector] updateGroups
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ItemSelector:updateGroups(event)
  Logging:trace(self.classname, "updateGroups()", event)

  self:resetGroups()

  for key, item in pairs(Player.getItemPrototypes()) do
    self:appendGroups(item.name, "item")
  end
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#ItemSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function ItemSelector:buildPrototypeTooltip(prototype)
  Logging:trace(self.classname, "buildPrototypeTooltip(player, prototype)", prototype)
  -- initalize tooltip
  local tooltip = ItemPrototype.load(prototype).getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#ItemSelector] buildPrototypeIcon
--
function ItemSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self.classname.."=element-select=ID=item=", Player.getItemIconType(prototype), prototype.name, prototype.name, tooltip)
end



