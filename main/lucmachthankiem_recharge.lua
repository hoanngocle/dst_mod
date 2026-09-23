local G = GLOBAL
local EQUIPSLOTS, TUNING, STRINGS, FRAMES = G.EQUIPSLOTS, G.TUNING, G.STRINGS, G.FRAMES
local net_bool, SendModRPCToServer, MOD_RPC = G.net_bool, G.SendModRPCToServer, G.MOD_RPC
local resolvefilepath = G.resolvefilepath
local CRAFTING_ATLAS, CRAFTING_ICONS_ATLAS = G.CRAFTING_ATLAS, G.CRAFTING_ICONS_ATLAS
local ACTIONS, ActionHandler, IsEntityDead = G.ACTIONS, G.ActionHandler, G.IsEntityDead

local materials = {
    bluegem = 40,
    redgem = 40,
    purplegem = 80,
    orangegem = 120,
    yellowgem = 160,
    greengem = 300,
    opalpreciousgem = 800,
    alterguardianhatshard = 800,
}

-- Dùng đúng bảng nạp của Tinh La Kiếm/Tu Tiên; tiêu hao một vật phẩm,
-- không nhân theo độ bền còn lại của vũ khí hiến tế.
for prefab, value in pairs(G.require("ttk_tinhlakiem_repair")) do
    materials[prefab] = value
end

for prefab in pairs(materials) do
    AddPrefabPostInit(prefab, function(inst)
        inst:AddComponent"lucmachthankiem_recharge"
    end)
end

AddAction("LUCMACHTHANKIEM_RECHARGE", STRINGS.LUCMACHTHANKIEM_RECHARGE, function(act)
    local lucmachthankiem = act.target
    if lucmachthankiem == nil or not lucmachthankiem:HasTag"lucmachthankiem" then
        return
    end

    local item = act.invobject
    local repairvalue = item and materials[item.prefab]
    if repairvalue == nil or item == lucmachthankiem then
        return
    end

    local finiteuses = lucmachthankiem.components.finiteuses
    local accept = lucmachthankiem:OnGetItem(item)
    if not accept and (finiteuses == nil or finiteuses:GetPercent() >= 1) then
        return
    end

    if finiteuses then
        finiteuses:Repair(repairvalue)
        lucmachthankiem:OnRepair()
    end

    if item.components.stackable then
        item.components.stackable:Get():Remove()
    else
        item:Remove()
    end

    if act.doer.SoundEmitter then
        act.doer.SoundEmitter:PlaySound"turnoftides/common/together/moon_glass/mine"
    end

    return true
end)


AddComponentAction("USEITEM", "lucmachthankiem_recharge", function(inst, doer, target, actions)
    if target and target:HasTag"lucmachthankiem"  then
        table.insert(actions, ACTIONS.LUCMACHTHANKIEM_RECHARGE)  
    end
end)

local state = "doshortaction"
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.LUCMACHTHANKIEM_RECHARGE, state))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.LUCMACHTHANKIEM_RECHARGE, state))