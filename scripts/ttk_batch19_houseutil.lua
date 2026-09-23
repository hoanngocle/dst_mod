local M = {}

local CANT_TARGET = {
    "INLIMBO", "notarget", "noattack", "invisible", "playerghost", "wall", "FX",
}

local function OwnerId(inst)
    if inst == nil then
        return nil
    end
    if inst._ttk_owner_userid ~= nil then
        return inst._ttk_owner_userid
    end
    local follower = inst.components ~= nil and inst.components.follower or nil
    local leader = follower ~= nil and follower.leader or nil
    return leader ~= nil and leader.userid or nil
end

function M.CanAttackTarget(inst, target)
    if inst == nil or target == nil or inst == target or not target:IsValid() then
        return false
    end
    local health = target.components ~= nil and target.components.health or nil
    local combat = target.components ~= nil and target.components.combat or nil
    if health == nil or health:IsDead() or combat == nil then
        return false
    end
    local ownerid = OwnerId(inst)
    local targetownerid = OwnerId(target)
    if ownerid ~= nil and (target.userid == ownerid or targetownerid == ownerid) then
        return false
    end
    if target:HasTag("player") and not TheNet:GetPVPEnabled() then
        return false
    end
    if inst:HasTag("companion") and target:HasTag("companion") then
        return false
    end
    return inst.components ~= nil
        and inst.components.combat ~= nil
        and inst.components.combat:CanTarget(target)
end

function M.GetDamageTargets(x, y, z, radius)
    return TheSim:FindEntities(x, y, z, radius, { "_combat", "_health" }, CANT_TARGET)
end

function M.GetGroundPoints(origin, rings)
    local result = {}
    rings = rings or 3
    for ring = 1, rings do
        local points = {}
        local count = ring * 8
        local radius = ring * 2
        for index = 1, count do
            local angle = 2 * PI * index / count
            table.insert(points, Vector3(origin.x + math.cos(angle) * radius, 0,
                origin.z + math.sin(angle) * radius))
        end
        table.insert(result, points)
    end
    return result
end

function M.SpawnAt(prefab, target, scale, offset)
    local spawned = SpawnPrefab(prefab)
    if spawned == nil or target == nil then
        return spawned
    end
    local pos
    if target.GetPosition ~= nil then
        pos = target:GetPosition()
    elseif target.x ~= nil and target.z ~= nil then
        pos = target
    end
    if pos ~= nil then
        offset = offset or Vector3(0, 0, 0)
        spawned.Transform:SetPosition(pos.x + offset.x, (pos.y or 0) + offset.y, pos.z + offset.z)
    end
    if scale ~= nil then
        spawned.Transform:SetScale(scale, scale, scale)
    end
    return spawned
end

function M.SetOwner(inst, owner)
    if inst == nil or owner == nil then
        return
    end
    inst._ttk_owner_userid = owner.userid
    inst._ttk_owner_name = owner.name
end

function M.SaveOwner(inst, data)
    data._ttk_owner_userid = inst._ttk_owner_userid
    data._ttk_owner_name = inst._ttk_owner_name
    data._ttk_tamed = inst._ttk_tamed or nil
end

function M.LoadOwner(inst, data)
    if data ~= nil then
        inst._ttk_owner_userid = data._ttk_owner_userid
        inst._ttk_owner_name = data._ttk_owner_name
        inst._ttk_tamed = data._ttk_tamed == true
    end
end

function M.BindOnBuilt(inst)
    inst:ListenForEvent("onbuilt", function(house, data)
        local builder = data ~= nil and (data.builder or data.doer) or nil
        if builder ~= nil then
            M.SetOwner(house, builder)
        end
    end)
end

function M.ReleaseChildrenForHammer(inst)
    local spawner = inst.components ~= nil and inst.components.childspawner or nil
    if spawner == nil then
        return true
    end
    local old_can_spawn = spawner.canspawnfn
    spawner.canspawnfn = nil
    spawner:ReleaseAllChildren()
    spawner.canspawnfn = old_can_spawn
    if (spawner.childreninside or 0) > 0 then
        local workable = inst.components.workable
        if workable ~= nil then
            workable:SetWorkLeft(1)
        end
        return false
    end
    return true
end

return M
