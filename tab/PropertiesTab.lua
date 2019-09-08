require "tab.AbstractTab"
require "model.BurnerPrototype"
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
-- Get Button Styles
--
-- @function [parent=#PropertiesTab] getButtonStyles
--
-- @return boolean
--
function PropertiesTab:getButtonStyles()
  return "helmod_button_icon_property","helmod_button_icon_property_selected"
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
  for _,prototype in pairs(prototype_compare) do
    local icon_type = nil
    local localised_name = nil
    if prototype.type == "entity" then
      local entity_prototype = EntityPrototype(prototype)
      icon_type = Player.getEntityIconType(entity_prototype:native())
      localised_name = entity_prototype:getLocalisedName()
    elseif prototype.type == "item" then
      local item_prototype = ItemPrototype(prototype)
      icon_type = Player.getEntityIconType(item_prototype:native())
      localised_name = item_prototype:getLocalisedName()
    elseif prototype.type == "fluid" then
      local fluid_prototype = FluidPrototype(prototype)
      icon_type = Player.getEntityIconType(fluid_prototype:native())
      localised_name = fluid_prototype:getLocalisedName()
    elseif string.find(prototype.type, "recipe") then
      local recipe_protoype = RecipePrototype(prototype)
      icon_type = Player.getEntityIconType(recipe_protoype:native())
      localised_name = recipe_protoype:getLocalisedName()
    elseif prototype.type == "technology" then
      local technology_protoype = Technology(prototype)
      icon_type = Player.getEntityIconType(technology_protoype:native())
      localised_name = technology_protoype:getLocalisedName()
    end
    ElementGui.addGuiButtonSprite(itable, self.classname.."=element-delete=ID=", icon_type, prototype.name, prototype.name, localised_name)

  end

  self:addCellHeader(itable, "property_type", "Element Type")
  for _,prototype in pairs(prototype_compare) do
    ElementGui.addGuiLabel(itable, string.format("element_type_%s", prototype.name), prototype.type)
  end

  self:addCellHeader(itable, "property_name", "Element Name")
  for _,prototype in pairs(prototype_compare) do
    ElementGui.addGuiText(itable, string.format("element_name_%s", prototype.name), prototype.name)
  end
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
  --local result_panel = self:getResultPanel({"helmod_result-panel.tab-title-properties"})
  local scroll_panel = self:getResultScrollPanel()
  scroll_panel.clear()

  local prototype_compare = User.getParameter("prototype_compare")
  if prototype_compare ~= nil then
    local data = {}
    for _,prototype in pairs(prototype_compare) do
      local data_prototype = self:getPrototypeData(prototype)
      --Logging:debug(self.classname, "data_prototype", data_prototype)
      for _,properties in pairs(data_prototype) do
        if data[properties.name] == nil then data[properties.name] = {} end
        data[properties.name][prototype.name] = properties
      end
    end
    local result_table = ElementGui.addGuiTable(scroll_panel,"table-resources",#prototype_compare+1, "helmod_table-rule-odd")

    self:addTableHeader(result_table, prototype_compare)

    for property, values in pairs(data) do
      local cell_name = ElementGui.addGuiFrameH(result_table, string.format("property_%s", property), helmod_frame_style.hidden)
      ElementGui.addGuiLabel(cell_name, "label", property)

      -- col chmod
      --local cell_chmod = ElementGui.addGuiFrameH(gui_table,property.name.."_chmod", helmod_frame_style.hidden)
      --ElementGui.addGuiLabel(cell_chmod, "label", property.chmod or "")

      for _,prototype in pairs(prototype_compare) do
        -- col value
        local cell_value = ElementGui.addGuiFrameH(result_table, string.format("%s_%s", property, prototype.name), helmod_frame_style.hidden)
        if values[prototype.name] ~= nil then
          local chmod = values[prototype.name].chmod
          local value = values[prototype.name].value
          local label_value = ElementGui.addGuiLabel(cell_value, "prototype_value", string.format("[%s]: %s", chmod, value), "helmod_label_max_600", nil, false)
          label_value.style.width = 400
        end
      end
    end

  end
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
      Logging:debug(self.classname, "prototype", prototype)
      return self:parseProperties(lua_prototype, 0)
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
end
-------------------------------------------------------------------------------
-- Parse Properties
--
-- @function [parent=#PropertiesTab] parseProperties
--
-- @param #LuaObject prototype
--
function PropertiesTab:parseProperties(prototype, level)
  Logging:debug(self.classname, "***************************")
  local properties = {}

  local help_string = string.gmatch(prototype:help(),"(%S+) [[](RW?)[]]")
  Logging:debug(self.classname, "help_string", help_string)

  for key, chmod in help_string do
    Logging:debug(self.classname, "loop", key)
    pcall(function()
      local type = type(prototype[key])
      local value = tostring(prototype[key])
      Logging:debug(self.classname, "property", key, type, value)
      if key == "group" or key == "subgroup" then
        local group = prototype[key]
        value = group.name
      elseif key == "burner_prototype" then
        local burner_prototype = BurnerPrototype(prototype[key]):toString()
        value = burner_prototype
      elseif type == "table" then
        local test, error = pcall(function() prototype[key]:help() return true end)
        pcall(function() Logging:debug(self.classname, "level", level, "help", prototype[key]:help(), "test", test, error, level < 2 and test) end)
        if level < 2 and test then
          local result = PropertiesTab:parseProperties(prototype[key], level + 1)
          value = ""
          for _, property in pairs(result) do
            value = value .. property.name .. " = " .. property.value .. "\n"
          end
        else
          value = string.match(serpent.dump(prototype[key]),"do local _=(.*);return _;end")
        end
      end
      table.insert(properties, {name = key, chmod = chmod, value = value})
      --Logging:debug(self.classname, "help_string:", i, type, value)
    end)
  end
  return properties
end
