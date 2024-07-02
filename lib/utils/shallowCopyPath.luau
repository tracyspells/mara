local types = require(script.Parent.Parent.types)

type Dictionary<Key, Value> = types.Dictionary<Key, Value>

local copy = table.clone

--[[
	recurses through `collection`, shallow-copying each entry until it 
	reaches the last entry in `path`.

	- if any entry in the path isn't a table, but is inside a table, this
	function returns said table
	- if any entry in the path does not exist, this function will return nil
	
	otherwise, return the entry (which should be a table).
]]
local function getLastEntryInPath<Key, Value>(collection: Dictionary<Key, Value>, path: { Key }, index: number): any
	local key = path[index]
	local isValueANonTable = false

	if typeof(collection[key]) == "table" then
		local clone = copy(collection[key] :: any)
		collection[key] = clone :: Value & {}
	else
		isValueANonTable = true
	end

	if index == #path then
		local isTable = typeof(collection[key]) == "table"

		if not isTable and collection[key] ~= nil then
			return collection
		end

		return collection[key]
	else
		if isValueANonTable then
			return collection
		end
	end

	return getLastEntryInPath(collection[key] :: any, path, index + 1)
end

local function shallowCopyPath<Key, Value>(dictionary: Dictionary<Key, Value>, path: { Key })
	local base = copy(dictionary)
	local index = 1
	local entry = getLastEntryInPath(base, path, index)

	return base, entry
end

return shallowCopyPath
