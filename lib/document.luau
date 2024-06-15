local Watchdog = require(script.Parent.Watchdog)
local types = require(script.Parent.types)
local utils = require(script.Parent.utils)

type Document<C> = types.Document<C>

local function validateContents(value: any): boolean
	if typeof(value) == "table" and getmetatable(value) == nil then
		return true
	end

	return false
end

local function createDocument<C>(initialContents: C): Document<C>
	assert(
		validateContents(initialContents),
		`Documents must be based on tables with no existing metatables. Got {typeof(initialContents)}`
	)

	local document = {}

	local contents = utils.freezeDeep(initialContents :: any)
	local watchdog = Watchdog.new() 

	function document:shred()
		watchdog:sleep()
	end

	function document:read(selector)
		return if selector then selector(contents) else contents
	end

	function document:changed(callback)
		local stopObserving = watchdog:observe(callback)

		return {
			Connected = true,
			Disconnect = function(self)
				self.Connected = false
				stopObserving()
			end
		}
	end

	function document:once(callback)
		local stopObserving = watchdog:observeOnce(callback)

		return {
			Connected = true,
			Disconnect = function(self)
				self.Connected = false
				stopObserving()
			end
		}
	end

	function document:edit(makeChanges)
		local oldContents = contents
		local newContents = utils.extend(initialContents, contents) :: any
		makeChanges(newContents)

		if newContents ~= oldContents then
			contents = utils.freezeDeep(newContents)

			watchdog:bark(contents, oldContents)
		end
	end

	return document :: any
end

return createDocument
