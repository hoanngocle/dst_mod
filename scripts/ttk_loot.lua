local defs = require("ttk_defs")
local rules = require("ttk_enemy_rules")

local function OnPreHealthSetVal(inst, data)
    if inst._ttk_death_paid
        and data ~= nil
        and type(data.old_health) == "number"
        and type(data.val) == "number"
        and data.old_health <= 0
        and data.val > 0
    then
        inst._ttk_death_paid = nil
    end
end

local function WatchForResurrection(inst)
    if not inst._ttk_resurrection_watch then
        inst._ttk_resurrection_watch = true
        inst:ListenForEvent("pre_health_setval", OnPreHealthSetVal)
    end
end

local function SpawnReward(inst, prefab, count)
    local lootdropper = inst.components ~= nil and inst.components.lootdropper or nil
    if lootdropper ~= nil then
        for _ = 1, count do
            lootdropper:SpawnLootPrefab(prefab)
        end
        return
    end

    if inst.Transform == nil then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    for _ = 1, count do
        local item = SpawnPrefab(prefab)
        if item ~= nil and item.Transform ~= nil then
            item.Transform:SetPosition(x, y, z)
        end
    end
end

local function OnEntityDeath(world, data)
    if data == nil or data.cause == "file_load" then
        return
    end

    local inst = data.inst
    if inst == nil or (inst.HasTag ~= nil and inst:HasTag("ttk_jitan_boss"))
        or inst._ttk_boss_managed or inst._ttk_boss_auxiliary or inst._ttk_death_paid then
        return
    end

    local kind = rules.Classify(inst)
    if kind == nil then
        return
    end

    inst._ttk_death_paid = true
    WatchForResurrection(inst)

    local prefab = kind == "boss" and "ttk_lingshi3" or "ttk_lingshi1"
    SpawnReward(inst, prefab, math.random(defs.drop_min, defs.drop_max))
end

local function Install(world)
    if world == nil or not world.ismastersim or world._ttk_loot_installed then
        return
    end

    world._ttk_loot_installed = true
    world:ListenForEvent("entity_death", OnEntityDeath)
end

return {
    Install = Install,
}
