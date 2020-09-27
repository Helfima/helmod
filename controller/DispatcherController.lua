require "core.Object"

-------------------------------------------------------------------------------
-- Class DispatcherController
--
-- @module DispatcherController
--
DispatcherController = newclass(Object,function(base,classname)
  Object.init(base,classname)
  base.handlers = {}
end)

-------------------------------------------------------------------------------
-- Bind
--
-- @function [parent=#DispatcherController] bind
--
function DispatcherController:bind(event_type, class, class_handler)
  if self.handlers[event_type] == nil then self.handlers[event_type] = {} end
  if self.handlers[event_type][class.classname] == nil then
    self.handlers[event_type][class.classname] = {class=class, handlers={}}
  end
  table.insert(self.handlers[event_type][class.classname].handlers, class_handler)
end

-------------------------------------------------------------------------------
-- Unbind
--
-- @function [parent=#DispatcherController] unbind
--
function DispatcherController:unbind(event_type, class, class_handler)
  if class == nil and class_handler == nil then
    self.handlers[event_type] = nil
  elseif class_handler == nil and self.handlers[event_type] then
    self.handlers[event_type][class.classname] = nil
  elseif self.handlers[event_type] and self.handlers[event_type][class.classname] then
    local remove_index = nil
    for index,handler in pairs(self.handlers[event_type][class.classname].handlers) do
      if class_handler == handler then remove_index = index end
    end
    if remove_index ~= nil then
      table.remove(self.handlers[event_type][class.classname].handlers,remove_index)
    end
  end
end

-------------------------------------------------------------------------------
-- Send
--
-- @function [parent=#DispatcherController] send
--
function DispatcherController:send(event_type, data, classname)
  local ok , err = pcall(function()
    data.type = event_type
    if self.handlers[event_type] then
      for name, group in pairs(self.handlers[event_type]) do
        local valid = true
        if classname ~= nil and classname ~= name then
          valid = false
        end
        if valid then
          for _,handler in pairs(group.handlers) do
            handler(group.class, data)
          end
        end
      end
    end
  end)
  if not(ok) then
    Player.print(err)
    log(err)
  end
end
