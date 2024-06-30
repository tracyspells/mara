local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mara = require(ReplicatedStorage.Packages.Mara)

local createDocument = Mara.createDocument

type Document<C> = Mara.Document<C>
type Contents = number

export type CounterDocument = Document<Contents>

return createDocument(0)
