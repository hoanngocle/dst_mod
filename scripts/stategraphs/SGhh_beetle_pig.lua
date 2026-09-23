local HH_UTILS = require("utils/hh_utils")
require("stategraphs/commonstates")
local BUFF_NAME = {
    "hh_beetle_pig_speed", "hh_beetle_pig_speed", "hh_beetle_pig_speed",
}
local CONTROL_CD = 45
local STRONG_CD = 27
local SWIPE_ARC = 240
local SWIPE_OFFSET = 2
local SWIPE_RADIUS = 3.5
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local function _AOEAttack(inst, dig, dist, radius, arc, heavymult, mult, hh_forcelanded, targets)
    inst["components"]["combat"]["ignorehitrange"] = true
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local arcx, cos_theta, sin_theta
    if dist ~= 0 or arc then
        local theta = inst["Transform"]:GetRotation() * DEGREES
        cos_theta = math["cos"](theta)
        sin_theta = math["sin"](theta)
        if dist ~= 0 then
            x = x + dist * cos_theta
            z = z - dist * sin_theta
        end
        if arc then
            arcx = x + math["cos"](arc / 2 * DEGREES) * radius
        end
    end
    for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + AOE_RANGE_PADDING, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)) do
        if v ~= inst and not (targets and targets[v]) and
                v:IsValid() and not v:IsInLimbo()
                and HH_UTILS:NotIsDead(inst)
                and HH_UTILS:CanHitTarget(inst, v)
                and HH_UTILS:NotIsDead(v)
        then
            local range = radius + v:GetPhysicsRadius(0)
            local x1, y1, z1 = v["Transform"]:GetWorldPosition()
            local dx = x1 - x
            local dz = z1 - z
            if dx * dx + dz * dz < range * range
                    and (arcx == nil or x + cos_theta * dx - sin_theta * dz > arcx)
                    and inst["components"]["combat"]:CanTarget(v)
            then
                --秒杀不会动的生物
                if dig and v["components"]["locomotor"] == nil then
                    v["components"]["health"]:Kill()
                else
                    inst["components"]["combat"]:DoAttack(v)
                    if mult then
                        --是否击飞
                        local hh_strengthmult = (v["components"]["inventory"] and v["components"]["inventory"]:ArmorHasTag("heavyarmor") or v:HasTag("heavybody")) and heavymult or mult
                        v:PushEvent("knockback", {
                            ["knocker"] = inst,
                            ["radius"] = radius + dist,
                            ["strengthmult"] = hh_strengthmult,
                            ["forcelanded"] = hh_forcelanded,
                        })
                    end
                end
                if targets then
                    targets[v] = true
                end
            end
        end
    end
    inst["components"]["combat"]["ignorehitrange"] = false
end
--aoe伤害
local function DoArcAttack(inst, dist, radius, arc, heavymult, mult, forcelanded, targets)
    _AOEAttack(inst, false, dist, radius, arc, heavymult, mult, forcelanded, targets)
end
local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
    _AOEAttack(inst, false, dist, radius, nil, heavymult, mult, forcelanded, targets)
end

--目标在前方
local function IsTargetInFront(inst, target, arc)
    if not (target and target:IsValid()) then
        return false
    end
    local rot = inst["Transform"]:GetRotation()
    local rot1 = inst:GetAngleToPoint(target["Transform"]:GetWorldPosition())
    return DiffAngle(rot, rot1) < (arc or 180) / 2
end

local COLLAPSIBLE_WORK_ACTIONS = {
    ["CHOP"] = true,
    ["DIG"] = true,
    ["HAMMER"] = true,
    ["MINE"] = true,
}
local COLLAPSIBLE_TAGS = {}
for k, v in pairs(COLLAPSIBLE_WORK_ACTIONS) do
    table["insert"](COLLAPSIBLE_TAGS, k .. "_workable")
end
local function DestroyWorkable(inst, radius)
    local x, y, z = inst["Transform"]:GetWorldPosition()
    local all_ent = TheSim:FindEntities(x, y, z, radius, nil, { "FX", "DECOR", "INLIMBO" }, COLLAPSIBLE_TAGS)
    if not all_ent or #all_ent <= 0 then
        return
    end
    for i, v in ipairs(all_ent) do
        if v and HH_UTILS:HasComponents(v, "workable") and v["components"]["workable"]:CanBeWorked() then
            v["components"]["workable"]:Destroy(inst)
        end
    end
end
----
---走路事件
---
local function eventWalkSg(inst, data)
    if not (HH_UTILS:HasComponents(inst, "locomotor") and inst["sg"]) then
        return
    end
    local inst_sg = inst["sg"]
    if inst["components"]["locomotor"]:WantsToMoveForward() then
        if inst_sg:HasStateTag("idle") then
            if data and data["dir"] then
                --转向
                inst["components"]["locomotor"]:SetMoveDir(data["dir"])
            end
            local new_sg = inst["components"]["locomotor"]:WantsToRun() and "run_start" or "walk_start"
            inst_sg:GoToState(new_sg)
        elseif inst_sg:HasStateTag("moving") then
            local should_run = inst["components"]["locomotor"]:WantsToRun()
            if should_run ~= inst_sg:HasStateTag("running") then
                inst_sg:GoToState(should_run and "run_start" or "walk_start")
            end
        end
    elseif inst_sg:HasStateTag("moving") then
        inst_sg:GoToState(inst_sg:HasStateTag("running") and "run_stop" or "walk_stop")
    end
end
----
---攻击事件
---
local function eventAttackSg(inst, data)
    local inst_sg = inst["sg"]
    local check_state = not inst_sg:HasStateTag("busy") and HH_UTILS:NotIsDead(inst)
    if not check_state then
        return false
    end
    local hh_target = data and data["target"] or inst["components"]["combat"]["target"]
    if hh_target and not hh_target:IsValid() then
        hh_target = nil
    end
    --团控期间无法攻击
    if inst_sg:HasStateTag("pig_control") then
        return true
    end
    if not inst["components"]["timer"]:TimerExists("pig_jump_cd") then
        --泰山压顶
        inst_sg:GoToState("attack_jump_pre", hh_target)
        return true
    elseif not inst["components"]["timer"]:TimerExists("pig_strong_cd") then
        --属性强化-每30秒强化一次
        inst_sg:GoToState("strong", hh_target)
        return true
    elseif not inst["components"]["timer"]:TimerExists("pig_control_cd") then
        --群体控制
        inst_sg:GoToState("pig_control", hh_target)
        return true

    elseif hh_target and inst:IsNear(hh_target, 4.5 + hh_target:GetPhysicsRadius(0)) then
        inst_sg:GoToState("attack1", hh_target)
        return true
    end
    return false
end
----
---受到攻击
---
local function eventAttackedSg(inst, data)
    --0.5概率免疫僵直
    local random_num = math["random"]()
    if random_num < 0.5 then
        return
    end
    local inst_sg = inst["sg"]
    if not inst_sg:HasStateTag("busy") or
            inst_sg:HasStateTag("caninterrupt") or
            inst_sg:HasStateTag("frozen")
    then
        --受击会加间隔
        if not CommonHandlers["HitRecoveryDelay"](inst) then
            inst_sg:GoToState("hit")
        end
    end

end
local hh_events = {
    CommonHandlers["OnDeath"](),
    --走路
    EventHandler("locomote", eventWalkSg),
    EventHandler("attacked", eventAttackedSg),
    --攻击sg
    EventHandler("doattack", eventAttackSg),

}
local hh_states = {
    --待机
    State {
        ["name"] = "idle",
        ["tags"] = { "idle", "canrotate" },

        ["onenter"] = function(inst, norotate)
            local inst_sg = inst["sg"]
            --死亡
            if not HH_UTILS:NotIsDead(inst) then
                inst_sg:GoToState("death")
                return
            end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("idle_loop", true)
        end,
        ["onexit"] = function(inst)
        end,
    },
    --死亡
    State {
        ["name"] = "death",
        ["tags"] = { "dead", "busy", "noattack" },
        ["onenter"] = function(inst)
            inst["AnimState"]:PlayAnimation("death")
            inst["Physics"]:Stop()
            RemovePhysicsColliders(inst)
            if HH_UTILS:HasComponents(inst, "lootdropper") then
                inst["components"]["lootdropper"]:DropLoot(inst:GetPosition())
            end
        end,
    },
    ---------------------------------------三连击-------------------------------------------------
    State {
        --左拳
        ["name"] = "attack1",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack1")
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
                inst["sg"]["statemem"]["target"] = target
            end
        end,
        ["timeline"] = {
            FrameEvent(1, function(inst)
                inst["components"]["combat"]:StartAttack()
            end),
            FrameEvent(4, function(inst)
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
            end),
        },

        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    if IsTargetInFront(inst, inst["sg"]["statemem"]["target"], SWIPE_ARC) then
                        inst["sg"]:GoToState("attack2", inst["sg"]["statemem"]["target"])
                    elseif inst["components"]["combat"]["target"] ~= inst["sg"]["statemem"]["target"]
                            and IsTargetInFront(inst, inst["components"]["combat"]["target"], SWIPE_ARC) then
                        inst["sg"]:GoToState("attack2", inst["components"]["combat"]["target"])
                    else
                        inst["sg"]:GoToState("attack1_pst")
                    end
                end
            end),
        },
    },
    --一段攻击结束
    State {
        ["name"] = "attack1_pst",
        ["tags"] = { "busy", "caninterrupt" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack1_pst")
        end,
        ["timeline"] = {
            FrameEvent(6, function(inst)
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },
    --右拳
    State {
        ["name"] = "attack2",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack2")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
        end,
        ["timeline"] = {
            FrameEvent(4, function(inst)
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    if IsTargetInFront(inst, inst["sg"]["statemem"]["target"], 120) then
                        inst["sg"]:GoToState("attack3", inst["sg"]["statemem"]["target"])
                    elseif inst["components"]["combat"]["target"] ~= inst["sg"]["statemem"]["target"]
                            and IsTargetInFront(inst, inst["components"]["combat"]["target"], 120) then
                        inst["sg"]:GoToState("attack3", inst["components"]["combat"]["target"])
                    else
                        inst["sg"]:GoToState("attack2_pst")
                    end
                end
            end),
        },
    },
    State {
        ["name"] = "attack2_pst",
        ["tags"] = { "busy", "caninterrupt" },
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack2_pst")
        end,
        ["timeline"] = {
            FrameEvent(5, function(inst)
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },
    --上勾拳
    State {
        ["name"] = "attack3",
        ["tags"] = { "attack", "busy", "jumping", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack3")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
            --加个小加速
            inst["Physics"]:SetMotorVelOverride(9, 0, 0)
        end,
        ["onupdate"] = function(inst)
            if inst["sg"]["statemem"]["decelspeed"] then
                if inst["sg"]["statemem"]["decelspeed"] > 1 then
                    inst["sg"]["statemem"]["decelspeed"] = inst["sg"]["statemem"]["decelspeed"] - 1
                    inst["Physics"]:SetMotorVelOverride(inst["sg"]["statemem"]["decelspeed"], 0, 0)
                else
                    inst["sg"]["statemem"]["decelspeed"] = nil
                    inst["Physics"]:ClearMotorVelOverride()
                    inst["Physics"]:Stop()
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(3, function(inst)
                inst["sg"]["statemem"]["decelspeed"] = 9
            end),
            FrameEvent(6, function(inst)
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC, nil, 1)
            end),
            FrameEvent(19, function(inst)
                inst["sg"]:AddStateTag("caninterrupt")
            end),
            FrameEvent(24, function(inst)
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    -------------------------------------------泰山压顶---------------------------------------
    State {
        ["name"] = "attack_jump_pre",
        ["tags"] = { "busy", "nosleep", "noattack", "invisible", "temp_invincible" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("bellyflop_pre")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst["sg"]["statemem"]["targetpos"] = target:GetPosition()
                inst:ForceFacePoint(inst["sg"]["statemem"]["targetpos"])
            end
        end,
        ["onupdate"] = function(inst)
            local target = inst["sg"]["statemem"]["target"]
            if target then
                if target:IsValid() then
                    local pos = inst["sg"]["statemem"]["targetpos"]
                    pos["x"], pos["y"], pos["z"] = target["Transform"]:GetWorldPosition()
                    if target["Physics"] then
                        local vx, vy, vz = target["Physics"]:GetVelocity()
                        pos["x"] = pos["x"] + vx * 0.3
                        pos["z"] = pos["z"] + vz * 0.3
                    end
                    local rot = inst["Transform"]:GetRotation()
                    local rot1 = inst:GetAngleToPoint(pos)
                    if DiffAngle(rot, rot1) < 45 then
                        inst["Transform"]:SetRotation(rot1)
                    else
                        inst["sg"]["statemem"]["target"] = nil
                    end
                else
                    inst["sg"]["statemem"]["target"] = nil
                end
            end
        end,
        ["timeline"] = {
            FrameEvent(10, PlayFootstep),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("attack_jump", inst["sg"]["statemem"]["targetpos"])
                end
            end),
        },
    },
    State {
        ["name"] = "attack_jump",
        ["tags"] = { "busy", "jumping", "nosleep" },
        ["onenter"] = function(inst, pos)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("bellyflop")
            inst["components"]["combat"]:StartAttack()

            local x, y, z = inst["Transform"]:GetWorldPosition()
            inst["components"]["timer"]:StopTimer("pig_jump_cd")
            if inst["sg"]["lasttags"] and inst["sg"]["lasttags"]["fastdig"] then
                inst["sg"]:AddStateTag("fastdig")
                inst["components"]["timer"]:StartTimer("pig_jump_cd", 7)
            else
                inst["components"]["timer"]:StartTimer("pig_jump_cd", 14)
            end
            inst["Physics"]:SetMotorVelOverride(10, 0, 0)
        end,
        ["timeline"] = {
            FrameEvent(15, function(inst)
                inst["sg"]["statemem"]["targets"] = {}
                DoAOEAttack(inst, 0, 6, nil, 1, nil)
                --摧毁建筑 防止卡位
                DestroyWorkable(inst, 6)
                inst["Physics"]:ClearMotorVelOverride()
                inst["Physics"]:Stop()
            end),
        },

        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    ---------------------------------------------------------------特殊动作强化----------------------------------------------------------------
    State {
        --捶地
        ["name"] = "strong",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("taunt")
            inst["components"]["timer"]:StopTimer("pig_strong_cd")
            inst["components"]["timer"]:StartTimer("pig_strong_cd", STRONG_CD)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
        ["timeline"] = {
            FrameEvent(15, function(inst)
                inst["Physics"]:ClearMotorVelOverride()
                inst["Physics"]:Stop()
                local random_num = math["random"](1, 3)
                if BUFF_NAME[random_num] and HH_UTILS:HasComponents(inst, "hh_monster")
                        and HH_UTILS:HasComponents(inst, "hh_buff")
                then
                    inst["components"]["hh_buff"]:AddBuff(BUFF_NAME[random_num], 10)
                end
            end),
        },

        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
        ["onexit"] = function(inst)
        end,
    },
    State {
        --敲屁股
        ["name"] = "pig_control",
        ["tags"] = { "attack", "busy", "candefeat", "pig_control", },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("fossilized_pst_r", true)
            inst["components"]["timer"]:StopTimer("pig_control_cd")
            inst["components"]["timer"]:StartTimer("pig_control_cd", CONTROL_CD)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
            inst["sg"]["statemem"]["control_time"] = 1
            --持续5秒
            inst["sg"]:SetTimeout(5)
        end,
        ["onupdate"] = function(inst, dt)
            local current_time = inst["sg"]["statemem"]["control_time"]
            if not HH_UTILS:IsHHType(current_time, "number") then
                inst["sg"]["statemem"]["control_time"] = 1
            end
            current_time = inst["sg"]["statemem"]["control_time"]
            if current_time <= 0 then
                inst["sg"]["statemem"]["control_time"] = 1
                HH_UTILS:SpawnClientStrFx(inst, "Khống chế")
                local x, y, z = inst["Transform"]:GetWorldPosition()
                local players = TheSim:FindEntities(x, y, z, 6, { "_combat", "_health" }, { "FX", "DECOR", "INLIMBO", "playerghost" }, { "player" })
                if players then
                    for i, v in ipairs(players) do
                        if HH_UTILS:IsHHType(v, "table") and HH_UTILS:HasComponents(v, "hh_player")
                                and HH_UTILS:NotIsDead(v) and v["sg"] and v["sg"]:HasState("mindcontrolled")
                                and not v["sg"]:HasStateTag("busy")
                        then
                            v["sg"]:GoToState('mindcontrolled')
                        end
                    end
                end

            end
            current_time = inst["sg"]["statemem"]["control_time"]
            inst["sg"]["statemem"]["control_time"] = current_time - dt
        end,

        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("idle")
        end,
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    ---------------------------------------------------------------受击----------------------------------------------------------------
    State {
        ["name"] = "hit",
        ["tags"] = { "hit", "busy" },
        ["onenter"] = function(inst, data)
            inst["components"]["locomotor"]:StopMoving()
            inst["AnimState"]:PlayAnimation("hit")
            --CommonHandlers["UpdateHitRecoveryDelay"](inst)
        end,
        ["timeline"] = {
            FrameEvent(11, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    --死亡
                    inst["sg"]:GoToState("death")
                    return
                elseif inst["sg"]["statemem"]["doattack"] then
                    if eventAttackSg(inst, { ["target"] = inst["sg"]["statemem"]["doattack"] }) then
                        return
                    end
                end
                inst["sg"]:RemoveStateTag("busy")
            end),
        },
        ["events"] = {
            EventHandler("doattack", function(inst, data)
                if inst["sg"]:HasStateTag("busy") then
                    inst["sg"]["statemem"]["doattack"] = data and data["target"] or nil
                    return true
                end
            end),
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },
}
--------------------------------走路------------------------------------------------
local function DoFootstep(inst, volume)
    inst["sg"]["mem"]["lastfootstep"] = GetTime()
    PlayFootstep(inst, volume)
end
CommonStates["AddWalkStates"](hh_states,
        {
            ["walktimeline"] = {
                FrameEvent(2, DoFootstep),
                FrameEvent(20, DoFootstep),
            },
        },
        {
            ["startwalk"] = "walk_pre",
            ["walk"] = "walk_loop",
            ["stopwalk"] = "walk_pst",
        }, nil, nil,
        {
            ["endonenter"] = function(inst)
                local t = GetTime()
                if (inst["sg"]["mem"]["lastfootstep"] or -math["huge"]) + 0.3 < t then
                    inst["sg"]["mem"]["lastfootstep"] = t
                    PlayFootstep(inst, 0.5)
                end
            end,
        })

CommonStates["AddRunStates"](hh_states,
        {
            ["starttimeline"] = {
            },
            ["runtimeline"] = {
                FrameEvent(2, DoFootstep),
                FrameEvent(16, DoFootstep),
            },
        },
--跑动画配置
        {
            ["startrun"] = "walk_pre",
            ["run"] = "walk_loop",
            ["stoprun"] = "walk_pst",
        }, nil, nil,
        {
            ["endonenter"] = function(inst)
                local t = GetTime()
                if (inst["sg"]["mem"]["lastfootstep"] or -math["huge"]) + 0.3 < t then
                    inst["sg"]["mem"]["lastfootstep"] = t
                    PlayFootstep(inst, 0.5)
                end
            end,
        })
return StateGraph("hh_beetle_pig", hh_states, hh_events, "idle")