local RunService = game:GetService("RunService")

local Watchdog = require(script.Parent.Watchdog)
local types = require(script.Parent.types)
local isStrictTable = require(script.Parent.utils.isStrictTable)

local copy = table.clone

local IS_STUDIO = RunService:IsStudio()
local IS_TESTING = IS_STUDIO and RunService:IsRunning()

local TIMELINE_WARNING = [[
	The method `%s` cannot be used without calling `trackDocumentHistory` first!
	%s
]]

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

		if self["_timeline"] then
			self._timeline:wipe()
		end
	end

	function document:read(selector)
		return if selector then selector(contents) else contents
	end

	function document:setContents(newContents)
		if not newContents then
			return
		end

		if not isStrictTable(newContents) then
			error(`Documents must be based on tables with no existing metatables. Got {typeof(initialContents)}`)
		end

		local oldContents = contents
		contents = newContents

		watchdog:bark(contents, oldContents)
	end

	function document:resetContents()
		self:setContents(initialContents)
	end

	function document:undo()
		if not self["_timeline"] then
			if IS_TESTING then
				local traceback = debug.traceback("Function traceback", 2)

				warn(string.format(TIMELINE_WARNING, ":undo()", traceback))
			end

			return
		end

		self._timeline:undo()
	end

	function document:redo()
		if not self["_timeline"] then
			if IS_TESTING then
				local traceback = debug.traceback("Function traceback", 2)

				warn(string.format(TIMELINE_WARNING, ":redo()", traceback))
			end

			return
		end

		self._timeline:redo()
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

	function document:batchEdits(edits)
		if not isStrictTable(edits) then
			error(`The 'edits' argument in ':batchEdits()' must be an array, got {typeof(edits)}`)
		end

		if #edits <= 1 then
			return
		end

		local oldContents = contents
		local newContents = copy(contents)

		for index = 1, #edits do
			local makeChanges = edits[index]

			if typeof(makeChanges) ~= "function" then
				continue
			end

			makeChanges(newContents)
		end

		if newContents ~= oldContents then
			contents = newContents
			watchdog:bark(contents, oldContents)
		end
	end

	function document:edit(makeChanges)
		local oldContents = contents
		local newContents = copy(contents)

		makeChanges(newContents)

		if newContents ~= oldContents then
			contents = newContents
			watchdog:bark(contents, oldContents)
		end
	end

	return document :: any
end

return createDocument
