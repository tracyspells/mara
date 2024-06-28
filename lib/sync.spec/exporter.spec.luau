local sync = require(script.Parent.Parent.sync)
local types = require(script.Parent.Parent.types)

local createDocument = require(script.Parent.Parent.createDocument)

type MockExporter = types.MockExporter
type Document<C> = types.Document<C>

type NetworkPayload = types.NetworkPayload

type Contents = {
	count: number,
}

return function()
	local mockPlayer = { __test = true }

	local resultPlayer: any
	local payload: NetworkPayload

	local exporter: MockExporter
	local document: Document<Contents>

	beforeEach(function()
		document = createDocument({ count = 0 })

		local function onExport(...)
			resultPlayer, payload = ...
		end

		exporter = sync.exporter({
			documents = { counter = document },
			interval = -1,
			onExport = onExport,
		}) :: MockExporter
	end)

	afterEach(function()
		resultPlayer = nil
		payload = nil :: never

		exporter:stop()
		document:shred()
	end)

	it("should send full document contents to players", function()
		exporter:start()
		exporter:addRecipient(mockPlayer :: any)

		expect(resultPlayer).to.equal(mockPlayer)

		expect(payload).to.be.ok()
		expect(payload).to.be.a("table")

		expect(payload.type).to.be.a("string")
		expect(payload.type).to.equal("full")

		expect(payload.contents).to.be.a("table")
		expect(payload.contents.counter).to.be.a("table")
		expect(payload.contents.counter.count).to.equal(0)
	end)

	it("should send delta snapshots of document contents to players", function()
		exporter:start()
		exporter:addRecipient(mockPlayer :: any)

		for _ = 1, 5 do
			document:edit(function(contents)
				contents.count += 1
			end)
		end

		exporter:_sendDiff(mockPlayer :: any)

		expect(resultPlayer).to.equal(mockPlayer)

		expect(payload).to.be.ok()
		expect(payload).to.be.a("table")

		expect(payload.type).to.be.a("string")
		expect(payload.type).to.equal("diff")

		expect(payload.contents).to.be.a("table")
		expect(payload.contents.counter).to.be.a("table")
		expect(payload.contents.counter.count).to.equal(5)
	end)
end
