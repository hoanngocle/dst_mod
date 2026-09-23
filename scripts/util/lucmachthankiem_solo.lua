-- No Solo imports: the numeric item damage is a standard enhancement carrier.
-- Flying swords retain the original gem-stage damage and planar damage.
local Bridge = {}

local function SyncBase(inst)
    local base = TUNING.LUCMACHTHANKIEM_DAMAGE * (inst.rainbow_enable and 2 or 1)
    require("ttk_weapon_damage").SetBase(inst, base)
end

local function Install(inst)
    inst:AddTag"weapon"
    if not TheWorld.ismastersim then
        return
    end
    if inst.components.weapon == nil then
        inst:AddComponent"weapon"
    end
    local carrier = inst.components.weapon
    local base = TUNING.LUCMACHTHANKIEM_DAMAGE
    carrier:SetDamage(base)
    -- The held item only orders the swords to attack. Its numeric damage is
    -- used by enhancement systems, not applied as an extra direct hit.
    carrier.GetDamage = function() return 0, nil end
    local command = carrier.OnAttack
    inst._ttk_attack_command = function(_, attacker, target)
        command(carrier, attacker, target)
    end

    local flying = inst.real_weapon.components.weapon
    local on_attack = flying.OnAttack
    flying.OnAttack = function(self, attacker, target, projectile, ...)
        on_attack(self, attacker, target, projectile, ...)
        require("ttk_weapon_damage").ForwardAttack(inst, self, attacker, target, projectile)
    end
    local get_damage = flying.GetDamage
    flying.GetDamage = function(self, attacker, target, ...)
        local damage, special = get_damage(self, attacker, target, ...)
        local enhanced = carrier.damage
        if type(enhanced) == "number" and base > 0 then
            damage = damage * enhanced / base
        end
        -- Opal doubles native planar damage. Solo's normal-damage bonus
        -- must not amplify planar damage too or be doubled by the opal.
        if inst.rainbow_enable and special ~= nil then
            local scaled = {}
            for kind, amount in pairs(special) do
                scaled[kind] = kind == "planar" and amount * 2 or amount
            end
            special = scaled
        end
        return damage, special
    end

    -- Keep the original rainbow visuals, one-opal acceptance check and save
    -- field. Existing rainbow swords receive the same x2 benefit on load.
    local rainbow = inst.RainbowEffect
    inst.RainbowEffect = function(self, enabled, ...)
        rainbow(self, enabled, ...)
        SyncBase(self)
    end
    local on_load = inst.OnLoad
    inst.OnLoad = function(self, data, ...)
        on_load(self, data, ...)
        SyncBase(self)
        -- Component save data may load before or after prefab save data.
        self:DoTaskInTime(0, SyncBase)
    end
end

-- Called inside the prefab factory, BEFORE any global post-init hooks. This
-- gives Solo a nonzero numeric base regardless of post-init callback order.
function Bridge.WrapPrefabs(prefabs)
    for _, prefab in ipairs(prefabs) do
        if prefab.name == "lucmachthankiem" then
            local factory = prefab.fn
            prefab.fn = function(...)
                local inst = factory(...)
                Install(inst)
                return inst
            end
        end
    end
    return prefabs
end

-- Original swords also have a fallback for owners without combat. Use the
-- same enhanced damage there; preserve the original nil attacker attribution.
function Bridge.FallbackArgs(real_weapon, multiplier)
    local damage, special = real_weapon.components.weapon:GetDamage()
    multiplier = multiplier or 1
    local scaled
    if special ~= nil then
        scaled = {}
        for kind, amount in pairs(special) do
            scaled[kind] = amount * multiplier
        end
    end
    return nil, damage * multiplier, nil, nil, scaled
end

return Bridge
