-------------------------------------------------------------------------------
-- Class to build PropertiesPanel panel
--
-- @module PropertiesPanel
-- @extends #Form
--

PropertiesPanel = newclass(Form,function(base,classname)
  Form.init(base,classname)
  base.add_special_button = true
end)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PropertiesPanel] onInit
--
function PropertiesPanel:onInit()
  self.panelCaption = ({"helmod_result-panel.tab-button-properties"})
  self.help_button = false
end

-------------------------------------------------------------------------------
-- On bind
--
-- @function [parent=#PropertiesPanel] onBind
--
function PropertiesPanel:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.updateData)
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#PropertiesPanel] getButtonSprites
--
-- @return boolean
--
function PropertiesPanel:getButtonSprites()
  return "property-white","property"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#PropertiesPanel] isVisible
--
-- @return boolean
--
function PropertiesPanel:isVisible()
  return User.getModGlobalSetting("hidden_panels")
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#PropertiesPanel] isSpecial
--
-- @return boolean
--
function PropertiesPanel:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#PropertiesPanel] getMenuPanel
--
function PropertiesPanel:getMenuPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "menu-panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameH(panel_name))
  panel.style.horizontally_stretchable = true
  --panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create header panel
--
-- @function [parent=#PropertiesPanel] getHeaderPanel
--
function PropertiesPanel:getHeaderPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "header-panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV(panel_name))
  panel.style.horizontally_stretchable = true
  --panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create content panel
--
-- @function [parent=#PropertiesPanel] getContentPanel
--
function PropertiesPanel:getContentPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "content"
  local scroll_name = "data-panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name][scroll_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV(panel_name))
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true
  local scroll_panel = GuiElement.add(panel, GuiScroll(scroll_name))
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PropertiesPanel] onEvent
--
-- @param #LuaEvent event
--
function PropertiesPanel:onEvent(event)
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
-- Update data
--
-- @function [parent=#PropertiesPanel] onUpdate
--
-- @param #LuaEvent event
--
function PropertiesPanel:onUpdate(event)
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local width_main, height_main = User.getMainSizes()
  flow_panel.style.height = height_main
  flow_panel.style.width = width_main
  
  self:updateMenu(event)
  self:updateHeader(event)
  self:updateData(event)
  
end

-------------------------------------------------------------------------------
-- Update menu
--
-- @function [parent=#PropertiesPanel] updateMenu
--
-- @param #LuaEvent event
--
function PropertiesPanel:updateMenu(event)
  local action_panel = self:getMenuPanel()
  action_panel.clear()
  GuiElement.add(action_panel, GuiButton("HMEntitySelector", "OPEN", "HMPropertiesPanel"):caption({"helmod_result-panel.select-button-entity"}))
  GuiElement.add(action_panel, GuiButton("HMItemSelector", "OPEN", "HMPropertiesPanel"):caption({"helmod_result-panel.select-button-item"}))
  GuiElement.add(action_panel, GuiButton("HMFluidSelector", "OPEN", "HMPropertiesPanel"):caption({"helmod_result-panel.select-button-fluid"}))
  GuiElement.add(action_panel, GuiButton("HMRecipeSelector", "OPEN", "HMPropertiesPanel"):caption({"helmod_result-panel.select-button-recipe"}))
  GuiElement.add(action_panel, GuiButton("HMTechnologySelector", "OPEN", "HMPropertiesPanel"):caption({"helmod_result-panel.select-button-technology"}))
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#PropertiesPanel] updateData
--
-- @param #LuaEvent event
--
function PropertiesPanel:updateData(event)
  if not(self:isOpened()) then return end
  -- data
  local content_panel = self:getContentPanel()
  content_panel.clear()
  -- data
  local filter = User.getParameter("filter-property")
  local prototype_compare = User.getParameter("prototype_compare")
  if prototype_compare ~= nil then
    local data = {}
    for _,prototype in pairs(prototype_compare) do
      local data_prototype = self:getPrototypeData(prototype)
      local key = string.format("%s_%s", prototype.type, prototype.name)
      for _,properties in pairs(data_prototype) do
        if data[properties.name] == nil then data[properties.name] = {} end
        data[properties.name][key] = properties
      end
    end
    local result_table = GuiElement.add(content_panel, GuiTable("table-resources"):column(#prototype_compare+1):style("helmod_table-rule-odd"))

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
              local key = string.format("%s_%s", prototype.type, prototype.name)
              if values[key] ~= nil then
                local chmod = values[key].chmod
                local value = self:tableToString(values[key].value)
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
-- Add cell header
--
-- @function [parent=#PropertiesPanel] addCellHeader
--
-- @param #LuaGuiElement guiTable
-- @param #string name
-- @param #string caption
-- @param #string sorted
--
function PropertiesPanel:addCellHeader(guiTable, name, caption, sorted)
  if (name ~= "index" and name ~= "id" and name ~= "name" and name ~= "type") or User.getModGlobalSetting("display_data_col_"..name) then
    local cell = GuiElement.add(guiTable, GuiFrameH("header", name):style(helmod_frame_style.hidden))
    GuiElement.add(cell, GuiLabel("label"):caption(caption))
  end
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#PropertiesPanel] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function PropertiesPanel:addTableHeader(itable, prototype_compare)
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
-- @function [parent=#PropertiesPanel] updateHeader
--
-- @param #LuaEvent event
--
function PropertiesPanel:updateHeader(event)
  local info_panel = self:getHeaderPanel()
  info_panel.clear()
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
-- Parse Properties
--
-- @function [parent=#PropertiesPanel] parseProperties
--
-- @param #LuaObject prototype
--
function PropertiesPanel:parseProperties(prototype, level, prototype_type)
  if prototype == nil then return "nil" end
  if level > 2 then 
    return prototype
    --return string.match(serpent.dump(prototype),"do local _=(.*);return _;end")
  end
  -- special
  local isluaobject, error = pcall(function() local test = prototype:help() return true end)
  local object_type = type(prototype)
  if isluaobject then
    local properties = {}
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
        pcall( function()
          value = self:parseProperties(prototype[key], level + 1, nil)
        end)
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

-------------------------------------------------------------------------------
-- Table to string
--
-- @function [parent=#PropertiesPanel] tableToString
--
-- @param #table value
--
function PropertiesPanel:tableToString(value)
  if type(value) == "table" then
    local key2,_ = next(value)
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
-- @function [parent=#PropertiesPanel] isNilLine
--
-- @param #table values
-- @param #table prototype_compare
--
function PropertiesPanel:isNilLine(values, prototype_compare)
  local is_nil = true
  for index,prototype in pairs(prototype_compare) do
    local key = string.format("%s_%s", prototype.type, prototype.name)
    if values[key] ~= nil and values[key].value ~= "nil" then is_nil = false end
  end
  return is_nil
end

-------------------------------------------------------------------------------
-- Is same line
--
-- @function [parent=#PropertiesPanel] isSameLine
--
-- @param #table values
-- @param #table prototype_compare
--
function PropertiesPanel:isSameLine(values, prototype_compare)
  local is_same = true
  local compare = nil
  for index,prototype in pairs(prototype_compare) do
    local key = string.format("%s_%s", prototype.type, prototype.name)
    if values[key] ~= nil then
      if compare == nil then
        compare = values[key].value
      else
        if values[key].value ~= compare then is_same = false end
      end
    end
  end
  return is_same
end

-------------------------------------------------------------------------------
-- Get prototype data
--
-- @function [parent=#PropertiesPanel] getPrototypeData
--
-- @param #table prototype
--
function PropertiesPanel:getPrototypeData(prototype)
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
      return self:parseProperties(lua_prototype, 0, prototype.type)
    end
  end
  return {}
end