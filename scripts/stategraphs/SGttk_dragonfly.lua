require("stategraphs/commonstates")
local TTK_GetGroundPoints = require("ttk_batch19_houseutil").GetGroundPoints

local function onattackedfn(inst)
    if (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("caninterrupt")) and not inst.components.health:IsDead() then
        if not CommonHandlers.HitRecoveryDelay(inst) then
            inst.sg:GoToState("hit")
        end
    end
end

local function ChooseAttack(inst) 
    inst.sg:GoToState(inst.enraged and inst.can_ground_pound and "pound_pre" or "attack")
    return true
end

local function onattackfn(inst)
    if not (inst.sg:HasStateTag("busy") or
            inst.sg:HasStateTag("grounded") or
            inst.components.health:IsDead()) then
        ChooseAttack(inst)
    end
end

local function ShakeIfClose(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .8, inst, 40)
end

local function doringfx(inst,pt,points,fx1,fx2)
    SpawnPrefab(fx1 or "firering_fx").Transform:SetPosition(pt:Get())
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab(fx2 or "firesplash_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end   
end

local function SwitchToFlyOverPhysics(inst)
    if not inst.sg.mem.flyoverphysics then
        inst.sg.mem.flyoverphysics = true
        CommonHandlers.UpdateHitRecoveryDelay(inst)
        inst.hit_recovery = TUNING.DRAGONFLY_FLYING_HIT_RECOVERY
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
end

local function SwitchToCombatPhysics(inst)
    if inst.sg.mem.flyoverphysics then
        inst.sg.mem.flyoverphysics = false
        inst.hit_recovery = TUNING.DRAGONFLY_HIT_RECOVERY
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "flyaway"), 
}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    EventHandler("doattack", onattackfn),
    EventHandler("attacked", onattackedfn),
}

local states =
{
    State{
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            if inst.sg.mem.sleeping then
                inst.sg:GoToState("sleep")
            else
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "walk_start",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            if inst.enraged then
                inst.AnimState:PlayAnimation("walk_angry_pre")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
            else
                inst.AnimState:PlayAnimation("walk_pre")
            end
            if inst.sg.mem.flyover then 
                SwitchToFlyOverPhysics(inst)
            end
            inst.components.locomotor:WalkForward()
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) if not inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
            TimeEvent(2*FRAMES, function(inst) if inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.walking = true
                    inst.sg:GoToState("walk")
                end
            end),
        },

        onexit = function(inst)
            if not (inst.sg.statemem.walking and inst.sg.mem.flyover) then
                SwitchToCombatPhysics(inst)
            end
        end,
    },

    State{
        name = "walk",
        tags = { "moving", "canrotate" },

        onenter = function(inst)
            if inst.enraged then
                inst.AnimState:PlayAnimation("walk_angry")
                if math.random() < .5 then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/angry")
                end
            else
                inst.AnimState:PlayAnimation("walk")
            end
            if inst.sg.mem.flyover then
                SwitchToFlyOverPhysics(inst)
            end
            inst.components.locomotor:WalkForward()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.walking = true
                    inst.sg:GoToState("walk")
                end
            end),
        },

        onexit = function(inst)
            if not (inst.sg.statemem.walking and inst.sg.mem.flyover) then
                SwitchToCombatPhysics(inst)
            end
        end,
    },

    State{
        name = "walk_stop",
        tags = { "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation(inst.enraged and "walk_angry_pst" or "walk_pst")
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) if not inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
            TimeEvent(2*FRAMES, function(inst) if inst.enraged then inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = { "hit", "busy" },

        onenter = function(inst, cb)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
			CommonHandlers.UpdateHitRecoveryDelay(inst)
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.doattack then
                    if not inst.components.health:IsDead() and ChooseAttack(inst) then
                        return
                    end
                    inst.sg.statemem.doattack = nil
                end
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.sg:AddStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("doattack", function(inst)
                inst.sg.statemem.doattack = true
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.doattack and ChooseAttack(inst) then
                        return
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "flyaway",
        tags = { "flight", "busy", "nosleep", "nofreeze" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        timeline =
        {
            TimeEvent(0.5, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door") 
                inst:PerformBufferedAction() inst.sg:GoToState("idle") 
            end),
        },
    },

    State{
        name = "attack",
        tags = { "attack", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.sg.statemem.target = inst.components.combat.target
            inst.AnimState:PlayAnimation("atk")
            if inst.enraged then
                local attackfx = SpawnPrefab("attackfire_fx")
                attackfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                attackfx.Transform:SetRotation(inst.Transform:GetRotation())
            end
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/swipe") end),
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/punchimpact")
				local target = inst.sg.statemem.target
				inst.components.combat:DoAttack(target)
                if inst.enraged and target ~= nil and target.components.health ~= nil and not target.components.health:IsDead() and target:IsValid() then
                    target.components.health:DoFireDamage(5, inst, true)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "transform_fire",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()

            if inst.enraged then
                inst.sg:GoToState("idle")
            else
                inst.AnimState:PlayAnimation("fire_on")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(7*FRAMES, function(inst)
                inst:TransformFire()
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/firedup", "fireflying")
            end),
        },
    },

    State{
        name = "transform_normal",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Physics:Stop()

            if not inst.enraged then
                inst.sg:GoToState("idle")
            else
                inst.AnimState:PlayAnimation("fire_off")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(17*FRAMES, function(inst)
                inst:TransformNormal()
                inst.SoundEmitter:KillSound("fireflying")
            end),
        },
    },

    State{
        name = "pound_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("pound")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
            end),
        },
    },

    State{
        name = "pound",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("taunt")
            local tauntfx = SpawnPrefab("tauntfire_fx")
            tauntfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            tauntfx.Transform:SetRotation(inst.Transform:GetRotation())

            inst.can_ground_pound = false
            inst.components.timer:StartTimer("groundpound_cd", TUNING.DRAGONFLY_POUND_CD)

            inst.sg.statemem.points = TTK_GetGroundPoints(inst:GetPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("pound_post")
                end
            end),
        },

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                if inst.sg.statemem.points then
                    local pt = inst:GetPosition()
                    doringfx(inst,pt,inst.sg.statemem.points)
                end
                inst:DoAoe()

            end),
            TimeEvent(9*FRAMES, function(inst)
                if inst.sg.statemem.points then
                    local pt = inst:GetPosition()
                    doringfx(inst,pt,inst.sg.statemem.points)
                end
                inst:DoAoe()

            end),
            TimeEvent(20*FRAMES, function(inst)
                if inst.sg.statemem.points then
                    local pt = inst:GetPosition()
                    doringfx(inst,pt,inst.sg.statemem.points)
                end
                inst:DoAoe()

            end),
        },
    },

    State{
        name = "pound_post",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
        },
    },
    State{
        name = "sleep",
        tags = { "busy", "sleeping", "nowake", "caninterrupt" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("land")
            inst.AnimState:PushAnimation("land_idle", false)
            inst.AnimState:PushAnimation("takeoff", false)
            inst.AnimState:PushAnimation("sleep_pre", false)
        end,

        timeline =
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:KillSound("flying") end),
            TimeEvent(16*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/land")
            end),
            TimeEvent(74*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(78*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying") end),
            TimeEvent(91*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(111*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/sleep_pre") end),
            TimeEvent(202*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink")
                inst.SoundEmitter:KillSound("flying")
                inst.sg:RemoveStateTag("caninterrupt")
            end),
            TimeEvent(203*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/land") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.continuesleeping = true
                    inst.sg:GoToState(inst.sg.mem.sleeping and "sleeping" or "wake")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping then
                
                if not inst.SoundEmitter:PlayingSound("flying") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                end
                if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                    inst.components.sleeper:WakeUp()
                end
            end
        end,
    },

    State{
        name = "sleeping",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("sleep_loop")
            if not inst.SoundEmitter:PlayingSound("sleep") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/sleep", "sleep")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.continuesleeping = true
                    inst.sg:GoToState("sleeping")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.continuesleeping then
                
                inst.SoundEmitter:KillSound("sleep")
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                    inst.components.sleeper:WakeUp()
                end
            end
        end,
    },

    State{
        name = "wake",
        tags = { "busy", "waking", "nosleep" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("sleep_pst")
            inst.SoundEmitter:KillSound("sleep")
            inst.SoundEmitter:KillSound("flying")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/wake")
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
        end,

        timeline =
        {
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            CommonHandlers.OnNoSleepTimeEvent(26 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nosleep")
            end),
        },

        events =
        {
            CommonHandlers.OnNoSleepAnimOver("idle"),
        },

        onexit = function(inst)
            
            if not inst.SoundEmitter:PlayingSound("flying") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
            end
        end,
    },

    State{
        name = "death",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.Light:Enable(false)
            inst.AnimState:PlayAnimation("death")
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/death")
            inst:AddTag("NOCLICK")
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/blink") end),
            TimeEvent(26*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("flying")
                inst.SoundEmitter:KillSound("fireflying")
            end),
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/land") end),
            TimeEvent(29*FRAMES, function(inst)
                ShakeIfClose(inst)
                if inst.persists then
                    inst.persists = false
                    inst.components.lootdropper:DropLoot(inst:GetPosition())
                end
            end),
            TimeEvent(5, ErodeAway),
        },

        onexit = function(inst)
            
            inst:RemoveTag("NOCLICK")
        end,
    },
}

CommonStates.AddFrozenStates(states,
    function(inst) 
        inst.SoundEmitter:KillSound("flying")
    end,
    function(inst) 
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/fly", "flying")
    end
)

return StateGraph("ttk_dragonfly", states, events, "idle", actionhandlers)
