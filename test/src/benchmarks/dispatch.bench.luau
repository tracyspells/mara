--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.Packages.Reflex)
local Mara = require(ReplicatedStorage.Packages.Mara)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local Silo = require(ReplicatedStorage.Packages.Silo)

local LOOPS = 500

--[[
	Benchmarker

	Device: Surface Pro 9
    Device Specs:
    	- CPU:  12 Gen Intel Core i5-1235U 2.50 GHz
    	- RAM: 8 GB

	Run type: Time
	Run time: 1 second

	Times

	Mara.Document: 138 microseconds
	Reflex.Producer: 206 microseconds
	Rodux.Store: 566 microseconds
	Sleitnick.Silo: 1380 microseconds
	
]]

return {
	ParameterGenerator = function()
		local result = {

			document = Mara.createDocument({
				countA = 0,
				countB = 0,
			}),

			producer = Reflex.createProducer({ countA = 0, countB = 0 }, {
				incrementA = function(state)
					return { countA = state.countA + 1, countB = state.countB }
				end,
				incrementB = function(state)
					return { countA = state.countA, countB = state.countB + 1 }
				end,
			}),

			store = Rodux.Store.new(Rodux.createReducer({ countA = 0, countB = 0 }, {
				incrementA = function(state)
					return { countA = state.countA + 1, countB = state.countB }
				end,
				incrementB = function(state)
					return { countA = state.countA, countB = state.countB + 1 }
				end,
			})),

			silo = Silo.new({ countA = 0, countB = 0 }, {
				incrementA = function(state, amount)
					state.countA += amount
				end,
				incrementB = function(state, amount)
					state.countB += amount
				end,
			}),
		}

		-- Destroy the Rodux stores to prevent memory leaks
		task.defer(function()
			result.store:destruct()
		end)

		return result
	end,

	Functions = {
		["Reflex.Producer"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.producer.incrementA()
				parameter.producer.incrementB()
			end
		end,

		["Rodux.Store"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.store:dispatch({ type = "incrementA" })
				parameter.store:dispatch({ type = "incrementB" })
			end
		end,

		["Sleitnick.Silo"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.silo:Dispatch(parameter.silo.Actions.incrementA(1))
				parameter.silo:Dispatch(parameter.silo.Actions.incrementB(1))
			end
		end,

		["Mara.Document"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.document:edit(function(contents)
					contents.countA += 1
				end)

				parameter.document:edit(function(contents)
					contents.countB += 1
				end)
			end
		end,
	},
}
