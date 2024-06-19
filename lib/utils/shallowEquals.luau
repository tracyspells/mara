local function shallowEquals(a: any, b: any): boolean
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end

	for key, value in pairs(a) do
		if value ~= b[key] then
			return false
		end
	end

	for key, value in pairs(b) do
		if value ~= a[key] then
			return false
		end
	end

	return true
end

return shallowEquals
