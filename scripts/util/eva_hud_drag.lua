local Drag = {}

local PERSISTENCE_KEY = "pham_nhan_eva_soul_hud_v1"

local function ParsePosition(value)
    if type(value) ~= "string" then return nil, nil end
    local x, y = value:match("^%s*([%+%-]?[%d%.]+)%s*,%s*([%+%-]?[%d%.]+)%s*$")
    return tonumber(x), tonumber(y)
end

function Drag.Attach(widget, deps)
    deps = deps or {}
    local input = deps.input or TheInput
    local sim = deps.sim or TheSim
    local left_button = deps.left_button or MOUSEBUTTON_LEFT
    local vector = deps.vector or Vector3
    local previous_mouse_button = widget.OnMouseButton
    local move_handler = nil
    local mouse_start = nil
    local position_start = nil

    local function SavePosition()
        local position = widget:GetPosition()
        sim:SetPersistentString(PERSISTENCE_KEY,
            string.format("%g,%g", position.x, position.y), false)
    end

    local function EndDrag()
        if move_handler ~= nil then move_handler:Remove() end
        move_handler = nil
        mouse_start = nil
        position_start = nil
        SavePosition()
    end

    local function StartDrag()
        if move_handler ~= nil then return end
        mouse_start = input:GetScreenPosition()
        position_start = widget:GetPosition()
        move_handler = input:AddMoveHandler(function(x, y)
            local mouse = input:GetScreenPosition()
            local scale = widget:GetScale()
            local scale_x = scale.x ~= 0 and scale.x or 1
            local scale_y = scale.y ~= 0 and scale.y or scale_x
            widget:SetPosition(vector(
                position_start.x + (mouse.x - mouse_start.x) / scale_x,
                position_start.y + (mouse.y - mouse_start.y) / scale_y,
                position_start.z or 0))
        end)
    end

    widget.OnMouseButton = function(self, button, down, ...)
        if button == left_button then
            if down then StartDrag() elseif move_handler ~= nil then EndDrag() end
            return true
        end
        return previous_mouse_button ~= nil
            and previous_mouse_button(self, button, down, ...) or false
    end
    if widget.SetClickable ~= nil then widget:SetClickable(true) end

    sim:GetPersistentString(PERSISTENCE_KEY, function(success, value)
        if not success then return end
        local x, y = ParsePosition(value)
        if x ~= nil and y ~= nil then widget:SetPosition(vector(x, y, 0)) end
    end)

    return widget
end

return Drag
