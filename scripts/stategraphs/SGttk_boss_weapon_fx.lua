-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require("stategraphs/commonstates")
local states =
{
	State{
		name = "idle",
		tags = { "idle", "canrotate" },
		onenter = function(inst)
		end,
	},
	State{
		name = "taunt",
		tags = { "taunt", "busy" },
		onenter = function(inst, target)
			inst.AnimState:PlayAnimation("xd_taunt")
			SpawnAt("ttk_boss_baihu_fsfx",inst,nil,Vector3(0,2,0))
		end,
		timeline =
		{
			FrameEvent(4, function(inst) inst.SoundEmitter:PlaySound("daywalker/voice/chainbreak_break_2",nil,0.75) end),
			FrameEvent(18, function(inst)
			end),
			FrameEvent(19, function(inst)
			end),
			FrameEvent(38, function(inst)
			end),
			FrameEvent(47, function(inst) inst.SoundEmitter:PlaySound(inst.footstep, nil, 0.2) end),
			FrameEvent(50, function(inst)
			end),
		},
		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:Remove()
				end
			end),
		},
	},
    State{
        name = "castspell",
        tags = { "doing", "busy", "canrotate" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            local colour = { 0, 0, 0 }
            inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(colour)
            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)
			inst.components.colourtweener:StartTween({0, 0, 0, 0.5}, 0.4, function() end)
        end,
        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
            end),
			TimeEvent(69 * FRAMES, function(inst)
				inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength()-0.5,function()
				end)
			end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:IsCurrentAnimation("staff") then
					inst:DoTaskInTime(0,function()
						inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength()-0.5,function()
							inst.components.colourtweener:StartTween({0, 0, 0, 0}, 0.5, inst.Remove)
						end)
					end)
                end
            end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                   inst:Remove()
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
}
return StateGraph("ttk_boss_weapon_fx", states, {}, "idle")
