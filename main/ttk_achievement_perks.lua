-- Scoped adapters for successful engine actions. Never change global tuning.
local G = GLOBAL
local Effects = require("achievement/ttk_perk_effects")
local Crafts = require("achievement/ttk_perk_crafts")
if rawget(env, "_ttk_achievement_perks_registered") then return end
rawset(env, "_ttk_achievement_perks_registered", true)

table.insert(PrefabFiles, "ttk_achievement_placers")
Crafts.Register(env)

local function Master()
    return G.TheWorld ~= nil and G.TheWorld.ismastersim
end

local function Hook(name, install)
    AddComponentPostInit(name, function(component)
        if not Master() or component._ttk_achievement_hook then return end
        component._ttk_achievement_hook = true
        install(component)
    end)
end

Hook("stewer", function(self)
    local previous = self.StartCooking
    self.StartCooking = function(stewer, doer, ...)
        local was_cooking = stewer:IsCooking()
        local result = previous(stewer, doer, ...)
        -- StartCooking returns nil; transition + product prove it succeeded.
        if not was_cooking and stewer:IsCooking() and stewer.product ~= nil and Effects.Has(doer, "cook_faster") then
            stewer:LongUpdate(math.max(0, stewer:GetTimeToCook()))
        end
        return result
    end
end)

Hook("fishingrod", function(self)
    local previous = self.WaitForFish
    self.WaitForFish = function(rod, ...)
        if not Effects.Has(rod.fisherman, "fish_faster") then return previous(rod, ...) end
        local low, high = rod.minwaittime, rod.maxwaittime
        rod:SetWaitTimes(0, 0)
        local ok, result = pcall(previous, rod, ...)
        rod:SetWaitTimes(low, high)
        if not ok then error(result) end
        return result
    end
end)

Hook("healer", function(self)
    local previous = self.Heal
    self.Heal = function(healer, target, doer, ...)
        local health = target ~= nil and target.components.health or nil
        local efficiency = doer ~= nil and doer.components.efficientuser or nil
        local multiplier = efficiency ~= nil and efficiency:GetMultiplier(G.ACTIONS.HEAL) or 1
        local bonus = health ~= nil and health.canheal and Effects.Has(target, "double_healed")
            and not Effects.Has(doer, "double_healed") and healer.health * multiplier or 0
        local result, reason = previous(healer, target, doer, ...)
        if result == true and bonus > 0 and not health:IsDead() then
            health:DoDelta(bonus, false, "ttk_achievement_double_healed")
        end
        return result, reason
    end
end)

local function BlessCage(cage)
    if cage.prefab ~= "birdcage" or cage._ttk_achievement_eternal_cage then return end
    -- Preserver is the native perish-rate provider for occupied livestock.
    if cage.components.preserver == nil then cage:AddComponent("preserver") end
    local previous = cage.components.preserver.perish_rate_multiplier
    cage.components.preserver:SetPerishRateMultiplier(function(inst, item)
        if item ~= nil and item:HasTag("small_livestock") then return 0 end
        return type(previous) == "function" and previous(inst, item) or previous
    end)
    cage._ttk_achievement_eternal_cage = true
end

AddPrefabPostInit("birdcage", function(inst)
    if not Master() then return end
    local save, load = inst.OnSave, inst.OnLoad
    inst.OnSave = function(cage, data, ...)
        local refs = save ~= nil and save(cage, data, ...) or nil
        data.ttk_achievement_eternal_cage = cage._ttk_achievement_eternal_cage or nil
        return refs
    end
    inst.OnLoad = function(cage, data, ...)
        if load ~= nil then load(cage, data, ...) end
        if data ~= nil and data.ttk_achievement_eternal_cage then BlessCage(cage) end
    end
    inst:ListenForEvent("onbuilt", function(cage, data)
        if data ~= nil and Effects.Has(data.builder, "eternal_cage") then BlessCage(cage) end
    end)
end)

local store = G.ACTIONS.STORE.fn
G.ACTIONS.STORE.fn = function(act)
    local ok, reason = store(act)
    if Master() and ok == true and act.target ~= nil and Effects.Has(act.doer, "eternal_cage") then
        BlessCage(act.target)
    end
    return ok, reason
end

AddStategraphPostInit("wilson", function(sg)
    for _, action in ipairs({G.ACTIONS.PICK, G.ACTIONS.TAKEITEM, G.ACTIONS.HARVEST}) do
        local handler = sg.actionhandlers[action]
        if handler ~= nil then
            local previous = handler.deststate
            handler.deststate = function(inst, act, ...)
                local state = type(previous) == "function" and previous(inst, act, ...) or previous
                local prefab = act.target ~= nil and act.target.prefab or nil
                if Effects.Has(inst, "fast_worker") and state == "dolongaction"
                    and prefab ~= "junk_pile" and prefab ~= "junk_pile_big" and prefab ~= "junk_pile_side" then
                    return "doshortaction"
                end
                return state
            end
        end
    end
end)
