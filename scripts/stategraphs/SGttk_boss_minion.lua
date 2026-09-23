-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require "stategraphs/commonstates"
local events =
{
    EventHandler("death", function(inst)
        if not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death")
        end
    end),
}
local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst)
            inst.Physics:Stop()
            if not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
        events =
        {
            EventHandler("locomote", function(inst)
                if inst.components.locomotor:WantsToMoveForward() then
                    inst.sg:GoToState("walk")
                end
            end),
        },
    },
    State{
        name = "walk",
        tags = { "moving", "canrotate" },
        onenter = function(inst)
            if inst.movestarttime ~= nil then
                inst.components.locomotor:StopMoving()
                inst.sg:SetTimeout(inst.movestarttime)
            else
                inst.components.locomotor:WalkForward()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/minion/step")
                if inst.movestoptime ~= nil then
                    inst.sg:SetTimeout(inst.movestoptime)
                end
            end
            inst.AnimState:PlayAnimation("walk")
        end,
        ontimeout = function(inst)
            if inst.movestarttime ~= nil then
                inst.components.locomotor:WalkForward()
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/minion/step")
            else
                inst.components.locomotor:StopMoving()
            end
        end,
        events =
        {
            EventHandler("locomote", function(inst)
                if inst.components.locomotor:WantsToMoveForward() then
                    if inst.sg.statemem.stopped then
                        inst.sg.statemem.stopped = nil
                        inst.sg:RemoveStateTag("idle")
                        inst.sg:AddStateTag("moving")
                        inst.sg:AddStateTag("canrotate")
                    end
                elseif not inst.sg.statemem.stopped then
                    inst.sg.statemem.stopped = true
                    inst.sg:RemoveStateTag("moving")
                    inst.sg:RemoveStateTag("canrotate")
                    inst.sg:AddStateTag("idle")
                    inst.components.locomotor:StopMoving()
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.sg.statemem.stopped and "idle" or "walk")
                end
            end),
        },
    },
    State{
        name = "emerge",
        tags = { "busy", "noattack" },
        onenter = function(inst)
            inst.emerging = true
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("spawn")
            inst.DynamicShadow:Enable(false)
            inst.sg:SetTimeout(inst.emergeimmunetime)
        end,
        timeline =
        {
        },
        ontimeout = function(inst)
            inst.sg.statemem.emerging = true
            inst.sg:GoToState("emerge2")
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.emerging = false
            if not inst.sg.statemem.emerging then
                inst.DynamicShadow:Enable(true)
            end
        end,
    },
    State{
        name = "emerge2",
        tags = { "busy" },
        onenter = function(inst)
            inst.sg:SetTimeout(inst.emergeshadowtime - inst.emergeimmunetime)
        end,
        ontimeout = function(inst)
            inst.DynamicShadow:Enable(true)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,
    },
    State{
        name = "death",
        tags = { "busy", "dead" },
        onenter = function(inst, anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(anim or "hit")
            inst.Physics:SetActive(false)
            inst:AddTag("NOCLICK")
            inst.persists = false
        end,
        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/minion/hit")
                inst:DoDamage()
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Remove()
                end
            end),
        },
        onexit = function(inst)
            inst:RemoveTag("NOCLICK")
            inst.DynamicShadow:Enable(true)
            inst.Physics:SetActive(true)
        end,
    },
}
return StateGraph("ttk_boss_minion", states, events, "idle")
