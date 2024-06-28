local types = require(script.types)
local createDocument = require(script.createDocument)
local createSelector = require(script.createSelector)
local trackDocumentHistory = require(script.trackDocumentHistory)
local watchUtils = require(script.watchUtils)
local sync = require(script.sync)

export type Document<C> = types.Document<C>

export type Exporter = types.Exporter
export type Importer = types.Importer

return {
	createDocument = createDocument,
	createSelector = createSelector,
	watch = watchUtils.watch,
	watchFor = watchUtils.watchFor,
	trackDocumentHistory = trackDocumentHistory,
	getExporter = sync.exporter,
	getImporter = sync.importer,
}
