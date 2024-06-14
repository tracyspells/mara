export type Document<C = any> = {
	read: (self: Document<C>, selector: ((contents: C) -> C)?) -> C,
	write: (self: Document<C>, edit: (contents: C) -> ()) -> (),
}

export type DocumentMap = { [string]: Document }

return nil
