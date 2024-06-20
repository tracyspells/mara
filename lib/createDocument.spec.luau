local types = require(script.Parent.types)
local None = require(script.Parent.None)

type Document<C> = types.Document<C>
type State = {
	a: number,
	b: {
		c: number,
		d: { string },
	},
	e: boolean,
}

return function()
	local createDocument = require(script.Parent.createDocument)

	local document: Document<State>
	local state: State

	beforeAll(function()
		state = {
			a = 1,
			b = {
				c = 2,
				d = { "a", "C" },
			},
			e = true,
		}
	end)

	afterAll(function()
		state = nil :: never
	end)

	beforeEach(function()
		document = createDocument(state)
	end)

	afterEach(function()
		document:shred()
		document = nil :: never
	end)

	it("should edit contents", function()
		document:edit(function(contents)
			contents.a += 1
			contents.e = false

			contents.b = table.clone(contents.b)
			contents.b.c += 2
			contents.b["g"] = "hi"

			contents.b.d = table.clone(contents.b.d)
			table.insert(contents.b.d, "F")
		end)

		local result = document:read()

		expect(result.a).to.equal(2)
		expect(result.b.c).to.equal(4)
		expect(result.e).to.equal(false)

		expect(result.b["g"]).to.be.ok()
		expect(result.b["g"]).to.equal("hi")

		expect(#result.b.d).to.equal(3)
	end)

	it("should listen to changes", function()
		local changes = 0

		document:changed(function()
			changes += 1
		end)

		document:edit(function(contents)
			contents.a += 1
		end)

		document:edit(function(contents)
			contents.a += 1
		end)

		expect(changes).to.equal(2)
	end)

	it("shouldn't read contents if selection is nil", function()
		local result = document:read(function(contents)
			return contents["f"]
		end)

		expect(result).to.never.be.ok()
	end)

	it("shouldn't update contents if :edit() returns None", function()  
		local changes = 0

		document:changed(function()
			changes += 1
		end)

		document:edit(function(contents)
			contents.a += 1
		end)

		document:edit(function(contents)
			contents.a += 1
		end)

		document:edit(function()
			return None
		end)

		expect(changes).to.never.be.near(3)
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

	it("shouldn't detect changes if `:changed()` was disconnected", function()
		local changes = 0

		local connection = document:changed(function()
			changes += 1
		end)

		connection:Disconnect()

		document:edit(function(contents)
			contents.a += 2
		end)

		document:edit(function(contents)
			contents.a += 2
		end)

		expect(changes).to.never.be.near(1)
	end)
end
