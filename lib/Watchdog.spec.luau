return function()
	local Watchdog = require(script.Parent.Watchdog)
	local watchdog

	beforeEach(function()
		watchdog = Watchdog.new()
	end)

	afterEach(function()
		watchdog:sleep()
		watchdog = nil :: never
	end)

	it("should observe subjects", function()
		local MAX_SUBJECTS = 5
		local numberOfSubjectsBeingObserved = 0

		for _ = 1, MAX_SUBJECTS do
			watchdog:observe(function()
				numberOfSubjectsBeingObserved += 1
			end)
		end

		watchdog:bark()

		expect(numberOfSubjectsBeingObserved).to.equal(MAX_SUBJECTS)
	end)

	it("should observe a subject only once", function()
		local count = 0
		watchdog:observeOnce(function()
			count += 1
		end)

		watchdog:bark()
		watchdog:bark()
		watchdog:bark()

		expect(count).to.equal(1)
	end)

	it("should scare subjects off with acidic saliva", function()
		local salivaContents: { any }

		watchdog:observe(function(...: any)
			salivaContents = { ... }
		end)

		watchdog:bark("Hey", "You", "Stink", 9000, false)

		expect(salivaContents[1]).to.equal("Hey")
		expect(salivaContents[2]).to.equal("You")
		expect(salivaContents[3]).to.equal("Stink")
		expect(salivaContents[4]).to.equal(9000)
		expect(salivaContents[5]).to.equal(false)
	end)

	it("shouldn't bark at non-subjects", function()
		local wasGuyAScared = false
		local wasGirlBScared = false
		local wasBabyCScared = false

		watchdog:observe(function()
			wasGuyAScared = true
		end)

		watchdog:observe(function()
			wasGirlBScared = true
		end)()

		watchdog:observeOnce(function()
			wasBabyCScared = true
		end)()

		watchdog:bark()

		expect(wasGuyAScared).to.equal(true)
		expect(wasGirlBScared).to.equal(false)
		expect(wasBabyCScared).to.equal(false)
	end)

	it("shouldn't bark while sleeping", function()
		local sleepCount = 0
		watchdog:observe(function()
			sleepCount += 1
		end)

		watchdog:bark()
		watchdog:sleep()
		watchdog:bark()

		expect(sleepCount).to.equal(1)
	end)
end
