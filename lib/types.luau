export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
}

export type Dictionary = { [any]: any }

export type Document<C = any> = {
	shred: (self: Document<C>) -> (),
	changed: (self: Document<C>, callback: (C, C) -> ()) -> Connection,
	read: (self: Document<C>, selector: Selector<C>?) -> C,
	edit: (self: Document<C>, makeChanges: Editor<C>) -> (),
	batchEdits: (self: Document<C>, edits: { Editor<C> }) -> (),
	setContents: (self: Document<C>, newContents: any) -> (),
	resetContents: (self: Document<C>) -> (),
	undo: (self: Document<C>) -> (),
	redo: (self: Document<C>) -> (),
}

export type Editor<C> = (contents: C) -> ()

export type DocumentMap = { [string]: Document<any> }

export type Selector<T> = (T) -> any
export type PrimitiveSelector<T> = (T) -> string | number | boolean
export type Predicate<C> = (C, C) -> boolean
export type Listener<C> = (C, C) -> ()

export type CompareFunction = (a: any, b: any) -> boolean

return nil
