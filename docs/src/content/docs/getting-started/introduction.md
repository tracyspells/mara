---
title: Introduction
description: A brief introduction to Mara.
---

_Mara_ is a lightweight state container that allows you to write simple code to manage state in Roblox.
It is inspired by [Reflex](https://littensy.github.io/reflex/), [Valtio](https://valtio.pmnd.rs/) and [Fusion](https://elttob.uk/Fusion/0.2/).

## Why Mara?

Dealing with state should be simple and straightforward.

Working with state management libraries like [Rodux](https://roblox.github.io/rodux/), Reflex, and [Silo](https://sleitnick.github.io/RbxUtil/api/Silo/) was awesome! But having to make a new action, a reducer, or a middleware felt too tedious and time consuming.

Instead of following the Redux model like its peers, Mara steps away from it, and approaches state management in a different way.

In Mara, we create state containers called [documents](/mara/guides/your-first-document/):

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

And to modify our document's contents, we can do this:

```lua showLineNumbers
document:edit(function(contents: Contents)
    contents.a += 1
end)
```

It's simple, and it gets the job done. No need to worry about actions or reducers — just edit your document!
