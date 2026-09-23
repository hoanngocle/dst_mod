require "prefabutil"

local assets = {
    Asset("ANIM", "anim/ttk_luoshen_hua.zip"),
    Asset("ANIM", "anim/ttk_luoshen_huazhong.zip"),
    Asset("ANIM", "anim/ttk_luoshen_huayin.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_luoshen_huazhong.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_luoshen_huazhong.tex"),
    Asset("ATLAS", "images/inventoryimages/ttk_luoshen_huayin.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_luoshen_huayin.tex"),
    Asset("ATLAS", "images/map_icons/ttk_luoshen_hua.xml"),
    Asset("IMAGE", "images/map_icons/ttk_luoshen_hua.tex"),
}

local stages = {
    [1] = {idle = "crop_seed", grow = "grow_seed"},
    [2] = {idle = "crop_sprout", grow = "grow_sprout"},
    [3] = {idle = "crop_small", grow = "grow_small"},
    [4] = {idle = "crop_med", grow = "grow_med"},
    [5] = {idle = "crop_full", grow = "grow_full"},
}

local function Stage(inst)
    return math.max(1, math.min(5, inst._stage_net:value()))
end

local function PlayStage(inst, growing)
    local data = stages[Stage(inst)]
    if growing then
        inst.AnimState:PlayAnimation(data.grow)
        inst.AnimState:PushAnimation(data.idle, true)
    else
        inst.AnimState:PlayAnimation(data.idle, true)
    end
end

local function Refresh(inst, growing)
    local stage = Stage(inst)
    PlayStage(inst, growing)
    if not TheWorld.ismastersim then return end

    if stage >= 3 then
        inst.components.temperatureoverrider:Enable()
        inst.components.sanityaura.aura = 2 * TUNING.SANITYAURA_TINY
    else
        inst.components.temperatureoverrider:Disable()
        inst.components.sanityaura.aura = 0
    end
    if stage >= 5 then
        inst:RemoveTag("xd_ztpuseable")
        inst:RemoveTag("ttk_luoshen_growing")
        inst.MiniMapEntity:SetEnabled(true)
    else
        inst:AddTag("xd_ztpuseable")
        inst:AddTag("ttk_luoshen_growing")
        inst.components.pickable:Pause()
        inst.components.pickable:MakeEmpty()
        inst.MiniMapEntity:SetEnabled(false)
        inst.components.container:Close()
    end
end

local function TryGrowth(target, maximize)
    if target == nil or not target:IsValid() or target:IsInLimbo()
        or (target.components.witherable ~= nil and target.components.witherable:IsWithered()) then
        return
    end
    if maximize and target.components.farmplantstress ~= nil then
        if target.components.farmplanttendable ~= nil then target.components.farmplanttendable:TendTo() end
        target.magic_tending = true
        local x, y, z = target.Transform:GetWorldPosition()
        local tx, tz = TheWorld.Map:GetTileCoordsAtPoint(x, y, z)
        local nutrients = target.plant_def ~= nil and target.plant_def.nutrient_consumption or nil
        if nutrients ~= nil and TheWorld.components.farming_manager ~= nil then
            TheWorld.components.farming_manager:AddTileNutrients(tx, tz,
                nutrients[1] * 6, nutrients[2] * 6, nutrients[3] * 6)
        end
    end
    if target.components.simplemagicgrower ~= nil then
        target.components.simplemagicgrower:StartGrowing()
    elseif target.components.growable ~= nil then
        if target.components.growable.domagicgrowthfn ~= nil then
            target.components.growable:DoMagicGrowth()
        else
            target.components.growable:DoGrowth()
        end
    elseif target.components.pickable ~= nil and not target.components.pickable:CanBePicked() then
        target.components.pickable:FinishGrowing()
    elseif target.components.crop ~= nil and (target.components.crop.rate or 0) > 0 then
        target.components.crop:DoGrow(1 / target.components.crop.rate, true)
    end
end

local function TendSoil(inst)
    local manager = TheWorld.components.farming_manager
    if manager == nil then return end
    local x, _, z = inst.Transform:GetWorldPosition()
    for ox = -12, 12, 4 do
        for oz = -12, 12, 4 do
            local wx, wz = x + ox, z + oz
            if TheWorld.Map:GetTileAtPoint(wx, 0, wz) == GROUND.FARMING_SOIL then
                manager:AddSoilMoistureAtPoint(wx, 0, wz, 100)
                local tx, tz = TheWorld.Map:GetTileCoordsAtPoint(wx, 0, wz)
                manager:AddTileNutrients(tx, tz, 100, 100, 100)
            end
        end
    end
end

local function GrowNearby(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local seen = {}
    for _, target in ipairs(TheSim:FindEntities(x, y, z, 12, nil,
        {"magicgrowth", "player", "FX", "stump", "withered", "barren", "INLIMBO"},
        {"plant", "lichen", "oceanvine", "mushroom_farm", "kelp", "tree", "winter_tree"})) do
        if not seen[target] then
            seen[target] = true
            TryGrowth(target, target.components.farmplantstress ~= nil)
        end
    end
end

local function OnCycle(inst)
    local stage = Stage(inst)
    if stage >= 5 and not inst.components.pickable:CanBePicked() then
        inst.components.pickable:Regen()
        inst.components.pickable:Pause()
    end
    if stage < 4 then return end
    inst._soil_cycles = (inst._soil_cycles or 0) - 1
    inst._growth_cycles = (inst._growth_cycles or 0) - 1
    if inst._soil_cycles <= 0 then TendSoil(inst); inst._soil_cycles = 2 end
    if inst._growth_cycles <= 0 then GrowNearby(inst); inst._growth_cycles = 7 end
end

local function OnPicked(inst)
    inst.components.pickable:Pause()
end

local function OnDug(inst)
    if inst.components.container ~= nil then inst.components.container:DropEverything() end
    for _ = 1, 10 do inst.components.lootdropper:SpawnLootPrefab("twigs") end
    for _ = 1, 8 do inst.components.lootdropper:SpawnLootPrefab("petals") end
    inst:Remove()
end

local function OnSave(inst, data)
    data.stage = Stage(inst)
    data.userid = inst._userid
    data.soil_cycles = inst._soil_cycles
    data.growth_cycles = inst._growth_cycles
end

local function OnLoad(inst, data)
    if data ~= nil then
        inst._stage_net:set(math.max(1, math.min(5, tonumber(data.stage) or 1)))
        inst._userid = data.userid
        inst._soil_cycles = tonumber(data.soil_cycles) or 0
        inst._growth_cycles = tonumber(data.growth_cycles) or 0
    end
    Refresh(inst, false)
end

local function FlowerFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .35)
    inst.AnimState:SetBank("farm_plant_pumpkin")
    inst.AnimState:SetBuild("xd_luoshen_hua")
    inst.AnimState:PlayAnimation(stages[1].idle, true)
    inst.MiniMapEntity:SetIcon("ttk_luoshen_hua.tex")
    inst.MiniMapEntity:SetEnabled(false)
    inst.Transform:SetScale(1.3, 1.3, 1.3)
    inst:AddTag("structure")
    inst:AddTag("flower")
    inst:AddTag("ttk_luoshen_growing")
    inst:AddTag("xd_ztpuseable")
    inst:AddTag("nonpackable")
    inst._stage_net = net_tinybyte(inst.GUID, "ttk_luoshen_hua.stage", "ttk_luoshen_stage_dirty")
    inst:AddComponent("temperatureoverrider")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("ttk_luoshen_stage_dirty", function() Refresh(inst, true) end)
        return inst
    end

    inst._stage_net:set(1)
    inst._soil_cycles = 0
    inst._growth_cycles = 0
    inst:AddComponent("inspectable")
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = 0
    inst.components.temperatureoverrider:SetRadius(15)
    inst.components.temperatureoverrider:SetTemperature(25)
    inst.components.temperatureoverrider:Disable()
    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("ttk_luoshen_huayin", TUNING.TOTAL_DAY_TIME)
    inst.components.pickable.onpickedfn = OnPicked
    inst.components.pickable:Pause()
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_luoshen_hua")
    inst.components.container.canbeopenedfn = function() return Stage(inst) >= 5 end
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnDug)
    inst.Nurture = function(self, doer)
        local stage = Stage(self)
        if stage >= 5 then return false end
        self._userid = self._userid or (doer ~= nil and doer.userid or nil)
        self._stage_net:set(stage + 1)
        Refresh(self, true)
        if stage + 1 >= 5 then self.components.pickable:Regen(); self.components.pickable:Pause() end
        return true
    end
    inst.OnSave = OnSave
    inst.use_ztp = function(self, bottle, doer) return self:Nurture(doer) end
    inst.OnLoad = OnLoad
    inst:WatchWorldState("cycles", OnCycle)
    Refresh(inst, false)
    MakeHauntableWork(inst)
    return inst
end

local function DeploySeed(inst, point, deployer)
    local flower = SpawnPrefab("ttk_luoshen_hua")
    if flower == nil then return end
    flower.Transform:SetPosition(point:Get())
    flower._userid = deployer ~= nil and deployer.userid or nil
    local item = inst.components.stackable ~= nil and inst.components.stackable:Get() or inst
    item:Remove()
    if deployer ~= nil and deployer.SoundEmitter ~= nil then
        deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
    end
end

local function SeedFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst.AnimState:SetBank("xd_luoshen_huazhong")
    inst.AnimState:SetBuild("xd_luoshen_huazhong")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_luoshen_huazhong.xml"
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = DeploySeed
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    MakeHauntableLaunch(inst)
    return inst
end

local function EssenceFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst.AnimState:SetBank("xd_luoshen_huayin")
    inst.AnimState:SetBuild("xd_luoshen_huayin")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("cattoy")
    inst:AddTag("vasedecoration")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ttk_luoshen_huayin.xml"
    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.healthvalue = 10
    inst.components.edible.hungervalue = 5
    inst.components.edible.sanityvalue = 10
    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("vasedecoration")
    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndPerish(inst)
    return inst
end

return Prefab("ttk_luoshen_huazhong", SeedFn, assets, {"ttk_luoshen_hua"}),
    Prefab("ttk_luoshen_hua", FlowerFn, assets, {"ttk_luoshen_huayin"}),
    Prefab("ttk_luoshen_huayin", EssenceFn, assets, {"spoiled_food"}),
    MakePlacer("ttk_luoshen_huazhong_placer", "farm_plant_pumpkin", "xd_luoshen_hua", "crop_seed")
