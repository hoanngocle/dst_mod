require("stategraphs/commonstates")
local easing = require("easing")
local TTK_GetDamageTargets = require("ttk_batch19_houseutil").GetDamageTargets

local SHAKE_DIST = 40

local function ChooseAttack(inst, target)
	target = target or inst.components.combat.target
	if target ~= nil and not target:IsValid() then
		target = nil
	end

	if target == nil then
		return false
	end

	if target:HasTag("beehive") then
		inst.sg:GoToState("attack", target)
		return true
    end

	if not inst.components.timer:TimerExists("GroundPound") then
        inst.sg:GoToState("pound")
		return true
    end
	inst.sg:GoToState("attack", target)
	return true
end

local ARC = 90 * DEGREES 
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local MAX_SIDE_TOSS_STR = 0.8

local function DoArcAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
	inst.components.combat.ignorehitrange = true
	local x, y, z = inst.Transform:GetWorldPosition()
	local rot = inst.Transform:GetRotation() * DEGREES
	local x0, z0
	if dist ~= 0 then
		if dist > 0 and ((mult ~= nil and mult > 1) or (heavymult ~= nil and heavymult > 1)) then
			x0, z0 = x, z
		end
		x = x + dist * math.cos(rot)
		z = z - dist * math.sin(rot)
	end
	local ents = TTK_GetDamageTargets(x, y, z, radius + AOE_RANGE_PADDING)
	for i, v in ipairs(ents) do
		if v ~= inst and
			not (targets ~= nil and targets[v]) and
			v:IsValid() and not v:IsInLimbo()
			and not (v.components.health ~= nil and v.components.health:IsDead())
		then
			local range = radius + v:GetPhysicsRadius(0)
			local x1, y1, z1 = v.Transform:GetWorldPosition()
			local dx = x1 - x
			local dz = z1 - z
			local distsq = dx * dx + dz * dz
			if distsq > 0 and distsq < range * range and
				DiffAngleRad(rot, math.atan2(-dz, dx)) < ARC and
				inst.components.combat:CanTarget(v)
			then
				inst.components.combat:DoAttack(v)
				if mult ~= nil then
					local strengthmult = (v.components.inventory ~= nil and v.components.inventory:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
					if strengthmult > MAX_SIDE_TOSS_STR and x0 ~= nil then
						
						dx = x1 - x0
						dz = z1 - z0
						if dx ~= 0 or dz ~= 0 then
							local rot1 = math.atan2(-dz, dx) + PI
							local k = math.max(0, math.cos(math.min(PI, DiffAngleRad(rot1, rot) * 2)))
							strengthmult = MAX_SIDE_TOSS_STR + (strengthmult - MAX_SIDE_TOSS_STR) * k * k
						end
					end
					v:PushEvent("knockback", { knocker = inst, radius = radius + dist, strengthmult = strengthmult, forcelanded = forcelanded })
				end
				if targets ~= nil then
					targets[v] = true
				end
			end
		end
	end
	inst.components.combat.ignorehitrange = false
end

local function TryStagger(inst)
	inst.sg:GoToState("stagger_pre")
	return true
end

local function IsAggro(inst) 
	return inst.components.combat.target ~= nil
		and not inst.components.combat.target:HasTag("beehive")
end

local TRACKING_ARC = 90

local function StartTrackingTarget(inst, target)
	if target ~= nil and target:IsValid() then
		inst.sg.statemem.target = target
		inst.sg.statemem.targetpos = target:GetPosition()
		inst.sg.statemem.tracking = true
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local rot = inst.Transform:GetRotation()
		local rot1 = inst:GetAngleToPoint(x1, y1, z1)
		local diff = DiffAngle(rot, rot1)
		if diff < TRACKING_ARC then
			inst.Transform:SetRotation(rot1)
		end
	end
end

local function UpdateTrackingTarget(inst)
	if inst.sg.statemem.tracking then
		if inst.sg.statemem.target ~= nil then
			if inst.sg.statemem.target:IsValid() then
				local p = inst.sg.statemem.targetpos
				p.x, p.y, p.z = inst.sg.statemem.target.Transform:GetWorldPosition()
			else
				inst.sg.statemem.target = nil
			end
		end
		if inst.sg.statemem.targetpos ~= nil then
			local rot = inst.Transform:GetRotation()
			local rot1 = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
			local drot = ReduceAngle(rot1 - rot)
			if math.abs(drot) < TRACKING_ARC then
				rot1 = rot + math.clamp(drot / 2, -1, 1)
				inst.Transform:SetRotation(rot1)
			end
		end
	end
end

local function StopTrackingTarget(inst)
	inst.sg.statemem.tracking = false
end

local function SpawnSwipeFX(inst, offset, reverse)
	if inst.swipefx ~= nil then
		
		inst.sg.statemem.fx = SpawnPrefab(inst.swipefx)
		inst.sg.statemem.fx.entity:SetParent(inst.entity)
		inst.sg.statemem.fx.Transform:SetPosition(offset, 0, 0)
		if reverse then
			inst.sg.statemem.fx:Reverse()
		end
	end
end

local function KillSwipeFX(inst)
	if inst.sg.statemem.fx ~= nil then
		if inst.sg.statemem.fx:IsValid() then
			inst.sg.statemem.fx:Remove()
		end
		inst.sg.statemem.fx = nil
	end
end

local actionhandlers =
{
	ActionHandler(ACTIONS.GOHOME, "gohome"),
}

local events =
{
	CommonHandlers.OnLocomote(true, true),
	CommonHandlers.OnSleepEx(),
	CommonHandlers.OnWakeEx(),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnDeath(),
    CommonHandlers.OnSink(),
	EventHandler("doattack", function(inst, data)
		if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
			ChooseAttack(inst, data ~= nil and data.target or nil)
		end
	end),
	EventHandler("attacked", function(inst, data)
		
		if inst.components.health ~= nil and not inst.components.health:IsDead() and (
			not inst.sg:HasStateTag("busy") or
			inst.sg:HasStateTag("caninterrupt") or
			inst.sg:HasStateTag("frozen")
		) then
			if inst.sg:HasStateTag("staggered") then
				inst.sg.statemem.staggered = true
				inst.sg:GoToState("stagger_hit")
			elseif not CommonHandlers.HitRecoveryDelay(inst) then
				inst.sg:GoToState(inst:IsStandState("quad") and "hit" or "standing_hit")
			end
		end
	end),
}

local function ShakeIfClose(inst)
    
end

local function ShakeIfClose_Pound(inst)
    
end

local function ShakeIfClose_Footstep(inst)
    
end

local function DoFootstep(inst)
	if inst:IsStandState("quad") then
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
	else
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
		ShakeIfClose_Footstep(inst)
	end
end

local function GoToStandState(inst, state, customtrans, params)
	if inst:IsStandState(state) then
		return true
	end
	inst.sg:GoToState(string.lower(state), { endstate = inst.sg.currentstate.name, customtrans = customtrans, params = params })
end

local IDLE_FLAGS =
{
	Aggro =		0x01,
	Calm =		0x02,
	NoFaced =	0x04,
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
		name = "bi",
		tags = { "busy" },

		onenter = function(inst, data)
			inst.components.locomotor:StopMoving()
			inst.sg.statemem.endstate = data.endstate
			inst.sg.statemem.params = data.params

			local flags = data.endstate == "idle" and data.params or nil
			local nofaced, aggro
			if flags ~= nil then
				nofaced = checkbit(flags, IDLE_FLAGS.NoFaced)
				if checkbit(flags, IDLE_FLAGS.Aggro) then
					aggro = true
				elseif checkbit(flags, IDLE_FLAGS.Calm) then
					aggro = false
				end
			end
			if aggro == nil then
				aggro = IsAggro(inst)
			end

			if data.customtrans ~= nil then
				inst.AnimState:PlayAnimation(data.customtrans)
				inst:SetStandState("bi")
			else
				inst.AnimState:PlayAnimation((aggro and "taunt_pre" or "to_bi")..(nofaced and "_nofaced" or ""))
			end

			inst.sg.statemem.endbusy =
				data.endstate == "idle" or
				data.endstate == "walk_start" or
				data.endstate == "run_start"
		end,

		timeline =
		{
			FrameEvent(6, DoFootstep),
			FrameEvent(7, function(inst)
				inst:SetStandState("bi")
			end),
			FrameEvent(8, function(inst)
				if inst.sg.statemem.endbusy and inst.sg.mem.dostagger then
					TryStagger(inst)
				end
			end),
			FrameEvent(12, function(inst)
				if inst.sg.statemem.endbusy then
					if inst.sg.mem.dostagger and TryStagger(inst) then
						return
					end
					inst.sg:RemoveStateTag("busy")
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.endstate, inst.sg.statemem.params)
				end
			end),
		},
	},

	State{
		name = "quad",
		tags = { "busy" },

		onenter = function(inst, data)
			inst.components.locomotor:StopMoving()
			inst.sg.statemem.endstate = data.endstate
			inst.sg.statemem.params = data.params
			if data.customtrans ~= nil then
				inst.AnimState:PlayAnimation(data.customtrans)
				inst:SetStandState("quad")
			else
				inst.AnimState:PlayAnimation("taunt_pst")
			end
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				inst:SetStandState("quad")
				DoFootstep(inst)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.endstate, inst.sg.statemem.params)
				end
			end),
		},
	},

	State{
		name = "idle",
		tags = { "idle", "canrotate" },

		onenter = function(inst, flags)
			if inst.sg.mem.dostagger and TryStagger(inst) then
				return
			elseif GoToStandState(inst, "bi", nil, flags) then
				inst.components.locomotor:StopMoving()
				local nofaced, aggro
				if flags ~= nil then
					nofaced = checkbit(flags, IDLE_FLAGS.NoFaced)
					if checkbit(flags, IDLE_FLAGS.Aggro) then
						aggro = true
					elseif checkbit(flags, IDLE_FLAGS.Calm) then
						aggro = false
					end
				end
				if aggro == nil then
					aggro = IsAggro(inst)
				end
				inst.AnimState:PlayAnimation((aggro and "standing_idle" or "idle_loop")..(nofaced and "_nofaced" or ""), true)
			end
		end,

		onexit = function(inst)
			inst:SwitchToFourFaced()
		end,
	},

	State{
		name = "hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("hit")
			inst.sg.statemem.aggro = IsAggro(inst)
			inst.AnimState:PushAnimation(inst.sg.statemem.aggro and "taunt_pre" or "to_bi", false)
			inst:SetStandState("quad")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if not inst.sg.mem.dostagger and inst.sg.statemem.doattack == nil then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			
			FrameEvent(12 + 7, function(inst)
				inst:SetStandState("bi")
			end),
			FrameEvent(12 + 8, function(inst)
				if inst.sg.mem.dostagger then
					TryStagger(inst)
				end
			end),
			FrameEvent(12 + 12, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if not inst.sg.mem.dostagger then
					if not inst.sg:HasStateTag("busy") then
						ChooseAttack(inst, data ~= nil and data.target or nil)
					else
						inst.sg.statemem.doattack = data ~= nil and data.target or nil
						inst.sg:RemoveStateTag("caninterrupt")
					end
				end
				return true
			end),
			EventHandler("stagger", function(inst)
				if not inst.sg:HasStateTag("busy") then
					TryStagger(inst)
				else
					inst.sg.mem.dostagger = true
					inst.sg:RemoveStateTag("caninterrupt")
				end
				return true
			end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", inst.sg.statemem.aggro and IDLE_FLAGS.Aggro or IDLE_FLAGS.Calm)
				end
			end),
		},
	},

	State{
		name = "standing_hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("standing_hit")
			inst:SetStandState("bi")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
		end,

		timeline =
		{
			FrameEvent(11, function(inst)
				if (inst.sg.mem.dostagger and TryStagger(inst)) or
					(inst.sg.statemem.doattack ~= nil and ChooseAttack(inst, inst.sg.statemem.doattack)) then
					return
				end
				inst.sg.statemem.doattack = nil
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("doattack", function(inst, data)
				if not inst.sg.mem.dostagger then
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
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},
	},
	State{
		name = "attack_action",
		onenter = function(inst)
			local buffaction = inst:GetBufferedAction()
			inst.sg:GoToState("attack", buffaction ~= nil and buffaction.target or nil)
		end,
	},

	State{
		name = "attack",
		tags = { "attack", "busy", "weapontoss" },

		onenter = function(inst, target)
			if inst.cancombo then
				inst.sg:GoToState("attack_combo1", target)
			elseif GoToStandState(inst, "bi", nil, target) then
				inst.components.locomotor:StopMoving()
				inst.components.combat:StartAttack()
				inst:SwitchToEightFaced()
				inst.AnimState:PlayAnimation("atk")
				StartTrackingTarget(inst, target)
				inst.sg.statemem.original_target = target 
			end
		end,

		onupdate = UpdateTrackingTarget,

		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(10, StopTrackingTarget),
			FrameEvent(28, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(29, function(inst)
				SpawnSwipeFX(inst, 1)
			end),
			FrameEvent(32, function(inst)
				inst.sg.statemem.targets = {}
				DoArcAttack(inst, 1, TUNING.BEARGER_MELEE_RANGE, nil, nil, nil, inst.sg.statemem.targets)
			end),
			FrameEvent(33, function(inst)
				DoArcAttack(inst, 1, TUNING.BEARGER_MELEE_RANGE, nil, nil, nil, inst.sg.statemem.targets)
				if next(inst.sg.statemem.targets) == nil then
					inst:PushEvent("onmissother", { target = inst.sg.statemem.original_target }) 
				end
			end),
			FrameEvent(47, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(54, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.keepfacing = true
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},

		onexit = function(inst)
			KillSwipeFX(inst)
			if not inst.sg.statemem.keepfacing then
				inst:SwitchToFourFaced()
			end
		end,
	},

	State{
		name = "pound",
		tags = { "attack", "busy" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:StopMoving()
				inst.AnimState:PlayAnimation("ground_pound")
			end
		end,

		timeline =
		{
			FrameEvent(13, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh") end),
			FrameEvent(20, function(inst)
				ShakeIfClose_Pound(inst)
				inst.components.groundpounder:GroundPound()
				inst.components.timer:StopTimer("GroundPound")
				inst.components.timer:StartTimer("GroundPound", 15)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
			end),
			FrameEvent(21, function(inst)
				inst:SetStandState("quad")
			end),
			FrameEvent(30, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:AddStateTag("caninterrupt")
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
		name = "butt_face_hit",
		tags = { "hit", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("butt_face_hit")
			inst:SetStandState("bi")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
			inst.sg.statemem.vulnerable = true
		end,

		timeline =
		{
			FrameEvent(8, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg.statemem.canstagger = true
			end),
			FrameEvent(28, function(inst)
				inst:SetStandState("quad")
				inst.sg.statemem.vulnerable = false
			end),
		},

		events =
		{
			EventHandler("attacked", function(inst, data)
				if inst.sg.statemem.vulnerable and
					not inst.components.health:IsDead() and
					data ~= nil and data.spdamage ~= nil and data.spdamage.planar ~= nil
				then
					inst.sg.mem.dostagger = true
					if inst.sg.statemem.canstagger then
						TryStagger(inst)
					end
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},
	},

	State{
		name = "death",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor:Stop()
				inst.AnimState:PlayAnimation("death")
			else
				inst.sg:AddStateTag("dead")
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/death") end),
			FrameEvent(46, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound") end),
			FrameEvent(48, function(inst)
				ShakeIfClose(inst)
				inst.components.lootdropper:DropLoot(inst:GetPosition())
				inst.looted = true
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("corpse")
				end
			end)
		},
	},

	State{
		name = "corpse",
		tags = { "dead", "busy", "noattack" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("corpse")
		end,

		timeline =
		{
			
			FrameEvent(1, function(inst)
				local corpse = nil
				if corpse == nil then
					inst:AddTag("NOCLICK")
					inst.persists = false
					RemovePhysicsColliders(inst)

					local delay = (inst.components.health.destroytime or 2) - 59 * FRAMES
					if delay > 0 then
						inst.sg:SetTimeout(delay)
					else
						ErodeAway(inst)
					end
				elseif IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
					corpse:SetAltBuild("yule")
				end
			end),
		},

		ontimeout = ErodeAway,
	},

	State{
		name = "corpse_idle",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("corpse")
		end,
	},

	State{
		name = "walk_start",
		tags = { "moving", "canrotate" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				if IsAggro(inst) then
					inst.components.locomotor.walkspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
					inst.AnimState:PlayAnimation("charge_pre")
				else
					inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
					inst.AnimState:PlayAnimation("walk_pre")
				end
				inst.components.locomotor:WalkForward()
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("walk")
				end
			end),
		},
	},

	State{
		name = "walk",
		tags = { "moving", "canrotate" },

		onenter = function(inst)
			inst:SetStandState("bi")
			inst.sg.statemem.aggro = IsAggro(inst)
			if inst.sg.statemem.aggro then
				inst.components.locomotor.walkspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
				inst.AnimState:PlayAnimation("charge_loop")
			else
				inst.components.locomotor.walkspeed = TUNING.BEARGER_CALM_WALK_SPEED
				inst.AnimState:PlayAnimation("walk_loop")
			end
			inst.components.locomotor:WalkForward()
			if inst.components.combat:HasTarget() and math.random() < 0.5 then
				inst.sg:SetTimeout(math.random(13) * FRAMES)
			end
		end,

		ontimeout = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/grrrr")
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				if inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
			FrameEvent(17, function(inst)
				if inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
			
			FrameEvent(3, function(inst)
				if not inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
			FrameEvent(29, function(inst)
				if not inst.sg.statemem.aggro then
					DoFootstep(inst)
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("walk")
				end
			end),
		},
	},

	State{
		name = "walk_stop",
		tags = { "canrotate" },

		onenter = function(inst)
			inst:SetStandState("bi")
			inst.components.locomotor:StopMoving()
			inst.sg.statemem.aggro = IsAggro(inst)
			inst.AnimState:PlayAnimation(inst.sg.statemem.aggro and "charge_pst" or "walk_pst")
			DoFootstep(inst)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", inst.sg.statemem.aggro and IDLE_FLAGS.Aggro or IDLE_FLAGS.Calm)
				end
			end),
		},
	},

	State{
		name = "run_start",
		tags = { "moving", "running", "atk_pre", "canrotate" },

		onenter = function(inst)
			if GoToStandState(inst, "bi") then
				inst.components.locomotor.runspeed = TUNING.BEARGER_ANGRY_WALK_SPEED
				inst.components.locomotor:RunForward()
				if not inst.SoundEmitter:PlayingSound("taunt") then
					inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt")
				end
				inst.AnimState:PlayAnimation("charge_pre")
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

		onexit = function(inst)
			inst.components.locomotor.runspeed = TUNING.BEARGER_RUN_SPEED
		end,
	},

	State{
		name = "run",
		tags = { "moving", "running", "canrotate" },

		onenter = function(inst)
			inst:SetStandState("bi")
			inst.components.locomotor:RunForward()
			if not inst.SoundEmitter:PlayingSound("taunt") then
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt", "taunt")
			end
			inst.AnimState:PlayAnimation("charge_roar_loop")
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				DoFootstep(inst)
			end),
			FrameEvent(8, function(inst)
				DoFootstep(inst)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("run")
				end
			end),
		},
	},

	State{
		name = "run_stop",
		tags = { "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("charge_pst")
			DoFootstep(inst)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.Aggro)
				end
			end),
		},
	},

	State{
		name = "sleep",
		tags = { "busy", "sleeping", "nowake", "caninterrupt" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.last_eat_time = nil 
			inst.sg.mem.dostagger = nil
			if inst:IsStandState("quad") then
				inst.AnimState:PlayAnimation("sleep_pre")
			else
				inst.AnimState:PlayAnimation("standing_sleep_pre")
				inst.AnimState:PushAnimation("sleep_pre", false)
			end
		end,

		timeline =
		{
			FrameEvent(24, function(inst)
				if inst.AnimState:IsCurrentAnimation("sleep_pre") then
					inst.sg:RemoveStateTag("caninterrupt")
				end
			end),
			FrameEvent(25, function(inst)
				if inst:IsStandState("bi") then
					inst:SetStandState("quad")
					DoFootstep(inst)
				end
			end),
			FrameEvent(34 + 24, function(inst)
				inst.sg:RemoveStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.continuesleeping = true
					inst.sg:GoToState(inst.sg.mem.sleeping and "sleeping" or "wake")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.continuesleeping and inst.components.sleeper:IsAsleep() then
				inst.components.sleeper:WakeUp()
			end
		end,
	},

	State{
		name = "sleeping",
		tags = { "busy", "sleeping" },

		onenter = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/sleep")
			inst.AnimState:PlayAnimation("sleep_loop")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.continuesleeping = true
					inst.sg:GoToState("sleeping")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.continuesleeping and inst.components.sleeper:IsAsleep() then
				inst.components.sleeper:WakeUp()
			end
		end,
	},

	State{
		name = "wake",
		tags = { "busy", "waking", "nosleep" },

		onenter = function(inst)
			inst.last_eat_time = GetTime() 
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("sleep_pst")
			if inst.components.sleeper:IsAsleep() then
				inst.components.sleeper:WakeUp()
			end
			inst:SetStandState("quad")
		end,

		timeline =
		{
			FrameEvent(27, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt_short") end),
			CommonHandlers.OnNoSleepFrameEvent(33, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:RemoveStateTag("nosleep")
			end),
			FrameEvent(44, function(inst)
				inst:SetStandState("bi")
			end),
		},

		events =
		{
			EventHandler("stagger", function(inst)
				if not inst.sg:HasStateTag("nosleep") then
					TryStagger(inst)
				else
					inst.sg.mem.dostagger = true
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
		name = "stagger_pre",
		tags = { "staggered", "busy", "nosleep" },

		onenter = function(inst)
			inst.sg.mem.dostagger = nil
			inst.components.timer:StopTimer("stagger")
			inst.components.timer:StartTimer("stagger", TUNING.MUTATED_BEARGER_STAGGER_TIME)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("stagger_pre")
			if inst:IsStandState("bi") then
				inst.AnimState:SetFrame(3)
				inst.sg:GoToState("stagger_pre_timeline_from_frame3")
			end
		end,

		timeline =
		{
			
			FrameEvent(2, function(inst)
				inst:SetStandState("bi")
			end),
			FrameEvent(3, function(inst)
				inst.sg:GoToState("stagger_pre_timeline_from_frame3")
			end),
		},
	},

	State{
		name = "stagger_pre_timeline_from_frame3",
		tags = { "staggered", "busy", "nosleep" },

		timeline =
		{
			
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/yawn") end),
			FrameEvent(33, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack") end),
			FrameEvent(40, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/yawn", nil, 0.5) end),
			FrameEvent(54, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
				ShakeIfClose_Footstep(inst)
			end),
			FrameEvent(56, function(inst)
				inst:SetStandState("quad")
			end),
			FrameEvent(80, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
				ShakeIfClose(inst)
			end),
			FrameEvent(83, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.components.timer:TimerExists("stagger") and "stagger_idle" or "stagger_pst")
				end
			end),
		},
	},

	State{
		name = "stagger_idle",
		tags = { "staggered", "busy", "caninterrupt", "nosleep" },

		onenter = function(inst)
			if not inst.components.timer:TimerExists("stagger") then
				inst.sg:GoToStandState("stagger_pst")
				return
			end
			inst.AnimState:PlayAnimation("stagger", true)
			inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
		end,

		events =
		{
			EventHandler("timerdone", function(inst, data)
				if data ~= nil and data.name == "stagger" then
					inst.sg:GoToState("stagger_pst")
				end
			end),
		},
	},

	State{
		name = "stagger_hit",
		tags = { "staggered", "busy", "hit", "nosleep" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("stagger_hit")
		end,

		timeline =
		{
			FrameEvent(10, function(inst)
				if inst.components.timer:TimerExists("stagger") then
					inst.sg:AddStateTag("caninterrupt")
				end
			end),
			FrameEvent(15, function(inst)
				if not inst.components.timer:TimerExists("stagger") then
					inst.sg:GoToState("stagger_pst", true)
					return
				end
				inst.sg.statemem.cangetup = true
			end),
		},

		events =
		{
			EventHandler("timerdone", function(inst, data)
				if data ~= nil and data.name == "stagger" and inst.sg.statemem.cangetup then
					inst.sg:GoToState("stagger_pst", true)
				end
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.components.timer:TimerExists("stagger") then
						inst.sg:GoToState("stagger_idle")
					else
						inst.sg:GoToState("stagger_pst", true)
					end
				end
			end),
		},
	},

	State{
		name = "stagger_pst",
		tags = { "staggered", "busy", "nosleep" },

		onenter = function(inst, nohit)
			inst.AnimState:PlayAnimation("stagger_pst")
			inst.sg.statemem.aggro = IsAggro(inst)
			inst.AnimState:PushAnimation(inst.sg.statemem.aggro and "standing_stagger_pst2" or "stagger_pst2", false)
			if not nohit then
				inst.sg:AddStateTag("caninterrupt")
			end
			if inst.components.sleeper ~= nil then
				inst.components.sleeper:WakeUp()
			end
		end,

		timeline =
		{
			FrameEvent(41, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt_short") end),
			FrameEvent(45, function(inst)
				inst.sg:RemoveStateTag("staggered")
				inst.sg:RemoveStateTag("caninterrupt")
			end),
			FrameEvent(56, function(inst)
				inst:SetStandState("bi")
			end),
			CommonHandlers.OnNoSleepFrameEvent(60, function(inst)
				if inst.sg.mem.dostagger and TryStagger(inst) then
					return
				end
				inst.sg:RemoveStateTag("nosleep")
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(67, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:AddStateTag("canrotate")
				inst:StartButtRecovery()
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle", IDLE_FLAGS.NoFaced + (inst.sg.statemem.aggro and IDLE_FLAGS.Aggro or IDLE_FLAGS.Calm))
				end
			end),
		},

		onexit = function(inst)
			inst:StartButtRecovery()
		end,
	},

    State{
        name = "gohome",
		tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        timeline =
        {
            TimeEvent(0.5, function(inst)inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door") inst:PerformBufferedAction() inst.sg:GoToState("idle") end),
        },
    },
	
}

CommonStates.AddFrozenStates(states, function(inst) inst:SetStandState("bi") end)
CommonStates.AddSinkAndWashAshoreStates(states)

return StateGraph("ttk_bearger", states, events, "init", actionhandlers)
