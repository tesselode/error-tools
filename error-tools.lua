local function getUserErrorLevel()
	local source = debug.getinfo(1).source
	local level = 1
	while debug.getinfo(level).source == source do
		level = level + 1
	end
	return level - 1
end

local function getUserCalledFunctionName()
	return debug.getinfo(getUserErrorLevel() - 1).name
end

local function checkCondition(condition, message)
	if condition then return end
	error(message, getUserErrorLevel())
end

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

local function checkArgument(argumentIndex, argument, ...)
	for i = 1, select('#', ...) do
		if type(argument) == select(i, ...) then
			return
		end
	end
	error(
		string.format(
			"bad argument #%i to '%s' (expected %s, got %s)",
			argumentIndex,
			getUserCalledFunctionName(),
			getAllowedTypesText(...),
			type(argument)
		),
		getUserErrorLevel()
	)
end

local function checkArguments(argumentSet, ...)
	for i = 1, select('#', ...) do
		checkArgument(i, select(i, ...), unpack(argumentSet[i]))
	end
end

-- the following is test code
local testArgumentSet = {
	{'number'},
	{'string'},
	{'table'},
	{'number', 'string'},
}

local test = {}

function test.doOtherOtherThing(a, b, c, d)
	checkArguments(testArgumentSet, a, b, c, d)
	checkCondition(a < 10, 'a must be less than 10')
end

function test.doOtherThing(...)
	test.doOtherOtherThing(...)
end

function test.doThing(...)
	test.doOtherThing(...)
end

return test
