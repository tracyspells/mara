export type Item<T> = {
	id: number,
	value: T,
}

export type VaultObject<T> = {
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
        end

        return contents[index]
    end

	function vault:push(item: Item<T>)
		if #contents > maxSize then
			table.remove(contents, 1)
		end

		table.insert(contents, item)
	end

	return vault :: any
end

return createVault
