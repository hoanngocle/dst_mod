local SkillDamage = {}

local function Pack(...)
    return {n = select("#", ...), ...}
end

function SkillDamage.Apply(owner, target, damage, stimuli)
    local combat = target.components.combat
    if owner.components.hh_player == nil then
        return combat:GetAttacked(owner, damage, nil, stimuli)
    end

    -- Solo treats weapon=nil as melee in its onhitother splash handler.
    -- Borrow its splash recursion guard for this synchronous skill hit only;
    -- keep the normal combat path (crit, armor, other procs and kill credit).
    -- Preserve an outer guard, including nil/false, on nested hits or errors.
    local previous = owner._is_splashing_aoe
    owner._is_splashing_aoe = true
    local result = Pack(pcall(combat.GetAttacked, combat, owner, damage, nil, stimuli))
    owner._is_splashing_aoe = previous
    if not result[1] then error(result[2], 0) end
    return unpack(result, 2, result.n)
end

return SkillDamage
