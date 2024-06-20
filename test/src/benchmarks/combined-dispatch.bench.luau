--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reflex = require(ReplicatedStorage.Packages.Reflex)
local Mara = require(ReplicatedStorage.Packages.Mara)
local Rodux = require(ReplicatedStorage.Packages.Rodux)
local Silo = require(ReplicatedStorage.Packages.Silo)

local LOOPS = 100

--[[
	Benchmarker

	Device: Surface Pro 9
    Device Specs:
    	- CPU:  12 Gen Intel Core i5-1235U 2.50 GHz
    	- RAM: 8 GB

	Run type: Time
	Run time: 1 second

	Times

	Mara.createDocument: 44 microseconds
	Mara.stapleDocuments: 42 microseconds

	Reflex.createProducer:   62 microseconds
	Reflex.combineProducers: 81 microseconds

	Rodux.createReducer:     137 microseconds
	Rodux.combineReducers:   187 microseconds

	Sleitnick.singleSilo:    480 microseconds
	Sleitnick.combineSilos:  511 microseconds
	
]]

return {
	ParameterGenerator = function()
		local result = {
			documents = Mara.stapleDocuments({
				a = Mara.createDocument({ count = 0 }),
				b = Mara.createDocument({ count = 0 }),
			}),

			document = Mara.createDocument({
				a = { count = 0 },
				b = { count = 0 },
			}),

			silo = Silo.combine({
				a = Silo.new({ count = 0 }, {
					incrementA = function(state, amount)
						state.count += amount
					end,
				}),

				b = Silo.new({ count = 0 }, {
					incrementB = function(state, amount)
						state.count += amount
					end,
				}),
			}),

			siloUncombined = Silo.new({
				a = { count = 0 },
				b = { count = 0 },
			}, {
				incrementA = function(state, amount)
					state.a = table.clone(state.a)
					state.a.count += amount
				end,

				incrementB = function(state, amount)
					state.b = table.clone(state.b)
					state.b.count += amount
				end,
			}),

			producer = Reflex.combineProducers({
				a = Reflex.createProducer({ count = 0 }, {
					incrementA = function(state, amount)
						return { count = state.count + amount }
					end,
				}),
				b = Reflex.createProducer({ count = 0 }, {
					incrementB = function(state, amount)
						return { count = state.count + amount }
					end,
				}),
			}),

			producerUncombined = Reflex.createProducer({ a = { count = 0 }, b = { count = 0 } }, {
				incrementA = function(state, amount)
					return { a = { count = state.a.count + amount }, b = state.b }
				end,
				incrementB = function(state, amount)
					return { b = { count = state.b.count + amount }, a = state.a }
				end,
			}),

			store = Rodux.Store.new(Rodux.combineReducers({
				a = Rodux.createReducer({ count = 0 }, {
					incrementA = function(state, action)
						return { count = state.count + action.amount }
					end,
				}),
				b = Rodux.createReducer({ count = 0 }, {
					incrementB = function(state, action)
						return { count = state.count + action.amount }
					end,
				}),
			})),

			storeUncombined = Rodux.Store.new(Rodux.createReducer({ a = { count = 0 }, b = { count = 0 } }, {
				incrementA = function(state, action)
					return { a = { count = state.a.count + action.amount }, b = state.b }
				end,
				incrementB = function(state, action)
					return { b = { count = state.b.count + action.amount }, a = state.a }
				end,
			})),
		}

		task.defer(function()
			result.store:destruct()
			result.storeUncombined:destruct()
		end)

		return result
	end,

	Functions = {
		["Reflex.combineProducers"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.producer.incrementA(1)
				parameter.producer.incrementB(1)
			end
		end,

		["Reflex.createProducer"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.producerUncombined.incrementA(1)
				parameter.producerUncombined.incrementB(1)
			end
		end,

		["Rodux.combineReducers"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.store:dispatch({ type = "incrementA", amount = 1 })
				parameter.store:dispatch({ type = "incrementB", amount = 1 })
			end
		end,

		["Rodux.createReducer"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.storeUncombined:dispatch({ type = "incrementA", amount = 1 })
				parameter.storeUncombined:dispatch({ type = "incrementB", amount = 1 })
			end
		end,

		["Sleitnick.combineSilos"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.silo:Dispatch(parameter.silo.Actions.incrementA(1))
				parameter.silo:Dispatch(parameter.silo.Actions.incrementB(1))
			end
		end,

		["Sleitnick.singleSilo"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.siloUncombined:Dispatch(parameter.siloUncombined.Actions.incrementA(1))
				parameter.siloUncombined:Dispatch(parameter.siloUncombined.Actions.incrementB(1))
			end
		end,

		["Mara.stapleDocuments"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.documents:edit(function(contents)
					contents.a = table.clone(contents.a)
					contents.a.count += 1
				end)

				parameter.documents:edit(function(contents)
					contents.b = table.clone(contents.b)
					contents.b.count += 1
				end)
			end
		end,

		["Mara.createDocument"] = function(profiler, parameter)
			for _ = 1, LOOPS do
				parameter.document:edit(function(contents)
					contents.a = table.clone(contents.a)
					contents.a.count += 1
				end)

				parameter.document:edit(function(contents)
					contents.b = table.clone(contents.b)
					contents.b.count += 1
				end)
			end
		end,
	},
}
