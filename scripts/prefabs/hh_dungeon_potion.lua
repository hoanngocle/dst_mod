local ShopDefs = require("dungeon_shop/hh_dungeon_shop_defs")

local assets = {
    Asset("ANIM", "anim/hh_dungeon_potions.zip"),
    Asset("ANIM", "anim/hh_dungeon_disciple_potions.zip"),
    Asset("ANIM", "anim/hh_vat_pham.zip"),
}
local reincarnation_assets = {
    Asset("ANIM", "anim/hh_da_chuyen_sinh.zip"),
}

local function ApplyGroundVisualForProduct(inst, product)
    if product ~= nil and product.ground_anim ~= nil then
        inst.AnimState:SetBank(product.ground_bank or "hh_dungeon_potions")
        inst.AnimState:SetBuild(product.ground_build or "hh_dungeon_potions")
        inst.AnimState:PlayAnimation(product.ground_anim)
    else
        inst.AnimState:SetBank("healingsalve")
        inst.AnimState:SetBuild("healingsalve")
        inst.AnimState:PlayAnimation("idle")
    end
end

local function ApplyGroundVisual(inst)
    ApplyGroundVisualForProduct(inst, ShopDefs.GetByVisual(inst.hh_dungeon_visual:value()))
end

local function SetProduct(inst, product_id)
    local product = ShopDefs.Get(product_id)
    if product == nil then return false end
    inst.hh_dungeon_product_id = product.id
    inst.components.inventoryitem.atlasname = product.inventory_atlas or product.atlas
    inst.components.inventoryitem.imagename = product.inventory_icon or product.icon or product.prefab or "healingsalve"
    inst.hh_dungeon_visual:set(product.visual or 0)
    ApplyGroundVisual(inst)
    return true
end

local function CanStackWith(inst, other)
    return inst.hh_dungeon_product_id ~= nil
        and inst.hh_dungeon_product_id == other.hh_dungeon_product_id
end

local function OnDeStack(new_item, source)
    if source.hh_dungeon_product_id ~= nil and new_item.SetDungeonProduct ~= nil then
        new_item:SetDungeonProduct(source.hh_dungeon_product_id)
    end
end

local function OnUse(inst, doer)
    local product = ShopDefs.Get(inst.hh_dungeon_product_id)
    local effects = doer and doer.components.hh_dungeon_effects
    if product == nil then return false end
    if product.effect_id ~= nil then
        if effects == nil then return false end
        if not effects:AddEffect(product.effect_id, product.duration or 600) then return false end
    elseif product.use_id ~= nil then
        if effects == nil or not effects:UseUtility(product.use_id, product.duration) then return false end
    else
        local reward = SpawnPrefab(product.prefab)
        if reward == nil or doer.components.inventory == nil then
            if reward ~= nil then reward:Remove() end
            return false
        end
        if not doer.components.inventory:GiveItem(reward) then
            reward:Remove()
            return false
        end
    end
    if inst.components.stackable and inst.components.stackable:StackSize() > 1 then
        local one = inst.components.stackable:Get()
        one:Remove()
    else
        inst:Remove()
    end
    return true
end

local function OnSave(inst, data)
    data.hh_dungeon_product_id = inst.hh_dungeon_product_id
end

local function OnLoad(inst, data)
    if data and data.hh_dungeon_product_id then SetProduct(inst, data.hh_dungeon_product_id) end
end

local function MakeFn(default_product_id)
    return function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        inst.hh_dungeon_visual = net_byte(inst.GUID, "hh_dungeon_potion.visual", "hh_dungeon_potion_visualdirty")

        local default_product = default_product_id ~= nil and ShopDefs.Get(default_product_id) or nil
        ApplyGroundVisualForProduct(inst, default_product)

        MakeInventoryFloatable(inst, "small", 0.15, 0.55)

        inst:ListenForEvent("hh_dungeon_potion_visualdirty", ApplyGroundVisual)
        inst:AddTag("hh_dungeon_potion")
        inst:AddTag("hh_dungeon_shop_item")

        -- Gắn tag phân loại animation cho QoL items (cần ở pristine state để client đọc được)
        if default_product ~= nil and default_product.anim_type ~= nil then
            inst:AddTag("hh_dg_" .. default_product.anim_type)
            -- QoL items không dùng animation uống thuốc
            inst:RemoveTag("hh_dungeon_potion")
        end

        -- Dùng đúng state drinkelixir vanilla (drink_pre -> drink_lag -> drink) cho mọi bình của Dungeon Shop.
        -- Symbol này là symbol vanilla của ghostlyelixir_shield và chỉ phục vụ phần cầm bình trong animation.
        inst.elixir_buff_type = "ghostlyelixir_shield"
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "healingsalve"
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
        inst.stackable_CanStackWithFn = CanStackWith
        inst.components.stackable:SetOnDeStack(OnDeStack)
        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(OnUse)
        inst.SetDungeonProduct = SetProduct
        inst.UseDungeonItem = OnUse
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        if default_product_id ~= nil then
            SetProduct(inst, default_product_id)
        end

        MakeHauntableLaunch(inst)
        return inst
    end
end

local function MakeReincarnationFn(default_product_id)
    return function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        inst.hh_dungeon_visual = net_byte(inst.GUID, "hh_dungeon_potion.visual", "hh_dungeon_potion_visualdirty")

        local default_product = default_product_id ~= nil and ShopDefs.Get(default_product_id) or nil
        ApplyGroundVisualForProduct(inst, default_product)

        MakeInventoryFloatable(inst, "small", 0.15, 0.55)
        inst:ListenForEvent("hh_dungeon_potion_visualdirty", ApplyGroundVisual)
        inst:AddTag("moonportalkey")
        inst:AddTag("donotautopick")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "healingsalve"
        inst.components.inventoryitem:SetSinks(true)
        inst:AddComponent("moonrelic")
        inst.SetDungeonProduct = SetProduct
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        if default_product_id ~= nil then
            SetProduct(inst, default_product_id)
        end

        MakeHauntableLaunch(inst)
        return inst
    end
end

local prefabs = {
    Prefab("hh_dungeon_potion", MakeFn(), assets),
}

for _, product in ipairs(ShopDefs.list) do
    if product.prefab_id ~= nil and product.category ~= "weapon" then
        if product.prefab_id == "hh_da_chuyen_sinh" then
            table.insert(prefabs, Prefab(product.prefab_id, MakeReincarnationFn(product.id), reincarnation_assets))
        else
            table.insert(prefabs, Prefab(product.prefab_id, MakeFn(product.id), assets))
        end
    end
end

return unpack(prefabs)
