local PREFAB = "thanhiquangtruong"
local READY_TAG = "thanhiquangtruong_ready"
local MAP_RANGE = 128

local function EquippedStaff(player)
    local inventory = player ~= nil and player.replica ~= nil and player.replica.inventory or nil
    local staff = inventory ~= nil and inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    return staff ~= nil and staff.prefab == PREFAB and staff or nil
end

local function ValidPoint(player, point, onmap)
    if player == nil or not player:IsValid() or player:HasTag("playerghost")
        or (player.components.health ~= nil and player.components.health:IsDead())
        or player:HasTag("steeringboat") or player:HasTag("rotatingboat")
        or point == nil or type(point.x) ~= "number" or type(point.z) ~= "number"
        or point.x ~= point.x or point.z ~= point.z
        or math.abs(point.x) == math.huge or math.abs(point.z) == math.huge then
        return false
    end
    local x, y, z = player.Transform:GetWorldPosition()
    local range = onmap and MAP_RANGE or 36
    if (point.x - x) ^ 2 + (point.z - z) ^ 2 > range * range
        or not TheWorld.Map:IsPassableAtPoint(point.x, 0, point.z)
        or TheWorld.Map:IsGroundTargetBlocked(point)
        or not IsTeleportingPermittedFromPointToPoint(x, y, z, point.x, 0, point.z) then
        return false
    end
    return not onmap or player:CanSeePointOnMiniMap(point.x, 0, point.z)
end

return {
    PREFAB = PREFAB,
    READY_TAG = READY_TAG,
    EquippedStaff = EquippedStaff,
    ValidPoint = ValidPoint,
}
