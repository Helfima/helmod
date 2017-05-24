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
  self:addCellHeader(player, itable, "value", {"helmod_result-panel.col-header-value"})
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#PropertiesTab] addTableRow
--
-- @param #LuaPlayer player
--
function PropertiesTab.methods:addTableRow(player, guiTable, property, value)
  Logging:debug(self:classname(), "addTableRow():", player, guiTable, property, value)
  local model = self.model:getModel(player)

  -- col property
  local guiCount = self:addGuiFlowH(guiTable,property.."_name")
  self:addGuiLabel(guiCount, "label", property)

  -- col value
  local guiType = self:addGuiFlowH(guiTable,property.."_value")
  self:addGuiLabel(guiType, "label", value, "helmod_label_max_600", nil, false)

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
  local scrollPanel = self.parent:getResultScrollPanel(player, {"helmod_result-panel.tab-title-properties"})

  local globalPlayer = self.player:getGlobal(player)
  if globalPlayer["entity-properties"] ~= nil then
    local prototype = self.player:getEntityPrototype(globalPlayer["entity-properties"])
    if prototype ~= nil then
      self:addGuiButtonSprite(scrollPanel, self:classname().."=entity-select=ID=", self.player:getEntityIconType(prototype), prototype.name, prototype.name, self.player:getLocalisedName(player, prototype))

      local resultTable = self:addGuiTable(scrollPanel,"table-resources",2)

      self:addTableHeader(player, resultTable)

      local properties = self:parseProperties(prototype)

      for _, property in pairs(properties) do
        self:addTableRow(player, resultTable, property.name, property.value)
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
function PropertiesTab.methods:parseProperties(prototype)
  local properties = {}

  local help_string = string.gmatch(prototype:help(),"(%S+) [[]R[]]")

  for i in help_string do
    --Logging:debug(self:classname(), "help_string:", i)
    pcall(function()
      local type = type(prototype[i])
      local value = tostring(prototype[i])
      if type == "table" then
        if pcall(function() prototype[i]:help() end) then
          local result = PropertiesTab.methods:parseProperties(prototype[i])
          value = ""
          for _, property in pairs(result) do
            value = value .. property.name .. " = " .. property.value .. "\n"
          end
        else
          value = string.match(serpent.dump(prototype[i]),"do local _=(.*);return _;end")
        end
      end
      table.insert(properties, {name = i, value = value})
      --Logging:debug(self:classname(), "help_string:", i, type, value)
    end)
  end
  return properties
end
