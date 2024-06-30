local types = require(script.Parent.Parent.types)

type Document<C> = types.Document<C>
type Contents = {
	a: number,
}

return function()
	local createDocument = require(script.Parent.Parent.createDocument)

	local document: Document<Contents>
	local documentRaw: Document<number>

	beforeEach(function()
		document = createDocument({ a = 0 })
		documentRaw = createDocument(0)
	end)

	afterEach(function()
		document:shred()
		documentRaw:shred()
	end)

	it("errors if 'edits' argument is a non-table", function()
		expect(function()
			document:batchEdits(0 :: any)
		end).to.throw()
	end)

	it("applies batched edits", function()
		document:batchEdits({
			function(contents)
				contents.a += 1
			end,

			function(contents)
				contents["b"] = true
			end,
		})

		documentRaw:batchEdits({
			function(number)
				return number + 1
			end,

			function(number)
				return number + 2
			end,

			function(number)
				return number * 2
			end
		})

		local result = document:read()
		local resultRaw = documentRaw:read()

		expect(result.a).to.equal(1)

		expect(result["b"]).to.be.ok()
		expect(result["b"]).to.be.a("boolean")
		expect(result["b"]).to.equal(true)

		expect(resultRaw).to.equal(6)
	end)
end
