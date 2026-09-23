-- Tiên Hà backpack: original art/layout; stable former boss-collectible ID.
local assets={Asset("ANIM","anim/xd_back_xh.zip"),
    Asset("ATLAS","images/inventoryimages/xd_back_xh.xml"),
    Asset("IMAGE","images/inventoryimages/xd_back_xh.tex"),
    Asset("ATLAS","images/xd_back_xh_ui.xml"),Asset("IMAGE","images/xd_back_xh_ui.tex")}

local function OnEquip(inst,owner)
    owner.AnimState:OverrideSymbol("swap_body","xd_back_xh","swap_body")
    inst.components.container:Open(owner)
end
local function OnUnequip(inst,owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.container:Close(owner)
end
local function OnEquipToModel(inst)
    inst.components.container:Close()
end

local function SplitLegacyBags(inst)
    -- Saved collectibles used to stack. Split extras beside the holder after
    -- container/inventory load finishes; never silently discard saved copies.
    local owner=inst.components.inventoryitem:GetGrandOwner() or inst
    local x,y,z=owner.Transform:GetWorldPosition()
    while (inst._ttk_legacy_bags or 0)>0 do
        local bag=SpawnPrefab(inst.prefab)
        if bag==nil then
            inst:DoTaskInTime(1,SplitLegacyBags)
            return
        end
        bag.Transform:SetPosition(x,y,z)
        inst._ttk_legacy_bags=inst._ttk_legacy_bags-1
    end
    inst._ttk_legacy_bags=nil
end
local function OnLoad(inst,data)
    if data then
        inst._ttk_legacy_bags=data.ttk_legacy_bags
            or (data.stackable and math.max(0,(data.stackable.stack or 1)-1))
        if (inst._ttk_legacy_bags or 0)>0 then inst:DoTaskInTime(0,SplitLegacyBags) end
    end
end
local function OnSave(inst,data)
    if (inst._ttk_legacy_bags or 0)>0 then data.ttk_legacy_bags=inst._ttk_legacy_bags end
end

local function fn()
    local inst=CreateEntity()
    inst.entity:AddTransform();inst.entity:AddAnimState();inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("xd_back_xh")
    inst.AnimState:SetBuild("xd_back_xh")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("backpack")
    MakeInventoryFloatable(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname="images/inventoryimages/xd_back_xh.xml"
    inst.components.inventoryitem:ChangeImageName("xd_back_xh")
    inst.components.inventoryitem.cangoincontainer=false
    inst:AddComponent("tradable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_boss_back_xh")
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot=EQUIPSLOTS.BACK or EQUIPSLOTS.BACKPACK or EQUIPSLOTS.PACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)
    inst.OnLoad=OnLoad;inst.OnSave=OnSave
    MakeHauntableLaunchAndDropFirstItem(inst)
    return inst
end
return Prefab("ttk_boss_back_xh",fn,assets)
