local counter = require(script.counter)

type SharedDocuments = {
    counter: counter.CounterDocument,
}

return {
    counter = counter,
} :: SharedDocuments
