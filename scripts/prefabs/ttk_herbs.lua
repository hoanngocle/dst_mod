local SEED_FOODS = require("ttk_seed_fooddefs")

local HERBS = {
    hsc = {bank = "farm_plant_asparagus", season = "winter", perish = 10, hunger = 8, sanity = -30, health = 10, temperature = -10, freeze_pick = true},
    dms = {bank = "farm_plant_carrot", phase = "day", no_rain = true, perish = 30, hunger = 12.5, sanity = -5, health = 10, regen = true, groggy_pick = true},
    qfx = {bank = "farm_plant_garlic", season = "autumn", perish = .5, hunger = 0, sanity = -2, health = 0},
    cyh = {bank = "farm_plant_pepper", season = "summer", perish = 10, hunger = 12.5, sanity = 0, health = 20, temperature = 15, burn_pick = true},
    lmg = {bank = "farm_plant_pumpkin", season = "spring", perish = 10, hunger = 12.5, sanity = -45, health = 20, temperature = -10, lightning = true},
    yhh = {bank = "farm_plant_tomato", phase = "night", perish = 10, hunger = 0, sanity = -60, health = 5, sanity_pick = -100},
}

local assets = {Asset("ANIM", "anim/ttk_lingcao.zip")}
for suffix in pairs(HERBS) do
    table.insert(assets, Asset("ANIM", "anim/ttk_plant_" .. suffix .. ".zip"))
    for _, postfix in ipairs({"", "_seed"}) do
        local name = "ttk_lc_" .. suffix .. postfix
        table.insert(assets, Asset("ATLAS", "images/inventoryimages/" .. name .. ".xml"))
        table.insert(assets, Asset("IMAGE", "images/inventoryimages/" .. name .. ".tex"))
    end
end

local output = {}

local function MakeItem(suffix, data, is_seed)
    local name = "ttk_lc_" .. suffix .. (is_seed and "_seed" or "")
    local item_prefabs = {"spoiled_food"}
    if not is_seed and data.regen then table.insert(item_prefabs, "ttk_dms_healthregenbuff") end
    if not is_seed and data.lightning then table.insert(item_prefabs, "lightning") end
    local function OnEat(inst, eater)
        if eater == nil then return end
        if data.regen and eater.AddDebuff ~= nil then
            eater:AddDebuff("ttk_dms_healthregenbuff", "ttk_dms_healthregenbuff")
        end
        if data.lightning then
            local lightning = SpawnPrefab("lightning")
            if lightning ~= nil then lightning.Transform:SetPosition(eater.Transform:GetWorldPosition()) end
        end
    end
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        inst.AnimState:SetBank("xd_lingcao")
        inst.AnimState:SetBuild("xd_lingcao")
        inst.AnimState:PlayAnimation(suffix .. (is_seed and "_seed" or ""))
        inst:AddTag("ttk_ylxc_valid")
        if is_seed then inst:AddTag("ttk_lc_seed") end
        MakeInventoryFloatable(inst)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("edible")
        inst.components.edible.foodtype = is_seed and FOODTYPE.SEEDS or FOODTYPE.GOODIES
        local nutrition = is_seed and SEED_FOODS[suffix] or data
        inst.components.edible.healthvalue = nutrition.health
        inst.components.edible.hungervalue = nutrition.hunger
        inst.components.edible.sanityvalue = nutrition.sanity
        if not is_seed then
            inst.components.edible.temperaturedelta = data.temperature or 0
            inst.components.edible.temperatureduration = data.temperature ~= nil and 5 or 0
            inst.components.edible:SetOnEatenFn(OnEat)
        end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. name .. ".xml"
        inst.components.inventoryitem.imagename = name
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
        inst:AddComponent("tradable")
        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime((is_seed and 20 or data.perish) * TUNING.TOTAL_DAY_TIME)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"
        if is_seed then inst.ttk_lc_plant = "ttk_plant_" .. suffix end
        MakeHauntableLaunchAndPerish(inst)
        return inst
    end
    return Prefab(name, fn, assets, item_prefabs)
end

local growth_stages = {
    {name = "seed", time = 720, anim = "seed", inspect_str = "SEED"},
    {name = "sprout", time = 720, anim = "sprout", inspect_str = "GROWING"},
    {name = "small", time = 720, anim = "small", inspect_str = "GROWING"},
    {name = "med", time = 720, anim = "med", inspect_str = "GROWING"},
    {name = "full", time = 10, anim = "full", inspect_str = "FULL", full = true},
}

local function MakePlant(suffix, data)
    local name = "ttk_plant_" .. suffix
    local plant_prefabs = {"ttk_lc_" .. suffix, "ttk_lc_" .. suffix .. "_seed", "dirt_puff"}
    if data.burn_pick then table.insert(plant_prefabs, "ttk_plant_cyh_buff") end
    local stages = {}

    local function OnPicked(inst, doer)
        if doer == nil or doer.components.inventory == nil then return end
        local herb = SpawnPrefab("ttk_lc_" .. suffix)
        if herb ~= nil then doer.components.inventory:GiveItem(herb, nil, inst:GetPosition()) end
        local has_source_basket = require("ttk_herbtool")(doer)
        local chance = has_source_basket and .75 or .4
        if math.random() < chance then
            local seed_count = has_source_basket and math.random() < .25 and 2 or 1
            for _ = 1, seed_count do
                local seed = SpawnPrefab("ttk_lc_" .. suffix .. "_seed")
                if seed ~= nil then doer.components.inventory:GiveItem(seed, nil, inst:GetPosition()) end
            end
        end
        if has_source_basket then return end
        if data.freeze_pick and doer.components.freezable ~= nil then
            doer.components.freezable:AddColdness(doer.components.freezable.resistance or 1)
            doer.components.freezable:SpawnShatterFX()
        elseif data.burn_pick and doer.AddDebuff ~= nil then
            doer:AddDebuff("ttk_plant_cyh_buff", "ttk_plant_cyh_buff")
        elseif data.lightning and doer.components.health ~= nil
            and not doer.components.health:IsDead() and not doer.components.health:IsInvincible() then
            if doer.components.inventory == nil or not doer.components.inventory:IsInsulated() then
                doer.components.health:DoDelta(-100, false, "lightning")
                doer:PushEventImmediate("electrocute")
            else
                doer:PushEvent("lightningdamageavoided")
            end
        elseif data.groggy_pick and doer.components.grogginess ~= nil then
            doer.components.grogginess:AddGrogginess(3, 10)
        elseif data.sanity_pick ~= nil and doer.components.sanity ~= nil then
            doer.components.sanity:DoDelta(data.sanity_pick)
        end
    end

    local function SetPickable(inst, enabled)
        if not enabled then
            if inst.components.pickable ~= nil then inst:RemoveComponent("pickable") end
            return
        end
        if inst.components.pickable == nil then
            inst:AddComponent("pickable")
            inst.components.pickable.onpickedfn = OnPicked
            inst.components.pickable.remove_when_picked = true
            inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
        end
        inst.components.pickable:SetUp(nil)
    end

    for _, stage in ipairs(growth_stages) do
        local stage_data = stage
        local entry = {name = stage_data.name, time = function() return stage_data.time end,
            inspect_str = stage_data.inspect_str, dig_fx = "dirt_puff"}
        entry.fn = function(inst)
            SetPickable(inst, stage_data.full)
            local anim = stage_data.anim
            if POPULATING or inst:IsAsleep() then
                inst.AnimState:PlayAnimation("crop_" .. anim, true)
                inst.AnimState:SetTime(10 + math.random() * 2)
            else
                inst.AnimState:PlayAnimation("grow_" .. anim, false)
                inst.AnimState:PushAnimation("crop_" .. anim, true)
                local sound = stage_data.full and "farming/common/farm/grow_full" or "farming/common/farm/grow_oversized"
                inst.SoundEmitter:PlaySound(sound)
            end
        end
        table.insert(stages, entry)
    end

    local function UpdateGrowing(inst)
        local holder = inst._ttk_ylxq
        local grower = holder ~= nil and holder:IsValid() and holder.components.ttk_ylxq_grower or nil
        local allowed = grower ~= nil and grower.current > 0
        if allowed and data.season ~= nil then allowed = TheWorld.state.season == data.season end
        if allowed and data.phase ~= nil then allowed = TheWorld.state.phase == data.phase end
        if allowed and data.no_rain then allowed = not TheWorld.state.israining and not TheWorld.state.issnowing end
        if allowed then inst.components.growable:Resume() else inst.components.growable:Pause() end
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
        inst:SetDeploySmartRadius(.5)
        inst:SetPhysicsRadiusOverride(TUNING.FARM_PLANT_PHYSICS_RADIUS)
        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild("xd_plant_" .. suffix)
        inst:AddTag("ttk_plant_lc")
        MakeSnowCoveredPristine(inst)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst.ttk_primary_product = "ttk_lc_" .. suffix
        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")
        inst:AddComponent("growable")
        inst.components.growable.growoffscreen = true
        inst.components.growable.stages = stages
        inst.components.growable:SetStage(1)
        inst.components.growable.domagicgrowthfn = function() return false end
        inst.components.growable.magicgrowable = true
        inst.components.growable:StartGrowing()
        inst.components.growable:Pause()
        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
        for _, state in ipairs({"season", "phase", "israining", "issnowing"}) do
            inst:WatchWorldState(state, function() inst:DoTaskInTime(0, UpdateGrowing) end)
        end
        inst.OnCheckGrowing = function() inst:DoTaskInTime(0, UpdateGrowing) end
        inst:DoTaskInTime(0, UpdateGrowing)
        return inst
    end
    return Prefab(name, fn, assets, plant_prefabs)
end

local function MakeRegenBuff()
    local function Tick(inst, target)
        if target.components.health ~= nil and not target.components.health:IsDead()
            and not target:HasTag("playerghost") then
            target.components.health:DoDelta(.5, nil, "ttk_lc_dms")
        else
            inst.components.debuff:Stop()
        end
    end
    local function Attached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0)
        inst._task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, Tick, nil, target)
        inst:ListenForEvent("death", function() inst.components.debuff:Stop() end, target)
    end
    local function Extended(inst, target)
        inst.components.timer:StopTimer("regenover")
        inst.components.timer:StartTimer("regenover", TUNING.JELLYBEAN_DURATION)
        if inst._task ~= nil then inst._task:Cancel() end
        inst._task = inst:DoPeriodicTask(TUNING.JELLYBEAN_TICK_RATE, Tick, nil, target)
    end
    local function fn()
        local inst = CreateEntity()
        if not TheWorld.ismastersim then inst:DoTaskInTime(0, inst.Remove) return inst end
        inst.entity:AddTransform()
        inst.entity:Hide()
        inst.persists = false
        inst:AddTag("CLASSIFIED")
        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(Attached)
        inst.components.debuff:SetDetachedFn(inst.Remove)
        inst.components.debuff:SetExtendedFn(Extended)
        inst.components.debuff.keepondespawn = true
        inst:AddComponent("timer")
        inst.components.timer:StartTimer("regenover", TUNING.JELLYBEAN_DURATION)
        inst:ListenForEvent("timerdone", function(_, event)
            if event.name == "regenover" then inst.components.debuff:Stop() end
        end)
        return inst
    end
    return Prefab("ttk_dms_healthregenbuff", fn)
end

local function MakeBurnBuff()
    local function Attached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0)
        inst._task = inst:DoPeriodicTask(1, function()
            if target.components.health ~= nil and not target.components.health:IsDead() then
                target.components.health:DoFireDamage(target.components.health.maxhealth * .02, target, true)
            end
        end, 1)
        local fx = SpawnPrefab("character_fire")
        if fx ~= nil then
            target:AddChild(fx)
            fx.Transform:SetPosition(0, 0, 0)
            fx.persists = false
            if fx.components.firefx ~= nil then
                fx.components.firefx:SetLevel(2, true, false)
                fx.components.firefx:AttachLightTo(target)
            end
            inst._fx = fx
        end
        inst:ListenForEvent("death", function() inst.components.debuff:Stop() end, target)
    end
    local function Detached(inst)
        if inst._fx ~= nil and inst._fx:IsValid() then inst._fx:Remove() end
        inst:Remove()
    end
    local function fn()
        local inst = CreateEntity()
        if not TheWorld.ismastersim then inst:DoTaskInTime(0, inst.Remove) return inst end
        inst.entity:AddTransform()
        inst.entity:Hide()
        inst.persists = false
        inst:AddTag("CLASSIFIED")
        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(Attached)
        inst.components.debuff:SetDetachedFn(Detached)
        inst.components.debuff:SetExtendedFn(function()
            inst.components.timer:StopTimer("buffover")
            inst.components.timer:StartTimer("buffover", 8.1)
        end)
        inst.components.debuff.keepondespawn = true
        inst:AddComponent("timer")
        inst.components.timer:StartTimer("buffover", 8.1)
        inst:ListenForEvent("timerdone", function(_, event)
            if event.name == "buffover" then inst.components.debuff:Stop() end
        end)
        return inst
    end
    return Prefab("ttk_plant_cyh_buff", fn, nil, {"character_fire"})
end

for suffix, data in pairs(HERBS) do
    table.insert(output, MakePlant(suffix, data))
    table.insert(output, MakeItem(suffix, data, false))
    table.insert(output, MakeItem(suffix, data, true))
end
table.insert(output, MakeRegenBuff())
table.insert(output, MakeBurnBuff())
return unpack(output)
