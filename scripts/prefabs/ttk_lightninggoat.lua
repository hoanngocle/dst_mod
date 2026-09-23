local assets =
{
    Asset("ANIM", "anim/lightning_goat_build.zip"),
    Asset("ANIM", "anim/lightning_goat_shocked_build.zip"),
    Asset("ANIM", "anim/lightning_goat_basic.zip"),
    Asset("ANIM", "anim/lightning_goat_actions.zip"),
    Asset("SOUND", "sound/lightninggoat.fsb"),
    Asset("ANIM", "anim/ttk_lightning_goat.zip"),
}

local prefabs =
{
    "meat",
    "lightninggoathorn",
    "goatmilk",
}

local brain = require("brains/ttk_beefalobrain")

SetSharedLootTable( 'ttk_lightninggoat',
{
    {'meat',              1.00},
})

local function KeepTarget(inst, target)
    return false
end

local function OnAttacked(inst, data)
end

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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1.75, .75)

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 100, .5)

    inst.AnimState:SetBank("lightning_goat")
    inst.AnimState:SetBuild("xd_lightning_goat")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:Hide("fx")

    inst:AddTag("lightninggoat")
    inst:AddTag("animal")
    inst:AddTag("lightningrod")
    inst:AddTag("companion")
	inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("no_dtexp")
    inst:AddTag("no_drop_xdlingshi")

    inst:SetPrefabNameOverride("lightninggoat")

    inst.Light:Enable(false)
    inst.Light:SetRadius(.85)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(255 / 255, 255 / 255, 236 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1400)

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.LIGHTNING_GOAT_DAMAGE)
    inst.components.combat:SetRange(TUNING.LIGHTNING_GOAT_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "lightning_goat_body"
    inst.components.combat:SetAttackPeriod(TUNING.LIGHTNING_GOAT_ATTACK_PERIOD)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/lightninggoat/hurt")
    inst.components.combat:SetKeepTargetFunction(KeepTarget)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper.sleeptestfn = ShouldSleep
    inst.components.sleeper.waketestfn = ShouldWakeUp

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ttk_lightninggoat')

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("timer")

    MakeMediumBurnableCharacter(inst, "lightning_goat_body")
    MakeMediumFreezableCharacter(inst, "lightning_goat_body")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.LIGHTNING_GOAT_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.LIGHTNING_GOAT_RUN_SPEED-2

    MakeHauntablePanic(inst)

    inst:SetStateGraph("SGttk_lightninggoat")
    inst:SetBrain(brain)

    return inst
end

return Prefab("ttk_lightninggoat", fn, assets, prefabs)
