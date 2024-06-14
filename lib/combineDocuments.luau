local types = require(script.Parent.types)
local document = require(script.Parent.document)

type DocumentMap = types.DocumentMap

local function combineDocuments(documents: DocumentMap)
    local contents = {}

    for name, doc in documents do
        contents[name] = doc:read()
    end

    return document(contents)
end

return combineDocuments