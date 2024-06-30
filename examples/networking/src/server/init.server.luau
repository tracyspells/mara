local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mara = require(ReplicatedStorage.Packages.Mara)

local network = require(ReplicatedStorage.Shared.network)
local documents = require(ReplicatedStorage.Shared.documents)

local exportContents = network.exportContents
local addRecipient = network.addRecipient

local function onExport(player, payload)
	exportContents:fire(player, payload)
end

-- initialization

local exporter = Mara.getExporter({
	onExport = onExport,
	documents = documents,
})

exporter:start()
addRecipient:connect(function(player)
	exporter:addRecipient(player)
end)

while task.wait(3) do
	documents.counter:edit(function(count)
		return count + 1
	end)
end
