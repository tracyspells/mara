--!nocheck

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ServerScriptService.DevPackages.TestEZ)

TestEZ.TestBootstrap:run({ ReplicatedStorage.Packages.Mara })
