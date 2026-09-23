require("prefabutil")

local cooking = require("cooking")
local defs = require("ttk_defs")

local assets = {
    Asset("ANIM", "anim/ttk_hhlmz.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_hhlmz.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_hhlmz.tex"),
    Asset("ATLAS", "images/map_icons/ttk_hhlmz.xml"),
    Asset("IMAGE", "images/map_icons/ttk_hhlmz.tex"),
}

local prefabs = {
    "collapse_small",
    "chestupgrade_stacksize_fx",
    "alterguardianhatshard",
    "collapsed_treasurechest",
}

local function OnOpen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function OnClose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function SpawnCollapseFx(inst)
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
    end
end

local function OnHammered(inst)
    if inst.components.lootdropper ~= nil then
        inst.components.lootdropper:DropLoot()
    end
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    SpawnCollapseFx(inst)
    inst:Remove()
end

local function OnHit(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
    inst.AnimState:PlayAnimation("idle")
end

local function ValidSlot(slot)
    return type(slot) == "number" and slot >= 1 and slot <= 8 and slot == math.floor(slot)
end

local function FindRecipe(prefab)
    for cooker, recipes in pairs(cooking.recipes or {}) do
        if recipes[prefab] ~= nil then
            return recipes[prefab], cooker
        end
    end
    return nil, nil
end

local function IsModCook(prefab)
    if type(IsModCookingProduct) ~= "function" then
        return false
    end
    for cooker in pairs(cooking.recipes or {}) do
        if IsModCookingProduct(cooker, prefab) then
            return true
        end
    end
    return false
end

local function GetBuild(item)
    if type(item.Get_Myth_Food_Table) == "function" then
        local ok, build, symbol = pcall(item.Get_Myth_Food_Table, item)
        if ok and build ~= nil and symbol ~= nil then
            return build, symbol
        end
    end

    local prefab = item.prefab
    if type(prefab) ~= "string" then
        return nil, nil
    end

    local base = string.match(prefab, "^(.-)_spice_") or prefab
    local recipe = FindRecipe(prefab)
    if recipe == nil and base ~= prefab then
        recipe = FindRecipe(base)
    end

    local is_mod_product = IsModCook(prefab) or (base ~= prefab and IsModCook(base))
    if recipe == nil and not is_mod_product then
        return nil, nil
    end

    local build = recipe ~= nil and recipe.overridebuild or nil
    local symbol = recipe ~= nil and recipe.overridesymbolname or nil
    return build or (is_mod_product and base or "cook_pot_food"), symbol or base
end

local function AddDecor(inst, data)
    if data == nil or not ValidSlot(data.slot) or data.item == nil or inst:HasTag("burnt") then
        return
    end
    local build, symbol = GetBuild(data.item)
    if build ~= nil and symbol ~= nil then
        inst.AnimState:OverrideSymbol("food_" .. data.slot, build, symbol)
    else
        inst.AnimState:ClearOverrideSymbol("food_" .. data.slot)
    end
end

local function RemoveDecor(inst, data)
    if data ~= nil and ValidSlot(data.slot) then
        inst.AnimState:ClearOverrideSymbol("food_" .. data.slot)
    end
end

local function RefreshDecor(inst)
    if inst.components.container == nil then
        return
    end
    for slot = 1, 8 do
        local item = inst.components.container:GetItemInSlot(slot)
        if item ~= nil then
            AddDecor(inst, { slot = slot, item = item })
        else
            inst.AnimState:ClearOverrideSymbol("food_" .. slot)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("ttk_hhlmz.tex")

    inst:AddTag("structure")

    inst.AnimState:SetBank("xd_hhlmz")
    inst.AnimState:SetBuild("xd_hhlmz")
    inst.AnimState:PlayAnimation("idle")
    inst.TTKRefreshDecor = RefreshDecor

    MakeObstaclePhysics(inst, 1.5)
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_hhlmz")
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

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(defs.table_perish_rate)

    inst:ListenForEvent("itemget", AddDecor)
    inst:ListenForEvent("itemlose", RemoveDecor)

    local old_postpass = inst.OnLoadPostPass
    inst.OnLoadPostPass = function(inst, newents, savedata)
        if old_postpass ~= nil then
            old_postpass(inst, newents, savedata)
        end
        RefreshDecor(inst)
    end

    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    require("ttk_chestupgrade")(inst)

    return inst
end

return Prefab("ttk_hhlmz", fn, assets, prefabs),
    MakePlacer("ttk_hhlmz_placer", "xd_hhlmz", "xd_hhlmz", "idle")
