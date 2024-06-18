local types = require(script.Parent.types)
local createDocument = require(script.Parent.createDocument)

type DocumentMap = types.DocumentMap

local function stapleDocuments(documents: DocumentMap)
	local contents = {}

	for name, document in documents do
		contents[name] = document:read()
	end

	return createDocument(contents)
end

return stapleDocuments
