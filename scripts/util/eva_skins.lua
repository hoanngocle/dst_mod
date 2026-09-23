local EvaSkins = {}

local CHARACTER = "eva"
local DEFAULT_SKIN = "eva_none"
local INSTALL_GUARD = "__PHAM_NHAN_EVA_SKINS_INSTALLED"

local function Pack(...)
    return {n = select("#", ...), ...}
end

local function ReturnOrRaise(results)
    if not results[1] then error(results[2], 0) end
    return unpack(results, 2, results.n)
end

local function AddUnique(items, value)
    for _, current in ipairs(items) do
        if current == value then return end
    end
    table.insert(items, value)
end

local function RegisterMetadata(G)
    G.PREFAB_SKINS[CHARACTER] = G.PREFAB_SKINS[CHARACTER] or {}
    AddUnique(G.PREFAB_SKINS[CHARACTER], DEFAULT_SKIN)

    G.PREFAB_SKINS_IDS[CHARACTER] = G.PREFAB_SKINS_IDS[CHARACTER] or {}
    for index, name in ipairs(G.PREFAB_SKINS[CHARACTER]) do
        G.PREFAB_SKINS_IDS[CHARACTER][name] = index
    end

end

local function InstallLoadout(G, require_fn)
    local LoadoutSelect = require_fn("widgets/redux/loadoutselect")
    local Constructor = LoadoutSelect._ctor
    if Constructor == nil then return end

    LoadoutSelect._ctor = function(self, ...)
        local _, character = ...
        if character ~= CHARACTER then
            return Constructor(self, ...)
        end

        local Contains = G.table.contains
        G.table.contains = function(items, value, ...)
            if items == G.DST_CHARACTERLIST and value == CHARACTER then
                return true
            end
            return Contains(items, value, ...)
        end
        local results = Pack(pcall(Constructor, self, ...))
        G.table.contains = Contains
        return ReturnOrRaise(results)
    end
end

local function InstallServerValidation(G)
    local Validate = G.ValidateSpawnPrefabRequest
    local ExceptionArrays = G.ExceptionArrays
    if Validate == nil or ExceptionArrays == nil then return end

    G.ValidateSpawnPrefabRequest = function(user_id, prefab_name, ...)
        if prefab_name ~= CHARACTER then
            return Validate(user_id, prefab_name, ...)
        end

        G.ExceptionArrays = function(items, exceptions, ...)
            local result = ExceptionArrays(items, exceptions, ...)
            if items ~= G.DST_CHARACTERLIST then return result end
            local copy = {}
            for _, value in ipairs(result) do table.insert(copy, value) end
            AddUnique(copy, CHARACTER)
            return copy
        end
        local results = Pack(pcall(Validate, user_id, prefab_name, ...))
        G.ExceptionArrays = ExceptionArrays
        return ReturnOrRaise(results)
    end
end

function EvaSkins.Install(env)
    local G = env.GLOBAL
    RegisterMetadata(G)
    if rawget(G, INSTALL_GUARD) then return end
    rawset(G, INSTALL_GUARD, true)

    InstallServerValidation(G)

    local dedicated = G.TheNet ~= nil and G.TheNet.IsDedicated ~= nil
        and G.TheNet:IsDedicated()
    if not dedicated then
        InstallLoadout(G, env.require or require)
    end
end

return EvaSkins
