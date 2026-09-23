-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
require("stategraphs/commonstates")
local actionhandlers =
{
}
local function spawnfire(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    for k = 90,-90,-180 do
        local facing_angle = (inst.Transform:GetRotation() + k) * DEGREES
        local fx = SpawnAt("ttk_boss_ziyunjfsn_fire",Vector3(x + 1.5* math.cos(facing_angle), y, z - 1.5 * math.sin(facing_angle)))
        fx.owner = inst.owner or inst
        fx.damage = inst.firedamage or 10
    end
end
local events =
{
}
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end
local function findtarget(inst)
    local owner = inst.owner
    return owner ~= nil and FindEntity(inst, 20,
        function(guy)
            return owner:IsValid() and XD_CanAttackTrget(inst,guy) and guy
        end,
        { "_combat","_health" },
        noltags
    ) or nil
end
local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("eatfish")
        end,
        timeline =
        {
            TimeEvent(0.6, function(inst) inst.SoundEmitter:PlaySound("xd_jfsnsound/xd_jfsnsound/jiao", nil, 0.3) end),
            TimeEvent(18* FRAMES, function(inst)
                if inst.iscanying then
                    local target = inst.firedamage and findtarget(inst) or nil
                    if target then
                        inst.sg:GoToState("swoop_pre",target)
                    else
                        inst.sg:GoToState("gohome")
                    end
                end
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                local target = inst.firedamage and findtarget(inst) or nil
                if target then
                    inst.sg:GoToState("swoop_pre",target)
                else
                    inst.sg:GoToState("gohome")
                end
            end),
        },
    },
    State{
        name = "gohome",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("despawn")
            inst:ClearBufferedAction()
        end,
        timeline =
        {
        },
        events =
        {
            EventHandler("animover", function(inst)
                inst:Remove()
            end),
        },
    },
    State{
        name = "swoop_pre",
        tags = {"busy", "canrotate", "swoop"},
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.sg.statemem.target = target
            inst.AnimState:PlayAnimation("swoop_pre")
        end,
        onupdate = function(inst)
            local target = inst.sg.statemem.target
            if not inst.sg.statemem.stopsteering and target and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,
        timeline =
        {
            TimeEvent(11 * FRAMES, function(inst) inst.sg.statemem.stopsteering = true end),
        },
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("swoop_loop") end),
        },
    },
    State{
        name = "swoop_loop",
        tags = {"busy", "swoop"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("swoop_loop", true)
            inst.Physics:SetMotorVelOverride(15,0,0)
            inst.sg:SetTimeout(20/15)
            inst.sg.statemem.collisiontime = 0
            spawnfire(inst)
        end,
        onupdate = function(inst, dt)
            inst.Physics:SetMotorVelOverride(15,0,0)
        end,
        timeline =
        {
            TimeEvent(2/15, function(inst)
                spawnfire(inst)
            end),
            TimeEvent(6/15, function(inst)
                spawnfire(inst)
            end),
            TimeEvent(10/15, function(inst)
                spawnfire(inst)
            end),
            TimeEvent(14/15, function(inst)
                spawnfire(inst)
            end),
            TimeEvent(18/15, function(inst)
                spawnfire(inst)
            end),
        },
        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.Physics:ClearMotorVelOverride()
        end,
        ontimeout=function(inst)
            inst.sg:GoToState("swoop_pst")
        end,
    },
    State{
        name = "swoop_pst",
        tags = {"busy", "swoop"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("swoop_pst")
        end,
        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        },
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("gohome") end),
        },
    },
}
return StateGraph("ttk_boss_ziyunjfsn", states, events, "idle", actionhandlers)
