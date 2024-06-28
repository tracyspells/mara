local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remo = require(ReplicatedStorage.Packages.Remo)
local Mara = require(ReplicatedStorage.Packages.Mara)

type NetworkPayload = Mara.NetworkPayload

export type Network = {
	addRecipient: Remo.ClientToServer<...never>,
	exportContents: Remo.ServerToClient<Mara.NetworkPayload>,
}

return Remo.createRemotes({
	addRecipient = Remo.remote(),
	exportContents = Remo.remote(),
}) :: Network
