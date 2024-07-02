local types = require(script.Parent.types)

type Document<C> = types.Document<C>
type Connection = types.Connection

type Item<T> = {
	id: number,
	value: T,
}

type VaultObject<T> = {
	getSize: (self: VaultObject<T>) -> number,
	getContents: (self: VaultObject<T>) -> { Item<T> },
	clear: (self: VaultObject<T>) -> (),
	getItem: (self: VaultObject<T>, itemId: number) -> Item<T>?,
	push: (self: VaultObject<T>, item: Item<T>) -> (),
}

-- https://github.com/cxmeel/sift/blob/main/src/Array/findWhere.lua
local function findWhere<T>(
	array: { T },
	predicate: (value: T, index: number, array: { T }) -> any,
	from: number?
): number?
	local length = #array

	if from and typeof(from) == "number" then
		if from < 1 then
			from = length + from
		end
	else
		from = 1
	end

	local start = from :: number

	for index = start, #array do
		if predicate(array[index], index, array) then
			return index
		end
	end

	return
end

local function createVault<T>(size: number): VaultObject<T>
	local maxSize = size
	local contents: { Item<T> } = {}

	local vault = {}

	function vault:getSize()
		return #contents
	end

	function vault:clear()
		table.clear(contents)
	end

	function vault:getContents()
		return contents
	end

	function vault:getItem(itemId: number)
		local index = findWhere(contents, function(item)
			return item.id == itemId
		end)

		if not index then
			return
		else
			return contents[index]
		end
	end

	function vault:push(item: Item<T>)
		if #contents > maxSize then
			table.remove(contents, 1)
		end

		table.insert(contents, item)
	end

	return vault :: any
end

local function trackDocumentHistory<Contents>(document: Document<Contents>): Document<Contents>
	local version = 0
	local vault = createVault(60) :: VaultObject<Contents>

	local isUndoing = false
	local isRedoing = false

	local connection: Connection
	connection = document:changed(function(contents)
		if isUndoing or isRedoing then
			return
		end

		version += 1
		vault:push({ id = version, value = contents })
	end)

	-- store in our initial contents
	vault:push({ id = version, value = document:read() })

	local timeline = {}
	function timeline:wipe()
		connection:Disconnect()
		vault:clear()
	end

	function timeline:undo()
		if version <= 0 then
			return
		end

		local previousEdit = math.clamp(version - 1, 0, vault:getSize())
		local item = vault:getItem(previousEdit)

		if item then
			isUndoing = true

			version = previousEdit
			document:setContents(item.value)

			isUndoing = false
		end
	end

	function timeline:redo()
		local nextEdit = version + 1

		if nextEdit > vault:getSize() then
			return
		end

		local item = vault:getItem(nextEdit)

		if item then
			isRedoing = true

			version = nextEdit
			document:setContents(item.value)

			isRedoing = false
		end
	end

	document["_timeline"] = timeline

	return document
end

return trackDocumentHistory
