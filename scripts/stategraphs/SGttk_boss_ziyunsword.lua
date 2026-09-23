-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require("stategraphs/commonstates")
local function isbusy(inst)
    return inst.busy or inst.goback or inst.skillon
end
local events =
{
    EventHandler("attack", function(inst,target)
        if not inst.busy then
            inst.sg:GoToState("attack_mo",target)
        end
    end),
    EventHandler("spell2", function(inst,target)
        if not inst.busy then
            inst.sg:GoToState("skill_mo_big",target)
        end
    end),
    EventHandler("zhansha", function(inst,target)
        if not inst.busy then
            inst.sg:GoToState("zhansha",target)
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
		name = "attack_mo",
		tags = { "skill", "busy" },
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
                        local s  = 5
                        local pt = inst.sg.statemem.target:GetPosition()
                        blast.Transform:SetPosition((pt+Vector3(0,0.8,0)):Get())
                        blast.Transform:SetScale(s, s, s)
                        if inst.owner and inst.owner:IsValid() then
                            inst.owner:DoAoeAttck(pt,2.5,75)
                        end
                    else
                        local proj = SpawnPrefab("ttk_boss_sword_ayq")
                        if proj.components.projectile ~= nil then
                            proj.Transform:SetPosition(inst.Transform:GetWorldPosition())
                            proj.components.projectile:Throw(inst, inst.sg.statemem.target, inst)
                            proj.damagefn = function(fx,pt)
                                if inst.owner and inst.owner:IsValid() then
                                    inst.owner:DoAoeAttck(pt,2.5,75)
                                end
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
		name = "zhansha",
		tags = { "attack","busy" },
		onenter = function(inst, target)
            inst.busy = true
            if target and target:IsValid() then
                target:PushEvent("ziyun_control")
                inst.Physics:Stop()
                inst.AnimState:OverrideSymbol("attack", "xd_sword_mo_attackbuild", "attack")
                inst.AnimState:PlayAnimation("attack")
                inst.sg.statemem.targetpos = target:GetPosition()
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
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
                    if inst.owner and inst.owner:IsValid() then
                        inst.owner:DoAoeAttck(pt,6,150)
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
            inst.AnimState:ClearOverrideSymbol("attack")
            inst.busy = false
		end,
	},
	State{
		name = "skill_mo_big",
		tags = { "attack","busy" },
		onenter = function(inst, target)
            inst.busy =  true
            if target and target:IsValid() then
                local pos = target:GetPosition()
                inst.components.locomotor:Stop()
                inst.sg.statemem.target = target
                inst.sg.statemem.skillpos = pos
                inst.AnimState:PlayAnimation("dazhaoqianzhi")
                inst:ForceFacePoint(pos:Get())
                local fx = SpawnPrefab("ttk_boss_sword_mo_skillfx")
                fx.entity:SetParent(inst.entity)
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, "png", 0, 30, 0)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff")
                return
            end
            inst.sg:GoToState("idle")
		end,
		timeline =
		{
            TimeEvent(1.5, function(inst)
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() then
                    inst.sg.statemem.skillpos = inst.sg.statemem.target:GetPosition()
                end
			end),
			TimeEvent(1.85, function(inst)
                local fx = SpawnAt("ttk_boss_ziyunsword_meteorfx",inst.sg.statemem.skillpos)
                fx.owner = inst.owner
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
return StateGraph("SGttk_boss_ziyunsword", states, events, "idle")
