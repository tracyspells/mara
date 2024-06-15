return function()
	local createDocument = require(script.Parent.document)

	local document
	local state: {
		a: number,
		b: {
			c: number,
			d: { string },
		},
		e: boolean,
	}

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
			contents.b.c += 2
			contents.b["g"] = "hi"
			contents.e = false

			table.insert(contents.b.d, "F")
		end)

		local result = document:read()

		expect(result.a).to.equal(2)
		expect(result.b.c).to.equal(4)
		expect(result.e).to.equal(false)
		expect(result.b["g"]).to.be.ok()
		expect(result.b["g"]).to.equal("hi")
		expect(#result.b.d).to.equal(3)

		document:edit(function(contents)
			contents["f"] = {}
			table.insert(contents["f"], "hello")
		end)

		local result2 = document:read()
		expect(result2["f"]).to.be.ok()
		expect(result2["f"][1]).to.equal("hello")
	end)

	it("should listen to changes", function()
		local changes = 0

		document:changed(function()
			changes += 1
		end)

        for _ = 1, 10 do
            document:edit(function(contents)
                contents.a += 1
            end)
        end

		expect(changes).to.equal(10)
	end)

	it("should listen to changes only once", function() 
		local changes = 0

		document:once(function()
			changes += 1
		end)

        document:edit(function(contents)
			contents.a += 1
		end)

		document:edit(function(contents)
			contents.a += 1
		end)

		expect(changes).to.equal(1)
	end)

	it("shouldn't modify readonly content", function()
		local result = document:read()

		expect(function()
			result.a += 1
		end).to.throw("attempt to modify a readonly table")
	end)

	it("shouldn't read contents if selection is nil", function()
		local result = document:read(function(contents)
            return contents["f"]
		end)

		expect(result).to.never.be.ok()
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


    it(
        "shouldn't detect changes if `:changed()` was disconnected",
        function()  
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
        end
    )
end
