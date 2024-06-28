local sync = require(script.Parent.Parent.sync)
local types = require(script.Parent.Parent.types)

local createDocument = require(script.Parent.Parent.createDocument)

type Importer = types.Importer
type Document<C> = types.Document<C>

type Contents = {
	count: number,
	[string]: any,
}

return function()
	it("shouldn't create an Importer if 'options' argument isn't properly specified", function()
		expect(function()
			sync.importer("hi" :: never)
		end).to.throw()
	end)

	it("should import full document contents", function()
		local document: Document<Contents> = createDocument({ count = 0 })
		local importer: Importer = sync.importer({ counter = document })

		importer:import({
			type = "full",
			contents = { counter = { count = 1 } },
		})

		local result = document:read()

		expect(result).to.be.ok()
		expect(result).to.be.a("table")
		expect(result.count).to.equal(1)
	end)

	it("should import delta document contents", function()
		local document: Document<Contents> = createDocument({ count = 0 })
		local importer: Importer = sync.importer({ counter = document })

		importer:import({
			type = "diff",
			contents = {
				counter = {
					count = 1,
					a = true,
					b = {
						c = 2,
					},
				},
			},
		})

		local result = document:read()

		expect(result).to.be.ok()
		expect(result).to.be.a("table")

		expect(result.count).to.equal(1)
		expect(result.a).to.equal(true)

		expect(result.b).to.be.a("table")
		expect(result.b.c).to.equal(2)
	end)
end
