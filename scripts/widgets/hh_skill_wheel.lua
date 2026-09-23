local Wheel = require "widgets/wheel"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local WHEEL_RADIUS = 130
local WHEEL_FOCUS_RADIUS = 130
local NORMAL_SCALE = 0.49
local FOCUS_SCALE = 0.735
local COOLDOWN_OVERLAY_INSET = 4

local function NetValue(owner, field)
    local netvar = owner ~= nil and owner[field] or nil
    return netvar ~= nil and netvar:value() or 0
end

local function SetPlayerScreenPosition(wheel)
    local owner = wheel.owner
    if owner == nil or not owner:IsValid() then
        return
    end

    local screen_width, screen_height = TheSim:GetScreenSize()
    if screen_width <= 0 or screen_height <= 0 then
        return
    end

    local screen_x, screen_y = TheSim:GetScreenPos(owner.Transform:GetWorldPosition())
    local proportional_scale = math.max(RESOLUTION_X / screen_width, RESOLUTION_Y / screen_height)
    wheel:SetPosition(
        (screen_x - screen_width * 0.5) * proportional_scale,
        (screen_y - screen_height * 0.5) * proportional_scale,
        0
    )
end

local function ConfigureImageButton(button)
    button.move_on_click = false
    button:SetNormalScale(NORMAL_SCALE)
    button:SetFocusScale(FOCUS_SCALE)
end

local function AddCooldownOverlay(button, skill_def, wheel)
    local overlay = button.image:AddChild(UIAnim())
    local animstate = overlay:GetAnimState()
    animstate:SetBank("status_meter_circle")
    animstate:SetBuild("status_meter_circle")
    animstate:PlayAnimation("meter")
    animstate:SetPercent("meter", 1)
    animstate:SetMultColour(0, 0, 0.4, 0.64)
    animstate:AnimateWhilePaused(false)
    overlay:SetClickable(false)

    local image_width, image_height = button.image:GetSize()
    local x1, y1, x2, y2 = animstate:GetVisualBB()
    local overlay_width, overlay_height = x2 - x1, y2 - y1
    if overlay_width > 0 and overlay_height > 0 then
        local target_diameter = math.max(
            0,
            math.min(image_width, image_height) - COOLDOWN_OVERLAY_INSET * 2
        )
        local scale = target_diameter / math.max(overlay_width, overlay_height)
        overlay:SetScale(scale)
        overlay:SetPosition(
            -(x1 + x2) * 0.5 * scale,
            -(y1 + y2) * 0.5 * scale,
            0
        )
    end
    overlay:Hide()

    wheel._hh_cooldown_states[#wheel._hh_cooldown_states + 1] = {
        overlay = overlay,
        animstate = animstate,
        remaining_field = skill_def.cooldown_netvar,
        total_field = skill_def.cooldown_total_netvar,
        net_remaining = nil,
        local_end_time = nil,
        session_active = false,
        visible = false,
    }
end

local function CreateHHSkillWheel(config)
    local wheel = Wheel(config.name or "HHSkillWheel", config.owner, { ignoreleftstick = true })
    wheel._hh_skill_defs = config.skills
    wheel._hh_visible_signature = nil
    wheel._hh_cooldown_states = {}

    function wheel:RefreshSkillItems()
        local visible = {}
        local signature = {}
        for _, skill_def in ipairs(self._hh_skill_defs) do
            if skill_def.is_unlocked == nil or skill_def.is_unlocked(self.owner) then
                visible[#visible + 1] = skill_def
                signature[#signature + 1] = skill_def.id
            end
        end

        local new_signature = table.concat(signature, "|")
        if new_signature == self._hh_visible_signature then
            return false
        end

        local items = {}
        self._hh_cooldown_states = {}
        for _, skill_def in ipairs(visible) do
            local item_skill_def = skill_def
            items[#items + 1] = {
                label = item_skill_def.label or "",
                atlas = item_skill_def.atlas,
                normal = item_skill_def.texture,
                focus = item_skill_def.texture,
                disabled = item_skill_def.texture,
                down = item_skill_def.texture,
                selected = item_skill_def.texture,
                checkenabled = item_skill_def.checkenabled,
                postinit = function(button)
                    ConfigureImageButton(button)
                    if item_skill_def.cooldown_netvar ~= nil
                        and item_skill_def.cooldown_total_netvar ~= nil then
                        AddCooldownOverlay(button, item_skill_def, self)
                    end
                end,
                execute = function()
                    self:StopVisualUpdates()
                    self:Close()
                    if item_skill_def.activate ~= nil then
                        item_skill_def.activate()
                    end
                end,
            }
        end

        self:SetItems(items, WHEEL_RADIUS, WHEEL_FOCUS_RADIUS)
        self._hh_visible_signature = new_signature
        return true
    end

    function wheel:ResetCooldownSnapshots()
        local now = GetTime()
        for _, state in ipairs(self._hh_cooldown_states) do
            local remaining = NetValue(self.owner, state.remaining_field)
            local total = NetValue(self.owner, state.total_field)
            state.net_remaining = remaining
            state.session_active = remaining > 0 and total > 0
            state.local_end_time = state.session_active and (now + remaining) or nil
        end
    end

    function wheel:UpdateCooldownOverlays()
        local now = GetTime()
        for _, state in ipairs(self._hh_cooldown_states) do
            local remaining = NetValue(self.owner, state.remaining_field)
            if remaining ~= state.net_remaining then
                local same_session = state.session_active and remaining > 0
                state.net_remaining = remaining
                if remaining > 0 then
                    local server_end_candidate = now + remaining
                    state.local_end_time = same_session
                        and math.min(state.local_end_time, server_end_candidate)
                        or server_end_candidate
                    state.session_active = true
                else
                    state.local_end_time = nil
                    state.session_active = false
                end
            end

            local total = NetValue(self.owner, state.total_field)
            local visual_remaining = state.local_end_time ~= nil
                and math.max(0, state.local_end_time - now)
                or 0
            local cooldown_visible = visual_remaining > 0 and total > 0
            if cooldown_visible then
                state.animstate:SetPercent("meter", math.clamp(visual_remaining / total, 0, 1))
                if not state.visible then
                    state.overlay:Show()
                    state.visible = true
                end
            else
                if state.visible then
                    state.overlay:Hide()
                    state.visible = false
                end
            end
        end
    end

    function wheel:RefreshEnabledStates()
        for _, item in ipairs(self.activeitems or {}) do
            if item.checkenabled ~= nil and item.widget ~= nil then
                local enabled = item.checkenabled(self.owner)
                if enabled and not item.widget.enabled then
                    item.widget:Enable()
                elseif not enabled and item.widget.enabled then
                    item.widget:Disable()
                end
            end
        end
    end

    local updater = wheel:AddChild(Widget("HHSkillWheelVisualUpdater"))
    updater:SetClickable(false)
    updater.OnUpdate = function(_, _)
        SetPlayerScreenPosition(wheel)
        wheel:RefreshEnabledStates()
        wheel:UpdateCooldownOverlays()
    end
    wheel._hh_visual_updater = updater

    function wheel:PrepareToOpen()
        self:RefreshSkillItems()
        SetPlayerScreenPosition(self)
        self:RefreshEnabledStates()
        self:ResetCooldownSnapshots()
        self:UpdateCooldownOverlays()
    end

    function wheel:StartVisualUpdates()
        self._hh_visual_updater:StartUpdating()
    end

    function wheel:StopVisualUpdates()
        self._hh_visual_updater:StopUpdating()
    end

    wheel:RefreshSkillItems()
    return wheel
end

return CreateHHSkillWheel
