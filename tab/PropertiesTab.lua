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
    GuiElement.add(itable, GuiButtonSprite(self.classname, "element-delete=ID", prototype.name, index):sprite(icon_type, prototype.name):tooltip(localised_name))

  end

  self:addCellHeader(itable, "property_type", "Element Type")
  for index,prototype in pairs(prototype_compare) do
    GuiElement.add(itable, GuiLabel("element_type", prototype.name, index):caption(prototype.type))
  end

  self:addCellHeader(itable, "property_name", "Element Name")
  for index,prototype in pairs(prototype_compare) do
    GuiElement.add(itable, GuiLabel("element_name", prototype.name, index):caption(prototype.name))
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
  local scroll_panel = self:getResultScrollPanel()
  scroll_panel.clear()

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
      local cell_name = GuiElement.add(result_table, GuiFrameH("property", property):style(helmod_frame_style.hidden))
      GuiElement.add(cell_name, GuiLabel("label"):caption(property))

      for index,prototype in pairs(prototype_compare) do
        -- col value
        local cell_value = GuiElement.add(result_table, GuiFrameH(property, prototype.name, index):style(helmod_frame_style.hidden))
        if values[prototype.name] ~= nil then
          local chmod = values[prototype.name].chmod
          local value = values[prototype.name].value
          local label_value = GuiElement.add(cell_value, GuiLabel("prototype_value"):caption(string.format("[%s]: %s", chmod, value)):style("helmod_label_max_600"))
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
        value = string.format("{name=%s,type=%s,order_in_recipe=%s,order=%s}", group.name, group.type, group.order_in_recipe, group.order) 
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
    end)
  end
  return properties
end
