local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)

local utils = script.Parent.Parent.utils
local isStrictTable = require(utils.isStrictTable)
local applyDifference = require(script.Parent.Parent.utils.applyDifference)

local IS_CLIENT = RunService:IsClient()
local IS_TESTING = RunService:IsStudio() and RunService:IsRunning()

local ERROR_MESSAGES = {
    Initialize = "'Mara.getImporter()' must be called from the client!",
    Documents = [[
        The 'documents' argument in 'Mara.getImporter()' must be a map of documents!
        (i.e. { [string]: Document<any> })
    ]]
}

type Importer = types.Importer
type DocumentMap = types.DocumentMap

type Dictionary<K, V> = types.Dictionary<K, V>

local function importer(documents: DocumentMap): Importer
    if not isStrictTable(documents) then
        error(ERROR_MESSAGES.Documents)
    end

    if not IS_TESTING and not IS_CLIENT then
        error(ERROR_MESSAGES.Initialize)
    end

    local self = {} :: Importer

    function self:import(payload)
        local contents = payload.contents
        local payloadType = payload.type

        for name, document in documents do
            local result

            if payloadType == "full" then
                result = contents[name]
            else
                result = applyDifference(document:read(), contents[name])
            end

            if result then
                document:setContents(result)   
            end
        end
    end

    return self
end

return importer
