--!native

local Watchdog = require(script.Parent.Watchdog)
local types = require(script.Parent.types)
local isStrictTable = require(script.Parent.isStrictTable)

local copy = table.clone

type Document<C> = types.Document<C>
type Connection = types.Connection

local function createDocument<C>(initialContents): Document<C>
	assert(
		isStrictTable(initialContents),
		`Documents must be based on tables with no existing metatables. Got {typeof(initialContents)}`
	)

	local document = {}
	local contents = initialContents

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
			Disconnect = function(connection)
				if not connection.Connected then
					return
				end

				connection.Connected = false

				if stopObserving then
					stopObserving()
				end
			end,

			Destroy = function(connection)
				connection:Disconnect()
			end,
		}
	end

	function document:undoAll()
		local oldContents = contents

		contents = initialContents
		watchdog:bark(contents, oldContents)
	end

	
	function document:edit(makeChanges)
		local oldContents = contents
		local newContents = copy(contents)
		makeChanges(newContents)

		if newContents ~= oldContents then
			contents = newContents

			watchdog:bark(newContents, oldContents)
		end
	end

	return document :: any
end

return createDocument
