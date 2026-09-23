local defs = require("ttk_boss_defs")

local prefabs = {}

-- All six cores use dedicated ground sprites compiled from their icons.
local WORLD_VISUALS = {
    baihu = {
        asset = "anim/ttk_boss_core_baihu.zip", bank = "ttk_boss_core_baihu",
        build = "ttk_boss_core_baihu", animation = "idle", scale = 1,
    },
    jfsn = {
        asset = "anim/ttk_boss_core_jfsn.zip", bank = "ttk_boss_core_jfsn",
        build = "ttk_boss_core_jfsn", animation = "idle", scale = 1,
    },
    qlch = {
        asset = "anim/ttk_boss_core_qlch.zip", bank = "ttk_boss_core_qlch",
        build = "ttk_boss_core_qlch", animation = "idle", scale = 1,
    },
    spiderqueen = {
        asset = "anim/ttk_boss_core_spiderqueen.zip", bank = "ttk_boss_core_spiderqueen",
        build = "ttk_boss_core_spiderqueen", animation = "idle", scale = 1,
    },
    stalke_fuben = {
        asset = "anim/ttk_boss_core_stalke_fuben.zip", bank = "ttk_boss_core_stalke_fuben",
        build = "ttk_boss_core_stalke_fuben", animation = "idle", scale = 1,
    },
    deerclops_ziyun = {
        asset = "anim/ttk_boss_core_deerclops_ziyun.zip", bank = "ttk_boss_core_deerclops_ziyun",
        build = "ttk_boss_core_deerclops_ziyun", animation = "idle", scale = 1,
    },
}

local PROGRESS_TEXT = {
    baihu = "+4 xuyên giáp mỗi lần; đủ 10: +10% chí mạng.",
    jfsn = "+20 máu tối đa mỗi lần; đủ 10: miễn nhiễm nóng.",
    qlch = "+20 mana tối đa mỗi lần; đủ 10: miễn nhiễm lạnh.",
    spiderqueen = "+20 độ no tối đa mỗi lần; đủ 10: miễn nhiễm độc.",
    stalke_fuben = "-2 sát thương nhận vào mỗi lần; đủ 10: miễn nhiễm gây ngủ.",
    deerclops_ziyun = "+20 tinh thần tối đa mỗi lần; đủ 10: miễn nhiễm đóng băng.",
}

local function GetProgressDescription(inst, viewer, key)
    local count = viewer ~= nil and viewer.GetTtkBossProgressCount ~= nil
        and viewer:GetTtkBossProgressCount(key) or 0
    return string.format(
        "Đã luyện hóa: %d/%d. %s",
        count,
        defs.limit or 10,
        PROGRESS_TEXT[key] or ""
    )
end

local function MakeCore(key, def)
    local visual = assert(WORLD_VISUALS[key], "missing boss-core visual: " .. tostring(key))
    local function OnEaten(inst, eater)
        if eater ~= nil and eater:HasTag("player") and eater.components ~= nil then
            local progress = eater.components.ttk_bossprogress
            if progress ~= nil then progress:Absorb(key) end
        end
    end

    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst)

        inst.AnimState:SetBank(visual.bank)
        inst.AnimState:SetBuild(visual.build)
        inst.AnimState:PlayAnimation(visual.animation)
        if visual.scale ~= nil then
            inst.AnimState:SetScale(visual.scale, visual.scale, visual.scale)
        end
        inst:AddTag("preparedfood")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst.components.inspectable.descriptionfn = function(item, viewer)
            return GetProgressDescription(item, viewer, key)
        end

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = def.food
        inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. def.food .. ".xml"

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("edible")
        inst.components.edible.foodtype = FOODTYPE.GOODIES
        -- GOODIES is accepted by omnivores and vegetarians. MEAT as the
        -- secondary type also lets Wigfrid consume this progression item.
        inst.components.edible.secondaryfoodtype = FOODTYPE.MEAT
        inst.components.edible.healthvalue = 50
        inst.components.edible.hungervalue = 75
        inst.components.edible.sanityvalue = 50
        inst.components.edible:SetOnEatenFn(OnEaten)

        MakeHauntableLaunch(inst)
        return inst
    end

    local assets = {
        Asset("ANIM", visual.asset),
        Asset("ATLAS", "images/inventoryimages/" .. def.food .. ".xml"),
        Asset("IMAGE", "images/inventoryimages/" .. def.food .. ".tex"),
    }
    prefabs[#prefabs + 1] = Prefab(def.food, fn, assets)
end

for _, key in ipairs(defs.order) do
    local def = defs.bosses[key]
    if def ~= nil and def.food ~= nil then MakeCore(key, def) end
end

return unpack(prefabs)
