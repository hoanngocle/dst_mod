local defs=require("ttk_boss_defs")
-- Each token has a dedicated relic visual. Shadowheart uses DST's native art
-- only: the summon item does not inherit shadowheart tags or socket mechanics.
local prefabs={}
for _,key in ipairs(defs.order) do
    local def=defs.bosses[key]
    if def.summon then
        local imagename=def.summon_icon or def.summon
        local atlas=def.summon_icon and GetInventoryItemAtlas(imagename..".tex") or ("images/inventoryimages/"..def.summon..".xml")
        local build=def.summon_icon or def.summon
        local itemassets={Asset("ANIM","anim/"..build..".zip")}
        if not def.summon_icon then
            itemassets[#itemassets+1]=Asset("ATLAS",atlas)
            itemassets[#itemassets+1]=Asset("IMAGE","images/inventoryimages/"..def.summon..".tex")
        end
        local function fn()
            local inst=CreateEntity()
            inst.entity:AddTransform();inst.entity:AddAnimState();inst.entity:AddNetwork()
            MakeInventoryPhysics(inst)
            inst.AnimState:SetBank(build)
            inst.AnimState:SetBuild(build)
            inst.AnimState:PlayAnimation("idle")
            inst:AddTag("ttk_boss_summon")
            MakeInventoryFloatable(inst)
            inst.entity:SetPristine()
            if not TheWorld.ismastersim then return inst end
            inst:AddComponent("inspectable")
            inst:AddComponent("inventoryitem")
            inst.components.inventoryitem.atlasname=atlas
            inst.components.inventoryitem:ChangeImageName(imagename)
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize=TUNING.STACK_SIZE_SMALLITEM
            inst:AddComponent("ttk_bosssummoner")
            inst.components.ttk_bosssummoner.key=key
            MakeHauntableLaunch(inst)
            return inst
        end
        table.insert(prefabs,Prefab(def.summon,fn,itemassets,{def.prefab}))
    end
end
return unpack(prefabs)
