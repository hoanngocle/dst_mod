local HHSummaryLock = {}

local MOD_NAME = "Solo Leveling"
local MOD_HUD_FOCUS_ID = "hh_summary_modal"

local function IsValid(value)
    if value == nil then
        return false
    end
    if value.inst ~= nil then
        return value.inst.IsValid == nil or value.inst:IsValid()
    end
    return value.IsValid == nil or value:IsValid()
end

local function GetControls(owner)
    if not IsValid(owner) or owner.HUD == nil then
        return nil
    end
    return owner.HUD.controls
end

function HHSummaryLock.GetContainerWidget(owner)
    owner = owner or ThePlayer
    local controls = GetControls(owner)
    if controls == nil then
        return nil
    end

    local container_widget = controls._hh_summary_container_widget
    local container = container_widget ~= nil and container_widget.container or nil
    if
        IsValid(container_widget) and
        container ~= nil and
        container.prefab == "hh_ui_container" and
        container_widget.isopen ~= false and
        IsValid(container_widget.hh_equip_ui) and
        container_widget.hh_equip_ui.shown ~= false
     then
        return container_widget
    end

    if container_widget ~= nil then
        controls._hh_summary_container_widget = nil
    end
    return nil
end

function HHSummaryLock.SetContainerWidget(owner, container_widget)
    local controls = GetControls(owner)
    if controls ~= nil then
        controls._hh_summary_container_widget = container_widget
    end
end

function HHSummaryLock.ClearContainerWidget(owner, container_widget)
    local controls = GetControls(owner)
    if controls ~= nil and
        (container_widget == nil or controls._hh_summary_container_widget == container_widget) then
        controls._hh_summary_container_widget = nil
    end
end

function HHSummaryLock.Get(owner)
    local container_widget = HHSummaryLock.GetContainerWidget(owner)
    return container_widget ~= nil and container_widget.hh_equip_ui or nil
end

function HHSummaryLock.IsOpen(owner)
    return HHSummaryLock.Get(owner) ~= nil
end

function HHSummaryLock.IsInputFocused(owner)
    local container_widget = HHSummaryLock.GetContainerWidget(owner)
    return container_widget ~= nil and container_widget.focus == true
end

local function IsWidgetWithin(widget, root)
    if widget == nil or root == nil then
        return false
    end

    local current = widget
    while current ~= nil do
        if current == root then
            return true
        end

        if current.GetParent ~= nil then
            current = current:GetParent()
        else
            current = current.parent
        end
    end

    return false
end

local function GetFocusedWidget(owner)
    owner = owner or ThePlayer
    local hud = IsValid(owner) and owner.HUD or nil
    if hud ~= nil and hud.GetDeepestFocus ~= nil then
        return hud:GetDeepestFocus()
    end
end

local function GetHoveredWidget()
    if TheInput == nil or TheInput.GetHUDEntityUnderMouse == nil then
        return nil
    end

    local entity = TheInput:GetHUDEntityUnderMouse()
    return entity ~= nil and entity.widget or nil
end

local function IsInventoryWidget(owner, widget)
    local controls = GetControls(owner)
    local inventory = controls ~= nil and controls.inv or nil
    if inventory == nil then
        return false
    end

    -- InventoryBar owns the normal inventory, equipment, integrated backpack,
    -- cursor and currently-visible inventory UI. Keep this generic instead of
    -- enumerating backpack prefab names.
    return IsWidgetWithin(widget, inventory)
end

local function IsOverflowContainerWidget(owner, widget)
    owner = owner or ThePlayer
    local controls = GetControls(owner)
    local replica = IsValid(owner) and owner.replica or nil
    local inventory = replica ~= nil and replica.inventory or nil
    if controls == nil or inventory == nil or inventory.GetOverflowContainer == nil then
        return false
    end

    local overflow = inventory:GetOverflowContainer()
    local container_widget = overflow ~= nil and controls.containers ~= nil and controls.containers[overflow] or nil
    return
        container_widget ~= nil and
        container_widget.isopen ~= false and
        IsWidgetWithin(widget, container_widget)
end

function HHSummaryLock.IsToggleIconFocused(owner)
    owner = owner or ThePlayer
    local controls = GetControls(owner)
    local guide = controls ~= nil and controls.hh_help_ui or nil
    local button = guide ~= nil and guide.hh_open_container or nil
    return button ~= nil and IsWidgetWithin(GetFocusedWidget(owner), button)
end

function HHSummaryLock.IsInputTarget(owner, widget)
    owner = owner or ThePlayer
    if widget == nil then
        return false
    end

    local container_widget = HHSummaryLock.GetContainerWidget(owner)
    if container_widget ~= nil and IsWidgetWithin(widget, container_widget) then
        return true
    end

    local controls = GetControls(owner)
    local guide = controls ~= nil and controls.hh_help_ui or nil
    local toggle_icon = guide ~= nil and guide.hh_open_container or nil
    if toggle_icon ~= nil and IsWidgetWithin(widget, toggle_icon) then
        return true
    end

    return IsInventoryWidget(owner, widget) or IsOverflowContainerWidget(owner, widget)
end

function HHSummaryLock.IsControlInputAllowed(owner)
    return HHSummaryLock.IsInputTarget(owner, GetFocusedWidget(owner))
end

function HHSummaryLock.IsMouseInputAllowed(owner)
    -- Mouse events must use the actual HUD entity under the pointer. Falling
    -- back to stale controller focus here could turn a world click into an
    -- inventory-slot click while an item is being carried.
    return HHSummaryLock.IsInputTarget(owner, GetHoveredWidget())
end

-- PlayerHud exposes this client-local focus channel for modal HUD widgets.
-- It is the same engine boundary used by DST's SetModHUDFocus helper.
function HHSummaryLock.SetHudInputFocus(owner, hasfocus)
    owner = owner or ThePlayer
    if not IsValid(owner) or owner.HUD == nil or owner.HUD.SetModFocus == nil then
        return false
    end

    owner.HUD:SetModFocus(MOD_NAME, MOD_HUD_FOCUS_ID, hasfocus == true)
    return true
end

function HHSummaryLock.CloseCompetingHudUi(owner)
    local controls = GetControls(owner)
    local hoverer = controls ~= nil and controls.hh_hoverer_config or nil
    local main = hoverer ~= nil and hoverer.hh_main_ui or nil
    if main == nil then
        return
    end

    -- Clear the reference first so event callbacks cannot re-enter a stale UI.
    hoverer.hh_main_ui = nil
    if IsValid(main) then
        main:Kill()
    end
end

-- Close the local widget immediately, then ask the server to perform the
-- existing container toggle. This keeps ESC/icon/X responsive while the RPC
-- remains the authoritative container state transition.
function HHSummaryLock.Close(owner)
    owner = owner or ThePlayer
    local container_widget = HHSummaryLock.GetContainerWidget(owner)
    if container_widget == nil or container_widget.Close == nil then
        return false
    end

    container_widget:Close()

    if
        owner == ThePlayer and
        SendModRPCToServer ~= nil and
        MOD_RPC ~= nil and
        MOD_RPC.hh_rpc ~= nil and
        MOD_RPC.hh_rpc.hh_ui_container ~= nil
     then
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_ui_container)
    end

    return true
end

return HHSummaryLock
