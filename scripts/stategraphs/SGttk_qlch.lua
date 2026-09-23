-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
require("stategraphs/commonstates")
local function DoChainSound(inst, volume)
    inst:DoChainSound(volume)
end
local function DoChainIdleSound(inst, volume)
    inst:DoChainIdleSound(volume)
end
local function DoBellSound(inst, volume)
end
local function DoBellIdleSound(inst, volume)
end
local function DoFootstep(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/footstep", nil, volume)
    PlayFootstep(inst, volume)
end
local function DoFootstepRun(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/footstep_run", nil, volume)
    PlayFootstep(inst, volume)
end
local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleepEx(),
    CommonHandlers.OnWakeEx(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst, data)
    end),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) and inst.skillmode ~= 3 then
            inst.sg:GoToState("attack", data ~= nil and data.target or nil)
        end
    end),
    EventHandler("spell1", function(inst,data)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and data and data.target then
            inst.sg:GoToState("spell1_pre", data.target)
        end
    end),
    EventHandler("spell2", function(inst,target)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("spell2_pre", target)
        end
    end),
    EventHandler("transition", function(inst,data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("spell1_pre")
        end
    end),
}
local function getcurrentpets(inst,skillnum)
    local pets = {}
    local Soldiers = inst.components.commander:GetAllSoldiers()
    for k,v in pairs(Soldiers) do
        if v.skillnum == 2 and skillnum == 3 then
            return v
        elseif v.skillnum == 1 and skillnum ~= 3 then
            return v
        else
            table.insert(pets,v)
        end
    end
    return  pets[1]
end
local states =
{
    State{
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            if inst.sg.mem.wantstocast then
                local targets = inst:FindCastTargets()
                if targets ~= nil then
                    inst.sg:GoToState("magic_pre", targets)
                    return
                end
                inst.sg.mem.wantstocast = nil
            end
            inst.sg.mem.wantstounshackle = nil
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop")
        end,
        timeline =
        {
            TimeEvent(10 * FRAMES, DoBellIdleSound),
            TimeEvent(12 * FRAMES, DoChainIdleSound),
            TimeEvent(20 * FRAMES, function(inst)
                DoBellIdleSound(inst, .4)
            end),
            TimeEvent(23 * FRAMES, function(inst)
                DoChainIdleSound(inst, .4)
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
        name = "spell1_pre",
        tags = { "attack", "busy", "casting" },
        onenter = function(inst, targets)
            if inst.spawnfs then
                inst.components.health:SetInvincible(true)
            end
            if inst.skillmode == 3  then
                local pet = getcurrentpets(inst,inst.skillcount)
                if pet  then
                    pet:PushEvent("spell2", targets)
                end
            end
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk_magic_pre")
            if targets and targets.Transform then
                inst:ForceFacePoint(targets.Transform:GetWorldPosition())
            end
            inst.sg.statemem.targets = targets
            inst.sg.mem.wantstocast = nil
            inst.sg.statemem.fx = SpawnPrefab("ttk_boss_qlch_charge")
            inst.sg.statemem.fx.entity:SetParent(inst.entity)
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "swap_antler_red", 0, 0, 0)
        end,
        timeline =
        {
            TimeEvent(0, DoChainIdleSound),
            TimeEvent(FRAMES, DoBellIdleSound),
            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/huff")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                DoChainSound(inst)
                DoBellSound(inst)
            end),
            TimeEvent(22 * FRAMES, DoBellSound),
            TimeEvent(23 * FRAMES, DoChainSound),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.magic = true
                    inst.sg:GoToState("spell1_pst", { targets = inst.sg.statemem.targets,fx = inst.sg.statemem.fx })
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.magic then
                inst.components.health:SetInvincible(false)
                inst.sg.statemem.fx:KillFX()
            end
        end,
    },
    State{
        name = "spell2_pre",
        tags = { "attack", "busy", "casting" },
        onenter = function(inst, targets)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk_magic_pre")
            if targets and targets.Transform then
                inst:ForceFacePoint(targets.Transform:GetWorldPosition())
            end
            inst.sg.statemem.targets = targets
            inst.sg.mem.wantstocast = nil
            inst.sg.statemem.fx = SpawnPrefab("ttk_boss_qlch_charge")
            inst.sg.statemem.fx.entity:SetParent(inst.entity)
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "swap_antler_red", 0, 0, 0)
        end,
        timeline =
        {
            TimeEvent(0, DoChainIdleSound),
            TimeEvent(FRAMES, DoBellIdleSound),
            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/huff")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                DoChainSound(inst)
                DoBellSound(inst)
            end),
            TimeEvent(22 * FRAMES, DoBellSound),
            TimeEvent(23 * FRAMES, DoChainSound),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.magic = true
                    inst.sg:GoToState("spell2_pst", { targets = inst.sg.statemem.targets,fx = inst.sg.statemem.fx })
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.magic then
                if inst.sg.statemem.fx ~= nil then
                    inst.sg.statemem.fx:KillFX()
                end
            end
        end,
    },
    State{
        name = "spell1_pst",
        tags = { "attack", "busy", "casting" },
        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.fx = data.fx
                inst.sg.statemem.targets = data.targets
            end
            inst.AnimState:PlayAnimation("atk_magic_pst")
        end,
        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/grrr")
            end),
            TimeEvent(5 * FRAMES, DoBellSound),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.targets and inst.sg.statemem.targets.IsValid and inst.sg.statemem.targets:IsValid() then
                    inst:ForceFacePoint(inst.sg.statemem.targets.Transform:GetWorldPosition())
                end
            end),
            TimeEvent(11 * FRAMES, DoChainSound),
            TimeEvent(13 * FRAMES, function(inst)
                if inst.skillnum == 4 then
                    inst.ci_targets = {}
                    local x,y,z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x,y,z, 14, {"player","_health","_combat"},{"playerghost"})
                    if #ents > 0 then
                        for i_,v in ipairs(ents) do
                            if not (v.components.health and v.components.health:IsDead()) then
                                table.insert(inst.ci_targets,{pt = v:GetPosition(),player = v})
                            end
                         end
                    end
                end
            end),
            TimeEvent(20 * FRAMES, DoBellSound),
            TimeEvent(21 * FRAMES, DoFootstepRun),
            TimeEvent(22 * FRAMES, DoChainSound),
            TimeEvent(25 * FRAMES, function(inst)
                local success
                if inst.spawnfs then
                    inst:SummonSpecter()
                    success = true
                    inst.components.health:SetInvincible(false)
                else
                    local spells = inst:DoCast(inst.sg.statemem.targets,1)
                    if spells ~= nil then
                        success = true
                    end
                end
                if inst.sg.statemem.fx ~= nil then
                    inst.sg.statemem.fx:KillFX(success and "blast" or nil)
                    inst.sg.statemem.fx = nil
                end
                inst.sg:RemoveStateTag("casting")
            end),
            TimeEvent(26 * FRAMES, function (inst)
                DoChainSound(inst)
                DoBellIdleSound(inst)
            end),
            TimeEvent(35 * FRAMES, DoBellSound),
            TimeEvent(36 * FRAMES, DoFootstep),
            TimeEvent(39 * FRAMES, DoChainSound),
            TimeEvent(41 * FRAMES, DoBellSound),
            TimeEvent(45 * FRAMES, DoFootstep),
            TimeEvent(46 * FRAMES, DoBellIdleSound),
            TimeEvent(47 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            if inst.sg.statemem.fx ~= nil then
                inst.sg.statemem.fx:KillFX()
            end
        end,
    },
    State{
        name = "spell2_pst",
        tags = { "attack", "busy", "casting" },
        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.fx = data.fx
                inst.sg.statemem.targets = data.targets
            end
            inst.AnimState:PlayAnimation("atk_magic_pst")
        end,
        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/grrr")
            end),
            TimeEvent(5 * FRAMES, DoBellSound),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.targets and inst.sg.statemem.targets.IsValid and inst.sg.statemem.targets:IsValid() then
                    inst:ForceFacePoint(inst.sg.statemem.targets.Transform:GetWorldPosition())
                end
            end),
            TimeEvent(11 * FRAMES, DoChainSound),
            TimeEvent(13 * FRAMES, function(inst)
                if inst.skillnum == 1 then
                    inst.ci_targets = {}
                    local x,y,z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x,y,z, 14, {"player","_health","_combat"},{"playerghost"})
                    if #ents > 0 then
                        for i_,v in ipairs(ents) do
                            if not (v.components.health and v.components.health:IsDead()) then
                                table.insert(inst.ci_targets,{pt = v:GetPosition(),player = v})
                            end
                         end
                    end
                end
            end),
            TimeEvent(20 * FRAMES, DoBellSound),
            TimeEvent(21 * FRAMES, DoFootstepRun),
            TimeEvent(22 * FRAMES, DoChainSound),
            TimeEvent(25 * FRAMES, function(inst)
                local success
                if inst:DoCastFS(inst.ci_targets) then
                    success = true
                end
                if inst.sg.statemem.fx ~= nil then
                    inst.sg.statemem.fx:KillFX(success and "blast" or nil)
                    inst.sg.statemem.fx = nil
                end
                inst.sg:RemoveStateTag("casting")
            end),
            TimeEvent(26 * FRAMES, function (inst)
                DoChainSound(inst)
                DoBellIdleSound(inst)
            end),
            TimeEvent(35 * FRAMES, DoBellSound),
            TimeEvent(36 * FRAMES, DoFootstep),
            TimeEvent(39 * FRAMES, DoChainSound),
            TimeEvent(41 * FRAMES, DoBellSound),
            TimeEvent(45 * FRAMES, DoFootstep),
            TimeEvent(46 * FRAMES, DoBellIdleSound),
            TimeEvent(47 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
        onexit = function(inst)
            if inst.sg.statemem.fx ~= nil then
                inst.sg.statemem.fx:KillFX()
            end
        end,
    },
    State{
        name = "magic_pre",
        tags = { "attack", "busy", "casting" },
        onenter = function(inst, targets)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("atk_magic_pre")
            inst.sg.statemem.targets = targets
            inst.sg.mem.wantstocast = nil
            inst.sg.statemem.fx = SpawnPrefab(inst.gem == "red" and "deer_fire_charge" or "deer_ice_charge")
            inst.sg.statemem.fx.entity:SetParent(inst.entity)
            inst.sg.statemem.fx.entity:AddFollower()
            inst.sg.statemem.fx.Follower:FollowSymbol(inst.GUID, "swap_antler_red", 0, 0, 0)
        end,
        timeline =
        {
            TimeEvent(0, DoChainIdleSound),
            TimeEvent(FRAMES, DoBellIdleSound),
            TimeEvent(3 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/huff")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                DoChainSound(inst)
                DoBellSound(inst)
            end),
            TimeEvent(19.5 * FRAMES, function(inst)
                if inst.gem ~= "red" then
                    inst.sg.statemem.spells = inst:DoCast(inst.sg.statemem.targets)
                    inst.sg.statemem.targets = nil
                end
            end),
            TimeEvent(22 * FRAMES, DoBellSound),
            TimeEvent(23 * FRAMES, DoChainSound),
        },
        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.magic = true
                    if inst.sg.statemem.spells == nil and inst.sg.statemem.targets == nil then
                        inst.sg:GoToState("magic_pst", { fx = inst.sg.statemem.fx })
                    else
                        inst.sg:GoToState("magic_loop", { fx = inst.sg.statemem.fx, spells = inst.sg.statemem.spells, targets = inst.sg.statemem.targets })
                    end
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.magic then
                inst.sg.statemem.fx:KillFX()
            end
        end,
    },
    State{
        name = "magic_loop",
        tags = { "attack", "busy", "casting" },
        onenter = function(inst, data)
            if inst.gem == "red" then
                inst.sg.statemem.magic = true
                inst.sg:GoToState("magic_pst", data)
            else
                data.looped = (data.looped or 0) + 1
                inst.sg.statemem.data = data
                if not inst.AnimState:IsCurrentAnimation("atk_magic_loop") then
                    inst.AnimState:PlayAnimation("atk_magic_loop", true)
                end
                inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            end
        end,
        timeline =
        {
            TimeEvent(0, DoChainIdleSound),
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/scratch")
            end),
            TimeEvent(14 * FRAMES, DoBellIdleSound),
        },
        ontimeout = function(inst)
            inst.sg.statemem.magic = true
            inst.sg:GoToState(inst.sg.statemem.data.looped < 3 and "magic_loop" or "magic_pst", inst.sg.statemem.data)
        end,
        onexit = function(inst)
            if not inst.sg.statemem.magic and inst.sg.statemem.data ~= nil and inst.sg.statemem.data.fx ~= nil then
                inst.sg.statemem.data.fx:KillFX()
            end
        end,
    },
    State{
        name = "magic_pst",
        tags = { "attack", "busy", "casting" },
        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.fx = data.fx
                inst.sg.statemem.spells = data.spells
                inst.sg.statemem.targets = data.targets
            end
            inst.AnimState:PlayAnimation("atk_magic_pst")
        end,
        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/grrr")
            end),
            TimeEvent(5 * FRAMES, DoBellSound),
            TimeEvent(11 * FRAMES, DoChainSound),
            TimeEvent(20 * FRAMES, DoBellSound),
            TimeEvent(21 * FRAMES, DoFootstepRun),
            TimeEvent(22 * FRAMES, DoChainSound),
            TimeEvent(25 * FRAMES, function(inst)
                local success = false
                if inst.sg.statemem.spells ~= nil then
                    for i, v in ipairs(inst.sg.statemem.spells) do
                        if v:IsValid() then
                            success = true
                            v:TriggerFX()
                        end
                    end
                elseif inst.gem == "red" then
                    local spells = inst:DoCast(inst.sg.statemem.targets)
                    if spells ~= nil then
                        success = true
                        for i, v in pairs(spells) do
                            v:TriggerFX()
                        end
                    end
                end
                if inst.sg.statemem.fx ~= nil then
                    inst.sg.statemem.fx:KillFX(success and "blast" or nil)
                    inst.sg.statemem.fx = nil
                end
                inst.sg:RemoveStateTag("casting")
            end),
            TimeEvent(26 * FRAMES, function (inst)
                DoChainSound(inst)
                DoBellIdleSound(inst)
            end),
            TimeEvent(35 * FRAMES, DoBellSound),
            TimeEvent(36 * FRAMES, DoFootstep),
            TimeEvent(39 * FRAMES, DoChainSound),
            TimeEvent(41 * FRAMES, DoBellSound),
            TimeEvent(45 * FRAMES, DoFootstep),
            TimeEvent(46 * FRAMES, DoBellIdleSound),
            TimeEvent(47 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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
        onexit = function(inst)
            if inst.sg.statemem.fx ~= nil then
                inst.sg.statemem.fx:KillFX()
            end
        end,
    },
}
CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            DoChainIdleSound(inst, .5)
            DoBellIdleSound(inst, .5)
        end),
    },
    walktimeline =
    {
        TimeEvent(0, function(inst)
            DoFootstep(inst)
            DoChainIdleSound(inst)
            DoBellIdleSound(inst)
        end),
        TimeEvent(6 * FRAMES, DoBellIdleSound),
        TimeEvent(7 * FRAMES, DoFootstep),
        TimeEvent(8 * FRAMES, DoChainIdleSound),
        TimeEvent(9 * FRAMES, DoFootstep),
        TimeEvent(10 * FRAMES, DoChainIdleSound),
        TimeEvent(12 * FRAMES, DoBellIdleSound),
        TimeEvent(17 * FRAMES, function(inst)
            DoFootstep(inst)
            DoBellIdleSound(inst)
        end),
        TimeEvent(18 * FRAMES, DoChainIdleSound),
    },
    endtimeline =
    {
        TimeEvent(3 * FRAMES, function(inst)
            DoFootstep(inst, .5)
            DoBellIdleSound(inst, .5)
            DoChainIdleSound(inst, .5)
        end),
    },
})
CommonStates.AddCombatStates(states,
{
    attacktimeline =
    {
        TimeEvent(0, DoBellSound),
        TimeEvent(FRAMES, function(inst)
            DoChainSound(inst, .6)
        end),
        TimeEvent(3 * FRAMES, function(inst)
        end),
        TimeEvent(5 * FRAMES, function(inst)
        end),
        TimeEvent(11 * FRAMES, DoBellSound),
        TimeEvent(12 * FRAMES, function(inst)
            inst.components.combat:DoAttack(inst.sg.statemem.target)
            DoChainSound(inst)
        end),
        TimeEvent(23 * FRAMES, DoFootstep),
        TimeEvent(25 * FRAMES, DoFootstepRun),
        TimeEvent(26 * FRAMES, function(inst)
            DoBellSound(inst)
            DoChainSound(inst)
        end),
        TimeEvent(28 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end)
    },
    hittimeline =
    {
        TimeEvent(0, DoChainSound),
        TimeEvent(FRAMES, DoBellSound),
        TimeEvent(12 * FRAMES, function(inst)
            if inst.gem == nil then
                DoFootstep(inst)
            end
        end),
        TimeEvent(13 * FRAMES, function(inst)
            if inst.gem == nil then
                inst.sg:RemoveStateTag("busy")
            end
        end),
        TimeEvent(14 * FRAMES, DoChainSound),
        TimeEvent(18 * FRAMES, DoBellSound),
        TimeEvent(22 * FRAMES, function(inst)
            if inst.gem ~= nil then
                inst.sg:RemoveStateTag("busy")
            end
        end),
    },
    deathtimeline =
    {
        TimeEvent(0, DoChainIdleSound),
        TimeEvent(5 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bodyfall_2")
            DoBellIdleSound(inst)
        end),
        TimeEvent(15 * FRAMES, DoChainSound),
        TimeEvent(20 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/hit")
        end),
        TimeEvent(23 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bodyfall_2")
            DoBellSound(inst)
        end),
        TimeEvent(24 * FRAMES, DoChainSound),
    },
},
{
    hit = function(inst)
        return inst.gem ~= nil and "hit_2" or "hit"
    end,
})
CommonStates.AddFrozenStates(states)
CommonStates.AddSleepExStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            DoChainSound(inst)
            DoBellSound(inst, .3)
        end),
        TimeEvent(9 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bodyfall")
            DoBellSound(inst, .5)
        end),
        TimeEvent(16 * FRAMES, DoChainSound),
    },
    sleeptimeline =
    {
        TimeEvent(9 * FRAMES, function(inst)
            DoBellSound(inst, .2)
        end),
        TimeEvent(31 * FRAMES, function(inst)
            DoBellIdleSound(inst, .2)
        end),
    },
    waketimeline =
    {
        TimeEvent(2 * FRAMES, DoBellIdleSound),
        TimeEvent(22 * FRAMES, DoChainSound),
        TimeEvent(24 * FRAMES, DoBellSound),
    },
})
return StateGraph("ttk_qlch", states, events, "idle")
