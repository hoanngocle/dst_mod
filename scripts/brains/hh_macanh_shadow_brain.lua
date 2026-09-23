require("behaviours/follow")
require("behaviours/runaway")

local BrainCommon = require("brains/braincommon")

local WORK_RADIUS = TUNING.HH_MACANH_SHADOW.WORK_RADIUS
local FOLLOW_RADIUS = TUNING.HH_MACANH_SHADOW.FOLLOW_RADIUS
local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 8
local WORK_EXIT_RADIUS = FOLLOW_RADIUS + 4

local WORK_ACTIONS = {
    CHOP = true,
    MINE = true,
    DIG = true,
    PICK = true,
}

-- These are recovery thresholds, not gameplay range/speed tuning. They are
-- deliberately local to Macanh so the vanilla behaviours remain untouched.
local MACANH_RUN_SPEED = math.max(1, TUNING.SHADOWWAXWELL_SPEED or 6)
local WORK_PROGRESS_TIMEOUT = math.max(4, WORK_RADIUS / MACANH_RUN_SPEED)
local WORK_PROGRESS_EPSILON = .25
local UNREACHABLE_TARGET_TTL = 8
local MAX_UNREACHABLE_TARGETS = 8
local FOLLOW_PROGRESS_TIMEOUT = math.max(4, FOLLOW_RADIUS / MACANH_RUN_SPEED)
local FOLLOW_PROGRESS_EPSILON = .25
-- Vanilla Follow sleeps for .25s between locomotor updates. Allow one
-- radius/speed travel window for a legitimate detour, but keep a hard upper
-- bound so repeated path searches cannot extend the same goal indefinitely.
local FOLLOW_BRAIN_TICK = .25
local FOLLOW_DETOUR_GRACE = math.max(
    FOLLOW_BRAIN_TICK * 2,
    FOLLOW_RADIUS / MACANH_RUN_SPEED
)
local FOLLOW_MAX_NO_GOAL_PROGRESS = FOLLOW_PROGRESS_TIMEOUT + FOLLOW_DETOUR_GRACE
local FOLLOW_NAVIGATION_RECENT_WINDOW = FOLLOW_BRAIN_TICK * 2
local FOLLOW_RECOVERY_COOLDOWN = 1
local RUNAWAY_PROGRESS_TIMEOUT = 3
local RUNAWAY_PROGRESS_EPSILON = .25
local DANGER_RECOVERY_COOLDOWN = 1

local function GetWorkRadius(inst)
    return inst._hh_work_radius or WORK_RADIUS
end
local AVOID_EXPLOSIVE_DIST = 5
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8
local COMBAT_TIMEOUT = 6

local CANT_WORK_TAGS = {
    "fire", "smolder", "event_trigger", "waxedplant", "INLIMBO",
    "NOCLICK", "carnivalgame_part",
}

local STATUS_BY_ACTION = {
    CHOP = "Đang chặt cây",
    MINE = "Đang đào khoáng sản",
    DIG = "Đang xúc tài nguyên",
    PICK = "Đang thu hoạch",
}

local function SetStatus(inst, status)
    if inst.SetHHStatus ~= nil then
        inst:SetHHStatus(status)
    end
end

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
end

local function GetActionId(action)
    return action ~= nil and (action.id or action.str) or nil
end

local function IsFollowRecoveryActive(inst)
    return (inst._hh_macanh_follow_recovery_until or 0) > GetTime()
end

local function IsFollowRecoveryBlocking(inst)
    if not IsFollowRecoveryActive(inst) then
        return false
    end
    local leader = GetLeader(inst)
    return leader ~= nil and not inst:IsNear(leader, WORK_EXIT_RADIUS)
end

local function IsDangerRecoveryActive(inst)
    return (inst._hh_macanh_danger_recovery_until or 0) > GetTime()
end

local function IsFullInventoryItem(item)
    if item == nil then
        return false
    end
    local stackable = item.components.stackable
    return stackable == nil
        or stackable:StackSize() >= (stackable.maxsize or math.huge)
end

local function HasFullInventoryStack(inst)
    local inventory = inst.components.inventory
    if inventory == nil then
        return false
    end
    local item = inventory:GetFirstItemInAnySlot()
    local activeitem = inventory:GetActiveItem()
    return IsFullInventoryItem(item) or
        (activeitem ~= item and IsFullInventoryItem(activeitem))
end

local function GetCargoItem(inst)
    local inventory = inst.components.inventory
    if inventory == nil then return nil end
    return inventory:GetFirstItemInAnySlot() or inventory:GetActiveItem()
end

local function HasCargo(inst)
    return GetCargoItem(inst) ~= nil
end

local function HasCompatibleGroundTarget(inst)
    local cargo = GetCargoItem(inst)
    if cargo == nil or cargo.prefab == nil
        or cargo.components.stackable == nil
        or cargo.components.stackable:IsFull() then
        return false
    end

    local leader = GetLeader(inst)
    if leader == nil or leader.components == nil then
        return false
    end

    local container = leader.components.inventory or leader.components.container
    if container == nil
        or (leader.components.inventory ~= nil and not container:IsOpenedBy(leader)) then
        return false
    end

    local inventory = inst.components.inventory
    if inventory == nil then
        return false
    end

    local item = FindPickupableItem(
        leader,
        GetWorkRadius(inst),
        false,
        inst:GetPosition(),
        leader._brain_pickup_ignorethese,
        {[cargo.prefab] = true},
        false,
        inst,
        nil,
        inventory
    )
    return item ~= nil and container.CanAcceptCount ~= nil
        and (container:CanAcceptCount(item, 1) or 0) > 0
end

local function StopMacanhMovement(inst)
    local previous = inst._hh_macanh_clearing_action
    inst._hh_macanh_clearing_action = true

    local locomotor = inst.components.locomotor
    if locomotor ~= nil and locomotor.bufferedaction ~= nil then
        locomotor:SetBufferedAction(nil)
    end
    inst:ClearBufferedAction()
    if locomotor ~= nil then
        locomotor:Stop()
    end

    inst._hh_macanh_clearing_action = previous
end

local function BeginDelivery(inst, reason, movement_already_stopped)
    if not inst._hh_macanh_delivery then
        inst._hh_macanh_delivery = true
        inst._hh_macanh_delivery_reason = reason
        inst._hh_macanh_give_failed = nil
        inst._hh_macanh_give_movement_failed = nil
        inst._hh_macanh_drop_failed = nil
        inst._hh_macanh_drop_retry_time = nil
        if not movement_already_stopped then
            StopMacanhMovement(inst)
        end
    end
    SetStatus(inst, "Đang giao tài nguyên")
end

local function FinishDelivery(inst)
    if not HasCargo(inst) then
        local pending_action = inst._hh_pending_work_action
        local pending_prefab = inst._hh_pending_work_prefab
        inst._hh_macanh_delivery = nil
        inst._hh_macanh_delivery_reason = nil
        inst._hh_pending_work_action = nil
        inst._hh_pending_work_prefab = nil
        inst._hh_macanh_give_failed = nil
        inst._hh_macanh_give_movement_failed = nil
        inst._hh_macanh_drop_failed = nil
        inst._hh_macanh_drop_retry_time = nil

        -- Owner-too-far clears the command that existed at the transition.
        -- A pending command can only be a newer command issued afterwards,
        -- so latest-command-wins remains intact for cargo delivery.
        if pending_action ~= nil and pending_prefab ~= nil
            and inst.SetHHWorkCommand ~= nil then
            inst:SetHHWorkCommand(pending_action, pending_prefab)
        end
        return true
    end
    return false
end

local function GetLeaderContainer(leader)
    return leader ~= nil and leader.components ~= nil
        and (leader.components.inventory or leader.components.container) or nil
end

local function CanMakeGiveAction(inst)
    local leader = GetLeader(inst)
    local item = GetCargoItem(inst)
    local container = GetLeaderContainer(leader)
    if leader == nil or not leader:IsValid() or item == nil or container == nil
        or container.CanAcceptCount == nil then
        return false
    end
    if leader.components.inventory ~= nil and not container:IsOpenedBy(leader) then
        return false
    end
    return (container:CanAcceptCount(item) or 0) > 0
end

local function MakeGiveAction(inst)
    local leader = GetLeader(inst)
    if inst._hh_macanh_give_failed
        or inst._hh_macanh_give_movement_failed
        or not CanMakeGiveAction(inst) then
        return nil
    end

    local item = GetCargoItem(inst)
    local generation = inst._hh_work_generation
    local action = BufferedAction(inst, leader, ACTIONS.GIVEALLTOPLAYER, item)
    action._hh_macanh_command_generation = generation
    action.validfn = function()
        return inst._hh_work_generation == generation
    end
    action:AddFailAction(function()
        if not inst._hh_macanh_clearing_action
            and inst.sg ~= nil and inst.sg:HasStateTag("busy") then
            -- A failure while the vanilla "give" state is executing is an
            -- actual transfer refusal/capacity failure. Locomotor/path
            -- cancellation happens outside the busy state and stays
            -- recoverable by following the owner.
            inst._hh_macanh_give_failed = true
        elseif not inst._hh_macanh_clearing_action then
            -- Path/arrival cancellation is movement failure, not proof that
            -- the owner refused the item. Follow owns recovery until near.
            inst._hh_macanh_give_movement_failed = true
        end
    end)
    action:AddSuccessAction(function()
        inst._hh_macanh_give_failed = nil
        inst._hh_macanh_give_movement_failed = nil
    end)
    return action
end

local function CanDropCargoNearOwner(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader:IsValid() and HasCargo(inst)
        and inst:IsNear(leader, MAX_FOLLOW_DIST)
end

local function ShouldDropCargo(inst)
    if not CanDropCargoNearOwner(inst) then
        return false
    end
    if (inst._hh_macanh_drop_retry_time or 0) > GetTime() then
        return false
    end
    return inst._hh_macanh_give_failed
        or inst._hh_macanh_give_movement_failed
        or not CanMakeGiveAction(inst)
end

local function MakeDropAction(inst)
    if not ShouldDropCargo(inst) then
        return nil
    end

    local leader = GetLeader(inst)
    local item = GetCargoItem(inst)
    local action = BufferedAction(inst, nil, ACTIONS.DROP, item, leader:GetPosition())
    action.options.wholestack = true
    action:AddFailAction(function()
        if inst._hh_macanh_clearing_action then
            return
        end

        inst._hh_macanh_drop_failed = true
        inst._hh_macanh_drop_retry_time = GetTime() + 1

        -- Reuse the vanilla inventory drop helper for both action-level
        -- refusal and locomotor/path failure. No prefab is spawned or
        -- duplicated here.
        local retry_leader = GetLeader(inst)
        local retry_item = GetCargoItem(inst)
        local inventory = inst.components.inventory
        if retry_item ~= nil and inventory ~= nil then
            local drop_pos = inst:GetPosition()
            if retry_leader ~= nil and retry_leader:IsValid()
                and inst:IsNear(retry_leader, MAX_FOLLOW_DIST) then
                drop_pos = retry_leader:GetPosition()
            end
            local dropped = inventory:DropItem(
                retry_item, true, true, drop_pos, true)
            if dropped ~= nil then
                inst._hh_macanh_drop_failed = nil
                inst._hh_macanh_drop_retry_time = nil
            end
        end
    end)
    action:AddSuccessAction(function()
        inst._hh_macanh_drop_failed = nil
        inst._hh_macanh_drop_retry_time = nil
    end)
    return action
end

local function EnterOwnerTooFar(inst)
    if inst._hh_macanh_returning_to_owner then
        return
    end

    inst._hh_macanh_returning_to_owner = true
    local had_cargo = HasCargo(inst)

    -- The prefab helper clears the old command and pending command, resets
    -- work/progress recovery, cancels the old buffered action once, and bumps
    -- the generation that guards stale actions.
    inst:CancelHHWorkCommand()

    if had_cargo then
        -- CancelHHWorkCommand already stopped the old work movement. Let the
        -- native Follow node own locomotion from this point onward.
        BeginDelivery(inst, "owner_too_far", true)
    elseif inst._hh_macanh_delivery
        and inst._hh_pending_work_action == nil then
        inst._hh_macanh_delivery_reason = "owner_too_far"
    end
    SetStatus(inst, "Đang quay về chủ")
end

local function IsLeaderInCombat(leader)
    local combat = leader ~= nil and leader.components.combat or nil
    if combat == nil then
        return false
    end
    local cutoff = GetTime() - COMBAT_TIMEOUT
    if math.max(combat.laststartattacktime or 0, combat.lastdoattacktime or 0) > cutoff then
        return true
    end
    if combat:GetLastAttackedTime() > cutoff then
        return combat.lastattacker == nil or combat.lastattacker.components.combat ~= nil
    end
    return false
end

local function IsLeaderTooFar(inst)
    local leader = GetLeader(inst)
    if leader == nil then
        inst._hh_macanh_returning_to_owner = nil
        return false
    end
    local too_far = not inst:IsNear(leader, WORK_EXIT_RADIUS)
    if too_far then
        if not inst._hh_macanh_returning_to_owner then
            EnterOwnerTooFar(inst)
        end
        SetStatus(inst, "Đang quay về chủ")
    elseif inst._hh_macanh_returning_to_owner then
        inst._hh_macanh_returning_to_owner = nil
    end
    return too_far
end

local function IsSafeTarget(target)
    return target ~= nil and target:IsValid() and target.entity:IsVisible()
        and not target:IsInLimbo() and not target:HasAnyTag(unpack(CANT_WORK_TAGS))
        and target:IsOnValidGround()
        and (target.components.burnable == nil
            or (not target.components.burnable:IsBurning()
                and not target.components.burnable:IsSmoldering()))
end

local function PruneFailedTargets(inst, now)
    local failed_targets = inst._hh_macanh_failed_targets
    if failed_targets == nil then
        return
    end
    for target, entry in pairs(failed_targets) do
        if entry == nil or entry.expires == nil or entry.expires <= now
            or target == nil or not target:IsValid() then
            failed_targets[target] = nil
        end
    end
end

local function IsFailedTarget(inst, target, action_id, now)
    local failed_targets = inst._hh_macanh_failed_targets
    local entry = failed_targets ~= nil and failed_targets[target] or nil
    if entry == nil then
        return false
    end
    if entry.expires <= now or entry.action_id ~= action_id then
        failed_targets[target] = nil
        return false
    end
    return true
end

local function BlacklistFailedTarget(inst, target, action_id, now)
    if target == nil then
        return
    end
    local failed_targets = inst._hh_macanh_failed_targets
    if failed_targets == nil then
        failed_targets = {}
        inst._hh_macanh_failed_targets = failed_targets
    end

    local count = 0
    local oldest_target = nil
    local oldest_expiry = math.huge
    for other, entry in pairs(failed_targets) do
        if entry == nil or entry.expires <= now or other == nil or not other:IsValid() then
            failed_targets[other] = nil
        else
            count = count + 1
            if entry.expires < oldest_expiry then
                oldest_target = other
                oldest_expiry = entry.expires
            end
        end
    end
    if count >= MAX_UNREACHABLE_TARGETS and oldest_target ~= nil then
        failed_targets[oldest_target] = nil
    end
    failed_targets[target] = {
        action_id = action_id,
        expires = now + UNREACHABLE_TARGET_TTL,
    }
end

local function IsMatchingTarget(inst, target, action_id, prefab, now)
    if not IsSafeTarget(target) or target.prefab ~= prefab
        or not target:IsNear(inst, GetWorkRadius(inst))
        or IsFailedTarget(inst, target, action_id, now) then
        return false
    end
    if action_id == "PICK" then
        return target.components.pickable ~= nil and target.components.pickable:CanBePicked()
    end
    local workable = target.components.workable
    local action = workable ~= nil and workable:GetWorkAction() or nil
    return workable ~= nil and workable:CanBeWorked()
        and action ~= nil and (action.id or action.str) == action_id
end

local function MakeWorkAction(inst, target, action)
    local generation = inst._hh_work_generation
    local bufferedaction = BufferedAction(inst, target, action)
    bufferedaction._hh_macanh_command_generation = generation
    bufferedaction.validfn = function()
        return inst._hh_work_generation == generation
    end
    return bufferedaction
end

local function FindCommandAction(inst)
    if GetLeader(inst) == nil or inst.sg:HasStateTag("busy") or IsLeaderTooFar(inst) then
        return nil
    end
    if inst._hh_macanh_delivery then
        return nil
    end
    local action_id = inst._hh_work_action
    local prefab = inst._hh_work_prefab
    local action = action_id ~= nil and ACTIONS[action_id] or nil
    if action == nil or prefab == nil then
        SetStatus(inst, "Đang theo chủ")
        return nil
    end
    if HasFullInventoryStack(inst) then
        BeginDelivery(inst, "stack_full")
        return nil
    end

    if HasCargo(inst) then
        if HasCompatibleGroundTarget(inst) then
            return nil
        end
        if action_id ~= "PICK" then
            BeginDelivery(inst, "batch_complete")
            return nil
        end
    end

    local now = GetTime()
    PruneFailedTargets(inst, now)
    local current = inst.sg.statemem.target
    if IsMatchingTarget(inst, current, action_id, prefab, now) then
        SetStatus(inst, STATUS_BY_ACTION[action_id])
        return MakeWorkAction(inst, current, action)
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local musttags = action_id == "PICK" and { "pickable" } or { action_id .. "_workable" }
    local closest = nil
    local closest_distsq = nil
    for _, target in ipairs(TheSim:FindEntities(x, y, z, GetWorkRadius(inst), musttags, CANT_WORK_TAGS)) do
        if IsMatchingTarget(inst, target, action_id, prefab, now) then
            local distsq = inst:GetDistanceSqToInst(target)
            if closest_distsq == nil or distsq < closest_distsq then
                closest = target
                closest_distsq = distsq
            end
        end
    end
    if closest ~= nil then
        SetStatus(inst, STATUS_BY_ACTION[action_id])
        return MakeWorkAction(inst, closest, action)
    end
    if HasCargo(inst) then
        BeginDelivery(inst, "no_more_targets")
    else
        SetStatus(inst, "Đang theo chủ")
    end
    return nil
end

local function ShouldAvoidExplosive(target)
    return target.components.explosive == nil
        or target.components.burnable == nil
        or target.components.burnable:IsBurning()
end

local function ShouldRunAway(target, inst)
    if target.components.health ~= nil and target.components.health:IsDead() then
        return false
    elseif target:HasAnyTag("shadowcreature", "nightmarecreature") then
        if target.HostileToPlayerTest ~= nil then
            local leader = GetLeader(inst)
            return leader ~= nil and target:HostileToPlayerTest(leader)
        end
        return false
    elseif target:HasTag("stalker") then
        return target.atriumstalker
            or (target.canfight and target.components.combat ~= nil and target.components.combat:HasTarget())
    end
    return true
end

local function HasDangerNearby(inst)
    inst._hh_macanh_danger_active = false
    local explosive = FindEntity(inst, AVOID_EXPLOSIVE_DIST, ShouldAvoidExplosive,
        { "explosive" }, { "INLIMBO" })
    if explosive ~= nil then
        SetStatus(inst, "Đang né nguy hiểm")
        inst._hh_macanh_danger_active = true
        return true
    end
    local target = FindEntity(inst, RUN_AWAY_DIST, function(candidate)
        return ShouldRunAway(candidate, inst)
    end, nil, { "player", "INLIMBO", "companion", "spiderden" }, { "monster", "hostile" })
    if target ~= nil then
        SetStatus(inst, "Đang né nguy hiểm")
        inst._hh_macanh_danger_active = true
        return true
    end
    return false
end

local function ResetWorkProgress(inst)
    inst._hh_macanh_progress_target = nil
    inst._hh_macanh_progress_action = nil
    inst._hh_macanh_progress_last_x = nil
    inst._hh_macanh_progress_last_z = nil
    inst._hh_macanh_progress_last_distance = nil
    inst._hh_macanh_progress_current_distance = nil
    inst._hh_macanh_progress_best_distance = nil
    inst._hh_macanh_progress_target_x = nil
    inst._hh_macanh_progress_target_z = nil
    inst._hh_macanh_progress_last_path_step = nil
    inst._hh_macanh_progress_last_time = nil
end

local function UpdateWorkProgress(inst)
    local locomotor = inst.components.locomotor
    local bufferedaction = locomotor ~= nil and locomotor.bufferedaction or nil
    local target = bufferedaction ~= nil and bufferedaction.target or nil
    local action_id = bufferedaction ~= nil and GetActionId(bufferedaction.action) or nil
    if bufferedaction == nil or target == nil or not WORK_ACTIONS[action_id]
        or inst.sg:HasStateTag("busy")
        or inst.sg:HasStateTag("working")
        or inst.sg:HasStateTag("doing")
        or not target:IsValid() then
        ResetWorkProgress(inst)
        return
    end

    local now = GetTime()
    local x, _, z = inst.Transform:GetWorldPosition()
    local target_x, _, target_z = target.Transform:GetWorldPosition()
    local distance = math.sqrt(inst:GetDistanceSqToInst(target))
    local path = locomotor.path
    local path_step = path ~= nil and path.currentstep or nil
    local waiting_for_path = locomotor.WaitingForPathSearch ~= nil
        and locomotor:WaitingForPathSearch()
    if inst._hh_macanh_progress_target ~= target
        or inst._hh_macanh_progress_action ~= action_id then
        inst._hh_macanh_progress_target = target
        inst._hh_macanh_progress_action = action_id
        inst._hh_macanh_progress_last_x = x
        inst._hh_macanh_progress_last_z = z
        inst._hh_macanh_progress_last_distance = distance
        inst._hh_macanh_progress_current_distance = distance
        inst._hh_macanh_progress_best_distance = distance
        inst._hh_macanh_progress_target_x = target_x
        inst._hh_macanh_progress_target_z = target_z
        inst._hh_macanh_progress_last_path_step = path_step
        inst._hh_macanh_progress_last_time = now
        return
    end

    local path_advanced = path_step ~= nil
        and path_step ~= inst._hh_macanh_progress_last_path_step
    inst._hh_macanh_progress_current_distance = distance
    if distance + WORK_PROGRESS_EPSILON < inst._hh_macanh_progress_best_distance then
        -- Motion alone is not progress. Only a new best distance to the
        -- actual work target resets the watchdog.
        inst._hh_macanh_progress_best_distance = distance
        inst._hh_macanh_progress_last_time = now
    elseif waiting_for_path or path_advanced then
        -- A valid detour can temporarily move farther from the target. An
        -- active path search or a new route waypoint is navigation progress;
        -- arbitrary locomotion without either signal is not.
        inst._hh_macanh_progress_last_time = now
    end
    inst._hh_macanh_progress_last_x = x
    inst._hh_macanh_progress_last_z = z
    inst._hh_macanh_progress_last_distance = distance
    inst._hh_macanh_progress_target_x = target_x
    inst._hh_macanh_progress_target_z = target_z
    inst._hh_macanh_progress_last_path_step = path_step

    if now - inst._hh_macanh_progress_last_time >= WORK_PROGRESS_TIMEOUT then
        local failed_target = target
        StopMacanhMovement(inst)
        BlacklistFailedTarget(inst, failed_target, action_id, now)
        ResetWorkProgress(inst)
    end
end

local ProgressFollow = Class(BehaviourNode, function(self, inst, child)
    BehaviourNode._ctor(self, "Macanh Follow Recovery", { child })
    self.inst = inst
    self.child = child
    self.last_target = nil
    self.last_action = nil
    self.last_x = nil
    self.last_z = nil
    self.last_distance = nil
    self.best_distance = nil
    self.last_target_x = nil
    self.last_target_z = nil
    self.last_path_step = nil
    self.last_goal_progress_time = nil
    self.navigation_started_time = nil
    self.last_navigation_time = nil
end)

function ProgressFollow:Reset()
    local was_running = self.status == RUNNING or self.child.status == RUNNING
    self._base.Reset(self)
    self.last_target = nil
    self.last_action = nil
    self.last_x = nil
    self.last_z = nil
    self.last_distance = nil
    self.best_distance = nil
    self.last_target_x = nil
    self.last_target_z = nil
    self.last_path_step = nil
    self.last_goal_progress_time = nil
    self.navigation_started_time = nil
    self.last_navigation_time = nil
    if was_running and self.inst.components.locomotor ~= nil then
        self.inst.components.locomotor:Stop()
    end
end

function ProgressFollow:Visit()
    if IsFollowRecoveryBlocking(self.inst) then
        if self.status == RUNNING and self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:Stop()
        end
        self.status = FAILED
        return
    end

    self.child:Visit()
    self.status = self.child.status
    if self.status ~= RUNNING then
        return
    end

    local target = self.child.currenttarget
    if target == nil or not target:IsValid() then
        return
    end

    local x, _, z = self.inst.Transform:GetWorldPosition()
    local target_x, _, target_z = target.Transform:GetWorldPosition()
    local distance = math.sqrt(self.inst:GetDistanceSqToInst(target))
    local locomotor = self.inst.components.locomotor
    local path = locomotor ~= nil and locomotor.path or nil
    local path_step = path ~= nil and path.currentstep or nil
    local waiting_for_path = locomotor ~= nil
        and locomotor.WaitingForPathSearch ~= nil
        and locomotor:WaitingForPathSearch()
    local action = self.child.action
    local now = GetTime()
    if self.last_target ~= target or self.last_action ~= action then
        self.last_target = target
        self.last_action = action
        self.last_x = x
        self.last_z = z
        self.last_distance = distance
        self.best_distance = distance
        self.last_target_x = target_x
        self.last_target_z = target_z
        self.last_path_step = path_step
        self.last_goal_progress_time = now
        self.navigation_started_time = nil
        self.last_navigation_time = nil
        return
    end

    local epsilon_sq = FOLLOW_PROGRESS_EPSILON * FOLLOW_PROGRESS_EPSILON
    local shadow_dx = x - self.last_x
    local shadow_dz = z - self.last_z
    local owner_dx = target_x - self.last_target_x
    local owner_dz = target_z - self.last_target_z
    local owner_moved = owner_dx * owner_dx + owner_dz * owner_dz >= epsilon_sq
    local shadow_moved = shadow_dx * shadow_dx + shadow_dz * shadow_dz >= epsilon_sq
    local relative_not_worse = distance <= self.last_distance + FOLLOW_PROGRESS_EPSILON
    local moving_with_owner = owner_moved and shadow_moved and relative_not_worse
        and shadow_dx * (self.last_target_x - self.last_x)
            + shadow_dz * (self.last_target_z - self.last_z) > 0
    local path_advanced = path_step ~= nil and path_step ~= self.last_path_step
    local navigation_activity = waiting_for_path or path_advanced
    if navigation_activity then
        -- Start one navigation episode. Further path searches/step changes
        -- belong to this same episode and must not restart its watchdog.
        self.navigation_started_time = self.navigation_started_time or now
        self.last_navigation_time = now
    end

    local navigation_recent = self.last_navigation_time ~= nil
        and now - self.last_navigation_time <= FOLLOW_NAVIGATION_RECENT_WINDOW
    local direct_follow_resumed = self.navigation_started_time ~= nil
        and not waiting_for_path
        and not navigation_recent
        and path == nil
        and shadow_moved
        and relative_not_worse
    if direct_follow_resumed then
        -- A completed detour that has returned to direct locomotion is no
        -- longer an unreachable-path episode. This requires actual movement
        -- with stable spacing; a failed search with no movement stays bounded.
        self.navigation_started_time = nil
        self.last_navigation_time = nil
    end

    local moving_owner_goal_progress = moving_with_owner
        and self.navigation_started_time == nil

    if distance + FOLLOW_PROGRESS_EPSILON < self.best_distance then
        self.best_distance = distance
        self.last_goal_progress_time = now
    elseif moving_owner_goal_progress then
        -- When the owner is moving, a valid follower can hold a stable
        -- relative distance without improving absolute distance every tick.
        -- Count that only outside a bounded navigation episode. Path search,
        -- repath, and waypoint transitions are navigation activity, not goal
        -- progress, and cannot reset this timer by themselves.
        self.last_goal_progress_time = now
    end
    self.last_x = x
    self.last_z = z
    self.last_distance = distance
    self.last_target_x = target_x
    self.last_target_z = target_z
    self.last_path_step = path_step

    local timeout = self.navigation_started_time ~= nil
        and FOLLOW_MAX_NO_GOAL_PROGRESS or FOLLOW_PROGRESS_TIMEOUT
    if now - self.last_goal_progress_time >= timeout then
        self.inst._hh_macanh_follow_recovery_until = now + FOLLOW_RECOVERY_COOLDOWN
        if self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:Stop()
        end
        self.status = FAILED
    end
end

local ProgressRunAway = Class(BehaviourNode, function(self, inst, child)
    BehaviourNode._ctor(self, "Macanh RunAway Recovery", { child })
    self.inst = inst
    self.child = child
    self.last_hunter = nil
    self.last_distance = nil
    self.best_distance = nil
    self.last_x = nil
    self.last_z = nil
    self.last_hunter_x = nil
    self.last_hunter_z = nil
    self.last_progress_time = nil
end)

function ProgressRunAway:Reset()
    local was_running = self.status == RUNNING or self.child.status == RUNNING
    self._base.Reset(self)
    self.last_hunter = nil
    self.last_distance = nil
    self.best_distance = nil
    self.last_x = nil
    self.last_z = nil
    self.last_hunter_x = nil
    self.last_hunter_z = nil
    self.last_progress_time = nil
    if was_running and self.inst.components.locomotor ~= nil then
        self.inst.components.locomotor:Stop()
    end
end

function ProgressRunAway:Visit()
    if IsDangerRecoveryActive(self.inst) then
        if self.status == RUNNING and self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:Stop()
        end
        self.status = FAILED
        return
    end

    self.child:Visit()
    self.status = self.child.status
    if self.status ~= RUNNING then
        return
    end

    local hunter = self.child.hunter
    if hunter == nil or not hunter:IsValid() then
        return
    end

    local x, _, z = self.inst.Transform:GetWorldPosition()
    local hunter_x, _, hunter_z = hunter.Transform:GetWorldPosition()
    local distance = math.sqrt(self.inst:GetDistanceSqToInst(hunter))
    local now = GetTime()
    if self.last_hunter ~= hunter then
        self.last_hunter = hunter
        self.last_distance = distance
        self.best_distance = distance
        self.last_x = x
        self.last_z = z
        self.last_hunter_x = hunter_x
        self.last_hunter_z = hunter_z
        self.last_progress_time = now
        return
    end

    local epsilon_sq = RUNAWAY_PROGRESS_EPSILON * RUNAWAY_PROGRESS_EPSILON
    local shadow_dx = x - self.last_x
    local shadow_dz = z - self.last_z
    local hunter_dx = hunter_x - self.last_hunter_x
    local hunter_dz = hunter_z - self.last_hunter_z
    local hunter_moved = hunter_dx * hunter_dx + hunter_dz * hunter_dz >= epsilon_sq
    local shadow_moved = shadow_dx * shadow_dx + shadow_dz * shadow_dz >= epsilon_sq
    local relative_not_worse = distance + RUNAWAY_PROGRESS_EPSILON >= self.last_distance
    local moving_away = shadow_dx * (self.last_x - self.last_hunter_x)
        + shadow_dz * (self.last_z - self.last_hunter_z) > 0

    if distance >= self.best_distance + RUNAWAY_PROGRESS_EPSILON then
        self.best_distance = distance
        self.last_progress_time = now
    elseif hunter_moved and shadow_moved and relative_not_worse and moving_away then
        -- A pursuer and the shadow can travel in the same direction at the
        -- same speed. Stable spacing with genuine outward motion is valid
        -- escape progress; otherwise the old watchdog would stop/retry every
        -- few seconds while the threat was still active.
        self.last_progress_time = now
    end
    self.last_distance = distance
    self.last_x = x
    self.last_z = z
    self.last_hunter_x = hunter_x
    self.last_hunter_z = hunter_z

    if now - self.last_progress_time >= RUNAWAY_PROGRESS_TIMEOUT then
        self.inst._hh_macanh_danger_recovery_until = now + DANGER_RECOVERY_COOLDOWN
        if self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:Stop()
        end
        self.status = FAILED
    end
end

local function MakeFollowNode(inst)
    return ProgressFollow(inst, Follow(
        inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST))
end

local function MakeRunAwayNode(inst, ...)
    -- Vanilla RunAway expects the owner entity as its first constructor argument.
    return ProgressRunAway(inst, RunAway(inst, ...))
end

local function GetFollowRecoveryWaitTime(inst)
    return math.max(0, (inst._hh_macanh_follow_recovery_until or GetTime()) - GetTime())
end

local function GetDangerRecoveryWaitTime(inst)
    return math.max(0, (inst._hh_macanh_danger_recovery_until or GetTime()) - GetTime())
end

local HHMacanhShadowBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function HHMacanhShadowBrain:OnStart()
    local leader = GetLeader(self.inst)
    local ignorethese = leader ~= nil and (leader._brain_pickup_ignorethese or {}) or {}
    if leader ~= nil then
        leader._brain_pickup_ignorethese = ignorethese
    end

    local function ShouldPickup()
        return not self.inst.sg:HasStateTag("phasing")
            and not self.inst._hh_macanh_delivery
            and not IsLeaderTooFar(self.inst)
    end
    local function ShouldDeliver()
        local current_leader = GetLeader(self.inst)
        return not self.inst.sg:HasStateTag("phasing")
            and current_leader ~= nil and not IsLeaderInCombat(current_leader)
            and not HasCompatibleGroundTarget(self.inst)
    end
    local pickupparams = {
        cond = ShouldPickup,
        range = GetWorkRadius(self.inst),
        give_cond = ShouldDeliver,
        give_range = GetWorkRadius(self.inst),
        furthestfirst = false,
        positionoverride = function() return self.inst:GetPosition() end,
        ignorethese = ignorethese,
        wholestacks = true,
        allowpickables = false,
    }

    local deliver = WhileNode(function()
        if not self.inst._hh_macanh_delivery then return false end
        if FinishDelivery(self.inst) then return false end
        SetStatus(self.inst, "Đang giao tài nguyên")
        return true
    end, "Deliver locked cargo", PriorityNode({
        DoAction(self.inst, function()
            if FinishDelivery(self.inst) then return nil end
            return MakeGiveAction(self.inst)
        end, "Give cargo to owner", true),
        DoAction(self.inst, function()
            if FinishDelivery(self.inst) then return nil end
            return MakeDropAction(self.inst)
        end, "Drop cargo near owner", true),
        MakeFollowNode(self.inst),
    }, .25))

    local avoid_explosions = MakeRunAwayNode(self.inst,
        { fn = ShouldAvoidExplosive, tags = { "explosive" }, notags = { "INLIMBO" } },
        AVOID_EXPLOSIVE_DIST, AVOID_EXPLOSIVE_DIST)
    local avoid_danger = MakeRunAwayNode(self.inst,
        { fn = ShouldRunAway, oneoftags = { "monster", "hostile" },
            notags = { "player", "INLIMBO", "companion", "spiderden" } },
        RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
    local danger_recovery_wait = WhileNode(function()
        return IsDangerRecoveryActive(self.inst)
            and self.inst._hh_macanh_danger_active
    end, "Danger movement recovery", WaitNode(function()
        return GetDangerRecoveryWaitTime(self.inst)
    end))

    local root = PriorityNode({
        WhileNode(function()
            return HasDangerNearby(self.inst)
        end, "Avoid danger", PriorityNode({
            avoid_explosions,
            avoid_danger,
            danger_recovery_wait,
        }, .25)),
        WhileNode(function() return IsLeaderTooFar(self.inst) end, "Return to owner",
            MakeFollowNode(self.inst)),
        deliver,
        WhileNode(function()
            return IsFollowRecoveryBlocking(self.inst)
        end, "Follow movement recovery", WaitNode(function()
            return GetFollowRecoveryWaitTime(self.inst)
        end)),
        WhileNode(function()
            self.keepworking = false
            return true
        end, "Mirror owner work", DoAction(self.inst, function()
            local act = FindCommandAction(self.inst)
            if act ~= nil then
                if self.inst.sg:HasStateTag("pre" .. string.lower(act.action.id)) then
                    self.keepworking = true
                else
                    return act
                end
            end
        end)),
        FailIfSuccessDecorator(ConditionWaitNode(function() return not self.keepworking end, "Repeating action")),
        BrainCommon.NodeAssistLeaderPickUps(self, pickupparams),
        MakeFollowNode(self.inst),
    }, .25)

    self.bt = BT(self.inst, root)
end

function HHMacanhShadowBrain:DoUpdate()
    if GetLeader(self.inst) == nil then
        ResetWorkProgress(self.inst)
        self.inst._hh_macanh_failed_targets = nil
        self.inst._hh_macanh_returning_to_owner = nil
        self.inst._hh_macanh_follow_recovery_until = nil
        self.inst._hh_macanh_danger_recovery_until = nil
        self.inst._hh_macanh_give_failed = nil
        self.inst._hh_macanh_give_movement_failed = nil
        StopMacanhMovement(self.inst)
        return
    end
    UpdateWorkProgress(self.inst)
end

function HHMacanhShadowBrain:OnStop()
    ResetWorkProgress(self.inst)
    self.inst._hh_macanh_failed_targets = nil
    self.inst._hh_macanh_returning_to_owner = nil
    self.inst._hh_macanh_follow_recovery_until = nil
    self.inst._hh_macanh_danger_recovery_until = nil
    self.inst._hh_macanh_give_failed = nil
    self.inst._hh_macanh_give_movement_failed = nil
    if self.inst:IsValid() then
        StopMacanhMovement(self.inst)
    end
end

return HHMacanhShadowBrain
