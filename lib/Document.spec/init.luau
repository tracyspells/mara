local types = require(script.Parent.types)

type Document<C> = types.Document<C>
type Contents = {
	a: number,
}

return function()
	local createDocument = require(script.Parent.createDocument)

	local document: Document<Contents>

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
		local result = document:read()

		expect(result).to.be.a("table")
		expect(result.a).to.equal(0)

		result = document:read(function(contents)
			return contents.a
		end)

		expect(result).to.be.a("number")
		expect(result).to.equal(0)
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
