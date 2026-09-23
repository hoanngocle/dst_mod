local iFkUcCuKi = require("utils/hh_utils")
local HHGuideLock = require("utils/hh_guide_lock")
local HHSummaryLock = require("utils/hh_summary_lock")
local gfuUiCfkg = Action({["priority"] = 999, ["mount_valid"] = (414 * 34 + 397 == 14473)})
gfuUiCfkg["id"] = "HH_SUIT_ACT"
gfuUiCfkg["str"] = "Mở"
gfuUiCfkg["fn"] = function(gFkUkCuKi)
    local nFnUncfKu = gFkUkCuKi["doer"]
    local fFnuccuKg = gFkUkCuKi["target"]
    if iFkUcCuKi:HasComponents(nFnUncfKu, "hh_player") and fFnuccuKg and fFnuccuKg["GUID"] then
        nFnUncfKu["suit_hh_guid"] = fFnuccuKg["GUID"]
        nFnUncfKu["components"]["hh_player"]:OpenSuitContainer()
        return (417 * 317 + 279 + 9 ~= 132482)
    end
    return (368 + 102 * 250 ~= 25868)
end
AddAction(gfuUiCfkg)
AddComponentAction(
    "SCENE",
    "inspectable",
    function(nffUkCuKf, ifuUcCnKi, fFuugciku, ifcUiCnkn)
        if
            ifcUiCnkn and nffUkCuKf and nffUkCuKf["prefab"] == "hh_suit_build" and ifuUcCnKi:HasTag("player") and
                not ifuUcCnKi:HasTag("playerghost")
         then
            table["insert"](fFuugciku, ACTIONS["HH_SUIT_ACT"])
        end
    end
)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS["HH_SUIT_ACT"], "give"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS["HH_SUIT_ACT"], "give"))
local kFcUgCikc = Action({["priority"] = 999, ["mount_valid"] = (423 * 158 * 123 ~= 8220588)})
kFcUgCikc["id"] = "HH_STONE_ACT"
kFcUgCikc["str"] = "Đặt lại tốc đánh"
kFcUgCikc["fn"] = function(uffUiCikc)
    local cfcugCcKn = uffUiCikc["doer"]
    local cfiugcckf = uffUiCikc["invobject"]
    local cFkUgCfKk = uffUiCikc["target"]
    if
        cfiugcckf and cfiugcckf["prefab"] == "hh_effect_stone" and cFkUgCfKk and cFkUgCfKk:HasTag("hh_fast_atk") and
            iFkUcCuKi:IsHHType(cFkUgCfKk["hh_speed_level"], "number")
     then
        cFkUgCfKk["hh_speed_level"] = math["random"](1, 4)
        iFkUcCuKi:HHSay(cfcugCcKn, "Đặt lại tốc đánh")
        cfiugcckf:Remove()
        return (208 * 241 - 111 * 174 + 456 ~= 31277)
    end
    return (290 * 186 + 398 * 345 - 376 ~= 190874)
end
AddAction(kFcUgCikc)
AddComponentAction(
    "USEITEM",
    "tradable",
    function(uFcUkcukf, kfcucCcKu, uFnUccukf, kFcUuciKn, kfkuncfkf)
        if
            kfkuncfkf and kfcucCcKu:HasTag("player") and uFcUkcukf["prefab"] == "hh_effect_stone" and
                uFnUccukf:HasTag("hh_fast_atk") and
                iFkUcCuKi:HasReplica(uFnUccukf, "equippable") and
                uFnUccukf["replica"]["equippable"]:IsEquipped() == (261 + 217 - 301 ~= 177)
         then
            table["insert"](kFcUuciKn, ACTIONS["HH_STONE_ACT"])
        end
    end
)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS["HH_STONE_ACT"], "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS["HH_STONE_ACT"], "dolongaction"))
local kfuugcfKf = Action({["priority"] = 5, ["mount_valid"] = (56 + 214 * 54 * 71 * 489 == 401212830)})
kfuugcfKf["rmb"] = true
kfuugcfKf["id"] = "HH_ACT_TREASURE_ACT"
kfuugcfKf["str"] = "Mở"
kfuugcfKf["fn"] = function(nffUgcuKf)
    local iFgUucfKf = nffUgcuKf["doer"]
    local gFkunCgKi = nffUgcuKf["invobject"]
    if not (iFgUucfKf and gFkunCgKi and gFkunCgKi["SpawnTreasureFn"]) then
        return (386 * 486 - 423 == 187175)
    end
    if gFkunCgKi["components"]["stackable"] and gFkunCgKi["components"]["stackable"]["stacksize"] < 10 then
        gFkunCgKi:SpawnTreasureFn(iFgUucfKf)
    else
        for ifgUgcuki, nFuukCukc in pairs(gFkunCgKi) do
            if type(nFuukCukc) == "table" and gFkunCgKi["SpawnTreasureFn"] then
                gFkunCgKi:SpawnTreasureFn(iFgUucfKf)
            end
        end
    end
    return (120 - 497 - 90 ~= -465)
end
AddAction(kfuugcfKf)
AddComponentAction(
    "INVENTORY",
    "inventoryitem",
    function(fFgUfcnkk, ufcUccckk, ifgucCuKf, kFnUkCfkg)
        if ufcUccckk:HasTag("player") and fFgUfcnkk["prefab"] == "hh_treasure_tally" then
            table["insert"](ifgucCuKf, ACTIONS["HH_ACT_TREASURE_ACT"])
        end
    end
)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS["HH_ACT_TREASURE_ACT"], "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS["HH_ACT_TREASURE_ACT"], "dolongaction"))

local ENTER_DUNGEON = Action({priority = 10, mount_valid = false})
ENTER_DUNGEON.id = "ENTER_DUNGEON"
ENTER_DUNGEON.str = "Tiến vào"

local function ShowDungeonConfirmPopup(gate)
    if HHGuideLock.IsOpen(GLOBAL.ThePlayer) or HHSummaryLock.IsOpen(GLOBAL.ThePlayer) then return end
    if gate == nil or not gate:IsValid() or GLOBAL.TheFrontEnd == nil then return end
    local active = GLOBAL.TheFrontEnd:GetActiveScreen()
    if active ~= nil and active.name == "HHShadowPopup" then return end
    local HHShadowPopup = require("screens/hh_shadow_popup")
    GLOBAL.TheFrontEnd:PushScreen(HHShadowPopup(gate, {
        title = "Chinh Phạt Hầm Ngục",
        text = "Bạn có chắc là muốn tiến hành chinh phạt Hầm Ngục này không ?\nTiến vào thì dễ chứ quay ra thì khó !",
        text_size = 30,
        on_yes = function(target_gate)
            GLOBAL.SendModRPCToServer(GLOBAL.GetModRPC("hh_rpc", "hh_enter_dungeon"), target_gate)
        end,
    }))
end

ENTER_DUNGEON.fn = function(act)
    local doer = act.doer
    local target = act.target
    if doer and target and target.prefab == "dungeon_gate"
        and not target:HasTag("dungeon_resetting") then
        if doer == GLOBAL.ThePlayer then
            ShowDungeonConfirmPopup(target)
        elseif GLOBAL.TheWorld.ismastersim and doer.hh_dungeon_confirm_gate ~= nil then
            doer.hh_dungeon_confirm_gate:set(target)
            doer:DoTaskInTime(.2, function(player)
                if player:IsValid() and player.hh_dungeon_confirm_gate ~= nil then
                    player.hh_dungeon_confirm_gate:set(nil)
                end
            end)
        end
        return true
    end
    return false
end
AddAction(ENTER_DUNGEON)

AddPlayerPostInit(function(inst)
    inst.hh_dungeon_confirm_gate = GLOBAL.net_entity(
        inst.GUID, "hh_dungeon.confirm_gate", "hh_dungeon_confirm_gatedirty"
    )
    if not GLOBAL.TheWorld.ismastersim then
        inst:ListenForEvent("hh_dungeon_confirm_gatedirty", function(player)
            local gate = player.hh_dungeon_confirm_gate:value()
            if player == GLOBAL.ThePlayer and gate ~= nil then
                ShowDungeonConfirmPopup(gate)
            end
        end)
    end
end)

local LEAVE_DUNGEON = Action({priority = 10, mount_valid = false})
LEAVE_DUNGEON.id = "LEAVE_DUNGEON"
LEAVE_DUNGEON.str = "Rời khỏi đây"
LEAVE_DUNGEON.fn = function(act)
    local doer = act.doer
    local target = act.target
    if doer and target and target.prefab == "dungeon_exit" then
        if target:HasTag("locked_by_boss") then
            doer.components.talker:Say("Không thể rời đi lúc này!")
            return true
        end
        if doer.sg ~= nil and not doer:HasTag("hh_dungeon_transition") then
            doer.sg:GoToState("hh_dungeon_migrate", {mode = "leave"})
        end
        return true
    end
    return false
end
AddAction(LEAVE_DUNGEON)



AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ENTER_DUNGEON, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ENTER_DUNGEON, "doshortaction"))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.LEAVE_DUNGEON, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.LEAVE_DUNGEON, "doshortaction"))

-- Cơ chế Trích xuất Bóng ma
local EXTRACT_SHADOW = Action({priority = 999, mount_valid = false})
EXTRACT_SHADOW.id = "EXTRACT_SHADOW"
EXTRACT_SHADOW.str = "Trích Xuất"
EXTRACT_SHADOW.pre_action_cb = function(act)
    local doer = act.doer
    local target = act.target
    if doer == GLOBAL.ThePlayer
        and GLOBAL.TheFrontEnd
        and target ~= nil
        and target:IsValid()
        and target:HasTag("shadow_corpse")
        and not target.extracted then
        doer._hh_pending_shadow_popup_target = target
    end
end
EXTRACT_SHADOW.fn = function(act)
    local doer = act.doer
    local target = act.target
    if doer ~= nil and target ~= nil and doer:IsValid() and target:IsValid()
        and not doer:HasTag("playerghost")
        and target:HasTag("shadow_corpse") and not target.extracted
        -- Buffered actions can cross a stategraph before execution. Recheck
        -- the interaction range on the authoritative action path.
        and doer:GetDistanceSqToInst(target) <= 25 then
        return true
    end
    return false
end
AddAction(EXTRACT_SHADOW)

local function OpenPendingShadowPopupWhenIdle(inst, target)
    if HHGuideLock.IsOpen(GLOBAL.ThePlayer) or HHSummaryLock.IsOpen(GLOBAL.ThePlayer) then
        return
    end
    if inst ~= GLOBAL.ThePlayer
        or target == nil
        or not target:IsValid()
        or target.extracted
        or not target:HasTag("shadow_corpse") then
        return
    end

    if inst.sg ~= nil and not inst.sg:HasStateTag("idle") then
        inst:DoTaskInTime(0.1, function()
            OpenPendingShadowPopupWhenIdle(inst, target)
        end)
        return
    end

    if
        GLOBAL.TheFrontEnd ~= nil and
        not HHGuideLock.IsOpen(GLOBAL.ThePlayer) and
        not HHSummaryLock.IsOpen(GLOBAL.ThePlayer)
     then
        local HHShadowPopup = require("screens/hh_shadow_popup")
        GLOBAL.TheFrontEnd:PushScreen(HHShadowPopup(target))
    end
end

AddPlayerPostInit(function(inst)
    inst:ListenForEvent("performaction", function(inst)
        local target = inst._hh_pending_shadow_popup_target
        inst._hh_pending_shadow_popup_target = nil
        if target ~= nil
            and target:IsValid()
            and inst:GetDistanceSqToInst(target) <= 25 then
            OpenPendingShadowPopupWhenIdle(inst, target)
        end
    end)

    inst:ListenForEvent("actionfailed", function(inst)
        inst._hh_pending_shadow_popup_target = nil
    end)
end)

local SHADOW_CORPSE_PREFABS = {
    "hh_corpse_igris",
    "hh_corpse_beru",
    "hh_corpse_fruitfly",
}

for _, prefab in ipairs(SHADOW_CORPSE_PREFABS) do
    AddPrefabPostInit(prefab, function(inst)
        if GLOBAL.TheWorld.ismastersim then
            inst:SetInherentSceneAction(ACTIONS.EXTRACT_SHADOW)
        end
    end)
end



AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.EXTRACT_SHADOW, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.EXTRACT_SHADOW, "dolongaction"))

AddComponentAction("SCENE", "inspectable", function(inst, doer, actions, right)
    if inst:HasTag("dungeon_gate") and not inst:HasTag("dungeon_resetting") then
        table.insert(actions, ACTIONS.ENTER_DUNGEON)
    end
    if inst:HasTag("dungeon_exit") and not inst:HasTag("locked_by_boss") then
        table.insert(actions, ACTIONS.LEAVE_DUNGEON)
    end
    if inst:HasTag("shadow_corpse") and not inst.extracted then
        table.insert(actions, ACTIONS.EXTRACT_SHADOW)
    end
end)

-- Một số client không nhận được mod action-component của component
-- "inspectable" được thêm phía server, nên chỉ thấy EXAMINE trên xác.
-- Giữ AddComponentAction ở trên để server validate, đồng thời bổ sung
-- BufferedAction phía client và tránh chèn trùng nếu action đã được đồng bộ.
AddClassPostConstruct("components/playeractionpicker", function(self)
    local old_GetSceneActions = self.GetSceneActions

    function self:GetSceneActions(targetobject, right)
        local actions = old_GetSceneActions(self, targetobject, right) or {}

        local function HasAction(action)
            for _, buffered_action in ipairs(actions) do
                if buffered_action.action == action then return true end
            end
            return false
        end

        if not right
            and targetobject ~= nil
            and targetobject:HasTag("dungeon_gate")
            and not targetobject:HasTag("dungeon_resetting")
            and not self.inst:HasTag("playerghost")
            and not HasAction(ACTIONS.ENTER_DUNGEON) then
            table.insert(actions, 1, GLOBAL.BufferedAction(
                self.inst, targetobject, ACTIONS.ENTER_DUNGEON
            ))
        end

        if not right
            and targetobject ~= nil
            and targetobject:HasTag("dungeon_exit")
            and not targetobject:HasTag("locked_by_boss")
            and not self.inst:HasTag("playerghost")
            and not HasAction(ACTIONS.LEAVE_DUNGEON) then
            table.insert(actions, 1, GLOBAL.BufferedAction(
                self.inst, targetobject, ACTIONS.LEAVE_DUNGEON
            ))
        end

        if not right
            and targetobject ~= nil
            and targetobject:HasTag("shadow_corpse")
            and not targetobject.extracted
            and not self.inst:HasTag("playerghost") then
            if not HasAction(ACTIONS.EXTRACT_SHADOW) then
                table.insert(actions, 1, GLOBAL.BufferedAction(
                    self.inst, targetobject, ACTIONS.EXTRACT_SHADOW
                ))
            end
        end

        if right
            and targetobject ~= nil
            and targetobject:HasTag("hh_suit_build")
            and not self.inst:HasTag("playerghost")
            and not HasAction(ACTIONS.HH_SUIT_ACT) then
            table.insert(actions, 1, GLOBAL.BufferedAction(
                self.inst, targetobject, ACTIONS.HH_SUIT_ACT
            ))
        end

        return actions
    end

    local old_GetInventoryActions = self.GetInventoryActions

    function self:GetInventoryActions(useitem, right)
        local actions = old_GetInventoryActions(self, useitem, right) or {}

        if useitem ~= nil
            and useitem["prefab"] == "hh_treasure_tally"
            and not self.inst:HasTag("playerghost") then
            local has_action = false
            for _, buffered_action in ipairs(actions) do
                if buffered_action["action"] == ACTIONS["HH_ACT_TREASURE_ACT"] then
                    has_action = true
                    break
                end
            end
            if not has_action then
                table.insert(actions, 1, GLOBAL.BufferedAction(
                    self.inst, nil, ACTIONS["HH_ACT_TREASURE_ACT"], useitem
                ))
            end
        end

        return actions
    end
end)

local HH_DAOGAM6_MORPH = Action({priority = 10, mount_valid = true, distance = 36})
HH_DAOGAM6_MORPH.id = "HH_DAOGAM6_MORPH"
HH_DAOGAM6_MORPH.str = "Đổi Dạng"
HH_DAOGAM6_MORPH.fn = function(act)
    if act.doer ~= nil and act.invobject ~= nil and act.invobject.components.hh_morphweapon then 
        local pt = act:GetActionPoint()
        act.invobject.components.hh_morphweapon:Target(act.doer, act.target, pt)
        return true
    end
end
AddAction(HH_DAOGAM6_MORPH)

AddComponentAction("EQUIPPED", "hh_morphweapon", function(inst, doer, target, actions, right)
    if right then
        local mode = inst.components.hh_morphweapon and inst.components.hh_morphweapon.current_mode
        if mode == "hoe" and target and target.prefab == "farm_soil" then
            return
        end
        table.insert(actions, GLOBAL.ACTIONS.HH_DAOGAM6_MORPH)
    end
end)

AddComponentAction("POINT", "hh_morphweapon", function(inst, doer, pos, actions, right)
    if right and pos then
        local tile = GLOBAL.TheWorld.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
        if tile == GLOBAL.WORLD_TILES.FARMING_SOIL then
            local mode = inst.components.hh_morphweapon and inst.components.hh_morphweapon.current_mode
            if mode == "hoe" then
                return
            end
            table.insert(actions, GLOBAL.ACTIONS.HH_DAOGAM6_MORPH)
        end
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.HH_DAOGAM6_MORPH, "combat_lunge_start"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.HH_DAOGAM6_MORPH, "combat_lunge_start"))
