local assets = {
    Asset("ANIM", "anim/hh_dungeon_spider_build.zip"),
    Asset("ATLAS", "images/inventoryimages/hh_dungeon_spider.xml"),
    Asset("IMAGE", "images/inventoryimages/hh_dungeon_spider.tex"),
}

local variations = {1, 2, 3, 4, 5}
local function shuffleArray(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

local function GetRandomWithVariance(x, v)
    return x + (math.random() * 2 - 1) * v
end

local function DoSpikeAttack(inst, pt)
    local x, y, z = pt:Get()
    local inital_r = 1
    x = GetRandomWithVariance(x, inital_r)
    z = GetRandomWithVariance(z, inital_r)

    shuffleArray(variations)

    local num = math.random(2, 4)
    local dtheta = PI * 2 / num
    for i = 1, num do
        local r = 1.1 + math.random() * 1.75
        local theta = i * dtheta + math.random() * dtheta * 0.8 + dtheta * 0.2
        local x1 = x + r * math.cos(theta)
        local z1 = z + r * math.sin(theta)
        if TheWorld.Map:IsVisualGroundAtPoint(x1, 0, z1) and not TheWorld.Map:IsPointNearHole(Vector3(x1, 0, z1)) then
            local spike = SpawnPrefab("minimoonspider_spike")
            spike.Transform:SetPosition(x1, 0, z1)
            spike:SetOwner(inst)
            if variations[i + 1] ~= 1 then
                spike.AnimState:OverrideSymbol("spike01", "spider_spike", "spike0"..tostring(variations[i + 1]))
            end
        end
    end
end

local function fn()
    -- Create the base spider entity using vanilla fn
    local inst = Prefabs["spider"].fn()

    inst.AnimState:SetBuild("hh_dungeon_spider_build")

    -- Add custom tags for our mod logic
    inst:AddTag("hh_dungeon_mob")
    inst:AddTag("spider_regular") -- required for warrior leap in uncom SG
    inst:AddTag("spider_warrior") -- required to trigger evade loop
    -- Actually, if we add both spider_regular and spider_warrior, the Uncom SG logic uses spider_regular for leap, and spider_warrior for evade.

    if not TheWorld.ismastersim then
        return inst
    end

    -- Increase stats to act like a warrior but look like a regular spider
    if inst.components.health then
        inst.components.health:SetMaxHealth(TUNING.SPIDER_WARRIOR_HEALTH * 2)
    end
    
    if inst.components.combat ~= nil then
        inst.components.combat:SetRange(TUNING.SPIDER_WARRIOR_ATTACK_RANGE * 0.5, TUNING.SPIDER_WARRIOR_HIT_RANGE * 0.8)
    end
    
    if inst.components.locomotor ~= nil then
        inst.components.locomotor.walkspeed = TUNING.SPIDER_WARRIOR_WALK_SPEED
        inst.components.locomotor.runspeed = TUNING.SPIDER_WARRIOR_RUN_SPEED
    end

    inst.DoSpikeAttack = DoSpikeAttack

    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem.atlasname = "images/inventoryimages/hh_dungeon_spider.xml"
        inst.components.inventoryitem:ChangeImageName("hh_dungeon_spider")
    end

    return inst
end

return Prefab("hh_dungeon_spider", fn, assets)
