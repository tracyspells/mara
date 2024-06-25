local types = require(script.Parent.Parent.types)

type Document<C> = types.Document<C>
type Contents = {
	a: number,
}

return function()
	local createDocument = require(script.Parent.Parent.createDocument)

	local document: Document<Contents>

	beforeEach(function()
		document = createDocument({ a = 0 })
	end)

	afterEach(function()
		document:shred()
	end)

	it("should reset to initial contents", function()
		local function selector(contents: Contents): number
			return contents.a
		end

		for _ = 1, 10 do
			document:edit(function(contents)
				contents.a += 1
			end)
		end

		local result = document:read(selector)

		expect(result).to.equal(10)

		document:resetContents()
		result = document:read(selector)

		expect(result).to.equal(0)
	end)
end
