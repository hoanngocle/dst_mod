-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
local assets = {
	Asset("ANIM", Boss.ArtPath("anim/rock_basalt.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_baihu_rock.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_futu_rock.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_yunxiao_jjj_rock.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_spiderqueen_rock.zip")),
}
local function onworked(inst, worker, workleft)
    if workleft <= 0 then
        local pos = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pos:Get())
        inst.components.lootdropper:DropLoot(pos)
        inst:Remove()
    else
        inst.AnimState:PlayAnimation(
            (workleft < TUNING.MARBLEPILLAR_MINE / 3 and "low") or
            (workleft < TUNING.MARBLEPILLAR_MINE * 2 / 3 and "med") or
            "full"
        )
    end
end
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	MakeObstaclePhysics(inst, 1)
	inst.AnimState:SetBank(Boss.Art("rock_basalt"))
	inst.AnimState:SetBuild(Boss.Art("rock_basalt"))
	inst.AnimState:PlayAnimation("full")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.workable:SetOnWorkCallback(onworked)
    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)
	inst:AddComponent("inspectable")
    MakeHauntableWork(inst)
    MakeSnowCovered(inst)
    inst.persists = false
	return inst
end
local function fn1(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	MakeObstaclePhysics(inst, 1)
	inst.AnimState:SetBank(Boss.Art("rock_basalt"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihu_rock"))
	inst.AnimState:PlayAnimation("full")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst:AddComponent("lootdropper")
    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)
    MakeHauntable(inst)
    MakeSnowCovered(inst)
    inst.persists = false
	return inst
end
local function fn2(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	MakeObstaclePhysics(inst, 1.2)
    local size = 1.2
    inst.AnimState:SetScale(size, size, size)
	inst.AnimState:SetBank(Boss.Art("rock_basalt"))
	inst.AnimState:SetBuild(Boss.Art("xd_spiderqueen_rock"))
	inst.AnimState:PlayAnimation("full")
    MakeSnowCoveredPristine(inst)
    inst:AddTag("ttk_boss_spiderqueen_rock")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)
    MakeHauntable(inst)
    MakeSnowCovered(inst)
    inst:DoTaskInTime(10,function()
        local pos = inst:GetPosition()
        SpawnAt("rock_break_fx",pos)
        local fx11 = SpawnAt("collapse_small",pos)
        fx11:SetMaterial("none")
        if inst.owner and inst.owner:IsValid() then
            inst.owner:DoAoeDamage(3,75,nil,nil,pos)
        end
        SpawnAt("groundpoundring_fx",pos)
        local points = XD_GetGroundPoints(pos)
        local map = TheWorld.Map
        for i, v1 in ipairs(points) do
            for i,v in ipairs(v1) do
                if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                    SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
                end
            end
        end
        inst:Remove()
    end)
    inst.persists = false
	return inst
end
local function fn3()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	MakeObstaclePhysics(inst, 1)
	inst.AnimState:SetBank(Boss.Art("rock_basalt"))
	inst.AnimState:SetBuild(Boss.Art("xd_futu_rock"))
    inst.AnimState:PlayAnimation("emerge")
    inst.AnimState:PushAnimation("full")
    MakeSnowCoveredPristine(inst)
    inst:AddTag("ttk_boss_futu_rock")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)
    MakeSnowCovered(inst)
    MakeHauntable(inst)
    inst:DoTaskInTime(31,function()
        local pos = inst:GetPosition()
        SpawnAt("rock_break_fx",pos)
        local fx11 = SpawnAt("collapse_small",pos)
        fx11:SetMaterial("stone")
        SpawnAt("groundpoundring_fx",pos)
        local points = XD_GetGroundPoints(pos)
        local map = TheWorld.Map
        for i, v1 in ipairs(points) do
            for i,v in ipairs(v1) do
                if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                    SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
                end
            end
        end
        if inst.damagefn then
            inst.damagefn(pos)
        end
        inst:Remove()
    end)
    inst.persists = false
	return inst
end
local function dofx(inst,count)
    local pos = inst:GetPosition()
    SpawnAt("groundpoundring_fx",pos)
    local points = XD_GetGroundPoints(pos)
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end
    if count and count >= 30 then
        SpawnAt("rock_break_fx",pos)
        local fx11 = SpawnAt("collapse_small",pos)
        fx11:SetMaterial("stone")
        inst:Remove()
    end
end
local function fn4()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.AnimState:SetBank(Boss.Art("rock_basalt"))
	inst.AnimState:SetBuild(Boss.Art("xd_yunxiao_jjj_rock"))
    inst.AnimState:PlayAnimation("emerge")
    inst.AnimState:PushAnimation("full")
    MakeSnowCoveredPristine(inst)
    inst:AddTag("ttk_boss_yunxiao_jjj_rock")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    local color = 0.5 + math.random() * 0.5
    anim:SetMultColour(color, color, color, 1)
    MakeSnowCovered(inst)
    MakeHauntable(inst)
    inst.DoFx = dofx
    inst:DoTaskInTime(31,function()
        inst:Remove()
    end)
    inst.persists = false
	return inst
end
return Prefab("ttk_boss_rock_basalt", fn,assets),
    Prefab("ttk_boss_baihu_rock", fn1,assets),
    Prefab("ttk_boss_spiderqueen_rock", fn2,assets),
    Prefab("ttk_boss_futu_rock", fn3,assets),
    Prefab("ttk_boss_yunxiao_jjj_rock", fn4,assets)
