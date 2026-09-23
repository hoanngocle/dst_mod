local Life = require "util/eva_life_common"

local Harvest = {}

Harvest.SOUL_COST = 3
Harvest.COOLDOWN = 10
Harvest.CAST_RANGE = 12
Harvest.RADIUS = 8
Harvest.DURATION = 7
Harvest.HARVEST_PERIOD = 0.5
Harvest.PULL_PERIOD = 0.1
Harvest.PULL_STEP = 0.45
Harvest.WORK_AMOUNT = 3

local HARVEST_ONE_OF_TAGS = {
    "pickable", "CHOP_workable", "MINE_workable", "DIG_workable",
}
local HARVEST_CANT_TAGS = {
    "INLIMBO", "FX", "structure", "trader", "playerowned",
}
local PULL_MUST_TAGS = {"_inventoryitem"}
local PULL_CANT_TAGS = {
    "INLIMBO", "FX", "structure", "trader", "playerowned",
    "irreplaceable", "heavy", "locomotor",
}
local PROTECTED_TAGS = {
    "INLIMBO", "structure", "trader", "playerowned",
}
local PLANTED_WORK_TAGS = {
    "planted", "planted_seed", "plantedsoil", "farm_plant",
    "plantresearchable",
}
local WORK_ACTIONS = {CHOP = true, MINE = true}

function Harvest.IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

function Harvest.CanOwnerRemain(owner)
    return Life.CanRemainActive(owner)
end

function Harvest.ValidateCenter(owner, x, z)
    if not Harvest.IsFiniteNumber(x) or not Harvest.IsFiniteNumber(z) then
        return false, "invalid_coordinates"
    end
    if not Life.CanActivate(owner) then return false, "invalid_state" end
    if owner:GetDistanceSqToPoint(x, 0, z) > Harvest.CAST_RANGE * Harvest.CAST_RANGE then
        return false, "out_of_range"
    end

    local map = TheWorld ~= nil and TheWorld.Map or nil
    if map == nil then return false, "invalid_terrain" end
    local width, height = map:GetSize()
    local scale = TILE_SCALE or 4
    if not Harvest.IsFiniteNumber(width) or not Harvest.IsFiniteNumber(height)
        or math.abs(x) >= width * scale / 2
        or math.abs(z) >= height * scale / 2 then
        return false, "out_of_bounds"
    end
    if map:GetPlatformAtPoint(x, z) ~= nil
        or map:IsPassableAtPoint(x, 0, z, false) then
        if map.IsGroundTargetBlocked ~= nil
            and map:IsGroundTargetBlocked({x = x, y = 0, z = z}) then
            return false, "blocked"
        end
        return true
    end
    return false, "invalid_terrain"
end

local function IsValidEntity(inst)
    return inst ~= nil and inst.IsValid ~= nil and inst:IsValid()
end

local function HasAnyTag(inst, tag_list)
    if inst.HasTag == nil then return false end
    for _, tag in ipairs(tag_list) do
        if inst:HasTag(tag) then return true end
    end
    return false
end

function Harvest.IsProtectedEntity(inst)
    if not IsValidEntity(inst) or HasAnyTag(inst, PROTECTED_TAGS) then return true end
    local components = inst.components
    if components == nil or components.trader ~= nil or components.container ~= nil then
        return true
    end
    local inventoryitem = components.inventoryitem
    return inventoryitem ~= nil and inventoryitem.IsHeld ~= nil
        and inventoryitem:IsHeld()
end

function Harvest.CanHarvestPickable(inst)
    if Harvest.IsProtectedEntity(inst) then return false end
    local pickable = inst.components.pickable
    return pickable ~= nil
        and pickable.CanBePicked ~= nil
        and pickable:CanBePicked()
        and pickable.caninteractwith ~= false
end

function Harvest.HarvestPickable(owner, inst)
    if not Harvest.CanOwnerRemain(owner) or not Harvest.CanHarvestPickable(inst) then
        return false
    end
    local success = inst.components.pickable:Pick(TheWorld)
    return success == true
end

function Harvest.CanWork(inst)
    if Harvest.IsProtectedEntity(inst) or HasAnyTag(inst, PLANTED_WORK_TAGS) then
        return false
    end
    local workable = inst.components.workable
    if workable == nil or workable.CanBeWorked == nil
        or not workable:CanBeWorked() or workable.GetWorkAction == nil then
        return false
    end
    local action = workable:GetWorkAction()
    local action_id = action ~= nil and action.id or nil
    if action_id == "DIG" then
        return inst.HasTag ~= nil and inst:HasTag("stump")
    end
    return WORK_ACTIONS[action_id] == true
end

function Harvest.WorkEntity(owner, inst)
    if not Harvest.CanOwnerRemain(owner) or not Harvest.CanWork(inst) then return false end
    inst.components.workable:WorkedBy(owner, Harvest.WORK_AMOUNT)
    return true
end

function Harvest.HarvestEntity(owner, inst)
    if not Harvest.CanOwnerRemain(owner) or not IsValidEntity(inst) then return false end
    local acted = Harvest.HarvestPickable(owner, inst)
    if IsValidEntity(inst) and Harvest.WorkEntity(owner, inst) then acted = true end
    return acted
end

function Harvest.FindHarvestables(x, z)
    if TheSim == nil then return {} end
    return TheSim:FindEntities(
        x, 0, z, Harvest.RADIUS, nil, HARVEST_CANT_TAGS, HARVEST_ONE_OF_TAGS)
end

function Harvest.CanPullItem(inst)
    if not IsValidEntity(inst) or Harvest.IsProtectedEntity(inst)
        or HasAnyTag(inst, PULL_CANT_TAGS) or inst.Physics == nil then
        return false
    end
    local inventoryitem = inst.components.inventoryitem
    if inventoryitem == nil or inventoryitem.IsHeld == nil
        or inventoryitem:IsHeld() then
        return false
    end
    return inst.entity ~= nil and inst.entity.GetParent ~= nil
        and inst.entity:GetParent() == nil
end

function Harvest.FindPullItems(x, z)
    if TheSim == nil then return {} end
    return TheSim:FindEntities(
        x, 0, z, Harvest.RADIUS, PULL_MUST_TAGS, PULL_CANT_TAGS)
end

local function IsSafePullStep(x, z, next_x, next_z, center_x, center_z)
    local world = TheWorld
    local map = world ~= nil and world.Map or nil
    local pathfinder = world ~= nil and world.Pathfinder or nil
    if map == nil or pathfinder == nil or pathfinder.IsClear == nil then return false end

    local platform = map:GetPlatformAtPoint(x, z)
    if map:GetPlatformAtPoint(next_x, next_z) ~= platform
        or map:GetPlatformAtPoint(center_x, center_z) ~= platform then
        return false
    end
    if platform == nil and not map:IsPassableAtPoint(next_x, 0, next_z, false) then
        return false
    end
    return pathfinder:IsClear(x, 0, z, next_x, 0, next_z, {
        ignorewalls = false,
        ignorecreep = false,
        allowocean = platform ~= nil,
    })
end

function Harvest.PullItemStep(inst, center_x, center_z)
    if not Harvest.IsFiniteNumber(center_x) or not Harvest.IsFiniteNumber(center_z)
        or not Harvest.CanPullItem(inst) then
        return false
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local dx, dz = center_x - x, center_z - z
    local distance_sq = dx * dx + dz * dz
    if distance_sq <= 0.000001 then return false end
    local distance = math.sqrt(distance_sq)
    local step = math.min(Harvest.PULL_STEP, distance)
    local next_x = x + dx / distance * step
    local next_z = z + dz / distance * step
    if not IsSafePullStep(x, z, next_x, next_z, center_x, center_z) then
        return false
    end
    inst.Transform:SetPosition(next_x, y, next_z)
    return true
end

return Harvest
