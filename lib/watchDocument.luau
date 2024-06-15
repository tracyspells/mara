local types = require(script.Parent.types)

type Document<C> = types.Document<C>
type Connection = types.Connection

type Selector<T> = (T) -> T
type Predicate<C> = (C, C) -> boolean
type Listener<C> = (C, C) -> ()

local function watchDocument<C>(document: Document<C>, ...: any): Connection
	local arguments = select("#", ...)
	local selector: Selector<C>, predicate: Predicate<C>, listener: Listener<C>

	if arguments >= 3 then
		selector, predicate, listener = ...
	elseif arguments == 2 then
		selector, listener = ...
	else
		listener = ...
	end

	return document:changed(function(newContents, oldContents)
		local newSelection = if selector then selector(newContents) else newContents
		local oldSelection = if selector then selector(oldContents) else oldContents

		if predicate and not predicate(newSelection, oldSelection) then
			return
		end

		listener(newSelection, oldSelection)
	end)
end

return watchDocument
