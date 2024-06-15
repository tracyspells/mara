local types = require(script.Parent.types)
local utils = require(script.Parent.utils)
local createDocument = require(script.Parent.document)

type DocumentMap = types.DocumentMap

local function stapleDocuments(documents: DocumentMap)
	local contents = {}

	for name, document in documents do
		contents[name] = document:read()
	end

	contents = utils.copyDeep(contents)

	return createDocument(contents)
end

return stapleDocuments
