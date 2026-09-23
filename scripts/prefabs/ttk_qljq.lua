local FUEL_TIME = 7 * 480
local assets = {
    Asset("ANIM", "anim/ttk_qljq.zip"),
    Asset("ANIM", "anim/ttk_ui_1x1.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_qljq.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_qljq.tex"),
}

local function UpdateLight(inst)
    local enabled = TheWorld.state.isnight and not inst.components.container:IsEmpty()
    inst.Light:Enable(enabled)
    local timer = inst.components.timer
    if not timer:TimerExists("cost") then
        timer:StartTimer("cost", FUEL_TIME, not enabled)
    elseif enabled then
        timer:ResumeTimer("cost")
    else
        timer:PauseTimer("cost")
    end
end

local function FuelChanged(inst)
    -- Container events can arrive before the slot finishes changing.
    if inst._fuelupdate ~= nil then inst._fuelupdate:Cancel() end
    inst._fuelupdate = inst:DoTaskInTime(0, function()
        inst._fuelupdate = nil
        UpdateLight(inst)
    end)
end

local function TimerDone(inst, data)
    if data.name == "cost" then
        inst.components.container:ConsumeByName("ttk_lingshi1", 1)
        UpdateLight(inst)
    end
end

local function Hammered(inst)
    inst.components.container:DropEverything()
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    end
    inst:Remove()
end

local function Fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("xd_qljq")
    inst.AnimState:SetBuild("xd_qljq")
    inst.AnimState:PlayAnimation("idle", true)
    inst.MiniMapEntity:SetIcon("ttk_qljq.tex")
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(6)
    inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)
    inst.Light:Enable(false)
    inst:AddTag("structure")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_qljq")
    inst:AddComponent("timer")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(Hammered)
    inst:WatchWorldState("isnight", UpdateLight)
    inst:ListenForEvent("itemget", FuelChanged)
    inst:ListenForEvent("itemlose", FuelChanged)
    inst:ListenForEvent("timerdone", TimerDone)
    inst.OnLoadPostPass = FuelChanged
    FuelChanged(inst)
    MakeSnowCovered(inst)
    MakeHauntable(inst)
    return inst
end

return Prefab("ttk_qljq", Fn, assets, {"ttk_lingshi1", "collapse_small"}),
    MakePlacer("ttk_qljq_placer", "xd_qljq", "xd_qljq", "idle")
