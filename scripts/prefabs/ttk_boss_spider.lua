-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/ds_spider_basic.zip")),
    Asset("ANIM", Boss.ArtPath("anim/spider_build.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_spider.zip")),
    Asset("ANIM", Boss.ArtPath("anim/ds_spider_boat_jump.zip")),
    Asset("SOUND", "sound/spider.fsb"),
}
local proassets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_spider_pro.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_slow_buff_ent.zip")),
}
local prefabs =
{
    "spidergland",
    "monstermeat",
    "silk",
    "spider_web_spit",
    "spider_web_spit_acidinfused",
}
local brain = require "brains/ttk_boss_spiderbrain"
local TARGET_MUST_TAGS = { "_combat", "character" }
local TARGET_CANT_TAGS = { "spiderwhisperer", "spiderdisguise", "INLIMBO","spider" }
local function FindTarget(inst, radius)
    return FindEntity(
        inst,
        SpringCombatMod(radius),
        function(guy)
            return (not inst.bedazzled and (not guy:HasTag("monster") or guy:HasTag("player")))
            and not (inst.components.follower ~= nil and inst.components.follower.leader == guy)
                and inst.components.combat:CanTarget(guy)
        end,
        TARGET_MUST_TAGS,
        TARGET_CANT_TAGS
    )
end
local function NormalRetarget(inst)
    return FindTarget(inst, inst.components.knownlocations:GetLocation("investigate") ~= nil and 6 or 4)
end
local function keeptargetfn(inst, target)
   return target ~= nil
        and target.components.combat ~= nil
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and not (inst.components.follower ~= nil and
        (inst.components.follower.leader == target or inst.components.follower:IsLeaderSame(target)))
end
local function BasicWakeCheck(inst)
    return inst.components.combat:HasTarget()
        or (inst.components.homeseeker ~= nil and inst.components.homeseeker:HasHome())
        or inst.components.burnable:IsBurning()
        or inst.components.freezable:IsFrozen()
        or inst.components.follower:GetLeader() ~= nil
        or inst.components.health.takingfiredamage
end
local function ShouldSleep(inst)
    return TheWorld.state.iscaveday and not BasicWakeCheck(inst)
end
local function ShouldWake(inst)
    return not TheWorld.state.iscaveday
        or BasicWakeCheck(inst)
end
local function DoReturn(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    if home ~= nil and
        home.components.childspawner ~= nil and
        not (inst.components.follower ~= nil and
            inst.components.follower.leader ~= nil) then
        home.components.childspawner:GoHome(inst)
    end
end
local function OnIsCaveDay(inst, iscaveday)
    if not iscaveday then
        inst.components.sleeper:WakeUp()
    elseif inst:IsAsleep() then
        DoReturn(inst)
    end
end
local function OnEntitySleep(inst)
    if TheWorld.state.iscaveday then
        DoReturn(inst)
    end
end
local SPIDERDEN_TAGS = {"ttk_boss_spiderden"}
local function SummonFriends(inst, attacker)
    local radius = 12
    local den = GetClosestInstWithTag(SPIDERDEN_TAGS, inst, radius)
    if den ~= nil and den.components.combat ~= nil and den.components.combat.onhitfn ~= nil then
        den.components.combat.onhitfn(den, attacker)
    end
end
local function OnAttacked(inst, data)
    inst.defensive = false
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        local should_share = dude:HasTag("ttk_boss_spider")
            and not dude.components.health:IsDead()
            and dude.components.follower ~= nil
            and dude.components.follower.leader == inst.components.follower.leader
        if should_share and dude.defensive then
            dude.defensive = false
        end
        return should_share
    end, 10)
end
local function OnGoToSleep(inst)
end
local function OnWakeUp(inst)
end
local function SoundPath(inst, event)
    local creature = "spider"
    if inst:HasTag("spider_healer") then
        return "webber1/creatures/spider_cannonfodder/" .. event
    elseif inst:HasTag("spider_moon") then
        return "turnoftides/creatures/together/spider_moon/" .. event
    elseif inst:HasTag("spider_warrior") then
        creature = "spiderwarrior"
    elseif inst:HasTag("spider_hider") or inst:HasTag("spider_spitter") then
        creature = "cavespider"
    else
        creature = "spider"
    end
    return "dontstarve/creatures/" .. creature .. "/" .. event
end
local function DoDamage(inst,target,damage)
    local basedamage = nil
    if damage then
        basedamage =  inst.components.combat.defaultdamage
        inst.components.combat:SetDefaultDamage(damage)
    end
    inst.components.combat.ignorehitrange = true
    inst.components.combat:DoAttack(target)
    inst.components.combat.ignorehitrange = false
    if basedamage then
        inst.components.combat:SetDefaultDamage(basedamage)
    end
end
local function OnHitOther(inst, data)
    if data.redirected then
        return
    end
	if inst.isshadow and data.target ~= nil and data.target.components.ttk_boss_poisonable ~= nil then
        data.target.components.ttk_boss_poisonable:Poison()
    end
end
local function DoFx(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("statue_transition_2")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(.8, .8, .8)
    end
    fx = SpawnPrefab("statue_transition")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(.8, .8, .8)
    end
end
local function ChangeToShadow(inst)
	DoFx(inst)
	inst.isshadow = true
	inst.AnimState:SetMultColour(0, 0, 0, .62)
end
local function ChangeToNormal(inst)
	inst.isshadow = false
	inst.AnimState:SetMultColour(1, 1, 1, 1)
end
local function UpdateStage(inst)
    local iscrazy = TheWorld.components.ttk_boss_kunpengstage and TheWorld.components.ttk_boss_kunpengstage:IsCrazy() or false
    local inrange = TheWorld.components.ttk_boss_kunpengspawner and TheWorld.components.ttk_boss_kunpengspawner:IsOnGround(inst:GetPosition()) or false
    if iscrazy and inrange and not inst.isshadow then
        inst:Xd_ChangeToShadow()
    elseif not iscrazy and inst.isshadow then
        inst:Xd_ChangeToNormal()
    end
end
local DIET = { FOODTYPE.MEAT }
local BASE_PATHCAPS = { ignorecreep = true }
local function create_common(bank, build, tag, common_init, extra_data)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    MakeCharacterPhysics(inst, 10, .5)
    inst.DynamicShadow:SetSize(1.5, .5)
    inst.Transform:SetFourFaced()
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("smallcreature")
    inst:AddTag("ttk_boss_spider")
    if tag ~= nil then
        inst:AddTag(tag)
    end
    inst:AddTag("trader")
    inst.AnimState:SetBank(Boss.Art(bank))
    inst.AnimState:SetBuild(Boss.Art(build))
    inst.AnimState:PlayAnimation("idle")
    if common_init ~= nil then
        common_init(inst)
    end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.OnEntitySleep = OnEntitySleep
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = (extra_data and extra_data.pathcaps) or BASE_PATHCAPS
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")
    inst:SetStateGraph((extra_data and extra_data.sg) or "SGttk_boss_spider")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("monstermeat", 1)
    inst.components.lootdropper:AddRandomLoot("silk", .5)
    inst.components.lootdropper:AddRandomLoot("spidergland", .5)
    inst.components.lootdropper:AddRandomHauntedLoot("spidergland", 1)
    inst.components.lootdropper.numrandomloot = 1
    MakeMediumBurnableCharacter(inst, "body")
    MakeMediumFreezableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.SPIDER_FLAMMABILITY
    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)
    inst.components.combat:SetOnHit(SummonFriends)
    inst:AddComponent("follower")
    inst:AddComponent("sleeper")
    inst.components.sleeper.watchlight = true
    inst.components.sleeper:SetResistance(2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst:AddComponent("knownlocations")
    inst:AddComponent("eater")
    inst.components.eater:SetDiet(DIET, DIET)
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true)
    inst.components.eater:SetCanEatRawMeat(true)
    inst:AddComponent("timer")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventory")
    inst:AddComponent("sanityaura")
    inst:AddComponent("acidinfusible")
    inst.components.acidinfusible:SetFXLevel(1)
    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.STRONGER)
    MakeHauntablePanic(inst)
    inst:SetBrain((extra_data and extra_data.brain) or brain)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("gotosleep", OnGoToSleep)
    inst:ListenForEvent("onwakeup", OnWakeUp)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:WatchWorldState("iscaveday", OnIsCaveDay)
    OnIsCaveDay(inst, TheWorld.state.iscaveday)
    inst.isshadow =  false
	inst.Xd_ChangeToShadow = ChangeToShadow
	inst.Xd_ChangeToNormal = ChangeToNormal
    inst:DoTaskInTime(0,UpdateStage)
    inst:ListenForEvent("ttk_boss_kunpengstage_change",function(_,data)
        UpdateStage(inst)
    end,TheWorld)
    inst.SoundPath = SoundPath
    inst.incineratesound = SoundPath(inst, "die")
    inst.DoDamage = DoDamage
    inst.build = build
    return inst
end
local function create_spider()
    local inst = create_common("spider", "ttk_boss_spider")
    if not TheWorld.ismastersim then
        return inst
    end
    inst.components.health:SetMaxHealth(400)
    inst.components.combat:SetDefaultDamage(35)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, NormalRetarget)
    inst.components.locomotor.walkspeed = 5
    inst.components.locomotor.runspeed = 6.5
    inst.components.sanityaura.aura = -1
    return inst
end
local function OnHit_Lunar(inst, attacker, target)
    if target and target:IsValid() and target:HasTag("player") then
        if not IsEntityDeadOrGhost(target) then
            target:AddDebuff("ttk_boss_slow_buff","ttk_boss_slow_buff")
        end
    end
    inst:Remove()
end
local function OnMiss_Lunar(inst, attacker, target)
    inst:Remove()
end
local function onthrown(inst, owner, target, attacker)
    inst.owner = owner
end
local function Hit(self,target)
    local attacker = self.owner
    local weapon = self.inst
    self:Stop()
    self.inst.Physics:Stop()
    attacker:DoDamage(target,30)
    if self.onhit ~= nil then
        self.onhit(self.inst, attacker, target)
    end
end
local function profn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
    inst.entity:SetCanSleep(false)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("xd_spider_pro"))
	inst.AnimState:SetBuild(Boss.Art("xd_spider_pro"))
	inst.AnimState:PlayAnimation("idle")
	inst:AddTag("projectile")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(32)
    inst.components.projectile:SetHoming(false)
	inst.components.projectile:SetRange(30)
	inst.components.projectile:SetOnHitFn(OnHit_Lunar)
	inst.components.projectile:SetOnMissFn(OnMiss_Lunar)
    inst.components.projectile.onthrown = onthrown
    inst.components.projectile:SetLaunchOffset(Vector3(0, 0, 0))
    inst.components.projectile.Hit = Hit
	inst.persists = false
	return inst
end
local function SetOwner(inst,owner)
    inst.entity:SetParent(owner.entity)
    inst.Transform:SetPosition(0,0.7,0)
    inst.owner = owner
end
local function bufffn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_slow_buff_ent"))
    inst.AnimState:SetBuild(Boss.Art("xd_slow_buff_ent"))
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(3)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.SetOwner = SetOwner
    inst.persists = false
    return inst
end
return Prefab("ttk_boss_spider", create_spider, assets, prefabs),
    Prefab("ttk_boss_spider_pro", profn, proassets),
    Prefab("ttk_boss_slow_buff_ent", bufffn, proassets)
