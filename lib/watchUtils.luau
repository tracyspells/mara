local RunService = game:GetService("RunService")

local types = require(script.Parent.types)
local isStrictTable = require(script.Parent.isStrictTable)

local IS_STUDIO = RunService:IsStudio()

local PRIMITIVES = { "string", "boolean", "number" }
local PRIMITIVE_WARNING = [[
	Mara has detected that the selector passed in `watchFor`
	returns either a table or `None`.

	Please ensure the selector returns a primitive value
	(e.g. strings, booleans, numbers)
]]

local TEST_WARNING = [[
	Mara detected a selector function that returns conflicting values for the same input!
	This is likely caused by one of the following:

	- The selector function is not memoized and should use 'createSelector'
	- The selector function is memoized but is not idempotent

	%s
]]

type Document<C> = types.Document<C>
type Connection = types.Connection

type Selector<T> = types.Selector<T>
type Predicate<C> = types.Predicate<C>
type Listener<C> = types.Listener<C>

local function isPrimitive(value: any): boolean
	if value ~= nil and isStrictTable(value) == false and table.find(PRIMITIVES, typeof(value)) ~= nil then
		return true
	end

	return false
end

local function getWatchFuncArguments<C>(...: any): (Selector<C>?, Predicate<C>?, Listener<C>)
	local arguments = select("#", ...)
	local selector: Selector<C>, predicate: Predicate<C>, listener: Listener<C>

	if arguments >= 3 then
		selector, predicate, listener = ...
	elseif arguments == 2 then
		selector, listener = ...
	else
		listener = ...
	end

	return selector, predicate, listener
end

local function testSelector<T>(selector: Selector<T>, expectedValue: T, ...: any)
	if selector(...) == expectedValue then
		return true
	end

	if IS_STUDIO then
		local traceback = debug.traceback("Function traceback", 2)
		warn(string.format(TEST_WARNING, traceback))
	end

	return false
end

local function watch<C>(document: Document<C>, ...: any): Connection
	local selector, predicate, listener = getWatchFuncArguments(...)

	local selection = document:read(selector)

	if selector then
		testSelector(selector, selection, document:read())
	end

	listener(selection, nil :: never)

	return document:changed(function(newContents, oldContents)
		local newSelection = if selector then selector(newContents) else newContents
		local oldSelection = if selector then selector(oldContents) else oldContents

		if predicate and not predicate(newSelection, oldSelection) then
			return
		end

		listener(newSelection, oldSelection)
	end)
end

local function watchFor<C>(document: Document<C>, keyWord: string, listener: Listener<C>): Connection
	local selector: Selector<C> = function(contents: any)
		return contents[keyWord]
	end

	if not isPrimitive(document:read(selector)) then
		error(PRIMITIVE_WARNING, 2)
	end

	return watch(document, selector, listener)
end

return {
	watch = watch,
	watchFor = watchFor,
}
