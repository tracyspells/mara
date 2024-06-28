local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mara = require(ReplicatedStorage.Packages.Mara)

local network = require(ReplicatedStorage.Shared.network)
local documents = require(ReplicatedStorage.Shared.documents)

local watchFor = Mara.watchFor

local exportContents = network.exportContents
local addRecipient = network.addRecipient

local importer = Mara.getImporter(documents)

local function counterSelector(contents): number
	return contents.count
end

local function fizzPredicate(count: number, _oldCount: number): boolean
	if count == 0 then
		return false
	end

	return (count % 3) == 0
end

local function buzzPredicate(count: number, _oldCount: number): boolean
	if count == 0 then
		return false
	end

	return (count % 5) == 0
end

-- initialization

addRecipient:fire()
exportContents:connect(function(payload)
	importer:import(payload)
end)

documents.counter:changed(function(newContents, oldContents)
	local newCount, oldCount = counterSelector(newContents), counterSelector(oldContents)
	local isFizz = fizzPredicate(newCount, oldCount) == true
	local isBuzz = buzzPredicate(newCount, oldCount) == true

	if isFizz then
		print('fizz')
	elseif isBuzz then
		print('buzz')
	end
end)

watchFor(documents.counter, counterSelector, function(count)  
	print(`count: {count}`)
end)
