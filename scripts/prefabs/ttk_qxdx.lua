-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_qxdx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_qxdx_phase2.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_qxdx_weapon.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_qxdx_spike.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_actions_idle.zip")),
    Asset("ATLAS", "images/xd_qxdx_ui.xml")
}
local prefabs = {
}
SetSharedLootTable('ttk_qxdx',
{
    {"ttk_npxsz",  1.00},
    {'ttk_npxsz',  1.00},
	{'redgem',  1.00},
	{'redgem',  1.00},
    {'redgem',  1.00},
	{'redgem',  1.00},
	{'redgem',  1.00},
    {'greengem',  1.00},
	{'greengem',  1.00},
	{'orangegem',  1.00},
	{'orangegem',  1.00},
	{'yellowgem',  1.00},
	{'yellowgem',  1.00},
	{'ttk_boss_back_xh',  1.0},
})
local not_aoetags = {"INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost"}
local brain = require "brains/ttk_boss_qxdxbrain"
local function UpdatePlayerTargets(inst)
	local toadd = {}
	local toremove = {}
	local x, y, z = inst.Transform:GetWorldPosition()
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		toremove[k] = true
	end
	for i, v in ipairs(FindPlayersInRange(x, y, z, 30, true)) do
		if toremove[v] then
			toremove[v] = nil
		else
			table.insert(toadd, v)
		end
	end
	for k in pairs(toremove) do
		inst.components.grouptargeter:RemoveTarget(k)
	end
	for i, v in ipairs(toadd) do
		inst.components.grouptargeter:AddTarget(v)
	end
end
local function Retarget(inst)
	UpdatePlayerTargets(inst)
	local target = inst.components.combat.target
	local inrange = target ~= nil and inst:IsNear(target, 12 + target:GetPhysicsRadius(0))
	if target ~= nil and target:HasTag("player") then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer ~= nil
			and newplayer:IsNear(inst, inrange and 12 + newplayer:GetPhysicsRadius(0) or 12)
			and newplayer
			or nil,
			true
	end
	local nearplayers = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if inst:IsNear(k, inrange and 6 + k:GetPhysicsRadius(0) or 12) then
			table.insert(nearplayers, k)
		end
	end
	return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end
local function ShouldKeepTarget(inst, target)
    return target and inst.components.combat:CanTarget(target)
end
local function OnAttacked(inst, data)
    if data and data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
			target:HasTag("player") and
			target:IsNear(inst, 12 + target:GetPhysicsRadius(0))) then
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end
local function settimeleft(inst,name,time)
	if not inst.components.timer:TimerExists(name) then
		inst.components.timer:StartTimer(name,time)
	else
		inst.components.timer:SetTimeLeft(name,time)
	end
end
local function OnHitOther(inst,data)
	inst.lastattacktime = GetTime()
end
local function StopTalkSound(inst, instant)
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end
local function DoTalkSound(inst)
	StopTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/talk_LP","talk")
        return true
    end
end
local function DoTalk(inst,str,anim)
	inst.components.talker:Say(str,nil,true,true)
	DoTalkSound(inst)
	if inst.talk_task then
		inst.talk_task:Cancel()
	end
    if anim then
        inst.AnimState:PlayAnimation("dial_loop",true)
    end
	inst.talk_task =  inst:DoTaskInTime(2,function()
		inst.talk_task = nil
		StopTalkSound(inst)
        if anim then
            inst.AnimState:PlayAnimation("xd_idle_loop",true)
        end
	end)
end
local function vortex_spawner(inst,data,skin)
    if inst._xd_weapon_fx == nil then
        inst._xd_weapon_fx = SpawnPrefab("ttk_boss_qxdx_yumaofx" )
        inst._xd_weapon_fx.entity:AddFollower()
    end
    inst._xd_weapon_fx.entity:SetParent(inst.entity)
    inst._xd_weapon_fx.Follower:FollowSymbol(inst.GUID, "swap_object", 40, -180, 0)
end
local function dogongdeattack(inst,data)
	if data and data.target and data.target:IsValid() then
        local x,y,z = data.target.Transform:GetWorldPosition()
        local r = 2
        local rd = math.random(360)*DEGREES
        local striker = SpawnPrefab("ttk_boss_gongdeshadow")
        if striker then
            local pos = Vector3(x+ r*math.cos(rd),0,z+r*math.sin(rd))
            striker.Transform:SetPosition(pos:Get())
            striker.attackdamage = 100
            striker.damage = 100
            striker:CopyFromPlayer(inst,data.target,pos)
			striker.not_aoetags = not_aoetags
			striker.AnimState:OverrideSymbol("swap_object","xd_qxdx_weapon", inst.mode == 2 and "up_swap" or "swap")
        end
        inst:PushEvent("do_gongde_attack",{target = data.target})
	end
end
local function DoAoe(inst,range,damage,aoepos,fn)
    if inst and inst:IsValid() then
        local x,y,z = inst.Transform:GetWorldPosition()
        if aoepos then
            x,y,z = aoepos:Get()
        end
        local ents = XD_GetDamageTargets(x, 0, z, range or 3, not_aoetags)
        for i,v in pairs(ents) do
            if v and v:IsValid() and v ~= inst and XD_CanAttackTrget(inst,v)
                and (not fn or fn(inst,v)) then
                local damage = damage or 10
                damage = Xd_CalcDamage(inst,damage,v,nil,1)
                v.components.combat:GetAttacked(inst,damage)
            end
        end
    end
end
local function GetAngleToPoint(pos,x, y, z,ang)
    return pos.x == x and pos.z == z
    and ang
    or math.atan2(pos.z - z, x - pos.x) * RADIANS
end
local function isinrange(target,rd,ang,pos)
    local x,y,z = target.Transform:GetWorldPosition()
    local angle = GetAngleToPoint(pos,x,0,z,ang)
    local drot = math.abs( ang - angle )
    while drot > 180 do
        drot = math.abs(drot - 360)
    end
    return drot < (rd or 30)
end
local function fire_attackfn(inst,data,buff)
    local pos = inst:GetPosition()
    local rota = inst.Transform:GetRotation()
    inst:DoTaskInTime(0.4,function()
        if inst.SoundEmitter then
            inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel", nil, 0.3)
        end
    end)
    local attackfx = SpawnPrefab("attackfire_fx")
    attackfx.Transform:SetPosition(pos:Get())
    attackfx.Transform:SetRotation(rota)
    local ang = rota
    inst:DoTaskInTime(0.5,function()
        DoAoe(inst,8,75,pos,function(inst,target)
            return isinrange(target,30,ang,pos)
        end)
    end)
end
local SNARE_OVERLAP_MIN = 1
local SNARE_OVERLAP_MAX = 3
local SNAREOVERLAP_TAGS = { "fossilspike", "groundspike" }
local function NoSnareOverlap(x, z, r)
    return #TheSim:FindEntities(x, 0, z, r or SNARE_OVERLAP_MIN, SNAREOVERLAP_TAGS) <= 0
end
local function SpawnSnare(inst, x, z, r, num, target,combattargets)
    local vars = { 1, 2, 3, 4, 5, 6, 7 }
    local used = {}
    local queued = {}
    local count = 0
    local dtheta = PI * 2 / num
    local thetaoffset = math.random() * PI * 2
    local delaytoggle = 0
    local map = TheWorld.Map
    for theta = math.random() * dtheta, PI * 2, dtheta do
        local x1 = x + r * math.cos(theta)
        local z1 = z + r * math.sin(theta)
        if map:IsPassableAtPoint(x1, 0, z1) and not map:IsPointNearHole(Vector3(x1, 0, z1)) then
            local spike = SpawnPrefab("ttk_boss_qxdx_spike")
            spike.Transform:SetPosition(x1, 0, z1)
            spike.targets = combattargets
            spike.owner = inst
            local delay = delaytoggle == 0 and 0 or .2 + delaytoggle * math.random() * .2
            delaytoggle = delaytoggle == 1 and -1 or 1
            local duration = 10
            local variation = table.remove(vars, math.random(#vars))
            table.insert(used, variation)
            if #used > 3 then
                table.insert(queued, table.remove(used, 1))
            end
            if #vars <= 0 then
                local swap = vars
                vars = queued
                queued = swap
            end
            spike:RestartSpike(delay, duration, variation)
            count = count + 1
        end
    end
    if count <= 0 then
        return false
    end
    return true
end
local function circular(inst,r,prefab,num,fn)
    local x,y,z = inst.Transform:GetWorldPosition()
    for k=1,num do
        local angle = k * 2 * PI / num
        local item = SpawnAt(prefab, Vector3(r*math.cos(angle)+x, 0, r*math.sin(angle)+z))
        if item ~= nil and fn ~= nil and type(fn) == "function" then
            fn(item, inst, k)
        end
    end
end
local function FireCircleFxDamage(inst,owner)
    inst.owner = owner
    inst:DoTaskInTime(0.4, inst.TriggerFX)
    inst:DoTaskInTime(7.5, function()
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
        inst.KillFX(inst)
    end)
    inst.task = inst:DoPeriodicTask(0.5,function()
        DoAoe(inst.owner,4,100,inst:GetPosition())
    end,0.2)
end
local function spawnspike(inst)
    inst.components.timer:StartTimer("spike_cd",30)
    inst:DoTaskInTime(2,function()
        if not inst.components.health or inst.components.health:IsDead() then
            return
        end
        circular(inst,4,"deer_fire_circle",5,function(fx,inst)
            FireCircleFxDamage(fx, inst)
        end)
        circular(inst,10,"deer_fire_circle",10,function(fx,inst)
            FireCircleFxDamage(fx, inst)
        end)
        circular(inst,16,"deer_fire_circle",16,function(fx,inst)
            FireCircleFxDamage(fx, inst)
        end)
    end)
    local combattargets = {}
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local ents = XD_GetDamageTargets(x1, 0, z1, 21, not_aoetags)
    for i,v in pairs(ents) do
        if v and v:IsValid() and v ~= inst and XD_CanAttackTrget(inst,v) then
            local x, y, z = v.Transform:GetWorldPosition()
            local islarge = v:HasTag("largecreature")
            local r = v:GetPhysicsRadius(0) + (islarge and 1.5 or .5)
            local num = islarge and 12 or 6
            if NoSnareOverlap(x, z, r + SNARE_OVERLAP_MAX) then
                if SpawnSnare(inst, x, z, r, num, v,combattargets) then
                    inst:DoTaskInTime(0.2,function()
                        local ents = XD_GetDamageTargets(x, y, z,2,not_aoetags)
                        for i,v in pairs(ents) do
                            if v:IsValid() and not combattargets[v] and XD_CanAttackTrget(inst,v) then
                                combattargets[v] = true
                                local damage = 50
                                damage = Xd_CalcDamage(inst,damage,v,nil,1)
                                v.components.combat:GetAttacked(inst,damage)
                            end
                        end
                    end)
                end
            end
        end
    end
end
local function OnAttack(inst,data)
    if inst.mode == 2 then
        fire_attackfn(inst,data)
    end
    inst.attack_count = math.min(6,inst.attack_count + 1)
    if inst.attack_count%3 == 0 and inst.attack_count ~= 0 then
        settimeleft(inst,"attack_cd",1.5)
    end
	if inst.attack_count == 6 then
		inst.attack_count =  0
		dogongdeattack(inst,data)
	end
end
local function spawnht(inst)
    if inst.components.leader:CountFollowers("ttk_boss_ht") < 1 then
        local x, y, z = inst.Transform:GetWorldPosition()
        local facing_angle = math.random(-180,180) * DEGREES
        local launchoffset = 20
        x =  x + launchoffset * math.cos(facing_angle)
        z = z - launchoffset * math.sin(facing_angle)
        local ht = SpawnPrefab("ttk_boss_ht")
        if ht then
            ht.Transform:SetPosition(x, y, z)
            ht:OnSpawnedBy(inst)
            ht.skill1_damage = 60
            ht.skill2_damage = 60
            ht.skill3_damage = 120
            ht.attackdamage = 70
            ht.not_aoetags = not_aoetags
        end
    end
end
local function ChangeMode(inst,mode)
    local old = inst.mode
    if mode then
        inst.mode = mode
    else
        inst.mode = inst.mode + 1
    end
    if inst.mode ~= old then
        if inst.mode == 1 then
			inst.attack_count = 0
			inst.AnimState:SetBuild(Boss.Art("xd_qxdx"))
			if inst._xd_weapon_fx then
				inst._xd_weapon_fx:Remove()
				inst._xd_weapon_fx = nil
			end
			inst.AnimState:OverrideSymbol("swap_object","xd_qxdx_weapon", "swap")
        elseif inst.mode == 2 then
            spawnht(inst)
			inst.attack_count = 0
            inst.components.timer:StopTimer("superjump_cd")
            inst.components.timer:StartTimer("superjump_cd",12)
            inst.components.timer:StopTimer("spike_cd")
            inst.components.timer:StartTimer("spike_cd",21)
			inst.AnimState:SetBuild(Boss.Art("xd_qxdx_phase2"))
			vortex_spawner(inst,{},{201/255, 67/255, 30/255, 1})
			inst.AnimState:OverrideSymbol("swap_object","xd_qxdx_weapon", "up_swap")
        end
    end
    inst:PushEvent("mode_change",{new = inst.mode ,old = old})
end
local DEFAULT_TALKER_OFFSET = Vector3(0, -400, 0)
local function GetTalkerOffset(inst)
    return DEFAULT_TALKER_OFFSET
end
local function isvalidtarget(inst,target)
	return target ~= nil and target:IsValid() and XD_CanAttackTrget(inst,target)
end
local function use_sword_skill(inst)
	local target = inst.components.combat.target
	if isvalidtarget(inst,target) and inst:IsNear(target,16) then
		local pos = target:GetPosition()
		inst.components.ttk_boss_sword_controller:UseSkill(pos)
		return
	end
end
local fixed_seed_loot = {
    "ttk_boss_zcyseed", "ttk_boss_zcyseed",
    "ttk_lc_hsc_seed", "ttk_lc_dms_seed", "ttk_lc_qfx_seed",
    "ttk_lc_cyh_seed", "ttk_lc_lmg_seed", "ttk_lc_yhh_seed",
}
local function OnDeath(inst)
    if inst._ttk_fixed_seeds_dropped then return end
    inst._ttk_fixed_seeds_dropped = true
    for _, prefab in ipairs(fixed_seed_loot) do
        for _ = 1, (prefab == "ttk_boss_zcyseed" and 1 or 3) do
            inst.components.lootdropper:SpawnLootPrefab(prefab)
        end
    end
end
local function OnEntityWake(inst)
    if not inst.skil_task then
        inst.skil_task = inst:DoStaticPeriodicTask(12,use_sword_skill,12)
    end
end
local function OnEntitySleep(inst)
    if inst.skil_task then
        inst.skil_task:Cancel()
        inst.skil_task = nil
    end
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddDynamicShadow()
    inst:SetPhysicsRadiusOverride(.5)
    MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)
    inst.DynamicShadow:SetSize(1.3, .6)
    inst:AddTag("scarytoprey")
    inst:AddTag("character")
    inst:AddTag("hostile")
	inst:AddTag("notraptrigger")
	inst:AddTag("epic")
	inst:AddTag("ttk_boss_zhenxian")
    inst.Transform:SetFourFaced()
    inst.AnimState:SetBank(Boss.Art("wilson"))
    inst.AnimState:SetBuild(Boss.Art("xd_qxdx"))
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_spawn"))
    inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_appear"))
    inst.AnimState:AddOverrideBuild(Boss.Art("lavaarena_shadow_lunge"))
    inst.AnimState:AddOverrideBuild(Boss.Art("player_lunge"))
    inst.AnimState:AddOverrideBuild(Boss.Art("player_attack_leap"))
    inst.AnimState:AddOverrideBuild(Boss.Art("player_superjump"))
	inst.AnimState:SetSymbolExchange( "hairfront", "swap_hat" )
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:OverrideSymbol("swap_object","xd_qxdx_weapon", "swap")
    inst.AnimState:OverrideSymbol("swap_body", "xd_back_xh", "swap_body")
    inst.AnimState:Hide("ARM_normal")
	inst:AddComponent("talker")
    inst.components.talker:SetOffsetFn(GetTalkerOffset)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst.soundsname = "woodie"
	inst:DoTaskInTime(0,function()
        if inst._vfx_fx_inst == nil then
            inst._vfx_fx_inst = SpawnPrefab("ttk_boss_xjs_curve_fx")
            inst._vfx_fx_inst.entity:AddFollower()
        end
        inst._vfx_fx_inst.entity:SetParent(inst.entity)
        inst._vfx_fx_inst.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -100, 0)
    end)
    inst.attack_count = 0
	inst.attack_round = 0
    inst.mode = 1
    inst.ChangeMode = ChangeMode
    inst:AddComponent("grouptargeter")
    inst:AddComponent("bloomer")
    inst:AddComponent("colouradder")
    inst:AddComponent("debuffable")
    inst.components.debuffable:SetFollowSymbol("headbase", 0, -200, 0)
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 8.5
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = {  allowocean = true, ignorecreep = true }
    inst.components.locomotor:SetSlowMultiplier(.6)
    inst:AddComponent("leader")
    inst.components.leader.OnSave = function(inst, data) end
    inst:AddComponent("knownlocations")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(102500)
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(100)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    inst.components.combat:SetRange(3.5)
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetRetargetFunction(2, Retarget)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ttk_qxdx')
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -80/60
    inst:AddComponent("inspectable")
	inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(function(inst)
        local pos = inst.components.knownlocations:GetLocation("spawnpoint")
        if pos ~= nil then
            local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
            return offset ~= nil and pos + offset or pos
        end
    end)
    inst.Xd_Hoerver_String = function(self,str)
        if inst.mode == 2 then
            table.insert(str,{"Hình thái: Thanh Tụ"})
        else
            table.insert(str,{"Hình thái: Đan Tiên"})
        end
    end
    inst:SetStateGraph("SGttk_qxdx")
    inst:SetBrain(brain)
    inst:AddComponent("colourtweener")
    inst:AddComponent("entitytracker")
    inst:AddComponent("timer")
    inst:ListenForEvent("onattackother", OnAttack)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("death", OnDeath)
	inst:AddComponent("ttk_boss_sword_controller")
	inst.components.ttk_boss_sword_controller.noattack_listen = true
	inst:DoTaskInTime(0,function()
		inst.components.ttk_boss_sword_controller:Summon(1)
	end)
	inst.DoTalk = DoTalk
    inst.DoAoe = DoAoe
    inst.SpawnSpike = spawnspike
    inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep
    return inst
end
local TEXTURE = resolvefilepath("fx/xd_yumao_jydmfx.tex")
local SHADER = "shaders/vfx_particle.ksh"
local COLOUR_ENVELOPE_NAME = "ttk_boss_qxdx_colourenvelope"
local SCALE_ENVELOPE_NAME = "ttk_boss_qxdx_scaleenvelope"
local fxassets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}
local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end
local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,    IntColour(201, 67, 30, 0) },
            { 0.05,  IntColour(201, 67, 30, 200) },
            { 0.85,  IntColour(201, 67, 30, 200) },
            { 1,    IntColour(201, 67, 30, 0) },
        }
   )
    local max_scale = .9
    local end_scale = 1.12
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { max_scale, max_scale } },
            { 0.5,  { max_scale, max_scale } },
            { 1,    { end_scale * max_scale, end_scale * max_scale } },
        }
    )
    InitEnvelope = nil
    IntColour = nil
end
local MAX_LIFETIME = 4.5
local function emit_fn(effect, emitter_fn)
    local vx, vy, vz = 0.006 * UnitRand(), -0.015 + 0.006 * (UnitRand() - 1), 0.006 * UnitRand()
    local lifetime = MAX_LIFETIME * (.6 + math.random() * .4)
    local px, py, pz = emitter_fn()
    local angle = math.random() * 360
    local uv_offset = math.random(0, 7) * .125
    local ang_vel = UnitRand() * 2
    effect:AddRotatingParticleUV(
        0,
        lifetime,
        px, py, pz,
        vx, vy, vz,
        angle, ang_vel,
        uv_offset, 0
    )
end
local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("FX")
    inst.entity:SetPristine()
    inst.persists = false
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end
    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, TEXTURE, SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetGroundPhysics(0, true)
    effect:SetUVFrameSize(0, .125, 1)
    effect:SetMaxNumParticles(0, 512)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 0)
    local tick_time = TheSim:GetTickTime()
    local desired_pps_low = 1
    local desired_pps_high = 4
    local low_per_tick = desired_pps_low * tick_time
    local high_per_tick = desired_pps_high * tick_time
    local num_to_emit = 0
    local emitter_fn = CreateBoxEmitter( -0.1, -0.3, -0.1, 0.1, 0.2, 0.1 )
    inst.last_pos = inst:GetPosition()
    EmitterManager:AddEmitter(inst, nil, function()
        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move*6, 0, 1)
        local per_tick = Lerp(low_per_tick, high_per_tick, move)
        inst.last_pos = inst:GetPosition()
        num_to_emit = num_to_emit + per_tick * math.random() * 3
        while num_to_emit > 1 do
            emit_fn(effect, emitter_fn)
            num_to_emit = num_to_emit - 1
        end
    end)
    return inst
end
local NUM_VARIATIONS = 7
local PHYSICS_RADIUS = .2
local DAMAGE_RADIUS_PADDING = .5
local function ChangeToObstacle(inst)
    inst:RemoveEventCallback("animover", ChangeToObstacle)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Physics:Stop()
    inst.Physics:SetMass(0)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:Teleport(x, 0, z)
end
local function SpikeLaunch(inst, launcher, basespeed, startheight, startradius)
    local x0, y0, z0 = launcher.Transform:GetWorldPosition()
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math.random()
    end
    local sina, cosa = math.sin(angle), math.cos(angle)
    local speed = basespeed + math.random()
    inst.Physics:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
    inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end
local function OnKill2(inst)
    inst:AddTag("NOCLICK")
    inst.Physics:SetActive(false)
    ErodeAway(inst, 1)
end
local function OnKill(inst)
    SpawnPrefab("erode_ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:DoTaskInTime(.5, OnKill2)
end
local function KillSpike(inst)
    if not inst.killed then
        if inst.basefx ~= nil then
            inst.killed = true
            if inst.task ~= nil then
                inst.task:Cancel()
                inst.task = nil
            end
            inst:RemoveEventCallback("animover", ChangeToObstacle)
            if inst.basefx:IsValid() then
                inst.basefx.AnimState:PlayAnimation("base_pst"..tostring(inst.basefx.variation))
                inst:DoTaskInTime(1, OnKill)
            else
                OnKill(inst)
            end
        else
            inst:Remove()
        end
    end
end
local function StartSpike(inst, duration, variation)
    inst.task = inst:DoTaskInTime(duration, KillSpike)
    inst.basefx = SpawnPrefab("fossilspike_base")
    inst.basefx.entity:SetParent(inst.entity)
    inst:ListenForEvent("animover", ChangeToObstacle)
    inst.AnimState:PlayAnimation("fossil_pst")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")
end
local function RestartSpike(inst, delay, duration, variation)
    if inst.task ~= nil then
        inst.task:Cancel()
        if variation == nil then
            local  VARIATIONS = PickSome(1,{1,3,4})
            variation = VARIATIONS
        elseif variation > NUM_VARIATIONS then
            variation = (variation - 1) % NUM_VARIATIONS + 1
        end
        inst.task = inst:DoTaskInTime(delay or 0, StartSpike, duration, variation)
    end
end
local spikerandom = {1,3,4}
local function spikefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("fossil_spike"))
    inst.AnimState:SetBuild(Boss.Art("fossil_spike"))
    inst.AnimState:PlayAnimation("empty")
    inst.AnimState:SetFinalOffset(1)
    inst.Physics:SetMass(99999)
    inst.Physics:SetCollisionGroup(COLLISION.SMALLOBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:SetCapsule(PHYSICS_RADIUS, 2)
    local  VARIATIONS = spikerandom[math.random(#spikerandom)]
    inst.AnimState:OverrideSymbol("bone1", "xd_qxdx_spike", "bone"..tostring(VARIATIONS))
    inst:AddTag("notarget")
    inst:AddTag("groundspike")
    inst:AddTag("fossilspike")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    local  VARIATIONS = PickSome(1,{1,3,4})
    inst.task = inst:DoTaskInTime(0, StartSpike, 5 + math.random(), VARIATIONS)
    inst.RestartSpike = RestartSpike
    inst.KillSpike = KillSpike
    return inst
end
local DRAGONFLY_SPAWNTIMER = "ttk_boss_qxdx_npc"
local function StartSpawning(inst)
    inst.components.timer:StartTimer(DRAGONFLY_SPAWNTIMER, TUNING.XD_BOSS_QXDX_RESPAWNTIME)
end
local function GenerateNewDragon(inst)
    inst.components.childspawner:AddChildrenInside(1)
    inst.components.childspawner:StartSpawning()
end
local function ontimerdone(inst, data)
    if data.name == DRAGONFLY_SPAWNTIMER then
        GenerateNewDragon(inst)
    end
end
local function onspawned(inst, child)
    if child and child.components.entitytracker then
		child.components.entitytracker:TrackEntity("spawnpoint", inst)
    end
end
local function spawnerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("CLASSIFIED")
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ttk_boss_qxdx_npc"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(1, 0)
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(onspawned)
	inst.StartSpawning = StartSpawning
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    return inst
end
return Prefab("ttk_qxdx", fn, assets, prefabs),
    Prefab("ttk_boss_qxdx_spike", spikefn, assets, prefabs),
    Prefab("ttk_boss_qxdx_yumaofx", fxfn, fxassets)
