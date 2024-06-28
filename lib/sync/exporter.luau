local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local types = require(script.Parent.Parent.types)

local setInterval = require(script.Parent.setInterval)

local utils = script.Parent.Parent.utils
local difference = require(utils.difference)
local isStrictTable = require(utils.isStrictTable)

local copy = table.clone

local IS_SERVER = RunService:IsServer()
local IS_TESTING = RunService:IsStudio() and RunService:IsRunning()

local ERROR_MESSAGES = {
	Initialize = "'Mara.getExporter()' must be called from the server!",
	Start = "'exporter:start()' must be called before 'exporter:%s()'!",
	Options = "The 'options' argument in 'Mara.getExporter()' must be a table, got %s",
}

type Contents = Dictionary<string, any>
type NetworkPayload = types.NetworkPayload

type MockExporter = types.MockExporter
type Exporter = types.Exporter
type ExporterOptions = types.ExporterOptions

type DocumentMap = types.DocumentMap

type Connection = types.Connection
type Connections = { Connection }

type Dictionary<K, V> = types.Dictionary<K, V>
type Set<T> = { [T]: boolean }

local function getExporter(options: ExporterOptions): Exporter
	if not isStrictTable(options) then
		error(string.format(ERROR_MESSAGES.Options, typeof(options)))
	end

	if not IS_TESTING and not IS_SERVER then
		error(ERROR_MESSAGES.Initialize)
	end

	local playersConnected: Set<Player> = {}

	local documentContents: Contents = {}
	local documentContentSnapshot: Contents = {}
	local changed = false

	local connections: Connections = {}
	local disconnectSnapshotInterval: () -> ()

	local documents = options.documents
	local onExport = options.onExport

	local exporter = {} :: Exporter
	local started = false

	Players.PlayerRemoving:Connect(function(player)
		if playersConnected[player] then
			playersConnected[player] = nil
		end
	end)

	function exporter:start()
		if started then
			warn("'exporter:start()' already started!")

			return
		end

		started = true

		-- step 1: get our document contents and
		-- setup connections for content changes
		for name, document in documents do
			documentContents[name] = document:read()
			documentContentSnapshot[name] = documentContents[name]

			table.insert(
				connections,
				document:changed(function(contents)
					documentContents[name] = contents
					changed = true
				end)
			)
		end

		-- step 2: send players delta snapshots of document contents
		disconnectSnapshotInterval = setInterval(function()
			if not changed then
				return
			end

			local diff = difference(documentContentSnapshot, documentContents) :: Contents

			documentContentSnapshot = copy(documentContents) -- store our new state here to use against our next state
			changed = false

			for player in playersConnected do
				onExport(player, { type = "diff", contents = diff })
			end
		end, options.interval)
	end

	function exporter:stop()
		if not started then
			error(string.format(ERROR_MESSAGES.Start, "stop"))
		end

		started = false

		disconnectSnapshotInterval()

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end

	function exporter:addRecipient(player)
		if not started then
			error(string.format(ERROR_MESSAGES.Start, "addRecipient"))
		end

		local isConnected = playersConnected[player]

		if isConnected then
			return
		end

		playersConnected[player] = true

		onExport(player, { type = "full", contents = documentContents })
	end

	(exporter :: MockExporter)._sendDiff = function(_, player)
		if not started then
			error(string.format(ERROR_MESSAGES.Start, "sendPatch"))
		end

		local isConnected = playersConnected[player]

		if not isConnected then
			return
		end

		if not changed then
			return
		end

		local diff = difference(documentContentSnapshot, documentContents) :: Contents

		documentContentSnapshot = copy(documentContents) -- store our new state here to use against our next state
		changed = false

		onExport(player, { type = "diff", contents = diff })
	end

	return exporter
end

return getExporter
