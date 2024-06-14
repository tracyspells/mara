local types = require(script.Parent.types)
local utils = require(script.Parent.utils)

type Document<C> = types.Document<C>

local function validateContents(value: any): boolean
	if typeof(value) == "table" and getmetatable(value) == nil then
		return true
	end

	return false
end

local function createDocument<C>(initialContents: C): Document<C>
	assert(
		validateContents(initialContents), 
		`Documents must be based on tables with no existing metatables. Got {typeof(initialContents)}`
	)

	local document = {}
	local contents = utils.freezeDeep(initialContents :: any)

	function document:read(selector)
		return if selector then selector(contents) else contents
	end

	function document:write(edit)
		local newContents = utils.merge(initialContents, contents)
		edit(newContents)

		if newContents ~= contents then
			contents = utils.freezeDeep(utils.merge(contents, newContents) :: any)
		end
	end

	return document :: any
end

return createDocument
