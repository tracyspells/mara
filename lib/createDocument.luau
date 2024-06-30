local RunService = game:GetService("RunService")

local Watchdog = require(script.Parent.Watchdog)
local types = require(script.Parent.types)
local isStrictTable = require(script.Parent.utils.isStrictTable)

local copy = table.clone

local IS_STUDIO = RunService:IsStudio()
local IS_TESTING = IS_STUDIO and RunService:IsRunning()

local TIMELINE_WARNING = [[
	Document`%s` cannot be used without calling `Mara.trackDocumentHistory()` first!
	%s
]]

local ERROR_MESSAGES = {
	NonNil = "The contents of a document must be a non-nil value.",
	Instances = "The contents of a document cannot be an Instance.",
	Metatables = "The contents of a document cannot be a metatable.",
	DifferentTypes = [[
		The result from the 'makeChanges' callback must have the same type as what was set for 'initialContents'!
		(got %s when it's supposed to be %s)
	]],
}

type Document<Contents> = types.Document<Contents>
type Connection = types.Connection

local function createDocument<Contents>(initialContents): Document<Contents>
	assert(initialContents ~= nil, ERROR_MESSAGES.NonNil)
	assert(typeof(initialContents) ~= "Instance", ERROR_MESSAGES.Instances)

	if typeof(initialContents) == "table" and getmetatable(initialContents) ~= nil then
		error(ERROR_MESSAGES.Metatables)
	end

	local contents = initialContents :: any
	local contentsType = typeof(initialContents)

	local watchdog = Watchdog.new()

	local function processContents(newContents: Contents, oldContents: Contents)
		if newContents ~= oldContents then
			if contentsType ~= "table" then
				if newContents == nil then
					error("The result from the 'makeChanges' callback cannot be nil!")
				elseif typeof(newContents) ~= contentsType then
					error(string.format(ERROR_MESSAGES.DifferentTypes, typeof(newContents), contentsType))
				end
			else
				if getmetatable(newContents :: any) ~= nil then
					error("The result from the 'makeChanges' callback cannot be a metatable!")
				end
			end

			contents = newContents
			watchdog:bark(contents, oldContents)
		end
	end

	local document = { contentsType = contentsType }
	function document:shred()
		watchdog:sleep()

		if self["_timeline"] then
			self._timeline:wipe()
		end
	end

	function document:read(selector)
		if contentsType == "table" then
			return if selector then selector(contents) else contents
		else
			return contents
		end
	end

	function document:setContents(newContents)
		if newContents == nil then
			error(ERROR_MESSAGES.NonNil)
		end

		if typeof(newContents) ~= contentsType then
			error(string.format(ERROR_MESSAGES.DifferentTypes, typeof(newContents), contentsType))
		end

		if typeof(newContents) == "table" and getmetatable(newContents :: any) ~= nil then
			error(ERROR_MESSAGES.Metatables)
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
		local newContents: any

		for index = 1, #edits do
			local makeChanges = edits[index]

			if typeof(makeChanges) ~= "function" then
				continue
			end

			if contentsType == "table" then
				if not newContents then
					newContents = copy(contents :: any)
				end

				makeChanges(newContents)
			else
				if not newContents then
					local areContentsInvalid = false

					newContents = makeChanges(oldContents)

					if newContents == nil then
						areContentsInvalid = true
					elseif typeof(newContents) == "Instance" then
						areContentsInvalid = true
					elseif typeof(newContents) == "table" and getmetatable(newContents) ~= nil then
						areContentsInvalid = true
					end

					if areContentsInvalid then
						newContents = oldContents

						break
					end
				else
					newContents = makeChanges(newContents)
				end
			end
		end

		processContents(newContents, oldContents)
	end

	function document:edit(makeChanges)
		local oldContents = contents
		local newContents: any

		if contentsType == "table" then
			newContents = copy(contents :: any)
			makeChanges(newContents)
		else
			newContents = makeChanges(oldContents)
		end

		processContents(newContents, oldContents)
	end

	return document :: any
end

return createDocument
