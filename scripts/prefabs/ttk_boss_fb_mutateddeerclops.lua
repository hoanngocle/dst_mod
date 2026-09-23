-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_Get_OwnerCalcDamage = Boss.XD_Get_OwnerCalcDamage
local brain = require "brains/ttk_boss_petbrains"
local mutated_assets =
{
    Asset("ANIM", Boss.ArtPath("anim/deerclops_basic.zip")),
    Asset("ANIM", Boss.ArtPath("anim/deerclops_actions.zip")),
    Asset("ANIM", Boss.ArtPath("anim/deerclops_mutated_actions.zip")),
    Asset("ANIM", Boss.ArtPath("anim/deerclops_mutated.zip")),
	Asset("ANIM", Boss.ArtPath("anim/lunar_flame.zip")),
    Asset("SOUND", "sound/deerclops.fsb"),
}
local mutated_prefabs =
{
    "deerclops",
	"deerclops_icespike_fx",
	"deerclops_icelance_ping_fx",
	"deerclops_impact_circle_fx",
	"deerclops_aura_circle_fx",
	"deerclops_spikefire_fx",
	"character_fire_flicker",
	"spoiled_food",
	"purebrilliance",
	"ice",
	"chesspiece_deerclops_mutated_sketch",
	"winter_ornament_boss_mutateddeerclops",
}
local mutated_sounds =
{
	step = "dontstarve/creatures/deerclops/step",
	taunt_grrr = "rifts3/mutated_deerclops/taunt_grrr",
	taunt_howl = "rifts3/mutated_deerclops/taunt_howl",
	hurt = "rifts3/mutated_deerclops/hurt",
	death = "rifts3/mutated_deerclops/death",
	attack = "rifts3/mutated_deerclops/attack",
	swipe = "dontstarve/creatures/deerclops/swipe",
	charge = "dontstarve/creatures/deerclops/charge",
	walk = "rifts3/mutated_deerclops/walk",
}
local nottags = {"abigail","companion","player","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
if TheNet:GetPVPEnabled() then
    nottags =  {"INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
end
local function RetargetFn(inst)
    local owner = inst.owner
    return owner ~= nil and FindEntity(inst, 10,
        function(guy)
            return owner:IsValid() and XD_CanAttackTrget(inst,guy)
                and (guy.components.combat:TargetIs(owner) or
                owner.components.combat:TargetIs(guy) or
                guy.components.combat:TargetIs(inst) )
        end,
        { "_combat","_health" },
        nottags
    ) or nil
end
local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
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
local function OnAttacked(inst, data)
    if data.attacker ~= nil and data.attacker ~= inst.owner then
        if data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end
local function ttk_boss_zhaohui(inst,owner)
    if inst and inst:IsValid() and not inst.components.health:IsDead() and owner and owner:IsValid() then
        if inst.components.combat and inst.components.combat.target then
            inst.components.combat:SetTarget(nil)
            inst.components.combat:BlankOutAttacks(1)
        end
        local x,y,z = owner.Transform:GetWorldPosition()
        local r = GetRandomMinMax(0.6,3)
        local rd = math.random(360)*DEGREES
        local pos = Vector3(x+ r*math.cos(rd),0,z+r*math.sin(rd))
        inst.Physics:Teleport(pos:Get())
        SpawnAt("ttk_boss_bigspawn_fx_medium_static_new",inst)
    end
end
local function OnSpawnedBy(inst, stalker,rate,fblevel)
    if stalker then
        inst.owner = stalker
        inst.components.health:SetMaxHealth((rate or 1)*inst.components.health.maxhealth)
		XD_Get_OwnerCalcDamage(inst,1)
        inst.components.locomotor.walkspeed = 1.0 *stalker.components.locomotor:GetRunSpeed()
        inst.components.locomotor.runspeed =  1.0 *stalker.components.locomotor:GetRunSpeed()
        inst.components.follower:SetLeader(stalker)
        inst:ForceFacePoint(stalker.Transform:GetWorldPosition())
        inst:ListenForEvent("onremove", function()
            if inst and inst:IsValid() then
                inst:Remove()
            end
        end,stalker)
		local level,ad = fblevel[1],fblevel[2]
		if TUNING.XD_FB_MUTATEDDEERCLOPS_SET.damage[level] then
			local damage = TUNING.XD_FB_MUTATEDDEERCLOPS_SET.damage[level]
			inst.components.combat:SetDefaultDamage(damage)
		end
    end
end
local function spanwefx(inst,fx)
    if fx then
        local fx = SpawnAt("sharkboi_iceimpact_fx",inst)
        local s  = 1.85
        fx.Transform:SetScale(s, s, s)
	    fx.AnimState:SetMultColour(0/255,0/255,0/255,0.5)
    end
end
local TWEEN_TARGET = {1, 1, 1, 0}
local TWEEN_TIME = 0.2
local function dodespawn(inst)
    if not inst.doremove and not inst.components.health:IsDead() then
        inst.components.health:SetInvincible(true)
        spanwefx(inst,true)
        inst.doremove = true
        if inst.components.container then
            inst.components.container:Close()
            inst.components.container.canbeopened = false
        end
        inst.components.colourtweener:StartTween(TWEEN_TARGET, TWEEN_TIME, inst.Remove)
    end
end
local function OnRemove(inst)
	if inst.spikefire ~= nil then
		inst.spikefire:Remove()
		inst.spikefire = nil
	end
	if inst.sg.mem.ping ~= nil then
		inst.sg.mem.ping:KillFX()
		inst.sg.mem.ping = nil
	end
	if inst.sg.mem.circle ~= nil then
		inst.sg.mem.circle:KillFX()
		inst.sg.mem.circle = nil
	end
	if inst.icespike_pool ~= nil then
		for i, v in ipairs(inst.icespike_pool) do
			v:Remove()
		end
		inst.icespike_pool = nil
	end
end
local function OnHitOtherMutated(inst, data)
	if data.target ~= nil and data.target:IsValid() and inst.owner and inst.owner:IsValid() then
        if data.target.components.health and not data.target.components.health:IsDead() and data.target.components.freezable ~= nil then
            data.target.components.freezable:AddColdness(1.5)
        end
    end
end
local function commonfn(build, commonfn)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
	inst:SetPhysicsRadiusOverride(.5)
	MakeGhostPhysics(inst, 1000, inst.physicsradiusoverride)
    local s  = 1.65
    inst.Transform:SetScale(s, s, s)
    inst.DynamicShadow:SetSize(6, 3.5)
    inst.Transform:SetFourFaced()
	inst:AddTag("scarytoprey")
	inst:AddTag("character")
	inst:AddTag("companion")
	inst:AddTag("notraptrigger")
	inst:AddTag("ttk_boss_skill_pet")
	inst:AddTag("no_drop_xdlingshi")
    inst.build = build
    inst.AnimState:SetBank(Boss.Art("deerclops"))
    inst.AnimState:SetBuild(Boss.Art(build))
    inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:Hide("head_neutral")
	inst.AnimState:SetMultColour(0, 0, 0, .5)
    inst.AnimState:UsePointFiltering(true)
    if commonfn ~= nil then
        commonfn(inst)
    end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst.icespike_pool = {}
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = {  allowocean = true, ignorecreep = true }
    inst:AddComponent("health")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "deerclops_body"
	inst.components.combat:SetRetargetFunction(1, RetargetFn)
	inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("onremove", OnRemove)
	inst:ListenForEvent("onhitother", OnHitOtherMutated)
    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
	inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true
    inst:SetBrain(brain)
	inst:DoTaskInTime(60,dodespawn)
    inst.persists = false
    inst.ttk_boss_zhaohui = ttk_boss_zhaohui
    inst.OnSpawnedBy = OnSpawnedBy
    inst.spanwefx = spanwefx
	inst.SwitchToEightFaced = SwitchToEightFaced
	inst.SwitchToFourFaced = SwitchToFourFaced
    return inst
end
local function Mutated_OnTemp8Faced(inst)
	if inst.temp8faced:value() then
		inst.gestalt.Transform:SetEightFaced()
	else
		inst.gestalt.Transform:SetFourFaced()
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
	inst.AnimState:SetBank(Boss.Art("lunar_flame"))
	inst.AnimState:SetBuild(Boss.Art("lunar_flame"))
	inst.AnimState:PlayAnimation("gestalt_eye", true)
	inst.AnimState:SetMultColour(0, 0, 0, 0.5)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:UsePointFiltering(true)
	return inst
end
local function Mutated_SetFrenzied(inst, frenzied)
	if frenzied then
		if not inst.frenzied then
			inst.frenzied = true
			inst.frenzy_starttime = GetTime()
			inst.frenzy_starthp = inst.components.health:GetPercent()
		end
	elseif inst.frenzied then
		inst.frenzied = nil
		inst.frenzy_starttime = nil
		inst.frenzy_starthp = nil
	end
end
local function Mutated_ShouldStayFrenzied(inst)
	return inst.frenzied
		and (	inst.frenzy_starttime + TUNING.MUTATED_DEERCLOPS_FRENZY_MIN_TIME > GetTime() or
				inst.frenzy_starthp - inst.components.health:GetPercent() < TUNING.MUTATED_DEERCLOPS_FRENZY_HP
			)
end
local function mutatedcommonfn(inst)
	inst.AnimState:Hide("gestalt_eye")
	inst.temp8faced = net_bool(inst.GUID, "ttk_boss_fb_mutateddeerclops.temp8faced", "temp8faceddirty")
	if not TheNet:IsDedicated() then
		inst.gestalt = Mutated_CreateGestaltFlame()
		inst.gestalt.entity:SetParent(inst.entity)
		inst.gestalt.Follower:FollowSymbol(inst.GUID, "swap_gestalt_flame", 0, 0, 0, true)
		local frames = inst.gestalt.AnimState:GetCurrentAnimationNumFrames()
		local rnd = math.random(frames) - 1
		inst.gestalt.AnimState:SetFrame(rnd)
	end
end
local function mutatedfn()
    local inst = commonfn("deerclops_mutated", mutatedcommonfn)
    if not TheWorld.ismastersim then
		inst:ListenForEvent("temp8faceddirty", Mutated_OnTemp8Faced)
        return inst
    end
    inst.sounds = mutated_sounds
	inst.hasiceaura = true
	inst.hasknockback = true
	inst.hasicelance = true
	inst.hasfrenzy = true
	inst.freezepower = 3
	inst.ignorebase = true
    inst:AddComponent("timer")
    inst.components.health:SetMaxHealth(2650)
    inst.components.combat:SetDefaultDamage(1344.4)
	inst.components.combat:SetRange(TUNING.MUTATED_DEERCLOPS_ATTACK_RANGE)
    inst.components.combat:SetAttackPeriod(3)
	inst.SwitchToEightFaced = Mutated_SwitchToEightFaced
	inst.SwitchToFourFaced = Mutated_SwitchToFourFaced
	inst.SetFrenzied = Mutated_SetFrenzied
	inst.ShouldStayFrenzied = Mutated_ShouldStayFrenzied
	inst:AddComponent("colourtweener")
	inst:SetStateGraph("SGttk_boss_fb_mutateddeerclops")
    return inst
end
local assets_impact =
{
	Asset("ANIM", Boss.ArtPath("anim/deerclops_mutated_actions.zip")),
	Asset("ANIM", Boss.ArtPath("anim/deerclops_mutated.zip")),
	Asset("ANIM", Boss.ArtPath("anim/deer_ice_circle.zip")),
}
local impact_firstplayhack = true
local function impact_DoSound(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/break_iceblock")
end
local function impact_CreateExplosion()
	local inst = CreateEntity()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.persists = false
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.AnimState:SetBank(Boss.Art("deerclops"))
	inst.AnimState:SetBuild(Boss.Art("deerclops_mutated"))
	inst.AnimState:PlayAnimation("ice_impact")
	if impact_firstplayhack then
		impact_firstplayhack = nil
		inst:DoTaskInTime(0, impact_DoSound)
	else
		impact_DoSound(inst)
	end
	inst:ListenForEvent("animover", inst.Remove)
	return inst
end
local function impact_KillFX(inst)
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("pst")
end
local function impactfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("deer_ice_circle"))
	inst.AnimState:SetBuild(Boss.Art("deer_ice_circle"))
	inst.AnimState:PlayAnimation("impact")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetScale(2.2, 2.2)
	if not TheNet:IsDedicated() then
		impact_CreateExplosion().entity:SetParent(inst.entity)
	end
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
	inst:DoTaskInTime(2, impact_KillFX)
	return inst
end
return Prefab("ttk_boss_fb_mutateddeerclops",  mutatedfn,  mutated_assets,  mutated_prefabs ),
	Prefab("ttk_boss_fb_impact_circle_fx",  impactfn,  assets_impact)
