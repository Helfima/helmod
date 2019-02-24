---
-- Description of the module.
-- @module Event
--
local Event = {
  -- single-line comment
  classname = "HMEvent",
  name = "",
  action = "",
  item1 = "",
  item2 = "",
  item3  = "",
  state = 0,
  STATE_START=0,
  STATE_CONTINUE=1,
  STATE_RELEASE=9,
  next = false
}

local lua_event = nil
local type_event = nil

local pattern = "([^=]*)=?([^=]*)=?[^=]*=?([^=]*)=?([^=]*)=?([^=]*)"

-------------------------------------------------------------------------------
-- Return factorio event
--
-- @function [parent=#Event] native
--
-- @return #lua_event
--
function Event.native()
  return lua_event
end

-------------------------------------------------------------------------------
-- Load factorio event
--
-- @function [parent=#Event] load
--
-- @param #LuaEvent event
-- @param #String type
--
-- @return #Event
--
function Event.load(event, type)
  Logging:debug(Event.classname, "load(event, type)", event, type)
  if(event.element ~= nil) then Logging:debug(Event.classname, "element name", event.element.name) end
  if(Event.state == Event.STATE_RELEASE) then
    lua_event = event
    type_event = type
    Event.name, Event.action, Event.item1, Event.item2, Event.item3 = string.match(Event.getElementName(),pattern)
    Event.state = Event.STATE_START
    Event.next = false
  end
  Logging:debug(Event.classname, "loaded", Event)
  return Event
end

-------------------------------------------------------------------------------
-- Set next event
--
-- @function [parent=#Event] setNext
--
-- @param #String name
-- @param #String action
-- @param #String item1
-- @param #String item2
-- @param #String item3
--
-- @return #Event
--
function Event.setNext(name, action, item1, item2, item3)
  Event.name = name
  Event.action = action
  Event.item1 = item1
  Event.item2 = item2
  Event.item3 = item3
  Event.state = Event.STATE_START
  Event.next = true
end
-------------------------------------------------------------------------------
-- Get type event
--
-- @function [parent=#Event] getType
--
-- @return #String
--
function Event.getType()
  return type_event
end

-------------------------------------------------------------------------------
-- Get name event
--
-- @function [parent=#Event] getName
--
-- @return #String
--
function Event.getName()
  return lua_event.name
end

-------------------------------------------------------------------------------
-- Get element event
--
-- @function [parent=#Event] getElement
--
-- @return #lua_element
--
function Event.getElement()
  return lua_event.element
end

-------------------------------------------------------------------------------
-- Get element event
--
-- @function [parent=#Event] getElement
--
-- @return #lua_element
--
function Event.getElementName()
  if(lua_event == nil or lua_event.element == nil) then return "" end
  return lua_event.element.name
end

-------------------------------------------------------------------------------
-- Is valid element
--
-- @function [parent=#Event] isElementValid
--
-- @return #boolean
--
function Event.isElementValid()
  return (lua_event ~= nil and lua_event.element ~= nil and lua_event.element.valid)
end

-------------------------------------------------------------------------------
-- Is button event
--
-- @function [parent=#Event] isButton
--
-- @return #boolean
--
function Event.isButton()
  Logging:debug(Event.classname, "isButton()", type_event, Event.isElementValid())
  return (lua_event ~= nil and (type_event == nil or type_event == "dropdown" or type_event == "checked") and Event.isElementValid())
end

-------------------------------------------------------------------------------
-- Is settings event
--
-- @function [parent=#Event] isSettings
--
-- @return #boolean
--
function Event.isSettings()
  return (lua_event ~= nil and lua_event.element == nil and type_event == "settings")
end

-------------------------------------------------------------------------------
-- Is hotkey event
--
-- @function [parent=#Event] isSettings
--
-- @return #boolean
--
function Event.isHotkey()
  return (lua_event ~= nil and lua_event.element == nil and type_event == "hotkey")
end

return Event
