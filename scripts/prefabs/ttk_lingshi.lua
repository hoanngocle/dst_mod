local assets = {
    Asset("ANIM", "anim/ttk_lingshi.zip"),
}

for tier = 1, 4 do
    table.insert(assets, Asset("ATLAS", "images/inventoryimages/ttk_lingshi" .. tier .. ".xml"))
    table.insert(assets, Asset("IMAGE", "images/inventoryimages/ttk_lingshi" .. tier .. ".tex"))
end

local function MakeStone(tier)
    local name = "ttk_lingshi" .. tier

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("xd_lingshi")
        inst.AnimState:SetBuild("xd_lingshi")
        inst.AnimState:PlayAnimation(tostring(tier))

        inst:AddTag("ttk_lingshi")
        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. name .. ".xml"
        inst.components.inventoryitem.imagename = name

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

        inst:AddComponent("tradable")

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeStone(1), MakeStone(2), MakeStone(3), MakeStone(4)
