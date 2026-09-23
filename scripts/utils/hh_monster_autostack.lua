local HHMonsterAutoStack = {}

local AUTO_STACK_RANGE = 10
local INITIAL_DELAY = 0.1
local RETRY_DELAY = 0.5
local MAX_READY_RETRIES = 20

local next_loot_order = 0
local component_hook_installed = false

local function IsServer()
    return TheWorld ~= nil and TheWorld.ismastersim
end

local function IsValid(inst)
    return inst ~= nil and inst:IsValid()
end

local function IsMonsterDropper(dropper)
    return IsValid(dropper)
        and dropper.components ~= nil
        and dropper.components.hh_monster ~= nil
end

local function IsMonsterLoot(inst)
    return inst ~= nil and inst._hh_monster_loot == true
end

local function CancelAutoStackTask(inst)
    local task = inst._hh_monster_loot_autostack_task
    if task ~= nil then
        task:Cancel()
        inst._hh_monster_loot_autostack_task = nil
    end
end

local function ClearMonsterLoot(inst)
    if inst == nil then
        return
    end
    inst._hh_monster_loot = nil
    inst._hh_monster_loot_order = nil
    CancelAutoStackTask(inst)
end

local function InstallLifecycleHooks(inst)
    if inst._hh_monster_loot_hooks_installed then
        return
    end
    inst._hh_monster_loot_hooks_installed = true
    inst:ListenForEvent("onpickup", ClearMonsterLoot)
    inst:ListenForEvent("onputininventory", ClearMonsterLoot)
    inst:ListenForEvent("ondropped", ClearMonsterLoot)
end

local function ShouldIgnoreEntity(inst)
    local components = inst.components
    return (components ~= nil and (
        components.locomotor ~= nil
        or components.heavyobstaclephysics ~= nil
        or components.trap ~= nil
        or (components.bait ~= nil and components.bait.trap ~= nil)
    ))
        or inst.prefab == "fireflies"
        or inst:HasTag("groundspike")
        or inst:HasTag("projectile")
        or inst:HasTag("trap")
        or inst:HasTag("creature")
        or inst:HasTag("livestock")
        or inst:HasTag("smallcreature")
        or inst:HasTag("small_livestock")
        or inst:HasTag("no_autostack_all")
end

local function SpecialCreatureChecks(inst)
    return not (inst.prefab == "mandrake" and not inst:HasTag("item"))
end

local function IsGroundStackableLoot(inst)
    if not IsServer() or not IsValid(inst) or inst.Transform == nil then
        return false
    end

    local components = inst.components
    local inventoryitem = components ~= nil and components.inventoryitem or nil
    local stackable = components ~= nil and components.stackable or nil
    if inventoryitem == nil or inventoryitem.owner ~= nil then
        return false
    end
    if stackable == nil or stackable:IsFull() then
        return false
    end
    if inst:HasTag("fire") or ShouldIgnoreEntity(inst) or not SpecialCreatureChecks(inst) then
        return false
    end

    local parent = inst.parent
    if parent ~= nil then
        if parent:HasTag("player") then
            return false
        end
        if parent.components ~= nil and parent.components.container ~= nil then
            return false
        end
    end
    return true
end

local function IsGroundStackItem(inst)
    return IsGroundStackableLoot(inst)
        and inst.components.inventoryitem.canbepickedup
end

local function IsReadyForAutoStack(inst)
    if inst.Physics ~= nil and not inst.Physics:IsActive() then
        return false
    end
    if inst.components.inventoryitem ~= nil and not inst.components.inventoryitem.canbepickedup then
        return false
    end
    if inst.updatetask ~= nil then
        return false
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    return not (x == 0 and y == 0 and z == 0)
end

local function PlaySmokePuff(x, y, z)
    local fx = SpawnPrefab("small_puff")
    if fx ~= nil and fx.Transform ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(0.5, 0.5, 0.5)
    end
end

local function TryAddToStack(item, target)
    if not IsMonsterLoot(item) or not IsMonsterLoot(target)
        or not IsGroundStackItem(item) or not IsGroundStackItem(target)
        or item == target or item.prefab ~= target.prefab
        or not SpecialCreatureChecks(item) or not SpecialCreatureChecks(target)
    then
        return false
    end

    local item_components = item.components
    local target_components = target.components
    if target_components.stackable:CanStackWith(item) ~= true then
        return false
    end
    if target_components.perishable ~= nil and item_components.perishable == nil then
        return false
    end
    if item_components.bait ~= nil and item_components.bait.trap ~= nil then
        return false
    end
    if target_components.bait ~= nil and target_components.bait.trap ~= nil then
        return false
    end

    target_components.stackable:Put(
        item,
        Vector3(TheSim:GetScreenPos(item.Transform:GetWorldPosition()))
    )
    return true
end

local function IsNewerMarkedItem(candidate, current)
    return (candidate._hh_monster_loot_order or 0) > (current._hh_monster_loot_order or 0)
end

local function AutoStackNewest(inst)
    if not IsGroundStackItem(inst) or not IsReadyForAutoStack(inst) then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local nearby = TheSim:FindEntities(
        x,
        y,
        z,
        AUTO_STACK_RANGE,
        {"_inventoryitem"},
        {"INLIMBO", "NOCLICK", "catchable", "fire"}
    )

    for _, candidate in ipairs(nearby) do
        if candidate ~= inst
            and IsMonsterLoot(candidate)
            and candidate.prefab == inst.prefab
            and IsGroundStackItem(candidate)
            and IsNewerMarkedItem(candidate, inst)
        then
            return
        end
    end

    for _, candidate in ipairs(nearby) do
        if candidate ~= inst and IsGroundStackItem(candidate) then
            local candidate_x, candidate_y, candidate_z = candidate.Transform:GetWorldPosition()
            if TryAddToStack(candidate, inst) then
                PlaySmokePuff(candidate_x, candidate_y, candidate_z)
                if not IsGroundStackItem(inst) then
                    break
                end
            end
        end
    end
end

local QueueAutoStack

local function TryAutoStack(inst, retries)
    if not IsServer() or not IsMonsterLoot(inst) or not IsGroundStackableLoot(inst) then
        return
    end
    if IsReadyForAutoStack(inst) then
        AutoStackNewest(inst)
        return
    end
    if retries < MAX_READY_RETRIES then
        QueueAutoStack(inst, retries + 1)
    end
end

QueueAutoStack = function(inst, retries)
    if not IsServer() or not IsMonsterLoot(inst) or inst._hh_monster_loot_autostack_task ~= nil then
        return
    end
    inst._hh_monster_loot_autostack_task = inst:DoTaskInTime(
        retries == 0 and INITIAL_DELAY or RETRY_DELAY,
        function(target)
            target._hh_monster_loot_autostack_task = nil
            TryAutoStack(target, retries)
        end
    )
end

local function OnVanillaLootDropped(inst, data)
    local dropper = data ~= nil and data.dropper or nil
    HHMonsterAutoStack.MarkMonsterLoot(inst, dropper)
end

function HHMonsterAutoStack.MarkMonsterLoot(inst, dropper)
    if not IsServer() or not IsValid(inst) or not IsMonsterDropper(dropper) then
        return false
    end
    if inst._hh_monster_loot then
        return true
    end

    local components = inst.components
    if components == nil or components.inventoryitem == nil or components.stackable == nil then
        return false
    end

    next_loot_order = next_loot_order + 1
    inst._hh_monster_loot = true
    inst._hh_monster_loot_order = next_loot_order
    InstallLifecycleHooks(inst)
    QueueAutoStack(inst, 0)
    return true
end

function HHMonsterAutoStack.Install(add_component_post_init)
    if component_hook_installed then
        return true
    end
    if type(add_component_post_init) ~= "function" then
        return false
    end
    if TheNet == nil or (not TheNet:GetIsServer() and not TheNet:IsDedicated()) then
        return false
    end
    component_hook_installed = true
    add_component_post_init("stackable", function(component)
        if component ~= nil and component.inst ~= nil then
            component.inst:ListenForEvent("on_loot_dropped", OnVanillaLootDropped)
        end
    end)
    return true
end

return HHMonsterAutoStack
