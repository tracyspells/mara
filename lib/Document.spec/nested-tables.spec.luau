local types = require(script.Parent.Parent.types)

type Document<C> = types.Document<C>
type Contents = {
	a: number,
	b: boolean,
	c: {
		d: number,
		e: { string },
		f: {
			g: boolean,
			h: number,
		},
	},
}

type ContentsA = {
	g: boolean,
	h: number,
}

type ContentsB = {
	d: number,
	e: { string },
	f: {
		g: boolean,
		h: number,
	},
}

return function()
	local createDocument = require(script.Parent.Parent.createDocument)

	local document: Document<Contents> = createDocument({
		a = 0,
		b = false,
		c = {
			d = 1,
			e = { "hi", "i'm", "bob" },
			f = {
				g = true,
				h = 2,
			},
		},
	})

	it("should edit nested tables", function()
		document:edit(function(contents: ContentsA)
			contents.h += 1
		end, { "c", "f", "h" })

		local result = document:read()
		expect(result.c.f.h).to.equal(3)

		document:edit(function(contents: ContentsB)
			contents.d += 1
		end, { "c", "d" })

		result = document:read()
		expect(result.c.d).to.equal(2)
	end)

	it("shouldn't edit entries that don't exist", function()
		expect(function()
			document:edit(function(contents)
				contents.a = false :: any
			end, { "c", "g" })
		end).to.throw()
	end)
end
