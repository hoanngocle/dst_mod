-- Reuse the complete, battle-tested Maxwell shadow state collection. Only the
-- three worker tool handlers need replacing because vanilla gates symbol swaps
-- behind inst.prefab == "shadowworker".
local base = require("stategraphs/SGshadowwaxwell")

local SHADOW_TALK_SOUND = "dontstarve/maxwell/talk_LP"

local function FixupWorkerCarry(inst, swap)
    if inst.sg.mem.swaptool == swap then
        return false
    end
    inst.sg.mem.swaptool = swap
    if swap == nil then
        inst.AnimState:ClearOverrideSymbol("swap_object")
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")
    else
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Hide("ARM_normal")
        inst.AnimState:OverrideSymbol("swap_object", swap, swap)
    end
    return true
end

local states = {}
for _, state in pairs(base.states) do
    table.insert(states, state)
end

local events = {}
for _, event in pairs(base.events) do
    table.insert(events, event)
end
table.insert(events, CommonHandlers.OnFreeze())
local COMMAND_INVALIDATING_STATES = {
    chop_start = true,
    chop = true,
    mine_start = true,
    mine = true,
    mine_recoil = true,
    dig_start = true,
    dig = true,
    item_out_chop = true,
    item_out_mine = true,
    item_out_dig = true,
    item_out = true,
    take = true,
    give = true,
    hh_pick_long = true,
    hh_pick_short = true,
}
table.insert(events, EventHandler("hh_macanh_command_changed", function(inst, data)
    local generation = data ~= nil and data.generation or nil
    if generation == nil or generation ~= inst._hh_work_generation then
        return
    end

    -- Vanilla worker timelines repeat statemem.action. A command generation
    -- change invalidates that old action and returns the shadow to idle; an
    -- unchanged generation keeps the inherited repeat behaviour intact.
    local state = inst.sg.currentstate
    if state == nil or not COMMAND_INVALIDATING_STATES[state.name] then
        return
    end
    if inst.sg.statemem ~= nil then
        inst.sg.statemem.action = nil
        inst.sg.statemem.target = nil
        inst.sg.statemem.hh_work_generation = generation
    end
    inst.sg:GoToState("idle", true)
end))

CommonStates.AddFrozenStates(states)

local actionhandlers = {}
for action, handler in pairs(base.actionhandlers) do
    if action ~= ACTIONS.CHOP and action ~= ACTIONS.MINE
        and action ~= ACTIONS.DIG and action ~= ACTIONS.PICK then
        table.insert(actionhandlers, handler)
    end
end

table.insert(states, State{
    name = "hh_pick_long",
    tags = { "doing", "busy", "nodangle" },

    onenter = function(inst)
        local speed = math.max(1, inst._hh_pick_speed_mult or 1)
        inst.sg.statemem.action = inst:GetBufferedAction()
        inst.sg:SetTimeout(1 / speed)
        inst.components.locomotor:Stop()
        inst.AnimState:SetDeltaTimeMultiplier(speed)
        inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", true)
        if inst.bufferedaction ~= nil and inst.bufferedaction.target ~= nil
            and inst.bufferedaction.target:IsValid() then
            inst.bufferedaction.target:PushEvent("startlongaction", inst)
        end
        inst.sg.statemem.release_busy_task = inst:DoTaskInTime(4 * FRAMES / speed, function(inst)
            inst.sg.statemem.release_busy_task = nil
            inst.sg:RemoveStateTag("busy")
        end)
    end,

    ontimeout = function(inst)
        inst.AnimState:PlayAnimation("build_pst")
        inst:PerformBufferedAction()
    end,

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end
        end),
    },

    onexit = function(inst)
        if inst.sg.statemem.release_busy_task ~= nil then
            inst.sg.statemem.release_busy_task:Cancel()
        end
        inst.AnimState:SetDeltaTimeMultiplier(1)
        if inst.bufferedaction == inst.sg.statemem.action then inst:ClearBufferedAction() end
    end,
})

table.insert(states, State{
    name = "hh_pick_short",
    tags = { "doing", "busy" },

    onenter = function(inst)
        local speed = math.max(1, inst._hh_pick_speed_mult or 1)
        inst.components.locomotor:Stop()
        inst.AnimState:SetDeltaTimeMultiplier(speed)
        inst.AnimState:PlayAnimation("pickup")
        inst.AnimState:PushAnimation("pickup_pst", false)
        inst.sg.statemem.action = inst:GetBufferedAction()
        inst.sg:SetTimeout(10 * FRAMES / speed)
        inst.sg.statemem.perform_task = inst:DoTaskInTime(6 * FRAMES / speed, function(inst)
            inst.sg.statemem.perform_task = nil
            inst:PerformBufferedAction()
        end)
    end,

    ontimeout = function(inst)
        inst.sg:GoToState("idle", true)
    end,

    onexit = function(inst)
        if inst.sg.statemem.perform_task ~= nil then inst.sg.statemem.perform_task:Cancel() end
        inst.AnimState:SetDeltaTimeMultiplier(1)
        if inst.bufferedaction == inst.sg.statemem.action then inst:ClearBufferedAction() end
    end,
})

table.insert(actionhandlers, ActionHandler(ACTIONS.PICK, function(inst, action)
    FixupWorkerCarry(inst, nil)
    local target = action.target
    if target == nil then return nil end
    local pickable = target.components.pickable
    local searchable = target.components.searchable
    local quick = pickable ~= nil and (pickable.jostlepick or pickable.quickpick)
        or searchable ~= nil and (searchable.jostlesearch or searchable.quicksearch)
    return quick and "hh_pick_short" or "hh_pick_long"
end))

table.insert(actionhandlers, ActionHandler(ACTIONS.CHOP, function(inst)
    if FixupWorkerCarry(inst, "swap_axe") then
        return "item_out_chop"
    elseif not inst.sg:HasStateTag("prechop") then
        return inst.sg:HasStateTag("chopping") and "chop" or "chop_start"
    end
end))

table.insert(actionhandlers, ActionHandler(ACTIONS.MINE, function(inst)
    if FixupWorkerCarry(inst, "swap_pickaxe") then
        return "item_out_mine"
    elseif not inst.sg:HasStateTag("premine") then
        return inst.sg:HasStateTag("mining") and "mine" or "mine_start"
    end
end))

table.insert(actionhandlers, ActionHandler(ACTIONS.DIG, function(inst)
    if FixupWorkerCarry(inst, "swap_shovel") then
        return "item_out_dig"
    elseif not inst.sg:HasStateTag("predig") then
        return inst.sg:HasStateTag("digging") and "dig" or "dig_start"
    end
end))

-- SGshadowwaxwell has no Talker state because the vanilla worker has no
-- talker component. Macanh adds one, so mirror the vanilla player speech
-- event chain without replacing the worker state collection.
table.insert(states, State{
    name = "hh_shadow_talk",
    tags = { "idle", "talking" },
    onenter = function(inst, noanim)
        inst.components.locomotor:Stop()
        if not noanim then
            inst.AnimState:PlayAnimation("dial_loop", true)
        end
        inst.SoundEmitter:PlaySound(SHADOW_TALK_SOUND, "hh_shadow_talk")
        inst.sg:SetTimeout(1.5 + math.random() * .5)
    end,
    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,
    events = {
        EventHandler("donetalking", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
    onexit = function(inst)
        inst.SoundEmitter:KillSound("hh_shadow_talk")
    end,
})

table.insert(events, EventHandler("ontalk", function(inst, data)
    if inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
        inst.sg:GoToState("hh_shadow_talk", data ~= nil and data.noanim)
    end
end))

return StateGraph("hh_macanh_shadow", states, events, base.defaultstate, actionhandlers)
