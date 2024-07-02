local RunService = game:GetService("RunService")

local Watchdog = require(script.Parent.Watchdog)
local types = require(script.Parent.types)

local utils = script.Parent.utils
local isStrictTable = require(utils.isStrictTable)
local shallowCopyPath = require(utils.shallowCopyPath)
local generateStringFromPath = require(utils.generateStringFromPath)

local copy = table.clone

local IS_TESTING = RunService:IsStudio() and RunService:IsRunning()

local WARNINGS = {
	Timeline = [[
		`Document%s` cannot be used without calling `Mara.trackDocumentHistory()` first!
		%s
	]],
}

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
type Editor<Contents> = types.Editor<Contents>
type Connection = types.Connection

local function areContentsInvalid<Contents>(contents: Contents): (boolean, string?)
	if contents == nil then
		return true, ERROR_MESSAGES.NonNil
	end

	if typeof(contents) == "Instance" then
		return true, ERROR_MESSAGES.Instances
	end

	if typeof(contents) == "table" and getmetatable(contents) ~= nil then
		return true, ERROR_MESSAGES.Metatables
	end

	return false
end

local function createDocument<Contents>(initialContents: Contents): Document<Contents>
	local isInvalid, message = areContentsInvalid(initialContents)

	if isInvalid then
		error(message)
	end

	local contents = initialContents
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
		if self["_timeline"] then
			self._timeline:wipe()
		end

		watchdog:sleep()
	end

	function document:read(selector)
		if contentsType == "table" then
			return if selector then selector(contents) else contents
		else
			return contents
		end
	end

	function document:setContents(newContents)
		local success, result = areContentsInvalid(newContents)

		if success then
			error(result)
		end

		if typeof(newContents) ~= contentsType then
			error(string.format(ERROR_MESSAGES.DifferentTypes, typeof(newContents), contentsType))
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

				warn(string.format(WARNINGS.Timeline, ":undo()", traceback))
			end

			return
		end

		self._timeline:undo()
	end

	function document:redo()
		if not self["_timeline"] then
			if IS_TESTING then
				local traceback = debug.traceback("Function traceback", 2)

				warn(string.format(WARNINGS.Timeline, ":redo()", traceback))
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
					newContents = makeChanges(oldContents)

					if areContentsInvalid(newContents) then
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

	function document:edit(...)
		local arguments = select("#", ...)
		local path: { string | number }
		local makeChanges: (Contents) -> any

		if arguments >= 2 then
			makeChanges, path = ...
		else
			makeChanges = ...
		end

		local oldContents = contents :: any
		local newContents: any

		if contentsType == "table" then
			if path then
				local result, tableToEdit = shallowCopyPath(contents :: any, path)

				if tableToEdit == nil then
					local lastEntry = #path
					local dictionaryPath = generateStringFromPath(path)

					error(`The data you are trying to edit {path[lastEntry]} in {dictionaryPath} doesn't exist!`)
				end

				newContents = result
				makeChanges(tableToEdit :: any)
			else
				newContents = copy(contents :: any)
				makeChanges(newContents)
			end
		else
			newContents = makeChanges(oldContents)
		end

		processContents(newContents, oldContents)
	end

	document.get = document.read
	document.set = document.setContents
	document.reset = document.resetContents
	document.update = document.edit

	return document :: any
end

return createDocument
