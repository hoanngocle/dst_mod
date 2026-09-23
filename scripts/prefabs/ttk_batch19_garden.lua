-- Selected standalone garden structures from Tu Tien 19.7.
local function Hammered(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("stone")
    end
    inst:Remove()
end

local function ButterflyDay(inst, isday)
    if not isday or TheWorld.state.iswinter or math.random() >= .4 then
        return
    end
    local butterfly = SpawnPrefab("butterfly")
    if butterfly ~= nil then
        if butterfly.components.pollinator ~= nil then
            butterfly.components.pollinator:Pollinate(inst)
        end
        if butterfly.components.homeseeker ~= nil then
            butterfly.components.homeseeker:SetHome(inst)
        end
        butterfly.Physics:Teleport(inst.Transform:GetWorldPosition())
    end
end

local function TreeSpawn(self)
    local product = self.inst._ttk_tree_product
    local amount = self.inst._ttk_tree_amount or 1
    if product == nil then
        return false
    end
    for _ = 1, amount do
        self.inst.components.lootdropper:SpawnLootPrefab(product)
    end
    return true
end

local function MakeDecoration(name, bank, build, animfile, kind, product, amount)
    local assets = {
        Asset("ANIM", "anim/" .. animfile .. ".zip"),
        Asset("ATLAS", "images/inventoryimages/" .. name .. ".xml"),
        Asset("IMAGE", "images/inventoryimages/" .. name .. ".tex"),
        Asset("ATLAS", "images/map_icons/" .. name .. ".xml"),
        Asset("IMAGE", "images/map_icons/" .. name .. ".tex"),
    }
    local function Fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle", true)
        inst.MiniMapEntity:SetIcon(name .. ".tex")
        if kind == "tree" then
            MakeObstaclePhysics(inst, .5)
            inst:AddTag("tree")
            inst:AddTag("shelter")
            inst.MiniMapEntity:SetPriority(-1)
            inst:AddComponent("temperatureoverrider")
        elseif kind == "well" then
            MakeObstaclePhysics(inst, .8)
            inst:AddTag("watersource")
        else
            inst:AddTag("flower")
        end
        inst:AddTag("structure")
        MakeSnowCoveredPristine(inst)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(Hammered)
        if kind == "tree" then
            inst._ttk_tree_product = product
            inst._ttk_tree_amount = amount
            inst.components.temperatureoverrider:SetRadius(6)
            inst.components.temperatureoverrider:SetTemperature(19)
            inst.components.temperatureoverrider:Enable()
            inst:AddComponent("periodicspawner")
            inst.components.periodicspawner:SetPrefab(product)
            inst.components.periodicspawner:SetRandomTimes(7 * 480, 100)
            inst.components.periodicspawner:SetDensityInRange(4, 40)
            inst.components.periodicspawner:SetMinimumSpacing(8)
            inst.components.periodicspawner.TrySpawn = TreeSpawn
            inst.components.periodicspawner:Start()
        elseif kind == "well" then
            inst:AddComponent("watersource")
        else
            inst:AddComponent("sanityaura")
            inst.components.sanityaura.aura = 2 * TUNING.SANITYAURA_TINY
            if not TheWorld:HasTag("cave") then
                inst:WatchWorldState("isday", ButterflyDay)
            end
        end
        MakeSnowCovered(inst)
        MakeHauntable(inst)
        return inst
    end
    local dependencies = { "collapse_small", "butterfly" }
    if product ~= nil then table.insert(dependencies, product) end
    return Prefab(name, Fn, assets, dependencies),
        MakePlacer(name .. "_placer", bank, build, "idle")
end

local prefabs = {}
local function Add(...)
    for _, prefab in ipairs({...}) do
        table.insert(prefabs, prefab)
    end
end
Add(MakeDecoration("ttk_tree_yls", "xd_tree_yls", "xd_trees", "ttk_trees", "tree", "greengem", 1))
for _, suffix in ipairs({"sfr", "zyh", "yl"}) do
    Add(MakeDecoration("ttk_flower_" .. suffix, "xd_flower_" .. suffix, "xd_flowers", "ttk_flowers", "flower"))
end
return unpack(prefabs)
