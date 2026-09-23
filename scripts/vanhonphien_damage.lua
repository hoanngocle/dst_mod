-- Optional numeric carrier. No Solo module is imported or component created.
local M = { BASE = 20 }

local function RitualMultiplier(inst)
    return 1 + 0.05 * math.max(0, math.min(9, tonumber(inst._ttk_ritual_level) or 0))
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, entry in pairs(value) do result[key] = Copy(entry) end
    return result
end

function M.Install(inst)
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(M.BASE)
    -- This portable banner cannot deal a second direct hit.
    inst.components.weapon.GetDamage = function() return 0, nil end
end

local function GetBase(inst)
    if inst == nil or not inst:IsValid() then return M.BASE end
    local weapon = inst.components.weapon
    -- A deployed banner only holds a snapshot, not a Solo component. Reading
    -- the already-loaded module is optional detection, never an import.
    if weapon == nil and inst._ttk_banner_strengthen ~= nil
        and package.loaded["components/wb_strengthen"] == nil then
        return M.BASE
    end
    local damage = weapon ~= nil and weapon.damage or inst._ttk_banner_damage
    return type(damage) == "number" and math.max(0, damage) or M.BASE
end

function M.Get(inst)
    return GetBase(inst) * RitualMultiplier(inst)
end

function M.Save(inst, data)
    data.banner_damage = inst.components.weapon ~= nil and GetBase(inst)
        or inst._ttk_banner_damage or M.BASE
    data.ttk_ritual_level = inst._ttk_ritual_level or 0
    local strengthen = inst.components.wb_strengthen
    local weapon = inst.components.weapon
    local callbacks = weapon ~= nil and weapon.__onattackfn_map or nil
    data.banner_attack_buffs = Copy(inst._ttk_banner_attack_buffs)
    if callbacks ~= nil then
        data.banner_attack_buffs = {}
        for id in pairs(callbacks) do data.banner_attack_buffs[id] = true end
    end
    data.banner_strengthen = Copy(strengthen ~= nil and strengthen:OnSave()
        or inst._ttk_banner_strengthen)
end

function M.Restore(inst)
    local strengthen = inst.components.wb_strengthen
    if strengthen ~= nil and inst._ttk_banner_strengthen ~= nil then
        -- Engine component loading may already have restored this item.
        if (strengthen.level or 0) == 0 then
            strengthen:OnLoad(Copy(inst._ttk_banner_strengthen))
        end
        inst._ttk_banner_strengthen = nil
    end
end

function M.Load(inst, data)
    inst._ttk_banner_damage = tonumber(data.banner_damage) or M.BASE
    inst._ttk_ritual_level = math.max(0, math.min(9, tonumber(data.ttk_ritual_level) or 0))
    inst._ttk_banner_strengthen = Copy(data.banner_strengthen)
    inst._ttk_banner_attack_buffs = Copy(data.banner_attack_buffs)
    if inst.components.weapon ~= nil then
        -- Leave the native base at 20; Solo recalculates from its saved level.
        -- Keep the snapshot while Solo is disabled so re-enabling it is safe.
        inst:DoTaskInTime(0, M.Restore)
    end
end


function M.SetRitualLevel(inst, level)
    inst._ttk_ritual_level = math.max(0, math.min(9, tonumber(level) or 0))
end

return M
