local G=GLOBAL
local defs=G.require("ttk_boss_defs")
modimport("main/ttk_boss_combat.lua")
modimport("main/ttk_boss_backpack.lua")
modimport("main/ttk_boss_seed.lua")
modimport("main/ttk_boss_food.lua")
table.insert(PrefabFiles,"ttk_boss_summons")

local lifecycle=G.require("ttk_boss_lifecycle")
for _,key in ipairs(defs.order) do
    local def=defs.bosses[key]
    G.STRINGS.NAMES[string.upper(def.prefab)]=def.name
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(def.prefab)]=def.unique
        and "Một tồn tại duy nhất. Nó không gây hấn nếu chưa bị khiêu chiến." or "Đánh bại nó để nhận linh vật và vật phẩm triệu hồi."
    if def.summon then
        G.STRINGS.NAMES[string.upper(def.summon)]=def.summon_name or ("Phù Triệu Hồi — "..def.name)
        G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(def.summon)]="Dùng trên đất liền để gọi "..def.name..". Tiêu hao một vật phẩm khi thành công."
        if not def.summon_icon then
            RegisterInventoryItemAtlas("images/inventoryimages/"..def.summon..".xml",def.summon..".tex")
        end
    end
    AddPrefabPostInit(def.prefab,function(inst)
        if G.TheWorld.ismastersim then lifecycle.Install(inst,def) end
    end)
end

local action=G.Action({priority=2,rmb=true,mount_valid=false})
action.id="TTK_SUMMON_BOSS"
action.str="Triệu hồi boss"
action.fn=function(act)
    local item=act.invobject
    return item and item.components.ttk_bosssummoner and item.components.ttk_bosssummoner:Summon(act.doer) or false
end
AddAction(action)
AddComponentAction("INVENTORY","inventoryitem",function(inst,doer,actions,right)
    if right and inst:HasTag("ttk_boss_summon") and not doer:HasTag("playerghost") then table.insert(actions,action) end
end)
AddStategraphActionHandler("wilson",G.ActionHandler(action,"doshortaction"))
AddStategraphActionHandler("wilson_client",G.ActionHandler(action,"doshortaction"))
AddPrefabPostInit("world",function(inst)
    if inst.ismastersim and not inst:HasTag("cave") then inst:AddComponent("ttk_bossregistry") end
end)
