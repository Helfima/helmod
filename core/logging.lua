Logging = {}

local append_log=false

function Logging:new()
	self.limit = 5
	self.filename="helmod\\helmod.log"
	self.logClass = {}
	
	self.debug_values = {none=0,error=1,warn=2,info=3,debug=4,trace=5}
end

function Logging:checkClass(logClass)
  if self:getFilter() == "all" or self:getFilter() == logClass then return true end
  return false
end

function Logging:getFilter()
  local filter = "all"
  if settings ~= nil  then
    filter = settings.global["helmod_debug_filter"].value
  end
  return filter
end

function Logging:getLevel()
  local level = "none"
  if settings ~= nil  then
    level = settings.global["helmod_debug"].value
  end
  return level
end

function Logging:trace(...)
  local arg = {...}
  self:logging("[TRACE]", self.debug_values.trace, unpack(arg))
end

function Logging:debug(...)
	local arg = {...}
	self:logging("[DEBUG]", self.debug_values.debug, unpack(arg))
end

function Logging:info(...)
  local arg = {...}
  self:logging("[INFO]", self.debug_values.info, unpack(arg))
end

function Logging:warn(...)
  local arg = {...}
  self:logging("[WARN ]", self.debug_values.warn, unpack(arg))
end

function Logging:error(...)
	local arg = {...}
	self:logging("[ERROR]", self.debug_values.error, unpack(arg))
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
      message = message..string.format("{\"type\":%q,\"name\":%q}", "nil", object.name or "nil")
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
  local debug_level = self.debug_values[self:getLevel()] or 0
  local arg = {...}
	if arg == nil then arg = "nil" end
	if self:checkClass(logClass) and level <= debug_level then
		local message = "";
		for key, object in pairs(arg) do
			message = message..self:objectToString(object)
		end
		local debug_info = debug.getinfo(3)
		log(string.format("%s|%s|%s:%s|%s", tag, logClass, string.match(debug_info.source,"[^/]*$"), debug_info.currentline, message))
		if append_log == false then append_log = true end
	end
end
