-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
require("stategraphs/commonstates")
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/antlion_sinkhole.zip")),
}
local prefabs =
{
    "sinkhole_spawn_fx_1",
    "sinkhole_spawn_fx_2",
    "sinkhole_spawn_fx_3",
    "mining_ice_fx",
    "mining_fx",
    "mining_moonglass_fx",
}
local NUM_CRACKING_STAGES = 1
local COLLAPSE_STAGE_DURATION = 1
local OBJECT_SCALE = 0.6
local NUM_FX = 7
local FX_THETA_DELTA = TWOPI / NUM_FX
local FX_RADIUS = 1.6
local function SpawnFx(inst, scale, pos)
    local theta = math.random() * PI * 2
    pos = pos or inst:GetPosition()
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(pos:Get())
    for i = 1, NUM_FX do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))
        dust.Transform:SetPosition(
            pos.x + math.cos(theta) * FX_RADIUS * (1 + math.random() * .1),
            0,
            pos.z - math.sin(theta) * FX_RADIUS * (1 + math.random() * .1)
        )
        local s = scale + math.random() * .2
        local x_scale = (i % 2 == 0 and -s) or s
        dust.Transform:SetScale(x_scale, s, s)
        theta = theta + FX_THETA_DELTA
    end
    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 2 })
end
local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "repair" then
        if not inst:IsAsleep() then
			SpawnFx(inst, inst.scale / 2)
        end
        inst.components.unevenground:Disable()
        inst.persists = false
        ErodeAway(inst)
    end
end
local function DoCollapse(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, COLLAPSE_STAGE_DURATION, .03, .15, inst, inst.radius * 6)
    inst.components.unevenground:Enable()
    local pos = inst:GetPosition()
	SpawnFx(inst, inst.scale, pos)
    inst.components.timer:StartTimer("repair", 20)
end
local function DoFXCollapse(inst,time)
    inst.components.unevenground:Enable()
    local pos = inst:GetPosition()
	SpawnFx(inst, inst.scale, pos)
    inst.components.timer:StartTimer("repair", time or 30)
    inst.persists = false
    inst.Despawn = function()
        inst.components.timer:SetTimeLeft("repair", 0)
        if inst.owner and inst.owner:IsValid() and inst.owner.wangfxs then
            inst.owner.wangfxs[inst] = nil
        end
    end
    inst:ListenForEvent("onremove",function()
        if inst.owner and inst.owner:IsValid() and inst.owner.wangfxs then
            inst.owner.wangfxs[inst] = nil
        end
    end)
end
local function DoFgCollapse(inst,time)
    inst.components.unevenground:Disable()
    local pos = inst:GetPosition()
	SpawnFx(inst, inst.scale, pos)
    inst.components.timer:StartTimer("repair", time or 30)
    inst.persists = false
end
local function OnLoad(inst)
	if inst.components.timer:TimerExists("repair") then
        inst.components.unevenground:Enable()
    end
end
local function OnLoadPostPass(inst)
	if inst.persists and not inst.components.timer:TimerExists("repair") then
		inst:Remove()
	end
end
local function MakeSinkhole(name, radius, scale, maxwork, toughworker)
	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()
		inst.AnimState:SetBank(Boss.Art("sinkhole"))
		inst.AnimState:SetBuild(Boss.Art("antlion_sinkhole"))
		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
		inst.AnimState:SetLayer(LAYER_BACKGROUND)
		inst.AnimState:SetSortOrder(2)
		inst.AnimState:SetScale(scale, scale)
		inst.Transform:SetEightFaced()
		inst:AddTag("antlion_sinkhole")
		inst:AddTag("antlion_sinkhole_blocker")
		inst:AddTag("NOCLICK")
		if toughworker then
			inst:AddTag("toughworker")
		end
		inst:SetDeployExtraSpacing(4)
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end
		inst.radius = radius
		inst.scale = scale
		inst.maxwork = maxwork
        inst.DoCollapse =  DoCollapse
        inst.DoFXCollapse = DoFXCollapse
        inst.DoFgCollapse = DoFgCollapse
		inst:AddComponent("timer")
		inst:AddComponent("unevenground")
		inst.components.unevenground.radius = radius
		inst:ListenForEvent("docollapse", DoCollapse)
		inst:ListenForEvent("timerdone", OnTimerDone)
		inst.OnLoad = OnLoad
		inst.OnLoadPostPass = OnLoadPostPass
		return inst
	end
	return Prefab(name, fn, assets, prefabs)
end
return MakeSinkhole("ttk_boss_daywalker_sinkhole", TUNING.DAYWALKER_SLAM_SINKHOLERADIUS, 1, true, true)
