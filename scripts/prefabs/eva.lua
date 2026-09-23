local MakePlayerCharacter = require "prefabs/player_common"
local EvaWingsInput = require "util/eva_wings_input"
local EvaSkillPanel = require "util/eva_skillpanel"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local start_inv = {}
for mode, items in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(mode)] = items.EVA
end
local prefabs = FlattenTree(start_inv, true)
table.insert(prefabs, "spear_wathgrithr_lightning_lunge_fx")

local function onbecamehuman(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(
        inst,
        "eva_speed_mod",
        TUNING.EVA_SPEED
    )
end

local function onbecameghost(inst)
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "eva_speed_mod")
end

local function IsValidVictim(victim)
    return victim ~= nil
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile"))
            or victim:HasTag("veggie")
            or victim:HasTag("structure")
            or victim:HasTag("wall")
            or victim:HasTag("balloon")
            or victim:HasTag("groundspike")
            or victim:HasTag("smashable")
            or victim:HasTag("companion"))
end

local function onKilled(inst, data)
    local victim = data ~= nil and data.victim or nil
    local souls = inst.components.eva_souls
    if souls == nil or not IsValidVictim(victim) then
        return
    end

    if victim:HasTag("ghost") then
        souls:DoDelta(10)
    elseif victim:HasTag("epic") then
        souls:DoDelta(30)
    else
        souls:DoDelta(1)
    end
end

local function RemoveSkillBook(inst)
    inst._eva_removing_skillbook = true
    local book = inst._eva_skillbook_entity
    inst._eva_skillbook_entity = nil
    if inst._eva_skillbook ~= nil then inst._eva_skillbook:set(nil) end
    if book ~= nil and book:IsValid() then book:Remove() end
end

local function EnsureSkillBook(inst)
    local book = inst._eva_skillbook_entity
    if book ~= nil and book:IsValid() then
        inst._eva_skillbook:set(book)
        return book
    end
    inst._eva_removing_skillbook = false
    book = SpawnPrefab("eva_skillbook")
    if book == nil or book.BindToOwner == nil then return nil end
    inst._eva_skillbook_entity = book
    book:BindToOwner(inst)
    inst._eva_skillbook:set(book)
    book:ListenForEvent("onremove", function()
        if inst._eva_skillbook_entity == book then
            inst._eva_skillbook_entity = nil
            inst._eva_skillbook:set(nil)
            if not inst._eva_removing_skillbook and inst:IsValid() then
                inst:DoTaskInTime(0, EnsureSkillBook)
            end
        end
    end)
    return book
end

local function OnLoad(inst)
    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
    inst:DoTaskInTime(0, EnsureSkillBook)
end

local common_postinit = function(inst)
    inst.MiniMapEntity:SetIcon("eva.tex")
    inst:AddTag("eva")
    inst._eva_wings_active = net_bool(inst.GUID, "eva_wings.active", "eva_wingsdirty")
    inst._eva_skillbook = net_entity(inst.GUID, "eva_skillbook.entity", "eva_skillbookdirty")
    inst._eva_skill_cd_life = net_byte(inst.GUID, "eva_skill.life_cd", "eva_skilldirty")
    inst._eva_skill_cd_array = net_byte(inst.GUID, "eva_skill.array_cd", "eva_skilldirty")
    inst._eva_skill_cd_harvest = net_byte(inst.GUID, "eva_skill.harvest_cd", "eva_skilldirty")
    inst._eva_skill_cd_daydu = net_byte(inst.GUID, "eva_skill.daydu_cd", "eva_skilldirty")
    inst._eva_skill_cd_fox = net_byte(inst.GUID, "eva_skill.fox_cd", "eva_skilldirty")
    if not TheWorld.ismastersim then
        EvaWingsInput.InstallReplica(inst)
    end
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    inst.soundsname = "wendy"

    if TUNING.EVA_HIDDEN == true then
        inst:ListenForEvent("equip", function()
            inst.AnimState:ClearOverrideSymbol("swap_hat")
            inst.AnimState:Show("hair")
            inst.AnimState:ClearOverrideSymbol("swap_body")
            inst.AnimState:Show("body")
        end)
    end

    inst.components.hunger:SetMax(TUNING.EVA_HUNGER)
    inst.components.sanity:SetMax(TUNING.EVA_SANITY)
    inst.components.health:SetMaxHealth(TUNING.EVA_HEALTH)
    inst.components.combat.damagemultiplier = TUNING.EVA_DMG
    inst.components.hunger.hungerrate = TUNING.EVA_HUNGER_RATE * TUNING.WILSON_HUNGER_RATE
    inst.components.locomotor:SetExternalSpeedMultiplier(
        inst,
        "eva_speed_mod",
        TUNING.EVA_SPEED
    )

    inst:AddComponent("eva_life")
    inst:AddComponent("eva_wings")
    inst:AddComponent("eva_scythe_array")
    inst:AddComponent("eva_melee_wave")
    inst:AddComponent("eva_harvest")
    inst:AddComponent("eva_daydu")
    inst:AddComponent("eva_fox_blink")

    inst:DoTaskInTime(0, EnsureSkillBook)
    EvaSkillPanel.InstallReplication(inst)

    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)
    inst:ListenForEvent("killed", onKilled)
    inst:ListenForEvent("onremove", RemoveSkillBook)

    inst.OnLoad = OnLoad
    inst.OnNewSpawn = OnLoad
end

return MakePlayerCharacter("eva", prefabs, assets, common_postinit, master_postinit, prefabs)
