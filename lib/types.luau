export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
	Destroy: (self: Connection) -> (),
}

export type Dictionary = { [any]: any }

export type Document<C = any> = {
	shred: (self: Document<C>) -> (),
	changed: (self: Document<C>, callback: (C, C) -> ()) -> Connection,
	read: (self: Document<C>, selector: ((contents: C) -> C)?) -> C,
	edit: (self: Document<C>, makeChanges: (contents: C) -> () | None) -> (),
	undoAll: (self: Document<C>) -> (),
	undo: (self: Document<C>) -> (),
	redo: (self: Document<C>) -> (),
	redoAll: (self: Document<C>) -> (),
}

export type DocumentMap = { [string]: Document<any> }

export type None = typeof(newproxy(true)) & { [string]: any }

export type Selector<T> = (T) -> any
export type PrimitiveSelector<T> = (T) -> string | number | boolean
export type Predicate<C> = (C, C) -> boolean
export type Listener<C> = (C, C) -> ()

export type CompareFunction = (a: any, b: any) -> boolean

return nil
