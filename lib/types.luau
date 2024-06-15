export type Connection = {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}

export type Document<C = any> = {
	shred: (self: Document<C>) -> (),
	changed: (self: Document<C>, callback: (C, C) -> ()) ->  Connection,
	once: (self: Document<C>, callback: (C, C) -> ()) -> Connection,
	read: (self: Document<C>, selector: ((contents: C) -> C)?) -> C,
	edit: (self: Document<C>, makeChanges: (contents: C) -> ()) -> (),
}

export type DocumentMap = { [string]: Document }

return nil
