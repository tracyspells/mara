---
title: Quick Start
description: Get started with the basics of Mara.
---

_Mara_ is a lightweight state container that allows you to write simple code to manage state in Roblox.
It is inspired by [Reflex](https://littensy.github.io/reflex/), [Valtio](https://valtio.pmnd.rs/) and [Fusion](https://elttob.uk/Fusion/0.2/).

## Installation
_Mara_ is available on [Wally](https://wally.run/package/tracyspells/mara).

```toml title = "wally.toml"
[dependencies]
Mara = "tracyspells/mara@2.2.0"
```

Alternatively, you can check out the latest [GitHub Release](https://github.com/tracyspells/mara/releases) to download the `.rbxm` file.

## Get started
Once you've installed Mara, you're good to go! All you need to do is make a document:

```lua showLineNumbers
local Mara = require(ReplicatedStorage.Packages.Mara)

local createDocument = Mara.createDocument

type Document<Contents> = Mara.Document<Contents>

type Contents = {
    a: number,
}

local contents: Contents = {
    a = 0
}

local document = createDocument(contents) :: Document<Contents>
```

## Easy to modify
Mara was designed to make managing state easy and straightforward. No need to worry about actions, producers or middlewares — just edit your document contents!

```lua showLineNumbers
document:edit(function(contents: Contents)
    contents.a += 1
end)

watch(document, function(contents: Contents)
    return contents.a
end, function(number: number)
    print("The letter a has the number "..number.."!")
end)
```

## Use your documents anywhere
_Mara_ is unopinionated when it comes to document organization. Do what you think best suits your needs!

```lua showLineNumbers
local timer = require(ReplicatedStorage.Documents.Timer)

-- Let's update our timer!
timer:edit(function(timeLeft: number)
    return timeLeft - 1
end)
```