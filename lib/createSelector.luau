local types = require(script.Parent.types)
local shallowEquals = require(script.Parent.utils.shallowEquals)

type CompareFunction = types.CompareFunction
type Selector<Input, Output> = types.Selector<Input, Output>
type EqualityOptions = {
	equalityCheck: CompareFunction?,
	resultEqualityCheck: CompareFunction?,
}

type AnySelector = Selector<any, any>

-- https://github.com/littensy/reflex/blob/master/src/createSelector.lua
local function memoize<Args...>(fn: (Args...) -> any, equalityFunc: CompareFunction?, resultEqualityFunc: CompareFunction?)
	local lastArguments = {}
	local lastArgumentCount = -1
	local lastResult = nil
	local firstRan = true

	return function(...: any)
		local arguments = { ... }
		local argumentCount = #arguments

		local result = lastResult

		if argumentCount ~= lastArgumentCount then
			result = fn(...)
			lastArgumentCount = argumentCount
			lastArguments = arguments
		else
			for index = 1, argumentCount do
				local current = arguments[index]
				local previous = lastArguments[index]

				if current ~= previous and (equalityFunc == nil or equalityFunc(current, previous) == false) then
					result = fn(...)
					lastArguments = arguments

					break
				end
			end
		end

		if resultEqualityFunc == nil then
			lastResult = result

			return result
		elseif firstRan or (result ~= lastResult and resultEqualityFunc(result, lastResult) == false) then
			firstRan = false
			lastResult = result
		end

		return lastResult
	end
end

local function createSelector(
	inputSelectors: { AnySelector },
	combiner: (...any) -> any,
	optionsOrEqualityCheck: EqualityOptions | CompareFunction
): (...any) -> any
	local options: EqualityOptions

	if typeof(optionsOrEqualityCheck) == "function" then
		options = {
			equalityCheck = optionsOrEqualityCheck,
		}
	elseif not optionsOrEqualityCheck then
		options = {
			equalityCheck = shallowEquals,
		}
	elseif typeof(optionsOrEqualityCheck) == "table" then
		options = optionsOrEqualityCheck
	end

	local memoizedCombiner = memoize(combiner, options.equalityCheck, options.resultEqualityCheck)

	return memoize(function(...: any)
		local params = {}

		for index, selector in inputSelectors do
			params[index] = selector(...)
		end

		return memoizedCombiner(table.unpack(params))
	end)
end

return createSelector
