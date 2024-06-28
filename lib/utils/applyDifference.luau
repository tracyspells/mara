local None = require(script.Parent.None)

local copy = table.clone

local function applyDifference(base: any, difference: any): any
    if typeof(difference) == "table" and difference == None then
        return nil
    elseif typeof(base) ~= "table" or typeof(difference) ~= "table" then
        return difference
    end

    local clone = copy(base)

    for key, value in difference do
        clone[key] = applyDifference(base[key], value)
    end

    return clone
end

return applyDifference
