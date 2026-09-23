-- Compatibility bridge for Workshop 3780347550 (Solo Leveling).
-- It observes exact successful player critical branches at the point where
-- Solo emits their label. Matching is deliberately closed over known strings.
local Bridge = {}

local CRITICAL_LABELS = {
    ["chí mạng"] = 2,
    ["chí mạng x1.5"] = 1.5,
    ["chí mạng x2"] = 2,
    ["chí mạng x3"] = 3,
    ["chí mạng x5"] = 5,
}

local function is_information(text)
    return text:find("EXP", 1, true) ~= nil
        or text:find("NHIỆM VỤ", 1, true) ~= nil
        or text:find("LEVEL", 1, true) ~= nil
        or text:find("CẤP", 1, true) ~= nil
end

local function active_for_attacker(resolver, attacker)
    for i = #resolver.stack, 1, -1 do
        if resolver.stack[i].attacker == attacker then return resolver.stack[i] end
    end
end

function Bridge.install_text(resolver)
    local ok, utils = pcall(require, "utils/hh_utils")
    if not ok or type(utils) ~= "table" or type(utils.SpawnClientStrFx) ~= "function" then
        return false
    end
    if utils._ttk_hud_original_spawn_text ~= nil then return true end

    local original = utils.SpawnClientStrFx
    utils._ttk_hud_original_spawn_text = original
    utils.SpawnClientStrFx = function(self, target, text, ...)
        local multiplier = CRITICAL_LABELS[text]
        local hit = target ~= nil and resolver.active[target.GUID] or nil
        if multiplier ~= nil and hit ~= nil then
            resolver:mark_critical(hit, multiplier)
            -- Suppress only Solo's combat critical phrase. EXP, quest, level,
            -- dodge, buffs and every other Solo notification still use original.
            return
        end
        if TUNING ~= nil and TUNING.HH_CAN_SHOW_TEXT_FX == false then
            if not is_information(text) then return end
            TUNING.HH_CAN_SHOW_TEXT_FX = true
            local result = { pcall(original, self, target, text, ...) }
            TUNING.HH_CAN_SHOW_TEXT_FX = false
            local ok = table.remove(result, 1)
            if not ok then error(result[1], 0) end
            return unpack(result)
        end
        return original(self, target, text, ...)
    end
    if type(utils.SpawnClientLevelUpFx) == "function" and utils._ttk_hud_original_level_text == nil then
        local level_original = utils.SpawnClientLevelUpFx
        utils._ttk_hud_original_level_text = level_original
        utils.SpawnClientLevelUpFx = function(self, target, text, ...)
            if TUNING ~= nil and TUNING.HH_CAN_SHOW_TEXT_FX == false then
                TUNING.HH_CAN_SHOW_TEXT_FX = true
                local result = { pcall(level_original, self, target, text, ...) }
                TUNING.HH_CAN_SHOW_TEXT_FX = false
                local ok = table.remove(result, 1)
                if not ok then error(result[1], 0) end
                return unpack(result)
            end
            return level_original(self, target, text, ...)
        end
    end
    return true
end

function Bridge.install_component_hooks(resolver, env)
    env.AddComponentPostInit("hh_monster", function(component)
        local original = component.DoAttackDamage
        if type(original) ~= "function" then return end
        component.DoAttackDamage = function(self, attacker, target, damage, ...)
            local original_get, critical_effect = self.GetEffectValueByKey, nil
            self.GetEffectValueByKey = function(owner, key, ...)
                local value = original_get(owner, key, ...)
                if key == "criticalHitEffect" then critical_effect = tonumber(value) or 0 end
                return value
            end
            local result = { pcall(original, self, attacker, target, damage, ...) }
            self.GetEffectValueByKey = original_get
            if critical_effect ~= nil and target ~= nil then
                resolver:mark_critical(resolver.active[target.GUID], 2 + critical_effect / 100)
            end
            local ok = table.remove(result, 1)
            if not ok then error(result[1], 0) end
            return unpack(result)
        end
    end)

    env.AddComponentPostInit("combat", function(component)
        local fn = component.GetAttacked
        if type(fn) ~= "function" then return end
        for i = 1, 40 do
            local name, original = debug.getupvalue(fn, i)
            if name == nil then break end
            if name == "ApplyFollowerCritical" and type(original) == "function" then
                debug.setupvalue(fn, i, function(attacker, damage)
                    local result = { pcall(original, attacker, damage) }
                    local ok = table.remove(result, 1)
                    if not ok then error(result[1], 0) end
                    if tonumber(result[1]) ~= nil and tonumber(damage) ~= nil and result[1] ~= damage then
                        resolver:mark_critical(active_for_attacker(resolver, attacker), 2)
                    end
                    return unpack(result)
                end)
                break
            end
        end
    end)
end

Bridge.install = Bridge.install_text

return Bridge
