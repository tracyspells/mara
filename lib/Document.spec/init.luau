local types = require(script.Parent.types)

type Document<C> = types.Document<C>
type Selector<I, O> = types.Selector<I, O>
type Contents = {
	a: number,
}

return function()
	local createDocument = require(script.Parent.createDocument)

	local document: Document<Contents>

	local function selector(contents: Contents): number
		return contents.a
	end

	beforeEach(function()
		document = createDocument({ a = 0 })
	end)

	afterEach(function()
		document:shred()
	end)

	it("should be a document", function()
		expect(document).to.be.a("table")
		expect(document.edit).to.be.a("function")
		expect(document.redo).to.be.a("function")
		expect(document.undo).to.be.a("function")
		expect(document.shred).to.be.a("function")
		expect(document.read).to.be.a("function")
		expect(document.setContents).to.be.a("function")
		expect(document.resetContents).to.be.a("function")
		expect(document.changed).to.be.a("function")
	end)

	it("should read contents", function()
		local resultA = document:read()

		expect(resultA).to.be.a("table")
		expect(resultA.a).to.equal(0)

		local resultB = document:read(selector)

		expect(resultB).to.be.a("number")
		expect(resultB).to.equal(0)
	end)

	it("should edit contents", function()
		document:edit(function(contents)
			contents.a += 1
		end)

		local result = document:read()

		expect(result.a).to.equal(1)

		document:edit(function(contents)
			contents.a -= 1
		end)

		result = document:read()

		expect(result.a).to.equal(0)
	end)
end
