-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require("stategraphs/commonstates")
local actionhandlers =
{
}
local function swoopcollision(inst)
    inst.Physics:ClearCollisionMask()
end
local function resetcollision(inst)
    inst.Physics:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.FLYERS)
end
local function spawnfire(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    for k = 90,-90,-180 do
        local facing_angle = (inst.Transform:GetRotation() + k) * DEGREES
        local fx = SpawnAt("ttk_boss_jfsn_fire",Vector3(x + 1.5* math.cos(facing_angle), y, z - 1.5 * math.sin(facing_angle)))
        fx.owner = inst
    end
end
local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttacked(),
    EventHandler("death", function(inst, data)
        if TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition()) or inst:GetCurrentPlatform() or not inst:IsOnOcean() then
            inst.sg:GoToState("death", data)
        else
            inst.sg:GoToState("death_ocean", data)
        end
    end),
    EventHandler("doattack", function(inst, data)
        if inst.components.health ~= nil and not inst.components.health:IsDead()
            and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("hit")) then
            inst.sg:GoToState("attack")
        end
    end),
    EventHandler("spell", function(inst,data)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and data and data.target then
            if inst.skillmode == 1 then
                inst.sg:GoToState("swoop_pre", data.target)
            elseif inst.skillmode == 2 then
                if inst.skillcount == 2 then
                    inst.sg:GoToState("swoop_pre", data.target)
                elseif inst.skillcount == 1 then
                    inst.sg:GoToState("zhaohuan", data.target)
                else
                    inst.sg:GoToState("yushi", data.target)
                end
            else
                if inst.skillcount == 1 then
                    inst.sg:GoToState("zhaohuan", data.target)
                elseif inst.skillcount == 2 then
                    inst.sg:GoToState("swoop_pre", data.target)
                else
                    inst.sg:GoToState("yushi", data.target)
                end
            end
        end
    end),
}
local function go_to_idle(inst)
    inst.sg:GoToState("idle")
end
local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
                if pushanim then
                    if type(pushanim) == "string" then
                        inst.AnimState:PlayAnimation(pushanim)
                    end
                    inst.AnimState:PushAnimation("idle_loop")
                else
                    inst.AnimState:PlayAnimation("idle_loop")
                end
        end,
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.mem.ate_all_the_fish then
                    inst.sg.mem.ate_all_the_fish = nil
                    inst.sg:GoToState("depart")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    State{
        name = "gohome",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst:ClearBufferedAction()
            inst.components.knownlocations:RememberLocation("home", nil)
        end,
        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_jfsnsound/xd_jfsnsound/jiao") end),
        },
        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },
    State{
        name = "taunt",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            if inst.bufferedaction and inst.bufferedaction.action == ACTIONS.GOHOME then
                inst:PerformBufferedAction()
            end
        end,
        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_jfsnsound/xd_jfsnsound/jiao") end),
        },
        events =
        {
            EventHandler("animover", go_to_idle),
        },
    },
    State{
        name = "death_ocean",
        tags = { "busy" },
        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("death_ocean")
            inst.AnimState:PushAnimation("death_ocean_idle")
            RemovePhysicsColliders(inst)
        end,
        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/death") end),
            TimeEvent(33 * FRAMES, function(inst)
            end),
            TimeEvent(34 * FRAMES, function(inst)
            end),
            TimeEvent(35 * FRAMES, function(inst)
            end),
            TimeEvent(36 * FRAMES, function(inst)
            end),
            TimeEvent(38 * FRAMES, function(inst)
            end),
            TimeEvent(39 * FRAMES, function(inst)
            end),
            TimeEvent(42 * FRAMES, function(inst)
                inst.components.lootdropper:DropLoot(inst:GetPosition())
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/boss")
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
            inst:DoCast()
            swoopcollision(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("swoop_loop", true)
            inst.Physics:SetMotorVelOverride(15,0,0)
            inst.sg:SetTimeout(20/15)
            inst.sg.statemem.collisiontime = 0
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
            resetcollision(inst)
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
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "yushi",
        tags = {"busy"},
        onenter = function(inst,target)
            inst.Physics:Stop()
            inst.sg.statemem.target = target
            inst.AnimState:PlayAnimation("despawn")
        end,
        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),
            TimeEvent(1.7, function(inst)
                inst:DoCast()
                local pos = inst:GetPosition()
                if inst.sg.statemem.target and inst.sg.statemem.target:IsValid() and inst:IsNear(inst.sg.statemem.target,20) then
                    pos = inst.sg.statemem.target:GetPosition()
                    local fx = SpawnAt("ttk_boss_jfsnmeteor",pos)
                    fx.owner = inst
                end
                inst.sg.statemem.pos = pos
                inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap")
            end),
            TimeEvent(3.06, function(inst)
                if inst.sg.statemem.pos then
                    if inst.Physics ~= nil then
                        inst.Physics:Teleport(inst.sg.statemem.pos.x, 0, inst.sg.statemem.pos.z)
                    elseif inst.Transform ~= nil then
                        inst.Transform:SetPosition(inst.sg.statemem.pos.x, 0, inst.sg.statemem.pos.z)
                    end
                end
                inst.DynamicShadow:Enable(true)
                inst.AnimState:PlayAnimation("eatfish")
            end),
            TimeEvent(3.66, function(inst)
                inst.SoundEmitter:PlaySound("xd_jfsnsound/xd_jfsnsound/jiao")
            end)
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("eatfish") then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,
    },
    State{
        name = "zhaohuan",
        tags = { "busy" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,
        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_jfsnsound/xd_jfsnsound/jiao") end),
            TimeEvent(0.7, function(inst) inst:ZhaoHuan() end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.skillmode == 3 then
                    local x,y,z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x,y,z,30,{"_health","ttk_boss_jfsnpet"},{ "FX", "NOCLICK", "DECOR", "INLIMBO"})
                    for k,v in pairs(ents) do
                        if v and v:IsValid() and not v.components.health:IsDead() then
                            v:QiangHua()
                        end
                    end
                end
                go_to_idle(inst)
            end)
        },
    },
    State{
        name = "shengtian",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.health:SetInvincible(true)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("despawn")
            inst:AddTag("notarget")
        end,
        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
            TimeEvent(1.7, function(inst)
                local pos = inst.components.knownlocations:GetLocation("spawnpoint")
                if pos then
                    if inst.Physics ~= nil then
                        inst.Physics:Teleport(pos.x, 0, pos.z)
                    elseif inst.Transform ~= nil then
                        inst.Transform:SetPosition(pos.x, 0, pos.z)
                    end
                end
                inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap")
            end),
            TimeEvent(1.7+ 1.36, function(inst)
                inst.DynamicShadow:Enable(true)
                inst.AnimState:PlayAnimation("spawn")
            end),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("spawn") then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            inst:RemoveTag("notarget")
            inst.components.health:SetInvincible(false)
        end,
    },
}
CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
    },
    walktimeline =
    {
        TimeEvent(37*FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
    },
    endtimeline =
    {
    },
})
CommonStates.AddCombatStates(states,
{
    hittimeline =
    {
        TimeEvent(0 * FRAMES, function(inst)
        end),
    },
    attacktimeline =
    {
        TimeEvent(0 * FRAMES, function(inst)
            inst.sg:AddStateTag("longattack")
        end),
        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/punchimpact")
        end),
        TimeEvent(15 * FRAMES, function(inst)
            if  inst.attack_count == 2 then
                local attackfx = SpawnPrefab("attackfire_fx")
                attackfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                attackfx.Transform:SetRotation(inst.Transform:GetRotation())
            end
        end),
        TimeEvent(29 * FRAMES, function(inst)
            inst.attack_count = inst.attack_count %3+1
            if  inst.attack_count == 3 then
                inst.components.combat:EnableAreaDamage(true)
            else
                inst.components.combat:EnableAreaDamage(false)
            end
            inst.components.combat:DoAttack(inst.sg.statemem.target)
        end),
    },
    deathtimeline =
    {
        TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("saltydog/creatures/boss/malbatross/flap") end),
        TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("xd_jfsnsound/xd_jfsnsound/jiao") end),
        TimeEvent(34 * FRAMES, function(inst)
        end),
        TimeEvent(36 * FRAMES, function(inst)
        end),
        TimeEvent(39 * FRAMES, function(inst)
            end),
        TimeEvent(44 * FRAMES, function(inst) ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 2, inst, 40) end),
		TimeEvent(44 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound") end),
    },
})
local function land_without_floater(creature)
    creature:RemoveTag("flying")
    if creature.Physics ~= nil then
        creature.Physics:CollidesWith(COLLISION.LIMITS)
        creature.Physics:ClearCollidesWith(COLLISION.FLYERS)
    end
end
local function raise_without_floater(creature)
    creature:AddTag("flying")
    if creature.Physics ~= nil then
        creature.Physics:ClearCollidesWith(COLLISION.LIMITS)
        creature.Physics:CollidesWith(COLLISION.FLYERS)
    end
end
CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(1 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_boss") end),
        TimeEvent(35 * FRAMES, function(inst)
            land_without_floater(inst)
            if not inst:IsOnPassablePoint() then
                inst.AnimState:PlayAnimation("sleep_ocean_pre")
				inst.AnimState:SetFrame(36)
            end
        end),
    },
    waketimeline =
    {
        TimeEvent(44 * FRAMES, raise_without_floater),
    },
},
{
    onsleeping = function(inst)
        land_without_floater(inst)
        if not inst:IsOnPassablePoint() then
            inst.AnimState:PlayAnimation("sleep_ocean_loop")
        end
    end,
    onexitsleeping = raise_without_floater,
    onwake = function(inst)
        land_without_floater(inst)
        if not inst:IsOnPassablePoint() then
            inst.AnimState:PlayAnimation("sleep_ocean_pst")
        end
    end,
    onexitwake = raise_without_floater,
})
return StateGraph("ttk_jfsn", states, events, "idle", actionhandlers)
