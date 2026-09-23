local G=GLOBAL
local terrain=G.require("ttk_tianjimap")
table.insert(PrefabFiles,"ttk_tianji")
table.insert(PrefabFiles,"ttk_tianji_interior")
local names={ttk_tianjiwu="Thiên Cơ Ốc",ttk_tianji_juanzhou="Thiên Cơ Quyển Trục",ttk_tianji_lingpai="Lệnh Bài Thiên Cơ Ốc",ttk_tianji_exit="Cửa ra Thiên Cơ Ốc"}
for prefab,name in pairs(names) do
    G.STRINGS.NAMES[string.upper(prefab)]=name
    G.STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(prefab)]=name
end
G.STRINGS.RECIPE_DESC.TTK_TIANJI_JUANZHOU="Dựng một căn nhà với phòng riêng lưu giữ đồ đạc."
G.STRINGS.RECIPE_DESC.TTK_TIANJI_LINGPAI="Dùng lên nhà của mình để thu hồi thành Quyển Trục."
for _,suffix in ipairs({"juanzhou","lingpai"}) do
    RegisterInventoryItemAtlas("images/inventoryimages/ttk_tianji_"..suffix..".xml","ttk_tianji_"..suffix..".tex")
end
AddMinimapAtlas("images/map_icons/ttk_tianjiwu.xml")
AddRecipe2("ttk_tianji_juanzhou",{
    G.Ingredient("papyrus",7),G.Ingredient("marble",15),G.Ingredient("livinglog",6),G.Ingredient("ttk_lingshi1",45),
},G.TECH.MAGIC_THREE,{atlas="images/inventoryimages/ttk_tianji_juanzhou.xml",image="ttk_tianji_juanzhou.tex",no_deconstruction=true},{"MAGIC","STRUCTURES"})
AddRecipe2("ttk_tianji_lingpai",{G.Ingredient("papyrus",1),G.Ingredient("ttk_lingshi1",1)},G.TECH.NONE,
    {atlas="images/inventoryimages/ttk_tianji_lingpai.xml",image="ttk_tianji_lingpai.tex",no_deconstruction=true},{"MAGIC"})

AddPrefabPostInit("world",function(inst)
    terrain.Reset();terrain.Install(inst.Map)
    if not G.TheWorld.ismastersim then return end
    inst:AddComponent("ttk_tianjirooms")
    local old=inst.OnPreLoad
    inst.OnPreLoad=function(world,data)
        terrain.Preload(data and data.ttk_tianjirooms)
        if old then old(world,data) end
    end
end)
AddPlayerPostInit(function(inst)
    if G.TheWorld.ismastersim then inst:AddComponent("ttk_tianjireturn") end
end)
local action=G.Action({priority=2,rmb=true,mount_valid=true,ghost_valid=true,encumbered_valid=true})
action.id="TTK_TIANJI_ENTER"
action.strfn=function(act) return act.target and act.target:HasTag("ttk_tianji_exit") and "EXIT" or "ENTER" end
action.fn=function(act)
    if not act.target or not act.target:IsValid() then return false end
    local manager=G.TheWorld.components.ttk_tianjirooms
    if not manager then return false end
    if act.target:HasTag("ttk_tianji_exit") then return manager:Exit(act.doer) end
    return not act.target._packing and manager:Enter(act.target,act.doer) or false
end
AddAction(action)
G.STRINGS.ACTIONS.TTK_TIANJI_ENTER={ENTER="Vào Thiên Cơ Ốc",EXIT="Ra ngoài"}
AddComponentAction("SCENE","inspectable",function(inst,doer,actions,right)
    if right and inst:HasTag("ttk_tianji_door") then table.insert(actions,action) end
end)
for _,sg in ipairs({"wilson","wilson_client"}) do AddStategraphActionHandler(sg,G.ActionHandler(action,"give")) end
for _,sg in ipairs({"wilsonghost","wilsonghost_client"}) do AddStategraphActionHandler(sg,G.ActionHandler(action,"haunt_pre")) end
G.require("ttk_tianjicamera")(env)
