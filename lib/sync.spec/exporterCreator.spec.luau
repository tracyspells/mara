local sync = require(script.Parent.Parent.sync)
local types = require(script.Parent.Parent.types)

local createDocument = require(script.Parent.Parent.createDocument)

type Exporter = types.Exporter
type Document<C> = types.Document<C>

type Contents = {
	count: number,
}

return function()
	it("shouldn't create an Exporter if 'options' argument isn't properly specified", function()
		expect(function()
			sync.exporter("hi" :: never)
		end).to.throw()
	end)

	it("shouldn't export document contents if ':start()' isn't called", function()
		local document: Document<Contents> = createDocument({ count = 0 })

		local exporter = sync.exporter({
			documents = { counter = document },
			interval = -1,
			onExport = function() end,
		})

		expect(function()
			exporter:stop()
		end).to.throw()

		expect(function()
			exporter:addRecipient({} :: any)
		end).to.throw()

		document:shred()
	end)
end
