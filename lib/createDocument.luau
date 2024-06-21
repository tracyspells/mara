--!native

local Watchdog = require(script.Parent.Watchdog)
local None = require(script.Parent.None)
local types = require(script.Parent.types)
local isStrictTable = require(script.Parent.utils.isStrictTable)
local createVault = require(script.Parent.createVault)

local copy = table.clone

type Document<C> = types.Document<C>
type Connection = types.Connection

type VaultObject<T> = createVault.VaultObject<T>
type VaultItem<T> = createVault.Item<T>

local function createDocument<C>(initialContents): Document<C>
	assert(
		isStrictTable(initialContents),
		`Documents must be based on tables with no existing metatables. Got {typeof(initialContents)}`
	)

	local document = {}
	local contents = initialContents

	local edits = 0

	local history = createVault(60) :: VaultObject<C>
	local temporaryHistory: { VaultItem<C> }

	local watchdog = Watchdog.new()

	history:push({ id = edits, value = contents })

	function document:shred()
		watchdog:sleep()
		history:clear()

		if temporaryHistory then
			temporaryHistory = nil :: never
		end
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

	function document:undo()
		if edits <= 0 then
			return
		end

		local previousEdit = math.clamp(edits - 1, 0, history:getSize())
		local item = history:getItem(previousEdit)

		local oldContents = contents

		if item then
			contents = item.value
			edits = previousEdit

			watchdog:bark(contents, oldContents)
		end
	end

	function document:redo()
		local nextEdit = edits + 1

		if nextEdit >= history:getSize() then
			return
		end

		local item = history:getItem(nextEdit)

		local oldContents = contents

		if item then
			contents = item.value
			edits = nextEdit

			watchdog:bark(contents, oldContents)
		end
	end

	function document:redoAll()
		if edits > 0 then
			return
		end

		if not temporaryHistory then
			return
		end

		local oldContents = contents
		local latestItem = temporaryHistory[#temporaryHistory]
		local newContents = latestItem.value

		edits = latestItem.id
		history:push({ id = edits, value = newContents })

		temporaryHistory = nil :: never

		contents = newContents
		watchdog:bark(contents, oldContents)
	end

	function document:undoAll()
		if edits <= 0 then
			return
		end

		local oldContents = contents

		if temporaryHistory then
			temporaryHistory = nil :: never
		end

		temporaryHistory = copy(history:getContents())

		edits = 0
		history:clear()

		contents = initialContents
		watchdog:bark(contents, oldContents)
	end

	function document:edit(makeChanges)
		local oldContents = contents
		local newContents = copy(contents)

		local changes = makeChanges(newContents)
		if changes == None then
			newContents = oldContents
		end

		if newContents ~= oldContents then
			contents = newContents

			edits += 1
			history:push({ id = edits, value = contents })

			watchdog:bark(newContents, oldContents)
		end
	end

	return document :: any
end

return createDocument
