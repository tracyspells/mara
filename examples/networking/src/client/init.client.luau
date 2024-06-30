local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Mara = require(ReplicatedStorage.Packages.Mara)

local network = require(ReplicatedStorage.Shared.network)
local documents = require(ReplicatedStorage.Shared.documents)

local watch = Mara.watch

local exportContents = network.exportContents
local addRecipient = network.addRecipient

local importer = Mara.getImporter(documents)
local counter = documents.counter

local function fizzPredicate(count: number): boolean
	if count == 0 then
		return false
	end

	return (count % 3) == 0
end

local function buzzPredicate(count: number): boolean
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

counter:changed(function(count)
	local isFizz = fizzPredicate(count) == true
	local isBuzz = buzzPredicate(count) == true

	if isFizz then
		print("fizz")
	elseif isBuzz then
		print("buzz")
	end
end)

watch(counter, function(count: number)
	print(`count: {count}`)
end)
