local brain = require "brains/ttk_beefalobrain"

local assets =
{
    Asset("ANIM", "anim/koalefant_basic.zip"),
    Asset("ANIM", "anim/koalefant_actions.zip"),
    
    Asset("ANIM", "anim/ttk_koalefant.zip"),
    Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs =
{
    "meat",
    "trunk_summer",
    "trunk_winter",
}

local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst)
end

local function ShouldSleep(inst)
    local home = inst.components.homeseeker and inst.components.homeseeker.home or nil
    if home and home:IsValid() then
        return false
    end
    return DefaultSleepTest(inst)
end

local function KeepTarget(inst, target)
    return false
end

local function OnAttacked(inst, data)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .75)

    inst.DynamicShadow:SetSize(4.5, 2)
    inst.Transform:SetSixFaced()

    inst:AddTag("koalefant")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
    inst:AddTag("companion")
	inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("no_dtexp")
    inst:AddTag("no_drop_xdlingshi")

    inst.AnimState:SetBank("koalefant")
    inst.AnimState:SetBuild("xd_koalefant")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:SetPrefabNameOverride("koalefant_summer")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "koalefant_body"
    inst.components.combat:SetDefaultDamage(TUNING.KOALEFANT_DAMAGE)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1800)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"meat"})

    inst:AddComponent("inspectable")

    MakeLargeBurnableCharacter(inst, "koalefant_body")
    MakeLargeFreezableCharacter(inst, "koalefant_body")

    MakeHauntablePanic(inst)

    inst:AddComponent("locomotor") 
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:SetBrain(brain)
    inst:SetStateGraph("SGttk_koalefant")
    return inst
end

return Prefab("ttk_koalefant", fn, assets, prefabs)
