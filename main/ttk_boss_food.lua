local defs = require("ttk_boss_defs")

if rawget(env, "_ttk_boss_food_loaded") then return end
env._ttk_boss_food_loaded = true

local FOOD_KEYS = {}
for _, key in ipairs(defs.order) do
    if defs.bosses[key] ~= nil and defs.bosses[key].food ~= nil then
        FOOD_KEYS[#FOOD_KEYS + 1] = key
    end
end

PrefabFiles = PrefabFiles or {}
local has_prefab = false
for _, prefab in ipairs(PrefabFiles) do
    if prefab == "ttk_boss_cores" then has_prefab = true end
end
if not has_prefab then PrefabFiles[#PrefabFiles + 1] = "ttk_boss_cores" end

Assets = Assets or {}
for _, key in ipairs(FOOD_KEYS) do
    local food = defs.bosses[key].food
    Assets[#Assets + 1] = Asset("ATLAS", "images/inventoryimages/" .. food .. ".xml")
    Assets[#Assets + 1] = Asset("IMAGE", "images/inventoryimages/" .. food .. ".tex")
    RegisterInventoryItemAtlas("images/inventoryimages/" .. food .. ".xml", food .. ".tex")
    STRINGS.NAMES[string.upper(food)] = defs.bosses[key].food_name
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(food)] = "Linh lực của cường địch vẫn còn ngưng tụ bên trong."
end

local function GetProgress(inst)
    return inst ~= nil and inst.components ~= nil and inst.components.ttk_bossprogress or nil
end

local function GetMaxBonus(inst, stat)
    local progress = GetProgress(inst)
    return progress ~= nil and progress:GetMaxBonus(stat) or 0
end

local function RestoreCurrent(component, current, maxvalue, kind)
    current = math.max(0, math.min(tonumber(current) or 0, tonumber(maxvalue) or 0))
    if kind == "health" and component.SetCurrentHealth ~= nil then
        local cap = component.GetMaxWithPenalty ~= nil and component:GetMaxWithPenalty() or maxvalue
        component:SetCurrentHealth(math.min(current, cap))
    elseif component.SetPercent ~= nil and maxvalue > 0 then
        component:SetPercent(current / maxvalue)
    else
        component.current = current
    end
end

local function InstallLoadedCurrentWrapper(component, field)
    if component._ttk_bossprogress_load_wrapped or component.OnLoad == nil then return end
    component._ttk_bossprogress_load_wrapped = true
    local old_load = component.OnLoad
    component.OnLoad = function(self, data, ...)
        local loaded = data ~= nil and tonumber(data[field]) or nil
        if loaded ~= nil then self._ttk_bossprogress_loaded_current = loaded end
        return old_load(self, data, ...)
    end
end

local function InstallMaxWrapper(component, kind, setmax, maxfield, currentfield)
    if component._ttk_bossprogress_max_wrapped or component[setmax] == nil then return end
    component._ttk_bossprogress_max_wrapped = true
    component._ttk_bossprogress_base_max = tonumber(component[maxfield]) or 0
    local old_setmax = component[setmax]

    component[setmax] = function(self, value, ...)
        value = tonumber(value) or 0
        if not self._ttk_bossprogress_internal then
            local bonus = GetMaxBonus(self.inst, kind)
            -- SetMax normally receives a new base maximum.  The explicit
            -- flag is used only around a known Solo caller that mutates the
            -- already-visible maximum for a timed dungeon effect.
            self._ttk_bossprogress_base_max = self._ttk_bossprogress_input_is_visible
                and value - bonus or value
            value = self._ttk_bossprogress_base_max + bonus
        end
        return old_setmax(self, value, ...)
    end

    component._ttk_bossprogress_refresh = function(self)
        local current = self._ttk_bossprogress_loaded_current
        if current == nil then current = self[currentfield] end
        local value = math.max(1, (self._ttk_bossprogress_base_max or 0) + GetMaxBonus(self.inst, kind))
        self._ttk_bossprogress_internal = true
        old_setmax(self, value)
        self._ttk_bossprogress_internal = nil
        RestoreCurrent(self, current, value, kind)
        self._ttk_bossprogress_loaded_current = nil
    end
end

-- hh_dungeon_effects applies/removes player_health by passing
-- health.maxhealth +/- a stored delta to SetMaxHealth.  Mark just that call
-- scope as visible-max input; every normal character/stat recalculation keeps
-- the public SetMaxHealth contract of accepting a fresh base maximum.
AddComponentPostInit("hh_dungeon_effects", function(component)
    if component._ttk_bossprogress_health_wrapped or component.RefreshTargets == nil then return end
    component._ttk_bossprogress_health_wrapped = true
    local old_refresh = component.RefreshTargets
    component.RefreshTargets = function(self, ...)
        local health = self.inst ~= nil and self.inst.components ~= nil
            and self.inst.components.health or nil
        local previous = health ~= nil and health._ttk_bossprogress_input_is_visible or nil
        if health ~= nil then health._ttk_bossprogress_input_is_visible = true end
        local results = {pcall(old_refresh, self, ...)}
        if health ~= nil then health._ttk_bossprogress_input_is_visible = previous end
        if not results[1] then error(results[2], 0) end
        return unpack(results, 2)
    end
end)

AddComponentPostInit("health", function(component)
    InstallMaxWrapper(component, "health", "SetMaxHealth", "maxhealth", "currenthealth")
    InstallLoadedCurrentWrapper(component, "health")
end)

AddComponentPostInit("hunger", function(component)
    InstallMaxWrapper(component, "hunger", "SetMax", "max", "current")
    InstallLoadedCurrentWrapper(component, "hunger")
    -- Native Hunger:OnSave omits full hunger.  A fresh player starts at its
    -- unaugmented maximum, so that omission would lose the extra stored food.
    -- Keep the exact current value for augmented players, including full ones.
    if not component._ttk_bossprogress_save_wrapped and component.OnSave ~= nil then
        component._ttk_bossprogress_save_wrapped = true
        local old_save = component.OnSave
        component.OnSave = function(self, ...)
            local data, references = old_save(self, ...)
            if GetMaxBonus(self.inst, "hunger") > 0 then
                data = data or {}
                data.hunger = self.current
            end
            return data, references
        end
    end
end)

AddComponentPostInit("sanity", function(component)
    InstallMaxWrapper(component, "sanity", "SetMax", "max", "current")
    InstallLoadedCurrentWrapper(component, "current")
end)

AddComponentPostInit("hh_player", function(component)
    if component._ttk_bossprogress_effect_wrapped or component.GetEffectValueByKey == nil then return end
    component._ttk_bossprogress_effect_wrapped = true
    local old_get = component.GetEffectValueByKey
    component.GetEffectValueByKey = function(self, key, ...)
        local base = old_get(self, key, ...) or 0
        local progress = GetProgress(self.inst)
        local value = base + (progress ~= nil and progress:GetEffectBonus(key) or 0)
        return self:ClampEffectValue(key, value)
    end
end)

AddComponentPostInit("hh_mana", function(component)
    if component._ttk_bossprogress_mana_wrapped or component.RecalculateMax == nil then return end
    component._ttk_bossprogress_mana_wrapped = true
    local old_recalculate = component.RecalculateMax
    component.RecalculateMax = function(self, fill_initial, ...)
        local previous = self.current
        old_recalculate(self, fill_initial, ...)
        local base = self.max
        self._ttk_bossprogress_base_max = base
        self.max = math.max(1, base + GetMaxBonus(self.inst, "mana"))
        self.current = fill_initial and self.max or math.max(0, math.min(previous, self.max))
        if self.Sync ~= nil then self:Sync() end
    end
    component._ttk_bossprogress_refresh = function(self)
        local loaded = self._ttk_bossprogress_loaded_current
        self:RecalculateMax(false)
        if loaded ~= nil then
            self.current = math.max(0, math.min(loaded, self.max))
            self._ttk_bossprogress_loaded_current = nil
            if self.Sync ~= nil then self:Sync() end
        end
    end
    InstallLoadedCurrentWrapper(component, "current")
end)

AddPlayerPostInit(function(inst)
    for _, key in ipairs(FOOD_KEYS) do
        -- Counts reach 10; net_tinybyte only carries 0..7 in DST.
        inst["ttk_bossprogress_" .. key] = net_smallbyte(
            inst.GUID,
            "ttk_bossprogress." .. key,
            "ttk_bossprogressdirty"
        )
    end

    inst.GetTtkBossProgressCount = function(player, key)
        local progress = GetProgress(player)
        if progress ~= nil then return progress:GetCount(key) end
        local netvar = player["ttk_bossprogress_" .. tostring(key)]
        return netvar ~= nil and netvar:value() or 0
    end

    if not TheWorld.ismastersim then return end
    if inst.components.ttk_bossprogress == nil then inst:AddComponent("ttk_bossprogress") end
    inst.components.ttk_bossprogress:Refresh()
end)
