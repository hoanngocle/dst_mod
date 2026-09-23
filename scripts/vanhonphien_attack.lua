local rules = require("vanhonphien_rules")
local M = {}

-- Keep the game's projectile lifecycle (Stop, impact effects and hit-range
-- handling). Only the synchronous damage call changes attribution under Solo.
function M.Hit(projectile, target, original_hit)
    local weapon = projectile.owner
    local soul = weapon ~= nil and weapon:IsValid()
        and weapon.components.inventoryitem ~= nil
        and weapon.components.inventoryitem.owner or nil
    if soul == nil or not soul:IsValid() or soul.components.health == nil
        or soul.components.health:IsDead() or not rules.CanAttack(soul, target) then
        return projectile:Miss(target)
    end
    local owner = soul.owner
    local combat = owner.components.combat
    if owner.components.hh_player == nil or combat == nil then
        return original_hit(projectile, target)
    end

    local pet_combat = soul.components.combat
    local pet_attack = pet_combat.DoAttack
    local pet_ignore = pet_combat.ignorehitrange
    local fields = { "ignorehitrange", "areahitrange", "areahitdamagepercent",
        "areahitcheck", "areahitdisabled", "AOEarc" }
    local saved = {}
    for _, key in ipairs(fields) do saved[key] = combat[key] end
    combat.ignorehitrange = true
    combat.areahitrange = 3
    combat.areahitdamagepercent = 1
    combat.areahitdisabled = false
    combat.AOEarc = nil
    combat.areahitcheck = function(ent) return rules.CanAttack(soul, ent) end
    pet_combat.DoAttack = function(_, ...)
        return combat:DoAttack(...)
    end
    local ok, result = pcall(original_hit, projectile, target)
    pet_combat.DoAttack = pet_attack
    pet_combat.ignorehitrange = pet_ignore
    for _, key in ipairs(fields) do combat[key] = saved[key] end
    if not ok then error(result, 0) end
    return result
end

function M.OnAttack(soul, weapon, attacker, target, projectile)
    local banner = soul.components.entitytracker:GetEntity("banner")
    if banner ~= nil and banner:IsValid() then
        require("ttk_weapon_damage").ForwardAttack(
            banner, weapon.components.weapon, attacker, target, projectile)
    end
end

return M
