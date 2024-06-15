local types = require(script.types)
local None = require(script.None)

local document = require(script.document)
local stapleDocuments = require(script.stapleDocuments)
local watchDocument = require(script.watchDocument)

export type Document<C> = types.Document<C>

return {
	createDocument = document,
	stapleDocuments = stapleDocuments,
	watchDocument = watchDocument,

	None = None,
}
