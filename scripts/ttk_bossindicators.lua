local M = {}

local SCAN_INTERVAL = 0.5
local RANGE_MULTIPLIER = 1.5
local SOURCE_ATLAS = "images/ttk_bossindicators.xml"
local FALLBACK_ATLAS = "images/avatars.xml"
local FALLBACK_IMAGE = "avatar_unknown.tex"

local SOURCE_ICONS = {
    antlion = "Antlion.tex",
    bearger = "bearger.tex",
    deerclops = "deerclops.tex",
    dragonfly = "dragonfly.tex",
    klaus = "klaus.tex",
    minotaur = "minotaur.tex",
    minotau = "minotaur.tex",
    moose = "moose.tex",
    toadstool = "toadstool.tex",
    toadstool_dark = "toadstool.tex",
}

-- Explicit entries document the supported large-boss surface. Unknown epic
-- prefabs still use the safe fallback below so later game and mod bosses work.
local KNOWN_MAJOR_BOSSES = {
    deerclops = true, bearger = true, dragonfly = true, moose = true,
    minotaur = true, toadstool = true, toadstool_dark = true, antlion = true,
    klaus = true, beequeen = true, crabking = true, malbatross = true,
    eyeofterror = true, twinofterror1 = true, twinofterror2 = true,
    alterguardian_phase1 = true, alterguardian_phase2 = true,
    alterguardian_phase3 = true, alterguardian_phase4_lunarrift = true,
    daywalker = true, daywalker2 = true, sharkboi = true,
    sharkboi_water = true, stalker = true, stalker_atrium = true,
    stalker_forest = true, worm_boss = true, vault_pillar_guard = true,
    wagboss_robot = true, mutatedbearger = true, mutateddeerclops = true,
    mutatedwarg = true,

    -- Bosses from the Solo system integrated into Phàm Nhân.
    hh_sharkboi = true, hh_beetle_pig = true, hh_dual_wield_pig = true,
    hh_igris_dungeon = true, hh_beru_dungeon = true, minotau = true,
    ttk_baihu = true, ttk_jfsn = true, ttk_qlch = true,
    ttk_qxdx = true, ttk_futu = true, ttk_spiderqueen = true,
    ttk_ziyunboss = true, ttk_stalke_fuben = true, ttk_deerclops_ziyun = true,
}

local KNOWN_MINOR_BOSSES = {
    fruitfly = true, lordfruitfly = true,
    spiderqueen = true, leif = true, leif_sparse = true,
    warg = true, warglet = true, claywarg = true, gingerbreadwarg = true,
    shadow_knight = true, shadow_bishop = true, shadow_rook = true,
}

local REJECT_TAGS = {
    "INLIMBO", "NOCLICK", "FX", "player", "playerghost", "companion",
    "pet", "shadow_minion", "shadowminion", "dead", "hiding",
    "nobossindicator",
}

local function has_tag(target, tag)
    return target ~= nil and target.HasTag ~= nil and target:HasTag(tag)
end

local function is_dead(target)
    local health = target ~= nil and target.replica ~= nil and target.replica.health or nil
    return health ~= nil and health.IsDead ~= nil and health:IsDead()
end

function M.ShouldTrack(target, globals)
    if target == nil or target.IsValid == nil or not target:IsValid() or target._ttk_boss_auxiliary then
        return false
    end
    local prefab = target.prefab
    if prefab == nil or KNOWN_MINOR_BOSSES[prefab] then
        return false
    end
    for _, tag in ipairs(REJECT_TAGS) do
        if has_tag(target, tag) then
            return false
        end
    end
    if not KNOWN_MAJOR_BOSSES[prefab] and not has_tag(target, "epic") then
        return false
    end
    if is_dead(target) then
        return false
    end
    if target.entity ~= nil and target.entity.IsVisible ~= nil and not target.entity:IsVisible() then
        return false
    end
    return target.Transform ~= nil and target.Transform.GetWorldPosition ~= nil
end

local function title_case_prefab(prefab)
    local text = (prefab or "boss"):gsub("_", " ")
    return (text:gsub("(%a)([%w']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end))
end

function M.GetDisplayName(target, globals)
    if target ~= nil and target.GetDisplayName ~= nil then
        local ok, name = pcall(target.GetDisplayName, target)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    local prefab = target ~= nil and target.prefab or nil
    local names = globals ~= nil and globals.STRINGS ~= nil and globals.STRINGS.NAMES or nil
    local localized = names ~= nil and prefab ~= nil and names[string.upper(prefab)] or nil
    return type(localized) == "string" and localized ~= "" and localized or title_case_prefab(prefab)
end

function M.GetIndicatorConfig(target, globals)
    local icon = SOURCE_ICONS[target ~= nil and target.prefab or ""]
    return {
        atlas = icon ~= nil and SOURCE_ATLAS or FALLBACK_ATLAS,
        image = icon or FALLBACK_IMAGE,
        name = M.GetDisplayName(target, globals),
    }
end

local function remove_indicator(hud, target)
    local indicators = hud._ttk_bossindicators
    local record = indicators ~= nil and indicators[target] or nil
    if record == nil then
        return
    end
    indicators[target] = nil
    if target ~= nil and target.RemoveEventCallback ~= nil then
        target:RemoveEventCallback("death", record.onremove)
        target:RemoveEventCallback("onremove", record.onremove)
    end
    if record.widget ~= nil and record.widget.Kill ~= nil then
        record.widget:Kill()
    end
end

local function add_indicator(hud, target, globals, factory)
    local widget = factory(target, M.GetIndicatorConfig(target, globals))
    if widget == nil then
        return
    end
    local function onremove()
        remove_indicator(hud, target)
    end
    hud._ttk_bossindicators[target] = {widget = widget, onremove = onremove}
    if target.ListenForEvent ~= nil then
        target:ListenForEvent("death", onremove)
        target:ListenForEvent("onremove", onremove)
    end
end

function M.RefreshHUD(hud, globals, factory)
    if hud == nil or hud.owner == nil or hud.owner.Transform == nil
        or globals == nil or globals.TheSim == nil or globals.TheSim.FindEntities == nil then
        return
    end
    hud._ttk_bossindicators = hud._ttk_bossindicators or {}
    local x, y, z = hud.owner.Transform:GetWorldPosition()
    local tuning = globals.TUNING or {}
    local range = (tuning.MAX_INDICATOR_RANGE or 30) * RANGE_MULTIPLIER
    local nearby = globals.TheSim:FindEntities(x, y, z, range, {"epic"}, REJECT_TAGS)
    local wanted = {}
    for _, target in ipairs(nearby or {}) do
        if M.ShouldTrack(target, globals) then
            local onscreen = target.entity ~= nil
                and target.entity.FrustumCheck ~= nil
                and target.entity:FrustumCheck()
            if not onscreen then
                wanted[target] = true
                if hud._ttk_bossindicators[target] == nil then
                    add_indicator(hud, target, globals, factory)
                end
            end
        end
    end
    local stale = {}
    for target in pairs(hud._ttk_bossindicators) do
        if not wanted[target] then
            stale[#stale + 1] = target
        end
    end
    for _, target in ipairs(stale) do
        remove_indicator(hud, target)
    end
end

function M.CleanupHUD(hud)
    if hud == nil or hud._ttk_bossindicators == nil then
        return
    end
    local targets = {}
    for target in pairs(hud._ttk_bossindicators) do
        targets[#targets + 1] = target
    end
    for _, target in ipairs(targets) do
        remove_indicator(hud, target)
    end
    hud._ttk_bossindicators = nil
end

function M.Install(env)
    local globals = env ~= nil and env.GLOBAL or nil
    if globals == nil or globals.TheNet == nil or globals.TheNet:IsDedicated() then
        return false
    end
    if rawget(globals, "TTK_BOSS_INDICATORS_INSTALLED") then
        return false
    end
    rawset(globals, "TTK_BOSS_INDICATORS_INSTALLED", true)
    env.AddClassPostConstruct("screens/playerhud", function(hud)
        local BossIndicator = require "widgets/ttk_bossindicator"
        local function factory(target, config)
            return hud.under_root:AddChild(BossIndicator(hud.owner, target, config))
        end
        hud._ttk_bossindicator_elapsed = SCAN_INTERVAL
        local old_update = hud.OnUpdate
        hud.OnUpdate = function(self, dt)
            if old_update ~= nil then
                old_update(self, dt)
            end
            self._ttk_bossindicator_elapsed = self._ttk_bossindicator_elapsed + (dt or 0)
            if self._ttk_bossindicator_elapsed >= SCAN_INTERVAL then
                self._ttk_bossindicator_elapsed = 0
                M.RefreshHUD(self, globals, factory)
            end
        end
        local old_destroy = hud.OnDestroy
        hud.OnDestroy = function(self)
            M.CleanupHUD(self)
            if old_destroy ~= nil then
                old_destroy(self)
            end
        end
    end)
    return true
end

return M
