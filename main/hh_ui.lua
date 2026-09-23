table.insert(Assets, Asset("ATLAS", "images/ttk_forge/frame.xml"))
table.insert(Assets, Asset("IMAGE", "images/ttk_forge/frame.tex"))
table.insert(Assets, Asset("ATLAS", "images/ttk_forge/controls.xml"))
table.insert(Assets, Asset("IMAGE", "images/ttk_forge/controls.tex"))
table.insert(Assets, Asset("ATLAS", "images/ttk_forge/effect_row.xml"))
table.insert(Assets, Asset("IMAGE", "images/ttk_forge/effect_row.tex"))
modimport("main/ttk_forge_fonts.lua")
local HHGuideLock = require("utils/hh_guide_lock")
local HHSummaryLock = require("utils/hh_summary_lock")
local HHacNguyetHoItems = require("utils/hh_hac_nguyet_ho_items")
local TTKUnifiedRegistry = require("ui/ttk_unified_registry")
local TTKNativeBridge = require("ui/ttk_native_bridge")
local MONARCH_STORAGE_PREFAB = "hh_monarch_storage_container"

local function IsGuideInputControl(control)
    return control == CONTROL_ACCEPT or control == CONTROL_PRIMARY or
        control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD
end

local function IsControllerAttached()
    return TheInput ~= nil and TheInput.ControllerAttached ~= nil and
        TheInput:ControllerAttached()
end

local function IsGuideEscapeControl(control)
    return control == CONTROL_CANCEL or control == CONTROL_PAUSE
end

local function IsGuideCloseControl(control)
    return control == CONTROL_CANCEL or
        (control == CONTROL_PAUSE and not IsControllerAttached())
end

local function IsGuideMovementFocusMove(dir)
    if TheInput == nil or TheInput.IsControlPressed == nil then
        return false
    end

    if dir == MOVE_UP then
        return TheInput:IsControlPressed(CONTROL_MOVE_UP)
    elseif dir == MOVE_DOWN then
        return TheInput:IsControlPressed(CONTROL_MOVE_DOWN)
    elseif dir == MOVE_LEFT then
        return TheInput:IsControlPressed(CONTROL_MOVE_LEFT)
    elseif dir == MOVE_RIGHT then
        return TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)
    end

    return false
end

local function IsSummaryEscapeControl(control)
    return control == CONTROL_CANCEL or control == CONTROL_PAUSE
end

local function IsSummaryCloseControl(control)
    return control == CONTROL_CANCEL or
        (control == CONTROL_PAUSE and not IsControllerAttached())
end

local function IsSummaryMovementFocusMove(dir)
    return IsGuideMovementFocusMove(dir)
end

local function IsSummaryPointerControl(control)
    if TheFrontEnd ~= nil and TheFrontEnd.isprimary then
        return true
    end

    if
        control == CONTROL_SECONDARY and
        TheInput ~= nil and
        TheInput.mouse_enabled and
        not IsControllerAttached()
     then
        return true
    end

    return
        (control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD) and
        TheInput ~= nil and
        TheInput.GetControlIsMouseWheel ~= nil and
        TheInput:GetControlIsMouseWheel(control)
end

local function IsMonarchEscapeControl(control)
    return control == CONTROL_CANCEL or control == CONTROL_PAUSE
end

local function IsMonarchCloseControl(control)
    return control == CONTROL_CANCEL or
        (control == CONTROL_PAUSE and not IsControllerAttached())
end

local function IsMonarchStorageOpen(owner)
    if owner == nil or owner.HHMonarchStorageOpen ~= true then
        return false
    end

    local hud = owner.HUD
    local controls = hud ~= nil and hud.controls or nil
    local containers = controls ~= nil and controls.containers or nil
    if type(containers) ~= "table" then
        return false
    end

    for container_inst in pairs(containers) do
        if container_inst ~= nil and container_inst.prefab == MONARCH_STORAGE_PREFAB then
            return true
        end
    end
    return false
end

local function RequestCloseMonarchStorage(owner)
    if IsMonarchStorageOpen(owner) then
        SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_monarch_storage_close"])
    end
end

-- Guide is a widget inside HUD (not a FrontEnd screen), so PlayerHud must be
-- the input boundary. This registration belongs in modimport's environment;
-- widgets loaded through require do not receive modutil's injected API table.
-- PlayerHud is client UI, so do not require/register it on a dedicated server.
if not GLOBAL["TheNet"]:IsDedicated() then
AddClassPostConstruct("screens/playerhud", function(self)
    local old_on_control = self.OnControl
    local old_on_mouse_button = self.OnMouseButton
    local old_on_focus_move = self.OnFocusMove
    local old_set_default_focus = self.SetDefaultFocus
    local old_on_raw_key = self.OnRawKey
    local old_on_destroy = self.OnDestroy

    self.OnControl = function(screen, control, down)
        local guide = HHGuideLock.Get(screen.owner)
        if guide ~= nil then
            if IsGuideEscapeControl(control) then
                if not IsControllerAttached() then
                    -- Keep the keyboard ESC cycle consumed after CloseGuide
                    -- clears the guide reference. The next raw ESC keydown
                    -- starts a new vanilla cycle and clears this latch.
                    screen._hh_guide_escape_latched = true
                end
                if IsGuideCloseControl(control) and not down then
                    guide:CloseGuide()
                end
                return true
            end

            if IsGuideInputControl(control) and guide:IsGuideInputFocused() then
                if old_on_control ~= nil and old_on_control(screen, control, down) then
                    return true
                end
            end

            return true
        end

        if screen._hh_guide_escape_latched and IsGuideEscapeControl(control) then
            return true
        end

        local summary = HHSummaryLock.Get(screen.owner)
        if summary ~= nil then
            if IsSummaryEscapeControl(control) then
                if not IsControllerAttached() then
                    screen._hh_summary_escape_latched = true
                end
                if IsSummaryCloseControl(control) and not down then
                    HHSummaryLock.Close(screen.owner)
                end
                return true
            end

            local input_allowed
            if IsSummaryPointerControl(control) then
                input_allowed = HHSummaryLock.IsMouseInputAllowed(screen.owner)
            else
                input_allowed = HHSummaryLock.IsControlInputAllowed(screen.owner)
            end
            if input_allowed and old_on_control ~= nil then
                old_on_control(screen, control, down)
            end

            -- The vanilla dispatch above is allowed to handle only the
            -- whitelisted UI trees. Its unhandled result must still be
            -- consumed so movement/world actions cannot leak through.
            return true
        end

        if screen._hh_summary_escape_latched and IsSummaryEscapeControl(control) then
            return true
        end

        if IsMonarchStorageOpen(screen.owner) and IsMonarchEscapeControl(control) then
            if not IsControllerAttached() then
                -- Consume the complete physical ESC cycle. Closing the
                -- container clears HHMonarchStorageOpen asynchronously, so
                -- the latch prevents the same key press from falling through
                -- into the vanilla pause/settings menu.
                screen._hh_monarch_escape_latched = true
            end
            if IsMonarchCloseControl(control) and not down then
                RequestCloseMonarchStorage(screen.owner)
            end
            return true
        end

        if screen._hh_monarch_escape_latched and IsMonarchEscapeControl(control) then
            return true
        end

        return old_on_control ~= nil and old_on_control(screen, control, down) or false
    end

    self.OnMouseButton = function(screen, button, down, x, y)
        local guide = HHGuideLock.Get(screen.owner)
        if guide ~= nil then
            if guide:IsGuideInputFocused() and old_on_mouse_button ~= nil and
                old_on_mouse_button(screen, button, down, x, y) then
                return true
            end
            return true
        end

        if HHSummaryLock.Get(screen.owner) ~= nil then
            if HHSummaryLock.IsMouseInputAllowed(screen.owner) and old_on_mouse_button ~= nil then
                old_on_mouse_button(screen, button, down, x, y)
            end

            -- The vanilla dispatch above is allowed only for Summary,
            -- Summary's toggle icon, InventoryBar and the owner's overflow
            -- container. World and unrelated HUD mouse input stays blocked.
            return true
        end

        return old_on_mouse_button ~= nil and old_on_mouse_button(screen, button, down, x, y) or false
    end

    self.OnFocusMove = function(screen, dir, down)
        local guide = HHGuideLock.Get(screen.owner)
        if guide ~= nil then
            -- FrontEnd.Update maps CONTROL_MOVE_* to focus movement too. Those
            -- are gameplay WASD/analog directions, not Guide navigation.
            -- Returning false avoids FrontEnd's controller-focus sound path.
            if IsGuideMovementFocusMove(dir) then
                return false
            end

            -- Let non-gameplay focus move only inside Guide; never fall back
            -- to HUD/world.
            if guide:IsGuideInputFocused() then
                guide:OnFocusMove(dir, down)
            end
            return true
        end

        if HHSummaryLock.Get(screen.owner) ~= nil then
            if IsSummaryMovementFocusMove(dir) then
                return false
            end

            if HHSummaryLock.IsControlInputAllowed(screen.owner) and old_on_focus_move ~= nil then
                old_on_focus_move(screen, dir, down)
            end
            return true
        end

        return old_on_focus_move ~= nil and old_on_focus_move(screen, dir, down) or false
    end

    self.SetDefaultFocus = function(screen)
        local guide = HHGuideLock.Get(screen.owner)
        if guide ~= nil then
            if not guide:IsGuideInputFocused() then
                guide:SetFocus()
            end
            return true
        end

        if HHSummaryLock.IsOpen(screen.owner) then
            return true
        end

        return old_set_default_focus ~= nil and old_set_default_focus(screen) or false
    end

    self.OnRawKey = function(screen, key, down)
        if key == KEY_ESCAPE then
            if down then
                if HHGuideLock.IsOpen(screen.owner) then
                    screen._hh_summary_escape_latched = nil
                    screen._hh_monarch_escape_latched = nil
                    screen._hh_guide_escape_latched = true
                elseif HHSummaryLock.IsOpen(screen.owner) then
                    screen._hh_guide_escape_latched = nil
                    screen._hh_monarch_escape_latched = nil
                    screen._hh_summary_escape_latched = true
                elseif IsMonarchStorageOpen(screen.owner) then
                    screen._hh_guide_escape_latched = nil
                    screen._hh_summary_escape_latched = nil
                    screen._hh_monarch_escape_latched = true
                else
                    -- A new physical ESC press after a modal/container close
                    -- restores the vanilla pause/settings lifecycle.
                    screen._hh_guide_escape_latched = nil
                    screen._hh_summary_escape_latched = nil
                    screen._hh_monarch_escape_latched = nil
                end
            end

            if
                HHGuideLock.IsOpen(screen.owner) or
                HHSummaryLock.IsOpen(screen.owner) or
                IsMonarchStorageOpen(screen.owner) or
                screen._hh_guide_escape_latched or
                screen._hh_summary_escape_latched or
                screen._hh_monarch_escape_latched
             then
                return true
            end
        elseif HHGuideLock.IsOpen(screen.owner) or HHSummaryLock.IsOpen(screen.owner) then
            -- Global key handlers are guarded separately; this consumes the
            -- remaining raw-key path so it cannot reach HUD/world controls.
            -- Monarch Storage intentionally does NOT consume non-ESC raw
            -- keys, preserving WASD/Z/inventory/equipment controls.
            return true
        end

        return old_on_raw_key ~= nil and old_on_raw_key(screen, key, down) or false
    end

    self.OnDestroy = function(screen, ...)
        -- A HUD can be rebuilt without a normal container Close callback.
        -- Clear only Summary's focus channel; Guide's proven lifecycle stays
        -- unchanged.
        HHSummaryLock.SetHudInputFocus(screen.owner, false)
        HHSummaryLock.ClearContainerWidget(screen.owner)
        screen._hh_monarch_escape_latched = nil
        return old_on_destroy ~= nil and old_on_destroy(screen, ...) or nil
    end
end)
end

local function ufguucgKu()
    local gFcUcCnKg = {}
    gFcUcCnKg["duckpack"] = {
        widget = {
            slotpos = {},
            animbank = "ui_krampusbag_2x8",
            animbuild = "ui_duck_2x7",
            pos = GLOBAL["Vector3"](-5, -90, 0)
        },
        issidewidget = (210 - 182 - 477 + 303 ~= -141),
        type = "pack"
    }
    for kffUkCnKk = 0, 6 do
        table["insert"](gFcUcCnKg["duckpack"]["widget"]["slotpos"], GLOBAL["Vector3"](-163, -74 * kffUkCnKk + 208, 0))
        table["insert"](
            gFcUcCnKg["duckpack"]["widget"]["slotpos"],
            GLOBAL["Vector3"](-163 + 75, -74 * kffUkCnKk + 208, 0)
        )
    end
    gFcUcCnKg["backcub"] = {
        widget = {
            slotpos = {},
            animbank = "ui_krampusbag_2x8",
            animbuild = "ui_pack_2x7",
            pos = GLOBAL["Vector3"](-5, -120, 0)
        },
        issidewidget = (true or not false and false and false and false or true and not true and false or not false or
            true and not false and not false and true and false),
        type = "pack"
    }
    for gFfuuckKn = 0, 6 do
        table["insert"](gFcUcCnKg["backcub"]["widget"]["slotpos"], GLOBAL["Vector3"](-162, -75 * gFfuuckKn + 240, 0))
        table["insert"](
            gFcUcCnKg["backcub"]["widget"]["slotpos"],
            GLOBAL["Vector3"](-162 + 75, -75 * gFfuuckKn + 240, 0)
        )
    end
    local iffUfckki = GLOBAL["require"] "containers"
    iffUfckki["MAXITEMSLOTS"] =
        math["max"](
        iffUfckki["MAXITEMSLOTS"],
        gFcUcCnKg["duckpack"]["widget"]["slotpos"] ~= nil and #gFcUcCnKg["duckpack"]["widget"]["slotpos"] or 0
    )
    iffUfckki["MAXITEMSLOTS"] =
        math["max"](
        iffUfckki["MAXITEMSLOTS"],
        gFcUcCnKg["backcub"]["widget"]["slotpos"] ~= nil and #gFcUcCnKg["backcub"]["widget"]["slotpos"] or 0
    )
    local kffuicnKg = iffUfckki["widgetsetup"]
    function iffUfckki.widgetsetup(nFuuicckn, ifcUkciKg, cfcukCfKf)
        local kFuUcCfkk = ifcUkciKg or nFuuicckn["inst"]["prefab"]
        if kFuUcCfkk == "duckpack" or kFuUcCfkk == "backcub" then
            local nFfUcccKk = gFcUcCnKg[kFuUcCfkk]
            if nFfUcccKk ~= nil then
                for uFiugCukn, fFuufcgkc in pairs(nFfUcccKk) do
                    nFuuicckn[uFiugCukn] = fFuufcgkc
                end
                nFuuicckn:SetNumSlots(nFuuicckn["widget"]["slotpos"] ~= nil and #nFuuicckn["widget"]["slotpos"] or 0)
            end
        else
            return kffuicnKg(nFuuicckn, ifcUkciKg)
        end
    end
end
ufguucgKu()
local nffUgCgkk = GLOBAL["STRINGS"]
local cfcugCckg = GLOBAL["require"]
local ifgUgCfkg = GLOBAL["FOODTYPE"]
local gfnufCnkf = GLOBAL["FOODGROUP"]
local gFgUiCgkg = GLOBAL["Vector3"]
local fFiUncckf = cfcugCckg("containers")
local ifuuickkf = GLOBAL["TECH"]
local kffugcckc = GLOBAL["TheWorld"]
local kFkugCukk = {}
local kfnUcCnKg = fFiUncckf["widgetsetup"] or function()
        return (401 + 260 + 381 ~= 1047)
    end
function fFiUncckf.widgetsetup(ffkUucnKu, nFiUucuKu, ffuuucukn, ...)
    local ifkUccfkf = nFiUucuKu or ffkUucnKu["inst"]["prefab"]
    if ifkUccfkf == "nn_icebox" then
        local ffgUfcnki = kFkugCukk[ifkUccfkf]
        if ffgUfcnki ~= nil then
            for gFkufCfki, fFfUnCkKu in pairs(ffgUfcnki) do
                ffkUucnKu[gFkufCfki] = fFfUnCkKu
            end
            ffkUucnKu:SetNumSlots(ffkUucnKu["widget"]["slotpos"] ~= nil and #ffkUucnKu["widget"]["slotpos"] or 0)
        end
    else
        return kfnUcCnKg(ffkUucnKu, nFiUucuKu, ffuuucukn, ...)
    end
end
kFkugCukk["nn_icebox"] = {
    widget = {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "UI_Musha_4x4",
        pos = gFgUiCgkg(-15, 200, 0),
        side_align_tip = 160
    },
    type = "chest"
}
for cfuuccgKf = 3, 0, -1 do
    for gfcuuciKi = 0, 3 do
        table["insert"](
            kFkugCukk["nn_icebox"]["widget"]["slotpos"],
            gFgUiCgkg(75 * gfcuuciKi - 78, 75 * cfuuccgKf - 130, 0)
        )
    end
end
function kFkugCukk.nn_icebox.itemtestfn(iFiUfciku, cFgUkCnKk, kFfUgcikc)
    if cFgUkCnKk:HasTag("icebox_valid") then
        return (250 - 368 + 314 == 196)
    end
    if not (cFgUkCnKk:HasTag("fresh") or cFgUkCnKk:HasTag("stale") or cFgUkCnKk:HasTag("spoiled")) then
        return (144 * 57 + 158 == 8372)
    end
    for nfcukCnKu, nfcukcikc in pairs(ifgUgCfkg) do
        if cFgUkCnKk:HasTag("edible_" .. nfcukcikc) then
            return (false and false and false and not false and false and false and false and not true and false and
                false and
                false or
                not false or
                not false or
                false)
        end
    end
    return (false and not true and not false or not false and false or true and true and not true and false and false)
end
for uFfukCnkf, kFgUgCnkf in pairs(kFkugCukk) do
    fFiUncckf["MAXITEMSLOTS"] =
        math["max"](
        fFiUncckf["MAXITEMSLOTS"],
        kFgUgCnkf["widget"]["slotpos"] ~= nil and #kFgUgCnkf["widget"]["slotpos"] or 0
    )
end
local fFiUncckf = cfcugCckg("containers")
local kFkugCukk = fFiUncckf["params"]
kFkugCukk["nn_well"] = {
    widget = {slotpos = {}, animbank = "ui_fish_box_5x4", animbuild = "ui_fish_box_5x4", pos = gFgUiCgkg(0, 220, 0)},
    type = "chest",
    itemtestfn = function(ifnufcikc, ffuucccKi, cfkUucukg)
        return ffuucccKi:HasTag("pondfish") and ffuucccKi:HasTag("fish")
    end
}
for ffcuncuKu = 2.5, -0.5, -1 do
    for kfnufcfkg = -1, 3 do
        table["insert"](
            kFkugCukk["nn_well"]["widget"]["slotpos"],
            gFgUiCgkg(75 * kfnufcfkg - 75 * 2 + 75, 75 * ffcuncuKu - 75 * 2 + 75, 0)
        )
    end
end
fFiUncckf["MAXITEMSLOTS"] =
    math["max"](
    fFiUncckf["MAXITEMSLOTS"],
    kFkugCukk["nn_well"]["slotpos"] ~= nil and #kFkugCukk["nn_well"]["widget"]["slotpos"] or 0
)
kFkugCukk["hh_hac_nguyet_ho"] = {
    widget = {slotpos = {}, animbank = "ui_fish_box_5x4", animbuild = "ui_fish_box_5x4", pos = gFgUiCgkg(0, 220, 0)},
    type = "chest",
    itemtestfn = function(ifnufcikc, ffuucccKi, cfkUucukg)
        return HHacNguyetHoItems.IsAllowed(ffuucccKi) and
            HHacNguyetHoItems.CanUseStackTarget(ifnufcikc, ffuucccKi, cfkUucukg)
    end
}
for ffcuncuKu = 2.5, -0.5, -1 do
    for kfnufcfkg = -1, 3 do
        table["insert"](
            kFkugCukk["hh_hac_nguyet_ho"]["widget"]["slotpos"],
            gFgUiCgkg(75 * kfnufcfkg - 75 * 2 + 75, 75 * ffcuncuKu - 75 * 2 + 75, 0)
        )
    end
end
fFiUncckf["MAXITEMSLOTS"] =
    math["max"](
    fFiUncckf["MAXITEMSLOTS"],
    #kFkugCukk["hh_hac_nguyet_ho"]["widget"]["slotpos"]
)
local ifgunCfkk = cfcugCckg("utils/hh_utils")
local kfnugciki = true -- Cố định ẩn tooltip gốc.
local cFiunCfKn = cfcugCckg("enums/hh_enchant")

if not GLOBAL["TheNet"]:IsDedicated() then
    local ELEMENTBEAD_GOGGLES_SOURCE_TAG = "hh_elementbead_goggles_source"
    local EQUIPSLOTS = GLOBAL["EQUIPSLOTS"]

    local function ShouldSuppressElementBeadGoggleOverlay(owner)
        if owner == nil then
            return false
        end

        local components = owner["components"]
        local playervision = components ~= nil and components["playervision"] or nil
        if playervision ~= nil and playervision["forcegogglevision"] then
            return false
        end

        local replica = owner["replica"]
        local inventory = replica ~= nil and replica["inventory"] or nil
        if inventory == nil or inventory["GetEquippedItem"] == nil or EQUIPSLOTS == nil then
            return false
        end

        local has_elementbead_goggles = false
        local has_other_goggles = false
        for _, slot in pairs(EQUIPSLOTS) do
            local item = inventory:GetEquippedItem(slot)
            if item ~= nil and item:HasTag "goggles" then
                if item:HasTag(ELEMENTBEAD_GOGGLES_SOURCE_TAG) then
                    has_elementbead_goggles = true
                else
                    has_other_goggles = true
                end
            end
        end

        return has_elementbead_goggles and not has_other_goggles
    end

    local function RefreshElementBeadGoggleOverlay(widget)
        if widget["shown"] and widget["bg"] ~= nil then
            if ShouldSuppressElementBeadGoggleOverlay(widget["owner"]) then
                widget["bg"]:Hide()
            else
                widget["bg"]:Show()
            end
        end
    end

    AddClassPostConstruct("widgets/gogglesover", function(self)
        local old_toggle_goggles = self["ToggleGoggles"]

        self["ToggleGoggles"] = function(widget, show, ...)
            local result = old_toggle_goggles(widget, show, ...)
            RefreshElementBeadGoggleOverlay(widget)
            return result
        end

        if self["owner"] ~= nil and self["inst"] ~= nil then
            local function on_inventory_changed()
                RefreshElementBeadGoggleOverlay(self)
            end

            self["inst"]:ListenForEvent("equip", on_inventory_changed, self["owner"])
            self["inst"]:ListenForEvent("unequip", on_inventory_changed, self["owner"])
            self["inst"]:ListenForEvent("inventoryclosed", on_inventory_changed, self["owner"])
        end

        RefreshElementBeadGoggleOverlay(self)
    end)
end

local kFfufciKi = cFiunCfKn["HH_EQUIP_BUFF_LIST"]
local gFiunCkKk = cFiunCfKn["HH_SUIT_LIST"]
local fFiUncckf = cfcugCckg("containers")
local cfkucckKk = {}
local gfcunCnKg = -17
local kFguicikk = 0
local cFuUncgkk = {["hh_cat_box"] = {["button_fn"] = function(nFkUfCnkk, uFguuCgki)
            local cFcUfCcKn = nFkUfCnkk["components"]["container"]
            local uFgucCuKi = cFcUfCcKn:GetNumSlots()
            local fffuicgKi = 0
            local iFnunCgku = 0
            local fFuufcgKg = 0
            local iffUfCgKk = HHGetComEquipEffect()
            for fFcUfccKu = 1, uFgucCuKi do
                local kfiUfCcku = 0
                local fFfUccuKi = cFcUfCcKn:GetItemInSlot(fFcUfccKu)
                if fFfUccuKi and fFfUccuKi["prefab"] == "hh_effect_stone" then
                    local gFgUnccKk = fFfUccuKi["hh_effect"]
                    if gFgUnccKk == nil or table["contains"](iffUfCgKk, gFgUnccKk) then
                        kfiUfCcku = 1
                    else
                        kfiUfCcku = 5
                    end
                    fFfUccuKi:Remove()
                    fFuufcgKg = fFuufcgKg + 1
                end
                fffuicgKi = fffuicgKi + kfiUfCcku
            end
            if fffuicgKi <= 0 then
                ifgunCfkk:HHSay(uFguuCgki, "Ko tìm thấy Đá Thuộc Tính hợp lệ")
                return
            end
            iFnunCgku = fffuicgKi
            repeat
                local fffUgCgKn = SpawnPrefab("hh_essence")
                if fffuicgKi <= TUNING["STACK_SIZE_SMALLITEM"] then
                    fffUgCgKn["components"]["stackable"]:SetStackSize(math["max"](fffuicgKi, 1))
                else
                    fffUgCgKn["components"]["stackable"]:SetStackSize(TUNING["STACK_SIZE_SMALLITEM"])
                end
                fffuicgKi = fffuicgKi - TUNING["STACK_SIZE_SMALLITEM"]
                if nFkUfCnkk["components"]["container"]:IsFull() then
                    uFguuCgki["components"]["inventory"]:GiveItem(fffUgCgKn)
                else
                    local uFuunCkkn = nFkUfCnkk:GetPosition()
                    nFkUfCnkk["components"]["container"]:GiveItem(fffUgCgKn, nil, uFuunCkkn)
                end
            until fffuicgKi <= 0
            ifgunCfkk:HHSay(
                uFguuCgki,
                string["format"]("Tiêu thụ %s Đá Thuộc Tính, Đã chuyển đổi: %s", fFuufcgKg, iFnunCgku)
            )
        end}, ["hh_duck_box"] = {["button_fn"] = function(kFfUkCiku, kFgukCiKf)
            local kfkugcgKk = kFfUkCiku["components"]["container"]
            local nFuuncnKn = kfkugcgKk:GetItemInSlot(1)
            if nFuuncnKn and ifgunCfkk:HasComponents(nFuuncnKn, "tradable") then
                local iFnuuCkkn = nFuuncnKn["components"]["tradable"]
                if ifgunCfkk:IsHHType(iFnuuCkkn["goldvalue"], "number") and iFnuuCkkn["goldvalue"] > 0 then
                    local gfiufCuki = iFnuuCkkn["goldvalue"]
                    local gfkUkCnKk = gfiufCuki
                    if ifgunCfkk:HasComponents(nFuuncnKn, "stackable") then
                        local nFuUgCgKc = nFuuncnKn["components"]["stackable"]:StackSize()
                        if ifgunCfkk:IsHHType(nFuUgCgKc, "number") and nFuUgCgKc > 0 then
                            gfkUkCnKk = nFuUgCgKc * gfiufCuki
                        end
                    end
                    nFuuncnKn:Remove()
                    local gfkunCuku = SpawnPrefab("goldnugget")
                    if gfkunCuku and ifgunCfkk:HasComponents(gfkunCuku, "stackable") then
                        local cFuUkcukf = kFfUkCiku:GetPosition()
                        gfkunCuku["components"]["stackable"]:SetStackSize(gfkUkCnKk)
                        kFfUkCiku["components"]["container"]:GiveItem(gfkunCuku, nil, cFuUkcukf)
                        ifgunCfkk:HHSay(kFgukCiKf, string["format"]("Đổi vàng: %s", tostring(gfkUkCnKk)))
                    end
                    return
                end
            end
            ifgunCfkk:HHSay(kFgukCiKf, "Hãy bỏ vào những vật phẩm có thể đổi lấy vàng")
        end}}
local function gfiuncnKc(nFiuuCgkn, ufiufckKc)
    if ifgunCfkk:HasComponents(nFiuuCgkn, "container") then
        if cFuUncgkk[nFiuuCgkn["prefab"]] and cFuUncgkk[nFiuuCgkn["prefab"]]["button_fn"] then
            cFuUncgkk[nFiuuCgkn["prefab"]]["button_fn"](nFiuuCgkn, ufiufckKc)
        end
    elseif ifgunCfkk:HasReplica(nFiuuCgkn, "container") then
        SendRPCToServer(RPC["DoWidgetButtonAction"], nil, nFiuuCgkn, nil)
    end
end
cFuUncgkk[MONARCH_STORAGE_PREFAB] = {
    ["button_fn"] = function(container, doer)
        if container["components"]["container"] ~= nil then
            container["components"]["container"]:Close(doer)
        end
    end,
}
local function kfcucCfkf(ffuUgCckg)
    return ffuUgCckg["replica"]["container"] ~= nil and not ffuUgCckg["replica"]["container"]:IsEmpty()
end
cfkucckKk["hh_ui_container"] = {
    widget = {
        slotpos = {
            gFgUiCgkg(-247 + kFguicikk, 160 + gfcunCnKg, 0),
            gFgUiCgkg(-202 + kFguicikk, 160 + gfcunCnKg, 0),
            gFgUiCgkg(-157 + kFguicikk, 160 + gfcunCnKg, 0),
            gFgUiCgkg(-112 + kFguicikk, 160 + gfcunCnKg, 0),
            gFgUiCgkg(-247 + kFguicikk, 115 + gfcunCnKg, 0),
            gFgUiCgkg(-202 + kFguicikk, 115 + gfcunCnKg, 0),
            gFgUiCgkg(-157 + kFguicikk, 115 + gfcunCnKg, 0),
            gFgUiCgkg(-112 + kFguicikk, 115 + gfcunCnKg, 0),
            gFgUiCgkg(-247 + kFguicikk, 70 + gfcunCnKg, 0),
            gFgUiCgkg(-202 + kFguicikk, 70 + gfcunCnKg, 0),
            gFgUiCgkg(-157 + kFguicikk, 70 + gfcunCnKg, 0),
            gFgUiCgkg(-112 + kFguicikk, 70 + gfcunCnKg, 0),
            gFgUiCgkg(-247 + kFguicikk, 25 + gfcunCnKg, 0),
            gFgUiCgkg(-202 + kFguicikk, 25 + gfcunCnKg, 0),
            gFgUiCgkg(-157 + kFguicikk, 25 + gfcunCnKg, 0),
            gFgUiCgkg(-112 + kFguicikk, 25 + gfcunCnKg, 0),
            gFgUiCgkg(-247 + kFguicikk, -20 + gfcunCnKg, 0),
            gFgUiCgkg(-202 + kFguicikk, -20 + gfcunCnKg, 0),
            gFgUiCgkg(-157 + kFguicikk, -20 + gfcunCnKg, 0),
            gFgUiCgkg(-112 + kFguicikk, -20 + gfcunCnKg, 0),
            gFgUiCgkg(-247 + kFguicikk, -65 + gfcunCnKg, 0),
            gFgUiCgkg(-202 + kFguicikk, -65 + gfcunCnKg, 0),
            gFgUiCgkg(-157 + kFguicikk, -65 + gfcunCnKg, 0),
            gFgUiCgkg(-112 + kFguicikk, -65 + gfcunCnKg, 0),
            gFgUiCgkg(10 + kFguicikk, 170 + gfcunCnKg, 0),
            gFgUiCgkg(60 + kFguicikk, 170 + gfcunCnKg, 0),
            gFgUiCgkg(110 + kFguicikk, 170 + gfcunCnKg, 0),
            gFgUiCgkg(250 + kFguicikk, 10 + gfcunCnKg, 0)
        },
        slotbg = {},
        pos = gFgUiCgkg(0, 0, 0)
    },
    type = "chest"
}
cfkucckKk["hh_ui_container"]["itemtestfn"] = function(nffunCkkn, ffuUcCcki, nFfUgCkki)
    local cFiucCfKn = (328 - 274 * 8 - 380 - 433 ~= -2677)
    if nFfUgCkki then
        if nFfUgCkki <= 24 then
            cFiucCfKn =
                (ffuUcCcki["replica"] and ffuUcCcki["replica"]["equippable"] and ffuUcCcki:HasTag("hh_equip")) or
                ffuUcCcki:HasTag("hh_add_stone") or
                ffuUcCcki:HasTag("hh_remove_stone")
        elseif nFfUgCkki == 25 then
            cFiucCfKn = ffuUcCcki:HasTag("hh_equip")
        elseif nFfUgCkki == 26 then
            cFiucCfKn = ffuUcCcki:HasTag("hh_add_stone")
        elseif nFfUgCkki == 27 then
            cFiucCfKn = ffuUcCcki:HasTag("hh_remove_stone")
        else
            cFiucCfKn = ffuUcCcki:HasTag("hh_equip")
        end
    else
        cFiucCfKn =
            (ffuUcCcki["replica"] and ffuUcCcki["replica"]["equippable"] and ffuUcCcki:HasTag("hh_equip")) or
            ffuUcCcki:HasTag("hh_add_stone") or
            ffuUcCcki:HasTag("hh_remove_stone")
    end
    return cFiucCfKn
end
local fFfukCfKn = 60
local iFnufCuKc = 0
local ufiunCfKc = 10
cfkucckKk["hh_forge_container"] = {
    widget = {
        slotpos = {
            gFgUiCgkg(-250, 150, 0),
            gFgUiCgkg(iFnufCuKc - fFfukCfKn * 3, ufiunCfKc, 0),
            gFgUiCgkg(iFnufCuKc - fFfukCfKn * 2, ufiunCfKc, 0),
            gFgUiCgkg(iFnufCuKc - fFfukCfKn, ufiunCfKc, 0),
            gFgUiCgkg(iFnufCuKc, ufiunCfKc, 0)
        },
        slotbg = {},
        pos = gFgUiCgkg(0, 0, 0)
    },
    type = "chest"
}
cfkucckKk["hh_forge_container"].itemtestfn = require("utils/ttk_forge_rules").ItemTest
cfkucckKk["hh_cat_box"] = {
    ["widget"] = {
        ["slotpos"] = {},
        ["animbank"] = "ui_bookstation_4x5",
        ["animbuild"] = "ui_bookstation_4x5",
        ["pos"] = gFgUiCgkg(-200, 100, 0),
        ["side_align_tip"] = 160,
        ["buttoninfo"] = {
            ["text"] = "Đổi",
            ["position"] = gFgUiCgkg(0, -350, 0),
            ["fn"] = gfiuncnKc,
            ["validfn"] = kfcucCfkf
        }
    },
    ["type"] = "hh_cat_box"
}
for fFuufckkf = 0, 4 do
    table["insert"](
        cfkucckKk["hh_cat_box"]["widget"]["slotpos"],
        gFgUiCgkg(-114, (-77 * fFuufckkf) + 37 - (fFuufckkf * 2), 0)
    )
    table["insert"](
        cfkucckKk["hh_cat_box"]["widget"]["slotpos"],
        gFgUiCgkg(-114 + 75, (-77 * fFuufckkf) + 37 - (fFuufckkf * 2), 0)
    )
    table["insert"](
        cfkucckKk["hh_cat_box"]["widget"]["slotpos"],
        gFgUiCgkg(-114 + 150, (-77 * fFuufckkf) + 37 - (fFuufckkf * 2), 0)
    )
    table["insert"](
        cfkucckKk["hh_cat_box"]["widget"]["slotpos"],
        gFgUiCgkg(-114 + 225, (-77 * fFuufckkf) + 37 - (fFuufckkf * 2), 0)
    )
end
local nFfuncukf = {
    ["hh_remove_stone"] = (90 - 164 - 280 == -354),
    ["hh_effect_tally"] = (93 + 488 - 113 - 237 == 231),
    ["hh_effect_stone"] = (289 * 374 - 49 ~= 108046),
    ["hh_essence"] = (179 - 183 + 461 - 70 ~= 392)
}
cfkucckKk["hh_cat_box"]["itemtestfn"] = function(kFiuncnku, ifuUkCikf, ufiUgcckn)
    return ifuUkCikf and (nFfuncukf[ifuUkCikf["prefab"]] or ifuUkCikf:HasTag("hh_add_stone")) or
        (456 + 343 * 359 * 231 ~= 28445103)
end
cfkucckKk["hh_duck_box"] = {
    ["widget"] = {
        ["slotpos"] = {gFgUiCgkg(-2, 18, 0)},
        ["slotbg"] = {{["image"] = "yotb_sewing_slot.tex", ["atlas"] = "images/hud2.xml"}},
        ["animbank"] = "ui_antlionhat_1x1",
        ["animbuild"] = "ui_antlionhat_1x1",
        ["pos"] = gFgUiCgkg(0, -200, 0),
        ["side_align_tip"] = 160,
        ["buttoninfo"] = {
            ["text"] = "Đổi",
            ["position"] = gFgUiCgkg(0, -40, 0),
            ["fn"] = gfiuncnKc,
            ["validfn"] = kfcucCfkf
        },
        ["hh_extra_btn"] = {
            {
                ["text"] = "Đổi",
                ["pos"] = gFgUiCgkg(-200, -100, 0),
                ["fn_index"] = "test_01",
                ["xml"] = "images/inventoryimages.xml",
                ["tex"] = "halloweenpotion_health_large.tex",
                ["focus_tex"] = "baconeggs.tex",
                ["check_fn"] = function()
                    return (129 - 287 - 28 ~= -186)
                end
            },
            {["text"] = "Đổi", ["pos"] = gFgUiCgkg(-100, -100, 0), ["fn_index"] = "test_02", ["check_fn"] = function()
                    return (285 - 409 - 490 ~= -614)
                end},
            {["text"] = "ccc", ["pos"] = gFgUiCgkg(0, -100, 0), ["fn_index"] = "test_03", ["check_fn"] = function()
                    return (174 - 351 - 88 - 474 == -733)
                end},
            {["text"] = "ddd", ["pos"] = gFgUiCgkg(100, -100, 0), ["fn_index"] = "fn", ["check_fn"] = function()
                    return (171 - 473 - 169 * 498 ~= -84464)
                end}
        }
    },
    ["type"] = "hh_duck_box"
}
cfkucckKk["hh_duck_box"]["itemtestfn"] = function(gFiUkckKk, nFfUgckKu, gFuUnCnku)
    if nFfUgckKu and nFfUgckKu["replica"] then
        return not nFfUgckKu["replica"]["container"]
    end
    return (257 + 255 + 72 ~= 589)
end
local kfgUfCkkn = {
    ["hh_remove_stone"] = (420 - 400 + 492 + 359 == 871),
    ["hh_effect_tally"] = (370 - 481 * 379 == -181929),
    ["hh_effect_stone"] = (403 - 132 + 91 == 362),
    ["gears"] = (211 * 117 + 385 - 19 - 18 == 25035),
    ["horn"] = (false or false and false and not true and true or not false and not false and not false and not false),
    ["greengem"] = (63 * 300 * 345 - 338 - 105 ~= 6520063),
    ["walrus_tusk"] = (461 + 123 - 383 * 468 * 158 == -28319968),
    ["redgem"] = (439 + 207 - 44 ~= 605),
    ["lightninggoathorn"] = (458 * 451 * 381 * 281 - 471 == 22114305567),
    ["silk"] = (399 * 175 + 41 + 21 * 470 ~= 79745),
    ["stinger"] = (342 - 356 - 412 ~= -423),
    ["townportaltalisman"] = (153 + 246 + 259 - 136 * 123 ~= -16067),
    ["steelwool"] = (456 * 357 + 26 - 361 + 339 ~= 162805),
    ["dragon_scales"] = (344 - 395 - 360 == -411),
    ["minotaurhorn"] = (false and not false or not false or not false and false and not true or false or not false or
        false and false and true),
    ["deerclops_eyeball"] = (false and false and not true or false and not true and not false or not false or
        false and not false or
        not false and not false or
        not false and not false or
        not true)
}
cfkucckKk["hh_quat_long_vu"] = {
    ["widget"] = {
        ["slotpos"] = {gFgUiCgkg(-2, 18, 0)},
        ["slotbg"] = {{["image"] = "spore_slot.tex", ["atlas"] = "images/hud2.xml"}},
        ["animbank"] = "ui_antlionhat_1x1",
        ["animbuild"] = "ui_antlionhat_1x1",
        ["pos"] = gFgUiCgkg(0, -200, 0),
        ["side_align_tip"] = 160
    },
    ["type"] = "hh_quat_long_vu",
    ["excludefromcrafting"] = (243 - 355 + 105 ~= -3)
}
cfkucckKk["hh_quat_long_vu"]["itemtestfn"] = function(gffufCfKc, fFiUkCgkc, kFnUucckg)
    return fFiUkCgkc and kfgUfCkkn[fFiUkCgkc["prefab"]] or (317 * 177 + 150 + 11 ~= 56270)
end
for kfuukCnKk, uFiugcnKg in pairs(cfkucckKk) do
    fFiUncckf["MAXITEMSLOTS"] =
        math["max"](
        fFiUncckf["MAXITEMSLOTS"],
        uFiugcnKg["widget"]["slotpos"] ~= nil and #uFiugcnKg["widget"]["slotpos"] or 0
    )
end
local iFuukCnKf = fFiUncckf["widgetsetup"]
function fFiUncckf.widgetsetup(ffuuuCfku, ufuuicikc, kFiUfCnKu)
    local iffugCnKg = kFiUfCnKu or cfkucckKk[ufuuicikc or ffuuuCfku["inst"]["prefab"]]
    if iffugCnKg ~= nil then
        for ufgUkcfkn, ifnUfCnKn in pairs(iffugCnKg) do
            ffuuuCfku[ufgUkcfkn] = ifnUfCnKn
        end
        ffuuuCfku:SetNumSlots(ffuuuCfku["widget"]["slotpos"] ~= nil and #ffuuuCfku["widget"]["slotpos"] or 0)
    else
        return iFuukCnKf(ffuuuCfku, ufuuicikc, kFiUfCnKu)
    end
end
local function iFuUccfkf(nFkUfCuku)
    local gFkuncgkn = string["gsub"](nFkUfCuku, "%s+$", "")
    return gFkuncgkn
end
local nfkukccKk = cfcugCckg("widgets/image")
local kFiUuCnKk = cfcugCckg("widgets/hh_hoverer")
local ufuUgCnKf = cfcugCckg("widgets/hh_buff")
AddClassPostConstruct(
    "widgets/controls",
    function(self, ffuuncgkn)
        self["hh_com_buff"] = self:AddChild(ufuUgCnKf(self["owner"]))
        self["hh_com_buff"]:SetPosition(250, -50)
        self["inst"]:ListenForEvent(
            "hh_poison_ui",
            function(ffkUuCnKg, gfgugCgKn)
                ifgunCfkk:HHKillChild(self, "hh_poison_ui")
                self["hh_poison_ui"] = self:AddChild(nfkukccKk("images/fx2.xml", "fume_over.tex"))
                self["hh_poison_ui"]:SetVRegPoint(ANCHOR_MIDDLE)
                self["hh_poison_ui"]:SetHRegPoint(ANCHOR_MIDDLE)
                self["hh_poison_ui"]:SetVAnchor(ANCHOR_MIDDLE)
                self["hh_poison_ui"]:SetHAnchor(ANCHOR_MIDDLE)
                self["hh_poison_ui"]:SetScaleMode(SCALEMODE_FILLSCREEN)
                self["hh_poison_ui"]:SetTint(1, 1, 1, 0.3)
                self["hh_poison_ui"]:SetClickable(
                    (false or not false and false and false and not false and false and not false or
                        false and false and not false and not true or
                        not true and false)
                )
                self["hh_poison_ui"]:TintTo(
                    {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 0.3},
                    {["r"] = 1, ["g"] = 1, ["b"] = 1, ["a"] = 0},
                    4,
                    function()
                        ifgunCfkk:HHKillChild(self, "hh_poison_ui")
                    end
                )
            end,
            self["owner"]
        )
        self["inst"]:ListenForEvent(
            "hh_black_player",
            function(nfkUnCfKg, ufiufciki)
                ifgunCfkk:HHKillChild(self, "hh_black_ui")
                self["hh_black_ui"] = self:AddChild(nfkukccKk("images/fx2.xml", "fume_over.tex"))
                self["hh_black_ui"]:SetVRegPoint(ANCHOR_MIDDLE)
                self["hh_black_ui"]:SetHRegPoint(ANCHOR_MIDDLE)
                self["hh_black_ui"]:SetVAnchor(ANCHOR_MIDDLE)
                self["hh_black_ui"]:SetHAnchor(ANCHOR_MIDDLE)
                self["hh_black_ui"]:SetScaleMode(SCALEMODE_FILLSCREEN)
                self["hh_black_ui"]:SetTint(0, 0, 0, 1)
                local ffnucCnkc = ifgunCfkk:GetClientValue(self["owner"], "hh_black_player")
                self["hh_black_ui"]["hh_str"] =
                    ifgunCfkk:HHCreateTextUi(self["hh_black_ui"], gFgUiCgkg(0, 100, 1), tostring(ffnucCnkc), nil, 40)
                self["hh_black_ui"]["hh_button"] =
                    ifgunCfkk:HHCreateImageButton(
                    self["hh_black_ui"],
                    "images/hh_icon/hh_white.xml",
                    "hh_white.tex",
                    gFgUiCgkg(0, -100, 1),
                    10,
                    5
                )
                self["hh_black_ui"]["hh_button"]["hh_str"] =
                    ifgunCfkk:HHCreateTextUi(self["hh_black_ui"]["hh_button"], gFgUiCgkg(0, 0, 1), "Thoát", nil, 30)
                self["hh_black_ui"]["hh_button"]["hh_str"]:SetClickable((13 * 222 + 139 == 3033))
                self["hh_black_ui"]["hh_button"]:SetOnClick(
                    function()
                        DoRestart((444 * 483 * 283 - 468 == 60689448))
                    end
                )
                ifgunCfkk:ExitGame(10)
            end,
            self["owner"]
        )
    end
)
local function iFnUfckki()
    local iffUgCfkg = TheInput:GetHUDEntityUnderMouse()
    iffUgCfkg =
        (iffUgCfkg and iffUgCfkg["widget"] and iffUgCfkg["widget"]["parent"] ~= nil and
        iffUgCfkg["widget"]["parent"]["item"]) or
        TheInput:GetWorldEntityUnderMouse() or
        nil
    return iffUgCfkg
end
local function kFfuiciKk(self)
    self["hh_hoverer"] = self:AddChild(kFiUuCnKk(self["owner"]))
    local cFfUkCgKi = self["OnUpdate"]
    self["OnUpdate"] = function(self, ...)
        cFfUkCgKi(self, ...)
        if self["hh_hoverer"] and self["hh_hoverer"]["SetTargetName"] then
            if self["text"] and self["text"]["Hide"] then
                if self["text"]["shown"] then
                    local cfcucCukn = "Tên"
                    if self["hh_hoverer"]["hh_main"] and self["hh_hoverer"]["hh_main"]["shown"] and kfnugciki then
                        self["text"]:Hide()
                    end
                    if self["text"]["GetString"] then
                        cfcucCukn = iFuUccfkf(tostring(self["text"]:GetString()))
                    end
                    if self["secondarytext"] and self["secondarytext"]["Hide"] and self["secondarystr"] then
                        local kFuUgckKf = tostring(self["secondarystr"])
                        cfcucCukn = cfcucCukn .. "\n" .. iFuUccfkf(kFuUgckKf)
                        if self["hh_hoverer"]["hh_main"] and self["hh_hoverer"]["hh_main"]["shown"] and kfnugciki then
                            self["secondarytext"]:Hide()
                        end
                    end
                    self["hh_hoverer"]:SetTargetName(cfcucCukn)
                end
            end
        end
    end
end
AddClassPostConstruct("widgets/hoverer", kFfuiciKk)
local iFnUuCuki = GetModConfigData("can_show_equip")
local function nFuUccgkf(self)
    if self["image"] and self["image"]["itemtile_lightning"] then
        ifgunCfkk:HHKillChild(self["image"], "itemtile_lightning")
    end
    if
        self["item"] and self["item"]["prefab"] and self["item"]["prefab"] == "hh_effect_stone" and
            self["item"]["hh_client_effect"]
     then
        local nfnugccki = self["item"]["hh_client_effect"]:value()
        if kFfufciKi[nfnugccki] then
            local iFgugCkKu = kFfufciKi[nfnugccki]
            if iFgugCkKu["client_text"] then
                local iFcUccckc = iFgugCkKu["client_text"]
                self["hh_effect_text"] =
                    ifgunCfkk:HHCreateTextUi(
                    self,
                    gFgUiCgkg(0, 0, 1),
                    tostring(iFcUccckc),
                    {1, 1, 1, 1},
                    40,
                    (199 - 339 + 424 + 209 ~= 498)
                )
                local cfiUgciKf, gFcukcgKu = self["hh_effect_text"]:GetRegionSize()
                self["hh_effect_text"]:SetPosition(-32 + cfiUgciKf / 2, -32 + gFcukcgKu / 2, 0)
                self["hh_effect_text"]:SetClickable((246 - 440 * 11 * 137 - 354 == -663178))
            end
            local kfnUgCcki = {128 / 255, 138 / 255, 135 / 255, 1}
            if iFgugCkKu["client_color"] then
                kfnUgCcki = iFgugCkKu["client_color"]
            elseif not iFgugCkKu["can_add"] and not iFgugCkKu["is_suit"] then
                kfnUgCcki = {255 / 255, 150 / 255, 0 / 255, 1}
            end
            self["hh_suit_ui"] =
                ifgunCfkk:HHCreateImageUi(
                self,
                "images/hh_icon/hh_status.xml",
                "hh_status.tex",
                gFgUiCgkg(0, 0, 1),
                64,
                64,
                kfnUgCcki
            )
            self["hh_suit_ui"]:SetClickable((260 + 146 * 347 ~= 50922))
            self["hh_suit_ui"]:MoveToBack()
            local nFnUncfkk = self["StartDrag"]
            self["StartDrag"] = function(...)
                if ifgunCfkk:HasReplica(self["item"], "inventoryitem") and self["hh_suit_ui"] then
                    ifgunCfkk:HHKillChild(self, "hh_suit_ui")
                end
                if nFnUncfkk then
                    nFnUncfkk(...)
                end
            end
        end
    end
    local cFiUkcikg = self["OnControl"]
    self["OnControl"] = function(uFfUgcfkg, nfuufcgkg, cfuUiCgkn, ...)
        if
            nfuufcgkg == CONTROL_ACCEPT and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and
                TheInput:IsControlPressed(CONTROL_FORCE_TRADE) and
                self["item"] and
                (self["item"]:HasTag("hh_equip") or self["item"]["prefab"] == "hh_effect_stone")
         then
            if iFnUuCuki then
                SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_share_equip"], self["item"])
            end
        end
        return cFiUkcikg(uFfUgcfkg, nfuufcgkg, cfuUiCgkn, ...)
    end
end
AddClassPostConstruct("widgets/itemtile", nFuUccgkf)
local function kFiugCkKi(self)
    if iFnUuCuki then
        local kFfUfciku = self["OnControl"]
        self["OnControl"] = function(nFguucnku, iFnUncukk, nffUicnki, ...)
            if
                iFnUncukk == CONTROL_ACCEPT and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT) and
                    TheInput:IsControlPressed(CONTROL_FORCE_TRADE)
             then
                if self["tile"] and self["tile"]["item"] and self["tile"]["item"]:HasTag("hh_equip") then
                    SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_share_equip"], self["tile"]["item"])
                end
            end
            return kFfUfciku(nFguucnku, iFnUncukk, nffUicnki, ...)
        end
    end
end
AddClassPostConstruct("widgets/equipslot", kFiugCkKi)
local nfnUfcuki = cfcugCckg("widgets/hh_ui/hh_equip_ui")
local ufuufCgKc = cfcugCckg("widgets/hh_ui/hh_forge_ui")
local ttkStorageUI = cfcugCckg("widgets/hh_ui/ttk_storage_ui")
local ifuUgcikc = {
    ["hh_ui_container"] = {["ui"] = nfnUfcuki, ["ui_id"] = "hh_equip_ui"},
    ["hh_forge_container"] = {["ui"] = ufuufCgKc, ["ui_id"] = "hh_equip_ui", ["scale"] = 0.7},
    [MONARCH_STORAGE_PREFAB] = {["ui"] = ttkStorageUI, ["ui_id"] = "ttk_storage_ui", ["scale"] = 0.82}
}
local function gFcUuckKi(self, uFfUucnkk)
    local fFgUccfKi = self["Open"]
    self["Open"] = function(self, ...)
        local owner = self["owner"]
        local container = select(1, ...)
        local prefab = container ~= nil and container["prefab"] or nil
        if TTKUnifiedRegistry.Get(owner) == nil and TTKNativeBridge.RejectCancelled(owner, prefab) then
            return
        end
        if HHGuideLock.IsOpen(owner) then
            return
        end
        if prefab ~= "hh_ui_container" and HHSummaryLock.IsOpen(owner) then
            return
        end
        if prefab == "hh_ui_container" then
            local existing_summary = HHSummaryLock.GetContainerWidget(owner)
            if existing_summary ~= nil and existing_summary ~= self then
                return
            end
        end
        local active_screen = TheFrontEnd ~= nil and TheFrontEnd:GetActiveScreen() or nil
        local unified_screen = TTKUnifiedRegistry.Get(owner)
        if active_screen ~= nil and active_screen ~= owner["HUD"] and active_screen ~= unified_screen then
            return
        end
        if unified_screen ~= nil and not unified_screen:WantsNativeContainer(prefab) then
            unified_screen:RejectNativeContainer(prefab)
            return
        end
        fFgUccfKi(self, ...)
        if prefab == MONARCH_STORAGE_PREFAB and owner ~= nil then
            owner.HHMonarchStorageOpen = true
        end
        if
            ifgunCfkk:HasReplica(self["container"], "container") and
                ifgunCfkk:IsHHType(ifuUgcikc[self["container"]["prefab"]], "table") and
                ifuUgcikc[self["container"]["prefab"]]["ui"] and
                ifuUgcikc[self["container"]["prefab"]]["ui_id"]
         then
            local ufnugCcki = ifuUgcikc[self["container"]["prefab"]]["ui"]
            local kfgukcfkf = ifuUgcikc[self["container"]["prefab"]]["ui_id"]
            local ffiuccfKf = ifuUgcikc[self["container"]["prefab"]]["scale"] or 0.5
            self:SetVAnchor(ANCHOR_MIDDLE)
            self:SetHAnchor(ANCHOR_MIDDLE)
            self:SetScaleMode(SCALEMODE_PROPORTIONAL)
            self[kfgukcfkf] = self:AddChild(ufnugCcki(self["owner"], self["container"]))
            self[kfgukcfkf]:MoveToBack()
            if self[kfgukcfkf].AttachContainerWidget then
                self[kfgukcfkf]:AttachContainerWidget(self)
            end
            if self["container"]["prefab"] == "hh_ui_container" then
                HHSummaryLock.CloseCompetingHudUi(self["owner"])
                HHSummaryLock.SetContainerWidget(self["owner"], self)
                HHSummaryLock.SetHudInputFocus(self["owner"], true)
            end
            if self["inv"] and ifgunCfkk:IsHHType(self["inv"], "table") then
                for kfuUgCuKc, iFguccgKc in ipairs(self["inv"]) do
                    local ui = self[kfgukcfkf]
                    local ffiuccfKf = ui.GetSlotScale and ui:GetSlotScale(kfuUgCuKc) or ffiuccfKf
                    if self["inv"][kfuUgCuKc] and self["inv"][kfuUgCuKc]["SetScale"] then
                        if self["inv"][kfuUgCuKc]["ScaleTo"] then
                            self["inv"][kfuUgCuKc]:ScaleTo(ffiuccfKf * 0.5, ffiuccfKf, 0.125)
                        end
                        self["inv"][kfuUgCuKc]:SetScale(ffiuccfKf)
                        self["inv"][kfuUgCuKc]["OnGainFocus"] = function(fFfUiCiKc)
                            self["inv"][kfuUgCuKc]:SetScale(ffiuccfKf)
                        end
                        self["inv"][kfuUgCuKc]["OnLoseFocus"] = function(ifuUkCfKi)
                            self["inv"][kfuUgCuKc]:SetScale(ffiuccfKf)
                        end
                    end
                end
            end
        end
        if unified_screen ~= nil and unified_screen.TrackNativeContainer ~= nil then
            unified_screen:TrackNativeContainer(self, prefab)
        end
    end
    local gfiUgcfKi = self["Close"]
    self["Close"] = function(self, ...)
        local container = self["container"]
        local is_summary = container ~= nil and container["prefab"] == "hh_ui_container"
        local is_monarch_storage = container ~= nil and container["prefab"] == MONARCH_STORAGE_PREFAB
        local unified_screen = TTKUnifiedRegistry.Get(self["owner"])
        if unified_screen ~= nil and unified_screen.UntrackNativeContainer ~= nil then
            unified_screen:UntrackNativeContainer(self)
        end
        if is_monarch_storage and self["owner"] ~= nil then
            self["owner"].HHMonarchStorageOpen = nil
        end
        if is_summary then
            HHSummaryLock.ClearContainerWidget(self["owner"], self)
            HHSummaryLock.SetHudInputFocus(self["owner"], false)
        end
        if
            ifgunCfkk:HasReplica(self["container"], "container") and
                ifgunCfkk:IsHHType(ifuUgcikc[self["container"]["prefab"]], "table") and
                ifuUgcikc[self["container"]["prefab"]]["ui"] and
                ifuUgcikc[self["container"]["prefab"]]["ui_id"]
         then
            local kfuUfccku = ifuUgcikc[self["container"]["prefab"]]["ui_id"]
            ifgunCfkk:HHKillChild(self, kfuUfccku)
        end
        gfiUgcfKi(self, ...)
        if is_summary and TheFrontEnd ~= nil then
            if TheFrontEnd.ClearFocus ~= nil then
                TheFrontEnd:ClearFocus()
            end
            if TheInput ~= nil and TheInput.UpdateEntitiesUnderMouse ~= nil then
                TheInput:UpdateEntitiesUnderMouse()
            end
        end
    end

end
AddClassPostConstruct("widgets/containerwidget", gFcUuckKi)
local fFnuncfkg = cfcugCckg("widgets/text")
local ifnUfcikg = cfcugCckg("widgets/widget")
local fFuuiCkkn = cfcugCckg("widgets/imagebutton")
local cfuUcCuKk = cfcugCckg("widgets/uianim")
local iFcUiCnkf = cfcugCckg("screens/redux/scrapbookdata")
local function gFnuccnKg(fFiukccKg)
    return fFiukccKg:gsub("\n%s*", "\n"):gsub("^%s*", "")
end
local gfguncnkg = TUNING["HH_UI_TEXT"]
local uFcUiCgkk = gfguncnkg["MOD_INFO"]
local fFcuucnKi = gfguncnkg["UI_ITEMS"]
local kFuugcikk = {
    ["hh_a_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_a_info"),
        ["hh_str"] = "#03: Hợp Thành",
        ["special_str"] = gFnuccnKg(uFcUiCgkk["mod_role_1"])
    },
    ["hh_b_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_b_info"),
        ["hh_str"] = "#04: Hợp Thành",
        ["special_str"] = gFnuccnKg(uFcUiCgkk["mod_role_2"])
    },
    ["hh_e_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_e_info"),
        ["hh_str"] = "#01: Đột Biến",
        ["special_str"] = gFnuccnKg(uFcUiCgkk["monster"])
    },

    ["hh_g_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_g_info"),
        ["hh_str"] = "#08: Đạo Cụ",
        ["special_str"] = gFnuccnKg(fFcuucnKi["ui_role_1"])
    },
    ["hh_h_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_h_info"),
        ["hh_str"] = "#09: Châu Báu",
        ["special_str"] = gFnuccnKg(fFcuucnKi["ui_role_2"])
    },
    ["hh_i_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_i_info"),
        ["hh_str"] = "#10: Châu Báu",
        ["special_str"] = gFnuccnKg(fFcuucnKi["ui_role_3"])
    },
    ["hh_j_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_j_info"),
        ["hh_str"] = "#11: Châu Báu",
        ["special_str"] = gFnuccnKg(fFcuucnKi["ui_role_4"])
    },
    ["hh_k_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_k_info"),
        ["hh_str"] = "#12: Châu Báu",
        ["special_str"] = gFnuccnKg(fFcuucnKi["ui_role_5"])
    },
    ["hh_l_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_l_info"),
        ["hh_str"] = "#13: Trang Bị Hỗ Trợ",
        ["special_str"] = gFnuccnKg(fFcuucnKi["ui_role_6"])
    },
    ["hh_m_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_m_info"),
        ["hh_str"] = "#13: Trang Bị Hỗ Trợ",
        ["special_str"] = gFnuccnKg(fFcuucnKi["ui_role_7"])
    },

    ["hh_l_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_l_info"),
        ["hh_str"] = "#14: CÁC MOD BẮT BUỘC",
        ["special_str"] = gFnuccnKg(uFcUiCgkk["respect"])
    },
    ["hh_m_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_m_info"),
        ["hh_str"] = "#15: Cập Nhật",
        ["special_str"] = (function()
            if type(uFcUiCgkk["update"]) == "table" then
                local out = ""
                for _, entry in ipairs(uFcUiCgkk["update"]) do
                    out = out .. entry["date"] .. "\n" .. entry["desc"] .. "\n"
                end
                return gFnuccnKg(out)
            else
                return gFnuccnKg(uFcUiCgkk["update"])
            end
        end)()
    },

    ["hh_1_info"] = {
        ["tex"] = "unknown.tex",
        ["type"] = "HH_TAB_B",
        ["prefab"] = "hh_test",
        ["build"] = "mapscroll",
        ["bank"] = "mapscroll",
        ["anim"] = "idle",
        ["specialinfo"] = string["upper"]("hh_1_info"),
        ["hh_str"] = "#20: Xung Đột",
        ["special_str"] = gFnuccnKg(uFcUiCgkk["conflict"])
    }
}
for cFiunccKg, kFkuncfkg in pairs(kFfufciKi) do
    if not kFuugcikk["hh_" .. cFiunccKg] then
        local nFiUnCgKf = {
            ["tex"] = "dyc_gem_purple.tex",
            ["type"] = "HH_TAB_A",
            ["prefab"] = "hh_test",
            ["build"] = "dyc_gem_purple",
            ["bank"] = "dyc_gems",
            ["anim"] = "dyc_gem_purple",
            ["hh_str"] = tostring(kFkuncfkg["name"]),
            ["specialinfo"] = string["upper"]("hh_" .. cFiunccKg)
        }
        local kFcUucgKk = kFkuncfkg["desc"] or "kxđ"
        if kFkuncfkg["value_range"] then
            nFiUnCgKf["damage"] =
                string["format"](
                "%s \n Pv:%s-%s",
                tostring(kFkuncfkg["name"]),
                kFkuncfkg["value_range"]["min"],
                kFkuncfkg["value_range"]["max"]
            )
            kFcUucgKk = string["format"](kFcUucgKk, ifgunCfkk:Template("{{min}}~{{max}}", kFkuncfkg["value_range"]))
        end
        if kFkuncfkg["is_suit"] then
            if kFkuncfkg["suit_str"] and TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][kFkuncfkg["suit_str"]] then
                kFcUucgKk = TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][kFkuncfkg["suit_str"]]["effect_str"] or "kxđ"
            end
            if kFkuncfkg["person_one"] then
                kFcUucgKk = "Set này chưa khả dụng"
            end
        end
        nFiUnCgKf["special_str"] = kFcUucgKk
        kFuugcikk["hh_" .. cFiunccKg] = nFiUnCgKf
    end
end
local iFnUiCiKn = gfguncnkg["UPDATE_VISION"]
for uFnUuCiku, fFkUfciKf in ipairs(iFnUiCiKn) do
    if not kFuugcikk["hh_update_" .. uFnUuCiku] then
        local cFiUnCfkf = {
            ["tex"] = "unknown.tex",
            ["type"] = "HH_TAB_B",
            ["prefab"] = "hh_test",
            ["build"] = "mapscroll",
            ["bank"] = "mapscroll",
            ["anim"] = "idle",
            ["specialinfo"] = string["upper"]("hh_update_" .. uFnUuCiku),
            ["hh_str"] = "#07: Cường Hoá " .. fFkUfciKf["title"],
            ["special_str"] = gFnuccnKg(fFkUfciKf["desc"])
        }
        kFuugcikk["hh_update_" .. uFnUuCiku] = cFiUnCfkf
    end
end
RegisterScrapbookIconAtlas("images/dyc_gem_purple.xml", "dyc_gem_purple.tex")
for cFuukccki, gFkUiCgKi in pairs(kFuugcikk) do
    if not iFcUiCnkf[cFuukccki] then
        gFkUiCgKi["name"] = cFuukccki
        iFcUiCnkf[cFuukccki] = gFkUiCgKi
        nffUgCgkk["NAMES"][string["upper"](cFuukccki)] = tostring(gFkUiCgKi["hh_str"])
        nffUgCgkk["SCRAPBOOK"]["SPECIALINFO"][string["upper"](cFuukccki)] =
            tostring(gFkUiCgKi["special_str"] or gFkUiCgKi["hh_str"])
    end
end
local function kFkUkCckn(self)
    local kffUncgKf = self["GetLevelFor"]
    self["GetLevelFor"] = function(kFcUiCnKk, fFfufCfki, ...)
        if kFuugcikk[fFfufCfki] then
            return 2
        end
        return kffUncgKf(kFcUiCnKk, fFfufCfki, ...)
    end
    local ufuUgCcKn = self["WasViewedInScrapbook"]
    self["WasViewedInScrapbook"] = function(uFnuncgkk, nFfunCgku, ...)
        if kFuugcikk[nFfunCgku] then
            return (332 + 170 * 145 + 149 == 25131)
        end
        return ufuUgCcKn(uFnuncgkk, nFfunCgku, ...)
    end
end
AddClassPostConstruct("scrapbookpartitions", kFkUkCckn)
local function gfnukCgKu(self, kFnUccckf, uFcUfCgkf)
    local fFfufCikg = 450
    local cFfUfckKn, nFuugCfkc = 252 / 2.2, 112 / 2.2
    local fFnUgCfKu = fFfufCikg / 2 - ((fFfufCikg / 7) * kFnUccckf - 1) + 50
    local kFuUgcfKn = self["root"]:AddChild(ifnUfcikg())
    local ifkucCnku = kFuUgcfKn:AddChild(fFuuiCkkn("images/scrapbook.xml", "tab.tex"))
    ifkucCnku:ForceImageSize(cFfUfckKn, nFuugCfkc)
    ifkucCnku["scale_on_focus"] = (420 * 456 - 336 + 382 + 393 ~= 191959)
    ifkucCnku["basecolor"] = {uFcUfCgkf["color"][1], uFcUfCgkf["color"][2], uFcUfCgkf["color"][3]}
    ifkucCnku:SetImageFocusColour(
        math["min"](1, uFcUfCgkf["color"][1] * 1.2),
        math["min"](1, uFcUfCgkf["color"][2] * 1.2),
        math["min"](1, uFcUfCgkf["color"][3] * 1.2),
        1
    )
    ifkucCnku:SetImageNormalColour(uFcUfCgkf["color"][1], uFcUfCgkf["color"][2], uFcUfCgkf["color"][3], 1)
    ifkucCnku:SetImageSelectedColour(uFcUfCgkf["color"][1], uFcUfCgkf["color"][2], uFcUfCgkf["color"][3], 1)
    ifkucCnku:SetImageDisabledColour(uFcUfCgkf["color"][1], uFcUfCgkf["color"][2], uFcUfCgkf["color"][3], 1)
    ifkucCnku:SetScale(-1, 1, 1)
    ifkucCnku:SetOnClick(
        function()
            self:SelectSideButton(uFcUfCgkf["filter"])
            self["current_dataset"] = self:CollectType(kFuugcikk, uFcUfCgkf["filter"])
            self["current_view_data"] = self:CollectType(kFuugcikk, uFcUfCgkf["filter"])
            self:SetGrid()
        end
    )
    kFuUgcfKn["focusimg"] = ifkucCnku:AddChild(nfkukccKk("images/scrapbook.xml", "tab_over.tex"))
    kFuUgcfKn["focusimg"]:ScaleToSize(cFfUfckKn, nFuugCfkc)
    kFuUgcfKn["focusimg"]:SetClickable((159 - 95 + 427 * 470 ~= 200754))
    kFuUgcfKn["focusimg"]:Hide()
    kFuUgcfKn["selectimg"] = ifkucCnku:AddChild(nfkukccKk("images/scrapbook.xml", "tab_selected.tex"))
    kFuUgcfKn["selectimg"]:ScaleToSize(cFfUfckKn, nFuugCfkc)
    kFuUgcfKn["selectimg"]:SetClickable((409 + 391 + 109 ~= 909))
    kFuUgcfKn["selectimg"]:Hide()
    kFuUgcfKn:SetOnGainFocus(
        function()
            kFuUgcfKn["focusimg"]:Show()
        end
    )
    kFuUgcfKn:SetOnLoseFocus(
        function()
            kFuUgcfKn["focusimg"]:Hide()
        end
    )
    local kFuUuCnki =
        ifkucCnku:AddChild(fFnuncfkg(HEADERFONT, 12, tostring(uFcUfCgkf["tab_str"] or "kxđ"), UICOLOURS["WHITE"]))
    kFuUuCnki:SetPosition(10, -8)
    kFuUuCnki:SetScale(-1, 1, 1)
    kFuUgcfKn:SetPosition(-522 - cFfUfckKn / 2, fFnUgCfKu)
    local nFiUuCnkg = kFuUgcfKn:AddChild(fFnuncfkg(HEADERFONT, 18, tostring(uFcUfCgkf["title"]), UICOLOURS["GOLD"]))
    nFiUuCnkg:SetPosition(-15, 17)
    kFuUgcfKn["newcreatures"] = {}
    kFuUgcfKn["flash"] = kFuUgcfKn:AddChild(cfuUcCuKk())
    kFuUgcfKn["flash"]:GetAnimState():SetBank("cookbook_newrecipe")
    kFuUgcfKn["flash"]:GetAnimState():SetBuild("cookbook_newrecipe")
    kFuUgcfKn["flash"]:GetAnimState():PlayAnimation("anim", (339 * 489 - 379 - 45 == 165347))
    kFuUgcfKn["flash"]:GetAnimState():SetScale(0.15, 0.15, 0.15)
    kFuUgcfKn["flash"]:SetPosition(40, 0, 0)
    kFuUgcfKn["flash"]:Hide()
    kFuUgcfKn["flash"]:SetClickable((267 - 260 + 241 * 257 ~= 61944))
    kFuUgcfKn["filter"] = uFcUfCgkf["filter"]
    kFuUgcfKn["focus_forward"] = ifkucCnku
    table["insert"](self["menubuttons"], kFuUgcfKn)
end
local kfgUiCuKi = {
    {
        ["tab_str"] = "Equipment",
        ["name"] = "HH_TAB_A",
        ["filter"] = "HH_TAB_A",
        ["color"] = {114 / 255, 56 / 255, 56 / 255},
        ["title"] = "Đá Thuộc Tính"
    },
    {
        ["tab_str"] = "Help",
        ["name"] = "HH_TAB_B",
        ["filter"] = "HH_TAB_B",
        ["color"] = {114 / 255, 56 / 255, 56 / 255},
        ["title"] = "Hướng dẫn"
    }
}
local function ffgukccKi(self)
    if not ifgunCfkk:IsHHType(self["menubuttons"], "table") or #self["menubuttons"] < 1 then
        return
    end
    for ufcUnCgku, iFcukCukn in ipairs(kfgUiCuKi) do
        gfnukCgKu(self, ufcUnCgku, iFcukCukn)
    end
end
AddClassPostConstruct("screens/redux/scrapbookscreen", ffgukccKi)
local ifgUfCckc = 5
local ufnUkCuKi =
    Class(
    ifnUfcikg,
    function(self, gFgUkcfKn)
        ifnUfcikg["_ctor"](self, "hh_announce")
        self["owner"] = gFgUkcfKn
        self["root"] = self:AddChild(ifnUfcikg("ROOT"))
        self["root"]:SetVAnchor(ANCHOR_MIDDLE)
        self["root"]:SetHAnchor(ANCHOR_MIDDLE)
        self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self["save_table"] = {}
        self["inst"]:ListenForEvent(
            "hh_share_equip_client",
            function(gfkUccfkn, kFnUuckkc)
                local gFnugciKn = ifgunCfkk:GetClientValue(self["owner"], "hh_share_equip_client")
                if not ifgunCfkk:IsHHType(gFnugciKn, "table") then
                    return
                end
                self:UpdateEquip(gFnugciKn)
            end,
            self["owner"]
        )
    end
)
function ufnUkCuKi:UpdateEquip(iFiUgcfkk)
    if #self["save_table"] <= 0 then
        table["insert"](self["save_table"], iFiUgcfkk)
    elseif #self["save_table"] >= ifgUfCckc then
        local ffcUccnKc = #self["save_table"]
        local ffuUfcgKg = ffcUccnKc - ifgUfCckc
        local gFfuncfKi = {}
        for kfkUkcnku = ffuUfcgKg, ffcUccnKc do
            if ifgunCfkk:IsHHType(self["save_table"][kfkUkcnku], "table") then
                table["insert"](gFfuncfKi, self["save_table"][kfkUkcnku])
            end
        end
        table["insert"](gFfuncfKi, iFiUgcfkk)
        self["save_table"] = gFfuncfKi
    else
        table["insert"](self["save_table"], iFiUgcfkk)
    end
    self:CreateAnnounceUi()
end
function ufnUkCuKi:CreateAnnounceUi()
    ifgunCfkk:HHKillChild(self, "hh_widget")
    if #self["save_table"] <= 0 then
        return
    end
    self["hh_widget"] = self["root"]:AddChild(ifnUfcikg())
    local cFgUucfKc = self["hh_widget"]
    cFgUucfKc:SetPosition(-500, 150, 1)
    local ffuUncgKn = #self["save_table"]
    local gFnUgcnKi = 0
    local kfiukcckg = 20
    for uFfUiCiKk = ffuUncgKn, 1, -1 do
        if ifgunCfkk:IsHHType(self["save_table"][uFfUiCiKk], "table") then
            local kfuucckKu = self["save_table"][uFfUiCiKk]
            local fFiuuccKk = "Trang bị"
            local kfcucCcKi = "Người chơi?"
            fFiuuccKk = tostring(kfuucckKu["equip"])
            kfcucCcKi = tostring(kfuucckKu["player"])
            local nfiuicuki = kfuucckKu["player_title"] or ""
            cFgUucfKc["hh_child_" .. uFfUiCiKk] =
                ifgunCfkk:CreateMoreTextUi(
                cFgUucfKc,
                {
                    {["str"] = nfiuicuki, ["color"] = {255 / 255, 232 / 255, 0 / 255, 1}, ["scale"] = kfiukcckg},
                    {["str"] = kfcucCcKi, ["color"] = {255 / 255, 102 / 255, 0 / 255, 1}, ["scale"] = kfiukcckg},
                    {["str"] = " đang có 【", ["scale"] = kfiukcckg},
                    {["str"] = fFiuuccKk, ["color"] = {255 / 255, 11 / 255, 0 / 255, 1}, ["scale"] = kfiukcckg},
                    {["str"] = "】", ["scale"] = kfiukcckg}
                },
                1
            )
            local nffuuCiKc, uFkUickKn =
                cFgUucfKc["hh_child_" .. uFfUiCiKk]["max_x"],
                cFgUucfKc["hh_child_" .. uFfUiCiKk]["max_y"]
            cFgUucfKc["hh_child_" .. uFfUiCiKk]:SetPosition(0, gFnUgcnKi, 1)
            local cfgufcnkn = cFgUucfKc["hh_child_" .. uFfUiCiKk]
            if cfgufcnkn["hh_text_4"] and cfgufcnkn["hh_text_4"]["GetRegionSize"] then
                local gfuUiciKc, fFfUfCiKc = cfgufcnkn["hh_text_4"]:GetRegionSize()
                cfgufcnkn["hh_text_4"]["hh_back_ground"] =
                    ifgunCfkk:HHCreateImageUi(
                    cfgufcnkn["hh_text_4"],
                    "images/global.xml",
                    "square.tex",
                    gFgUiCgkg(0, 0, 1),
                    gfuUiciKc,
                    fFfUfCiKc,
                    {1, 1, 1, 0}
                )
                local kfnUkcnku = cfgufcnkn["hh_text_4"]["hh_back_ground"]
                local ifkUicgkc = kfnUkcnku["OnGainFocus"]
                kfnUkcnku["OnGainFocus"] = function()
                    if ifkUicgkc then
                        ifkUicgkc()
                    end
                    ifgunCfkk:HHKillChild(kfnUkcnku, "info_ui")
                    local gFuUcciKf = {
                        ["name"] = {["str"] = fFiuuccKk, ["color"] = {255 / 255, 102 / 255, 0 / 255, 1}},
                        ["player"] = {["str"] = kfcucCcKi, ["color"] = {255 / 255, 102 / 255, 0 / 255, 1}},
                        ["effect"] = {["str"] = kfuucckKu["effect"], ["color"] = {255 / 255, 11 / 255, 0 / 255, 1}}
                    }
                    if kfuucckKu["gem"] then
                        gFuUcciKf["gem"] = {["str"] = kfuucckKu["gem"], ["color"] = {255 / 255, 11 / 255, 0 / 255, 1}}
                    end
                    kfnUkcnku["info_ui"] =
                        ifgunCfkk:CreateInfoUi(
                        kfnUkcnku,
                        gFuUcciKf,
                        {
                            {["id"] = "name", ["name"] = "Trang bị:", ["scale"] = 20},
                            {["id"] = "player", ["name"] = "Người chơi:", ["scale"] = 20},
                            {["id"] = "effect", ["name"] = "Hiệu ứng:", ["scale"] = 20},
                            {["id"] = "gem", ["name"] = "Châu báu:", ["scale"] = 20}
                        }
                    )
                    local nFuuiccKg, cFcUicfkc = kfnUkcnku["info_ui"]["max_x"], kfnUkcnku["info_ui"]["max_y"]
                    kfnUkcnku["info_ui"]["back_ground"] =
                        ifgunCfkk:CreateFrameUi(
                        kfnUkcnku["info_ui"],
                        gFgUiCgkg(nFuuiccKg / 2, -cFcUicfkc / 2, 1),
                        {["size_x"] = nFuuiccKg + 10, ["size_y"] = cFcUicfkc + 10, ["color"] = {0, 0, 0, 0.5}},
                        {["size"] = 2.5, ["color"] = {0, 0, 0, 1}}
                    )
                    kfnUkcnku["info_ui"]["back_ground"]:MoveToBack()
                    kfnUkcnku["info_ui"]:SetPosition(-nFuuiccKg / 2, cFcUicfkc + 20, 1)
                    kfnUkcnku["info_ui"]:SetClickable((18 * 54 * 151 - 338 * 395 ~= 13262))
                end
                local iffUuCgKg = kfnUkcnku["OnLoseFocus"]
                kfnUkcnku["OnLoseFocus"] = function()
                    if iffUuCgKg then
                        iffUuCgKg()
                    end
                    ifgunCfkk:HHKillChild(kfnUkcnku, "info_ui")
                end
            end
            if nfiuicuki and nfiuicuki ~= "" then
                cfgufcnkn["back_ground"] =
                    ifgunCfkk:CreateFrameUi(
                    cfgufcnkn,
                    gFgUiCgkg(nffuuCiKc / 2, -uFkUickKn / 2, 1),
                    {["size_x"] = nffuuCiKc + 5, ["size_y"] = uFkUickKn + 5, ["color"] = {0, 0, 0, 0.5}},
                    {["size"] = 2, ["color"] = {0, 0, 0, 1}}
                )
                cfgufcnkn["back_ground"]:MoveToBack()
                cfgufcnkn["back_ground"]:SetClickable((220 * 301 + 497 - 445 ~= 66272))
            end
            gFnUgcnKi = gFnUgcnKi - uFkUickKn - 10
        end
    end
    self["show_time"] = 0
    self:StartUpdating()
end
function ufnUkCuKi:OnUpdate(iFuUcccKg)
    if not ifgunCfkk:IsHHType(self["show_time"], "number") or self["show_time"] < 0 then
        self["show_time"] = 0
    end
    self["show_time"] = self["show_time"] + iFuUcccKg
    if self["show_time"] > 20 then
        ifgunCfkk:HHKillChild(self, "hh_widget")
        self:StopUpdating()
    end
end
local nFkunCkkk = cfcugCckg("widgets/hh_waring_ui")
AddClassPostConstruct(
    "widgets/controls",
    function(self, gfgUicikn)
        self["hh_announce_ui"] = self:AddChild(ufnUkCuKi(self["owner"]))
        self["hh_announce_ui"]:MoveToBack()
        self["hh_waring_ui"] = self:AddChild(nFkunCkkk(self["owner"]))
    end
)
local ifgUcCiKn = {}
local uffuuCkKn = 30
local nFnUncikn
local gFcucCiKu
local cfgUfCkKu = fFiUncckf["widgetsetup2"] or function()
        return (166 - 395 + 329 * 487 - 65 == 159929)
    end
function fFiUncckf.widgetsetup2(kfgufcckf, nfnUuCikk, kfnufcckf, ...)
    local iFguicnKu = nfnUuCikk or kfgufcckf["inst"]["prefab"]
    if iFguicnKu == MONARCH_STORAGE_PREFAB then
        local nffuuCkKk = kFkugCukk[iFguicnKu]
        if nffuuCkKk ~= nil then
            for nfkUccuKu, gFiugcfki in pairs(nffuuCkKk) do
                kfgufcckf[nfkUccuKu] = gFiugcfki
            end
            kfgufcckf:SetNumSlots(kfgufcckf["widget"]["slotpos"] ~= nil and #kfgufcckf["widget"]["slotpos"] or 0)
        end
    else
        return cfgUfCkKu(kfgufcckf, nfnUuCikk, kfnufcckf, ...)
    end
end
kFkugCukk[MONARCH_STORAGE_PREFAB] = {
    widget = {
        slotpos = ifgUcCiKn,
        pos = gFgUiCgkg(0, -100, 0),
        bgatlas = "images/nn_cauldron_ui.xml",
        bgimage = "nn_cauldron_ui.tex",
        ["buttoninfo"] = {
            ["text"] = "Đóng",
            ["position"] = gFgUiCgkg(-10, -200, 0),
            ["fn"] = gfiuncnKc
        }
    },
    type = MONARCH_STORAGE_PREFAB,
    excludefromcrafting = true
}
for nFguicgkf = 0, 2 do
    for fFuukckKf = 7, 0, -1 do
        for nFiuccnki = 0, 4 do
            nFnUncikn = 80 * nFiuccnki - 600 + 80 * 5 * nFguicgkf + uffuuCkKn * nFguicgkf
            local posY = 80 * fFuukckKf - 100
            if fFuukckKf > 3 then
                posY = posY + uffuuCkKn
            end
            table["insert"](ifgUcCiKn, gFgUiCgkg(nFnUncikn, posY, 0))
        end
    end
end
function kFkugCukk.hh_monarch_storage_container.itemtestfn(gFuugCiku, kffUkCukk, kFguuCiKu)
    return kffUkCukk ~= nil and
        (kffUkCukk["components"] ~= nil and kffUkCukk["components"]["inventoryitem"] ~= nil
            or kffUkCukk["replica"] ~= nil and kffUkCukk["replica"]["inventoryitem"] ~= nil)
end
for cfkugCuKu, ffcUcCgKf in pairs(kFkugCukk) do
    fFiUncckf["MAXITEMSLOTS"] =
        math["max"](
        fFiUncckf["MAXITEMSLOTS"],
        ffcUcCgKf["widget"]["slotpos"] ~= nil and #ffcUcCgKf["widget"]["slotpos"] or 0
    )
end

local MonarchStorageText = require("widgets/text")
AddClassPostConstruct("widgets/invslot", function(self)
    local function IsMonarchSlot()
        return self.container ~= nil and self.container.inst ~= nil
            and self.container.inst.prefab == MONARCH_STORAGE_PREFAB
    end
    local function RefreshLockStar(forced_locked, forced_guid)
        local item = self.tile ~= nil and self.tile.item or nil
        local locked = item ~= nil and item.replica.inventoryitem ~= nil
            and item.replica.inventoryitem:IsLockedInSlot() or false
        if forced_guid ~= nil and item ~= nil and item.GUID == forced_guid then
            locked = forced_locked == true
        end
        if IsMonarchSlot() and locked then
            if self.hh_monarch_lock_star == nil then
                self.hh_monarch_lock_star = self:AddChild(MonarchStorageText(NUMBERFONT, 22, "★", { 1, 0, 0, 1 }))
                self.hh_monarch_lock_star:SetPosition(28, -28, 0)
                self.hh_monarch_lock_star:SetClickable(false)
            end
            self.hh_monarch_lock_star:Show()
            self.hh_monarch_lock_star:MoveToFront()
        elseif self.hh_monarch_lock_star ~= nil then
            self.hh_monarch_lock_star:Hide()
        end
    end
    local OldSetTile = self.SetTile
    self.SetTile = function(slot_self, tile, ...)
        local result = OldSetTile(slot_self, tile, ...)
        RefreshLockStar()
        return result
    end
    local OldOnControl = self.OnControl
    self.OnControl = function(slot_self, control, down, ...)
        if down and control == CONTROL_SECONDARY and IsMonarchSlot()
            and TheInput:IsControlPressed(CONTROL_FORCE_INSPECT)
            and slot_self.tile ~= nil and slot_self.tile.item ~= nil then
            SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_monarch_storage_lock"],
                slot_self.num, slot_self.tile.item.GUID)
            return true
        end
        local inventoryitem = IsMonarchSlot() and slot_self.tile ~= nil and slot_self.tile.item ~= nil
            and slot_self.tile.item.replica.inventoryitem or nil
        if down and inventoryitem ~= nil and inventoryitem:IsLockedInSlot() then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
            return true
        end
        return OldOnControl(slot_self, control, down, ...)
    end
    local function HasOpenMonarchStorage(slot_self)
        local owner = slot_self.owner
        local containers = owner ~= nil and owner.HUD ~= nil and owner.HUD.controls ~= nil
            and owner.HUD.controls.containers or nil
        if owner == nil or not owner.HHMonarchStorageOpen or type(containers) ~= "table" then
            return false
        end
        for container_inst in pairs(containers) do
            if container_inst ~= nil and container_inst.prefab == MONARCH_STORAGE_PREFAB then
                return true
            end
        end
        return false
    end
    local OldCanTradeItem = self.CanTradeItem
    self.CanTradeItem = function(slot_self, stack_mod, ...)
        local item = slot_self.tile ~= nil and slot_self.tile.item or nil
        local inventoryitem = item ~= nil and item.replica.inventoryitem or nil
        if HasOpenMonarchStorage(slot_self) and inventoryitem ~= nil
            and not inventoryitem:IsLockedInSlot()
            and not (GetGameModeProperty("non_item_equips") and item.replica.equippable ~= nil) then
            -- Kho Quân Vương intentionally accepts valid inventory items even when
            -- vanilla chest rules reject CanGoInContainer/pocket-only items.
            return true
        end
        return OldCanTradeItem(slot_self, stack_mod, ...)
    end
    self.inst:ListenForEvent("hh_monarch_storage_lock_dirty", function(_, data)
        if data ~= nil and data.slot == self.num then
            RefreshLockStar(data.locked, data.guid)
        end
    end, self.owner)
end)

AddClassPostConstruct("widgets/itemtile", function(self)
    if self.item
        and self.item:HasTag("hh_daily_slot_lock")
        and self.image then
        self.image:SetScale(
            TUNING.HH_DAILY_QUEST.SLOT_LOCK_ICON_SCALE,
            TUNING.HH_DAILY_QUEST.SLOT_LOCK_ICON_SCALE,
            1
        )
    end
end)
