---
title: How to subscribe to document changes
description: A guide on how to listen for changes to a document's contents in Mara.
---

To keep track of changes to a document's contents, we can use `:changed()`:

```lua showLineNumbers
local timer = require(ReplicatedStorage.Documents.Timer)

timer:changed(function(timeLeft: number)
    print("Time left: ", timeLeft, " seconds")
end)

-- Let's update our timer!
timer:edit(function(timeLeft: number)
    return timeLeft - 1
end)
```

`:changed()` returns a [`RBXScriptConnection`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) like object, so if you wish to stop listening to changes, call `:Disconnect()`.

```lua showLineNumbers
local connection: Connection
connection = timer:changed(function(timeLeft: number)
    -- The print statement below will not run.
    print("Time left: ", timeLeft, " seconds")
end)

connection:Disconnect()

-- Let's update our timer!
timer:edit(function(timeLeft: number)
    return timeLeft - 1
end)
```

But what happens if you want more control when listening to document changes?

## Predicates

Predicates are useful because they allow you to run conditional side effects.

Let's take our `timer` document and add a predicate that checks when the timer reaches zero.

```lua showLineNumbers
local function reachedZero(timeLeft: number)
    return timeLeft <= 0
end

timer:changed(function(timeLeft: number)
    if not reachedZero(timeLeft) then
        return
    end

    print("Time's up!")
end)
```

## Selectors


