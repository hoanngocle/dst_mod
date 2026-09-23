
local assets =
{
    Asset("ANIM", "anim/beefalo_basic.zip"),
    Asset("ANIM", "anim/beefalo_actions.zip"),
    Asset("ANIM", "anim/beefalo_actions_domestic.zip"),
    Asset("ANIM", "anim/beefalo_actions_quirky.zip"),
    Asset("ANIM", "anim/beefalo_build.zip"),
    Asset("ANIM", "anim/beefalo_shaved_build.zip"),
    Asset("ANIM", "anim/beefalo_baby_build.zip"),

    Asset("ANIM", "anim/ttk_beefalo_antler.zip"),

    Asset("ANIM", "anim/beefalo_domesticated.zip"),
    Asset("ANIM", "anim/beefalo_personality_docile.zip"),
    Asset("ANIM", "anim/beefalo_personality_ornery.zip"),
    Asset("ANIM", "anim/beefalo_personality_pudgy.zip"),

    Asset("ANIM", "anim/beefalo_skin_change.zip"),

    Asset("ANIM", "anim/beefalo_carrat_idles.zip"),
    Asset("ANIM", "anim/yotc_carrat_colour_swaps.zip"),

    Asset("ANIM", "anim/beefalo_carry.zip"),

    Asset("ANIM", "anim/beefalo_fx.zip"),
    Asset("ANIM", "anim/poop_cloud.zip"),

    Asset("SOUND", "sound/beefalo.fsb"),

}

local prefabs =
{
    "meat",
}

local brain = require("brains/ttk_beefalobrain")

SetSharedLootTable( 'ttk_beefalo',
{
    {'meat',            1.00},
})

local sounds =
{
    walk = "dontstarve/beefalo/walk",
    grunt = "dontstarve/beefalo/grunt",
    yell = "dontstarve/beefalo/yell",
    swish = "dontstarve/beefalo/tail_swish",
    curious = "dontstarve/beefalo/curious",
    angry = "dontstarve/beefalo/angry",
    sleep = "dontstarve/beefalo/sleep",
}

local function KeepTarget(inst, target)
    return false
end
local function OnNewTarget(inst, data)
end

local function OnAttacked(inst, data)
end

local function ShouldBeg(inst)
    return false
end

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst)
end

local function MountSleepTest(inst)
    local home = inst.components.homeseeker and inst.components.homeseeker.home or nil
    if home and home:IsValid() then
        return false
    end
    return DefaultSleepTest(inst)
end

local function getbasebuild(inst)
    return (inst:HasTag("baby") and "beefalo_baby_build")
            or (not inst:HasTag("has_beard") and "beefalo_shaved_build")
            or "beefalo_build"
end

local function OnResetBeard(inst)
    inst:RemoveTag("has_beard")
    inst.sg:GoToState("shaved")
end

local function CanShaveTest(inst, shaver)
    return true 
end

local function OnShaved(inst)
    inst:ApplyBuildOverrides(inst.AnimState)
end

local function OnHairGrowth(inst)
    if inst.components.beard.bits == 0 then
        inst.hairGrowthPending = true
    end
end

local function ApplyBuildOverrides(inst, animstate)
    local basebuild = getbasebuild(inst)
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:AddOverrideBuild(basebuild)
    else
        animstate:SetBuild(basebuild)
    end

    if animstate == inst.AnimState then
        animstate:ClearOverrideBuild("beefalo_personality_docile")
    end
end

local function beefalo()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()

    inst.AnimState:SetBank("beefalo")
    inst.AnimState:SetBuild("beefalo_build")
    inst.AnimState:AddOverrideBuild("poop_cloud")
    inst.AnimState:AddOverrideBuild("beefalo_carrat_idles")
    inst.AnimState:AddOverrideBuild("xd_beefalo_antler")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("HEAT")

    inst:SetPrefabNameOverride("beefalo")

    inst.MiniMapEntity:SetIcon("beefalo_domesticated.png")
    inst.MiniMapEntity:SetEnabled(false)

    inst:AddTag("beefalo")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
    inst:AddTag("companion")
	inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("no_dtexp")
    inst:AddTag("no_drop_xdlingshi")

    inst.sounds = sounds

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("bloomer")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.DEFAULT)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1800)
    inst.components.health.nofadeout = true
    inst.components.health:StartRegen(TUNING.BEEFALO_HEALTH_REGEN, TUNING.BEEFALO_HEALTH_REGEN_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ttk_beefalo')

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    MakeLargeBurnableCharacter(inst, "beefalo_body")
    MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BEEFALO_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BEEFALO_RUN_SPEED.DEFAULT

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.sleeptestfn = MountSleepTest
    inst.components.sleeper.waketestfn = ShouldWakeUp

    inst:AddComponent("timer")
    
    MakeHauntablePanic(inst)

    inst.ApplyBuildOverrides = ApplyBuildOverrides

    inst:SetBrain(brain)
    inst:SetStateGraph("SGttk_beefalo")

    return inst
end

return Prefab("ttk_beefalo", beefalo, assets, prefabs)