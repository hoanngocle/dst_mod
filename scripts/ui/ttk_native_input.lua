local NativeInput = {}

local function IsWidgetWithin(widget, root)
    local current = widget
    while current ~= nil do
        if current == root then return true end
        current = current.GetParent ~= nil and current:GetParent() or current.parent
    end
    return false
end

local function GetHud(owner)
    return owner ~= nil and owner.HUD or nil
end

local function GetInventoryRoot(owner, widget)
    if widget == nil then return nil end
    local hud = GetHud(owner)
    local controls = hud ~= nil and hud.controls or nil
    local inventory = controls ~= nil and controls.inv or nil
    if inventory ~= nil and IsWidgetWithin(widget, inventory) then return inventory end

    local replica = owner ~= nil and owner.replica or nil
    local inventory_replica = replica ~= nil and replica.inventory or nil
    local overflow = inventory_replica ~= nil and inventory_replica.GetOverflowContainer ~= nil
        and inventory_replica:GetOverflowContainer() or nil
    local overflow_widget = overflow ~= nil and controls ~= nil and controls.containers ~= nil
        and controls.containers[overflow] or nil
    if overflow_widget ~= nil and overflow_widget.isopen ~= false
        and IsWidgetWithin(widget, overflow_widget) then
        return overflow_widget
    end
end

local function GetHoveredWidget()
    if TheInput == nil or TheInput.GetHUDEntityUnderMouse == nil then return nil end
    local entity = TheInput:GetHUDEntityUnderMouse()
    return entity ~= nil and entity.widget or nil
end

local function IsPointerControl(control)
    if TheFrontEnd ~= nil and TheFrontEnd.isprimary then return true end
    if control == CONTROL_PRIMARY then return true end
    if control == CONTROL_SECONDARY and TheInput ~= nil and TheInput.mouse_enabled then return true end
    return (control == CONTROL_SCROLLBACK or control == CONTROL_SCROLLFWD)
        and TheInput ~= nil and TheInput.GetControlIsMouseWheel ~= nil
        and TheInput:GetControlIsMouseWheel(control)
end

function NativeInput.IsMouseInputAllowed(owner)
    return GetInventoryRoot(owner, GetHoveredWidget()) ~= nil
end

function NativeInput.IsControlInputAllowed(owner, control)
    if control == CONTROL_CANCEL or control == CONTROL_PAUSE then return false end
    if IsPointerControl(control) then return NativeInput.IsMouseInputAllowed(owner) end
    local hud = GetHud(owner)
    local focused = hud ~= nil and hud.GetDeepestFocus ~= nil and hud:GetDeepestFocus() or nil
    return GetInventoryRoot(owner, focused) ~= nil
end

local function DispatchToTarget(target, root, method, ...)
    local current = target
    while current ~= nil do
        local handler = current[method]
        if handler ~= nil and handler(current, ...) then return true end
        if current == root then break end
        current = current.GetParent ~= nil and current:GetParent() or current.parent
    end
    return false
end

function NativeInput.ForwardMouse(owner, button, down, x, y)
    local hud = GetHud(owner)
    local target = GetHoveredWidget()
    local root = GetInventoryRoot(owner, target)
    if hud == nil or root == nil then return false end
    if not DispatchToTarget(target, root, "OnMouseButton", button, down, x, y)
        and hud.OnMouseButton ~= nil then
        hud:OnMouseButton(button, down, x, y)
    end
    return true
end

function NativeInput.ForwardControl(owner, control, down)
    local hud = GetHud(owner)
    if hud == nil or hud.OnControl == nil or not NativeInput.IsControlInputAllowed(owner, control) then
        return false
    end
    local target = IsPointerControl(control) and GetHoveredWidget()
        or (hud.GetDeepestFocus ~= nil and hud:GetDeepestFocus() or nil)
    local root = GetInventoryRoot(owner, target)
    if root == nil or not DispatchToTarget(target, root, "OnControl", control, down) then
        hud:OnControl(control, down)
    end
    return true
end

return NativeInput
