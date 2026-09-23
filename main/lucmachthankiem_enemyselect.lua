local G = GLOBAL
local EQUIPSLOTS, TUNING, STRINGS, FRAMES = G.EQUIPSLOTS, G.TUNING, G.STRINGS, G.FRAMES
local net_bool, SendModRPCToServer, MOD_RPC = G.net_bool, G.SendModRPCToServer, G.MOD_RPC
local resolvefilepath = G.resolvefilepath
local CRAFTING_ATLAS, CRAFTING_ICONS_ATLAS = G.CRAFTING_ATLAS, G.CRAFTING_ICONS_ATLAS
local ACTIONS, ActionHandler, IsEntityDead = G.ACTIONS, G.ActionHandler, G.IsEntityDead

local function GetLucMachThanKiem(player)
    local inventory = player.components.inventory
    if inventory then
        for k, v in pairs(inventory.equipslots) do
            if v and v:HasTag"lucmachthankiem" then
                return v
            end
        end
    end
end

AddAction("LUCMACHTHANKIEM_SELECT", STRINGS.LUCMACHTHANKIEM_ENEMYSELECT, function(act)
    local doer = act.doer
    local target = act.target
    local lucmachthankiem = GetLucMachThanKiem(doer)
    if target and lucmachthankiem then
        lucmachthankiem:Attack(doer, target)
    end
end)

ACTIONS.LUCMACHTHANKIEM_SELECT.distance = 20
ACTIONS.LUCMACHTHANKIEM_SELECT.instant = true
ACTIONS.LUCMACHTHANKIEM_SELECT.mount_valid = true
ACTIONS.LUCMACHTHANKIEM_SELECT.priority = 3

AddComponentAction("SCENE", "combat", function(inst, doer, actions, right)
    if not right then
        return
    end
    local inventory = doer.replica.inventory
    if inventory == nil or not inventory:EquipHasTag"lucmachthankiem" then
        return
    end
    if inst:HasTag"player" then
        return
    end
    if (not IsEntityDead(inst, true)) and inst.replica.combat and inst.replica.combat:CanBeAttacked(doer) and (not doer.replica.combat:IsAlly(inst)) then
        table.insert(actions, ACTIONS.LUCMACHTHANKIEM_SELECT)
    end
end)