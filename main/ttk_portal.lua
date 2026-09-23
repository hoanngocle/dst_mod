-- Truyền Tống Trận: register private runtime paths before loading modules.
local private_scripts = {
    "scripts/ttt_debugutil.lua",
    "scripts/ttt_portal_visuals.lua",
    "scripts/screens/ttt_travelscreen.lua",
    "scripts/components/ttt_travelable.lua",
    "scripts/components/ttt_travelable_replica.lua",
    "scripts/prefabs/ttt_travelable_classified.lua",
    "anim/ttt_portal.zip",
    "anim/ttt_portal_gcsz.zip",
    "images/inventoryimages/ttt_portal_gcsz.xml",
    "images/inventoryimages/ttt_portal_gcsz.tex",
    "images/ttt_portal/frame.xml", "images/ttt_portal/frame.tex",
    "images/ttt_portal/vortex.xml", "images/ttt_portal/vortex.tex",
    "images/ttt_portal/panel.xml", "images/ttt_portal/panel.tex",
    "images/ttt_portal/icon.xml", "images/ttt_portal/icon.tex",
}
for _, filename in ipairs(private_scripts) do
    GLOBAL.ManifestManager:AddFileToModManifest(modname, filename)
end

local require = GLOBAL.require
local TravelScreen = require "screens/ttt_travelscreen"
local portal_visuals = require "ttt_portal_visuals"

local portal_assets = {
    Asset("ANIM", "anim/ttt_portal.zip"),
    Asset("ANIM", "anim/ttt_portal_gcsz.zip"),
    Asset("ATLAS", "images/inventoryimages/ttt_portal_gcsz.xml"),
    Asset("IMAGE", "images/inventoryimages/ttt_portal_gcsz.tex"),
    Asset("ATLAS", "images/ttt_portal/frame.xml"),
    Asset("IMAGE", "images/ttt_portal/frame.tex"),
    Asset("ATLAS", "images/ttt_portal/vortex.xml"),
    Asset("IMAGE", "images/ttt_portal/vortex.tex"),
    Asset("ATLAS", "images/ttt_portal/panel.xml"),
    Asset("IMAGE", "images/ttt_portal/panel.tex"),
    Asset("ATLAS", "images/ttt_portal/icon.xml"),
    Asset("IMAGE", "images/ttt_portal/icon.tex"),
}

for _, asset in ipairs(portal_assets) do
    table.insert(Assets, asset)
end

local debugutil = require "ttt_debugutil"
local print = debugutil.print

table.insert(PrefabFiles, "ttt_travelable_classified")

-- Thiết lập cố định; không đọc lựa chọn config cũ của thế giới.
local ArrowsignEnable = false
local Ownership = false

local TTT_TRAVEL = {}
GLOBAL.TTT_TRAVEL = TTT_TRAVEL
TTT_TRAVEL.HUNGER_COST = 1
TTT_TRAVEL.SANITY_COST = 1
TTT_TRAVEL.COUNTDOWN_ENABLE = false

if GLOBAL.KnownModIndex:IsModEnabled("workshop-1416161108") then
    print("Đã bật mod Camp Security.")
    TTT_TRAVEL.CampSecurityCheckPermissionUse = function(doer, target)
        return not Ownership or GLOBAL.checkPermissionUse(doer, target)
    end
else
    print("Chưa bật mod Camp Security.")
    TTT_TRAVEL.CampSecurityCheckPermissionUse = function(doer, target)
        return true
    end
end

local FT_Points = {"homesign"}
if ArrowsignEnable then table.insert(FT_Points, "arrowsign_post") end
portal_visuals.Register(env, FT_Points)

AddReplicableComponent("ttt_travelable")
for k, v in pairs(FT_Points) do
    AddPrefabPostInit(v, function(inst)
        portal_visuals.Apply(inst)
        if inst.components.talker == nil then inst:AddComponent("talker") end
        inst:AddTag("_ttt_travelable")
        if GLOBAL.TheWorld.ismastersim then
            inst:RemoveTag("_ttt_travelable")
            inst:AddComponent("ttt_travelable")
            inst.components.ttt_travelable.ownership = Ownership
        end
    end)
end

-- Mod RPC ------------------------------

AddModRPCHandler("NYX_TTT", "Travel", function(player, inst, index)
    if player == nil or inst == nil or not player:IsValid() or not inst:IsValid() then return end
    local travelable = inst.components.ttt_travelable
    if travelable == nil or travelable.traveller ~= player then return end
    if index == nil then
        travelable:EndTravel()
        return
    end
    if type(index) ~= "number" or index ~= math.floor(index)
        or travelable.destinations[index] == nil or not player:IsNear(inst, 3)
        or inst:HasTag("burnt") or inst:HasTag("fire")
        or not TTT_TRAVEL.CampSecurityCheckPermissionUse(player, inst) then
        travelable:EndTravel()
        return
    end
    travelable:Travel(player, index)
end)

-- PlayerHud UI -------------------------

AddClassPostConstruct("screens/playerhud", function(self, anim, owner)
    self.ShowTTTTravelScreen = function(_, attach)
        if attach == nil then
            return
        else
            self.ttt_travelscreen = TravelScreen(self.owner, attach)
            self:OpenScreenUnderPause(self.ttt_travelscreen)
            return self.ttt_travelscreen
        end
    end

    self.CloseTTTTravelScreen = function(_)
        if self.ttt_travelscreen then
            self.ttt_travelscreen:Close()
            self.ttt_travelscreen = nil
        end
    end
end)

-- Actions ------------------------------

AddAction("TTT_DESTINATION_UI", "Chọn điểm đến", function(act)
    if act.doer ~= nil and act.target ~= nil and act.doer:HasTag("player") and
        act.target.components.ttt_travelable and not act.target:HasTag("burnt") and
        not act.target:HasTag("fire") then
        act.target.components.ttt_travelable:BeginTravel(act.doer)
        return true
    end
end)
GLOBAL.ACTIONS.TTT_DESTINATION_UI.priority = 1
GLOBAL.ACTIONS.TTT_DESTINATION_UI.mount_valid = true

-- Component actions ---------------------

AddComponentAction("SCENE", "ttt_travelable", function(inst, doer, actions, right)
    if right then
        if not inst:HasTag("burnt") and not inst:HasTag("fire") and
            TTT_TRAVEL.CampSecurityCheckPermissionUse(doer, inst)
        then
            table.insert(actions, GLOBAL.ACTIONS.TTT_DESTINATION_UI)
        end
    end
end)

-- Stategraph ----------------------------

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(
                               GLOBAL.ACTIONS.TTT_DESTINATION_UI, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(
                               GLOBAL.ACTIONS.TTT_DESTINATION_UI, "give"))
