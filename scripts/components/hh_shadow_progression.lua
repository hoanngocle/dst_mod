local ShadowDefs = require("enums/hh_shadow_progression_defs")

local SAVE_VERSION = ShadowDefs.VERSION
local MAX_AWARD_PER_EVENT = 1000

local HHShadowProgression = Class(function(self, inst)
    self.inst = inst
    self.profiles = {}

    if TheWorld.ismastersim then
        self.inst:DoTaskInTime(0, function()
            if self.inst:IsValid() then
                self:ReconcileOwnedProfiles()
                self:SyncAll()
            end
        end)
    end
end)

local function ClampInteger(value, minimum, maximum)
    value = math.floor(tonumber(value) or minimum)
    return math.max(minimum, math.min(maximum, value))
end

local function UnlockTalentsForLevel(prefab, profile, level)
    local unlocked = {}
    local def = ShadowDefs.Get(prefab)
    if def == nil or profile == nil then
        return unlocked
    end

    for index, talent in ipairs(def.talents) do
        if talent.level <= level and not ShadowDefs.HasTalent(profile.talents, index) then
            profile.talents = ShadowDefs.AddTalent(profile.talents, index)
            table.insert(unlocked, talent)
        end
    end
    return unlocked
end

function HHShadowProgression:GetProfile(prefab)
    return self.profiles[prefab]
end

function HHShadowProgression:EnsureProfile(prefab, should_sync)
    if not ShadowDefs.IsSupported(prefab) then return nil end
    local profile = self.profiles[prefab]
    if profile == nil then
        profile = {
            level = 1,
            exp = 0,
            skill_points = 0,
            talents = 0,
        }
        self.profiles[prefab] = profile
        if should_sync ~= false then
            self:SyncProfile(prefab)
        end
    else
        -- Compatibility for profiles created before talent unlocks became automatic.
        profile.skill_points = 0
        UnlockTalentsForLevel(prefab, profile, profile.level)
    end
    return profile
end

function HHShadowProgression:ReconcileOwnedProfiles()
    local manager = self.inst.components.hh_shadow_manager
    if manager == nil or manager.shadows == nil then return end
    for _, shadow_data in ipairs(manager.shadows) do
        if ShadowDefs.IsSupported(shadow_data.prefab) then
            self:EnsureProfile(shadow_data.prefab, false)
        end
    end
end

function HHShadowProgression:Owns(prefab)
    local manager = self.inst.components.hh_shadow_manager
    return manager ~= nil and manager:HasShadowPrefab(prefab)
end

function HHShadowProgression:SyncProfile(prefab)
    if not TheWorld.ismastersim then return end
    local profile = self.profiles[prefab]
    local fields = {
        level = profile ~= nil and profile.level or 0,
        exp = profile ~= nil and profile.exp or 0,
        points = 0,
        talents = profile ~= nil and profile.talents or 0,
    }
    for field, value in pairs(fields) do
        local net_name = ShadowDefs.GetNetField(prefab, field)
        local netvar = net_name ~= nil and self.inst[net_name] or nil
        if netvar ~= nil then
            netvar:set(value)
        end
    end
end

function HHShadowProgression:SyncAll()
    for _, prefab in ipairs(ShadowDefs.ORDER) do
        self:SyncProfile(prefab)
    end
end

function HHShadowProgression:GetStats(prefab)
    local profile = self.profiles[prefab]
    return ShadowDefs.CalculateStats(
        prefab,
        profile ~= nil and profile.level or 1,
        profile ~= nil and profile.talents or 0
    )
end

function HHShadowProgression:HasTalent(prefab, talent_id)
    local profile = self.profiles[prefab]
    return profile ~= nil and ShadowDefs.HasTalent(profile.talents, talent_id, prefab)
end

function HHShadowProgression:RefreshActiveShadow(prefab)
    local manager = self.inst.components.hh_shadow_manager
    if manager == nil then return end
    for _, shadow_data in ipairs(manager.shadows) do
        if shadow_data.prefab == prefab and shadow_data.is_spawned
            and shadow_data.inst ~= nil and shadow_data.inst:IsValid()
            and shadow_data.inst.components.hh_shadow_unit ~= nil then
            shadow_data.inst.components.hh_shadow_unit:Refresh()
        end
    end
end

function HHShadowProgression:AwardExp(prefab, amount, reason)
    local profile = self.profiles[prefab]
    if profile == nil or not self:Owns(prefab) then return false end
    if profile.level >= ShadowDefs.GetMaxLevel() then return false end

    local stats = self:GetStats(prefab)
    amount = ClampInteger((tonumber(amount) or 0) * (stats.xp_mult or 1), 0, MAX_AWARD_PER_EVENT)
    if amount <= 0 then return false end

    profile.exp = profile.exp + amount
    local old_level = profile.level
    local unlocked_talents = {}
    while profile.level < ShadowDefs.GetMaxLevel() do
        local required = ShadowDefs.GetExpForNextLevel(profile.level)
        if profile.exp < required then break end
        profile.exp = profile.exp - required
        profile.level = profile.level + 1
        local level_unlocks = UnlockTalentsForLevel(prefab, profile, profile.level)
        for _, talent in ipairs(level_unlocks) do
            table.insert(unlocked_talents, talent)
        end
    end
    if profile.level >= ShadowDefs.GetMaxLevel() then
        profile.exp = 0
    end

    self:SyncProfile(prefab)
    if profile.level ~= old_level then
        self:RefreshActiveShadow(prefab)
        local def = ShadowDefs.Get(prefab)
        if self.inst.components.talker ~= nil and def ~= nil then
            self.inst.components.talker:Say(def.name .. " đã đạt cấp " .. tostring(profile.level) .. "!")
        end
    end
    self.inst:PushEvent("hh_shadow_exp_awarded", {
        prefab = prefab,
        amount = amount,
        reason = reason,
        level = profile.level,
    })
    if #unlocked_talents > 0 and self.inst.components.talker ~= nil then
        local def = ShadowDefs.Get(prefab)
        local unlock_prefix = string.char(
            32, 196, 145, 195, 163, 32,
            109, 225, 187, 159, 32,
            107, 104, 195, 179, 97, 32,
            107, 225, 187, 185, 32,
            110, 196, 131, 110, 103, 32
        )
        local notifications = {}
        for _, talent in ipairs(unlocked_talents) do
            table.insert(notifications,
                string.format('%s%s%s %s', def.name, unlock_prefix, talent.name, string.char(33)))
        end
        self.inst.components.talker:Say(table.concat(notifications, string.char(10)))
    end
    return true
end

function HHShadowProgression:PurchaseTalent(prefab, talent_id)
    -- Legacy RPC compatibility: milestones are now unlocked automatically.
    do
        return false, 'Talent unlocks automatically at level milestones.'
    end
    --[[
    if type(prefab) ~= "string" or type(talent_id) ~= "string"
        or not ShadowDefs.IsSupported(prefab) or not self:Owns(prefab) then
        return false, "Đệ tử không hợp lệ."
    end
    local profile = self.profiles[prefab]
    local talent, index = ShadowDefs.GetTalent(prefab, talent_id)
    if profile == nil or talent == nil then
        return false, "Nâng cấp không hợp lệ."
    end
    if ShadowDefs.HasTalent(profile.talents, index) then
        return false, "Nâng cấp này đã được mở."
    end
    if profile.level < talent.level then
        return false, "Cần đạt cấp " .. tostring(talent.level) .. "."
    end
    if index > 1 and not ShadowDefs.HasTalent(profile.talents, index - 1) then
        return false, "Cần mở nâng cấp trước đó."
    end
    if profile.skill_points <= 0 then
        return false, "Không đủ điểm kỹ năng."
    end

    profile.talents = ShadowDefs.AddTalent(profile.talents, index)
    profile.skill_points = profile.skill_points - 1
    self:SyncProfile(prefab)
    self:RefreshActiveShadow(prefab)
    return true, "Đã mở " .. talent.name .. "."
    ]]
end

function HHShadowProgression:BindShadow(shadow, prefab)
    if shadow == nil or not shadow:IsValid() or not ShadowDefs.IsSupported(prefab) then
        return false
    end
    self:EnsureProfile(prefab)
    if shadow.components.hh_shadow_unit == nil then
        shadow:AddComponent("hh_shadow_unit")
    end
    shadow.components.hh_shadow_unit:Bind(self.inst, prefab)
    return true
end

function HHShadowProgression:ShouldWaiveMana(prefab, shadow_data)
    local stats = self:GetStats(prefab)
    local every = stats.mana_free_every
    if every == nil or every <= 1 or shadow_data == nil then
        return false
    end
    shadow_data._hh_progression_mana_counter = (shadow_data._hh_progression_mana_counter or 0) + 1
    if shadow_data._hh_progression_mana_counter >= every then
        shadow_data._hh_progression_mana_counter = 0
        return true
    end
    return false
end

function HHShadowProgression:GetUpkeepInterval(prefab, base)
    return math.max(.5, (base or 0) + (self:GetStats(prefab).upkeep_interval_bonus or 0))
end

function HHShadowProgression:GetHacanhAttacksPerMana(base)
    return math.max(1, math.floor((base or 1) + (self:GetStats("hh_hacanh_shadow").attacks_per_mana_bonus or 0)))
end

function HHShadowProgression:OnSave()
    local data = {
        version = SAVE_VERSION,
        profiles = {},
    }
    for _, prefab in ipairs(ShadowDefs.ORDER) do
        local profile = self.profiles[prefab]
        if profile ~= nil then
            data.profiles[prefab] = {
                level = profile.level,
                exp = profile.exp,
                skill_points = profile.skill_points,
                talents = profile.talents,
            }
        end
    end
    return data
end

function HHShadowProgression:OnLoad(data)
    self.profiles = {}
    local profiles = data ~= nil and data.profiles or nil
    if type(profiles) == "table" then
        for _, prefab in ipairs(ShadowDefs.ORDER) do
            local saved = profiles[prefab]
            if type(saved) == "table" then
                local level = ClampInteger(saved.level, 1, ShadowDefs.GetMaxLevel())
                local max_mask = 2 ^ 6 - 1
                local saved_talents = ClampInteger(saved.talents, 0, max_mask)
                local talents = 0
                local def = ShadowDefs.Get(prefab)
                for index, talent in ipairs(def.talents) do
                    if talent.level <= level and ShadowDefs.HasTalent(saved_talents, index)
                        and (index == 1 or ShadowDefs.HasTalent(talents, index - 1)) then
                        talents = ShadowDefs.AddTalent(talents, index)
                    end
                end
                local spent = ShadowDefs.CountTalents(talents)
                local earned = math.floor(level / 5)
                local available = math.max(0, earned - spent)
                local profile = {
                    level = level,
                    exp = level >= ShadowDefs.GetMaxLevel()
                        and 0
                        or ClampInteger(saved.exp, 0, ShadowDefs.GetExpForNextLevel(level) - 1),
                    talents = talents,
                    skill_points = saved.skill_points == nil
                        and available
                        or ClampInteger(saved.skill_points, 0, available),
                }
                profile.talents = 0
                profile.skill_points = 0
                UnlockTalentsForLevel(prefab, profile, level)
                self.profiles[prefab] = profile
            end
        end
    end
    self.inst:DoTaskInTime(0, function()
        if self.inst:IsValid() then
            self:ReconcileOwnedProfiles()
            self:SyncAll()
        end
    end)
end

function HHShadowProgression:GetDebugString()
    local values = {}
    for _, prefab in ipairs(ShadowDefs.ORDER) do
        local profile = self.profiles[prefab]
        if profile ~= nil then
            table.insert(values, string.format("%s=L%d/%dXP/%dP",
                prefab, profile.level, profile.exp, profile.skill_points))
        end
    end
    return table.concat(values, ", ")
end

return HHShadowProgression
