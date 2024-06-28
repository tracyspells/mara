local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mara = require(ReplicatedStorage.Packages.Mara)

local createDocument = Mara.createDocument

type Document<C> = Mara.Document<C>
type Contents = {
    count: number
}

export type CounterDocument = Document<Contents>

return createDocument({ count = 0 })
