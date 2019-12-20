local errorTools = {}

function errorTools.getAllowedTypesText(...)
	local numberOfArguments = select('#', ...)
	if numberOfArguments >= 3 then
		local text = ''
		for i = 1, numberOfArguments - 1 do
			text = text .. string.format('%s, ', select(i, ...))
		end
		text = text .. string.format('or %s', select(numberOfArguments, ...))
		return text
	elseif numberOfArguments == 2 then
		return string.format('%s or %s', select(1, ...), select(2, ...))
	end
	return select(1, ...)
end

function errorTools.getBadArgumentErrorText(argumentIndex, functionName, argumentType, ...)
	return string.format("bad argument #%i to '%s' (expected %s, got %s)",
		argumentIndex, functionName, errorTools.getAllowedTypesText(...), argumentType)
end

local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

function ErrorHandler:push(functionName)
	table.insert(self._functionStack, functionName)
end

function ErrorHandler:pop()
	table.remove(self._functionStack, #self._functionStack)
end

function ErrorHandler:error(message)
	error(message, #self._functionStack + 1)
end

function ErrorHandler:assert(condition, message)
	if not condition then self:error(message) end
end

-- argumentIndex - the number of the argument
-- argument - the argument that was passed in
-- ... - valid argument types
function ErrorHandler:checkArgument(argumentIndex, argument, ...)
	local argumentType = type(argument)
	for i = 1, select('#', ...) do
		if argumentType == select(i, ...) then
			return
		end
	end
	local functionName = self._functionStack[#self._functionStack]
	self:error(errorTools.getBadArgumentErrorText(argumentIndex, functionName, argumentType, ...))
end

--[[
	checks a series of arguments
	- argumentSet - a definition of what arguments are valid (list of list of strings)
	- ... - the arguments that were passed in

	example usage:
	errorHandler:checkArguments({
		{'number'}
		{'number', 'string'},
		{'string'},
		{'number', 'table', 'string'}
	}, 1, 2, 'asdf', {})
]]
function ErrorHandler:checkArguments(argumentSet, ...)
	for i = 1, select('#', ...) do
		local argument = select(i, ...)
		local validTypes = argumentSet[i]
		self:checkArgument(i, argument, unpack(validTypes))
	end
end

function errorTools.newHandler()
	return setmetatable({
		_functionStack = {},
	}, ErrorHandler)
end

return errorTools
