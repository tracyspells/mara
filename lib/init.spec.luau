return function()
    local mara = require(script.Parent)

    it("should load", function()
        expect(mara).to.be.ok()
    end)
end
