-- A persistent pot tracks its crop, so harvest never has to respawn the pot.
local assets = {
    Asset("ANIM", "anim/ttk_huapen.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_huapen.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_huapen.tex"),
}

local function UpdateState(inst)
    local empty = inst.components.finiteuses:GetUses() <= 0
    inst.AnimState:PlayAnimation(empty and "idle1" or "idle")
    if empty then inst:AddTag("ttk_huapen_empty") else inst:RemoveTag("ttk_huapen_empty") end
    local plant = inst._plant
    if plant ~= nil and plant:IsValid() then
        inst:RemoveTag("soil")
        inst.components.workable:SetWorkable(false)
        if empty then plant:AddTag("ttk_huapen_empty") else plant:RemoveTag("ttk_huapen_empty") end
    else
        inst:AddTag("soil")
        inst.components.workable:SetWorkable(true)
    end
end

local function DetachPlant(inst)
    local plant = inst._plant
    if plant ~= nil and plant:IsValid() then
        if inst._onplantremoved ~= nil then
            inst:RemoveEventCallback("onremove", inst._onplantremoved, plant)
        end
        plant._ttk_pot = nil
        plant:RemoveTag("ttk_pottedplant")
        plant:RemoveTag("ttk_huapen_empty")
    end
    inst.components.entitytracker:ForgetEntity("crop")
    inst._plant = nil
    inst._onplantremoved = nil
end

local SetPlant
SetPlant = function(inst, plant)
    DetachPlant(inst)
    if plant ~= nil and plant:IsValid() then
        inst._plant = plant
        plant._ttk_pot = inst
        plant:AddTag("ttk_pottedplant")
        local x, _, z = inst.Transform:GetWorldPosition()
        plant.Transform:SetPosition(x, 1.1, z)
        inst.components.entitytracker:TrackEntity("crop", plant)
        inst._onplantremoved = function()
            local replacement = plant.grew_into
            -- Wait until entitytracker's removal listener has run before reusing its key.
            inst:DoTaskInTime(0, function()
                if inst._plant ~= plant then return end
                DetachPlant(inst)
                if replacement ~= nil and replacement:IsValid() then
                    SetPlant(inst, replacement)
                else
                    inst.components.finiteuses:Use(1)
                    UpdateState(inst)
                end
            end)
        end
        inst:ListenForEvent("onremove", inst._onplantremoved, plant)
    end
    UpdateState(inst)
end

local function PlantSeed(inst, plantable, planter)
    if inst._plant ~= nil or not inst:HasTag("soil") or plantable.plant == nil then
        return false
    end
    local prefab = FunctionOrValue(plantable.plant, plantable.inst)
    local plant = prefab ~= nil and SpawnPrefab(prefab) or nil
    if plant == nil then return false end
    SetPlant(inst, plant)
    plant:PushEvent("on_planted", { doer = planter, seed = plantable.inst, in_soil = true })
    if plant.SoundEmitter ~= nil then
        plant.SoundEmitter:PlaySound("dontstarve/common/plant")
    end
    TheWorld:PushEvent("itemplanted", { doer = planter, pos = inst:GetPosition() })
    plantable.inst:Remove()
    return true
end

local function Hammered(inst)
    if inst._plant ~= nil then return end
    inst.components.lootdropper:SpawnLootPrefab("cutstone")
    inst.components.lootdropper:SpawnLootPrefab("ttk_lingshi1")
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) end
    inst:Remove()
end

local function OnRemove(inst)
    local plant = inst._plant
    DetachPlant(inst)
    if plant ~= nil and plant:IsValid() then
        local x, _, z = plant.Transform:GetWorldPosition()
        plant.Transform:SetPosition(x, 0, z)
    end
end

local function Fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("xd_huapen")
    inst.AnimState:SetBuild("xd_huapen")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(-1)
    inst:AddTag("soil")
    inst:AddTag("ttk_huapen")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(Hammered)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(2)
    inst.components.finiteuses:SetUses(2)
    inst:AddComponent("entitytracker")
    inst:ListenForEvent("percentusedchange", UpdateState)
    inst.PlantSeed = PlantSeed
    inst.Refill = function()
        inst.components.finiteuses:SetUses(2)
        UpdateState(inst)
    end
    inst.OnLoadPostPass = function()
        SetPlant(inst, inst.components.entitytracker:GetEntity("crop"))
    end
    inst.OnRemoveEntity = OnRemove
    MakeHauntable(inst)
    return inst
end

return Prefab("ttk_huapen", Fn, assets, { "cutstone", "ttk_lingshi1", "collapse_small" }),
    MakePlacer("ttk_huapen_placer", "xd_huapen", "xd_huapen", "idle")
