return function()
	local sync = require(script.Parent.sync)

	it("should load", function()
		expect(sync).to.be.ok()
	end)
end
