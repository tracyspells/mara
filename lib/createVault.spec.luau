return function()
	local createVault = require(script.Parent.createVault)

	local vault: createVault.VaultObject<number>
    
    type VaultItem = createVault.Item<number>

	beforeEach(function()
		vault = createVault(10)
	end)

	afterEach(function()
		vault:clear()
		vault = nil :: never
	end)

	it("should store items", function()
        for index = 1, 8 do
			vault:push({ id = index, value = math.random(index + 10) })
		end 

		expect(vault:getSize()).to.equal(8)
	end)

	it("should clear items", function()
		for index = 1, 3 do
			vault:push({ id = index, value = 43 })
		end

		vault:clear()
		expect(vault:getSize()).to.never.be.near(1)
	end)

    it("must get a specified item", function() 
        for index = 1, 8 do
			vault:push({ id = index, value = math.random(index + 10) })
		end 

        local item = vault:getItem(2)

        expect(item).to.be.ok()
        expect((item :: VaultItem).id).to.equal(2)
    end)

end
