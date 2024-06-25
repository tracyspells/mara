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

	it("should return a Connection object", function()
		local connection = document:changed(function()
			-- do nothing :P
		end)

		expect(connection).to.be.a("table")
		expect(connection.Connected).to.be.a("boolean")
		expect(connection.Destroy).to.be.a("function")
		expect(connection.Disconnect).to.be.a("function")

		connection:Destroy()
	end)

	it("should call the listener when document contents change", function()
		local changes = 0

		document:changed(function()
			changes += 1
		end)

		expect(changes).to.equal(0)

		document:edit(function(contents)
			contents.a += 1
		end)

		expect(changes).to.equal(1)

		document:edit(function(contents)
			contents.a += 1
		end)

		expect(changes).to.equal(2)
	end)

	it("should pass old and new contents to the listener", function()
		local initialContents = document:read()
		local newContents, oldContents

		document:changed(function(new, old)
			newContents = new
			oldContents = old
		end)

		document:edit(function(contents)
			contents.a += 1
		end)

		expect(oldContents).to.equal(initialContents)
		expect(newContents).to.equal(document:read())
		expect(newContents).to.never.equal(oldContents)
	end)

	it("should listen to batched edits", function()
		local changes = 0

		document:changed(function()
			changes += 1
		end)

		document:batchEdits({
			function(contents)
				contents.a += 1
			end,

			function(contents)
				contents["b"] = true
			end,
		})

		expect(changes).to.equal(1)
	end)

	it("shouldn't detect changes after being shredded", function()
		local changes = 0

		document:changed(function()
			changes += 1
		end)

		document:edit(function(contents)
			contents.a += 2
		end)

		document:shred()
		document:edit(function(contents)
			contents.a += 2
		end)

		expect(changes).to.equal(1)
	end)
end
