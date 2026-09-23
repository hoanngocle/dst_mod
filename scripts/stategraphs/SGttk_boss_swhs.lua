-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
local Xd_CalcDamage = Boss.Xd_CalcDamage
require("stategraphs/commonstates")
local hit_recovery_delay = CommonHandlers.HitRecoveryDelay
local actionhandlers =
{
}
local function GetUnequipState(inst, data)
    return (inst:HasTag("wereplayer") and "item_in")
        or (data.eslot ~= EQUIPSLOTS.HANDS and "item_hat")
        or (not data.slip and "item_in")
        or (data.item ~= nil and data.item:IsValid() and "tool_slip")
        or "toolbroke"
        , data.item
end
local function isinrange(inst,target,rd)
    local ang = inst.Transform:GetRotation()
    local x,y,z = target.Transform:GetWorldPosition()
    local angle = inst:GetAngleToPoint( x,0,z )
    local drot = math.abs( ang - angle )
    while drot > 180 do
        drot = math.abs(drot - 360)
    end
    return drot < (rd or 90)
end
local function doaoe(inst,fx)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = XD_GetDamageTargets(x,y,z, 6)
    for i,v in pairs(ents) do
        if  v:IsValid() and  XD_CanAttackTrget(inst,v) and isinrange(inst,v) then
            local damage = inst.sudaji_damage and inst.sudaji_damage[1] and inst.sudaji_damage[1][1] or 56.4
            damage = Xd_CalcDamage(inst,damage,v)
            inst.skillattack = true
            v.components.combat:GetAttacked(inst,damage)
            inst.skillattack = false
            inst:PushEvent("onareaattackother", { target = v})
            if fx and inst.level == 2 and XD_CanAttackTrget(inst,v) then
                v:DoTaskInTime(0.3,function()
                    if v:IsValid() and inst:IsValid() and XD_CanAttackTrget(inst,v) then
                        SpawnAt("ttk_boss_sudaji_hitfx",v)
                        local damage = inst.sudaji_damage and inst.sudaji_damage[1] and inst.sudaji_damage[1][2] or  32.1
                        damage = Xd_CalcDamage(inst,damage,v)
                        inst.skillattack = true
                        v.components.combat:GetAttacked(inst,damage)
                        inst.skillattack = false
                    end
                end)
            end
        end
    end
end
local function NotBlocked(pt)
	return not TheWorld.Map:IsGroundTargetBlocked(pt)
end
local xu = {{0,1},{1,1},{1,-1},{0,-1}}
local function GoAngle(player, w, h)
	local t = {}
	local d = player.entity
	for i,v in ipairs(xu) do
		local x,_,z = d:LocalToWorldSpace(v[1] * h, 0, v[2] * w)
		table.insert(t, {x,z})
	end
	local range = ( ( w * w ) + ( h * h ) ) ^ 0.5
	return t, range, Point( d:LocalToWorldSpace(h * 0.5, 0, 0) )
end
local function tiaopiaoe(inst)
    local rot = inst.Transform:GetRotation()
	local tbl = GoAngle(inst, 4, 9)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = XD_GetDamageTargets(x,y,z, 9)
    for i,v in pairs(ents) do
        if  v:IsValid() and  XD_CanAttackTrget(inst,v) then
            local pos = v:GetPosition()
            if TheSim:WorldPointInPoly(pos.x,pos.z, tbl) then
                local damage = 375.3
                damage = Xd_CalcDamage(inst,damage,v)
                inst.skillattack = true
                v.components.combat:GetAttacked(inst,damage)
                inst.skillattack = false
                inst:PushEvent("onareaattackother", { target = v})
                if inst.level == 2 and XD_CanAttackTrget(inst,v) then
                    v:DoTaskInTime(0.3,function()
                        if v:IsValid() and inst:IsValid() and XD_CanAttackTrget(inst,v) then
                            SpawnAt("ttk_boss_sudaji_hitfx",v)
                            damage = Xd_CalcDamage(inst,45,v)
                            inst.skillattack = true
                            v.components.combat:GetAttacked(inst,damage)
                            inst.skillattack = false
                        end
                    end)
                end
            end
        end
    end
end
local function tiaopiaoenew(inst)
    local rot = inst.Transform:GetRotation()
	local tbl = GoAngle(inst, 4, 9)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = XD_GetDamageTargets(x,y,z, 9)
    for i,v in pairs(ents) do
        if  v:IsValid() and  XD_CanAttackTrget(inst,v) then
            local pos = v:GetPosition()
            if TheSim:WorldPointInPoly(pos.x,pos.z, tbl) then
                local damage = inst.components.combat.defaultdamage * 6.5
                damage = Xd_CalcDamage(inst,damage,v)
                inst.skillattack = true
                v.components.combat:GetAttacked(inst,damage)
                inst.skillattack = false
                inst:PushEvent("onareaattackother", { target = v})
            end
        end
    end
end
local function DoLunge(doer, startingpos, targetpos)
    local p1 = { x = startingpos.x, y = startingpos.z }
    local p2 = { x = targetpos.x, y = targetpos.z }
    local dx, dy = p2.x - p1.x, p2.y - p1.y
    local dist = dx * dx + dy * dy
    local toskip = {}
    local pv = {}
    local r, cx, cy
    if dist > 0 then
        dist = math.sqrt(dist)
        r = 3
        dx, dy = dx / dist, dy / dist
        cx, cy = p1.x + dx * r, p1.y + dy * r
        local ents = XD_GetDamageTargets(cx, 0, cy,3)
        for i,v in pairs(ents) do
            toskip[v] = true
            if v and v:IsValid() and XD_CanAttackTrget(doer,v) then
                pv.x, pv._, pv.y = v.Transform:GetWorldPosition()
                local vrange = 1 + v:GetPhysicsRadius(0.5)
                if DistPointToSegmentXYSq(pv, p1, p2) < vrange * vrange then
                    local damage =  doer.sudaji_damage and doer.sudaji_damage[2] and doer.sudaji_damage[2][1]  or 303.8
                    damage = Xd_CalcDamage(doer,damage,v)
                    v.components.combat:GetAttacked(doer,damage)
                end
            end
        end
    end
    local angle = (doer.Transform:GetRotation() + 90) * DEGREES
    local p3 = { x = p2.x + 2 * math.sin(angle), y = p2.y + 2 * math.cos(angle) }
    local ents = XD_GetDamageTargets(p2.x, 0, p2.y,5)
    for i,v in pairs(ents) do
        if v and v:IsValid() and not toskip[v]  and XD_CanAttackTrget(doer,v) then
            pv.x, pv._, pv.y = v.Transform:GetWorldPosition()
            local vradius = v:GetPhysicsRadius(0.5)
            local vrange = 2 + vradius
            if distsq(pv.x, pv.y, p2.x, p2.y) < vrange * vrange then
                vrange = 1 + vradius
                if DistPointToSegmentXYSq(pv, p2, p3) < vrange * vrange then
                    local damage = doer.sudaji_damage and doer.sudaji_damage[2] and doer.sudaji_damage[2][1]  or 303.8
                    damage = Xd_CalcDamage(doer,damage,v)
                    v.components.combat:GetAttacked(doer,damage)
                end
            end
        end
    end
    local fx = SpawnPrefab("ttk_boss_sudaji_lungefx")
    fx.Transform:SetPosition(startingpos.x,startingpos.y+1,startingpos.z)
    fx.Transform:SetRotation(doer:GetRotation())
    return true
end
local function dojunpaoe(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = XD_GetDamageTargets(x,y,z, 6)
    for i,v in pairs(ents) do
        if  v:IsValid() and  XD_CanAttackTrget(inst,v) and isinrange(inst,v) then
            local damage = 375.3
            damage = Xd_CalcDamage(inst,damage,v)
            inst.skillattack = true
            v.components.combat:GetAttacked(inst,damage)
            inst.skillattack = false
            inst:PushEvent("onareaattackother", { target = v})
            if inst.level == 2 and XD_CanAttackTrget(inst,v) then
                v:DoTaskInTime(0.3,function()
                    if v:IsValid() and inst:IsValid() and XD_CanAttackTrget(inst,v) then
                        SpawnAt("ttk_boss_sudaji_hitfx",v)
                        local damage = 45
                        damage = Xd_CalcDamage(inst,damage,v)
                        inst.skillattack = true
                        v.components.combat:GetAttacked(inst,damage)
                        inst.skillattack = false
                    end
                end)
            end
        end
    end
end
local function onattacked(inst, data, hitreact_cooldown, max_hitreacts, skip_cooldown_fn)
    if inst.components.health ~= nil and not inst.components.health:IsDead()
		and not hit_recovery_delay(inst, hitreact_cooldown, max_hitreacts, skip_cooldown_fn)
        and not inst.sg:HasStateTag("skill")
        and (not inst.sg:HasStateTag("busy")
            or inst.sg:HasStateTag("caninterrupt")
            or inst.sg:HasStateTag("frozen")) then
        inst.sg:GoToState("hit")
    end
end
local function SpawnEffect(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("ttk_boss_ht_sand_puff_back").Transform:SetPosition(x, y - .1, z)
    SpawnPrefab("ttk_boss_ht_sand_puff_front").Transform:SetPosition(x, y, z)
end
local function setflyable(inst, flyable,fx)
    if flyable then
        if fx then
            fx:Remove()
        end
        inst.flyfx = SpawnPrefab('ttk_boss_ht_flyerfx_cloud')
        inst.flyfx:config({})
        inst.flyfx:init()
        inst:AddChild(inst.flyfx)
        inst.Physics:SetCapsule(0.5, -2.5)
    else
        if inst.flyfx then
            inst.sg.statemem.flyfx = inst.flyfx
            inst:RemoveChild(inst.flyfx)
            inst.flyfx = nil
            local pos = inst:GetPosition()
            if inst.sg.statemem.flyfx then
                inst.sg.statemem.flyfx.Transform:SetPosition(pos.x, pos.y, pos.z)
            end
        end
        inst.Physics:SetCapsule(0.5, 1)
    end
end
local events=
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreezeEx(),
	EventHandler("attacked", function(inst, data)
        onattacked(inst, data, 0.5, 2)
	end),
	EventHandler("doattack", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
			if inst.prefab == "ttk_boss_htz_txm" and inst.canspell and inst.components.timer:TimerExists("lifetime") and inst.components.timer:GetTimeLeft("lifetime") < 4 then
                inst.sg:GoToState("txm_spell", data ~= nil and data.target or nil)
            elseif inst.components.combat.attackrange == 5 and inst.lunce_count and inst.lunce_count < 2 then
                inst.sg:GoToState("txm_lunge_pre", data ~= nil and data.target or nil)
            elseif inst.components.combat.attackrange == 6 then
                inst.sg:GoToState("lunge_pre", data ~= nil and data.target or nil)
            elseif (inst.prefab == "ttk_boss_zhouwang_shadow" or inst.prefab == "ttk_boss_zhouwang")  and inst.attack_count >= 9 then
                inst.sg:GoToState("threeattack", data ~= nil and data.target or nil)
            else
				inst.sg:GoToState("attack", data ~= nil and data.target or nil)
			end
		end
	end),
	EventHandler("do_ht_attack", function(inst, data)
		if not inst.components.combat:InCooldown() and inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("ht_attack", data ~= nil and data.target or nil)
		end
	end),
	EventHandler("skill1", function(inst, data)
		if not inst.components.health:IsDead() and not (inst.sg:HasStateTag("hit") or inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("nointerrupt")) then
			inst.skill1target = nil
			inst.sg:GoToState("skill1", data and data.target or nil)
		end
	end),
	EventHandler("skill2", function(inst, data)
		if not inst.components.health:IsDead() and not (inst.sg:HasStateTag("hit") or inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("nointerrupt")) then
			inst.skill2pos = nil
			inst.sg:GoToState("skill2", {pos = data and data.pos,spellname = "skill2"})
		end
	end),
    EventHandler("skill3", function(inst, data)
        if not inst.components.health:IsDead() and not (inst.sg:HasStateTag("hit") or inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("nointerrupt")) then
            inst.skill3pos = nil
            inst.sg:GoToState("skill3", {pos = data and data.pos,spellname = "skill3"})
        end
    end),
    EventHandler("goaway", function(inst, data)
        if inst.shouldgoaway and not inst.components.health:IsDead() and not (inst.sg:HasStateTag("hit") or inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("nointerrupt")) then
            inst.sg:GoToState("goaway")
        end
    end),
    EventHandler("oneat", function(inst,data)
        local obj = data and data.food or nil
        if obj == nil then
            return
        end
        if obj.components.edible.foodtype == FOODTYPE.MEAT then
            inst.sg:GoToState("eat")
        else
            inst.sg:GoToState("quickeat")
        end
    end),
    EventHandler("oneat_levelitem", function(inst,data)
        inst.sg:GoToState("eat")
    end),
    EventHandler("dance", function(inst)
        if not inst.sg:HasStateTag("busy") and (inst._brain_dancedata ~= nil or not inst.sg:HasStateTag("dancing")) then
            inst.sg:GoToState("dance")
        end
    end),
    EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if data.eslot == EQUIPSLOTS.BEARD then
            return nil
        elseif data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
            inst.sg:GoToState("heavylifting_start")
		elseif inst.components.inventory and inst.components.inventory:IsHeavyLifting()
            and not inst.components.rider:IsRiding() then
            if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("heavylifting_item_hat")
            end
        elseif (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling")) and not inst:HasTag("wereplayer") then
            inst.sg:GoToState(
                (data.item ~= nil and data.item.projectileowner ~= nil and "catch_equip") or
                (data.eslot == EQUIPSLOTS.HANDS and "item_out") or
                "item_hat"
            )
        elseif data.item ~= nil and data.item.projectileowner ~= nil then
            SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
        end
    end),
    EventHandler("unequip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("heavylifting_stop")
            end
        elseif inst.components.inventory and inst.components.inventory:IsHeavyLifting()
            and not inst.components.rider:IsRiding() then
            if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("heavylifting_item_hat")
            end
        elseif inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling") then
            inst.sg:GoToState(GetUnequipState(inst, data))
        end
    end),
    EventHandler("skillpos", function(inst,data)
        if not inst.sg:HasStateTag("attack") and data and data.x and data.z then
            local time = inst.components.timer:GetTimeLeft("lifetime") or 0
            if not inst.components.health:IsDead() and time > 2.2 then
                inst.skillpos = data
                if inst:GetDistanceSqToPoint(inst.skillpos.x, 0, inst.skillpos.z) < 64 then
                    inst.sg:GoToState("tiaopi")
                else
                    inst.sg:GoToState("superjump_start")
                end
            end
        end
    end),
    EventHandler("ttk_boss_wukong_shadow_skill", function(inst,data)
        if data and data.skill then
            inst.sg:GoToState("ttk_boss_wukong_skill",data.skill)
        end
    end),
}
local function TrySplashFX(inst, size)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) and not inst.flyfx then
		SpawnPrefab("ocean_splash_"..(size or "med")..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
		return true
	end
end
local function TryStepSplash(inst)
	local t = GetTime()
	if (inst.sg.mem.laststepsplash == nil or inst.sg.mem.laststepsplash + .1 < t) and TrySplashFX(inst) then
		inst.sg.mem.laststepsplash = t
	end
end
local function IsNearOther(pt, newpillars)
	for i, v in ipairs(newpillars) do
		if distsq(pt.x, pt.z, v.x, v.z) < 1 then
			return true
		end
	end
	return false
end
local function DoPillarsTarget(target, caster, item, newpillars, map, x0, z0)
	target:PushEvent("dispell_shadow_pillars")
	local padding =
		(target:HasTag("epic") and 1) or
		(target:HasTag("smallcreature") and 0) or
		.75
	local radius = math.max(1, target:GetPhysicsRadius(0) + padding)
	local circ = PI2 * radius
	local num = math.floor(circ / 1.4 + .5)
	local period = 1 / num
	local delays = {}
	for i = 0, num - 1 do
		table.insert(delays, i * period)
	end
	local platform = target:GetCurrentPlatform()
	local flying = not platform and target:HasTag("flying")
	local ent = SpawnPrefab("shadow_pillar_target")
	ent.Transform:SetPosition(x0, 0, z0)
	ent:SetDelay(delays[#delays])
	ent:SetTarget(target, radius, platform ~= nil)
    local old_StartTimer = ent.components.timer.StartTimer
    ent.components.timer.StartTimer = function(self,name,time)
        if name == "lifetime" then
            time = 4
        end
        return old_StartTimer(self,name,time)
    end
	local theta = math.random() * PI2
	local delta = PI2 / num
	for i = 1, num do
		local pt = Vector3(x0 + math.cos(theta) * radius, 0, z0 - math.sin(theta) * radius)
		if not IsNearOther(pt, newpillars) and
			map:IsPassableAtPoint(pt.x, 0, pt.z, true) and
			flying or (map:GetPlatformAtPoint(pt.x, pt.z) == platform) and
			not map:IsGroundTargetBlocked(pt) then
			ent = SpawnPrefab("shadow_pillar")
			ent.Transform:SetPosition(pt:Get())
			ent:SetDelay(table.remove(delays, math.random(#delays)))
			ent:SetTarget(target, platform ~= nil)
            local old_StartTimer = ent.components.timer.StartTimer
            ent.components.timer.StartTimer = function(self,name,time)
                if name == "lifetime" then
                    time = 4
                end
                return old_StartTimer(self,name,time)
            end
			newpillars[ent] = pt
		end
		theta = theta + delta
	end
	if not (target.sg ~= nil and target.sg:HasStateTag("noattack")) then
		target:PushEvent("attacked", { attacker = caster, damage = 0, weapon = item })
	end
end
local function doattack(inst,damage,range,fx,fn,aoepos,norate)
    if inst and inst:IsValid() then
        local x,y,z = inst.Transform:GetWorldPosition()
        if aoepos then
            x,y,z = aoepos:Get()
        end
        local ents = XD_GetDamageTargets(x, 0, z,range or 3)
        for i,v in pairs(ents) do
            if v and v:IsValid() and v ~= inst and XD_CanAttackTrget(inst,v)
                and (not fn or fn(inst,v,inst)) then
                local damage = damage or 10
                if not norate then
                    damage = Xd_CalcDamage(inst,damage,v)
                end
                if fx then
                    SpawnAt(fx,v,Vector3(2,2,2),Vector3(0,1,0))
                end
                v.components.combat:GetAttacked(inst,damage)
            end
        end
    end
end
local function DoSound(inst, sound)
	inst.SoundEmitter:PlaySound(sound)
end
local states = {
	State{
		name = "spawn",
		tags = { "busy", "noattack", "temp_invincible" },
		onenter = function(inst, mult)
            inst:Show()
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("minion_spawn")
			mult = mult or (0.8 + math.random() * 0.2)
			inst.AnimState:SetDeltaTimeMultiplier(mult)
			mult = 1 / mult
			inst.sg.statemem.tasks =
			{
                inst:DoTaskInTime(0 * FRAMES * mult, DoSound, "maxwell_rework/shadow_worker/spawn"),
				inst:DoTaskInTime(0 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(20 * FRAMES * mult, TrySplashFX),
				inst:DoTaskInTime(44 * FRAMES * mult, TrySplashFX, "small"),
			}
			inst.sg:SetTimeout(70 * FRAMES * mult)
		end,
		ontimeout = function(inst)
			inst.sg:AddStateTag("caninterrupt")
			inst.AnimState:SetDeltaTimeMultiplier(1)
		end,
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.spawn then
				inst.AnimState:SetDeltaTimeMultiplier(1)
			end
			for i, v in ipairs(inst.sg.statemem.tasks) do
				v:Cancel()
			end
		end,
	},
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
        end,
        timeline =
        {
			TimeEvent(1 * FRAMES, function(inst)
                if inst.prefab == "ttk_boss_htz_txm" and inst:GetTimeAlive() < 0.1 then
                    inst.sg:GoToState("spawn")
                    return
                end
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if inst.flyfx then
                inst.AnimState:PlayAnimation("xd_fly_pre")
            else
                inst.AnimState:PlayAnimation("run_pre")
            end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
        timeline =
        {
			TimeEvent(1 * FRAMES, TryStepSplash),
			TimeEvent(3 * FRAMES, function(inst)
                PlayFootstep(inst)
            end),
        },
    },
    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        onenter = function(inst)
            inst.components.locomotor:RunForward()
            if inst.flyfx then
                if not inst.AnimState:IsCurrentAnimation("xd_fly_loop") then
                    inst.AnimState:PlayAnimation("xd_fly_loop", true)
                end
            else
                if not inst.AnimState:IsCurrentAnimation("run_loop") then
                    inst.AnimState:PlayAnimation("run_loop", true)
                end
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,
        timeline =
        {
			TimeEvent(5 * FRAMES, TryStepSplash),
            TimeEvent(7 * FRAMES, function(inst)
                PlayFootstep(inst)
				inst.sg.mem.laststepsplash = GetTime()
            end),
			TimeEvent(13 * FRAMES, TryStepSplash),
            TimeEvent(15 * FRAMES, function(inst)
                PlayFootstep(inst)
				inst.sg.mem.laststepsplash = GetTime()
            end),
        },
        ontimeout = function(inst)
			inst.sg.statemem.running = true
            inst.sg:GoToState("run")
        end,
		onexit = function(inst)
			if not inst.sg.statemem.running then
				TryStepSplash(inst)
			end
		end,
    },
    State{
        name = "run_stop",
        tags = {"canrotate", "idle"},
        onenter = function(inst)
            inst.Physics:Stop()
            if inst.flyfx then
                inst.AnimState:PlayAnimation("xd_fly_pst")
            else
                inst.AnimState:PlayAnimation("run_pst")
            end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "attack",
		tags = {"attack", "abouttoattack"},
		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk", false)
			inst.components.combat:StartAttack()
			if target == nil then
				target = inst.components.combat.target
			end
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			else
				target = nil
			end
        end,
        timeline =
        {
			TimeEvent(6 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
			TimeEvent(8*FRAMES, function(inst)
				inst.sg:RemoveStateTag("abouttoattack")
				local target = inst.sg.statemem.target
				inst.components.combat:DoAttack(target)
			end),
            TimeEvent(12*FRAMES, function(inst)
            end),
            TimeEvent(13*FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
                local time = inst.components.timer:GetTimeLeft("lifetime") or 0
                if inst.skillpos ~= nil and time > 2.2 then
                    if inst:GetDistanceSqToPoint(inst.skillpos.x, inst.skillpos.y, inst.skillpos.z) < 64 then
                        inst.sg:GoToState("tiaopi")
                    else
                        inst.sg:GoToState("superjump_start")
                    end
                elseif inst.levelup and not inst.components.timer:TimerExists("swhs_tiaopi") then
                    inst.sg:GoToState("tiaopi")
                end
            end),
        },
        events =
        {
			EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
    },
    State{
        name = "ht_attack",
		tags = {"attack", "abouttoattack"},
		onenter = function(inst,target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk", false)
            local target = target or inst.owner
			if target ~= nil and target:IsValid() then
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
        end,
        timeline =
        {
			TimeEvent(6 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
			TimeEvent(8*FRAMES, function(inst)
				inst.sg:RemoveStateTag("abouttoattack")
                inst:Do_Ht_Attack()
			end),
            TimeEvent(12*FRAMES, function(inst)
            end),
            TimeEvent(13*FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
            end),
        },
        events =
        {
			EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
    },
    State{
        name = "skill1",
		tags = {"attack", "abouttoattack","busy"},
		onenter = function(inst,target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk", false)
			if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			end
        end,
        timeline =
        {
			TimeEvent(6 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
			TimeEvent(8*FRAMES, function(inst)
				inst.sg:RemoveStateTag("abouttoattack")
                inst:Do_Gd_Attack(inst.sg.statemem.target)
			end),
            TimeEvent(12*FRAMES, function(inst)
            end),
            TimeEvent(13*FRAMES, function(inst)
                inst.sg:RemoveStateTag("attack")
            end),
        },
        events =
        {
			EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
		end,
    },
	State{
        name = "skill2",
        tags = { "busy", "flying", "busy" },
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()
            local colour = { 239/255, 186/255, 0/255 }
            inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(colour)
            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
            inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
            inst.sg.statemem.pos = data.pos
        end,
        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(53 * FRAMES, function(inst)
                inst.sg.statemem.stafffx = nil
                inst.sg.statemem.stafflight = nil
                inst:DoSkill2Cast(inst.sg.statemem.pos)
            end),
			TimeEvent(69 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    },
    State{
        name = "skill3",
		tags = {"attack","busy"},
		onenter = function(inst,data)
            if inst.skill3_playerpos and data.pos then
			    inst.components.locomotor:Stop()
                SpawnEffect(inst)
                setflyable(inst, false)
                inst.Physics:Teleport(inst.skill3_playerpos.x,0,inst.skill3_playerpos.z)
                SpawnEffect(inst)
                inst.sg.statemem.skillpos = data.pos
            end
        end,
        timeline =
        {
			TimeEvent(0.1, function(inst)
                SpawnPrefab("electricchargedfx"):SetTarget(inst)
			    inst.AnimState:PlayAnimation("xd_tiaopi")
                if inst.sg.statemem.skillpos then
				    inst:ForceFacePoint(inst.sg.statemem.skillpos)
			    end
			end),
			TimeEvent(0.49, function(inst)
                local fx  = SpawnPrefab("ttk_boss_suduji_xyjfx")
                fx.entity:SetParent(inst.entity)
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0, true, nil, 0, 10)
			end),
            TimeEvent(1.2, function(inst)
                inst.SoundEmitter:PlaySound("xd_sudaji_sound/xd_sudaji_sound/ground",nil,0.5)
			end),
            TimeEvent(1.33, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/dustpoof")
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                inst:DoSkill3Cast()
			end),
        },
        events =
        {
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.flyfx then
                        local pos = inst.sg.statemem.flyfx:GetPosition()
                        SpawnEffect(inst)
                        setflyable(inst, true, inst.sg.statemem.flyfx)
                        inst.Physics:Teleport(pos.x,2.5,pos.z)
                        SpawnEffect(inst)
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
		onexit = function(inst)
		end,
    },
    State{
        name = "threeattack",
		tags = {"attack", "abouttoattack","skill"},
		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("xd_threeatk")
			inst.components.combat:StartAttack()
			if target == nil then
				target = inst.components.combat.target
			end
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst:ForceFacePoint(target.Transform:GetWorldPosition())
			else
				target = nil
			end
        end,
        timeline =
        {
            TimeEvent(0, function(inst)
				inst.SoundEmitter:PlaySound("xd_sudaji_sound/xd_sudaji_sound/threehit",nil,0.5)
			end),
			TimeEvent(0.232, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
            TimeEvent(0.242, function(inst)
                doaoe(inst)
			end),
			TimeEvent(0.643, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
            TimeEvent(0.674, function(inst)
                doaoe(inst)
			end),
            TimeEvent(1.176, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
            TimeEvent(1.194, function(inst)
                inst.sg:RemoveStateTag("abouttoattack")
                doaoe(inst,true)
			end),
            TimeEvent(1.7, function(inst)
                inst.sg:RemoveStateTag("attack")
            end),
        },
        events =
        {
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local time = inst.components.timer:GetTimeLeft("lifetime") or 0
                    if inst.skillpos ~= nil and time > 2.2 then
                        if inst:GetDistanceSqToPoint(inst.skillpos.x, inst.skillpos.y, inst.skillpos.z) < 64 then
                            inst.sg:GoToState("tiaopi")
                        else
                            inst.sg:GoToState("superjump_start")
                        end
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
		onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
			end
            inst.attack_count = 0
		end,
    },
    State{
        name = "tiaopi",
		tags = {"attack", "abouttoattack","skill"},
		onenter = function(inst)
            SpawnPrefab("electricchargedfx"):SetTarget(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("xd_tiaopi")
			inst.components.combat:StartAttack()
            if inst.skillpos then
				inst:ForceFacePoint(inst.skillpos)
                inst.skillpos = nil
			end
            if inst.levelup then
                inst.components.timer:StartTimer("swhs_tiaopi",10)
            end
        end,
        timeline =
        {
			TimeEvent(0.48, function(inst)
                local fx  = SpawnPrefab("ttk_boss_suduji_xyjfx")
                fx.entity:SetParent(inst.entity)
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0, true, nil, 0, 10)
			end),
            TimeEvent(1.1, function(inst)
                inst.SoundEmitter:PlaySound("xd_sudaji_sound/xd_sudaji_sound/ground",nil,0.5)
			end),
            TimeEvent(1.23, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/dustpoof")
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                if inst.levelup then
                    tiaopiaoenew(inst)
                else
                    tiaopiaoe(inst)
                end
			end),
        },
        events =
        {
			EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
		onexit = function(inst)
		end,
    },
    State{
        name = "frozen",
        tags = { "busy", "frozen", "nopredict", "nodangle" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            if inst.components.freezable == nil then
                inst.sg:GoToState("hit", true)
            elseif inst.components.freezable:IsThawing() then
                inst.sg.statemem.isstillfrozen = true
                inst.sg:GoToState("thaw")
            elseif not inst.components.freezable:IsFrozen() then
                inst.sg:GoToState("hit", true)
            end
        end,
        events =
        {
            EventHandler("onthaw", function(inst)
                inst.sg.statemem.isstillfrozen = true
                inst.sg:GoToState("thaw")
            end),
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },
        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },
    State{
        name = "thaw",
        tags = { "busy", "thawing", "nopredict", "nodangle" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
        end,
        events =
        {
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },
        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },
    State{
        name = "hit",
        tags = { "busy", "pausepredict" },
        onenter = function(inst, frozen)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("hit")
            if frozen == "noimpactsound" then
                frozen = nil
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end
			local stun_frames = math.min(inst.AnimState:GetCurrentAnimationNumFrames(), frozen and 10 or 6)
            inst.sg:SetTimeout(stun_frames * FRAMES)
            CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "death",
        tags = { "busy", "dead", "pausepredict", "nomorph" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()
            if inst.components.container then
                inst.components.container:Close()
                inst.components.container.canbeopened = false
            end
            inst.AnimState:PlayAnimation(inst.deathanimoverride or "death")
            inst.AnimState:Hide("swap_arm_carry")
            if inst.components.burnable then
                inst.components.burnable:Extinguish()
            end
            inst.sg:ClearBufferedEvents()
        end,
        timeline =
        {
        },
        onexit = function(inst)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.dodespawn then
                        inst:dodespawn(true)
                    else
                        inst:Remove()
                    end
                end
            end),
        },
    },
    State{
        name = "eat",
        tags = { "busy", "nodangle" },
        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
            if inst.components.hunger then
                inst.components.hunger:Pause()
            end
        end,
        timeline =
        {
            TimeEvent(70 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("eating")
            end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            if inst.components.hunger then
                inst.components.hunger:Resume()
            end
        end,
    },
    State{
        name = "quickeat",
        tags = { "busy" },
        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
            inst.AnimState:PlayAnimation("quick_eat_pre")
            inst.AnimState:PushAnimation("quick_eat", false)
            if inst.components.hunger then
                inst.components.hunger:Pause()
            end
        end,
        timeline =
        {
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
            if inst.components.hunger then
                inst.components.hunger:Resume()
            end
        end,
    },
    State{
        name = "dance",
        tags = {"idle", "dancing"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            local ignoreplay = inst.AnimState:IsCurrentAnimation("run_pst")
            if inst._brain_dancedata and #inst._brain_dancedata > 0 then
                for _, data in ipairs(inst._brain_dancedata) do
                    if data.play and not ignoreplay then
                        inst.AnimState:PlayAnimation(data.anim, data.loop)
                    else
                        inst.AnimState:PushAnimation(data.anim, data.loop)
                    end
                end
            else
                if ignoreplay then
                    inst.AnimState:PushAnimation("emoteXL_pre_dance0")
                else
                    inst.AnimState:PlayAnimation("emoteXL_pre_dance0")
                end
                inst.AnimState:PushAnimation("emoteXL_loop_dance0", true)
            end
            inst._brain_dancedata = nil
        end,
    },
    State{
        name = "heavylifting_start",
        tags = { "busy", "pausepredict" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("heavy_pickup_pst")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "heavylifting_item_hat",
        tags = { "busy", "pausepredict" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("heavy_item_hat")
            inst.AnimState:PushAnimation("heavy_item_hat_pst", false)
            inst.sg:SetTimeout(12 * FRAMES)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },
    State{
        name = "catch_equip",
        tags = { "idle" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("catch_pre")
            inst.AnimState:PushAnimation("catch", false)
        end,
        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg.statemem.playedfx = true
                SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_catch")
            end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.playedfx then
                SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
            end
        end,
    },
    State{
        name = "item_in",
        tags = { "idle", "nodangle" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            if inst.sg.statemem.followfx ~= nil then
                for i, v in ipairs(inst.sg.statemem.followfx) do
                    v:Remove()
                end
            end
        end,
    },
    State{
        name = "item_out",
        tags = { "idle", "nodangle" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "item_hat",
        tags = { "idle" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "heavylifting_stop",
        tags = { "busy", "pausepredict" },
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)
            local stun_frames = 6
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },
    State{
        name = "toolbroke",
        tags = { "busy", "pausepredict" },
        onenter = function(inst, tool)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            if tool == nil or not tool.nobrokentoolfx then
                SpawnPrefab("brokentool").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
            inst.sg.statemem.toolname = tool ~= nil and tool.prefab or nil
            inst.sg:SetTimeout(10 * FRAMES)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
        onexit = function(inst)
            if inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },
    State{
        name = "tool_slip",
        tags = { "busy", "pausepredict" },
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/common/tool_slip")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            local splash = SpawnPrefab("splash")
            splash.entity:SetParent(inst.entity)
            splash.entity:AddFollower()
            splash.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0)
            if inst.components.talker ~= nil then
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_TOOL_SLIP"))
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.sg:SetTimeout(10 * FRAMES)
        end,
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },
	State{
		name = "lunge_pre",
		tags = { "attack", "busy","skill" },
		onenter = function(inst, target)
			inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("lunge_pre")
			inst.components.combat:StartAttack()
			if target == nil then
				target = inst.components.combat.target
			end
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			else
				target = nil
			end
		end,
		onupdate = function(inst)
			if inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					inst.sg.statemem.targetpos = inst.sg.statemem.target:GetPosition()
				else
					inst.sg.statemem.target = nil
				end
			end
		end,
        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/twirl")
            end),
        },
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.lunge = true
                    inst.AnimState:PlayAnimation("lunge_lag")
                    inst.sg:GoToState("lunge_loop",{targetpos = inst.sg.statemem.targetpos})
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.lunge then
				inst.components.combat:CancelAttack()
                inst.components.combat:SetRange(4)
			end
		end,
	},
	State{
		name = "lunge_loop",
		tags = { "attack", "busy", "noattack", "temp_invincible","skill" },
		onenter = function(inst, data)
            local pos = data.targetpos
            inst.targets = {}
            inst.AnimState:PlayAnimation("lunge_pst")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")
            local pt = inst:GetPosition()
			local dir
			if pos and pos.x ~= pos.x or pos.z ~= pos.z then
				dir = inst:GetAngleToPoint(pos)
				inst.Transform:SetRotation(dir)
			end
            local facing_angle = inst.Transform:GetRotation() * DEGREES
            local targetpos = Vector3(pt.x + 7 * math.cos(facing_angle), pt.y + 0, pt.z - 7 * math.sin(facing_angle))
            local halftargetpos = Vector3(pt.x + 3.5 * math.cos(facing_angle), pt.y + 0, pt.z - 3.5 * math.sin(facing_angle))
            if DoLunge(inst, pt, targetpos) then
                inst.sg.statemem.lunge = true
                inst.Physics:Teleport(targetpos.x, 0, targetpos.z)
                inst:DoTaskInTime(0.3,function()
                    local fx = SpawnAt("ttk_boss_sudaji_lungehitfx",halftargetpos)
                    fx.owner = inst
                end)
            end
		end,
        timeline =
        {
            FrameEvent(8, function(inst)
            end),
            TimeEvent(12 * FRAMES, function(inst)
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.components.combat:SetRange(4)
        end,
	},
	State{
		name = "land",
        tags = { "aoe", "doing", "busy", "nopredict", "nomorph" },
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("superjump_land")
            inst.AnimState:SetMultColour(1, 1, 1, .4)
            inst.sg:SetTimeout(22 * FRAMES)
            inst.DynamicShadow:Enable(false)
        end,
        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                local c = math.min(1, inst.sg.statemem.flash)
                inst.components.colouradder:PushColour("superjump", c, c, 0, 0)
            end
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst.AnimState:SetMultColour(1, 1, 1, .7)
                inst.components.colouradder:PushColour("superjump", .1, .1, 0, 0)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, .9)
                inst.components.colouradder:PushColour("superjump", .2, .2, 0, 0)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.components.colouradder:PushColour("superjump", .4, .4, 0, 0)
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("superjump", 1, 1, 0, 0)
                inst.components.bloomer:PushBloom("superjump", "shaders/anim.ksh", -2)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                if inst.sg.statemem.flash then
                    inst.sg.statemem.flash = 1.3
                end
                inst.sg:RemoveStateTag("noattack")
                local pt = inst:GetPosition()
                SpawnPrefab("groundpoundring_fx").Transform:SetPosition(pt:Get())
                local fx = SpawnPrefab("ttk_boss_sinkhole")
                fx.Transform:SetPosition(pt:Get())
                fx:SetFx()
                local points = XD_GetGroundPoints(pt)
                local map = TheWorld.Map
                for i, v1 in ipairs(points) do
                    for i,v in ipairs(v1) do
                        if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                            SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
                        end
                    end
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("superjump")
            end),
            TimeEvent(19 * FRAMES, PlayFootstep),
        },
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.DynamicShadow:Enable(true)
            inst.components.bloomer:PopBloom("superjump")
            inst.components.colouradder:PopColour("superjump")
        end,
	},
	State{
        name = "superjump_start",
        tags = { "attack", "doing", "busy", "nointerrupt", "nomorph","skill" },
        onenter = function(inst,pos)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("superjump_pre")
            if inst.skillpos then
				inst:ForceFacePoint(inst.skillpos)
                inst.sg.statemem.pos = Vector3(inst.skillpos.x,0,inst.skillpos.z)
                inst.skillpos = nil
			end
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("superjump_pre") and inst.sg.statemem.pos then
                        inst.AnimState:PlayAnimation("superjump_lag")
                        inst.sg:GoToState("superjump", inst.sg.statemem.pos)
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },
	State{
        name = "superjump",
        tags = { "attack", "doing", "busy", "nointerrupt", "nopredict", "nomorph" ,"skill"},
        onenter = function(inst, pos)
            if pos ~= nil and inst.AnimState:IsCurrentAnimation("superjump_lag") then
                inst.AnimState:PlayAnimation("superjump")
                inst.AnimState:SetMultColour(.8, .8, .8, 1)
                inst.components.colouradder:PushColour("superjump", .1, .1, .1, 0)
                inst.sg.statemem.startingpos = inst:GetPosition()
                inst.sg.statemem.targetpos = pos
                if inst.sg.statemem.startingpos.x ~= pos.x or inst.sg.statemem.startingpos.z ~= pos.z then
                    inst:ForceFacePoint(pos:Get())
                end
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
                inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                inst.sg:SetTimeout(1)
                return
            end
            inst.sg:GoToState("idle", true)
        end,
        onupdate = function(inst)
            if inst.sg.statemem.dalpha ~= nil and inst.sg.statemem.alpha > 0 then
                inst.sg.statemem.dalpha = math.max(.1, inst.sg.statemem.dalpha - .1)
                inst.sg.statemem.alpha = math.max(0, inst.sg.statemem.alpha - inst.sg.statemem.dalpha)
                inst.AnimState:SetMultColour(0, 0, 0, inst.sg.statemem.alpha)
            end
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                inst.components.health:SetInvincible(true)
                inst.AnimState:SetMultColour(.5, .5, .5, 1)
                inst.components.colouradder:PushColour("superjump", .3, .3, .2, 0)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(0, 0, 0, 1)
                inst.components.colouradder:PushColour("superjump", .6, .6, .4, 0)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.sg.statemem.alpha = 1
                inst.sg.statemem.dalpha = .5
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Hide()
                    inst.Physics:Teleport(inst.sg.statemem.targetpos.x, 0, inst.sg.statemem.targetpos.z)
                end
            end),
        },
        ontimeout = function(inst)
            inst.sg.statemem.superjump = true
            inst.sg.statemem.isphysicstoggle = inst.sg.statemem.isphysicstoggle
            inst.sg:GoToState("superjump_pst", {isphysicstoggle=inst.sg.statemem.isphysicstoggle,targetpos =inst.sg.statemem.targetpos, })
        end,
        onexit = function(inst)
            if not inst.sg.statemem.superjump then
                inst.components.health:SetInvincible(false)
                inst.components.colouradder:PopColour("superjump")
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.DynamicShadow:Enable(true)
            end
            inst:Show()
        end,
    },
	State{
        name = "superjump_pst",
        tags = { "attack", "doing", "busy", "nopredict", "nomorph","skill" },
        onenter = function(inst, data)
            if data ~= nil and data.targetpos ~= nil then
                inst.sg.statemem.isphysicstoggle = data.isphysicstoggle
                inst.AnimState:PlayAnimation("superjump_land")
                inst.AnimState:SetMultColour(1, 1, 1, .4)
                inst.sg.statemem.targetpos = data.targetpos
                if not data.skipflash then
                    inst.sg.statemem.flash = 0
                end
                inst.Physics:Teleport(data.targetpos.x, 0, data.targetpos.z)
                inst.components.health:SetInvincible(true)
                inst.sg:SetTimeout(22 * FRAMES)
                return
            end
            inst.sg:GoToState("idle", true)
        end,
        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                local c = math.min(1, inst.sg.statemem.flash)
                inst.components.colouradder:PushColour("superjump", c, c, 0, 0)
            end
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst.AnimState:SetMultColour(1, 1, 1, .7)
                inst.components.colouradder:PushColour("superjump", .1, .1, 0, 0)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, .9)
                inst.components.colouradder:PushColour("superjump", .2, .2, 0, 0)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.components.colouradder:PushColour("superjump", .4, .4, 0, 0)
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("superjump", 1, 1, 0, 0)
                inst.components.bloomer:PushBloom("superjump", "shaders/anim.ksh", -2)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                if inst.sg.statemem.flash then
                    inst.sg.statemem.flash = 1.3
                end
                inst.sg:RemoveStateTag("noattack")
                inst.components.health:SetInvincible(false)
                local pt = inst:GetPosition()
                SpawnPrefab("groundpoundring_fx").Transform:SetPosition(pt:Get())
                local fx = SpawnPrefab("ttk_boss_sinkhole")
                fx.Transform:SetPosition(pt:Get())
                fx.owner = inst
                dojunpaoe(inst)
                local points = XD_GetGroundPoints(pt)
                local map = TheWorld.Map
                for i, v1 in ipairs(points) do
                    for i,v in ipairs(v1) do
                        if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                            SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
                        end
                    end
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("superjump")
            end),
            TimeEvent(19 * FRAMES, PlayFootstep),
        },
        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.DynamicShadow:Enable(true)
            inst.components.health:SetInvincible(false)
            inst.components.bloomer:PopBloom("superjump")
            inst.components.colouradder:PopColour("superjump")
        end,
    },
    State{
		name = "txm_lunge_pre",
		tags = { "attack", "busy" },
		onenter = function(inst, target)
			inst:StopBrain()
			inst.components.locomotor:Stop()
			inst.AnimState:SetBankAndPlayAnimation("lavaarena_shadow_lunge", "lunge_pre")
			inst.components.combat:StartAttack()
			if target == nil then
				target = inst.components.combat.target
			end
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			else
				target = nil
			end
            inst.components.timer:StartTimer("lunge_cd", 8)
            inst.components.combat:SetRange(4)
		end,
		onupdate = function(inst)
			if inst.sg.statemem.target ~= nil then
				if inst.sg.statemem.target:IsValid() then
					inst.sg.statemem.targetpos = inst.sg.statemem.target:GetPosition()
				else
					inst.sg.statemem.target = nil
				end
			end
		end,
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.lunge = true
					inst.sg:GoToState("txm_lunge_loop", { target = inst.sg.statemem.target, targetpos = inst.sg.statemem.targetpos })
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.lunge then
				inst.components.combat:CancelAttack()
				inst:RestartBrain()
				inst.AnimState:SetBank(Boss.Art("wilson"))
			end
		end,
	},
	State{
		name = "txm_lunge_loop",
		tags = { "attack", "busy", "noattack", "temp_invincible" },
		onenter = function(inst, data)
            inst.lunce_count =  inst.lunce_count + 1
			inst.AnimState:PlayAnimation("lunge_loop")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			TrySplashFX(inst)
			if data ~= nil then
				if data.target ~= nil and data.target:IsValid() then
					inst.sg.statemem.target = data.target
					inst:ForceFacePoint(data.target.Transform:GetWorldPosition())
				elseif data.targetpos ~= nil then
					inst:ForceFacePoint(data.targetpos)
				end
			end
			inst.Physics:SetMotorVelOverride(35, 0, 0)
            inst.components.combat:SetDefaultDamage(30.3)
			inst.sg:SetTimeout(8 * FRAMES)
		end,
		onupdate = function(inst)
			if inst.sg.statemem.attackdone then
				return
			end
			local target = inst.sg.statemem.target
			if target == nil or not target:IsValid() then
				if inst.sg.statemem.animdone then
					inst.sg.statemem.lunge = true
					inst.sg:GoToState("txm_lunge_pst")
					return
				end
				inst.sg.statemem.target = nil
			elseif inst:IsNear(target, 1) then
				local fx = SpawnPrefab(math.random() < .5 and "shadowstrike_slash_fx" or "shadowstrike_slash2_fx")
				local x, y, z = target.Transform:GetWorldPosition()
				fx.Transform:SetPosition(x, y + 1.5, z)
				fx.Transform:SetRotation(inst.Transform:GetRotation())
                inst.components.combat.ignorehitrange = true
				inst.components.combat:DoAttack(target)
                inst.components.combat.ignorehitrange = false
                if inst.dopillar and not (target.components.health ~= nil and target.components.health:IsDead()) and target:IsValid() then
                    local x, y, z = target.Transform:GetWorldPosition()
                    local map = TheWorld.Map
                    if map:IsPassableAtPoint(x, y, z, true) then
                        DoPillarsTarget(target, inst, nil, {}, map, x, z)
                    end
                end
				if inst.sg.statemem.animdone then
					inst.sg.statemem.lunge = true
					inst.sg:GoToState("txm_lunge_pst", target)
					return
				end
				inst.sg.statemem.attackdone = true
			end
		end,
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.attackdone or inst.sg.statemem.target == nil then
						inst.sg.statemem.lunge = true
						inst.sg:GoToState("txm_lunge_pst", inst.sg.statemem.target)
						return
					end
					inst.sg.statemem.animdone = true
				end
			end),
		},
		ontimeout = function(inst)
			inst.sg.statemem.lunge = true
			inst.sg:GoToState("txm_lunge_pst")
		end,
		onexit = function(inst)
            inst.components.combat:SetDefaultDamage(7.6)
			if not inst.sg.statemem.lunge then
				inst:RestartBrain()
				inst.AnimState:SetBank(Boss.Art("wilson"))
			end
		end,
	},
	State{
		name = "txm_lunge_pst",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },
		onenter = function(inst, target)
			inst.AnimState:PlayAnimation("lunge_pst")
			inst.Physics:SetMotorVelOverride(12, 0, 0)
			inst.sg.statemem.target = target
		end,
		onupdate = function(inst)
			inst.Physics:SetMotorVelOverride(inst.Physics:GetMotorVel() * .8, 0, 0)
		end,
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local target = inst.sg.statemem.target
					local pos = inst:GetPosition()
					pos.y = 0
					local moved = false
					if target ~= nil then
						if target:IsValid() then
							local targetpos = target:GetPosition()
							local dx, dz = targetpos.x - pos.x, targetpos.z - pos.z
							local radius = math.sqrt(dx * dx + dz * dz)
							local theta = math.atan2(dz, -dx)
							local offs = FindWalkableOffset(targetpos, theta, radius + 3 + math.random(), 8, false, true, NotBlocked, true, true)
							if offs ~= nil then
								pos.x = targetpos.x + offs.x
								pos.z = targetpos.z + offs.z
								inst.Physics:Teleport(pos:Get())
								moved = true
							end
						else
							target = nil
						end
					end
					if not moved and not TheWorld.Map:IsPassableAtPoint(pos.x, 0, pos.z, true) then
						pos = FindNearbyLand(pos, 1) or FindNearbyLand(pos, 2)
						if pos ~= nil then
							inst.Physics:Teleport(pos.x, 0, pos.z)
						end
					end
					if target ~= nil then
						inst:ForceFacePoint(target.Transform:GetWorldPosition())
					end
					inst.sg.statemem.appearing = true
					inst.sg:GoToState("appear")
				end
			end),
		},
		onexit = function(inst)
			inst:RestartBrain()
			inst.AnimState:SetBank(Boss.Art("wilson"))
		end,
	},
	State{
		name = "appear",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("appear")
		end,
		timeline =
		{
			TimeEvent(9 * FRAMES, function(inst)
				TrySplashFX(inst, "small")
			end),
			TimeEvent(11 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("temp_invincible")
				inst.sg:RemoveStateTag("phasing")
			end),
			TimeEvent(13 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	State{
		name = "txm_spell",
		tags = { "busy", "skill"},
        onenter = function(inst,target)
            inst.canspell = false
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local colour = staff ~= nil and staff.fxcolour or { 0, 0, 0 }
            inst.sg.statemem.staff = staff
            inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx.entity:AddFollower()
            inst.sg.statemem.stafffx.Follower:FollowSymbol(inst.GUID, "", -40, 70, 0)
            inst.sg.statemem.stafffx:SetUp(colour)
            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
            inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
            inst.sg.statemem.target = target
            inst.dospell =  true
        end,
        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(53 * FRAMES, function(inst)
                inst.sg.statemem.stafffx = nil
                inst.sg.statemem.stafflight = nil
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    local pos = inst.sg.statemem.target:GetPosition()
                    local fx = SpawnAt("ttk_boss_ziyunsword_meteorfx",pos)
                    fx.owner = inst.owner
                    fx.damage = 40
                end
            end),
            TimeEvent(69 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.dospell =  false
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            if not inst.components.timer:TimerExists("lifetime") then
                inst:dodespawn()
            end
        end,
	},
    State{
        name = "goaway",
        tags = {"busy" },
        onenter = function(inst)
            if inst.components.follower then
                inst.components.follower:StopFollowing()
            end
            inst.AnimState:PlayAnimation("xd_fly_pre")
            inst.AnimState:PushAnimation("xd_fly_loop", true)
            inst.Physics:SetMotorVelOverride(12, 0, 0)
            inst.sg:SetTimeout(8)
        end,
        onupdate = function(inst)
        end,
        timeline =
        {
            TimeEvent(5, function(inst)
                if inst.components.colourtweener then
                    inst.components.colourtweener:StartTween({1,1,1,0}, 2, inst.Remove)
                end
            end),
        },
        onexit = function(inst)
            if inst:IsValid() then
                inst:Remove()
            end
        end,
    },
}
return StateGraph("ttk_boss_swhs", states, events, "idle", actionhandlers)
