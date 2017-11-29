require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module PropertiesTab
-- @extends #AbstractTab
--

PropertiesTab = setclass("HMPropertiesTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#PropertiesTab] getButtonCaption
--
-- @return #string
--
function PropertiesTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-properties"}
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#PropertiesTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function PropertiesTab.methods:addTableHeader(itable)
  Logging:debug(self:classname(), "addTableHeader():", itable)

  -- data columns
  self:addCellHeader(itable, "property", {"helmod_result-panel.col-header-name"})
  self:addCellHeader(itable, "chmod", {"helmod_result-panel.col-header-chmod"})
  self:addCellHeader(itable, "value", {"helmod_result-panel.col-header-value"})
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#PropertiesTab] addTableRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table property
--
function PropertiesTab.methods:addTableRow(guiTable, property)
  Logging:debug(self:classname(), "addTableRow():", guiTable, property)
  -- col property
  local guiCount = ElementGui.addGuiFlowH(guiTable,property.name.."_name")
  ElementGui.addGuiLabel(guiCount, "label", property.name)

  -- col chmod
  local guiCount = ElementGui.addGuiFlowH(guiTable,property.name.."_chmod")
  ElementGui.addGuiLabel(guiCount, "label", property.chmod or "")

  -- col value
  local guiType = ElementGui.addGuiFlowH(guiTable,property.name.."_value")
  ElementGui.addGuiLabel(guiType, "label", property.value, "helmod_label_max_600", nil, false)

end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#PropertiesTab] updateData
--
function PropertiesTab.methods:updateData()
  Logging:debug(self:classname(), "updateData()")
  local globalGui = Player.getGlobalGui()
  -- data
  local resultPanel = self.parent:getResultPanel({"helmod_result-panel.tab-title-properties"})
  local listPanel = ElementGui.addGuiFlowH(resultPanel, "list-element", "helmod_flow_full_resize_row")
  local scrollPanel = self.parent:getResultScrollPanel()

  local globalPlayer = Player.getGlobal()
  if globalPlayer["prototype-properties"] ~= nil and globalPlayer["prototype-properties"].name ~= nil then
    local prototype_name = globalPlayer["prototype-properties"].name
    local prototype_type = globalPlayer["prototype-properties"].type
    local prototype = nil
    if prototype_type == "entity" then
      EntityPrototype.load(prototype_name)
      prototype = EntityPrototype.native()
      if prototype ~= nil then
        ElementGui.addGuiButtonSprite(listPanel, self:classname().."=entity-select=ID=", Player.getEntityIconType(prototype), prototype.name, prototype.name, EntityPrototype.getLocalisedName())
      end
    elseif prototype_type == "item" then
      ItemPrototype.load(prototype_name)
      prototype = ItemPrototype.native()
      if prototype ~= nil then
        ElementGui.addGuiButtonSprite(listPanel, self:classname().."=item-select=ID=", Player.getItemIconType(prototype), prototype.name, prototype.name, ItemPrototype.getLocalisedName())
      end
    elseif prototype_type == "fluid" then
      FluidPrototype.load(prototype_name)
      prototype = FluidPrototype.native()
      if prototype ~= nil then
        ElementGui.addGuiButtonSprite(listPanel, self:classname().."=fluid-select=ID=", Player.getItemIconType(prototype), prototype.name, prototype.name, FluidPrototype.getLocalisedName())
      end
    elseif prototype_type == "recipe" then
      RecipePrototype.load(prototype_name)
      prototype = RecipePrototype.native()
      if prototype ~= nil then
        ElementGui.addGuiButtonSprite(listPanel, self:classname().."=recipe-select=ID=", Player.getRecipeIconType(prototype), prototype.name, prototype.name, RecipePrototype.getLocalisedName())
      end
    elseif prototype_type == "technology" then
      Technology.load(prototype_name)
      prototype = Technology.native()
     if prototype ~= nil then
        ElementGui.addGuiButtonSprite(listPanel, self:classname().."=technology-select=ID=", "technology", prototype.name, prototype.name, Technology.getLocalisedName())
      end
    end
    if prototype ~= nil then
      ElementGui.addGuiLabel(listPanel, "type-label", prototype_type, "helmod_label_right_100")
      local resultTable = ElementGui.addGuiTable(scrollPanel,"table-resources",3)

      self:addTableHeader(resultTable)

      local properties = self:parseProperties(prototype, 0)

      for _, property in pairs(properties) do
        if property.value ~= "nil" then
          Logging:debug(self:classname(), "property:", property)
          self:addTableRow(resultTable, property)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Parse Properties
--
-- @function [parent=#PropertiesTab] parseProperties
--
-- @param #LuaObject prototype
--
function PropertiesTab.methods:parseProperties(prototype, level)
  local properties = {}

  local help_string = string.gmatch(prototype:help(),"(%S+) [[](RW?)[]]")

  for key, chmod in help_string do
    --Logging:debug(self:classname(), "help_string:", i)
    pcall(function()
      local type = type(prototype[key])
      local value = tostring(prototype[key])
      if type == "table" then
        if level < 2 and pcall(function() prototype[key]:help() end) then
          local result = PropertiesTab.methods:parseProperties(prototype[key], level + 1)
          value = ""
          for _, property in pairs(result) do
            value = value .. property.name .. " = " .. property.value .. "\n"
          end
        else
          value = string.match(serpent.dump(prototype[key]),"do local _=(.*);return _;end")
        end
      end
      table.insert(properties, {name = key, chmod = chmod, value = value})
      --Logging:debug(self:classname(), "help_string:", i, type, value)
    end)
  end
  return properties
end
