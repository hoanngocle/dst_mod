-- Source rewards that currently have no active recipe, cultivation or gear power.
local out={}
for _,row in ipairs(require("ttk_boss_collectible_defs")) do
    local name,icon,build,animation=unpack(row)
    if name ~= "ttk_boss_back_xh" and name ~= "ttk_boss_zcyseed" then -- dedicated functional prefabs
    local assets={Asset("ANIM","anim/"..build..".zip"),
        Asset("ATLAS","images/inventoryimages/"..icon..".xml"),
        Asset("IMAGE","images/inventoryimages/"..icon..".tex")}
    local function fn()
        local inst=CreateEntity()
        inst.entity:AddTransform();inst.entity:AddAnimState();inst.entity:AddNetwork()
        MakeInventoryPhysics(inst)
        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build);inst.AnimState:PlayAnimation(animation)
        MakeInventoryFloatable(inst)
        inst:AddTag("ttk_boss_collectible")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname="images/inventoryimages/"..icon..".xml"
        inst.components.inventoryitem:ChangeImageName(icon)
        inst:AddComponent("stackable");inst.components.stackable.maxsize=TUNING.STACK_SIZE_LARGEITEM
        MakeHauntableLaunch(inst)
        return inst
    end
    table.insert(out,Prefab(name,fn,assets))
    end
end
return unpack(out)
