require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module PropertiesTab
-- @extends #AbstractTab
--

PropertiesTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#PropertiesTab] getButtonCaption
--
-- @return #string
--
function PropertiesTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-properties"}
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#PropertiesTab] getButtonSprites
--
-- @return boolean
--
function PropertiesTab:getButtonSprites()
  return "property-white","property"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#PropertiesTab] isVisible
--
-- @return boolean
--
function PropertiesTab:isVisible()
  return User.getModGlobalSetting("properties_tab")
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#PropertiesTab] isSpecial
--
-- @return boolean
--
function PropertiesTab:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#PropertiesTab] hasIndexModel
--
-- @return #boolean
--
function PropertiesTab:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#PropertiesTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function PropertiesTab:addTableHeader(itable, prototype_compare)
  Logging:debug(self.classname, "addTableHeader()", itable)

  self:addCellHeader(itable, "property", {"helmod_result-panel.col-header-name"})
  for index,prototype in pairs(prototype_compare) do
    local icon_type = nil
    local localised_name = nil
    if prototype.type == "entity" then
      local entity_prototype = EntityPrototype(prototype)
      icon_type = "entity"
      localised_name = entity_prototype:getLocalisedName()
    elseif prototype.type == "item" then
      local item_prototype = ItemPrototype(prototype)
      icon_type = "item"
      localised_name = item_prototype:getLocalisedName()
    elseif prototype.type == "fluid" then
      local fluid_prototype = FluidPrototype(prototype)
      icon_type = "fluid"
      localised_name = fluid_prototype:getLocalisedName()
    elseif string.find(prototype.type, "recipe") then
      local recipe_protoype = RecipePrototype(prototype)
      icon_type = recipe_protoype:getType()
      localised_name = recipe_protoype:getLocalisedName()
    elseif prototype.type == "technology" then
      local technology_protoype = Technology(prototype)
      icon_type = "technology"
      localised_name = technology_protoype:getLocalisedName()
    end
    local cell_header = GuiElement.add(itable, GuiFlowH("header", prototype.name, index))
    GuiElement.add(cell_header, GuiButtonSprite(self.classname, "element-delete", prototype.name, index):sprite(icon_type, prototype.name):tooltip(localised_name))
    if prototype.type == "technology" then
      GuiElement.add(cell_header, GuiCheckBox(self.classname, "technology-search", prototype.name, index):state(Technology(prototype):isResearched()):tooltip("isResearched"))
    end
  end

  self:addCellHeader(itable, "property_type", "Element Type")
  for index,prototype in pairs(prototype_compare) do
    GuiElement.add(itable, GuiLabel("element_type", prototype.name, index):caption(prototype.type))
  end

  self:addCellHeader(itable, "property_name", "Element Name")
  for index,prototype in pairs(prototype_compare) do
    local textfield = GuiElement.add(itable, GuiTextField("element_name", prototype.name, index):text(prototype.name))
    textfield.style.width = 300
  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#PropertiesTab] updateHeader
--
-- @param #LuaEvent event
--
function PropertiesTab:updateHeader(event)
  local info_panel = self:getInfoPanel3()
  local options_table = GuiElement.add(info_panel, GuiTable("options-table"):column(2))
  -- nil values
  local switch_nil = "left"
  if User.getParameter("filter-nil-property") == true then
    switch_nil = "right"
  end
  GuiElement.add(options_table, GuiLabel("filter-nil-property"):caption("Hide nil values:"))
  local filter_switch = GuiElement.add(options_table, GuiSwitch(self.classname, "filter-nil-property-switch"):state(switch_nil):leftLabel("Off"):rightLabel("On"))
  -- difference values
  local switch_nil = "left"
  if User.getParameter("filter-difference-property") == true then
    switch_nil = "right"
  end
  GuiElement.add(options_table, GuiLabel("filter-difference-property"):caption("Show differences:"))
  local filter_switch = GuiElement.add(options_table, GuiSwitch(self.classname, "filter-difference-property-switch"):state(switch_nil):leftLabel("Off"):rightLabel("On"))
  
  GuiElement.add(options_table, GuiLabel("filter-property-label"):caption("Filter:"))
  local filter_value = User.getParameter("filter-property")
  local filter_field = GuiElement.add(options_table, GuiTextField(self.classname, "filter-property", "onchange"):text(filter_value))
  filter_field.style.width = 300
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#PropertiesTab] updateData
--
-- @param #LuaEvent event
--
function PropertiesTab:updateData(event)
  Logging:debug(self.classname, "updateData()", event)
  -- data
  local scroll_panel = self:getResultScrollPanel()
  scroll_panel.clear()
  -- data
  local filter = User.getParameter("filter-property")
  local prototype_compare = User.getParameter("prototype_compare")
  if prototype_compare ~= nil then
    local data = {}
    for _,prototype in pairs(prototype_compare) do
      local data_prototype = self:getPrototypeData(prototype)
      for _,properties in pairs(data_prototype) do
        if data[properties.name] == nil then data[properties.name] = {} end
        data[properties.name][prototype.name] = properties
      end
    end
    local result_table = GuiElement.add(scroll_panel, GuiTable("table-resources"):column(#prototype_compare+1):style("helmod_table-rule-odd"))

    self:addTableHeader(result_table, prototype_compare)

    for property, values in pairs(data) do
      if filter == nil or filter == "" or string.find(property, filter, 0, true) then
        if not(User.getParameter("filter-nil-property") == true and self:isNilLine(values, prototype_compare)) then
          if not(User.getParameter("filter-difference-property") == true and self:isSameLine(values, prototype_compare)) then
            local cell_name = GuiElement.add(result_table, GuiFrameH("property", property):style(helmod_frame_style.hidden))
            GuiElement.add(cell_name, GuiLabel("label"):caption(property))
  
            for index,prototype in pairs(prototype_compare) do
              -- col value
              local cell_value = GuiElement.add(result_table, GuiFrameH(property, prototype.name, index):style(helmod_frame_style.hidden))
              if values[prototype.name] ~= nil then
                local chmod = values[prototype.name].chmod
                local value = self:tableToString(values[prototype.name].value)
                GuiElement.add(cell_value, GuiLabel("prototype_chmod"):caption(string.format("[%s]:", chmod)))
                local label_value = GuiElement.add(cell_value, GuiLabel("prototype_value"):caption(value):style("helmod_label_max_600"))
                label_value.style.width = 400
              end
            end
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Table to string
--
-- @function [parent=#PropertiesTab] tableToString
--
-- @param #table value
--
function PropertiesTab:tableToString(value)
  if type(value) == "table" then
    local key2,_ = next(value)
    Logging:debug(self.classname, "tableToString()", value, type(key2))
    if type(key2) ~= "number" then
      local message = "{\n"
      local first = true
      for key,content in pairs(value) do
        local mask = "%s%s%s=%s%s"
        if not(first) then
          message = message..",\n"
        end
        if type(content) == "table" then
          message = string.format(mask, message, helmod_tag.color.orange, key, helmod_tag.color.close, string.match(serpent.dump(content),"do local _=(.*);return _;end"))
        else
          message = string.format(mask, message, helmod_tag.color.orange, key, helmod_tag.color.close, content)
        end
        first = false
      end
      value = message.."\n}"
    else
      local message = "{"
      local first = true
      for key,content in pairs(value) do
        if not(first) then
          message = message..","
        end
        message = message..tostring(self:tableToString(content))
        first = false
      end
      value = message.."}"
    end
  end
  return value
end
-------------------------------------------------------------------------------
-- Is nil line
--
-- @function [parent=#PropertiesTab] isNilLine
--
-- @param #table values
-- @param #table prototype_compare
--
function PropertiesTab:isNilLine(values, prototype_compare)
  local is_nil = true
  for index,prototype in pairs(prototype_compare) do
    if values[prototype.name] ~= nil and values[prototype.name].value ~= "nil" then is_nil = false end
  end
  return is_nil
end

-------------------------------------------------------------------------------
-- Is same line
--
-- @function [parent=#PropertiesTab] isSameLine
--
-- @param #table values
-- @param #table prototype_compare
--
function PropertiesTab:isSameLine(values, prototype_compare)
  local is_same = true
  local compare = nil
  for index,prototype in pairs(prototype_compare) do
    if values[prototype.name] ~= nil then
      if compare == nil then
        compare = values[prototype.name].value
      else
        if values[prototype.name].value ~= compare then is_same = false end
      end
    end
  end
  return is_same
end

-------------------------------------------------------------------------------
-- Get prototype data
--
-- @function [parent=#PropertiesTab] getPrototypeData
--
-- @param #table prototype
--
function PropertiesTab:getPrototypeData(prototype)
  Logging:debug(self.classname, "getPrototypeData()", prototype)
  -- data
  if prototype ~= nil then
    local lua_prototype = nil
    if prototype.type == "entity" then
      lua_prototype = EntityPrototype(prototype):native()
    elseif prototype.type == "item" then
      lua_prototype = ItemPrototype(prototype):native()
    elseif prototype.type == "fluid" then
      lua_prototype = FluidPrototype(prototype):native()
    elseif string.find(prototype.type, "recipe") then
      local recipe_prototype = RecipePrototype(prototype)
      lua_prototype = recipe_prototype:native()
      if recipe_prototype:getType() ~= "recipe" then
        function lua_prototype:help()
          local help = "Help for LuaRecipePrototype:Methods:help(...)Values:"
          for key,_ in pairs(lua_prototype) do
            help = string.format("%s %s [R]", help, key)
          end
          return help
        end
      end
    elseif prototype.type == "technology" then
      lua_prototype = Technology(prototype):native()
    end
    if lua_prototype ~= nil then
      Logging:debug(self.classname, "****************************")
      Logging:debug(self.classname, "prototype", prototype)
      return self:parseProperties(lua_prototype, 0, prototype.type)
    end
  end
  return {}
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PropertiesTab] onEvent
--
-- @param #LuaEvent event
--
function PropertiesTab:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  if event.action == "element-delete" then
    local prototype_compare = User.getParameter("prototype_compare") or {}
    local index = nil
    for i,prototype in pairs(prototype_compare) do
      if prototype.name == event.item1 then
        index = i
      end
    end
    if index ~= nil then
      table.remove(prototype_compare, index)
    end
    User.setParameter("prototype_compare", prototype_compare)
    self:updateData(event)
  end

  if event.action == "filter-nil-property-switch" then
    local switch_nil = event.element.switch_state == "right"
    User.setParameter("filter-nil-property", switch_nil)
    self:updateData(event)
  end

  if event.action == "filter-difference-property-switch" then
    local switch_nil = event.element.switch_state == "right"
    User.setParameter("filter-difference-property", switch_nil)
    self:updateData(event)
  end
  
  if event.action == "technology-search" then
    local state = event.element.state
    Player.getForce().technologies[event.item1].researched = state
    self:updateData(event)
  end
  
  if event.action == "filter-property" then
    local filter = event.element.text
    User.setParameter("filter-property", filter)
    self:updateData(event)
  end
end
-------------------------------------------------------------------------------
-- Parse Properties
--
-- @function [parent=#PropertiesTab] parseProperties
--
-- @param #LuaObject prototype
--
function PropertiesTab:parseProperties(prototype, level, prototype_type)
  Logging:debug(self.classname, "->prototype", prototype, level, prototype_type)
  if prototype == nil then return "nil" end
  if level > 2 then 
    return prototype
    --return string.match(serpent.dump(prototype),"do local _=(.*);return _;end")
  end
  -- special
  local isluaobject, error = pcall(function() local test = prototype:help() return true end)
  local object_type = type(prototype)
  if isluaobject then
    local lua_type = string.match(prototype:help(), "Help for%s([^:]*)")
    if lua_type == "LuaEntityPrototype" and prototype.name == "character" then
      table.insert(properties, {name = "PLAYER.character_crafting_speed_modifier", chmod = "RW", value = Player.native().character_crafting_speed_modifier})
      table.insert(properties, {name = "PLAYER.character_mining_speed_modifier", chmod = "RW", value = Player.native().character_mining_speed_modifier})
      table.insert(properties, {name = "PLAYER.character_additional_mining_categories", chmod = "RW", value = string.match(serpent.dump(Player.native().character_additional_mining_categories),"do local _=(.*);return _;end")})
      table.insert(properties, {name = "PLAYER.character_running_speed_modifier", chmod = "RW", value = Player.native().character_running_speed_modifier})
      table.insert(properties, {name = "PLAYER.character_build_distance_bonus", chmod = "RW", value = Player.native().character_build_distance_bonus})
      table.insert(properties, {name = "PLAYER.character_item_drop_distance_bonus", chmod = "RW", value = Player.native().character_item_drop_distance_bonus})
      table.insert(properties, {name = "PLAYER.character_reach_distance_bonus", chmod = "RW", value = Player.native().character_reach_distance_bonus})
      table.insert(properties, {name = "PLAYER.character_resource_reach_distance_bonus", chmod = "RW", value = Player.native().character_resource_reach_distance_bonus})
      table.insert(properties, {name = "PLAYER.character_item_pickup_distance_bonus", chmod = "RW", value = Player.native().character_item_pickup_distance_bonus})
      table.insert(properties, {name = "PLAYER.character_loot_pickup_distance_bonus", chmod = "RW", value = Player.native().character_loot_pickup_distance_bonus})
      table.insert(properties, {name = "PLAYER.character_inventory_slots_bonus", chmod = "RW", value = Player.native().character_inventory_slots_bonus})
      table.insert(properties, {name = "PLAYER.character_logistic_slot_count_bonus", chmod = "RW", value = Player.native().character_logistic_slot_count_bonus})
      table.insert(properties, {name = "PLAYER.character_trash_slot_count_bonus", chmod = "RW", value = Player.native().character_trash_slot_count_bonus})
      table.insert(properties, {name = "PLAYER.character_maximum_following_robot_count_bonus", chmod = "RW", value = Player.native().character_maximum_following_robot_count_bonus})
      table.insert(properties, {name = "PLAYER.character_health_bonus", chmod = "RW", value = Player.native().character_health_bonus})
    end
    if (lua_type == "LuaEntityPrototype" or lua_type == "LuaItemPrototype") and prototype.type == "inserter" then
      table.insert(properties, {name = "FORCE.inserter_stack_size_bonus", chmod = "RW", value = Player.getForce().inserter_stack_size_bonus})
      table.insert(properties, {name = "FORCE.stack_inserter_capacity_bonus", chmod = "RW", value = Player.getForce().stack_inserter_capacity_bonus})
    end
    if lua_type == "LuaFluidBoxPrototype" then
      return FluidboxPrototype(prototype):toData()
    end
  
    local help_string = string.gmatch(prototype:help(),"(%S+) [[](RW?)[]]")
    local properties = {}
    for key, chmod in help_string do
      local value = nil
        Logging:debug(self.classname, "prototype key", key)
        pcall( function()
          value = self:parseProperties(prototype[key], level + 1, nil)
        end)
        if key == "heat_energy_source_prototype" then
          Logging:debug(self.classname, key, chmod, value)
        end
        if level == 0 then
          table.insert(properties, {name = key, chmod = chmod, value = value})
        else
          properties[key]=value
        end
    end
    return properties
  elseif object_type == "table" then
    local properties = {}
    for key,value in pairs(prototype) do
      properties[key] = self:parseProperties(value, level + 1, nil)
    end
    return properties
  else
    return prototype
  end
end