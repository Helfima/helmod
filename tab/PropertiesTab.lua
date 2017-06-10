require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module PropertiesTab
-- @extends #ElementGui
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
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PropertiesTab.methods:addTableHeader(player, itable)
  Logging:debug(self:classname(), "addTableHeader():", player, itable)

  -- data columns
  self:addCellHeader(player, itable, "property", {"helmod_result-panel.col-header-name"})
  self:addCellHeader(player, itable, "chmod", {"helmod_result-panel.col-header-chmod"})
  self:addCellHeader(player, itable, "value", {"helmod_result-panel.col-header-value"})
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#PropertiesTab] addTableRow
--
-- @param #LuaPlayer player
--
function PropertiesTab.methods:addTableRow(player, guiTable, property)
  Logging:debug(self:classname(), "addTableRow():", player, guiTable, property)
  local model = self.model:getModel(player)

  -- col property
  local guiCount = self:addGuiFlowH(guiTable,property.name.."_name")
  self:addGuiLabel(guiCount, "label", property.name)

  -- col chmod
  local guiCount = self:addGuiFlowH(guiTable,property.name.."_chmod")
  self:addGuiLabel(guiCount, "label", property.chmod or "")

  -- col value
  local guiType = self:addGuiFlowH(guiTable,property.name.."_value")
  self:addGuiLabel(guiType, "label", property.value, "helmod_label_max_600", nil, false)

end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#PropertiesTab] updateData
--
-- @param #LuaPlayer player
--
function PropertiesTab.methods:updateData(player)
  Logging:debug(self:classname(), "updateData():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  -- data
  local resultPanel = self.parent:getResultPanel(player, {"helmod_result-panel.tab-title-properties"})
  local listPanel = self:addGuiFlowH(resultPanel, "list-element", "helmod_flow_full_resize_row")
  local scrollPanel = self.parent:getResultScrollPanel(player)

  local globalPlayer = self.player:getGlobal(player)
  if globalPlayer["prototype-properties"] ~= nil and globalPlayer["prototype-properties"].name ~= nil then
    local prototype_name = globalPlayer["prototype-properties"].name
    local prototype_type = globalPlayer["prototype-properties"].type
    local prototype = nil
    if prototype_type == "entity" then
      prototype = self.player:getEntityPrototype(prototype_name)
      if prototype ~= nil then
        self:addGuiButtonSprite(listPanel, self:classname().."=entity-select=ID=", self.player:getEntityIconType(prototype), prototype.name, prototype.name, self.player:getLocalisedName(player, prototype))
      end
    elseif prototype_type == "item" then
      prototype = self.player:getItemPrototype(prototype_name)
      if prototype ~= nil then
        self:addGuiButtonSprite(listPanel, self:classname().."=item-select=ID=", self.player:getItemIconType(prototype), prototype.name, prototype.name, self.player:getLocalisedName(player, prototype))
      end
    elseif prototype_type == "fluid" then
      prototype = self.player:getFluidPrototype(prototype_name)
      if prototype ~= nil then
        self:addGuiButtonSprite(listPanel, self:classname().."=fluid-select=ID=", self.player:getItemIconType(prototype), prototype.name, prototype.name, self.player:getLocalisedName(player, prototype))
      end
    elseif prototype_type == "recipe" then
      prototype = self.player:getRecipe(player, prototype_name)
      if prototype ~= nil then
        self:addGuiButtonSprite(listPanel, self:classname().."=recipe-select=ID=", self.player:getRecipeIconType(player, prototype), prototype.name, prototype.name, self.player:getRecipeLocalisedName(player, prototype))
      end
    elseif prototype_type == "technology" then
      prototype = self.player:getTechnology(player, prototype_name)
      if prototype ~= nil then
        self:addGuiButtonSprite(listPanel, self:classname().."=technology-select=ID=", "technology", prototype.name, prototype.name, self.player:getTechnologyLocalisedName(player, prototype))
      end
    end
    if prototype ~= nil then
      self:addGuiLabel(listPanel, "type-label", prototype_type, "helmod_label_right_100")
      local resultTable = self:addGuiTable(scrollPanel,"table-resources",3)

      self:addTableHeader(player, resultTable)

      local properties = self:parseProperties(prototype, 0)

      for _, property in pairs(properties) do
        self:addTableRow(player, resultTable, property)
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
