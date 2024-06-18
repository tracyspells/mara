local types = require(script.types)
local createDocument = require(script.createDocument)
local stapleDocuments = require(script.stapleDocuments)
local watchUtils = require(script.watchUtils)

export type Document<C> = types.Document<C>

return {
	createDocument = createDocument,
	stapleDocuments = stapleDocuments,
	watch = watchUtils.watch,
	watchFor = watchUtils.watchFor,
}
