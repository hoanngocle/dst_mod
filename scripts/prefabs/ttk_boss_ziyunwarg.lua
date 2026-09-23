-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local Xd_CalcDamage = Boss.Xd_CalcDamage
local sounds_mutated =
{
	idle = "rifts3/mutated_varg/idle",
	howl = "rifts3/mutated_varg/howl",
	hit = "rifts3/mutated_varg/hit",
	attack = "rifts3/mutated_varg/attack",
	death = "rifts3/mutated_varg/death",
	sleep = "rifts3/mutated_varg/sleep",
}
local function Mutated_OnRemove(inst)
	if inst.flame_pool ~= nil then
		for i, v in ipairs(inst.flame_pool) do
			v:Remove()
		end
		inst.flame_pool = nil
	end
	if inst.ember_pool ~= nil then
		for i, v in ipairs(inst.ember_pool) do
			v:Remove()
		end
		inst.ember_pool = nil
	end
end
local function Mutated_OnTemp8Faced(inst)
	if inst.temp8faced:value() then
		inst.gestalt.Transform:SetEightFaced()
		inst.eyeL.Transform:SetEightFaced()
		inst.eyeR.Transform:SetEightFaced()
		inst.mouthL.Transform:SetEightFaced()
		inst.mouthR.Transform:SetEightFaced()
	else
		inst.gestalt.Transform:SetSixFaced()
		inst.eyeL.Transform:SetSixFaced()
		inst.eyeR.Transform:SetSixFaced()
		inst.mouthL.Transform:SetSixFaced()
		inst.mouthR.Transform:SetSixFaced()
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
local function Mutated_SwitchToSixFaced(inst)
	if inst.temp8faced:value() then
		inst.temp8faced:set(false)
		if not TheNet:IsDedicated() then
			Mutated_OnTemp8Faced(inst)
		end
		inst.Transform:SetSixFaced()
	end
end
local function Mutated_CreateGestaltFlame()
	local inst = CreateEntity()
	inst:AddTag("FX")
	inst.persists = false
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.Transform:SetSixFaced()
	inst.AnimState:SetBank(Boss.Art("lunar_flame"))
	inst.AnimState:SetBuild(Boss.Art("lunar_flame"))
	inst.AnimState:PlayAnimation("gestalt_eye", true)
	inst.AnimState:SetMultColour(0, 0, 0, .5)
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
	inst.Transform:SetSixFaced()
	inst.AnimState:SetBank(Boss.Art("lunar_flame"))
	inst.AnimState:SetBuild(Boss.Art("lunar_flame"))
	inst.AnimState:PlayAnimation("flameanim", true)
	inst.AnimState:SetMultColour(0, 0, 0, .5)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:UsePointFiltering(true)
	return inst
end
local function Mutated_CreateMouthFlame()
	local inst = CreateEntity()
	inst:AddTag("FX")
	inst.persists = false
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddFollower()
	inst.Transform:SetSixFaced()
	inst.AnimState:SetBank(Boss.Art("lunar_flame"))
	inst.AnimState:SetBuild(Boss.Art("lunar_flame"))
	inst.AnimState:PlayAnimation("mouthflameanim", true)
	inst.AnimState:SetMultColour(0, 0, 0, .5)
	inst.AnimState:SetLightOverride(0.1)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:UsePointFiltering(true)
	return inst
end
local function spanwefx(inst,fx)
    if fx then
        local fx = SpawnAt("sharkboi_iceimpact_fx",inst)
        local s  = 1.42
        fx.Transform:SetScale(s, s, s)
	    fx.AnimState:SetMultColour(0/255,0/255,0/255,0.5)
    end
end
local TWEEN_TARGET = {1, 1, 1, 0}
local TWEEN_TIME = 0.2
local function dodespawn(inst)
    if not inst.doremove then
        spanwefx(inst,true)
        inst.doremove = true
        inst.components.colourtweener:StartTween(TWEEN_TARGET, TWEEN_TIME, inst.Remove)
    end
end
local function MakeWarg(data)
    local name     = data.name
    local bank     = data.bank
    local build    = data.build
    local prefabs  = data.prefabs
    local tag      = nil
	local epic     = false
    local assets =
    {
        Asset("SOUND", "sound/vargr.fsb"),
    }
    if bank == "warg" then
        table.insert(assets, Asset("ANIM", Boss.ArtPath("anim/warg_actions.zip")))
    elseif bank ~= build then
        table.insert(assets, Asset("ANIM", Boss.ArtPath("anim/"..bank..".zip")))
    end
    if tag == "gingerbread" then
        table.insert(assets, Asset("ANIM", Boss.ArtPath("anim/warg_gingerbread.zip")))
    elseif tag == "lunar_aligned" then
        table.insert(assets, Asset("ANIM", Boss.ArtPath("anim/warg_mutated_actions.zip")))
		table.insert(assets, Asset("ANIM", Boss.ArtPath("anim/lunar_flame.zip")))
    end
    table.insert(assets, Asset("ANIM", Boss.ArtPath("anim/"..build..".zip")))
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()
        inst.DynamicShadow:SetSize(2.5, 1.5)
        inst.Transform:SetSixFaced()
        inst:SetPhysicsRadiusOverride(1)
        MakeGhostPhysics(inst, 1000, inst.physicsradiusoverride)
        inst:AddTag("fx")
        inst.AnimState:SetMultColour(0, 0, 0, .5)
        inst.AnimState:UsePointFiltering(true)
        inst.temp8faced = net_bool(inst.GUID, name..".temp8faced", "temp8faceddirty")
        inst.AnimState:SetSymbolBloom("breath_02")
        inst.AnimState:SetSymbolBrightness("breath_02", 1.5)
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
            inst.mouthL = Mutated_CreateMouthFlame()
            inst.mouthL.entity:SetParent(inst.entity)
            inst.mouthL.Follower:FollowSymbol(inst.GUID, "mouthflameL", 0, 0, 0, true)
            frames = inst.mouthL.AnimState:GetCurrentAnimationNumFrames()
            rnd = math.random(frames) - 1
            inst.mouthL.AnimState:SetFrame(rnd)
            inst.mouthR = Mutated_CreateMouthFlame()
            inst.mouthR.entity:SetParent(inst.entity)
            inst.mouthR.Follower:FollowSymbol(inst.GUID, "mouthflameR", 0, 0, 0, true)
            rnd = (rnd + math.floor((0.35 + math.random() * 0.35) * frames)) % frames
            inst.mouthR.AnimState:SetFrame(rnd)
            if not TheWorld.ismastersim then
                inst:ListenForEvent("temp8faceddirty", Mutated_OnTemp8Faced)
            end
        end
        inst.AnimState:SetBank(Boss.Art(bank))
        inst.AnimState:SetBuild(Boss.Art(build))
        inst.AnimState:PlayAnimation("idle_loop", true)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst.addrange = 2
		inst.sounds = sounds_mutated
		inst.flame_pool = {}
		inst.ember_pool = {}
		inst.canflamethrower = true
		inst.OnRemoveEntity = Mutated_OnRemove
		inst.SwitchToEightFaced = Mutated_SwitchToEightFaced
		inst.SwitchToSixFaced = Mutated_SwitchToSixFaced
        inst.DoDespawn = dodespawn
        inst.persists = false
        inst.spanwefx = spanwefx
        inst:AddComponent("colourtweener")
		inst:SetStateGraph("SGttk_boss_ziyunwarg")
        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end
local assets =
{
	Asset("ANIM", Boss.ArtPath("anim/warg_mutated_breath_fx.zip")),
}
local prefabs =
{
	"ttk_boss_fb_warg_mutated_ember_fx",
}
local AOE_RANGE = 0.9
local AOE_RANGE_PADDING = 3
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function OnUpdateHitbox(inst)
    if  inst.owner and inst.owner:IsValid() and inst.owner.components.health and not inst.owner.components.health:IsDead() then
        inst.owner.components.combat.ignorehitrange = true
        local x, y, z = inst.Transform:GetWorldPosition()
        local radius = AOE_RANGE * inst.scale
        local ents =  TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, attacktag,noltags)
        for i, v in ipairs(ents) do
            if v and  v:IsValid() and (not v.ziyun_breathdamagetime or  (GetTime() - v.ziyun_breathdamagetime) > 0.5) and not (v.components.health ~= nil and v.components.health:IsDead()) and XD_CanAttackTrget(inst.owner,v) then
                v.ziyun_breathdamagetime = GetTime()
                local damage = 35
                damage = Xd_CalcDamage(inst.owner,damage,v)
                v.components.combat:GetAttacked(inst.owner,damage)
                if v.components.health and not v.components.health:IsDead() and v.components.freezable ~= nil then
                    v.components.freezable:AddColdness(1.3)
                end
            end
        end
        inst.owner.components.combat.ignorehitrange = false
    end
end
local function RefreshBrightness(inst)
	local k = math.min(1, inst.brightness:value() / 6)
	inst.AnimState:OverrideBrightness(1 + k * k * 0.5)
end
local function OnUpdateBrightness(inst)
	inst.brightness:set_local(inst.brightness:value() - 1)
	if inst.brightness:value() <= 0 then
		inst.updatingbrightness = false
		inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateBrightness)
	end
	RefreshBrightness(inst)
end
local function OnBrightnessDirty(inst)
	RefreshBrightness(inst)
	if inst.brightness:value() > 0 and inst.brightness:value() < 7 then
		if not inst.updatingbrightness then
			inst.updatingbrightness = true
			inst.components.updatelooper:AddOnUpdateFn(OnUpdateBrightness)
		end
	elseif inst.updatingbrightness then
		inst.updatingbrightness = false
		inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateBrightness)
	end
end
local function StartFade(inst)
	inst.brightness:set(6)
	OnBrightnessDirty(inst)
end
local function OnAnimQueueOver(inst)
	if inst.owner ~= nil and inst.owner.flame_pool ~= nil then
		inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateHitbox)
		inst.targets = nil
		inst.brightness:set(7)
		OnBrightnessDirty(inst)
		inst:RemoveFromScene()
		table.insert(inst.owner.flame_pool, inst)
	else
		inst:Remove()
	end
end
local function KillFX(inst, fadeoption)
	if fadeoption == "nofade" then
		StartFade(inst)
	end
	inst.AnimState:PlayAnimation("flame"..tostring(math.random(3)).."_pst")
	inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateHitbox)
	inst.targets = nil
	if inst.embers ~= nil then
		if inst.embers:IsValid() then
			inst.embers:KillFX()
		end
		inst.embers = nil
	end
end
local function SetFXOwner(inst, owner, attacker)
	inst.owner = owner.owner or owner
end
local function SpawnEmbers(inst, scale, fadeoption)
	local x, y, z = inst.Transform:GetWorldPosition()
	if not TheWorld.Map:IsPassableAtPoint(x, 0, z) then
		return
	elseif inst.embers ~= nil and inst.embers:IsValid() then
		inst.embers:KillFX()
	end
	inst.embers = inst.owner ~= nil and inst.owner.ember_pool ~= nil and table.remove(inst.owner.ember_pool) or nil
	if inst.embers == nil then
		inst.embers = SpawnPrefab("warg_mutated_ember_fx")
		inst.embers:SetFXOwner(inst.owner)
	end
	inst.embers.Transform:SetPosition(x, 0, z)
	inst.embers:RestartFX(scale, fadeoption)
end
local function RestartFX(inst, scale, fadeoption, targets)
	if inst:IsInLimbo() then
		inst:ReturnToScene()
	end
	local anim = "flame"..tostring(math.random(3))
	if not inst.AnimState:IsCurrentAnimation(anim.."_pre") then
		inst.AnimState:PlayAnimation(anim.."_pre")
		inst.AnimState:PushAnimation(anim.."_loop", true)
	end
	inst.scale = scale or 1
	inst.AnimState:SetScale(math.random() < 0.5 and -inst.scale or inst.scale, inst.scale)
	if fadeoption == "latefade" then
		inst:DoTaskInTime(10 * FRAMES, StartFade)
	elseif fadeoption ~= "nofade" then
		StartFade(inst)
	end
	inst:DoTaskInTime(2 * FRAMES, SpawnEmbers, inst.scale * 1.1, fadeoption)
	inst:DoTaskInTime(math.random(18, 22) * FRAMES, KillFX, fadeoption)
	if inst.embers ~= nil then
		if inst.embers:IsValid() then
			inst.embers:KillFX()
		end
		inst.embers = nil
	end
	if inst.owner ~= nil then
		inst.components.updatelooper:AddOnUpdateFn(OnUpdateHitbox)
	end
end
local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.AnimState:SetBank(Boss.Art("warg_mutated_breath_fx"))
	inst.AnimState:SetBuild(Boss.Art("warg_mutated_breath_fx"))
	inst.AnimState:PlayAnimation("flame1_pre")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetLightOverride(0.1)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.brightness = net_tinybyte(inst.GUID, "ttk_boss_ziyunwarg_breath_fx.brightness", "brightnessdirty")
	inst.brightness:set(7)
	OnBrightnessDirty(inst)
	inst:AddComponent("updatelooper")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		inst:ListenForEvent("brightnessdirty", OnBrightnessDirty)
		return inst
	end
	inst:ListenForEvent("animqueueover", OnAnimQueueOver)
	inst.persists = false
	inst.SetFXOwner = SetFXOwner
	inst.RestartFX = RestartFX
	inst.AnimState:PushAnimation("flame1_loop", true)
	RestartFX(inst)
	return inst
end
return Prefab("ttk_boss_ziyunwarg_breath_fx", fn, assets, prefabs),
    MakeWarg({
            name = "ttk_boss_ziyunwarg",
            bank = "warg",
            build = "warg_mutated_actions",
        })
