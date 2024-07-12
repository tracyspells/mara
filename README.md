<div align="center">

# mara

</div>
---

_Mara_ is a lightweight state container that allows you to write simple code to manage state in Roblox.
It is inspired by [Reflex](https://littensy.github.io/reflex/), [Valtio](https://valtio.pmnd.rs/) and [Fusion](https://elttob.uk/Fusion/0.2/).

## 📦 Installation

You can install Mara on [Wally](https://wally.run/package/tracyspells/mara).

Alternatively, you can check out the latest [GitHub Release](https://github.com/tracyspells/mara/releases) to download the `.rbxm` file.

## ⚡️ Quick Start

[Take me to the documentation →](https://tracyspells.github.io/mara)

### 📃 Create Documents

Mara uses [documents](https://tracyspells.github.io/mara/reference/create-document/document/), containers that hold state.

```lua
local Mara = require(ReplicatedStorage.Packages.Mara)

local createDocument = Mara.createDocument

type Document<Contents> = Mara.Document<Contents>

type Contents = {
    a: number,
    b: boolean
}

local document = createDocument({
    a = 0,
    b = false
}) :: Document<Contents>
```

### 🌎 Use your documents anywhere

Mara was designed to make managing state simple and straightforward. Make edits to your document, and watch for changes!

```lua
local watch = Mara.watch

local function selectA(contents: Contents)
    return contents.a
end

watch(document, selectA, function(a: number)
    print(a)
end)

document:edit(function(contents: Contents)
    contents.a += 1
end)
```

---

## 📝 License

This project is under the [MIT license](LICENSE.md).
