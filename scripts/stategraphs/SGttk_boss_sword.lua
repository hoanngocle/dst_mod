-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
require("stategraphs/commonstates")
local function isbusy(inst)
    return inst.busy or inst.goback or inst.skillon
end
local events =
{
	EventHandler("doattack", function(inst, data)
		if data and data.target and data.target:IsValid() then
            if not isbusy(inst) then
                if inst.sword == "mo" then
                    if inst:IsNear(data.target,14) then
                        inst.sg:GoToState("attack_"..inst.sword, data.target)
                    end
                elseif inst.sword == "fj" then
                    inst.sg:GoToState("attack_fj", data.target)
                else
                    inst.sg:GoToState("attack_"..inst.sword, data.target)
                    data.com.mode = data.com.mode%3 + 1
                end
            end
		end
	end),
	EventHandler("spell", function(inst, data)
		if data then
            if not isbusy(inst) then
                if inst.sword == "mo" then
                    if data.com.skillmode == 3 then
                        inst.sg:GoToState("skill_"..inst.sword.."_big", data)
                    else
                        inst.sg:GoToState("skill_"..inst.sword, data)
                    end
                    data.com.skillmode = data.com.skillmode%3 + 1
                    if data.com.inst.components.ttk_boss_skillcd then
                        data.com.inst.components.ttk_boss_skillcd:Start("source_F15C2F2BC385F1F838CE0CE3",24)
                    end
                else
                    if data.com.inst.components.ttk_boss_skillcd then
                        data.com.inst.components.ttk_boss_skillcd:Start("source_F15C2F2BC385F1F838CE0CE3",18)
                    end
                    inst.sg:GoToState("skill_"..inst.sword, data)
                    data.com.skillmode = data.com.skillmode%4 + 1
                end
            end
		end
	end),
    EventHandler("spell_big", function(inst, data)
		if data then
            if not isbusy(inst) then
                inst.sg:GoToState("skill_big", data)
                if inst.sword == "red" then
                    if data.com.inst.components.ttk_boss_skillcd then
                        data.com.inst.components.ttk_boss_skillcd:Start("source_F15C2F2BC385F1F838CE0CE3",20)
                    end
                    data.com.skillmode = data.com.skillmode%4 + 1
                end
            end
		end
	end),
    EventHandler("locomote", function(inst)
        if not inst.components.locomotor then
            return
        end
        if inst.sg:HasStateTag("busy") then
            return
        end
        local can_run = true
        local can_walk = false
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local is_idling = inst.sg:HasStateTag("idle")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        if is_moving and not should_move then
            inst.sg:GoToState(is_running and "run_stop" or "walk_stop")
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run and can_run and can_walk) then
            if can_run and (should_run or not can_walk) then
                inst.sg:GoToState("run_start")
            elseif can_walk then
                inst.sg:GoToState("walk_start")
            end
        end
    end)
}
local function GetDistanceToPoint(inst,x, y, z)
    if x and not y and not z then
        x, y, z = x:Get()
    end
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    return math.sqrt((x - x1) ^ 2 + (y - y1) ^ 2 + (z - z1) ^ 2)
end
local function GetPositionAdjacentTo(inst,pos, distance)
    local p1 = Vector3(inst.Transform:GetWorldPosition())
    local p2 = pos
    local offset = p1-p2
    offset:Normalize()
    offset = offset * distance
    return (p2 + offset)
end
local function doattack(inst,damage,range,fx,fn,aoepos,norate)
    if inst and inst:IsValid() and  inst.owner and inst.owner:IsValid() then
        local x,y,z = inst.Transform:GetWorldPosition()
        if aoepos then
            x,y,z = aoepos:Get()
        end
        local notag = inst.owner.prefab == "ttk_qxdx" and {"INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost"}  or nil
        local ents = XD_GetDamageTargets(x, 0, z,range or 3,notag)
        for i,v in pairs(ents) do
            if v and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v)
                and (not fn or fn(inst,v,inst.owner)) then
                local damage = damage or 10
                if not norate or inst.owner.prefab == "ttk_qxdx" then
                    damage = Xd_CalcDamage(inst.owner,damage,v)
                end
                if fx then
                    SpawnAt(fx,v,Vector3(2,2,2),Vector3(0,1,0))
                end
                v.components.combat:GetAttacked(inst.owner,damage)
            end
        end
    end
end
local function isinrange(inst,target,rd)
    local ang = inst.Transform:GetRotation()
    local x,y,z = target.Transform:GetWorldPosition()
    local angle = inst:GetAngleToPoint( x,0,z )
    local drot = math.abs( ang - angle )
    while drot > 180 do
        drot = math.abs(drot - 360)
    end
    return drot < (rd or 30)
end
local function getspawnlocation(inst, pos)
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local theta = math.random() * TWOPI
    local radius = 1
    local offset = FindWalkableOffset(Vector3(x1, y1, z1), theta, radius, 6)
    if offset ~= nil then
        x1 = x1 + offset.x
        z1 = z1 + offset.z
    end
    local x2, y2, z2 = pos.x,pos.y,pos.z
    return x1 + .15 * (x2 - x1), 0, z1 + .15 * (z2 - z1)
end
local function setskin(inst,fx)
    if inst.skin and fx.SetSkin then
        fx:SetSkin(inst.skin)
    end
end
local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.AnimState:PlayAnimation("idle", true)
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
	State{
		name = "attack_red",
		tags = { "attack"},
		onenter = function(inst, target)
            inst.busy = true
            inst.AnimState:ShowSymbol("attack")
            inst.AnimState:PlayAnimation("attack")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
                if inst:GetDistanceSqToPoint(inst.sg.statemem.targetpos) >= 4 then
                    local targetpos = GetPositionAdjacentTo(inst,inst.sg.statemem.targetpos, 1)
                    inst.sg.statemem.attackpos = targetpos
                    inst.sg.statemem.attackspeed = GetDistanceToPoint(inst,targetpos)/0.43
                else
                    inst.sg.statemem.attackpos = inst:GetPosition()
                end
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			end
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
            TimeEvent(0.188, function(inst)
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/red_attack",nil,0.75)
			end),
			TimeEvent(0.43, function(inst)
                doattack(inst,200,4,"ttk_boss_sword_red_hitfx")
                inst.Physics:Stop()
                inst.sg.statemem.attackspeed = 0
			end),
			TimeEvent(0.784, function(inst)
                inst.AnimState:HideSymbol("attack")
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                inst.goback =  true
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
		name = "attack_blue",
		tags = { "attack"},
		onenter = function(inst, target)
            inst.busy = true
            inst.AnimState:ShowSymbol("attack")
            inst.AnimState:PlayAnimation("attack")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
                if inst:GetDistanceSqToPoint(inst.sg.statemem.targetpos) >= 4 then
                    local targetpos = GetPositionAdjacentTo(inst,inst.sg.statemem.targetpos, 1)
                    inst.sg.statemem.attackpos = targetpos
                    inst.sg.statemem.attackspeed = GetDistanceToPoint(inst,targetpos)/0.43
                else
                    inst.sg.statemem.attackpos = inst:GetPosition()
                end
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			end
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
			TimeEvent(0.43, function(inst)
                inst.Physics:Stop()
                inst.sg.statemem.attackspeed = 0
			end),
            TimeEvent(0.45, function(inst)
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/blue_attack",nil,0.75)
			end),
			TimeEvent(0.511, function(inst)
                doattack(inst,150,4)
			end),
			TimeEvent(0.683, function(inst)
                doattack(inst,150,4)
			end),
			TimeEvent(1.255, function(inst)
                inst.AnimState:HideSymbol("attack")
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                inst.goback =  true
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
		name = "attack_green",
		tags = { "attack"},
		onenter = function(inst, target)
            inst.busy = true
            inst.AnimState:ShowSymbol("attack")
            inst.AnimState:PlayAnimation("attack")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
                if inst:GetDistanceSqToPoint(inst.sg.statemem.targetpos) >= 4 then
                    local targetpos = GetPositionAdjacentTo(inst,inst.sg.statemem.targetpos, 1)
                    inst.sg.statemem.attackpos = targetpos
                    inst.sg.statemem.attackspeed = GetDistanceToPoint(inst,targetpos)/0.43
                else
                    inst.sg.statemem.attackpos = inst:GetPosition()
                end
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			end
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
			TimeEvent(0.4, function(inst)
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/green_attack",nil,0.75)
			end),
			TimeEvent(0.43, function(inst)
                inst.Physics:Stop()
                inst.sg.statemem.attackspeed = 0
			end),
			TimeEvent(0.47, function(inst)
                doattack(inst,133.3,4)
			end),
			TimeEvent(0.79, function(inst)
                doattack(inst,133.3,4)
			end),
            TimeEvent(1.23, function(inst)
                doattack(inst,133.3,4)
			end),
			TimeEvent(1.63, function(inst)
                inst.AnimState:HideSymbol("attack")
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                inst.goback =  true
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
		name = "attack_fj",
		tags = { "attack"},
		onenter = function(inst, target)
            inst.busy = true
            inst.AnimState:ShowSymbol("attack")
            inst.AnimState:PlayAnimation("attack")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
                if inst:GetDistanceSqToPoint(inst.sg.statemem.targetpos) >= 4 then
                    local targetpos = GetPositionAdjacentTo(inst,inst.sg.statemem.targetpos, 1)
                    inst.sg.statemem.attackpos = targetpos
                    inst.sg.statemem.attackspeed = GetDistanceToPoint(inst,targetpos)/0.43
                else
                    inst.sg.statemem.attackpos = inst:GetPosition()
                end
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			end
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
			TimeEvent(0.4, function(inst)
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/green_attack",nil,0.75)
			end),
			TimeEvent(0.43, function(inst)
                inst.Physics:Stop()
                inst.sg.statemem.attackspeed = 0
			end),
			TimeEvent(0.47, function(inst)
                doattack(inst,75,4,nil,nil,nil,true)
			end),
			TimeEvent(0.79, function(inst)
                doattack(inst,75,4,nil,nil,nil,true)
			end),
            TimeEvent(1.23, function(inst)
                doattack(inst,75,4,nil,nil,nil,true)
			end),
			TimeEvent(1.63, function(inst)
                inst.AnimState:HideSymbol("attack")
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                inst.goback =  true
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
		name = "skill_red",
		tags = { "attack"},
		onenter = function(inst, data)
            local doer = data.com and data.com.inst or nil
            if doer and doer:IsValid() and data.pos then
                inst.busy = true
                inst.skillon = true
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("fire")
                local pos =  doer:GetPosition()
                local pt
                if pos.x == data.pos.x and  pos.z == data.pos.z then
                    local facing_angle = doer.Transform:GetRotation() * DEGREES
                    pt = Vector3(pos.x - 4 * math.cos(facing_angle), 0, pos.z + 4 * math.sin(facing_angle))
                else
                    local offset = pos-data.pos
                    offset:Normalize()
                    offset = offset * 4
                    pt =  (data.pos + offset)
                end
                local facing_angle = doer.Transform:GetRotation() * DEGREES
                local spellpos = Vector3(pos.x - 1 * math.cos(facing_angle), 0, pos.z + 1 * math.sin(facing_angle))
                inst.sg.statemem.target = doer
				inst.sg.statemem.targetpos = data.pos
                inst.sg.statemem.attackpos = pt
				inst:ForceFacePoint(spellpos:Get())
                local fx = SpawnPrefab("ttk_boss_sword_red_skillfx")
                fx.entity:SetParent(inst.entity)
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "png", 0, 30, 0)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff")
                doer:PushEvent("do_skill_small",{pos = data.pos})
                return
            end
            inst.sg:GoToState("idle")
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
			TimeEvent(1.68, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.components.colourtweener:StartTween({1, 1, 1, 0}, 0.28, function()
                    inst.Transform:SetPosition(inst.sg.statemem.attackpos:Get())
                    inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                end)
			end),
			TimeEvent(1.971, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 0)
                inst.components.colourtweener:StartTween({1, 1, 1, 1}, 0.766, function()
                end)
			end),
			TimeEvent(2, function(inst)
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/red_skill",nil,0.75)
                local damage= inst.owner.prefab == "ttk_qxdx" and 150 or 277.5
                doattack(inst,damage,8,nil,function(inst,target,doer)
                    return isinrange(inst,target,75)
                end)
			end),
            TimeEvent(2.65, function(inst)
                local damage= inst.owner.prefab == "ttk_qxdx" and 150 or 277.5
                doattack(inst,damage,8,nil,function(inst,target,doer)
                    return isinrange(inst,target,75)
                end)
			end),
            TimeEvent(3.3, function(inst)
                local damage= inst.owner.prefab == "ttk_qxdx" and 150 or 277.5
                doattack(inst,damage,8,nil,function(inst,target,doer)
                    return isinrange(inst,target,75)
                end)
			end),
            TimeEvent(3.735, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.components.colourtweener:StartTween({1, 1, 1, 0}, 0.275, function()
                end)
			end),
            TimeEvent(3.95, function(inst)
                local damage= inst.owner.prefab == "ttk_qxdx" and 150 or 277.5
                doattack(inst,damage,8,nil,function(inst,target,doer)
                    return isinrange(inst,target,75)
                end)
			end),
			TimeEvent(4.02, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 0)
                inst.components.colourtweener:StartTween({1, 1, 1, 1}, 0.5, function()
                    inst.skillon = false
                end)
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                local pos = inst:GetTargetPos()
                if pos then
                    inst.Transform:SetPosition(pos:Get())
                end
                inst.sg:GoToState("idle")
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
		name = "skill_blue",
		tags = { "attack"},
		onenter = function(inst, data)
            local doer = data.com and data.com.inst or nil
            if doer and doer:IsValid() and data.pos then
                inst.skillon = true
                inst.busy = true
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("quick")
				inst.sg.statemem.targetpos = data.pos
                inst.sg.statemem.attackpos = inst:GetPosition()
                inst.sg.statemem.attackspeed = 0
				inst:ForceFacePoint(data.pos:Get())
                doer:PushEvent("do_skill_small",{pos = data.pos})
                return
            end
            inst.sg:GoToState("idle")
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
            TimeEvent(0.741, function(inst)
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/blue_skill1",nil,0.75)
            end),
			TimeEvent(1.54-0.4, function(inst)
                SpawnAt("ttk_boss_sword_blue_skillfx",inst.sg.statemem.targetpos,Vector3(4,4,4),Vector3(0,1.2,0))
                inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/blue_skill2",nil,0.75)
			end),
			TimeEvent(1.54 + 0.16-0.4, function(inst)
                local damage= inst.owner.prefab == "ttk_qxdx" and 120 or 258.75
                doattack(inst,damage,7.5,nil,nil,inst.sg.statemem.targetpos)
			end),
            TimeEvent(1.54 + 0.32-0.4, function(inst)
                local damage= inst.owner.prefab == "ttk_qxdx" and 120 or 258.75
                doattack(inst,damage,7.5,nil,nil,inst.sg.statemem.targetpos)
			end),
            TimeEvent(1.54 + 0.48-0.4, function(inst)
                local damage= inst.owner.prefab == "ttk_qxdx" and 120 or 258.75
                doattack(inst,damage,7.5,nil,nil,inst.sg.statemem.targetpos)
			end),
            TimeEvent(1.54 + 0.64-0.4, function(inst)
                local damage= inst.owner.prefab == "ttk_qxdx" and 120 or 258.75
                doattack(inst,damage,7.5,nil,nil,inst.sg.statemem.targetpos)
			end),
			TimeEvent(3-0.4, function(inst)
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                inst.AnimState:SetMultColour(1, 1, 1, 0)
                inst.components.colourtweener:StartTween({1, 1, 1, 1}, 1.5, function()
                    inst.skillon = false
                end)
                inst:Show()
                inst._hiding = false
                local pos = inst:GetTargetPos()
                if pos then
                    inst.Transform:SetPosition(pos:Get())
                end
                inst.sg:GoToState("idle")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:IsCurrentAnimation("quick") then
                    inst:Hide()
                    inst._hiding = true
				end
			end),
		},
		onexit = function(inst)
		end,
	},
	State{
		name = "skill_green",
		tags = { "attack"},
		onenter = function(inst, data)
            local doer = data.com and data.com.inst or nil
            if doer and doer:IsValid() and data.pos then
                inst.busy = true
                inst.skillon = true
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("skill")
				inst.sg.statemem.targetpos = data.pos
                inst.sg.statemem.attackpos = inst:GetPosition()
				inst:ForceFacePoint(data.pos:Get())
                doer:PushEvent("do_skill_small",{pos = data.pos})
                return
            end
            inst.sg:GoToState("idle")
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
            TimeEvent(1.2, function(inst)
                inst.attack_task = inst:DoPeriodicTask(0.2,function()
                    local pt = inst.sg.statemem.targetpos
                    if pt then
                        local theta = math.random() * TWOPI
                        local offset = FindValidPositionByFan(math.random() * TWOPI,GetRandomMinMax(0,3.5),12,function(offset)
                            return true
                        end) or Vector3(0,0,0)
                        local fx = SpawnAt("ttk_boss_sword_green_skillfx",pt+offset)
                        setskin(inst,fx)
                        fx.damagefn = function(fx,...)
                            local damage= inst.owner.prefab == "ttk_qxdx" and 65 or 67.2
                            doattack(inst,damage,3.75,nil,nil,pt+offset)
                        end
                    end
                end,0)
                inst.attack_task.limit =  13
            end),
			TimeEvent(5.2, function(inst)
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                inst.AnimState:SetMultColour(1, 1, 1, 0)
                inst.components.colourtweener:StartTween({1, 1, 1, 1}, 1.5, function()
                    inst.skillon = false
                end)
                inst:Show()
                inst._hiding = false
                local pos = inst:GetTargetPos()
                if pos then
                    inst.Transform:SetPosition(pos:Get())
                end
                inst.sg:GoToState("idle")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:IsCurrentAnimation("skill") then
                    inst.AnimState:PlayAnimation("go")
                    SpawnAt("ttk_boss_sword_green_upfx",inst)
                    inst.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/green_skill1",nil,0.75)
                elseif inst.AnimState:IsCurrentAnimation("go") then
                    inst:Hide()
                    inst._hiding = true
				end
			end),
		},
		onexit = function(inst)
		end,
	},
	State{
		name = "skill_big",
		tags = { "attack"},
		onenter = function(inst, data)
            local doer = data.com and data.com.inst or nil
            if doer and doer:IsValid() and data.pos then
                inst.busy = true
                inst.skillon = true
                inst.Physics:Stop()
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.components.colourtweener:StartTween({1, 1, 1, 0}, 0.3, function()
                end)
				inst.sg.statemem.targetpos = data.pos
                inst.sg.statemem.attackpos = inst:GetPosition()
				inst:ForceFacePoint(data.pos:Get())
                doer:PushEvent("do_skill_big",{pos = data.pos})
                if inst.sword == "red" and inst.skin == "duanzui" then
                    SpawnAt("ttk_boss_duanzui_baihu_fx",doer)
                end
                return
            end
            inst.sg:GoToState("idle")
		end,
		onupdate = function(inst,dt)
		end,
		timeline =
		{
            TimeEvent(0.5, function(inst)
                if inst.sword == "red" then
                    local fx = SpawnAt("ttk_boss_sword_bigskill",inst.sg.statemem.targetpos)
                    fx.damagefn = function(fx,pt)
                        local damage= inst.owner.prefab == "ttk_qxdx" and 275 or 162.4
                        doattack(inst,damage,8,nil,nil,inst.sg.statemem.targetpos)
                    end
                end
            end),
            TimeEvent(1.1, function(inst)
                if inst.sword == "red" then
                    inst.attack_task = inst:DoPeriodicTask(0.1,function()
                        local pt = inst.sg.statemem.targetpos
                        if pt then
                            local theta = math.random() * TWOPI
                            local offset = FindValidPositionByFan(math.random() * TWOPI,GetRandomMinMax(0,7.5),12,function(offset)
                                return true
                            end) or Vector3(0,0,0)
                            local fxs = {"ttk_boss_sword_green_skillfx","ttk_boss_sword_bigskill_redfx","ttk_boss_sword_bigskill_bluefx"}
                            local fx = SpawnAt(fxs[math.random(#fxs)],pt+offset)
                            setskin(inst,fx)
                            fx.damagefn = function(fx,...)
                                local damage= inst.owner.prefab == "ttk_qxdx" and 50 or 97.4
                                doattack(inst,damage,8,nil,nil,pt+offset)
                            end
                        end
                    end,0)
                    inst.attack_task.limit =  52
                end
            end),
			TimeEvent(8, function(inst)
                inst.busy = false
                inst.sg.statemem.attackpos = nil
                inst.AnimState:SetMultColour(1, 1, 1, 0)
                inst.components.colourtweener:StartTween({1, 1, 1, 1}, 1.5, function()
                    inst.skillon = false
                end)
                inst:Show()
                local pos = inst:GetTargetPos()
                if pos then
                    inst.Transform:SetPosition(pos:Get())
                end
                inst.sg:GoToState("idle")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
			end),
		},
		onexit = function(inst)
		end,
	},
	State{
		name = "attack_mo",
		tags = { "attack", "busy" },
		onenter = function(inst, target)
            inst.Physics:Stop()
            inst.busy = true
            inst.AnimState:PlayAnimation("attack")
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
			end
		end,
		timeline =
		{
			TimeEvent(0.336, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
			TimeEvent(0.45, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    if inst:IsNear(inst.sg.statemem.target,4.5) then
                        local blast = SpawnPrefab("ttk_boss_sword_mo_boom")
                        blast.SoundEmitter:PlaySound("xd_pog_sound/xd_pog_sound/mo_attack3",nil,0.75)
                        local s  = 5
                        local pt = inst.sg.statemem.target:GetPosition()
                        blast.Transform:SetPosition((pt+Vector3(0,0.8,0)):Get())
                        blast.Transform:SetScale(s, s, s)
                        doattack(inst,100,2.5,nil,nil,pt)
                    else
                        local proj = SpawnPrefab("ttk_boss_sword_ayq")
                        if proj.components.projectile ~= nil then
                            proj.Transform:SetPosition(inst.Transform:GetWorldPosition())
                            proj.components.projectile:Throw(inst, inst.sg.statemem.target, inst)
                            proj.damagefn = function(fx,pt)
                                doattack(inst,100,2.5,nil,nil,pt)
                            end
                        end
                    end
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
            inst.busy = false
		end,
	},
	State{
		name = "skill_mo",
		tags = { "attack","busy" },
		onenter = function(inst, data)
            inst.busy = true
            local doer = data.com and data.com.inst or nil
            if doer and doer:IsValid() and data.pos then
                inst.Physics:Stop()
                inst.AnimState:OverrideSymbol("attack", "xd_sword_mo_attackbuild", "attack")
                inst.AnimState:PlayAnimation("attack")
                inst.sg.statemem.targetpos = data.pos
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                doer:PushEvent("do_skill_mo",{pos = data.pos})
                return
            end
            inst.sg:GoToState("idle")
		end,
		timeline =
		{
			TimeEvent(0.336, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
			end),
			TimeEvent(0.45, function(inst)
                for k = 1,3 do
                    local tornado = SpawnPrefab("ttk_boss_sword_mo_tornado")
                    tornado.Transform:SetPosition(getspawnlocation(inst, inst.sg.statemem.targetpos))
                    tornado.components.knownlocations:RememberLocation("target", inst.sg.statemem.targetpos)
                end
                local fx = SpawnAt("ttk_boss_sword_mo_quanfx",inst.sg.statemem.targetpos)
                fx.Transform:SetScale(1.4, 1.4, 1.4)
                fx:DoRemove(5.1)
                local fx = SpawnAt("ttk_boss_sword_mo_aoe",inst.sg.statemem.targetpos)
                fx.damagefn = function(fx,pt)
                    doattack(inst,86.3,6,nil,nil,pt)
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
            inst.AnimState:ClearOverrideSymbol("attack")
            inst.busy = false
		end,
	},
	State{
		name = "skill_mo_big",
		tags = { "attack","busy" },
		onenter = function(inst, data)
            inst.busy =  true
            local doer = data.com and data.com.inst or nil
            if doer and doer:IsValid() and data.pos then
                inst.components.locomotor:Stop()
                inst.sg.statemem.skillpos = data.pos
                inst.AnimState:PlayAnimation("dazhaoqianzhi")
                inst:ForceFacePoint(data.pos:Get())
                local fx = SpawnPrefab("ttk_boss_sword_mo_skillfx")
                fx.entity:SetParent(inst.entity)
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "png", 0, 30, 0)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff")
                if inst.skin == "duanzui" then
                    local theta = math.random() * TWOPI
                    local pt = doer:GetPosition()
                    local radius = 2
                    local offset = FindWalkableOffset(pt, theta, radius, 6)
                    if offset ~= nil then
                        pt.x = pt.x + offset.x
                        pt.z = pt.z + offset.z
                    end
                    SpawnAt("ttk_boss_duanzui_mojun_fx",pt)
                end
                doer:PushEvent("do_skill_mo_big",{pos = data.pos})
                return
            end
            inst.sg:GoToState("idle")
		end,
		timeline =
		{
			TimeEvent(1.85, function(inst)
                local fx = SpawnAt("ttk_boss_sword_mo_meteorfx",inst.sg.statemem.skillpos)
                fx.owner = inst.owner
			end),
			TimeEvent(2.28, function(inst)
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
            inst.busy = false
		end,
	},
}
CommonStates.AddSimpleWalkStates(states, "idle")
CommonStates.AddSimpleRunStates(states, "idle")
return StateGraph("ttk_boss_sword", states, events, "idle")
