local test = require 'error-tools'

local function heck()
	test.doThing(11, 'asdf', {}, 3)
end

heck()
