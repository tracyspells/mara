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

	it("shouldn't call `:redo()` if `:trackDocumentHistory()` wasn't called prior", function()
		local function selector(contents: Contents): number
			return contents.a
		end

		document:edit(function(contents)
			contents.a += 1
		end)

		local result = document:read(selector)

		expect(result).to.equal(1)

		document:redo()
		result = document:read(selector)

		expect(result).to.equal(1)
	end)

	it("shouldn't call `:undo()` if `:trackDocumentHistory()` wasn't called prior", function()
		local function selector(contents: Contents): number
			return contents.a
		end

		document:edit(function(contents)
			contents.a += 1
		end)

		local result = document:read(selector)

		expect(result).to.equal(1)

		document:undo()
		result = document:read(selector)

		expect(result).to.equal(1)
	end)
end
