type Callback = (...any?) -> ()
type GenericCallback = () -> ()

type Entity = {
	getScared: Callback,
	getsScaredOnce: boolean?,
}

type ObserveTable = { [Entity]: Callback }

export type WatchdogObject = {
	observe: (self: WatchdogObject, subject: Callback) -> GenericCallback,
	observeOnce: (self: WatchdogObject, subject: Callback) -> GenericCallback,
	bark: (self: WatchdogObject, ...any) -> (),
	sleep: (self: WatchdogObject) -> (),
}

export type Watchdog = {
	new: () -> WatchdogObject,
}

local Watchdog = {}

function Watchdog.new(): WatchdogObject
	local watchdog = {}
	local observing: ObserveTable = {}
	local isSleeping = false

	local function observe(subject: Callback, observeOnce: boolean?)
		local entity = {
			getScared = subject,
			getsScaredOnce = observeOnce,
		}

		local function stopObserving()
			observing[entity] = nil
		end

		observing[entity] = stopObserving

		return stopObserving
	end

	function watchdog:observe(subject: Callback)
		if isSleeping then
			return
		end

		return observe(subject)
	end

	function watchdog:observeOnce(subject: Callback)
		if isSleeping then
			return
		end

		return observe(subject, true)
	end

	function watchdog:bark(...: any)
		if isSleeping then
			return
		end

		for entity, stopObserving in observing do
			task.spawn(entity.getScared, ...)

			if entity.getsScaredOnce then
				stopObserving()
			end
		end
	end

	function watchdog:sleep()
		if isSleeping then
			return
		end

		for _, stopObserving in observing do
			stopObserving()
		end

		local _, stopObserving = next(observing)

		while stopObserving ~= nil do
			stopObserving()

			_, stopObserving = next(observing)
		end

		observing = {}
		isSleeping = true
	end

	return watchdog :: any
end

return Watchdog :: Watchdog
