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
-- @function [parent=#TechnologySelector] afterInit
--
function TechnologySelector.methods:afterInit()
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
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
-- Append groups
--
-- @function [parent=#TechnologySelector] appendGroups
--
-- @param #string name
-- @param #string type
--
function TechnologySelector.methods:appendGroups(name, type)
  Logging:debug(self:classname(), "appendGroups()", name, type)
  Technology.load(name, type)
  local find = self:checkFilter(Technology.native())
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")

  local list_group = Cache.getData(self:classname(), "list_group")
  local list_prototype = Cache.getData(self:classname(), "list_prototype")
  local list_subgroup = Cache.getData(self:classname(), "list_subgroup")
  
  if find == true and (Technology.getValid() == true or filter_show_disable == true) then
    local group_name = "normal"
    if Technology.native().research_unit_count_formula ~= nil then group_name = "infinite" end

    local subgroup_name = "default"

    --list_subgroup[subgroup_name] = ItemPrototype.native().subgroup

    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
    list_subgroup[subgroup_name] = {name = subgroup_name}
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    
    local search_ingredients = ""
    
    for key, element in pairs(Technology.native().research_unit_ingredients) do
      search_ingredients = search_ingredients .. element.name
      list_group[group_name].search_ingredients = list_group[group_name].search_ingredients .. search_ingredients
    end
    
    local search_products = name
    list_group[group_name].search_products = list_group[group_name].search_products .. search_products

    table.insert(list_prototype[group_name][subgroup_name], {name=name, type=type, order=Technology.native().order, search_products=search_products, search_ingredients=search_ingredients})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#TechnologySelector] updateGroups
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function TechnologySelector.methods:updateGroups(event, action, item, item2, item3)
  Logging:trace(self:classname(), "updateGroups()", action, item, item2, item3)

  self:resetGroups()

  for key, technology in pairs(Player.getTechnologies()) do
    self:appendGroups(technology.name, "technology")
  end

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
  return ElementGui.getTooltipTechnology(prototype)
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



