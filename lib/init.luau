local types = require(script.types)
local None = require(script.None)

local document = require(script.document)
local combineDocuments = require(script.combineDocuments)

export type Document<C> = types.Document<C>

return {
	createDocument = document,
	combineDocuments = combineDocuments,
	None = None,
}
