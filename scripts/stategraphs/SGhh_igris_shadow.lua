local HH_UTILS = require("utils/hh_utils")
require("stategraphs/commonstates")
local ROTATE_CD = 12
local AROUND_CD = 30
local SWIPE_ARC = 240
local SWIPE_OFFSET = 2
local SWIPE_RADIUS = 3.5
local AOE_RANGE_PADDING = 3
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local SPIN_CANT_TAGS = { "brightmareboss", "brightmare", "INLIMBO", "FX", "NOCLICK", "playerghost", "flight", "invisible", "notarget", "noattack" }
local SPIN_ONEOF_TAGS = { "_health", "CHOP_workable", "HAMMER_workable", "MINE_workable" }

local function IsDungeonBlink(inst)
    if inst:HasTag("in_solo_dungeon")
        or inst.hh_is_dungeon_monster == true
        or inst:HasTag("hh_dungeon_mob") then
        return true
    end
    local follower = inst.components ~= nil and inst.components.follower or nil
    local leader = follower ~= nil and follower:GetLeader() or nil
    return leader ~= nil and leader:HasTag("in_solo_dungeon")
end

local function IsBlinkPathClear(inst, dest)
    -- The companion stategraph is also used in the overworld. Only the
    -- dungeon-bound companion path needs the dynamic arena-wall check.
    if not IsDungeonBlink(inst) then
        return true
    end
    if TheWorld == nil or TheWorld.Map == nil or TheWorld.Pathfinder == nil
        or not TheWorld.Map:IsPassableAtPoint(dest.x, dest.y, dest.z)
        or TheWorld.Map:IsGroundTargetBlocked(dest) then
        return false
    end
    local x, y, z = inst["Transform"]:GetWorldPosition()
    return TheWorld.Pathfinder:IsClear(x, y, z, dest.x, dest.y, dest.z)
end

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
                and HH_UTILS:CanShadowDamageTarget(inst, v)
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
                --One-hit chết mục tiêu không di chuyển (công trình/tường)
                if dig and v["components"]["locomotor"] == nil then
                    HH_UTILS:KillWithAttacker(v, inst)
                else
                    inst["components"]["combat"]:DoAttack(v)
                    if mult then
                        --Kiểm tra có hiệu ứng Hất tung hay không
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
--Hàm tính sát thương diện rộng (AoE)
local function DoArcAttack(inst, dist, radius, arc, heavymult, mult, forcelanded, targets)
    _AOEAttack(inst, false, dist, radius, arc, heavymult, mult, forcelanded, targets)
end
local function DoAOEAttack(inst, dist, radius, heavymult, mult, forcelanded, targets)
    _AOEAttack(inst, false, dist, radius, nil, heavymult, mult, forcelanded, targets)
end
--Kiểm tra Mục tiêu có nằm phía trước mặt không
local function IsTargetInFront(inst, target, arc)
    if not (target and target:IsValid()) then
        return false
    end
    local rot = inst["Transform"]:GetRotation()
    local rot1 = inst:GetAngleToPoint(target["Transform"]:GetWorldPosition())
    return DiffAngle(rot, rot1) < (arc or 180) / 2
end
----
---SỰ KIỆN: ĐI BỘ VÀ RƯỢT ĐUỔI
---
local function eventWalkSg(inst, data)
    if not (HH_UTILS:HasComponents(inst, "locomotor") and inst["sg"]) then
        return
    end
    local inst_sg = inst["sg"]
    if inst["components"]["locomotor"]:WantsToMoveForward() then
        if inst_sg:HasStateTag("idle") then
            if data and data["dir"] then
                --Đổi hướng quay mặt
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
---SỰ KIỆN: BỊ ĐÁNH TRÚNG (BỊ HIT)
---
local function eventAttackedSg(inst, data)
    --Tỉ lệ 50% miễn nhiễm khựng (Super Armor - Tránh bị ngắt chiêu)
    local random_num = math["random"]()
    if random_num < 0.5 then
        return
    end
    local inst_sg = inst["sg"]
    if not inst_sg:HasStateTag("busy") or
            inst_sg:HasStateTag("caninterrupt") or
            inst_sg:HasStateTag("frozen")
    then
        --Bị đánh trúng sẽ làm tăng thời gian delay
        if not CommonHandlers["HitRecoveryDelay"](inst) then
            inst_sg:GoToState("hit")
        end
    end
end
----
---SỰ KIỆN TÍNH TOÁN KỸ NĂNG SẼ TUNG RA (AI TẤN CÔNG)
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

    if not hh_target then
        return false
    end

    local available_skills = {
        "relentless_dash_1",
        "shadow_blink_pre",
        "attack_rotate_pre"
    }

    if not inst["components"]["timer"]:TimerExists("pig_around_cd") then
        table.insert(available_skills, "attack_around")
    end

    if inst:IsNear(hh_target, 4.5 + hh_target:GetPhysicsRadius(0)) then
        table.insert(available_skills, "attack1")
    end

    -- Ngẫu nhiên có trí nhớ: Lọc bỏ chiêu vừa đánh
    if not inst["sg"]["mem"] then inst["sg"]["mem"] = {} end
    local last_skill = inst["sg"]["mem"]["last_used_skill"]
    if last_skill and #available_skills > 1 then
        for i, skill in ipairs(available_skills) do
            if skill == last_skill then
                table.remove(available_skills, i)
                break
            end
        end
    end

    if #available_skills > 0 then
        local chosen_skill = available_skills[math.random(#available_skills)]
        inst["sg"]["mem"]["last_used_skill"] = chosen_skill
        inst_sg:GoToState(chosen_skill, hh_target)
        return true
    end

    return false
end
local hh_events = {
    CommonHandlers["OnDeath"](),
    --TRẠNG THÁI: ĐI BỘ
    EventHandler("locomote", eventWalkSg),
    EventHandler("attacked", eventAttackedSg),
    --Các sự kiện tấn công của StateGraph
    EventHandler("doattack", eventAttackSg),

}
local hh_states = {
    --TRẠNG THÁI: ĐỨNG YÊN (IDLE)
    State {
        ["name"] = "idle",
        ["tags"] = { "idle", "canrotate" },

        ["onenter"] = function(inst, norotate)
            local inst_sg = inst["sg"]
            --TRẠNG THÁI: TỬ VONG (DEATH)
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
    --TRẠNG THÁI: TỬ VONG (DEATH)
    State {
        ["name"] = "death",
        ["tags"] = { "dead", "busy", "noattack" },
        ["onenter"] = function(inst)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/death") end
            inst["AnimState"]:PlayAnimation("death2")
            inst["Physics"]:Stop()
            RemovePhysicsColliders(inst)
            if HH_UTILS:HasComponents(inst, "lootdropper") then
                inst["components"]["lootdropper"]:DropLoot(inst:GetPosition())
            end
        end,
    },
    ---------------------------------------KỸ NĂNG 1: TAM LIÊN KÍCH (Chuỗi đấm 3 Hit liên tiếp)-------------------------------------------------
    State {
        --HIT 1 (CỦA TAM LIÊN KÍCH): Đấm trái
        ["name"] = "attack1",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe_pre") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack1")
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
                inst["sg"]["statemem"]["target"] = target
            end
        end,
        ["timeline"] = {
            FrameEvent(3, function(inst)
                inst["components"]["combat"]:StartAttack()
            end),
            FrameEvent(8, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") end
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
    --Kết thúc Hit 1 - Chờ chuyển sang Hit 2
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
    --HIT 2 (CỦA TAM LIÊN KÍCH): Đấm phải
    State {
        ["name"] = "attack2",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe_pre") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack2")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
        end,
        ["timeline"] = {
            FrameEvent(4, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") end
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
    --HIT 3 (CỦA TAM LIÊN KÍCH): Móc ngược (Uppercut - Đòn chốt)
    State {
        ["name"] = "attack3",
        ["tags"] = { "attack", "busy", "jumping", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe_pre") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack3")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
            --Buff thêm tốc độ lướt tới phía trước
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
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/taunt_2") end
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
    ---------------------------------------------------------------KỸ NĂNG 5: VŨ ĐIỆU TỬ THẦN (Relentless Execution)----------------------------------------------------------------
    -- 
    -- STATE 1: Lướt lần 1 (Dash 1)
    State {
        ["name"] = "relentless_dash_1",
        ["tags"] = { "attack", "busy", "canrotate" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("dash")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
            end
            
            -- Ép vật lý bằng API chuẩn đã test ở skill Xoay Chong Chóng
            inst["Physics"]:SetMotorVelOverride(150, 0, 0)
            
            -- Animation dash có 14 frames, ép timeout để đảm bảo 100% chuyển state
            inst["sg"]:SetTimeout(14 * FRAMES)
        end,
        ["onupdate"] = function(inst)
            local target = inst["sg"]["statemem"]["target"]
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
            end
        end,
        ["timeline"] = {
            FrameEvent(2, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/step") end
            end),
        },
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("relentless_attack_1", inst["sg"]["statemem"]["target"])
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                inst["sg"]:GoToState("relentless_attack_1", inst["sg"]["statemem"]["target"])
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },

    -- STATE 2: Chém nhát đầu (Attack 1 đặc biệt)
    State {
        ["name"] = "relentless_attack_1",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe_pre") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack1")
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
                inst["sg"]["statemem"]["target"] = target
            end
            
            -- Animation attack1 tốn 19 frames
            inst["sg"]:SetTimeout(19 * FRAMES)
        end,
        ["timeline"] = {
            FrameEvent(3, function(inst)
                inst["components"]["combat"]:StartAttack()
            end),
            FrameEvent(8, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") end
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
            end),
        },
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("relentless_dash_2", inst["sg"]["statemem"]["target"])
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                inst["sg"]:GoToState("relentless_dash_2", inst["sg"]["statemem"]["target"])
            end),
        },
    },
    -- STATE 3: Lướt lần 2 (Dash 2)
    State {
        ["name"] = "relentless_dash_2",
        ["tags"] = { "attack", "busy" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("dash")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
            end
            
            -- Ép vật lý lao tới với tốc độ 150
            inst["Physics"]:SetMotorVelOverride(150, 0, 0)
            
            -- Timeout đúng 14 frames
            inst["sg"]:SetTimeout(14 * FRAMES)
        end,
        ["onupdate"] = function(inst)
            local target = inst["sg"]["statemem"]["target"]
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
            end
        end,
        ["timeline"] = {
            FrameEvent(2, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/step") end
            end),
        },
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("relentless_attack1", inst["sg"]["statemem"]["target"])
        end,
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    --HIT 1 (CỦA VŨ ĐIỆU TỬ THẦN)
    State {
        ["name"] = "relentless_attack1",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe_pre") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack1")
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
                inst["sg"]["statemem"]["target"] = target
            end
        end,
        ["timeline"] = {
            FrameEvent(3, function(inst)
                inst["components"]["combat"]:StartAttack()
            end),
            FrameEvent(8, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") end
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    if IsTargetInFront(inst, inst["sg"]["statemem"]["target"], SWIPE_ARC) then
                        inst["sg"]:GoToState("relentless_attack2", inst["sg"]["statemem"]["target"])
                    elseif inst["components"]["combat"]["target"] ~= inst["sg"]["statemem"]["target"]
                            and IsTargetInFront(inst, inst["components"]["combat"]["target"], SWIPE_ARC) then
                        inst["sg"]:GoToState("relentless_attack2", inst["components"]["combat"]["target"])
                    else
                        inst["sg"]:GoToState("relentless_attack1_pst")
                    end
                end
            end),
        },
    },
    State {
        ["name"] = "relentless_attack1_pst",
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
    --HIT 2 (CỦA VŨ ĐIỆU TỬ THẦN)
    State {
        ["name"] = "relentless_attack2",
        ["tags"] = { "attack", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe_pre") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack2")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
        end,
        ["timeline"] = {
            FrameEvent(4, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") end
                DoArcAttack(inst, SWIPE_OFFSET, SWIPE_RADIUS, SWIPE_ARC)
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    if IsTargetInFront(inst, inst["sg"]["statemem"]["target"], 120) then
                        inst["sg"]:GoToState("relentless_attack3", inst["sg"]["statemem"]["target"])
                    elseif inst["components"]["combat"]["target"] ~= inst["sg"]["statemem"]["target"]
                            and IsTargetInFront(inst, inst["components"]["combat"]["target"], 120) then
                        inst["sg"]:GoToState("relentless_attack3", inst["components"]["combat"]["target"])
                    else
                        inst["sg"]:GoToState("relentless_attack2_pst")
                    end
                end
            end),
        },
    },
    State {
        ["name"] = "relentless_attack2_pst",
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
    --HIT 3 (CỦA VŨ ĐIỆU TỬ THẦN)
    State {
        ["name"] = "relentless_attack3",
        ["tags"] = { "attack", "busy", "jumping", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe_pre") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack3")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
            inst["components"]["combat"]:StartAttack()
            --Buff thêm tốc độ lướt tới phía trước
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
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/taunt_2") end
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
                    inst["sg"]:GoToState("relentless_pst")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
     -- STATE 4: Đứng idle
    State {
        ["name"] = "relentless_pst",
        ["tags"] = { "busy"},
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("idle_loop", true)
            inst["sg"]:SetTimeout(2) -- Đứng uy nghiêm 3 giây
        end,
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("idle")
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                -- Không làm gì, chờ timeout
            end),
        },
    },
    ---------------------------------------------------------------KỸ NĂNG 2: ĐẠI PHONG XA (Xoay chong chóng liên tục)----------------------------------------------------------------
    State {
        --Chuẩn bị gồng Xoay chong chóng (Wind-up)
        ["name"] = "attack_rotate_pre",
        ["tags"] = { "busy", "canrotate", "spin", "attack_rotate", },
        ["onenter"] = function(inst, hh_target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("taunt")
            inst["sg"]["statemem"]["target"] = hh_target
        end,
        ["timeline"] = {
            FrameEvent(19, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/taunt") end
            end),
        }, 
        ["events"] = {
            EventHandler("animover", function(inst)
                --Đưa tốc độ di chuyển về 0
                inst["components"]["locomotor"]:EnableGroundSpeedMultiplier(false)
                inst["sg"]:GoToState("attack_rotate", inst["sg"]["statemem"]["target"])
            end),
        },
        ["onexit"] = function(inst)
            inst["components"]["locomotor"]:EnableGroundSpeedMultiplier(true)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
            inst["components"]["locomotor"]:Stop()
        end,
    },
    State {
        ["name"] = "attack_rotate",
        ["tags"] = { "busy", "canrotate", "spin" },

        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/spin") end
            inst["components"]["locomotor"]:Stop()
            inst["components"]["locomotor"]:EnableGroundSpeedMultiplier(false)
            inst["AnimState"]:PlayAnimation("attack4")
            inst["sg"]["statemem"]["target"] = target
            inst["sg"]["statemem"]["update_rotate_cd"] = 8 * FRAMES
        end,
        ["timeline"] = {
            FrameEvent(15, function(inst)
                local spin_speed = 7
                local hh_target = inst["sg"]["statemem"]["target"]
                if hh_target ~= nil and hh_target:IsValid() and HH_UTILS:HasComponents(hh_target, "locomotor") and hh_target["Transform"] then
                    inst:ForceFacePoint(hh_target["Transform"]:GetWorldPosition())
                    local target_locomotor = hh_target["components"]["locomotor"]
                    local inst_locomotor = inst["components"]["locomotor"]
                    spin_speed = math["max"](spin_speed, target_locomotor:GetRunSpeed() * inst_locomotor:GetSpeedMultiplier()) - 0.25
                    spin_speed = math["min"](spin_speed, 35)
                end
                spin_speed = spin_speed + 10
                inst["sg"]["statemem"]["spin_speed"] = spin_speed
                inst["Physics"]:SetMotorVelOverride(spin_speed, 0, 0)
            end),
        },
        ["onupdate"] = function(inst, dt)

            local hh_target = inst["sg"]["statemem"]["target"]
            if hh_target ~= nil and HH_UTILS:NotIsDead(hh_target) and hh_target["Transform"] then
                inst:ForceFacePoint(hh_target["Transform"]:GetWorldPosition())
                local tx, ty, tz = hh_target["Transform"]:GetWorldPosition()
                inst["Transform"]:SetRotation(inst:GetAngleToPoint(tx, ty, tz))
            else
                inst["sg"]["statemem"]["target"] = nil
            end
            local current_time = inst["sg"]["statemem"]["update_rotate_cd"]
            if not HH_UTILS:IsHHType(current_time, "number") then
                inst["sg"]["statemem"]["update_rotate_cd"] = 8 * FRAMES
            end
            inst["sg"]["statemem"]["update_rotate_cd"] = inst["sg"]["statemem"]["update_rotate_cd"] - dt
            if current_time < 0 then
                local ix, iy, iz = inst["Transform"]:GetWorldPosition()
                local targets = TheSim:FindEntities(ix, iy, iz, 6, nil, SPIN_CANT_TAGS, SPIN_ONEOF_TAGS)
                for _, target in ipairs(targets) do
                    if target and target ~= inst and target:IsValid() and not target:IsInLimbo()
                        and HH_UTILS:CanShadowDamageTarget(inst, target) then
                        local range = 4.5 + target:GetPhysicsRadius(0)
                        if target:GetDistanceSqToPoint(ix, iy, iz) < range * range then
                            local has_health = target["components"]["health"] ~= nil
                            if has_health and target:HasTag("smashable") then
                                HH_UTILS:KillWithAttacker(target, inst)
                            elseif target["components"]["workable"] ~= nil and target["components"]["workable"]:CanBeWorked() then
                                target["components"]["workable"]:Destroy(inst)
                            elseif has_health and not target["components"]["health"]:IsDead() then
                                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe") end
                                inst["components"]["combat"]:DoAttack(target)
                            end
                        end
                    end
                end
                inst["sg"]["statemem"]["update_rotate_cd"] = 8 * FRAMES
            end
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["AnimState"]:AnimDone() then
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
        ["onexit"] = function(inst)
            inst["components"]["locomotor"]:EnableGroundSpeedMultiplier(true)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
            inst["components"]["locomotor"]:Stop()
        end,
    },
    ---------------------------------------------------------------KỸ NĂNG 3: HỌA ĐỊA VI LAO (Dậm đất nổ AoE)----------------------------------------------------------------
    State {
        --Đập tay xuống đất gây nổ AoE
        ["name"] = "attack_around",
        ["tags"] = { "canrotate", "busy", "candefeat" },
        ["onenter"] = function(inst, target)
            if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/grunt") end
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack5")
            inst["components"]["timer"]:StopTimer("pig_around_cd")
            inst["components"]["timer"]:StartTimer("pig_around_cd", AROUND_CD)
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
        ["timeline"] = {
            FrameEvent(12, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/attack_5") end
            end),
            FrameEvent(35, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/attack_5_fire_1") end
            end),
            FrameEvent(37, function(inst)
                if inst["SoundEmitter"] then inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/attack_5_fire_2") end
            end),
            FrameEvent(38, function(inst)
                local x, y, z = inst["Transform"]:GetWorldPosition()
                local targets = TheSim:FindEntities(x, y, z, 16, { "_combat", "_health" }, { "FX", "DECOR", "INLIMBO", "playerghost", "player", "companion", "shadow_minion" })
                for index, v in ipairs(targets or {}) do
                    if HH_UTILS:IsHHType(v, "table") and HH_UTILS:NotIsDead(v) and v["Transform"] and v["Physics"] then
                        local player_x, player_y, player_z = v["Transform"]:GetWorldPosition()
                        local radius = math["max"](1, v:GetPhysicsRadius(0) + 0.75)
                        local circ = PI2 * radius
                        local num = math["floor"](circ / 1.4 + 0.5)
                        local theta = math["random"]() * PI2
                        local delta = PI2 / num
                        for i = 1, num do
                            local pt = Vector3(player_x + math["cos"](theta) * radius, 0, player_z - math["sin"](theta) * radius)
                            local spawn_wall = SpawnPrefab("wall_moonrock")
                            if spawn_wall and spawn_wall["Transform"] then
                                spawn_wall["Transform"]:SetPosition(pt:Get())
                                spawn_wall["persists"] = false
                                spawn_wall:DoTaskInTime(4, spawn_wall["Remove"])
                            end
                            theta = theta + delta
                        end
                    end
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
            inst["Physics"]:ClearMotorVelOverride()
            inst["Physics"]:Stop()
        end,
    },
    ---------------------------------------------------------------TRẠNG THÁI: BỊ ĐÁNH TRÚNG (KHỰNG LẠI)----------------------------------------------------------------
    State {
        ["name"] = "hit",
        ["tags"] = { "hit", "busy" },
        ["onenter"] = function(inst, data)
            inst["components"]["locomotor"]:StopMoving()
            inst["AnimState"]:PlayAnimation("hit")
        end,
        ["timeline"] = {
            FrameEvent(11, function(inst)
                if not HH_UTILS:NotIsDead(inst) then
                    --TRẠNG THÁI: TỬ VONG (DEATH)
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

    ---------------------------------------KỸ NĂNG 4: TỬ THẦN PHỤC KÍCH (Blink Strike)-------------------------------------------------
    State {
        ["name"] = "shadow_blink_pre",
        ["tags"] = { "attack", "busy", "noattack" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("taunt")
            if target and target:IsValid() then
                inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
                inst["sg"]["statemem"]["target"] = target
            end
        end,
        ["timeline"] = {
            FrameEvent(19, function(inst)
                if inst["SoundEmitter"] then
                    inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/taunt")
                end
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["SoundEmitter"] then
                    inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/step")
                end
                local target = inst["sg"]["statemem"]["target"]
                if target and target:IsValid() then
                    local angle = target["Transform"]:GetRotation() * DEGREES
                    local offset = Vector3(-math.cos(angle)*2, 0, -math.sin(angle)*2)
                    local dest = target:GetPosition() + offset
                    if IsBlinkPathClear(inst, dest) then
                        if inst["Physics"] ~= nil then
                            inst["Physics"]:Teleport(dest:Get())
                        else
                            inst["Transform"]:SetPosition(dest:Get())
                        end
                        inst:ForceFacePoint(target["Transform"]:GetWorldPosition())
                        inst["sg"]:GoToState("shadow_blink_strike", target)
                    else
                        inst["sg"]:GoToState("idle")
                    end
                else
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },
    State {
        ["name"] = "shadow_blink_strike",
        ["tags"] = { "attack", "busy" },
        ["onenter"] = function(inst, target)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("attack1")
            if target and target:IsValid() then
                inst["sg"]["statemem"]["target"] = target
            end
        end,
        ["timeline"] = {
            FrameEvent(8, function(inst)
                if inst["SoundEmitter"] then
                    inst["SoundEmitter"]:PlaySound("dontstarve/creatures/lava_arena/boarrior/swipe")
                end
            end),
            FrameEvent(12, function(inst)
                local target = inst["sg"]["statemem"]["target"]
                local missed = true
                local pt = inst:GetPosition()
                local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 4.0, { "_combat", "_health" }, { "player", "companion", "shadow_minion", "INCOVER", "notarget", "noattack", "flight", "invisible" })
                for i, v in ipairs(ents) do
                    if v:IsValid() and not v["components"]["health"]:IsDead() then
                        if IsTargetInFront(inst, v, 100)
                            and HH_UTILS:CanShadowDamageTarget(inst, v) then
                            -- Gây sát thương cực lớn cho quái vật (300)
                            HH_UTILS:DoDeltaWithAttacker(v, -300, inst.prefab, inst)
                            missed = false
                        end
                    end
                end
                if missed then
                    inst["sg"]["statemem"]["missed"] = true
                end
            end),
        },
        ["events"] = {
            EventHandler("animover", function(inst)
                if inst["sg"]["statemem"]["missed"] then
                    inst["sg"]:GoToState("shadow_blink_pst")
                else
                    inst["sg"]:GoToState("idle")
                end
            end),
        },
    },
    State {
        ["name"] = "shadow_blink_pst",
        ["tags"] = { "busy"},
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst["AnimState"]:PlayAnimation("idle_loop", true)
            inst["sg"]:SetTimeout(3) -- Đứng uy nghiêm 3 giây
        end,
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("idle")
        end,
        ["events"] = {
            EventHandler("animover", function(inst)
                -- Không làm gì, chờ timeout
            end),
        },
    },
}
--------------------------------TRẠNG THÁI: ĐI BỘ------------------------------------------------
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
--Cấu hình Hoạt ảnh Chạy (Run Animation)
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
return StateGraph("hh_igris_shadow", hh_states, hh_events, "idle")
