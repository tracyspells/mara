curl -o scripts/roblox.d.luau https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau

rojo sourcemap default.project.json -o sourcemap.json

luau-lsp analyze --defs=test/testez.d.luau --defs=scripts/roblox.d.luau --sourcemap=sourcemap.json --ignore="**/_Index/**" --no-strict-dm-types lib

selene lib
stylua --check lib

rm scripts/roblox.d.luau