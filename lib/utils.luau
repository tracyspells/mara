local None = require(script.Parent.None)

local function extend<T>(a: any, b: any): T
	local tbl = table.clone(a)

	for key, value in b do
		if typeof(value) == "table" then
			local otherValue = a[key]

			if typeof(otherValue) == "table" then
				tbl[key] = extend(otherValue, value)
			else
				tbl[key] = table.clone(value)
			end
		elseif value == None then
			tbl[key] = nil
		else
			tbl[key] = value
		end
	end

	return tbl :: any
end

-- https://github.com/cxmeel/sift/blob/main/src/Dictionary/freezeDeep.lua
local function freezeDeep<T>(tbl: { [string]: any }): T
	local result = {}

	for key, value in tbl do
		if typeof(value) == "table" then
			if table.isfrozen(value) then
				continue
			end

			result[key] = freezeDeep(value)
		else
			result[key] = value
		end
	end

	table.freeze(result)

	return result :: any
end

-- https://github.com/cxmeel/sift/blob/main/src/Dictionary/copyDeep.lua
local function copyDeep<T>(dictionary: T): T
	local new = table.clone(dictionary :: any)

	for key, value in (dictionary :: any) do
		if type(value) == "table" then
			new[key] = copyDeep(value)
		end
	end

	return new :: any
end

return table.freeze({
	extend = extend,
	copyDeep = copyDeep,
	freezeDeep = freezeDeep,
})
