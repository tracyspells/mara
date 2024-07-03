---
title: watch
description: Manage documents in Mara.
---

`Mara.watch()` allows you to watch for changes in a document's contents. In addition to this, the `listener` callback is called with the initial contents as an argument.

```lua showLineNumbers
local watch = Mara.watch
local createDocument = Mara.createDocument

local document = createDocument({ a = 0 })

local function selectA(contents): number
    return contents.a
end

watch(document, selectA, function(contents)
    print(contents)
end)

document:edit(function(contents)
    contents.a += 1
end)
```

```lua
--> 0 
--> 1
```

You may optionally pass a predicate function to `watch` to only listen for changes that match a certain condition. If the predicate is provided, the listener will only be called if the predicate returns true.

```lua showLineNumbers
local watch = Mara.watch
local createDocument = Mara.createDocument

local document = createDocument({ a = 0 })

local function selectA(contents): number
    return contents.a
end

local function isEven(contents)
    return contents.a % 2 == 0
end

watch(document, selectA, isEven, function(a: number)
    print(a)
end)

document:edit(function(contents)
    contents.a += 1
end)

document:edit(function(contents)
    contents.a += 1
end)

document:edit(function(contents)
    contents.a += 1
end)
```

```lua
--> 0 
--> 1
```

#### Parameters

- `selector` - A function that selects a specific part of your state. If not provided, the entire state is returned
- `predicate` - A function that runs conditional side effects. If the predicate returns true, `listener` is called

#### Returns

A [`RBXScriptConnection`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) like object.

---
