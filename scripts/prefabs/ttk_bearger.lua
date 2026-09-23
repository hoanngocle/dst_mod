local houseutil = require("ttk_batch19_houseutil")
local TTK_CanAttackTarget = houseutil.CanAttackTarget
local TTK_GetDamageTargets = houseutil.GetDamageTargets
local mutated_assets =
{
    Asset("ANIM", "anim/bearger_build.zip"),
    Asset("ANIM", "anim/bearger_basic.zip"),
    Asset("ANIM", "anim/bearger_actions.zip"),
    Asset("ANIM", "anim/bearger_mutated_actions.zip"),
    Asset("ANIM", "anim/bearger_mutated.zip"),
	Asset("ANIM", "anim/lunar_flame.zip"),
    Asset("SOUND", "sound/bearger.fsb"),
}

local mutated_prefabs =
{
    "bearger",
	"bearger_sinkhole",
	"mutatedbearger_swipe_fx",
	"groundpound_fx",
	"groundpoundring_fx",
	"furtuft",
	"collapse_small",
	"spoiled_food",
	"purebrilliance",
	"chesspiece_bearger_mutated_sketch",
	"winter_ornament_boss_mutatedbearger",
}

local brain = require("brains/ttk_drangonflybrain")

local function heal(inst)
    if not (inst.components.homeseeker and inst.components.homeseeker.home and 
        inst.components.homeseeker.home:IsValid() and inst:IsNear(inst.components.homeseeker.home,8)) then
        return
    end
    if not inst.components.health:IsDead() and inst.components.health:IsHurt() then
        inst.components.health:DoDelta(inst.components.health.maxhealth*0.02)
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

local function IsHibernationSeason(season)
    return season == "winter" or season == "spring"
end

local function OnSeasonChange(inst, season)
    if IsHibernationSeason(season) then
        inst:AddTag("hibernation")
    else
        inst:RemoveTag("hibernation")
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

local function DoAoe(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TTK_GetDamageTargets(x, y, z, 6)
    for i,v in pairs(ents) do
        if  v:IsValid() and TTK_CanAttackTarget(inst,v) then
            if inst.components.combat:CanTarget(v) then
				inst.components.combat:DoAttack(v)
            end
        end
    end
end

local function OnGroundPound(inst)
    DoAoe(inst)
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
        if (DefaultSleepTest(inst) or IsLeaderSleeping(inst)) and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) then
            inst:AddTag("hibernation")
            inst:AddTag("asleep")
            inst.AnimState:OverrideSymbol("bearger_head", IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "bearger_yule" or "bearger_build", "bearger_head_groggy")
            return true
        end
    elseif inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        return false
    elseif DefaultSleepTest(inst) then
        inst:AddTag("hibernation")
        inst:AddTag("asleep")
        inst.AnimState:OverrideSymbol("bearger_head", IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and "bearger_yule" or "bearger_build", "bearger_head_groggy")
        return true
    end
    return false
end

local function ShouldWake(inst)
    if inst.components.follower.leader and inst.components.follower.leader:IsValid() then 
        if (DefaultWakeTest(inst) and not IsLeaderSleeping(inst)) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE) then
            inst:RemoveTag("hibernation")
            inst:RemoveTag("asleep")
            inst.AnimState:ClearOverrideSymbol("bearger_head")
            return true
        end
    elseif inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
        inst:RemoveTag("hibernation")
        inst:RemoveTag("asleep")
        inst.AnimState:ClearOverrideSymbol("bearger_head")
        return true
    elseif DefaultWakeTest(inst) then
        inst:RemoveTag("hibernation")
        inst:RemoveTag("asleep")
        inst.AnimState:ClearOverrideSymbol("bearger_head")
        return true
    end
    return false
end

local function OnDroppedTarget(inst, data)
    if not inst.heal_task then
        inst.heal_task = inst:DoPeriodicTask(10,heal,10)
    end
end

local function OnCombatTarget(inst, data)
    if inst.heal_task then
        inst.heal_task:Cancel()
        inst.heal_task = nil
    end
end

local function OnDead(inst)
end

local function SwitchToEightFaced(inst)
	if not inst._temp8faced then
		inst._temp8faced = true
		inst.Transform:SetEightFaced()
	end
end

local function SwitchToFourFaced(inst)
	if inst._temp8faced then
		inst._temp8faced = false
		inst.Transform:SetFourFaced()
	end
end

local function SetStandState(inst, state)
    
    inst.StandState = string.lower(state)
end

local function IsStandState(inst, state)
    return inst.StandState == string.lower(state)
end

local function commonfn(build, commonfn)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(4.5, 3.15)

    inst.Transform:SetScale(0.75, 0.75, 0.75)

	inst:SetPhysicsRadiusOverride(1.4)
	MakeGiantCharacterPhysics(inst, 1000, inst.physicsradiusoverride)

    inst.AnimState:SetBank("bearger")
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:SetPrefabNameOverride("mutatedbearger")

    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("companion")
	inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("no_dtexp")
    inst:AddTag("no_drop_xdlingshi")

    if commonfn ~= nil then
        commonfn(inst)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
	inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat.hiteffectsymbol = "bearger_body"
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
    inst:AddComponent("groundpounder")
	inst.components.groundpounder:UseRingMode()
    inst.components.groundpounder.destroyer = false
	inst.components.groundpounder.damageRings = 3
	inst.components.groundpounder.destructionRings = 3
	inst.components.groundpounder.platformPushingRings = 3
    inst.components.groundpounder.numRings = 3
	inst.components.groundpounder.radiusStepDistance = 2
	inst.components.groundpounder.ringWidth = 1.5
    inst.components.groundpounder.groundpoundFn = OnGroundPound
    local old = inst.components.groundpounder.DestroyRing
    inst.components.groundpounder.DestroyRing = function(self,pt, radius, points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx, ents_hit, platforms_hit)
        breakobjects = false
        dodamage = false
        pushplatforms = false
        pushinventoryitems = false
        platforms_hit = false
        return old(self,pt, radius, points, breakobjects, dodamage, pushplatforms, pushinventoryitems, spawnfx, ents_hit, platforms_hit)
    end
    inst:AddComponent("timer")

    inst:AddComponent("drownable")

    inst:ListenForEvent("attacked", OnAttacked)

    SetStandState(inst, "quad")
    inst.SetStandState = SetStandState
    inst.IsStandState = IsStandState

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeHugeFreezableCharacter(inst, "bearger_body")

	inst.SwitchToEightFaced = SwitchToEightFaced
	inst.SwitchToFourFaced = SwitchToFourFaced

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
    inst.components.locomotor:SetShouldRun(true)

    inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(4)
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:SetStateGraph("SGttk_bearger")
    inst:SetBrain(brain)

    return inst
end

local function Mutated_OnTemp8Faced(inst)
	if inst.temp8faced:value() then
		inst.gestalt.Transform:SetEightFaced()
		inst.eyeL.Transform:SetEightFaced()
		inst.eyeR.Transform:SetEightFaced()
	else
		inst.gestalt.Transform:SetFourFaced()
		inst.eyeL.Transform:SetFourFaced()
		inst.eyeR.Transform:SetFourFaced()
	end
end

local function Mutated_SwitchToEightFaced(inst)
	if not inst.temp8faced:value() then
		inst.temp8faced:set(true)
		if not TheNet:IsDedicated() then
			Mutated_OnTemp8Faced(inst)
		end
		inst.Transform:SetEightFaced()
	end
end

local function Mutated_SwitchToFourFaced(inst)
	if inst.temp8faced:value() then
		inst.temp8faced:set(false)
		if not TheNet:IsDedicated() then
			Mutated_OnTemp8Faced(inst)
		end
		inst.Transform:SetFourFaced()
	end
end

local function Mutated_CreateGestaltFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")

	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("lunar_flame")
	inst.AnimState:SetBuild("lunar_flame")
	inst.AnimState:PlayAnimation("gestalt_eye", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:UsePointFiltering(true)

	return inst
end

local function Mutated_CreateEyeFlame()
	local inst = CreateEntity()

	inst:AddTag("FX")

	inst.persists = false

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("lunar_flame")
	inst.AnimState:SetBuild("lunar_flame")
	inst.AnimState:PlayAnimation("flameanim", true)
	inst.AnimState:SetMultColour(1, 1, 1, 0.6)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

	return inst
end

local function Mutated_OnRecoveryHealthDelta(inst, data)

end

local function Mutated_StartButtRecovery(inst, norunningbutt)

end

local function Mutated_IsButtRecovering(inst)
	return inst.recovery_starthp ~= nil
end

local function ShouldAcceptItem(inst, item)
    return item.prefab == "purebrilliance"
end

local function OnGetItemFromPlayer(inst, giver, item)
    if giver == nil or giver.components == nil then
        return
    end
    if inst.components.follower and inst.components.follower.leader then
        if giver == inst.components.follower.leader then
            inst.components.follower:AddLoyaltyTime(3*480)
            inst.components.follower.maxfollowtime = 3*480
        end
    elseif giver.components.leader ~= nil then
        giver.components.leader:AddFollower(inst)
        inst.components.follower:AddLoyaltyTime(3*480)
        inst.components.follower.maxfollowtime =3*480 
    end
    houseutil.SetOwner(inst, giver)
    inst._ttk_tamed = true
end

local function OnRefuseItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function mutatedcommonfn(inst)
    inst:AddTag("lunar_aligned")
	inst:AddTag("noepicmusic")

	inst.temp8faced = net_bool(inst.GUID, "ttk_mutatedbearger.temp8faced", "temp8faceddirty")

	if not TheNet:IsDedicated() then
		inst.gestalt = Mutated_CreateGestaltFlame()
		inst.gestalt.entity:SetParent(inst.entity)
		inst.gestalt.Follower:FollowSymbol(inst.GUID, "swap_gestalt_flame", 0, 0, 0, true)
		local frames = inst.gestalt.AnimState:GetCurrentAnimationNumFrames()
		local rnd = math.random(frames) - 1
		inst.gestalt.AnimState:SetFrame(rnd)

		inst.eyeL = Mutated_CreateEyeFlame()
		inst.eyeL.entity:SetParent(inst.entity)
		inst.eyeL.Follower:FollowSymbol(inst.GUID, "flameL", 0, 0, 0, true)
		frames = inst.eyeL.AnimState:GetCurrentAnimationNumFrames()
		rnd = math.random(frames) - 1
		inst.eyeL.AnimState:SetFrame(rnd)

		inst.eyeR = Mutated_CreateEyeFlame()
		inst.eyeR.entity:SetParent(inst.entity)
		inst.eyeR.Follower:FollowSymbol(inst.GUID, "flameR", 0, 0, 0, true)
		rnd = (rnd + math.floor((0.35 + math.random() * 0.35) * frames)) % frames
		inst.eyeR.AnimState:SetFrame(rnd)
	end
end

local function mutatedfn()
    local inst = commonfn("bearger_mutated", mutatedcommonfn)

    if not TheWorld.ismastersim then
		inst:ListenForEvent("temp8faceddirty", Mutated_OnTemp8Faced)
        return inst
    end

	inst.cancombo = false
	inst.canbutt = true
	inst.canrunningbutt = false
	inst.swipefx = "mutatedbearger_swipe_fx"

    inst.components.health:SetMaxHealth(6500)

    inst.components.combat:SetDefaultDamage(125)
	inst.components.combat:SetRange(6)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRetargetFunction(3, RetargetFn
)

	inst:AddComponent("planarentity")
	inst:AddComponent("planardamage")
	inst.components.planardamage:SetBaseDamage(30)

	inst.SwitchToEightFaced = Mutated_SwitchToEightFaced
	inst.SwitchToFourFaced = Mutated_SwitchToFourFaced

	inst.StartButtRecovery = Mutated_StartButtRecovery
	inst.IsButtRecovering = Mutated_IsButtRecovering

	inst:StartButtRecovery(true) 

    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = 3*480

    inst:AddComponent("homeseeker")

    inst:ListenForEvent("loseloyalty",function()
        if inst:IsValid() and not inst.components.health:IsDead() then
            local home = inst.components.homeseeker and inst.components.homeseeker.home or nil
            if home and home:IsValid() and not inst:IsNear(home,8) and home.components.childspawner ~= nil then
                houseutil.SpawnAt("statue_transition", inst)
               home.components.childspawner:GoHome(inst)
            end
        end
    end)
    
    inst:ListenForEvent("newcombattarget", OnCombatTarget)
	inst:ListenForEvent("droppedtarget", OnDroppedTarget)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.acceptnontradable = true

    inst.heal_task = inst:DoPeriodicTask(10,heal,10)

    inst.OnSave = houseutil.SaveOwner
    inst.OnLoad = houseutil.LoadOwner

    return inst
end

return Prefab("ttk_bearger",  mutatedfn,  mutated_assets,  mutated_prefabs )
