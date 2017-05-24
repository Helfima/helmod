Logging = {}

local append_log=false

function Logging:new(log)
	self.limit = 5
	self.filename="helmod\\helmod.log"
	self.logClass = {}
	
	self.debug_values = {none=0,info=1,error=2,debug=3,trace=4}
end

function Logging:checkClass(logClass)
  local name = settings.global["helmod_debug_filter"].value
  if name == "all" or name == logClass then return true end
  return false
end

function Logging:trace(...)
  local arg = {...}
  self:logging("[TRACE]", 4, unpack(arg))
end

function Logging:debug(...)
	local arg = {...}
	self:logging("[DEBUG]", 3, unpack(arg))
end

function Logging:info(...)
	local arg = {...}
	self:logging("[INFO]", 2, unpack(arg))
end

function Logging:error(...)
	local arg = {...}
	self:logging("[ERROR]", 1, unpack(arg))
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
		message = message.." "..object end
	if type(object) == "string" then
		message = message.."\""..object.."\"" end
	if type(object) == "function" then
		message = message.."\"__function\"" end
	if type(object) == "table" then
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
	return message
end

function Logging:logging(tag, level, logClass, ...)
  local debug_level = self.debug_values[settings.global["helmod_debug"].value] or 0
  local arg = {...}
	if arg == nil then arg = "nil" end
	if self:checkClass(logClass) and level <= debug_level then
		local message = "";
		for key, object in pairs(arg) do
			message = message..self:objectToString(object)
		end
		--game.write_file(self.filename, tag.."|"..logClass.."|"..message.."\n", append_log)
    log(tag.."|"..logClass.."|"..message)
		if append_log == false then append_log = true end
	end
end
