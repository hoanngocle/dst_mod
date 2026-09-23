require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, 
        function(inst, action)
            return "eat"
        end),

    ActionHandler(ACTIONS.GOHOME, "eat"),
    ActionHandler(ACTIONS.INVESTIGATE, "investigate"),
}

local events =
{
    CommonHandlers.OnHop(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnSink(),
    CommonHandlers.OnFallInVoid(),

    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() then
            if inst:HasTag("spider_warrior") or inst:HasTag("spider_spitter") or inst:HasTag("spider_moon") then
                if not inst.sg:HasAnyStateTag("attack", "moving") then 
                    inst.sg:GoToState("hit") 
                end
            elseif not inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("hit_stunlock")  
            end
        end
    end),
    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("attack",data.target)
        end
    end),

    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if not inst.sg:HasStateTag("attack") and is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg:GoToState("premoving")
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),

    EventHandler("skill1", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("skill1",data.target)
        end
    end),

    EventHandler("skill2", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("skill2",data.target)
        end
    end),

    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("entershield", function(inst) inst.sg:GoToState("shield") end),
    EventHandler("exitshield", function(inst) inst.sg:GoToState("shield_end") end),
}

local function SoundPath(inst, event)
    return inst:SoundPath(event)
end

local function SpawnEffect(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("ttk_spider_puff_back").Transform:SetPosition(x, y - .1, z)
    SpawnPrefab("ttk_spider_puff_front").Transform:SetPosition(x, y, z)
end

local function tete(inst,target)
    local x, y, z = target.Transform:GetWorldPosition()
    local rot0 = target.Transform:GetRotation() * DEGREES
    local range = target:GetPhysicsRadius(0) + 2
    inst.Physics:Teleport(x - range * math.cos(rot0), 0, z + range * math.sin(rot0))
    inst:ForceFacePoint(x, y, z)
end

local states =
{
    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(SoundPath(inst, "die"))
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    },

    State{
        name = "premoving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PushAnimation("walk_loop")
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "walk_spider")) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("moving") end),
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        ontimeout = function(inst)
            inst.sg:GoToState("taunt")
        end,

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            local animname = "idle"
            if math.random() < 0.3 then
                inst.sg:SetTimeout(math.random()*2 + 2)
            end
            if start_anim then
                inst.AnimState:PlayAnimation(start_anim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
        end,
    },

    State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst, forced)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            inst.sg.statemem.forced = forced
            inst.SoundEmitter:PlaySound(SoundPath(inst, "eat"), "eating")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                local state = (inst:PerformBufferedAction() or inst.sg.statemem.forced) and "eat_loop" or "idle"
                if state == "idle" then
                    inst.SoundEmitter:KillSound("eating")
                end
                inst.sg:GoToState(state)
            end),
        },
    },

    State{
        name = "eat_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_loop", true)
            inst.sg:SetTimeout(1+math.random()*1)
        end,

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("eating")
            inst.sg:GoToState("idle", "eat_pst")
        end,
    },

    State{
        name = "born",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(SoundPath(inst, "scream"))
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "investigate",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(SoundPath(inst, "scream"))
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "Attack")) end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "attack_grunt")) end),
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "skill1",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target
        end,
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "Attack")) end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "attack_grunt")) end),
            TimeEvent(25*FRAMES, function(inst) 
                local target = inst.sg.statemem.target
                if target and target:IsValid() and not 
                    (target.components.health and target.components.health:IsDead()) then
                    local x,y,z = inst.Transform:GetWorldPosition()
                    local proj = SpawnPrefab("ttk_spider_pro")
                    proj.Transform:SetPosition(x,y+0.5,z)
                    proj.components.projectile:Throw(inst, target, inst)
                end
            end)
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        onexit = function(inst)
            inst.components.timer:StartTimer("skill1", 5)
        end,
    },

    State{
        name = "skill2",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target
        end,
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "Attack")) end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "attack_grunt")) end),
            TimeEvent(12*FRAMES, function(inst) 
                if  inst.sg.statemem.target and  inst.sg.statemem.target:IsValid() then
                    SpawnEffect(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
                end
            end),
            TimeEvent(19*FRAMES, function(inst) 
                if  inst.sg.statemem.target and  inst.sg.statemem.target:IsValid() then
                    tete(inst,inst.sg.statemem.target)
                    SpawnEffect(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
                end
            end),
            TimeEvent(25*FRAMES, function(inst) 
                inst:DoDamage(inst.sg.statemem.target,52.5)
            end),
        },
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        onexit = function(inst)
            inst.components.timer:StartTimer("skill2", 5)
        end,
    },

    State{
        name = "hit",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "hit_stunlock",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(SoundPath(inst, "hit_response"))
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "shield",
        tags = {"busy", "shield"},

        onenter = function(inst)
            
            inst.components.health:SetAbsorptionAmount(TUNING.SPIDER_HIDER_SHELL_ABSORB)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hide")
            inst.AnimState:PushAnimation("hide_loop")
        end,

        onexit = function(inst)
            inst.components.health:SetAbsorptionAmount(0)
        end,
    },

    State{
        name = "shield_end",
        tags = {"busy", "shield"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("unhide")
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "dropper_enter",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("enter")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/descend")
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },
}

CommonStates.AddSleepStates(states,
{
    starttimeline = {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "fallAsleep")) end ),
    },
    sleeptimeline =
    {
        TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "sleeping")) end ),
    },
    waketimeline = {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(SoundPath(inst, "wakeUp")) end ),
    },
})

CommonStates.AddFrozenStates(states)
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump", pst = "boat_jump_pst"})
CommonStates.AddSinkAndWashAshoreStates(states)
CommonStates.AddVoidFallStates(states)

return StateGraph("ttk_spider", states, events, "idle", actionhandlers)
