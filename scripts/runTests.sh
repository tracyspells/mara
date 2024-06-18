rojo build test.project.json -o test.rbxl

run-in-roblox --place test.rbxl --script test/runTests.server.luau

rm test.rbxl