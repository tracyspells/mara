---
title: How to organize your documents
description: A guide to how to organize documents in Mara.
---

## One Source of Truth

You can have one document be the source of truth:

```lua title = "document.luau" showLineNumbers
local createDocument = Mara.createDocument

local document = createDocument({
    playerData = {
        ["36898568"] = {
            coins = 5,
            exp = 10
        },

        ["12839345658"] = {
            coins = 30,
            exp = 0
        },
    },

    matchType = "Deathmatch",
    timeLeft = "2:39",
    scores = {
        red = 1,
        blue = 0,
    },
})

return document
```

## Combining Documents

..or you can create documents and combine them.

```lua title = "gameState.luau" showLineNumbers
local createDocument = Mara.createDocument

local gameState = {
    matchType = createDocument("Deathmatch"),
    timeLeft = createDocument("2:39"),
    scores = {
        red = createDocument(0),
        blue = createDocument(0),
    },

    playerData = {
        ["36898568"] = createDocument({
            coins = 5,
            exp = 10
        }),

        ["12839345658"] = createDocument({
            coins = 30,
            exp = 0
        }),
    }
}

return gameState
```

Mara is unopinionated when it comes to document organization. Do what you think best serves your needs!
