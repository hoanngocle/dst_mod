-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require("stategraphs/commonstates")
local hit_recovery_delay = CommonHandlers.HitRecoveryDelay
local actionhandlers =
{
}
local events=
{
}
local function TrySplashFX(inst, size)
	local x, y, z = inst.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
		SpawnPrefab("ocean_splash_"..(size or "med")..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
		return true
	end
end
local states = {
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, pushanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
        end,
        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    State{
		name = "lunge_pre",
		tags = { "attack", "busy" },
		onenter = function(inst, target)
			inst.AnimState:SetBankAndPlayAnimation("lavaarena_shadow_lunge", "lunge_pre")
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
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.lunge = true
					inst.sg:GoToState("lunge_loop", { target = inst.sg.statemem.target, targetpos = inst.sg.statemem.targetpos })
				end
			end),
		},
		onexit = function(inst)
			if not inst.sg.statemem.lunge then
				inst.AnimState:SetBank(Boss.Art("wilson"))
			end
		end,
	},
	State{
		name = "lunge_loop",
		tags = { "attack", "busy", "noattack", "temp_invincible" },
		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("lunge_loop")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
			inst.SoundEmitter:PlaySound("dontstarve/impacts/impact_shadow_med_sharp")
			if data ~= nil then
				if data.target ~= nil and data.target:IsValid() then
					inst.sg.statemem.target = data.target
					inst:ForceFacePoint(data.target.Transform:GetWorldPosition())
				elseif data.targetpos ~= nil then
					inst:ForceFacePoint(data.targetpos)
				end
			end
            inst.targets = {}
			inst.Physics:SetMotorVelOverride(35, 0, 0)
			inst.sg:SetTimeout(8 * FRAMES)
		end,
		onupdate = function(inst)
            local attacker = inst.owner or inst
            if attacker and attacker:IsValid() then
                attacker:DoAoeAttck(inst:GetPosition(),3,inst.damage or 10,inst.targets)
            end
		end,
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
                    inst.sg.statemem.lunge = true
                    inst.sg:GoToState("lunge_pst", inst.sg.statemem.target)
				end
			end),
		},
		ontimeout = function(inst)
			inst.sg.statemem.lunge = true
			inst.sg:GoToState("lunge_pst")
		end,
		onexit = function(inst)
			if not inst.sg.statemem.lunge then
				inst.AnimState:SetBank(Boss.Art("wilson"))
			end
		end,
	},
	State{
		name = "lunge_pst",
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
                    inst:Remove()
				end
			end),
		},
		onexit = function(inst)
		end,
	},
	State{
		name = "appear",
		tags = { "busy", "noattack", "temp_invincible", "phasing" },
		onenter = function(inst)
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
}
return StateGraph("ttk_boss_ziyunshadow", states, events, "appear", actionhandlers)
