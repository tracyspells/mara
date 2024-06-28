export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
}

export type Dictionary<K, V> = { [K]: V }
export type AnyDictionary = Dictionary<any, any>

export type Document<Contents = AnyDictionary> = {
	shred: (self: Document<Contents>) -> (),
	changed: (self: Document<Contents>, callback: Listener<Contents>) -> Connection,

	read: ((self: Document<Contents>) -> Contents)
		& (<Selection>(self: Document<Contents>, selector: Selector<Contents, Selection>) -> Selection),

	edit: (self: Document<Contents>, makeChanges: Editor<Contents>) -> (),
	batchEdits: (self: Document<Contents>, edits: { Editor<Contents> }) -> (),
	setContents: (self: Document<Contents>, newContents: any) -> (),
	resetContents: (self: Document<Contents>) -> (),
	undo: (self: Document<Contents>) -> (),
	redo: (self: Document<Contents>) -> (),
}

export type Editor<Contents> = (contents: Contents) -> ()

export type DocumentMap = Dictionary<string, Document>

export type Selector<Input, Output> = (Input) -> Output
export type PrimitiveSelector<Input, Output> = (Input) -> Output & (string | number | boolean)
export type Predicate<A, B> = (A, B) -> boolean
export type Listener<T> = (T, T) -> ()

export type CompareFunction = (a: any, b: any) -> boolean

export type NetworkPayload = {
	type: "diff" | "full",
	contents: Dictionary<string, any>,
}

export type Importer = {
	import: (self: Importer, payload: NetworkPayload) -> (),
}

export type Exporter = {
	addRecipient: (self: Exporter, player: Player) -> (),
	start: (self: Exporter) -> (),
	stop: (self: Exporter) -> (),
}

export type ExporterOptions = {
	documents: DocumentMap,
	onExport: (player: Player, payload: NetworkPayload) -> (),
	interval: number?,
}

export type MockExporter = Exporter & {
	_sendDiff: (self: MockExporter, player: Player) -> (),
}

return nil
