local Widget = require "widgets/widget"
local SkillPanel = require "util/eva_skillpanel"

local Layout = {}

local TOGGLE_SIZE = 80
local SKILL_ICON_SIZE = 58.08
local ICON_GAP = 64
local BADGE_X = -40
local BADGE_Y = -150
local PANEL_X = 0
local ROW_Y = 230

local function Pack(...)
    return {n = select("#", ...), ...}
end

local function UpdateHUDScale(controls)
    local root = controls.eva_bottomleft_hud_root
    if root == nil then return end
    local scale = TheFrontEnd ~= nil and TheFrontEnd.GetHUDScale ~= nil
        and TheFrontEnd:GetHUDScale() or 1
    root:SetScale(scale)
end

local function TrackHUDScale(controls)
    if controls._eva_hud_layout_tracks_scale then return end
    controls._eva_hud_layout_tracks_scale = true
    local SetHUDSize = controls.SetHUDSize
    if SetHUDSize == nil then return end
    controls.SetHUDSize = function(self, ...)
        local results = Pack(SetHUDSize(self, ...))
        UpdateHUDScale(self)
        return unpack(results, 1, results.n)
    end
end

local function ConfigureButton(button, size)
    if button == nil then return end
    -- Native ImageButton focus handling calls Image:SetScale for equal normal
    -- and focus textures, which otherwise discards ForceImageSize.
    button.scale_on_focus = false
    button:ForceImageSize(size, size)
end

function Layout.ConfigurePanel(panel)
    if panel == nil then return end

    ConfigureButton(panel.collapse, TOGGLE_SIZE)
    if panel.collapse ~= nil then panel.collapse:SetPosition(0, 0, 0) end

    for index, skill in ipairs(SkillPanel.DISPLAY_ORDER) do
        local button = panel.icons ~= nil and panel.icons[skill] or nil
        ConfigureButton(button, SKILL_ICON_SIZE)
        if button ~= nil then
            button:SetPosition(index * ICON_GAP, 0, 0)
        end
    end

    local tooltip = panel.skill_tooltip_text or panel.tooltip
    if tooltip ~= nil then tooltip:SetPosition(160, 52, 0) end
end

local function GetOrCreateRoot(controls)
    if controls.eva_bottomleft_root == nil then
        controls.eva_bottomleft_root = controls:AddChild(Widget("EvaBottomLeftRoot"))
        controls.eva_bottomleft_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        controls.eva_bottomleft_root:SetMaxPropUpscale(MAX_HUD_SCALE)
        controls.eva_bottomleft_root:SetHAnchor(ANCHOR_LEFT)
        controls.eva_bottomleft_root:SetVAnchor(ANCHOR_BOTTOM)
        controls.eva_bottomleft_root:SetPosition(0, 0, 0)
    end
    if controls.eva_bottomleft_hud_root == nil then
        controls.eva_bottomleft_hud_root = controls.eva_bottomleft_root:AddChild(
            Widget("EvaBottomLeftHUDRoot"))
    end
    TrackHUDScale(controls)
    UpdateHUDScale(controls)
    return controls.eva_bottomleft_hud_root
end

function Layout.Apply(controls)
    local owner = controls ~= nil and controls.owner or nil
    if owner == nil or owner.prefab ~= "eva" then return false end

    local status = controls.status or controls.statusdisplays
    local badge = owner.soulhud or (status ~= nil and status.hud_souls or nil)
    local panel = controls.eva_skillpanel
    if status == nil or badge == nil or panel == nil then return false end

    local root = GetOrCreateRoot(controls)
    status:AddChild(badge)
    badge:SetPosition(BADGE_X, BADGE_Y, 0)
    root:AddChild(panel)
    panel:SetPosition(PANEL_X, ROW_Y, 0)
    Layout.ConfigurePanel(panel)
    return true
end

function Layout.Install(add_class_post_construct)
    add_class_post_construct("widgets/controls", function(controls)
        local owner = controls.owner
        if owner == nil or owner.prefab ~= "eva" or controls.inst == nil then return end
        controls.inst:DoTaskInTime(0, function()
            if controls.inst == nil or controls.inst.IsValid == nil
                or controls.inst:IsValid() then
                Layout.Apply(controls)
            end
        end)
    end)
end

return Layout
