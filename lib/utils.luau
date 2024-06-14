local None = require(script.Parent.None)

local function merge<T>(a: any, b: any): T?
	if typeof(a) ~= "table" then
		return nil
	end

	if typeof(b) ~= "table" then
		return nil
	end

	local result = {}

	for key, value in a do
		result[key] = if value == None then nil else value
	end

	for key, value in b do
		result[key] = if value == None then nil else value
	end

	return result :: any
end

local function freezeDeep<T>(tbl: { [string]: any }): T
	local result = {}

	for key, value in tbl do
		if typeof(value) == "table" then
			if table.isfrozen(value) then
				continue
			else
				result[key] = freezeDeep(value)
			end
		else
			result[key] = value
		end
	end

	table.freeze(result)

	return result :: any
end

return table.freeze({
	merge = merge,
	freezeDeep = freezeDeep,
})
