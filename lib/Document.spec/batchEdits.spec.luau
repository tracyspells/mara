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

	it("should error if 'edits' argument is a non-table", function()
		expect(function()
			document:batchEdits(0 :: any)
		end).to.throw()
	end)

	it("should apply batched edits", function()
		document:batchEdits({
			function(contents)
				contents.a += 1
			end,

			function(contents)
				contents["b"] = true
			end,
		})

		local result = document:read()

		expect(result.a).to.equal(1)

		expect(result["b"]).to.be.ok()
		expect(result["b"]).to.be.a("boolean")
		expect(result["b"]).to.equal(true)
	end)
end
