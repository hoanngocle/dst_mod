local HH_UTILS = require("utils/hh_utils")
local brain = require("brains/hh_com_monster")

local assets = {
    Asset("ANIM", "anim/hh_beru_dungeon.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_basic.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_actions.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_block.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_fx.zip"),
    Asset("ANIM", "anim/lavaarena_beetletaur_break.zip"),
}

local function MakeBossPhysics(inst, mass, rad)
    local phys = inst.entity:AddPhysics()
    phys:SetMass(mass)
    phys:SetFriction(0.1)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.CHARACTERS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(rad, 1)
    return phys
end

local function RetargetFn(inst)
    return FindEntity(
        inst,
        14,
        function(guy)
            return guy and inst.components.combat:CanTarget(guy)
        end,
        {"_combat"},
        {"prey", "smallcreature", "INLIMBO"}
    )
end

local function KeepTargetFn(inst, target)
    if HH_UTILS:HasComponents(inst, "combat") and HH_UTILS:HasComponents(target, "combat") and
       HH_UTILS:NotIsDead(target) and
       inst.components.combat:CanTarget(target) and
       HH_UTILS:CanHitTarget(inst, target) then
        return true
    end
    return false
end

local function OnSleepTask(inst)
    if inst.components.commander then
        for _, soldier in ipairs(inst.components.commander:GetAllSoldiers()) do
            if soldier:IsAsleep() then
                soldier:Remove()
            end
        end
    end
    inst:Remove()
end

local function OnSleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
    end
    inst._sleeptask = not inst.components.health:IsDead() and inst:DoTaskInTime(10, OnSleepTask) or nil
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(3.5, 1.5)
    inst:SetPhysicsRadiusOverride(1.5)
    MakeBossPhysics(inst, 1000, inst.physicsradiusoverride)

    inst.AnimState:SetBank("beetletaur")
    inst.AnimState:SetBuild("hh_beru_dungeon")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.Transform:SetFourFaced()

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("epic")
    inst:AddTag("largecreature")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 7
    inst.components.locomotor.walkspeed = 7

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(50)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRange(4.5)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat.battlecryenabled = false
    inst.components.combat.forcefacing = false

    if not inst.components.hh_monster then
        inst:AddComponent("hh_monster")
    end
    if not inst.components.hh_buff then
        inst:AddComponent("hh_buff")
    end
    if not inst.hh_tags then
        inst.hh_tags = {}
    end
    inst.hh_tags["boss_monster"] = "Quái trùm"
    inst.HasHHTag = function(self, tag)
        return self.hh_tags and self.hh_tags[tag] ~= nil
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(600000)
    inst.components.health.fire_damage_scale = 0

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("pig_jump_cd", 7)
    inst.components.timer:StartTimer("pig_strong_cd", 27)
    inst.components.timer:StartTimer("pig_control_cd", 45)

    inst:AddComponent("grouptargeter")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("hh_treasure_monster")
    inst:AddComponent("planarentity")
    inst:AddComponent("planardamage")
    inst.components.planardamage:SetBaseDamage(30)

    inst:SetStateGraph("SGhh_beru_dungeon")
    inst:SetBrain(brain)
    inst.OnEntitySleep = OnSleep

    inst:ListenForEvent("attacked", function(inst, data)
        if not data or not data.attacker then return end
        local attacker = data.attacker
        if HH_UTILS:NotIsDead(attacker) and HH_UTILS:NotIsDead(inst) and HH_UTILS:HasComponents(attacker, "combat") and HH_UTILS:CanHitTarget(inst, attacker) then
            inst.components.combat:SetTarget(attacker)
        end
    end)
    inst:ListenForEvent("death", function(inst)
        inst:AddTag("NOCLICK")
        if inst.components.health then
            inst.components.health.nofadeout = true
        end
    end)

    return inst
end

return Prefab("hh_beru_dungeon", fn, assets)
