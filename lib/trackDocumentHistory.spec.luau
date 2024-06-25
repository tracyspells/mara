local types = require(script.Parent.types)

type Document<C> = types.Document<C>
type Contents = {
	a: number,
}

return function()
	local createDocument = require(script.Parent.createDocument)
    local trackDocumentHistory = require(script.Parent.trackDocumentHistory)

	local document: Document<Contents>

	beforeEach(function()
		document = trackDocumentHistory(createDocument({ a = 0 }))
	end)

	afterEach(function()
		document:shred()
	end)

	it("should undo an edit", function()
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
        expect(result).to.equal(0)
	end)

    it("should redo an edit", function() 
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
        expect(result).to.equal(0)

        document:redo()
        result = document:read(selector)
        expect(result).to.equal(1)
    end)

    it("should revert back to inital contents", function()
        local function selector(contents: Contents): number
            return contents.a
        end

        for _ = 1, 10 do
            document:edit(function(contents)
                contents.a += 1
            end)
        end

        local result = document:read(selector)
        expect(result).to.equal(10)

        for _ = 1, 10 do
            document:undo()
        end

        result = document:read(selector)
        expect(result).to.equal(0)
    end)

    it("should redo all edits to the latest one", function()
        local function selector(contents: Contents): number
            return contents.a
        end

        for _ = 1, 10 do
            document:edit(function(contents)
                contents.a += 1
            end)
        end

        local result = document:read(selector)
        expect(result).to.equal(10)

        for _ = 1, 10 do
            document:undo()
        end

        result = document:read(selector)
        expect(result).to.equal(0)

        for _ = 1, 10 do
            document:redo()
        end

        result = document:read(selector)
        expect(result).to.equal(10)
    end)
end
