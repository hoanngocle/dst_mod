local HHGuideLock = {}

local MOD_NAME = "Solo Leveling"
local MOD_HUD_FOCUS_ID = "hh_guide_modal"

function HHGuideLock.Get(owner)
    owner = owner or ThePlayer
    if owner == nil or (owner.IsValid ~= nil and not owner:IsValid()) then
        return nil
    end

    local hud = owner.HUD
    local controls = hud ~= nil and hud.controls or nil
    local guide = controls ~= nil and controls.hh_help_ui or nil
    if guide == nil or guide.owner ~= owner or guide.IsGuideOpen == nil then
        return nil
    end

    return guide:IsGuideOpen() and guide or nil
end

function HHGuideLock.IsOpen(owner)
    return HHGuideLock.Get(owner) ~= nil
end

-- PlayerHud exposes this client-local focus channel for modal HUD widgets.
-- It is the same boundary used by DST's SetModHUDFocus helper, without
-- touching the server-side playercontroller netvar.
function HHGuideLock.SetHudInputFocus(owner, hasfocus)
    owner = owner or ThePlayer
    if owner == nil or (owner.IsValid ~= nil and not owner:IsValid()) then
        return false
    end

    local hud = owner.HUD
    if hud == nil or hud.SetModFocus == nil then
        return false
    end

    hud:SetModFocus(MOD_NAME, MOD_HUD_FOCUS_ID, hasfocus == true)
    return true
end

return HHGuideLock
