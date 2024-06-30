local types = require(script.Parent.Parent.types)

type Document<C> = types.Document<C>

return function()
	local createDocument = require(script.Parent.Parent.createDocument)

	local document: Document<any>

	beforeEach(function()
		document = createDocument({ a = 0 })
	end)

	afterEach(function()
		document:shred()
	end)

	it("should set contents", function()
		local oldContents = document:read()

		document:setContents({ b = 0 })

		local newContents = document:read()

		expect(newContents).to.never.equal(oldContents)
		expect(newContents.b).to.equal(0)
	end)

	it("shouldn't set contents to nil", function()
		expect(function()
			document:setContents(nil)
		end).to.throw()
	end)

	it("shouldn't set contents to a type different than what was initially set", function() 
		expect(function()
			document:setContents("hi my name is alice")
		end).to.throw()
	end)
end
