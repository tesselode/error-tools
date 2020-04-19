local test = require 'error-tools'

local t = {}
setmetatable(t, {
	__call = function() end,
})

local function heck()
	test.doThing(t)
end

heck()
