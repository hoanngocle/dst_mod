-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
require("stategraphs/commonstates")
local easing = require("easing")
local actionhandlers =
{
}
local SHAKE_DIST = 40
local ICE_LANCE_RADIUS = 5.5
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function DoIceLanceAOE(inst, pt, targets)
	inst.components.combat.ignorehitrange = true
	local dist = math.sqrt(inst:GetDistanceSqToPoint(pt))
	local ents =  TheSim:FindEntities(pt.x, 0, pt.z, ICE_LANCE_RADIUS, {"_combat","_health"},noltags)
	for i, v in ipairs(ents) do
		if not targets[v] and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and XD_CanAttackTrget(inst,v) then
			local shouldknockback =  v.components.freezable ~= nil and v.components.freezable:IsFrozen()
			inst.components.combat:DoAttack(v)
			if shouldknockback then
				v:PushEvent("knockback", { knocker = inst, radius = TUNING.DEERCLOPS_ATTACK_RANGE })
			end
			targets[v] = true
		end
	end
	inst.components.combat.ignorehitrange = false
end
local function ChooseAttack(inst, target)
	target = target or inst.components.combat.target
	if target ~= nil and not target:IsValid() then
		target = nil
	end
	if inst.sg.mem.noice == 1 then
		inst.sg:GoToState("icegrow", target)
		return true
	else
		inst.sg:GoToState("icelance", target)
		return true
	end
end
local function StartAttackCooldown(inst)
	inst.components.combat:StartAttack()
end
local function DeerclopsFootstep(inst, moving, noice)
	inst.SoundEmitter:PlaySound(inst.sounds.step)
	ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .03, 1, inst, SHAKE_DIST)
end
local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnDeath(),
	EventHandler("attacked", function(inst, data)
		if inst.components.health ~= nil and not inst.components.health:IsDead() and (
			not inst.sg:HasStateTag("busy") or
			inst.sg:HasStateTag("caninterrupt") or
			inst.sg:HasStateTag("frozen")
		) then
			if not CommonHandlers.HitRecoveryDelay(inst) then
				inst.sg:GoToState("hit", inst.sg:HasStateTag("struggle"))
			end
		end
	end),
    EventHandler("doattack", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
			ChooseAttack(inst, data ~= nil and data.target or nil)
        end
    end),
}
local states =
{
	State{
		name = "init",
		onenter = function(inst)
			inst.sg:GoToState(inst.components.locomotor ~= nil and "idle" or "corpse_idle")
		end,
	},
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            if pushanim then
				inst.AnimState:PushAnimation("idle_loop")
			else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
        end,
		onexit = function(inst)
			inst:SwitchToFourFaced()
		end,
    },
	State{
		name = "walk_start",
		tags = { "moving", "canrotate" },
		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_pre")
		end,
		timeline =
		{
			FrameEvent(7, function(inst)
				if inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg.statemem.canact = true
				DeerclopsFootstep(inst, true)
			end),
		},
		events =
		{
			EventHandler("doattack", function(inst, data)
				if inst.sg.mem.circle ~= nil then
					if inst.sg.statemem.canact then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
					return true
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.walking = true
					inst.sg:GoToState("walk")
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.walking then
				DeerclopsFootstep(inst, false)
			end
		end,
	},
	State{
		name = "walk",
		tags = { "moving", "canrotate" },
		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			inst.AnimState:PlayAnimation("walk_loop", true)
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
			inst.sg.statemem.canact = true
			if inst.sounds.walk ~= nil then
				inst.SoundEmitter:PlaySound(inst.sounds.walk)
			end
		end,
		timeline =
		{
			FrameEvent(1, function(inst)
				inst.sg.statemem.canact = false
			end),
			FrameEvent(23, function(inst)
				if (inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg.statemem.canact = true
				DeerclopsFootstep(inst, true)
			end),
			FrameEvent(25, function(inst)
				inst.sg.statemem.canact = false
			end),
			FrameEvent(47, function(inst)
				if (inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg.statemem.canact = true
				DeerclopsFootstep(inst, true)
			end),
		},
		ontimeout = function(inst)
			inst.sg.statemem.walking = true
			inst.sg:GoToState("walk")
		end,
		events =
		{
			EventHandler("doattack", function(inst, data)
				if inst.sg.mem.circle ~= nil then
					if inst.sg.statemem.canact then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
					return true
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.walking then
				DeerclopsFootstep(inst, false)
			end
		end,
    },
	State{
		name = "walk_stop",
		tags = { "canrotate" },
		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pst")
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
		name = "hit",
		tags = { "hit", "busy" },
		onenter = function(inst, ignorestagger)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound(inst.sounds.hurt)
			CommonHandlers.UpdateHitRecoveryDelay(inst)
			inst.sg.statemem.ignorestagger = ignorestagger
		end,
		timeline =
		{
			FrameEvent(10, function(inst)
				if (inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("busy")
			end),
		},
		events =
		{
			EventHandler("doattack", function(inst, data)
				if not inst.sg.mem.dostagger or inst.sg.statemem.ignorestagger then
					if not inst.sg:HasStateTag("busy") then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
					end
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
	},
	State{
		name = "death",
		tags = { "dead", "busy", "noattack" },
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("death")
			inst.SoundEmitter:PlaySound(inst.sounds.death)
			inst.components.lootdropper:DropLoot(inst:GetPosition())
			inst.looted = 1
		end,
		timeline =
		{
			FrameEvent(48, function(inst)
				if TheWorld.state.snowlevel > 0.02 then
					inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_snow")
				else
					inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/bodyfall_dirt")
				end
				ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, SHAKE_DIST)
				if inst.sg.mem.circle ~= nil then
					inst.sg.mem.circle:KillFX(true)
					inst.sg.mem.circle = nil
				end
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("corpse")
				end
			end),
		},
		onexit = function(inst)
			if inst.sg.mem.circle ~= nil then
				inst.sg.mem.circle:KillFX(true)
				inst.sg.mem.circle = nil
			end
		end,
	},
	State{
		name = "corpse",
		tags = { "dead", "busy", "noattack" },
		onenter = function(inst, loading)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("corpse")
		end,
		timeline =
		{
			FrameEvent(1, function(inst)
				inst:AddTag("NOCLICK")
				RemovePhysicsColliders(inst)
				local delay = (inst.components.health.destroytime or 2) - 69 * FRAMES
				if delay > 0 then
					inst.sg:SetTimeout(delay)
				else
					ErodeAway(inst)
				end
			end),
		},
		ontimeout = function(inst)
			ErodeAway(inst)
		end,
	},
	State{
		name = "corpse_idle",
		onenter = function(inst)
			inst.AnimState:PlayAnimation("corpse")
		end,
	},
	State{
		name = "corpse_mutate_pre",
		tags = { "mutating","busy" },
		onenter = function(inst)
			inst:AddTag("notarget")
			inst.AnimState:SetBuild(Boss.Art("deerclops_build"))
			inst.components.health:SetInvincible(true)
			inst.AnimState:SetMultColour(0, 0, 0, 0)
			inst.components.colourtweener:StartTween({0, 0, 0, 0.5}, 1, function()
			end)
			inst.AnimState:PlayAnimation("twitch", true)
			inst.sg:SetTimeout(1.5)
			inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/twitching_LP", "loop")
		end,
		ontimeout = function(inst)
			inst.sg:GoToState("corpse_mutate")
		end,
		onexit = function(inst)
			inst.SoundEmitter:KillSound("loop")
		end,
	},
	State{
		name = "corpse_mutate",
		tags = { "mutating","busy"},
		onenter = function(inst)
			inst.AnimState:OverrideSymbol("eye_crystal", "deerclops_mutated", "eye_crystal")
			inst.AnimState:OverrideSymbol("frozen_debris", "deerclops_mutated", "frozen_debris")
			inst.AnimState:PlayAnimation("mutate_pre")
			inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_crackling_LP", "loop")
		end,
		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/mutate_pre_f0") end),
			FrameEvent(6, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(10, function(inst)
			end),
			FrameEvent(45, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/mutate_pre_f45") end),
			FrameEvent(46, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(50, function(inst)
			end),
			FrameEvent(61, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(65, function(inst)
			end),
			FrameEvent(66, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin") end),
			FrameEvent(70, function(inst)
				inst.SoundEmitter:KillSound("loop")
			end),
			FrameEvent(71, function(inst)
				inst.AnimState:SetAddColour(.5, .5, .5, 0)
				inst.AnimState:SetLightOverride(.5)
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.AnimState:SetBuild(Boss.Art("deerclops_mutated"))
					inst.sg:GoToState("mutate_pst")
				end
			end),
		},
		onexit = function(inst)
			inst.AnimState:ClearAllOverrideSymbols()
			inst.AnimState:SetAddColour(0, 0, 0, 0)
			inst.AnimState:SetLightOverride(0)
			inst.SoundEmitter:KillSound("loop")
		end,
	},
	State{
		name = "mutate_pst",
		tags = { "busy", "noattack", "temp_invincible" },
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("mutate")
			inst.sg.statemem.flash = 24
		end,
		onupdate = function(inst)
			local c = inst.sg.statemem.flash
			if c >= 0 then
				inst.sg.statemem.flash = c - 1
				c = easing.inOutQuad(math.min(20, c), 0, 1, 20)
				inst.AnimState:SetAddColour(c, c, c, 0)
				inst.AnimState:SetLightOverride(c)
			end
		end,
		timeline =
		{
			FrameEvent(16, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/stunned_pst_f70") end),
			FrameEvent(20, function(inst)
				DeerclopsFootstep(inst, false, true)
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
			inst:RemoveTag("notarget")
			inst.components.health:SetInvincible(false)
			inst.AnimState:SetAddColour(0, 0, 0, 0)
			inst.AnimState:SetLightOverride(0)
		end,
	},
	State{
		name = "icelance",
		tags = { "attack", "busy" },
		onenter = function(inst, target)
			inst.components.locomotor:Stop()
			inst:SwitchToEightFaced()
			if inst.sg.mem.noice == nil then
				inst.AnimState:PlayAnimation("throw")
			else
				if inst.sg.mem.noice == 0 then
					inst.AnimState:Show("ice_1")
				end
				inst.AnimState:PlayAnimation("throw_2")
			end
			StartAttackCooldown(inst)
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				inst:ForceFacePoint(inst.sg.statemem.targetpos)
			end
			inst.sg.statemem.original_target = target
		end,
		onupdate = function(inst)
			local target = inst.sg.statemem.target
			if target ~= nil then
				if target:IsValid() then
					local p = inst.sg.statemem.targetpos
					p.x, p.y, p.z = target.Transform:GetWorldPosition()
					local rot = inst.Transform:GetRotation()
					local rot1 = inst:GetAngleToPoint(p)
					local drot = ReduceAngle(rot1 - rot)
					if math.abs(drot) < 90 then
						rot1 = rot + math.clamp(drot / 2, -1, 1)
						inst.Transform:SetRotation(rot1)
					end
				else
					inst.sg.statemem.target = nil
				end
			end
		end,
		timeline =
		{
			FrameEvent(8, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_throw_f13") end),
			FrameEvent(30, function(inst)
				inst.sg.statemem.target = nil
				local range = TUNING.MUTATED_DEERCLOPS_ICELANCE_RANGE
				local p = inst.sg.statemem.targetpos
				local x, y, z = inst.Transform:GetWorldPosition()
				local rot = inst.Transform:GetRotation() * DEGREES
				local dist
				if p ~= nil then
					local dx = p.x - x
					local dz = p.z - z
					if dx ~= 0 or dz ~= 0 then
						local rot1 = math.atan2(-dz, dx)
						local diff = DiffAngleRad(rot, rot1)
						if diff * RADIANS < 90 then
							dist = math.sqrt(dx * dx + dz * dz) * math.cos(diff)
							dist = math.clamp(dist, range.min, range.max)
						else
							dist = range.min
						end
					else
						dist = range.min
					end
					p.y = 0
				else
					dist = (range.min + range.max) * 0.5
					p = Vector3(0, 0, 0)
					inst.sg.statemem.targetpos = p
				end
				p.x = x + math.cos(rot) * dist
				p.z = z - math.sin(rot) * dist
				inst.sg.mem.ping = SpawnPrefab("deerclops_icelance_ping_fx")
				inst.sg.mem.ping.Transform:SetPosition(p:Get())
			end),
			FrameEvent(34, function(inst)
				inst.sg.mem.noice = inst.sg.mem.noice == nil and 0 or 1
			end),
			FrameEvent(47, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_throw_f47") end),
			FrameEvent(56, function(inst)
				DeerclopsFootstep(inst, false, true)
			end),
			FrameEvent(60, function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.attack)
				inst.sg.mem.ping:KillFX()
				inst.sg.mem.ping = nil
				local lance = SpawnPrefab("ttk_boss_fb_impact_circle_fx")
				lance.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
				inst.sg.statemem.targets = {}
				inst.sg.statemem.freezepower = 99
				DoIceLanceAOE(inst, inst.sg.statemem.targetpos, inst.sg.statemem.targets)
				inst.attack_count = inst.attack_count + 1
			end),
			FrameEvent(61, function(inst)
				DoIceLanceAOE(inst, inst.sg.statemem.targetpos, inst.sg.statemem.targets)
			end),
			FrameEvent(62, function(inst)
				DoIceLanceAOE(inst, inst.sg.statemem.targetpos, inst.sg.statemem.targets)
				if next(inst.sg.statemem.targets) == nil then
					inst:PushEvent("onmissother", { target = inst.sg.statemem.original_target })
				end
			end),
			FrameEvent(72, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(76, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.keepfacing = true
					inst.sg:GoToState("idle")
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
			end
			if inst.sg.mem.noice == 0 then
				inst.AnimState:Hide("ice_0")
			elseif inst.sg.mem.noice == 1 then
				inst.AnimState:Hide("ice_1")
			end
			if inst.sg.mem.ping ~= nil then
				inst.sg.mem.ping:KillFX()
			end
		end,
	},
	State{
		name = "icegrow",
		tags = { "icegrow", "busy" },
		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("ice_grow")
			inst.AnimState:Show("grow_ice_0")
			inst.AnimState:Show("grow_ice_1")
			inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_crackling_LP", "loop")
			StartAttackCooldown(inst)
		end,
		timeline =
		{
			FrameEvent(7, function(inst)
				DeerclopsFootstep(inst, false, true)
			end),
			FrameEvent(9, function(inst)
			end),
			FrameEvent(5, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.taunt_grrr) end),
			FrameEvent(6, function(inst)
				inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin")
			end),
			FrameEvent(9, function(inst)
				inst.SoundEmitter:PlaySound("rifts3/mutated_deerclops/ice_grow_4f_leadin")
			end),
			FrameEvent(13, function(inst)
				if inst.attack_count == 4 then
					if inst.owner and inst.owner:IsValid() then
						inst.owner:PushEvent("zhaohuan1")
					end
				elseif inst.attack_count == 8 then
					if inst.owner and inst.owner:IsValid() then
						inst.owner:PushEvent("zhaohuan2")
					end
					inst.attack_count = 0
				end
				inst.sg.mem.noice = nil
				inst.sg.statemem.icegrow = true
				inst.SoundEmitter:KillSound("loop")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("icegrow_pst")
				end
			end),
		},
		onexit = function(inst)
			 if inst.sg.mem.noice == nil then
				inst.AnimState:Show("ice_1")
				inst.AnimState:Show("ice_0")
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},
	State{
		name = "icegrow_pst",
		tags = { "busy" },
		onenter = function(inst)
			inst.AnimState:PlayAnimation("ice_grow_pst")
		end,
		timeline =
		{
			FrameEvent(12, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(14, function(inst)
				inst.sg:GoToState("idle", true)
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
}
return StateGraph("ttk_boss_deerclops_ziyun_aux", states, events, "corpse_mutate_pre", actionhandlers)
