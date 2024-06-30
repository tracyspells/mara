local RunService = game:GetService("RunService")

local types = require(script.Parent.types)
local isStrictTable = require(script.Parent.utils.isStrictTable)

local IS_STUDIO = RunService:IsStudio()

local PRIMITIVES = { "string", "boolean", "number" }
local WARNINGS = {
	Primitive = [[
	Mara has detected that the selector passed in `watchFor`
	returns either a table or `None`.

	Please ensure the selector returns a primitive value
	(e.g. strings, booleans, numbers)
]],

	TestingSelector = [[
	Mara detected a selector function that returns conflicting values for the same input!
	This is likely caused by one of the following:

	- The selector function is not memoized and should use 'createSelector'
	- The selector function is memoized but is not idempotent

	%s
]],
}

type Document<Contents> = types.Document<Contents>
type Connection = types.Connection

type Selector<Input, Output> = types.Selector<Input, Output>
type PrimitiveSelector<Input, Output> = types.PrimitiveSelector<Input, Output>
type Predicate<A, B> = types.Predicate<A, B>
type Listener<T> = types.Listener<T>

local function isPrimitive(value: any): boolean
	if value ~= nil and isStrictTable(value) == false and table.find(PRIMITIVES, typeof(value)) ~= nil then
		return true
	end

	return false
end

local function testSelector<Input, Output>(selector: Selector<Input, Output>, expectedValue: Output, ...: any): boolean
	if selector(...) == expectedValue then
		return true
	end

	if IS_STUDIO then
		local traceback = debug.traceback("Function traceback", 2)
		warn(string.format(WARNINGS.TestingSelector, traceback))
	end

	return false
end

local function watchRaw<Contents>(document: Document<Contents>, ...: any): Connection
	local arguments = select("#", ...)

	local predicate: Predicate<Contents, Contents>
	local listener: Listener<Contents>

	if arguments >= 2 then
		predicate, listener = ...
	else
		listener = ...
	end

	local contents = document:read()

	listener(contents, contents)

	return document:changed(function(newContents, oldContents)
		if newContents == oldContents then
			return
		end

		if predicate and predicate(newContents, oldContents) == false then
			return
		end

		listener(newContents, oldContents)
	end)
end

local function watch<Contents, Selection>(document: Document<Contents>, ...: any): Connection
	if document.contentsType ~= "table" then
		return watchRaw(document, ...)
	end

	local arguments = select("#", ...)

	local selector: Selector<Contents, Selection>
	local predicate: Predicate<Contents | Selection, Contents | Selection>
	local listener: Listener<Contents | Selection>

	if arguments >= 3 then
		selector, predicate, listener = ...
	elseif arguments == 2 then
		selector, listener = ...
	else
		listener = ...
	end

	local selection = document:read(selector)

	if selector then
		testSelector(selector, selection, document:read())
	end

	listener(selection, selection)

	return document:changed(function(newContents, oldContents)
		local newSelection = if selector then selector(newContents) else newContents
		local oldSelection = if selector then selector(oldContents) else oldContents

		if newSelection == oldSelection then
			return
		end

		if predicate and predicate(newSelection, oldSelection) == false then
			return
		end

		listener(newSelection, oldSelection)
	end)
end

local function watchFor<Contents, KeyWord>(
	document: Document<Contents>,
	keyword: PrimitiveSelector<Contents, KeyWord>,
	listener: Listener<KeyWord>
): Connection
	if document.contentsType ~= "table" then
		error("`Mara.watchFor()` is only for tables, please use `Mara.watch()` for non-table document contents!")
	end

	if not isPrimitive(document:read(keyword)) then
		error(WARNINGS.Primitive)
	end

	return watch(document, keyword, listener)
end

return {
	watch = watch,
	watchFor = watchFor,
}
