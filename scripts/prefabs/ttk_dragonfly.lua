local brain = require("brains/ttk_drangonflybrain")
local houseutil = require("ttk_batch19_houseutil")
local TTK_CanAttackTarget = houseutil.CanAttackTarget
local TTK_GetDamageTargets = houseutil.GetDamageTargets
local SpawnAt = houseutil.SpawnAt

local assets =
{
    Asset("ANIM", "anim/dragonfly_build.zip"),
    Asset("ANIM", "anim/dragonfly_fire_build.zip"),
    Asset("ANIM", "anim/dragonfly_basic.zip"),
    Asset("ANIM", "anim/dragonfly_actions.zip"),
    Asset("ANIM", "anim/dragonfly_yule_build.zip"),
    Asset("ANIM", "anim/dragonfly_fire_yule_build.zip"),
    Asset("SOUND", "sound/dragonfly.fsb"),
}

local prefabs =
{
    "firesplash_fx",
    "tauntfire_fx",
    "attackfire_fx",
    "vomitfire_fx",
    "firering_fx",

    "dragon_scales",
    "lavae_egg",
    "meat",
    "goldnugget",
    "redgem",
    "bluegem",
    "purplegem",
    "orangegem",
    "yellowgem",
    "greengem",
}

SetSharedLootTable('ttk_dragonfly',
{
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             1.00},
})

local function heal(inst)
    if not (inst.components.homeseeker and inst.components.homeseeker.home and 
        inst.components.homeseeker.home:IsValid() and inst:IsNear(inst.components.homeseeker.home,8)) then
        return
    end
    if not inst.components.health:IsDead() and inst.components.health:IsHurt() then
        inst.components.health:DoDelta(inst.components.health.maxhealth*0.02)
    end
end

local function TransformNormal(inst) 
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_yule_build" or "dragonfly_build")
    inst.enraged = false
    inst.Light:Enable(false)
    inst.SoundEmitter:KillSound("fireflying")
    if not inst.heal_task then
        inst.heal_task = inst:DoPeriodicTask(10,heal,10)
    end
end

local function TransformFire(inst) 
    SpawnAt("firesplash_fx",inst)
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_fire_yule_build" or "dragonfly_fire_build")
    inst.enraged = true
    if not inst.components.timer:TimerExists("groundpound_cd") then
        inst.components.timer:StartTimer("groundpound_cd", math.random(3,6))
    end
    
    inst.can_ground_pound = false
    inst.Light:Enable(true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/firedup", "fireflying")

    if inst.heal_task then
        inst.heal_task:Cancel()
        inst.heal_task = nil
    end
end

local function OnNewTarget(inst, data) 
    if not inst.enraged then
        TransformFire(inst)
    end
end

local function OnDropTarget(inst)
    if inst.enraged then
        TransformNormal(inst)
    end
end

local nottags = {"abigail","companion","player","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
if TheNet:GetPVPEnabled() then
    nottags =  {"INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
end
local function RetargetFn(inst) 
    local owner = inst.components.follower and inst.components.follower.leader or nil
    return owner ~= nil and FindEntity(inst, 10,
        function(guy)
            return owner:IsValid() and TTK_CanAttackTarget(inst,guy)
                and (guy.components.combat:TargetIs(owner) or
                owner.components.combat:TargetIs(guy) or
                guy.components.combat:TargetIs(inst) )
        end,
        { "_combat","_health" }, 
        nottags
    ) or nil
end

local function KeepTargetFn(inst, target) 
    if inst:IsValid() and inst.components.follower.leader and inst.components.follower.leader:IsValid() then
        return inst.components.follower:IsNearLeader(12) and target:IsValid()
        and target:IsNear(inst.components.follower.leader,20)
            and inst.components.combat:CanTarget(target)
    elseif inst:IsValid() and inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return inst:IsNear(inst.components.homeseeker.home,16) and 
            target:IsValid()
            and inst.components.combat:CanTarget(target)
    else 
        return target:IsValid() and inst.components.combat:CanTarget(target)
    end
end

local function OnLoad(inst, data)
    houseutil.LoadOwner(inst, data)
    if inst._ttk_tamed and inst.components.lootdropper ~= nil then
        inst.components.lootdropper:SetChanceLootTable(nil)
    end
end

local function OnTimerDone(inst, data)
    if data.name == "groundpound_cd" then 
        inst.can_ground_pound = true
    end
end

local function isplayerattack(inst)
    return inst:HasTag("player")
    or (inst.owner and inst.owner:HasTag("player"))
    or (inst.components.follower and inst.components.follower.leader and inst.components.follower.leader:HasTag("player"))
end

local function OnAttacked(inst, data)
    if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    if data.attacker ~= nil and data.attacker:IsValid() then
        if isplayerattack(data.attacker) then
            
            inst.runaway_target = data.attacker
            inst.last_runaway_time = GetTime()
        else
            inst.components.combat:SetTarget(data.attacker)
        end
    end
end

local function IsLeaderSleeping(inst)
    return inst.components.follower.leader and inst.components.follower.leader:HasTag("sleeping")
end
local SLEEP_NEAR_LEADER_DISTANCE = 6
local WAKE_TO_FOLLOW_DISTANCE = 8
local function ShouldSleep(inst) 
    local target = inst.components.combat.target
    if target  then
        return false
    end
    if inst.components.follower.leader and inst.components.follower.leader:IsValid() then 
        return (DefaultSleepTest(inst)
        or IsLeaderSleeping(inst))
        and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE)
    elseif inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return false
    else
        return DefaultSleepTest(inst)
    end
end

local function ShouldWake(inst)
    if inst.components.follower.leader and inst.components.follower.leader:IsValid() then 
        return (DefaultWakeTest(inst) and not IsLeaderSleeping(inst)) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
    elseif inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return true
    else
        return DefaultWakeTest(inst)
    end
end

local function DoAoe(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TTK_GetDamageTargets(x, y, z, 8)
    for i,v in pairs(ents) do
        if  v:IsValid() and TTK_CanAttackTarget(inst,v) then
            local damage = 50
            v.components.combat:GetAttacked(inst,damage)
            inst:PushEvent("onareaattackother", { target = v})
        end
    end
end

local function ShouldAcceptItem(inst, item)
    return item.prefab == "dragon_scales"
end

local function OnGetItemFromPlayer(inst, giver, item)
    if giver == nil or giver.components == nil then
        return
    end
    if inst.components.follower and inst.components.follower.leader then
        if giver == inst.components.follower.leader then
            inst.components.follower:AddLoyaltyTime(2*480)
            inst.components.follower.maxfollowtime = 2*480
        end
    elseif giver.components.leader ~= nil then
        giver.components.leader:AddFollower(inst)
        inst.components.follower:AddLoyaltyTime(2*480)
        inst.components.follower.maxfollowtime =2*480
    end
    houseutil.SetOwner(inst, giver)
    inst._ttk_tamed = true
    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:SetChanceLootTable(nil)
    end
end

local function OnRefuseItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(5.5, 3.2)
    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(0.975, 0.975, 0.975)

    MakeFlyingGiantCharacterPhysics(inst, 500, 1.4)

    inst.AnimState:SetBank("dragonfly")
    inst.AnimState:SetBuild(IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "dragonfly_yule_build" or "dragonfly_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst:SetPrefabNameOverride("drangonfly")

    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("companion")
	inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("no_dtexp")
    inst:AddTag("no_drop_xdlingshi")

    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(235/255, 121/255, 12/255)

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    local combat = inst:AddComponent("combat")
    local health = inst:AddComponent("health")
    local inspectable = inst:AddComponent("inspectable")
    inst:AddComponent("inventory")
    inst:AddComponent("knownlocations")
    local lootdropper = inst:AddComponent("lootdropper")
    local locomotor = inst:AddComponent("locomotor")
    local sleeper = inst:AddComponent("sleeper")
    local groundpounder = inst:AddComponent("groundpounder")

    inst:AddComponent("timer")

    inst:SetStateGraph("SGttk_dragonfly")
    inst:SetBrain(brain)

    combat:SetDefaultDamage(150)
    combat:SetAttackPeriod(3)
    combat.playerdamagepercent = 0.5
    combat:SetRange(6, 6)
    combat:SetRetargetFunction(1.5, RetargetFn)
    combat:SetKeepTargetFunction(KeepTargetFn)
    combat.battlecryenabled = false
    combat.hiteffectsymbol = "dragonfly_body"
    combat:SetHurtSound("dontstarve_DLC001/creatures/dragonfly/hurt")

    groundpounder:UseRingMode()
    groundpounder.numRings = 3
    groundpounder.initialRadius = 1.5
    groundpounder.radiusStepDistance = 2
    groundpounder.ringWidth = 2
    groundpounder.damageRings = 2
    groundpounder.destructionRings = 3
    groundpounder.platformPushingRings = 3
    groundpounder.fxRings = 2
    groundpounder.fxRadiusOffset = 1.5
    groundpounder.burner = true
    groundpounder.groundpoundfx = "firesplash_fx"
    groundpounder.groundpounddamagemult = 0.5
    groundpounder.groundpoundringfx = "firering_fx"

    health:SetMaxHealth(23500)
    health.nofadeout = true 
    health.fire_damage_scale = 0 

    inspectable:RecordViews()

    lootdropper:SetChanceLootTable("ttk_dragonfly")

    locomotor:EnableGroundSpeedMultiplier(false)
    locomotor:SetTriggersCreep(false)
    locomotor.pathcaps = { ignorewalls = true, allowocean = true }
    locomotor.walkspeed = 5

    sleeper:SetResistance(4)
    sleeper:SetSleepTest(ShouldSleep)
    sleeper:SetWakeTest(ShouldWake)
    sleeper.diminishingreturns = true

    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = 2*480
    inst:AddComponent("homeseeker")

    inst:ListenForEvent("loseloyalty",function()
        if inst:IsValid() and not inst.components.health:IsDead() then
            local home = inst.components.homeseeker and inst.components.homeseeker.home or nil
            if home and home:IsValid() and not inst:IsNear(home,8) and home.components.childspawner ~= nil then
                SpawnAt("statue_transition", inst)
               home.components.childspawner:GoHome(inst)
            end
        end
    end)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.acceptnontradable = true

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("droppedtarget", OnDropTarget)
    inst:ListenForEvent("timerdone", OnTimerDone)

    local freezable = MakeHugeFreezableCharacter(inst)
    freezable:SetResistance(TUNING.DRAGONFLY_FREEZE_THRESHOLD)
    freezable.damagetobreak = TUNING.DRAGONFLY_FREEZE_RESIST
    freezable.diminishingreturns = true

    inst.heal_task = inst:DoPeriodicTask(10,heal,10)

    inst.DoAoe = DoAoe
    inst.OnSave = houseutil.SaveOwner
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("ttk_dragonfly", fn, assets, prefabs)
