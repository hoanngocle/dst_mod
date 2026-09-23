-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require("stategraphs/commonstates")
local easing = require("easing")
local actionhandlers =
{
}
local function SpawnCloseEmberFX(inst, angle)
	local x, y, z = inst.Transform:GetWorldPosition()
	angle = (inst.Transform:GetRotation() + angle) * DEGREES
	x = x + math.cos(angle) * 3.5
	z = z - math.sin(angle) * 3.5
	angle = math.random() * PI2
	x = x + math.cos(angle) * 0.6
	z = z - math.sin(angle) * 0.6
	if not TheWorld.Map:IsPassableAtPoint(x, 0, z) then
		return
	end
	local fx = table.remove(inst.ember_pool)
	if fx == nil then
		fx = SpawnPrefab("ttk_boss_fb_warg_mutated_ember_fx")
		fx:SetFXOwner(inst)
	end
	fx.Transform:SetPosition(x, 0, z)
	fx:RestartFX(1.7 + math.random() * 0.3, "nofade")
	fx:DoTaskInTime(math.random(18, 22) * FRAMES, fx.KillFX)
end
local function SpawnBreathFX(inst, angle, dist, targets)
	local fx = table.remove(inst.flame_pool)
	if fx == nil then
		fx = SpawnPrefab("ttk_boss_ziyunwarg_breath_fx")
		fx:SetFXOwner(inst)
	end
	local scale = (1.4 + math.random() * 0.25)
	if dist < 6 then
		scale = scale * 1.2
	elseif dist > 7 then
		scale = scale * (1 + (dist - 7) / 6)
	end
	local fadeoption = (dist < 6 and "nofade") or (dist <= 7 and "latefade") or nil
	local x, y, z = inst.Transform:GetWorldPosition()
	angle = (inst.Transform:GetRotation() + angle) * DEGREES
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist
	dist = dist / 20
	angle = math.random() * PI2
	x = x + math.cos(angle) * dist
	z = z - math.sin(angle) * dist
	fx.Transform:SetPosition(x, 0, z)
	fx:RestartFX(scale, fadeoption, targets)
end
local AOE_OFFSET = 3
local AOE_RANGE = 1.7
local AOE_RANGE_PADDING = 3
local AOE_TARGET_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "playerghost", "lunar_aligned" }
local MULTIHIT_FRAMES = 10
local function DoFlamethrowerAOE(inst, angle, targets)
end
local events =
{
}
local function ShowEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(true)
    end
end
local function HideEyeFX(inst)
    if inst._eyeflames ~= nil then
        inst._eyeflames:set(false)
    end
end
local states =
{
	State{
		name = "mutate",
		tags = { "busy", "noattack", "temp_invincible" },
		onenter = function(inst)
			inst.AnimState:PlayAnimation("mutate")
			inst.sg.statemem.flash = 24
			inst.sg:SetTimeout(40 * FRAMES)
		end,
        ontimeout = function(inst)
			inst.sg:GoToState("flamethrower_pre")
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
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("flamethrower_pre")
				end
			end),
		},
		onexit = function(inst)
			inst.AnimState:SetAddColour(0, 0, 0, 0)
			inst.AnimState:SetLightOverride(0)
		end,
	},
	State{
		name = "flamethrower_pre",
		tags = { "attack", "busy" },
		onenter = function(inst)
			inst.AnimState:PlayAnimation("atk_breath_pre")
			inst:SwitchToEightFaced()
			local dir
			local target = inst.target
			if target ~= nil and target:IsValid() then
				inst.sg.statemem.target = target
				inst.sg.statemem.targetpos = target:GetPosition()
				dir = inst:GetAngleToPoint(inst.sg.statemem.targetpos)
			else
				dir = inst.Transform:GetRotation()
			end
			inst.Transform:SetRotation(math.floor(dir / 45 + .5) * 45)
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
						inst.Transform:SetRotation(math.floor(rot1 / 45 + .5) * 45)
					end
				else
					inst.sg.statemem.target = nil
				end
			elseif inst.sg.statemem.angle ~= nil then
				DoFlamethrowerAOE(inst, inst.sg.statemem.angle, inst.sg.statemem.targets)
			end
		end,
		timeline =
		{
			FrameEvent(0, function(inst) inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pre_f0") end),
			FrameEvent(16, function(inst)
				inst.sg.statemem.target = nil
				inst.sg.statemem.targets = {}
			end),
			FrameEvent(17, function(inst)
				inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pre_f17")
				inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_lp", "loop")
			end),
			FrameEvent(19, function(inst) SpawnBreathFX(inst, -40, 4, inst.sg.statemem.targets) end),
			FrameEvent(20, function(inst) inst.sg.statemem.angle = -45 end),
			FrameEvent(21, function(inst) SpawnBreathFX(inst, -45, 6, inst.sg.statemem.targets) end),
			FrameEvent(24, function(inst) SpawnBreathFX(inst, -45, 8, inst.sg.statemem.targets) end),
			FrameEvent(27, function(inst) SpawnBreathFX(inst, -45, 9, inst.sg.statemem.targets) end),
			FrameEvent(29, function(inst) SpawnCloseEmberFX(inst, -45) end),
			FrameEvent(26, function(inst) SpawnBreathFX(inst, -45, 5, inst.sg.statemem.targets) end),
			FrameEvent(29, function(inst) SpawnBreathFX(inst, -45, 7, inst.sg.statemem.targets) end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.attacking = true
					inst.sg:GoToState("flamethrower_loop", inst.sg.statemem.targets)
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.attacking then
				inst:SwitchToSixFaced()
				inst.SoundEmitter:KillSound("loop")
			end
		end,
	},
	State{
		name = "flamethrower_loop",
		tags = { "attack", "busy" },
		onenter = function(inst, targets)
			inst.AnimState:PlayAnimation("atk_breath_loop")
			inst:SwitchToEightFaced()
			inst.sg.statemem.targets = targets or {}
			inst.sg.statemem.angle = -45
			if not inst.SoundEmitter:PlayingSound("loop") then
				inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_lp", "loop")
			end
		end,
		onupdate = function(inst)
			DoFlamethrowerAOE(inst, inst.sg.statemem.angle, inst.sg.statemem.targets)
		end,
		timeline =
		{
			FrameEvent(3, function(inst) SpawnBreathFX(inst, -45, 9, inst.sg.statemem.targets) end),
			FrameEvent(2, function(inst) inst.sg.statemem.angle = -27 end),
			FrameEvent(3, function(inst) SpawnCloseEmberFX(inst, -27) end),
			FrameEvent(0, function(inst) SpawnBreathFX(inst, -27, 5, inst.sg.statemem.targets) end),
			FrameEvent(3, function(inst) SpawnBreathFX(inst, -27, 7, inst.sg.statemem.targets) end),
			FrameEvent(7, function(inst)
				SpawnBreathFX(inst, -27, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, -27, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(4, function(inst) inst.sg.statemem.angle = -9 end),
			FrameEvent(5, function(inst) SpawnCloseEmberFX(inst, -9) end),
			FrameEvent(2, function(inst) SpawnBreathFX(inst, -9, 5, inst.sg.statemem.targets) end),
			FrameEvent(5, function(inst) SpawnBreathFX(inst, -9, 7, inst.sg.statemem.targets) end),
			FrameEvent(9, function(inst)
				SpawnBreathFX(inst, -9, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, -9, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(6, function(inst) inst.sg.statemem.angle = 9 end),
			FrameEvent(7, function(inst) SpawnCloseEmberFX(inst, 9) end),
			FrameEvent(4, function(inst) SpawnBreathFX(inst, 9, 5, inst.sg.statemem.targets) end),
			FrameEvent(7, function(inst) SpawnBreathFX(inst, 9, 7, inst.sg.statemem.targets) end),
			FrameEvent(11, function(inst)
				SpawnBreathFX(inst, 9, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, 9, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(9, function(inst) inst.sg.statemem.angle = 27 end),
			FrameEvent(10, function(inst) SpawnCloseEmberFX(inst, 27) end),
			FrameEvent(7, function(inst) SpawnBreathFX(inst, 27, 5, inst.sg.statemem.targets) end),
			FrameEvent(10, function(inst) SpawnBreathFX(inst, 27, 7, inst.sg.statemem.targets) end),
			FrameEvent(14, function(inst)
				SpawnBreathFX(inst, 27, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, 27, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(12, function(inst) inst.sg.statemem.angle = 45 end),
			FrameEvent(13, function(inst) SpawnCloseEmberFX(inst, 45) end),
			FrameEvent(10, function(inst) SpawnBreathFX(inst, 45, 5, inst.sg.statemem.targets) end),
			FrameEvent(13, function(inst) SpawnBreathFX(inst, 45, 7, inst.sg.statemem.targets) end),
			FrameEvent(17, function(inst)
				SpawnBreathFX(inst, 45, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, 45, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(15, function(inst) inst.sg.statemem.angle = 27 end),
			FrameEvent(16, function(inst) SpawnCloseEmberFX(inst, 27) end),
			FrameEvent(13, function(inst) SpawnBreathFX(inst, 27, 5, inst.sg.statemem.targets) end),
			FrameEvent(16, function(inst) SpawnBreathFX(inst, 27, 7, inst.sg.statemem.targets) end),
			FrameEvent(20, function(inst)
				SpawnBreathFX(inst, 27, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, 27, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(18, function(inst) inst.sg.statemem.angle = 9 end),
			FrameEvent(19, function(inst) SpawnCloseEmberFX(inst, 9) end),
			FrameEvent(16, function(inst) SpawnBreathFX(inst, 9, 5, inst.sg.statemem.targets) end),
			FrameEvent(19, function(inst) SpawnBreathFX(inst, 9, 7, inst.sg.statemem.targets) end),
			FrameEvent(23, function(inst)
				SpawnBreathFX(inst, 9, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, 9, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(21, function(inst) inst.sg.statemem.angle = -9 end),
			FrameEvent(22, function(inst) SpawnCloseEmberFX(inst, -9) end),
			FrameEvent(19, function(inst) SpawnBreathFX(inst, -9, 5, inst.sg.statemem.targets) end),
			FrameEvent(22, function(inst) SpawnBreathFX(inst, -9, 7, inst.sg.statemem.targets) end),
			FrameEvent(26, function(inst)
				SpawnBreathFX(inst, -9, 9, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, -9, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(24, function(inst) inst.sg.statemem.angle = -27 end),
			FrameEvent(25, function(inst) SpawnCloseEmberFX(inst, -27) end),
			FrameEvent(22, function(inst) SpawnBreathFX(inst, -27, 5, inst.sg.statemem.targets) end),
			FrameEvent(25, function(inst)
				SpawnBreathFX(inst, -27, 7, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, -27, 9+k*2, inst.sg.statemem.targets)
				end
			end),
			FrameEvent(27, function(inst) inst.sg.statemem.angle = -45 end),
			FrameEvent(28, function(inst) SpawnCloseEmberFX(inst, -45) end),
			FrameEvent(25, function(inst) SpawnBreathFX(inst, -45, 5, inst.sg.statemem.targets) end),
			FrameEvent(28, function(inst)
				SpawnBreathFX(inst, -45, 7, inst.sg.statemem.targets)
				for k = 1,inst.addrange do
					SpawnBreathFX(inst, -45, 9+k*2, inst.sg.statemem.targets)
				end
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.attacking = true
					if inst.sg.statemem.loop then
						SpawnBreathFX(inst, -27, 9, inst.sg.statemem.targets)
						inst.sg:GoToState("flamethrower_loop", inst.sg.statemem.targets)
					else
						inst.sg:GoToState("flamethrower_pst", inst.sg.statemem.targets)
					end
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.attacking then
				inst:SwitchToSixFaced()
				inst.SoundEmitter:KillSound("loop")
			elseif not inst.sg.statemem.loop then
			end
		end,
	},
	State{
		name = "flamethrower_pst",
		tags = { "attack", "busy" },
		onenter = function(inst, targets)
			inst.AnimState:PlayAnimation("atk_breath_pst")
			inst:SwitchToEightFaced()
			inst.SoundEmitter:PlaySound("rifts3/mutated_varg/blast_pst")
			inst.sg.statemem.targets = targets or {}
		end,
		timeline =
		{
			FrameEvent(0, function(inst) SpawnBreathFX(inst, -27, 9, inst.sg.statemem.targets) end),
			FrameEvent(3, function(inst) SpawnBreathFX(inst, -45, 9, inst.sg.statemem.targets) end),
			FrameEvent(4, function(inst)
				inst.sg:AddStateTag("caninterrupt")
			end),
			FrameEvent(6, function(inst) inst.SoundEmitter:KillSound("loop") end),
			FrameEvent(13, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.DoDespawn then
						inst:DoDespawn()
					else
						inst:Remove()
					end
				end
			end),
		},
		onexit = function(inst)
			inst:SwitchToSixFaced()
			inst.SoundEmitter:KillSound("loop")
		end,
	},
}
return StateGraph("ttk_boss_ziyunwarg", states, events, "mutate", actionhandlers)
