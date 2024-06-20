rojo build test/default.project.json -o test/build.rbxl

run-in-roblox --place test/build.rbxl --script test/src/runTests.server.luau

rm test/build.rbxl