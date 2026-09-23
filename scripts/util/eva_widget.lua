local soulbadge = GLOBAL.require "widgets/eva_badge"
local huddrag = GLOBAL.require "util/eva_hud_drag"

local function SoulMax(owner)
    local maximum = owner.maxsouls ~= nil and owner.maxsouls:value() or 0
    return maximum > 0 and maximum or 100
end

local function UpdateSoulBadge(owner)
    if owner.UpdateBadges ~= nil then
        owner.UpdateBadges()
    end
end

local function UpdateSoulVisibility(owner, ghostmode)
    if owner.soulhud == nil then
        return
    end
    if ghostmode == nil then
        ghostmode = owner:HasTag("playerghost")
    end
    if ghostmode then
        owner.soulhud:Hide()
    else
        owner.soulhud:Show()
    end
end

local function onstatusdisplaysconstruct(self)
    if self.owner.prefab ~= "eva" then
        return
    end

    self.hud_souls = self:AddChild(soulbadge(self, self.owner))
    self.hud_souls:SetPosition(-80, -40, 0)
    huddrag.Attach(self.hud_souls)
    self.owner.soulhud = self.hud_souls
    self.owner.UpdateBadges = function()
        local current = self.owner.currentsouls ~= nil and self.owner.currentsouls:value() or 0
        local maximum = SoulMax(self.owner)
        self.hud_souls:SetPercent(current / maximum, maximum)
    end

    -- player_classified calls StatusDisplays:SetGhostMode on every client when
    -- its replicated isghostmode netvar changes.
    local SetGhostMode = self.SetGhostMode
    self.SetGhostMode = function(status, ghostmode, ...)
        local result = SetGhostMode(status, ghostmode, ...)
        UpdateSoulVisibility(status.owner, ghostmode)
        return result
    end

    UpdateSoulBadge(self.owner)
    UpdateSoulVisibility(self.owner, self.isghostmode == true)
end

AddClassPostConstruct("widgets/statusdisplays", onstatusdisplaysconstruct)

AddPlayerPostInit(function(inst)
    if inst.prefab ~= "eva" then
        return
    end

    inst.currentsouls = GLOBAL.net_ushortint(inst.GUID, "eva_souls.current", "soulsdirty")
    inst.maxsouls = GLOBAL.net_ushortint(inst.GUID, "eva_souls.max", "soulsdirty")
    inst.eva_level = GLOBAL.net_uint(inst.GUID, "eva.level", "eva_leveldirty")
    inst:ListenForEvent("soulsdirty", UpdateSoulBadge)

    if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("eva_souls")
    end
end)
