require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module TechnologySelector
-- @extends #AbstractSelector
--

TechnologySelector = setclass("HMTechnologySelector", AbstractSelector)

local firstGroup = nil

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
-- Check filter
--
-- @function [parent=#TechnologySelector] checkFilter
--
-- @param #LuaTechnology prototype
--
-- @return boolean
--
function TechnologySelector.methods:checkFilter(prototype)
  Logging:trace(self:classname(), "checkFilter()")
  local filter_prototype = self:getFilter()
  local filter_prototype_product = self:getProductFilter()

  if filter_prototype ~= nil and filter_prototype ~= "" then
    if filter_prototype_product == true then
      local elements = prototype.research_unit_ingredients
      for key, element in pairs(elements) do
        local search = element.name:lower():gsub("[-]"," ")
        if string.find(search, filter_prototype) then
          return true
        end
      end
    else
      local search = prototype.name:lower():gsub("[-]"," ")
      if string.find(search, filter_prototype) then
        return true
      end
    end
  else
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#TechnologySelector] appendGroups
--
-- @param #string name
-- @param #string type
-- @param #table list_group
-- @param #table list_subgroup
-- @param #table list_prototype
--
function TechnologySelector.methods:appendGroups(technology, type, list_group, list_subgroup, list_prototype)
  Logging:debug(self:classname(), "appendGroups()", technology.name, type)
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")

  if (technology.valid == true or filter_show_disable == true) then
    Technology.load(technology.name, type)
    local find = self:checkFilter(Technology.native())

    if find == true then
      local group_name = "normal"
      if Technology.native().research_unit_count_formula ~= nil then group_name = "infinite" end

      local subgroup_name = "default"

      if firstGroup == nil then firstGroup = group_name end
      list_group[group_name] = {name = group_name}
      list_subgroup[subgroup_name] = {name = subgroup_name}
      if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
      if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
      table.insert(list_prototype[group_name][subgroup_name],{name = technology.name, type = type, order = Technology.native().order})
    end
  end
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
-- @return list_group, list_subgroup, list_prototype
--
function TechnologySelector.methods:updateGroups(item, item2, item3)
  Logging:debug(self:classname(), "updateGroups():", item, item2, item3)
  local global_player = Player.getGlobal()
  local global_gui = Player.getGlobalGui()
  -- recuperation recipes
  local list_group = {}
  local list_subgroup = {}
  local list_prototype = {}

  firstGroup = nil

  for key, technology in pairs(Player.getTechnologies()) do
    self:appendGroups({name = technology.name, valid = technology.valid}, "technology", list_group, list_subgroup, list_prototype)
  end

  if list_prototype[global_player.recipeGroupSelected] == nil then
    global_player.recipeGroupSelected = firstGroup
  end
  Logging:debug(self:classname(), "list_group", list_group, "list_subgroup", list_subgroup, "list_prototype", list_prototype)
  return list_group, list_subgroup, list_prototype
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
  Technology.load(prototype)
  -- insert __1__ value
  table.insert(tooltip, Technology.getLocalisedName())

  -- insert __2__ value
  table.insert(tooltip, Technology.getLevel())

  -- insert __3__ value
  table.insert(tooltip, Technology.getFormula() or "")

  -- insert __4__ value
  local lastTooltip = tooltip
  for _,element in pairs(Technology.getIngredients()) do
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



