local assets = {
    Asset("ANIM", "anim/ttk_lbx.zip"),
    Asset("ANIM", "anim/ttk_ui_4x5.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_lbx.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_lbx.tex"),
}

local prefabs = {"collapse_small", "ttk_hyf_fullfx", "ttk_hyf_frontfx"}
local SPAWN_TIME = 15 * TUNING.TOTAL_DAY_TIME
local count = 0

local function SetCount(delta)
    count = math.max(0, count + delta)
    if TheWorld ~= nil and TheWorld.net ~= nil and TheWorld.net.ttk_lbx_count ~= nil then
        TheWorld.net.ttk_lbx_count:set(math.min(count, 6))
    end
end

local function RegisterCount(inst)
    if not inst._ttk_lbx_counted then
        inst._ttk_lbx_counted = true
        SetCount(1)
    end
end

local function UnregisterCount(inst)
    if inst._ttk_lbx_counted then
        inst._ttk_lbx_counted = false
        SetCount(-1)
    end
end

local function SpawnLunarFx(inst)
    for _, name in ipairs({"ttk_hyf_fullfx", "ttk_hyf_frontfx"}) do
        local fx = SpawnPrefab(name)
        if fx ~= nil then
            fx.entity:SetParent(inst.entity)
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(inst.GUID, "png", 0, 0, 0)
        end
    end
end

local function CloneStoredItem(inst)
    local container = inst.components.container
    local items = container ~= nil and container:GetAllItems() or nil
    local item_count = items ~= nil and #items or 0
    if container == nil or item_count < 12 or item_count >= container.numslots then
        return
    end

    local source = items[math.random(item_count)]
    local record = source ~= nil and source:GetSaveRecord() or nil
    local clone = record ~= nil and SpawnSaveRecord(record) or nil
    if clone == nil then
        return
    end
    if clone.components.stackable ~= nil and clone.components.stackable:StackSize() > 20 then
        clone.components.stackable:SetStackSize(20)
    end
    if not container:GiveItem(clone) then
        clone.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    SpawnLunarFx(inst)
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "spawnitem" then
        CloneStoredItem(inst)
        inst.components.timer:StartTimer("spawnitem", SPAWN_TIME)
    end
end

local function OnOpen(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open") end
local function OnClose(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close") end

local function OnHammered(inst)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    end
    inst:Remove()
end

local function OnHit(inst)
    inst.components.container:DropEverything()
    inst.components.container:Close()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("xd_lbx")
    inst.AnimState:SetBuild("xd_lbx")
    inst.AnimState:PlayAnimation("idle")
    inst.MiniMapEntity:SetIcon("ttk_lbx.tex")
    MakeSnowCoveredPristine(inst)
    inst:AddTag("structure")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_lbx")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("spawnitem", SPAWN_TIME)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("onremove", UnregisterCount)
    RegisterCount(inst)
    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    return inst
end

return Prefab("ttk_lbx", fn, assets, prefabs),
    MakePlacer("ttk_lbx_placer", "xd_lbx", "xd_lbx", "idle")
