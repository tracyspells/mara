local None = require(script.Parent.None)
local types = require(script.Parent.Parent.types)

local copy = table.clone

type AnyDictionary = types.AnyDictionary

local function difference<N, O>(new: N & AnyDictionary, old: O & AnyDictionary): AnyDictionary?
	if not old then
		return copy(new)
	end

	local result = copy(new)

	for key, value in old :: AnyDictionary do
		local other = (new :: AnyDictionary)[key]

		if value == other then
			result[key] = nil
		elseif other == nil then
			result[key] = None
		elseif typeof(value) == "table" and typeof(other) == "table" then
			result[key] = difference(other, value)
		end
	end

	return result
end

return difference
