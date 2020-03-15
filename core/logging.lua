Logging = {}

local append_log=false
local debug_level = 0
local debug_filter = "all"
local global_profiler = nil
local profiler = nil

function Logging:new()
  self.limit = 5
  self.filename="helmod\\helmod.log"
  self.logClass = {}
  self.debug_values = {none=0,error=1,warn=2,info=3,debug=4,trace=5}
  self:updateLevel()
  self.profiler = false
end

function Logging:profilerStart()
  if self.profiler == false then return end
  if global_profiler == nil then global_profiler = game.create_profiler() end
  global_profiler.reset()
  log({"", "[PROFILER]", " | ", "GLOBAL", " | ", "*** Profiler begin ***", " | ", global_profiler})
end

function Logging:profilerStep(name, ...)
  if self.profiler == false then return end
  if profiler == nil then profiler = {} end
  if profiler[name] == nil then profiler[name] = game.create_profiler() end
  local message = {...}
  log({"", "[PROFILER]", " | ", name, " | ", table.concat({...}," "), " | ", profiler[name]})
  profiler[name].reset()
end

function Logging:profilerStop()
  if self.profiler == false then return end
  if profiler ~= nil then
    log({"", "[PROFILER]", " | ", "GLOBAL", " | ", "*** Profiler end ***", " | ", global_profiler})
    log({"", "----------------------------------------------------------------------------------"})
    global_profiler.stop()
    global_profiler = nil
    for _,profiler_step in pairs(profiler or {}) do
      profiler_step.stop()
    end
    profiler = nil
  end
end

function Logging:checkClass(logClass)
  if debug_filter == "all" or debug_filter == logClass then return true end
  return false
end

function Logging:updateLevel()
  local level = "none"
  if settings ~= nil and settings.global["helmod_debug"]  then
    level = settings.global["helmod_debug"].value
  end
  debug_level = self.debug_values[level] or 0
  
  if settings ~= nil and settings.global["helmod_debug_filter"] then
    debug_filter = settings.global["helmod_debug_filter"].value
  end
end

function Logging:trace(...)
  if self.debug_values.trace > debug_level then return end
  local arg = {...}
  self:logging("[TRACE]", self.debug_values.trace, unpack(arg))
end

function Logging:debug(...)
  if self.debug_values.debug > debug_level then return end
  local arg = {...}
  self:logging("[DEBUG]", self.debug_values.debug, unpack(arg))
end

function Logging:info(...)
  if self.debug_values.info > debug_level then return end
  local arg = {...}
  self:logging("[INFO]", self.debug_values.info, unpack(arg))
end

function Logging:warn(...)
  if self.debug_values.warn > debug_level then return end
  local arg = {...}
  self:logging("[WARN ]", self.debug_values.warn, unpack(arg))
end

function Logging:error(...)
  if self.debug_values.error > debug_level then return end
  local arg = {...}
  self:logging("[ERROR]", self.debug_values.error, unpack(arg))
end

function Logging:line(...)
  if self.debug_values.debug > debug_level then return end
  local arg = {...}
  self:previousCall("[DEBUG]", unpack(arg))
end

function Logging:objectToString(object, level)
  if level == nil then level = 0 end
  local message = ""
  if type(object) == "nil" then
    message = message.." nil"
  elseif type(object) == "boolean" then
    if object then message = message.." true"
    else message = message.." false" end
  elseif type(object) == "number" then
    message = message.." "..object
  elseif type(object) == "string" then
    message = message.."\""..object.."\""
  elseif type(object) == "function" then
    message = message.."\"__function\""
  elseif object.isluaobject then
    if object.valid then
      local help = nil
      pcall(function() help = object.help() end)
      if help ~= nil and help ~= "" then
        local lua_type = string.match(help, "Help for%s([^:]*)")
        if lua_type == "LuaCustomTable" then
          local custom_table = {}
          for _,element in pairs(object) do
            table.insert(custom_table, element)
          end
          return self:objectToString(custom_table, level)
        elseif string.find(lua_type, "Lua") then
          local object_name = "unknown"
          pcall(function() object_name = object.name end)
          message = message..string.format("{\"type\":%q,\"name\":%q}", lua_type, object_name or "nil")
        else
          message = message..string.format("{\"type\":%q,\"name\":%q}", object.type or "nil", object.name or "nil")
        end
      else
        message = message.."invalid object"
      end
    else
      message = message.."invalid object"
    end
  elseif type(object) == "table" then
    if level <= self.limit then
      local first = true
      message = message.."{"
      for key, nextObject in pairs(object) do
        if not first then message = message.."," end
        message = message.."\""..key.."\""..":"..self:objectToString(nextObject, level + 1);
        first = false
      end
      message = message.."}"
    else
      message = message.."\"".."__table".."\""
    end
  end
  return string.gsub(message,"\n","")
end

function Logging:logging(tag, level, logClass, ...)
  local arg = {...}
  if arg == nil then arg = "nil" end
  if self:checkClass(logClass) then
    local message = "";
    for key, object in pairs(arg) do
      message = message..self:objectToString(object)
    end
    local debug_info = debug.getinfo(3)
    log(string.format("%s|%s|%s:%s|%s", tag, logClass, string.match(debug_info.source,"[^/]*$"), debug_info.currentline, message))
    if append_log == false then append_log = true end
  end
end


function Logging:previousCall(tag, logClass, back)
  local debug_info = debug.getinfo(back+2)
  log(string.format("%s|%s|%s:%s", tag, logClass, string.match(debug_info.source,"[^/]*$"), debug_info.currentline))
end
