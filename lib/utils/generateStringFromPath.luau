local function generateStringFromPath(path: { string | number }, skipLastEntry: boolean?): string
	local result: string

	for index = 1, #path do
		local entry = path[index]

		if index == #path and skipLastEntry then
			continue
		end

		if not result then
			result = if typeof(entry) == "number" then `[{entry}]` else entry
		else
			result = result .. if typeof(entry) == "number" then `[{entry}]` else `.{entry}`
		end
	end

	return result
end

return generateStringFromPath
