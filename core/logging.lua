Logging = {}

function Logging:new(log)
	self.name = "helmod.log"
	self.log = log
	self.content = "Helfima Mod logging\n"
	self.console = false
	self.force = false
	self.limit = 5
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

function Logging:logging(tag, level, ...)
	local arg = {...}
	if arg == nil then arg = "nil" end
	if level <= self.log then
		local message = "";
		for key, object in pairs(arg) do
			message = message..self:objectToString(object);
		end
		if self.console then
			game.players[1].print(tag..message)
		end
		log(tag..message)
	end
end
