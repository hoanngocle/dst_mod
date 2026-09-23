local assets = {}
local prefabs = { "collapse_small" }

local function FindRewardChest(inst, player)
    local x, y, z = inst.Transform:GetWorldPosition()
    for _, chest in ipairs(TheSim:FindEntities(x, y, z, 32, { "ttk_llbx" })) do
        if chest:IsValid() and (chest.CanUse == nil or chest:CanUse(player)) then return chest end
    end
end

local function OnHammered(inst, worker)
    if inst.components.ttk_jitan_trial.state ~= "idle" then
        inst.components.workable:SetWorkLeft(3)
        if worker ~= nil and worker.components.talker ~= nil then
            worker.components.talker:Say("Không thể tháo Tế Đàn khi thử luyện đang diễn ra.")
        end
        return
    end
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) end
    inst:Remove()
end

local function OnSave(inst, data)
    data.ttk_jitan_trial = inst.components.ttk_jitan_trial:OnSave()
end

local function OnLoad(inst, data)
    inst.components.ttk_jitan_trial:OnLoad(data ~= nil and data.ttk_jitan_trial or nil)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.7)
    inst.AnimState:SetBank("xd_jitan")
    inst.AnimState:SetBuild("xd_jitan")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_jitan.tex")
    inst:AddTag("structure")
    inst:AddTag("ttk_jitan")
    inst:AddTag("trader")
    inst._ttk_trial_state = net_tinybyte(inst.GUID, "ttk_jitan.state", "ttk_jitan_statedirty")
    inst._ttk_trial_run = net_uint(inst.GUID, "ttk_jitan.run", "ttk_jitan_rundirty")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst.FindRewardChest = FindRewardChest
    inst:AddComponent("inspectable")
    inst:AddComponent("ttk_jitan_trial")
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(function(_, item, giver, count)
        return inst.components.ttk_jitan_trial:CanAcceptTrade(giver, item, count)
    end)
    inst.components.trader:SetOnAccept(function(_, giver, item, count)
        inst.components.ttk_jitan_trial:OnOfferingAccepted(giver, item, count)
    end)
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    MakeSnowCovered(inst)
    MakeHauntableWork(inst)
    return inst
end

return Prefab("ttk_jitan", fn, assets, prefabs),
    MakePlacer("ttk_jitan_placer", "xd_jitan", "xd_jitan", "idle")

