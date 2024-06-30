local types = require(script.Parent.types)

type Document<C> = types.Document<C>
type Selector<I, O> = types.Selector<I, O>
type Contents = {
	a: number,
}

return function()
	local createDocument = require(script.Parent.createDocument)

	local function selector(contents: Contents): number
		return contents.a
	end

	it("should be a document", function()
		local document = createDocument({ a = 0 })

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

	describe("basic functions", function()  
		local documentA: Document<Contents>
		local documentB: Document<number>

		beforeEach(function()
			documentA = createDocument({ a = 0 })
			documentB = createDocument(0)
		end)

		afterEach(function() 
			documentA:shred()
			documentB:shred() 
		end)

		it("should read contents", function()
			local resultA = documentA:read()
	
			expect(resultA).to.be.a("table")
			expect(resultA.a).to.equal(0)
	
			local resultB = documentA:read(selector)
	
			expect(resultB).to.be.a("number")
			expect(resultB).to.equal(0)

			local resultC = documentB:read()
			
			expect(resultC).to.be.a("number")
			expect(resultC).to.equal(0)
		end)

		it("should edit contents", function()
			documentA:edit(function(contents)
				contents.a += 1
			end)
	
			local resultA = documentA:read()
	
			expect(resultA.a).to.equal(1)
	
			documentA:edit(function(contents)
				contents.a -= 1
			end)
	
			resultA = documentA:read()
	
			expect(resultA.a).to.equal(0)

			documentB:edit(function(number)
				return number + 1
			end)

			local resultB = documentB:read()

			expect(resultB).to.equal(1)

			documentB:edit(function(number)
				return number - 1
			end)

			resultB = documentB:read()

			expect(resultB).to.equal(0)
		end)
	end)
end
