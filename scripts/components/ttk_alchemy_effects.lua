local Defs = require("alchemy/ttk_alchemy_defs")

local DURATION_MAX = 2400
local PROTECTION = 240
local VALID_KINDS = {
    damage_mult=true, health_regen=true, lightning_damage=true, sanity_regen=true,
    speed_mult=true, damage_reduction=true, work_efficiency=true,
    cold_protection=true, heat_protection=true, lifesteal=true, hunger_rate=true,
}

local TtkAlchemyEffects = Class(function(self, inst)
    self.inst = inst
    self.active = {}
    self.deadlines = {}
    self.tasks = {}
    self.expiry_tasks = {}
    self.listeners = {}
    self.insulation = {}
    self.processing_auxiliary_hit = false
end)

local function Key(prefab) return "ttk_alchemy_" .. prefab end
local function Alive(inst)
    return inst ~= nil and (inst.components.health == nil or not inst.components.health:IsDead())
end

function TtkAlchemyEffects:Remove(prefab)
    local task = self.tasks[prefab]
    if task ~= nil then task:Cancel(); self.tasks[prefab] = nil end
    local expiry_task = self.expiry_tasks[prefab]
    if expiry_task ~= nil then expiry_task:Cancel(); self.expiry_tasks[prefab] = nil end
    local listener = self.listeners[prefab]
    if listener ~= nil then
        self.inst:RemoveEventCallback("onhitother", listener)
        self.listeners[prefab] = nil
    end
    local kind = self.active[prefab]
    local key = Key(prefab)
    local components = self.inst.components
    if kind == "damage_mult" and components.combat ~= nil then
        components.combat.externaldamagemultipliers:RemoveModifier(self.inst, key)
    elseif kind == "damage_reduction" and components.health ~= nil then
        if components.health.externaldamagetakenmultipliers ~= nil then
            components.health.externaldamagetakenmultipliers:RemoveModifier(self.inst, key)
        elseif components.health.externalabsorbmodifiers ~= nil then
            components.health.externalabsorbmodifiers:RemoveModifier(self.inst, key)
        end
    elseif kind == "speed_mult" and components.locomotor ~= nil then
        components.locomotor:RemoveExternalSpeedMultiplier(self.inst, key)
    elseif kind == "work_efficiency" and components.workmultiplier ~= nil then
        for _, action in ipairs({ACTIONS.CHOP, ACTIONS.MINE, ACTIONS.HAMMER}) do
            components.workmultiplier:RemoveMultiplier(action, self.inst)
        end
    elseif kind == "hunger_rate" and components.hunger ~= nil then
        components.hunger.burnratemodifiers:RemoveModifier(self.inst, key)
    elseif kind == "cold_protection" or kind == "heat_protection" then
        local temperature, amount = components.temperature, self.insulation[prefab]
        if temperature ~= nil and amount ~= nil then
            local field = kind == "cold_protection" and "inherentinsulation" or "inherentsummerinsulation"
            temperature[field] = math.max(0, (temperature[field] or 0) - amount)
        end
        self.insulation[prefab] = nil
    end
    self.active[prefab] = nil
    self.deadlines[prefab] = nil
end

function TtkAlchemyEffects:Expire(prefab)
    self:Remove(prefab)
end

function TtkAlchemyEffects:SetTimed(prefab, kind, duration)
    self.active[prefab] = kind
    self.deadlines[prefab] = GetTime() + duration
    self.expiry_tasks[prefab] = self.inst:DoTaskInTime(duration, function() self:Expire(prefab) end)
end

function TtkAlchemyEffects:Apply(prefab, saved_duration)
    if not TheWorld.ismastersim then return false end
    local row = Defs.Get(prefab)
    local effect = row ~= nil and row.effect or nil
    if effect == nil or not VALID_KINDS[effect.kind] then return false end
    self:Remove(prefab)
    local kind, key, components = effect.kind, Key(prefab), self.inst.components
    if kind == "hunger_rate" then
        if components.hunger ~= nil then components.hunger.burnratemodifiers:SetModifier(self.inst, effect.multiplier, key) end
        self.active[prefab] = kind
        return true
    end
    local duration = effect.duration or DURATION_MAX
    if type(saved_duration) == "number" and saved_duration == saved_duration
        and saved_duration ~= math.huge and saved_duration ~= -math.huge then
        duration = saved_duration
    end
    duration = math.max(1, math.min(DURATION_MAX, duration))
    if kind == "damage_mult" and components.combat ~= nil then
        components.combat.externaldamagemultipliers:SetModifier(self.inst, effect.multiplier, key)
    elseif kind == "damage_reduction" and components.health ~= nil then
        if components.health.externaldamagetakenmultipliers ~= nil then
            components.health.externaldamagetakenmultipliers:SetModifier(self.inst, effect.multiplier, key)
        elseif components.health.externalabsorbmodifiers ~= nil then
            components.health.externalabsorbmodifiers:SetModifier(self.inst, 1 - effect.multiplier, key)
        end
    elseif kind == "speed_mult" and components.locomotor ~= nil then
        components.locomotor:SetExternalSpeedMultiplier(self.inst, key, effect.multiplier)
    elseif kind == "work_efficiency" then
        if components.workmultiplier == nil then self.inst:AddComponent("workmultiplier") end
        for _, action in ipairs({ACTIONS.CHOP, ACTIONS.MINE, ACTIONS.HAMMER}) do
            self.inst.components.workmultiplier:AddMultiplier(action, effect.multiplier, self.inst)
        end
    elseif kind == "health_regen" then
        local function heal()
            if Alive(self.inst) and components.health ~= nil then components.health:DoDelta(effect.amount) end
        end
        if saved_duration == nil and Alive(self.inst) and components.health ~= nil then
            components.health:DoDelta(effect.immediate)
        end
        self.tasks[prefab] = self.inst:DoPeriodicTask(effect.interval, heal)
        self:SetTimed(prefab, kind, duration)
        return true
    elseif kind == "sanity_regen" then
        self.tasks[prefab] = self.inst:DoPeriodicTask(1, function()
            if Alive(self.inst) and components.sanity ~= nil then components.sanity:DoDelta(effect.amount) end
        end)
        self:SetTimed(prefab, kind, duration)
        return true
    elseif kind == "lightning_damage" or kind == "lifesteal" then
        self.listeners[prefab] = function(_, data)
            if self.processing_auxiliary_hit then return end
            if data == nil then return end
            local damage = data.damageresolved or data.damage
            if type(damage) ~= "number" or damage <= 0 then return end
            if kind == "lightning_damage" then
                local target = data.target
                if target ~= nil and target.components.combat ~= nil then
                    self.processing_auxiliary_hit = true
                    pcall(target.components.combat.GetAttacked, target.components.combat, self.inst, effect.amount, nil, "electric")
                    self.processing_auxiliary_hit = false
                end
            elseif Alive(self.inst) and components.health ~= nil then
                components.health:DoDelta(damage * effect.fraction)
            end
        end
        self.inst:ListenForEvent("onhitother", self.listeners[prefab])
    elseif kind == "cold_protection" or kind == "heat_protection" then
        local temperature = components.temperature
        if temperature ~= nil then
            local field = kind == "cold_protection" and "inherentinsulation" or "inherentsummerinsulation"
            temperature[field] = (temperature[field] or 0) + PROTECTION
            self.insulation[prefab] = PROTECTION
        end
    end
    self:SetTimed(prefab, kind, duration)
    return true
end

function TtkAlchemyEffects:OnSave()
    local effects = {}
    for prefab, kind in pairs(self.active) do
        if VALID_KINDS[kind] then
            if kind == "hunger_rate" then
                effects[prefab] = true
            else
                local remaining = (self.deadlines[prefab] or GetTime()) - GetTime()
                if remaining > 0 then effects[prefab] = math.max(1, math.min(DURATION_MAX, remaining)) end
            end
        end
    end
    return { effects = effects }
end

function TtkAlchemyEffects:OnLoad(data)
    local effects = type(data) == "table" and data.effects or nil
    if type(effects) ~= "table" then return end
    for prefab, enabled in pairs(effects) do
        local row = type(prefab) == "string" and Defs.Get(prefab) or nil
        if row ~= nil and row.effect ~= nil and VALID_KINDS[row.effect.kind] then
            if enabled == true and row.effect.kind == "hunger_rate" then
                self:Apply(prefab)
            elseif type(enabled) == "number" and enabled == enabled and enabled ~= math.huge and enabled ~= -math.huge
                and row.effect.kind ~= "hunger_rate" then
                self:Apply(prefab, math.max(1, math.min(DURATION_MAX, enabled)))
            end
        end
    end
end

return TtkAlchemyEffects
