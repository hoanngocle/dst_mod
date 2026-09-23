-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local brain = require("brains/ttk_boss_ziyunminionbrain")
local MINIONS =
{
    {
        name = "ttk_boss_minion1",
        bank = "stalker_minion",
        addbuild = "stalker_minion",
        build = "xd_minion",
        emergeimmunetime = 38 * FRAMES,
        emergeshadowtime = 81 * FRAMES,
        movestoptime = 6 * FRAMES,
        movespeed = 3,
    },
    {
        name = "ttk_boss_minion2",
        bank = "stalker_minion_2",
        addbuild = "stalker_minion_2",
        build = "xd_minion_2",
        emergeimmunetime = 40 * FRAMES,
        emergeshadowtime = 49 * FRAMES,
        movestarttime = 16 * FRAMES,
        movespeed = 1.5,
    },
}
local function OnSpawnedBy(inst, stalker,target)
    if stalker then
        inst.owner = stalker
        inst.target = target
        inst:ForceFacePoint(stalker.Transform:GetWorldPosition())
        inst.sg:GoToState("emerge")
    end
end
local function OnTimerDone(inst, data)
    if data.name == "lifetime" and not inst.components.health:IsDead() then
        inst.components.health:Kill()
    end
end
local AREA_EXCLUDE_TAGS = { "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }
local function DoDamage(inst)
    local pt = inst:GetPosition()
    inst.components.combat:DoAreaAttack(inst, 2.5, nil, nil, nil, AREA_EXCLUDE_TAGS)
end
local function MakeMinion(name, data, prefabs)
    local assets = data ~= nil and {
        Asset("ANIM", Boss.ArtPath("anim/stalker_shadow_build.zip")),
        Asset("ANIM", Boss.ArtPath("anim/"..data.build..".zip")),
        Asset("ANIM", Boss.ArtPath("anim/"..data.addbuild..".zip")),
    } or nil
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)
        inst.DynamicShadow:SetSize(1.5, 1)
        inst.Transform:SetSixFaced()
        local params = data
        if params == nil then
            params = MINIONS[math.random(#MINIONS)]
            inst:SetPrefabName(params.name)
        end
        inst.AnimState:SetBank(Boss.Art(params.bank))
        inst.AnimState:SetBuild(Boss.Art(params.addbuild))
        inst.AnimState:OverrideSymbol("fx_flames", "stalker_shadow_build", "fx_flames")
        inst.AnimState:OverrideSymbol("shield_minion", "stalker_shadow_build", "shield_minion")
        inst.AnimState:OverrideSymbol("fx_dark_minion", "stalker_shadow_build", "fx_dark_minion")
        inst.AnimState:PlayAnimation("idle", true)
        inst:AddTag("hostile")
        inst:AddTag("notraptrigger")
        inst:AddTag("ttk_boss_fb_item")
        inst:SetPrefabNameOverride("stalker_minion")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("inspectable")
        inst:AddComponent("locomotor")
        inst.components.locomotor.walkspeed = 14
        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(600)
        inst.components.health.nofadeout = true
        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(275)
        inst:AddComponent("timer")
        inst.components.timer:StartTimer("lifetime", 10)
        inst:ListenForEvent("timerdone", OnTimerDone)
        inst.emergeimmunetime = params.emergeimmunetime
        inst.emergeshadowtime = params.emergeshadowtime
        inst.movestarttime = params.movestarttime
        inst.movestoptime = params.movestoptime
        inst:SetStateGraph("SGttk_boss_minion")
        inst:SetBrain(brain)
        inst.OnSpawnedBy = OnSpawnedBy
        inst.DoDamage = DoDamage
        inst.persists = false
        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end
local ret = {}
local prefs = {}
for i, v in ipairs(MINIONS) do
    table.insert(prefs, v.name)
    table.insert(ret, MakeMinion(v.name, v))
end
table.insert(ret, MakeMinion("ttk_boss_fubenminion", nil, prefs))
prefs = nil
return unpack(ret)
