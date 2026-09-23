-- Standalone target/owner rules. Never load Tu Tien or Solo modules.
local EXCLUDED = { "INLIMBO", "wall", "notarget", "noattack", "flight",
    "invisible", "playerghost" }

local function IsLivingPlayer(player)
    return player ~= nil and player:IsValid() and player:HasTag("player")
        and not player:HasTag("playerghost")
        and player.components.health ~= nil
        and not player.components.health:IsDead()
end

local function FindOwner(userid)
    if userid ~= nil then
        for _, player in ipairs(AllPlayers) do
            if player.userid == userid and IsLivingPlayer(player) then
                return player
            end
        end
    end
end

local function CanAttack(inst, target)
    local owner = inst.owner
    if not IsLivingPlayer(owner) or target == nil or not target:IsValid()
        or target == inst or target == owner or target.owner == owner
        or target.components.health == nil or target.components.health:IsDead()
        or target.components.combat == nil then
        return false
    end
    for _, tag in ipairs(EXCLUDED) do
        if target:HasTag(tag) then
            return false
        end
    end
    local follower = target.components.follower
    local leader = follower ~= nil and follower.leader or nil
    if leader == owner or leader == inst
        or (owner.components.petleash ~= nil and owner.components.petleash:IsPet(target)) then
        return false
    end
    if not TheNet:GetPVPEnabled() and (target:HasTag("player")
        or target:HasTag("companion") or target:HasTag("abigail")
        or (leader ~= nil and leader:HasTag("player"))) then
        return false
    end
    return inst.components.combat ~= nil and inst.components.combat:CanTarget(target)
        and not (owner.components.combat ~= nil and owner.components.combat:IsAlly(target))
end

return { IsLivingPlayer = IsLivingPlayer, FindOwner = FindOwner, CanAttack = CanAttack }
