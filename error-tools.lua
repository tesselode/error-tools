local function getAllowedTypesText(...)
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

local function getBadArgumentErrorText(argumentIndex, functionName, argumentType, ...)
	return string.format("bad argument #%i to '%s' (expected %s, got %s)",
		argumentIndex, functionName, getAllowedTypesText(...), argumentType)
end

local function getUserCalledFunctionName()
	local source = debug.getinfo(1).source
	local level = 1
	while debug.getinfo(level).source == source do
		level = level + 1
	end
	return debug.getinfo(level - 1).name
end

local test = {}

function test.doOtherOtherThing()
	print(getUserCalledFunctionName())
end

function test.doOtherThing()
	test.doOtherOtherThing()
end

function test.doThing()
	test.doOtherThing()
end

return test
