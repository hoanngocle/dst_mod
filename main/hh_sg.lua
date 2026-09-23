local nFfuiccKu = require("utils/hh_utils")
AddStategraphState(
    "wilson",
    State {
        ["name"] = "hh_fast_sg",
        ["tags"] = {"doing", "busy", "keepchannelcasting"},
        ["onenter"] = function(cFkuccfKu)
            cFkuccfKu["components"]["locomotor"]:Stop()
            cFkuccfKu["AnimState"]:PlayAnimation("pickup")
            cFkuccfKu["sg"]["statemem"]["action"] = cFkuccfKu["bufferedaction"]
            cFkuccfKu["sg"]:SetTimeout(5 * FRAMES)
        end,
        ["timeline"] = {
            TimeEvent(
                2 * FRAMES,
                function(iFiukciki)
                    iFiukciki["sg"]:RemoveStateTag("busy")
                    iFiukciki:PerformBufferedAction()
                end
            )
        },
        ["ontimeout"] = function(gFcuuCgkc)
            gFcuuCgkc:PerformBufferedAction()
        end,
        ["events"] = {
            EventHandler(
                "animover",
                function(nFcukCnKi)
                    nFcukCnKi["sg"]:GoToState("idle")
                end
            )
        },
        ["onexit"] = function(ffcugCfKc)
            if
                ffcugCfKc["bufferedaction"] == ffcugCfKc["sg"]["statemem"]["action"] and
                    (ffcugCfKc["components"]["playercontroller"] == nil or
                        ffcugCfKc["components"]["playercontroller"]["lastheldaction"] ~= ffcugCfKc["bufferedaction"])
             then
                ffcugCfKc:ClearBufferedAction()
            end
        end
    }
)

-- Issue 4: dynamic dungeon walls are registered in Pathfinder, while some
-- custom attack/knockback states move with motor velocity. Validate only
-- those active movement states; normal locomotion remains vanilla physics.
local function HHIsDungeonMotionEntity(inst)
    if inst == nil or inst.Transform == nil then
        return false
    end
    if inst:HasTag("in_solo_dungeon")
        or inst.hh_is_dungeon_monster == true
        or inst.hh_is_dungeon_boss == true
        or inst:HasTag("hh_dungeon_mob") then
        return true
    end

    local follower = inst.components ~= nil and inst.components.follower or nil
    local leader = follower ~= nil and follower:GetLeader() or nil
    return leader ~= nil and leader:IsValid() and leader:HasTag("in_solo_dungeon")
end

local function HHIsDungeonPathClear(inst, from_pos, x, z)
    if not HHIsDungeonMotionEntity(inst) then
        return true
    end
    local pathfinder = TheWorld ~= nil and TheWorld.Pathfinder or nil
    if pathfinder == nil then
        return false
    end

    local sx, sz
    if from_pos ~= nil then
        sx, sz = from_pos.x, from_pos.z
    else
        local px, _, pz = inst.Transform:GetWorldPosition()
        sx, sz = px, pz
    end
    return pathfinder:IsClear(sx, 0, sz, x, 0, z)
end

local function HHGetDungeonMotionStateMem(inst)
    return inst ~= nil and inst.sg ~= nil and inst.sg.statemem or nil
end

local function HHBeginDungeonMotion(inst)
    if not HHIsDungeonMotionEntity(inst) then
        return
    end
    local statemem = HHGetDungeonMotionStateMem(inst)
    if statemem == nil then
        return
    end
    local x, _, z = inst.Transform:GetWorldPosition()
    statemem._hh_dungeon_motion_last_clear_pos = Vector3(x, 0, z)
end

local function HHStopAtDungeonMotionPosition(inst)
    local statemem = HHGetDungeonMotionStateMem(inst)
    local safe = statemem ~= nil and statemem._hh_dungeon_motion_last_clear_pos or nil
    if inst.Physics == nil then
        return
    end
    inst.Physics:Stop()
    inst.Physics:ClearMotorVelOverride()
    if safe ~= nil then
        inst.Physics:Teleport(safe.x, 0, safe.z)
    end
end

local function HHCheckDungeonMotion(inst)
    if not HHIsDungeonMotionEntity(inst) then
        return true
    end

    local statemem = HHGetDungeonMotionStateMem(inst)
    if statemem == nil then
        return true
    end
    local x, _, z = inst.Transform:GetWorldPosition()
    local safe = statemem._hh_dungeon_motion_last_clear_pos
    if safe == nil then
        statemem._hh_dungeon_motion_last_clear_pos = Vector3(x, 0, z)
        return true
    end

    local dx = x - safe.x
    local dz = z - safe.z
    if dx * dx + dz * dz < 0.0001 then
        return true
    end

    if not HHIsDungeonPathClear(inst, safe, x, z) then
        HHStopAtDungeonMotionPosition(inst)
        return false
    end

    safe.x, safe.y, safe.z = x, 0, z
    return true
end

local function HHWrapDungeonMotionState(state_name, state)
    local old_onenter = state.onenter
    local old_onupdate = state.onupdate
    local old_onexit = state.onexit
    state._hh_dungeon_motion_guarded = true

    state.onenter = function(inst, data)
        HHBeginDungeonMotion(inst)

        if old_onenter ~= nil then
            old_onenter(inst, data)
        end

        if inst.sg ~= nil and inst.sg.currentstate == state then
            HHCheckDungeonMotion(inst)
        end
    end

    state.onupdate = function(inst, dt)
        if old_onupdate ~= nil then
            old_onupdate(inst, dt)
        end
        if inst.sg == nil or inst.sg.currentstate ~= state then
            return
        end
        HHCheckDungeonMotion(inst)
    end

    state.onexit = function(inst)
        if inst.sg ~= nil and inst.sg.currentstate == state then
            local statemem = HHGetDungeonMotionStateMem(inst)
            if statemem ~= nil then
                statemem._hh_dungeon_motion_last_clear_pos = nil
            end
        end
        if old_onexit ~= nil then
            old_onexit(inst)
        end
    end
end

local function HHInstallDungeonMotionStates(sg, state_names)
    if sg.states == nil then
        return
    end
    for _, state_name in ipairs(state_names) do
        local state = sg.states ~= nil and sg.states[state_name] or nil
        if state ~= nil and not state._hh_dungeon_motion_guarded then
            HHWrapDungeonMotionState(state_name, state)
        end
    end
end

local function HHWrapDungeonKnockbackState(state_name, state)
    local old_onenter = state.onenter
    local old_onupdate = state.onupdate
    local old_onexit = state.onexit
    state._hh_dungeon_knockback_guarded = true

    state.onenter = function(inst, data)
        HHBeginDungeonMotion(inst)
        if old_onenter ~= nil then
            old_onenter(inst, data)
        end
        if inst.sg ~= nil and inst.sg.currentstate == state then
            HHCheckDungeonMotion(inst)
        end
    end

    state.onupdate = function(inst, dt)
        if old_onupdate ~= nil then
            old_onupdate(inst, dt)
        end
        if inst.sg == nil or inst.sg.currentstate ~= state then
            return
        end
        HHCheckDungeonMotion(inst)
    end

    state.onexit = function(inst)
        if inst.sg ~= nil and inst.sg.currentstate == state then
            local statemem = HHGetDungeonMotionStateMem(inst)
            if statemem ~= nil then
                statemem._hh_dungeon_motion_last_clear_pos = nil
            end
        end
        if old_onexit ~= nil then
            old_onexit(inst)
        end
    end
end

local function HHInstallDungeonKnockbackGuard(sg)
    for _, state_name in ipairs({"knockback", "knockbacklanded"}) do
        local state = sg.states ~= nil and sg.states[state_name] or nil
        if state ~= nil and not state._hh_dungeon_knockback_guarded then
            HHWrapDungeonKnockbackState(state_name, state)
        end
    end
end

AddStategraphPostInit("wilson", HHInstallDungeonKnockbackGuard)

local function HHInstallNamedDungeonMotionStates(state_names)
    return function(sg)
        HHInstallDungeonMotionStates(sg, state_names)
    end
end

-- The player shadow-knife leap uses a motor burst followed by a direct
-- Physics:Teleport. It is guarded only while the player is inside a dungeon.
AddStategraphPostInit(
    "wilson",
    HHInstallNamedDungeonMotionStates({"hh_knife_aoe"})
)

AddStategraphPostInit(
    "hh_igris_shadow",
    HHInstallNamedDungeonMotionStates({
        "attack3",
        "relentless_dash_1",
        "relentless_dash_2",
        "relentless_attack3",
        "attack_rotate",
    })
)
AddStategraphPostInit(
    "hh_igris_dungeon",
    HHInstallNamedDungeonMotionStates({
        "attack3",
        "relentless_dash_1",
        "relentless_dash_2",
        "relentless_attack3",
        "attack_rotate",
    })
)
AddStategraphPostInit(
    "hh_beru_shadow",
    HHInstallNamedDungeonMotionStates({"attack3", "attack_jump"})
)
AddStategraphPostInit(
    "hh_beru_dungeon",
    HHInstallNamedDungeonMotionStates({"attack3", "attack_jump"})
)
AddStategraphPostInit(
    "hh_beetle_pig",
    HHInstallNamedDungeonMotionStates({"attack3", "attack_jump"})
)
AddStategraphPostInit(
    "hh_dual_wield_pig",
    HHInstallNamedDungeonMotionStates({"attack3", "attack_rotate"})
)
AddStategraphPostInit(
    "hh_sharkboi",
    HHInstallNamedDungeonMotionStates({
        "spawn",
        "attack3",
        "torpedo_jump",
        "torpedo",
        "dive_jump_delay",
        "dive_jump",
        "dive_dig_stun",
    })
)

-- The dungeon spider's evade state is injected in hh_dungeon_mobs_sg.lua and
-- uses both SetMotorVelOverride and SetMotorVel. Guard that state only.
AddStategraphPostInit(
    "spider",
    HHInstallNamedDungeonMotionStates({"evade_loop", "warrior_attack"})
)

-- Vanilla dungeon mobs with state-local dash/joust motor bursts. Keep the
-- guard limited to those states so ordinary locomotion remains untouched.
AddStategraphPostInit(
    "bearger",
    HHInstallNamedDungeonMotionStates({
        "attack_combo1",
        "attack_combo2",
        "attack_combo1a",
        "butt",
        "butt_pst",
    })
)
AddStategraphPostInit(
    "rook",
    HHInstallNamedDungeonMotionStates({"run_stop"})
)
AddStategraphPostInit(
    "knight",
    HHInstallNamedDungeonMotionStates({
        "joust_pre",
        "joust_loop",
        "joust_pst",
        "joust_collide",
    })
)
AddStategraphPostInit(
    "minotaur",
    HHInstallNamedDungeonMotionStates({"leap_attack"})
)
AddStategraphPostInit(
    "dragonfly",
    HHInstallNamedDungeonMotionStates({"flyaway"})
)

local function HHDungeonTransitionCleanup(inst)
    inst:RemoveTag("hh_dungeon_transition")
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(true)
    end
end

AddStategraphState(
    "wilson",
    State {
        name = "hh_dungeon_migrate",
        tags = {"doing", "busy", "nopredict", "nomorph", "nodangle", "nointerrupt"},
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst:AddTag("hh_dungeon_transition")
            inst.sg.statemem.mode = data ~= nil and data.mode or nil
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_item_hat" or "pickup")
        end,
        events = {
            EventHandler("animover", function(inst)
                if not inst.AnimState:AnimDone() or inst.sg.statemem.transition_started then
                    return
                end
                inst.sg.statemem.transition_started = true

                local departfx = SpawnPrefab("spawn_fx_medium_static")
                if departfx ~= nil then
                    departfx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
                if inst.components.colourtweener ~= nil then
                    inst.components.colourtweener:StartTween({0, 0, 0, 1}, 13 * FRAMES)
                else
                    inst.AnimState:SetMultColour(0, 0, 0, 1)
                end

                inst.sg.statemem.movetask = inst:DoTaskInTime(13 * FRAMES, function(player)
                    player.sg.statemem.movetask = nil
                    local manager = TheWorld.components.dungeon_manager
                    local moved = false
                    if manager ~= nil then
                        if player.sg.statemem.mode == "enter" then
                            moved = manager:EnterDungeon(player) == true
                        elseif player.sg.statemem.mode == "leave" then
                            moved = manager:LeaveDungeon(player, "dungeon_exit") == true
                            if moved and player.components.dungeon_cooldown ~= nil then
                                player.components.dungeon_cooldown:StartTimer(8 * 60)
                            end
                        end
                    end
                    player.sg.statemem.moved = moved

                    if moved then
                        local arrivefx = SpawnPrefab("spawn_fx_medium_static")
                        if arrivefx ~= nil then
                            arrivefx.entity:SetParent(player.entity)
                        end
                    end
                    player.sg.statemem.fadeintask = player:DoTaskInTime(6 * FRAMES, function(player)
                        player.sg.statemem.fadeintask = nil
                        if player.components.colourtweener ~= nil then
                            player.components.colourtweener:StartTween({1, 1, 1, 1}, 19 * FRAMES)
                        else
                            player.AnimState:SetMultColour(1, 1, 1, 1)
                        end
                        player.sg.statemem.finishtask = player:DoTaskInTime(19 * FRAMES, function(player)
                            player.sg.statemem.finishtask = nil
                            player.sg.statemem.completed = true
                            HHDungeonTransitionCleanup(player)
                            player.sg:GoToState("idle")
                        end)
                    end)
                end)
            end),
        },
        onexit = function(inst)
            for _, taskname in ipairs({"movetask", "fadeintask", "finishtask"}) do
                local task = inst.sg.statemem[taskname]
                if task ~= nil then
                    task:Cancel()
                    inst.sg.statemem[taskname] = nil
                end
            end
            HHDungeonTransitionCleanup(inst)
        end,
    }
)

AddStategraphState(
    "wilson_client",
    State {
        name = "hh_dungeon_migrate",
        tags = {"doing", "busy", "pausepredict", "nomorph", "nodangle"},
        server_states = {"hh_dungeon_migrate"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
        end,
        onupdate = function(inst)
            inst.entity:FlattenMovementPrediction()
        end,
    }
)

local function HHShadowSwapOverrideSymbols(inst)
    inst.AnimState:OverrideSymbol("shadow_hands", "shadow_skinchangefx", "shadow_hands")
    inst.AnimState:OverrideSymbol("shadow_ball", "shadow_skinchangefx", "shadow_ball")
    inst.AnimState:OverrideSymbol("splode", "shadow_skinchangefx", "splode")
end

local function HHShadowSwapClearSymbols(inst)
    inst.AnimState:ClearOverrideSymbol("shadow_hands")
    inst.AnimState:ClearOverrideSymbol("shadow_ball")
    inst.AnimState:ClearOverrideSymbol("splode")
end

AddStategraphState(
    "wilson",
    State {
        name = "hh_shadow_swap",
        tags = {"doing", "busy", "pausepredict", "nopredict", "nomorph", "nodangle", "nointerrupt"},
        onenter = function(inst, data)
            if data == nil or inst.components.hh_shadow_manager == nil then
                inst.sg:GoToState("idle")
                return
            end
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()
            inst.sg.statemem.data = data
            HHShadowSwapOverrideSymbols(inst)
            inst.AnimState:PlayAnimation("skin_change", false)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            if inst.components.talker ~= nil then
                inst.components.talker:Say("Hoán Đổi", 42 * FRAMES, true)
            end
            local fx = SpawnPrefab("hh_shadow_swap_grab_fx")
            if fx ~= nil then
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end
        end,
        timeline = {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
            end),
            TimeEvent(42 * FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.components.talker:ShutUp()
                end
                inst.components.hh_shadow_manager:PerformSwapTeleport(inst.sg.statemem.data)
            end),
        },
        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.hh_shadow_manager:FinishSwap(inst.sg.statemem.data)
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = function(inst)
            if inst.components.talker ~= nil then
                inst.components.talker:ShutUp()
            end
            if inst.components.hh_shadow_manager ~= nil then
                inst.components.hh_shadow_manager:FinishSwap(inst.sg.statemem.data)
            end
            HHShadowSwapClearSymbols(inst)
        end,
    }
)

AddStategraphState(
    "wilson_client",
    State {
        name = "hh_shadow_swap",
        tags = {"doing", "busy", "pausepredict", "nomorph", "nodangle", "nointerrupt"},
        server_states = {"hh_shadow_swap"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            HHShadowSwapOverrideSymbols(inst)
            inst.AnimState:PlayAnimation("skin_change", false)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,
        timeline = {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
            end),
        },
        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
        onexit = HHShadowSwapClearSymbols,
    }
)
AddStategraphState(
    "wilson_client",
    State {
        ["name"] = "hh_fast_sg",
        ["tags"] = {"doing", "busy"},
        ["server_states"] = {"doshortaction"},
        ["onenter"] = function(gFiuiCkKk)
            gFiuiCkKk["components"]["locomotor"]:Stop()
            gFiuiCkKk["AnimState"]:PlayAnimation("pickup")
            gFiuiCkKk:PerformPreviewBufferedAction()
            gFiuiCkKk["sg"]:SetTimeout(5 * FRAMES)
        end,
        ["onupdate"] = function(ffgUnciKf)
            if ffgUnciKf["sg"]:ServerStateMatches() then
                if ffgUnciKf["entity"]:FlattenMovementPrediction() then
                    ffgUnciKf["sg"]:GoToState("idle", "noanim")
                end
            elseif ffgUnciKf["bufferedaction"] == nil then
                ffgUnciKf["sg"]:GoToState("idle", (160 * 458 * 9 ~= 659526))
            end
        end,
        ["ontimeout"] = function(gfcUkCuKn)
            gfcUkCuKn:ClearBufferedAction()
            gfcUkCuKn["sg"]:GoToState("idle", (223 * 381 * 385 + 1 == 32710756))
        end
    }
)
local gffUfCiKk = {{1, 1, 10}, {2, 0.8, 8}, {3, 1, 6}, {4, 1.2, 4}, {5, 1.5, 2}}
local function kFgUicnki(nfnUuCukg, ifnufccki, cFnucCkku)
    return State {
        ["name"] = "hh_fast_attack_" .. nfnUuCukg,
        ["tags"] = {"attack", "notalking", "abouttoattack", "autopredict"},
        ["onenter"] = function(uFgUiCcKf)
            uFgUiCcKf["components"]["locomotor"]:Stop()
            uFgUiCcKf["AnimState"]:PlayAnimation("spearjab")
            uFgUiCcKf["AnimState"]:SetDeltaTimeMultiplier(ifnufccki or 1)
            uFgUiCcKf["SoundEmitter"]:PlaySound("dontstarve/wilson/attack_whoosh")
            if uFgUiCcKf["components"]["playercontroller"] ~= nil then
                uFgUiCcKf["components"]["playercontroller"]:RemotePausePrediction()
            end
        end,
        ["timeline"] = {
            TimeEvent(
                (cFnucCkku or 8) * 0.5 * FRAMES,
                function(uFuUncikf)
                    uFuUncikf:PerformBufferedAction()
                end
            ),
            TimeEvent(
                (cFnucCkku or 8) * FRAMES,
                function(gfiUkckkc)
                    gfiUkckkc:PerformBufferedAction()
                    gfiUkckkc["AnimState"]:SetDeltaTimeMultiplier(1)
                    gfiUkckkc["sg"]:GoToState("idle", (226 + 3 + 414 == 643))
                end
            )
        },
        ["events"] = {
            EventHandler(
                "unequip",
                function(ufkuiCfkf)
                    ufkuiCfkf["sg"]:GoToState("idle", (422 - 358 - 2 - 237 - 247 ~= -420))
                    ufkuiCfkf["AnimState"]:SetDeltaTimeMultiplier(1)
                end
            ),
            EventHandler(
                "equip",
                function(ufkukCiKc)
                    ufkukCiKc["sg"]:GoToState("idle", (489 - 376 + 94 - 359 == -152))
                    ufkukCiKc["AnimState"]:SetDeltaTimeMultiplier(1)
                end
            ),
            EventHandler(
                "animover",
                function(uFgufCkkc)
                    uFgufCkkc["sg"]:GoToState("idle", (176 - 448 + 98 + 268 + 195 ~= 298))
                    uFgufCkkc["AnimState"]:SetDeltaTimeMultiplier(1)
                end
            )
        },
        ["ontimeout"] = function(uFgunCcKu)
            uFgunCcKu["AnimState"]:SetDeltaTimeMultiplier(1)
            if
                uFgunCcKu["bufferedaction"] == uFgunCcKu["sg"]["statemem"]["action"] and
                    (uFgunCcKu["components"]["playercontroller"] == nil or
                        uFgunCcKu["components"]["playercontroller"]["lastheldaction"] ~= uFgunCcKu["bufferedaction"])
             then
                uFgunCcKu:ClearBufferedAction()
            end
        end,
        ["onexit"] = function(iffUiCiKg)
            iffUiCiKg["AnimState"]:SetDeltaTimeMultiplier(1)
        end
    }
end
for nFuUuccKu, uFgUfCnKi in ipairs(gffUfCiKk) do
    local kFnunccKu = kFgUicnki(uFgUfCnKi[1], uFgUfCnKi[2], uFgUfCnKi[3])
    AddStategraphState("wilson", kFnunccKu)
end
AddStategraphState(
    "wilson",
    State {
        ["name"] = "hh_fast_attack_pre",
        ["tags"] = {"doing", "busy", "notalking"},
        ["onenter"] = function(uFuUfciKc)
            uFuUfciKc["components"]["locomotor"]:Stop()
            local iFnUiCcKc = uFuUfciKc:GetBufferedAction()
            if iFnUiCcKc and iFnUiCcKc["target"] and iFnUiCcKc["target"]:IsValid() then
                uFuUfciKc:ForceFacePoint(iFnUiCcKc["target"]["Transform"]:GetWorldPosition())
            end
            uFuUfciKc["sg"]:SetTimeout(0.1)
        end,
        ["events"] = {
            EventHandler(
                "unequip",
                function(nffugCnKf)
                    nffugCnKf["sg"]:GoToState("idle")
                end
            ),
            EventHandler(
                "equip",
                function(nfguuCfKg)
                    nfguuCfKg["sg"]:GoToState("idle")
                end
            )
        },
        ["ontimeout"] = function(iFcuuCiKc)
            local nFcuicukg = nFfuiccKu:GetAtkSpeedLevel(iFcuuCiKc)
            iFcuuCiKc["sg"]:GoToState("hh_fast_attack_" .. nFcuicukg)
        end
    }
)
AddStategraphState(
    "wilson_client",
    State {
        ["name"] = "hh_fast_attack_pre",
        ["tags"] = {"attack", "notalking", "abouttoattack"},
        ["server_states"] = {"hh_fast_attack_pre"},
        ["onenter"] = function(cffUfciKn)
            cffUfciKn["components"]["locomotor"]:Stop()
            cffUfciKn["AnimState"]:PlayAnimation("spearjab")
            cffUfciKn:PerformPreviewBufferedAction()
            cffUfciKn["sg"]:SetTimeout(0.1)
        end,
        ["onupdate"] = function(kFuuuCckk)
            if kFuuuCckk["sg"]:ServerStateMatches() then
                if kFuuuCckk["entity"]:FlattenMovementPrediction() then
                    kFuuuCckk["sg"]:GoToState("idle", "noanim")
                end
            elseif kFuuuCckk["bufferedaction"] == nil then
                kFuuuCckk["sg"]:GoToState("idle")
            end
        end,
        ["ontimeout"] = function(nffuncckg)
            nffuncckg:ClearBufferedAction()
            nffuncckg["sg"]:GoToState("idle")
        end
    }
)
AddStategraphState(
    "wilson",
    State {
        ["name"] = "hh_knife_aoe_start",
        ["tags"] = {"aoe", "doing", "busy", "nointerrupt", "nomorph"},
        ["onenter"] = function(nFgugCikn)
            nFgugCikn["components"]["locomotor"]:Stop()
            nFgugCikn["AnimState"]:PlayAnimation("atk_leap_pre")
        end,
        ["events"] = {
            EventHandler(
                "combat_hh_knife",
                function(iFiUiCnKn, uFnunckKu)
                    iFiUiCnKn["sg"]:GoToState("hh_knife_aoe", uFnunckKu)
                end
            ),
            EventHandler(
                "animover",
                function(uFuufCuKf)
                    if uFuufCuKf["AnimState"]:AnimDone() then
                        if uFuufCuKf["AnimState"]:IsCurrentAnimation("atk_leap_pre") then
                            uFuufCuKf["AnimState"]:PlayAnimation("atk_leap_lag")
                            uFuufCuKf:PerformBufferedAction()
                        else
                            uFuufCuKf["sg"]:GoToState("idle")
                        end
                    end
                end
            )
        },
        ["onexit"] = function(nfuUicnKg)
        end
    }
)
local function kfnUgCgKg(nFgUkcikg)
    nFgUkcikg["sg"]["statemem"]["isphysicstoggle"] = (49 * 81 - 11 - 304 == 3654)
    nFgUkcikg["Physics"]:ClearCollisionMask()
    nFgUkcikg["Physics"]:CollidesWith(COLLISION["GROUND"])
end
local function nFnUgcfKi(kFuUiCckc)
    kFuUiCckc["sg"]["statemem"]["isphysicstoggle"] = nil
    kFuUiCckc["Physics"]:ClearCollisionMask()
    kFuUiCckc["Physics"]:CollidesWith(COLLISION["WORLD"])
    kFuUiCckc["Physics"]:CollidesWith(COLLISION["OBSTACLES"])
    kFuUiCckc["Physics"]:CollidesWith(COLLISION["SMALLOBSTACLES"])
    kFuUiCckc["Physics"]:CollidesWith(COLLISION["CHARACTERS"])
    kFuUiCckc["Physics"]:CollidesWith(COLLISION["GIANTS"])
end
AddStategraphState(
    "wilson",
    State {
        ["name"] = "hh_knife_aoe",
        ["tags"] = {"aoe", "doing", "busy", "nointerrupt", "nopredict", "nomorph"},
        ["onenter"] = function(iffucCkKf, ufgUccuKk)
            if
                ufgUccuKk ~= nil and ufgUccuKk["targetpos"] ~= nil and ufgUccuKk["weapon"] ~= nil and
                    iffucCkKf["AnimState"]:IsCurrentAnimation("atk_leap_lag")
             then
                kfnUgCgKg(iffucCkKf)
                iffucCkKf["Transform"]:SetEightFaced()
                iffucCkKf["AnimState"]:PlayAnimation("atk_leap")
                iffucCkKf["SoundEmitter"]:PlaySound("dontstarve/common/deathpoof")
                iffucCkKf["sg"]["statemem"]["startingpos"] = iffucCkKf:GetPosition()
                iffucCkKf["sg"]["statemem"]["weapon"] = ufgUccuKk["weapon"]
                iffucCkKf["sg"]["statemem"]["targetpos"] = ufgUccuKk["targetpos"]
                iffucCkKf["sg"]["statemem"]["flash"] = 0
                if
                    iffucCkKf["sg"]["statemem"]["startingpos"]["x"] ~= ufgUccuKk["targetpos"]["x"] or
                        iffucCkKf["sg"]["statemem"]["startingpos"]["z"] ~= ufgUccuKk["targetpos"]["z"]
                 then
                    iffucCkKf:ForceFacePoint(ufgUccuKk["targetpos"]:Get())
                    iffucCkKf["Physics"]:SetMotorVel(
                        math["sqrt"](
                            distsq(
                                iffucCkKf["sg"]["statemem"]["startingpos"]["x"],
                                iffucCkKf["sg"]["statemem"]["startingpos"]["z"],
                                ufgUccuKk["targetpos"]["x"],
                                ufgUccuKk["targetpos"]["z"]
                            )
                        ) /
                            (12 * FRAMES),
                        0,
                        0
                    )
                end
                return
            end
            iffucCkKf["sg"]:GoToState("idle", (330 - 60 + 92 - 333 == 29))
        end,
        ["onupdate"] = function(fFcUkCnkn)
            if fFcUkCnkn["sg"]["statemem"]["flash"] and fFcUkCnkn["sg"]["statemem"]["flash"] > 0 then
                fFcUkCnkn["sg"]["statemem"]["flash"] = math["max"](0, fFcUkCnkn["sg"]["statemem"]["flash"] - 0.1)
                local nffuncuki = math["min"](1, fFcUkCnkn["sg"]["statemem"]["flash"])
                fFcUkCnkn["components"]["colouradder"]:PushColour("leap", nffuncuki, nffuncuki, 0, 0)
            end
        end,
        ["timeline"] = {
            TimeEvent(
                10 * FRAMES,
                function(ifuUgciKn)
                    if ifuUgciKn["sg"]["statemem"]["flash"] then
                        ifuUgciKn["components"]["colouradder"]:PushColour("leap", 0.1, 0.1, 0, 0)
                    end
                end
            ),
            TimeEvent(
                11 * FRAMES,
                function(cFuuncfku)
                    if cFuuncfku["sg"]["statemem"]["flash"] then
                        cFuuncfku["components"]["colouradder"]:PushColour("leap", 0.2, 0.2, 0, 0)
                    end
                end
            ),
            TimeEvent(
                12 * FRAMES,
                function(nfguiccKu)
                    if nfguiccKu["sg"]["statemem"]["flash"] then
                        nfguiccKu["components"]["colouradder"]:PushColour("leap", 0.4, 0.4, 0, 0)
                    end
                    nFnUgcfKi(nfguiccKu)
                    nfguiccKu["Physics"]:Stop()
                    nfguiccKu["Physics"]:SetMotorVel(0, 0, 0)
                    nfguiccKu["Physics"]:Teleport(
                        nfguiccKu["sg"]["statemem"]["targetpos"]["x"],
                        0,
                        nfguiccKu["sg"]["statemem"]["targetpos"]["z"]
                    )
                end
            ),
            TimeEvent(
                13 * FRAMES,
                function(gfkuiCikn)
                    ShakeAllCameras(CAMERASHAKE["VERTICAL"], 0.7, 0.015, .8, gfkuiCikn, 20)
                    if gfkuiCikn["sg"]["statemem"]["flash"] then
                        gfkuiCikn["components"]["bloomer"]:PushBloom("leap", "shaders/anim.ksh", -2)
                        gfkuiCikn["components"]["colouradder"]:PushColour("leap", 1, 1, 0, 0)
                        gfkuiCikn["sg"]["statemem"]["flash"] = 1.3
                    end
                    gfkuiCikn["sg"]:RemoveStateTag("nointerrupt")
                    if gfkuiCikn["sg"]["statemem"]["weapon"]:IsValid() then
                    end
                end
            ),
            TimeEvent(
                25 * FRAMES,
                function(ifcuiCnKk)
                    if ifcuiCnKk["sg"]["statemem"]["flash"] then
                        ifcuiCnKk["components"]["bloomer"]:PopBloom("leap")
                    end
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animover",
                function(nfkukCcKu)
                    if nfkukCcKu["AnimState"]:AnimDone() then
                        nfkukCcKu["sg"]:GoToState("idle")
                    end
                end
            )
        },
        ["onexit"] = function(iFnUkcgkg)
            if iFnUkcgkg["sg"]["statemem"]["isphysicstoggle"] then
                nFnUgcfKi(iFnUkcgkg)
                iFnUkcgkg["Physics"]:Stop()
                iFnUkcgkg["Physics"]:SetMotorVel(0, 0, 0)
                local gFuufCcKc, cFnUkccKg, cFfucckKk = iFnUkcgkg["Transform"]:GetWorldPosition()
                if
                    TheWorld["Map"]:IsPassableAtPoint(gFuufCcKc, 0, cFfucckKk) and
                        not TheWorld["Map"]:IsGroundTargetBlocked(Vector3(gFuufCcKc, 0, cFfucckKk))
                 then
                    iFnUkcgkg["Physics"]:Teleport(gFuufCcKc, 0, cFfucckKk)
                else
                    iFnUkcgkg["Physics"]:Teleport(
                        iFnUkcgkg["sg"]["statemem"]["targetpos"]["x"],
                        0,
                        iFnUkcgkg["sg"]["statemem"]["targetpos"]["z"]
                    )
                end
            end
            iFnUkcgkg["Transform"]:SetFourFaced()
            if iFnUkcgkg["sg"]["statemem"]["flash"] then
                iFnUkcgkg["components"]["bloomer"]:PopBloom("leap")
                iFnUkcgkg["components"]["colouradder"]:PopColour("leap")
            end
        end
    }
)
AddStategraphState(
    "wilson_client",
    State {
        ["name"] = "hh_knife_aoe_start",
        ["tags"] = {"doing", "busy", "nointerrupt"},
        ["onenter"] = function(cFcugcnKg)
            cFcugcnKg["components"]["locomotor"]:Stop()
            cFcugcnKg["AnimState"]:PlayAnimation("atk_leap_pre")
            cFcugcnKg["AnimState"]:PushAnimation("atk_leap_lag", (489 - 224 + 443 * 134 == 59636))
            cFcugcnKg:PerformPreviewBufferedAction()
            cFcugcnKg["sg"]:SetTimeout(2)
        end,
        ["onupdate"] = function(iFfUnccKc)
            if iFfUnccKc:HasTag("doing") then
                if iFfUnccKc["entity"]:FlattenMovementPrediction() then
                    iFfUnccKc["sg"]:GoToState("idle", "noanim")
                end
            elseif iFfUnccKc["bufferedaction"] == nil then
                iFfUnccKc["sg"]:GoToState("idle")
            end
        end,
        ["ontimeout"] = function(fFnufCfkk)
            fFnufCfkk:ClearBufferedAction()
            fFnufCfkk["sg"]:GoToState("idle")
        end
    }
)
local function cfiukCgkf(uFnUcCcKk)
    if uFnUcCcKk["sg"]["statemem"]["targetfx"]["KillFX"] ~= nil then
        uFnUcCcKk["sg"]["statemem"]["targetfx"]:RemoveEventCallback("onremove", cfiukCgkf, uFnUcCcKk)
        uFnUcCcKk["sg"]["statemem"]["targetfx"]:KillFX()
    else
        uFnUcCcKk["sg"]["statemem"]["targetfx"]:Remove()
    end
end
AddStategraphState(
    "wilson",
    State {
        ["name"] = "hh_daogam3",
        ["tags"] = {"doing", "busy", "canrotate"},
        ["onenter"] = function(fFnuccikf, kfcUuCkKg)
            if fFnuccikf["components"]["playercontroller"] ~= nil then
                fFnuccikf["components"]["playercontroller"]:Enable((190 - 79 * 3 * 102 * 428 == -10346280))
            end
            fFnuccikf["AnimState"]:PlayAnimation("staff_pre")
            fFnuccikf["AnimState"]:PushAnimation("staff", (277 - 94 * 126 == -11562))
            fFnuccikf["components"]["locomotor"]:Stop()
            local nfcuncukn = fFnuccikf["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
            local cFgukCkKk = nfcuncukn ~= nil and nfcuncukn["fxcolour"] or {1, 1, 1}
            fFnuccikf["sg"]["statemem"]["stafffx"] =
                SpawnPrefab(fFnuccikf["components"]["rider"]:IsRiding() and "staffcastfx_mount" or "staffcastfx")
            fFnuccikf["sg"]["statemem"]["stafffx"]["entity"]:SetParent(fFnuccikf["entity"])
            fFnuccikf["sg"]["statemem"]["stafffx"]:SetUp(cFgukCkKk)
            fFnuccikf["sg"]["statemem"]["stafflight"] = SpawnPrefab("staff_castinglight")
            fFnuccikf["sg"]["statemem"]["stafflight"]["Transform"]:SetPosition(
                fFnuccikf["Transform"]:GetWorldPosition()
            )
            fFnuccikf["sg"]["statemem"]["stafflight"]:SetUp(cFgukCkKk, 1.9, 0.33)
            if nfcuncukn ~= nil and nfcuncukn["components"]["aoetargeting"] ~= nil then
                local cFfUfCuKu = fFnuccikf:GetBufferedAction()
                if cFfUfCuKu ~= nil then
                    fFnuccikf["sg"]["statemem"]["targetfx"] =
                        nfcuncukn["components"]["aoetargeting"]:SpawnTargetFXAt(cFfUfCuKu:GetDynamicActionPoint())
                    if fFnuccikf["sg"]["statemem"]["targetfx"] ~= nil then
                        fFnuccikf["sg"]["statemem"]["targetfx"]:ListenForEvent("onremove", cfiukCgkf, fFnuccikf)
                    end
                end
            end
            if nfcuncukn ~= nil then
                fFnuccikf["sg"]["statemem"]["castsound"] =
                    nfcuncukn["skin_castsound"] or nfcuncukn["castsound"] or "dontstarve/wilson/use_gemstaff"
            else
                fFnuccikf["sg"]["statemem"]["castsound"] = "dontstarve/wilson/use_gemstaff"
            end
        end,
        ["timeline"] = {
            TimeEvent(
                13 * FRAMES,
                function(gfnuicikf)
                    gfnuicikf["SoundEmitter"]:PlaySound(gfnuicikf["sg"]["statemem"]["castsound"])
                end
            ),
            TimeEvent(
                25 * FRAMES,
                function(cFfucckKi)
                    cFfucckKi:PerformBufferedAction()
                end
            ),
            TimeEvent(
                53 * FRAMES,
                function(fFnUuCnKn)
                    if fFnUuCnKn["sg"]["statemem"]["targetfx"] ~= nil then
                        if fFnUuCnKn["sg"]["statemem"]["targetfx"]:IsValid() then
                            cfiukCgkf(fFnUuCnKn)
                        end
                        fFnUuCnKn["sg"]["statemem"]["targetfx"] = nil
                    end
                    fFnUuCnKn["sg"]["statemem"]["stafffx"] = nil
                    fFnUuCnKn["sg"]["statemem"]["stafflight"] = nil
                end
            ),
            TimeEvent(
                69 * FRAMES,
                function(uFnugccKn)
                    uFnugccKn["sg"]:RemoveStateTag("busy")
                    if uFnugccKn["components"]["playercontroller"] ~= nil then
                        uFnugccKn["components"]["playercontroller"]:Enable((389 + 41 * 241 + 458 - 78 ~= 10659))
                    end
                end
            )
        },
        ["events"] = {
            EventHandler(
                "animqueueover",
                function(ifgukCukf)
                    if ifgukCukf["AnimState"]:AnimDone() then
                        ifgukCukf["sg"]:GoToState("idle")
                    end
                end
            )
        },
        ["onexit"] = function(nfnUiCnKg)
            if nfnUiCnKg["components"]["playercontroller"] ~= nil then
                nfnUiCnKg["components"]["playercontroller"]:Enable((66 + 40 + 174 * 196 + 403 == 34613))
            end
            if nfnUiCnKg["sg"]["statemem"]["stafffx"] ~= nil and nfnUiCnKg["sg"]["statemem"]["stafffx"]:IsValid() then
                nfnUiCnKg["sg"]["statemem"]["stafffx"]:Remove()
            end
            if nfnUiCnKg["sg"]["statemem"]["stafflight"] ~= nil and nfnUiCnKg["sg"]["statemem"]["stafflight"]:IsValid() then
                nfnUiCnKg["sg"]["statemem"]["stafflight"]:Remove()
            end
            if nfnUiCnKg["sg"]["statemem"]["targetfx"] ~= nil and nfnUiCnKg["sg"]["statemem"]["targetfx"]:IsValid() then
                cfiukCgkf(nfnUiCnKg)
            end
        end
    }
)
AddStategraphState(
    "wilson_client",
    State {
        ["name"] = "hh_daogam3",
        ["tags"] = {"doing", "busy", "canrotate"},
        ["server_states"] = {"hh_daogam3"},
        ["onenter"] = function(nfcuncikf)
            nfcuncikf["components"]["locomotor"]:Stop()
            nfcuncikf["AnimState"]:PlayAnimation("staff_pre")
            nfcuncikf["AnimState"]:PushAnimation("staff_lag", (72 - 330 * 84 * 440 ~= -12196728))
            nfcuncikf:PerformPreviewBufferedAction()
            nfcuncikf["sg"]:SetTimeout(2)
        end,
        ["onupdate"] = function(cFgucckKu)
            if cFgucckKu["sg"]:ServerStateMatches() then
                if cFgucckKu["entity"]:FlattenMovementPrediction() then
                    cFgucckKu["sg"]:GoToState("idle", "noanim")
                end
            elseif cFgucckKu["bufferedaction"] == nil then
                cFgucckKu["sg"]:GoToState("idle")
            end
        end,
        ["ontimeout"] = function(ifuuucgku)
            ifuuucgku:ClearBufferedAction()
            ifuuucgku["sg"]:GoToState("idle")
        end
    }
)

-- Kẻ Thống Trị vẫn đi qua native CASTAOE/aoespell, nhưng commit action ngay
-- khi StateGraph nhận được proxy hh_ruler_caster. State chỉ tồn tại một frame
-- để server/client có điểm đồng bộ, không tạo cast wind-up cho người chơi.
AddStategraphState(
    "wilson",
    State {
        ["name"] = "hh_ruler_cast_instant",
        ["tags"] = {"doing", "busy", "canrotate"},
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst:PerformBufferedAction()
            inst["sg"]:SetTimeout(FRAMES)
        end,
        ["ontimeout"] = function(inst)
            inst["sg"]:GoToState("idle", "noanim")
        end,
    }
)

AddStategraphState(
    "wilson_client",
    State {
        ["name"] = "hh_ruler_cast_instant",
        ["tags"] = {"doing", "busy", "canrotate"},
        ["server_states"] = {"hh_ruler_cast_instant"},
        ["onenter"] = function(inst)
            inst["components"]["locomotor"]:Stop()
            inst:PerformPreviewBufferedAction()
            inst["sg"]:SetTimeout(2)
        end,
        ["onupdate"] = function(inst)
            if inst["sg"]:ServerStateMatches() then
                if inst["entity"]:FlattenMovementPrediction() then
                    inst["sg"]:GoToState("idle", "noanim")
                end
            elseif inst["bufferedaction"] == nil then
                inst["sg"]:GoToState("idle", "noanim")
            end
        end,
        ["ontimeout"] = function(inst)
            inst:ClearBufferedAction()
            inst["sg"]:GoToState("idle", "noanim")
        end,
    }
)

local function gFguiCiku(ifuUiCkKf, ufgUiCnKf, cFcuccnKf)
    local kfiUfCkKi = ifuUiCkKf["actionhandlers"][ufgUiCnKf]["deststate"]
    ifuUiCkKf["actionhandlers"][ufgUiCnKf]["deststate"] = function(gFiunCcKn, ffcugcfkc)
        if ufgUiCnKf == ACTIONS["PICK"] and nFfuiccKu:IsHHType(ffcugcfkc, "table") then
            local iFkukccKn = ffcugcfkc["target"]
            if nFfuiccKu:IsHHType(iFkukccKn, "table") and iFkukccKn["prefab"] == "junk_pile_big" then
                return kfiUfCkKi(gFiunCcKn, ffcugcfkc)
            end
        end
        local ifguncgKn = "hh_fast_sg"
        if ufgUiCnKf == ACTIONS["BUILD"] or ufgUiCnKf == ACTIONS["HARVEST"] then
            ifguncgKn = "doshortaction"
        end
        if cFcuccnKf then
            if
                nFfuiccKu:HasComponents(gFiunCcKn, "hh_player") and
                    gFiunCcKn["components"]["hh_player"]:HasSpecialEffect("fast_act")
             then
                return ifguncgKn
            end
        else
            if nFfuiccKu:HasComponents(gFiunCcKn, "hh_client") then
                local cFiunCfkn = nFfuiccKu:GetClientValue(gFiunCcKn, "hh_fast_act")
                if cFiunCfkn then
                    return ifguncgKn
                end
            end
        end
        return kfiUfCkKi(gFiunCcKn, ffcugcfkc)
    end
end
local function ifiUfcukn(ffnUucgKg, uFfUcCcKk, nFnugcnKu, nFuUuccKc)
    if not nFfuiccKu:IsHHType(nFnugcnKu, "table") then
        return
    end
    local ifuUuccKc = ffnUucgKg["actionhandlers"][uFfUcCcKk]["deststate"]
    ffnUucgKg["actionhandlers"][uFfUcCcKk]["deststate"] = function(nfnufCkkg, nFnuiCkKn)
        if
            nFnuiCkKn ~= nil and nFnuiCkKn["invobject"] ~= nil and
                nFnuiCkKn["invobject"]:HasTag("hh_ruler_caster")
         then
            return "hh_ruler_cast_instant"
        end
        local cfcucCikf = nil
        local ffcufcfKk = (422 - 194 - 192 ~= 36)
        if nFuUuccKc then
            cfcucCikf = nfnufCkkg["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
            ffcufcfKk = nfnufCkkg["components"]["rider"] ~= nil and nfnufCkkg["components"]["rider"]:IsRiding()
        else
            cfcucCikf = nfnufCkkg["replica"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
            ffcufcfKk = nfnufCkkg["replica"]["rider"] ~= nil and nfnufCkkg["replica"]["rider"]:IsRiding()
        end
        if
            cfcucCikf and not ffcufcfKk and cfcucCikf["prefab"] and
                nFfuiccKu:IsHHType(nFnugcnKu[cfcucCikf["prefab"]], "string")
         then
            return nFnugcnKu[cfcucCikf["prefab"]]
        end
        return ifuUuccKc(nfnufCkkg, nFnuiCkKn)
    end
end
local ufkUccckn = {["hh_daogam3"] = "hh_daogam3"}

STRINGS["ACTIONS"]["CASTAOE"][string["upper"]("hh_daogam3")] = "Thập Ảnh Xuyên Kích"


STRINGS["ACTIONS"]["CASTAOE"][string["upper"]("hh_daogam")] = "Thiên Phạt Quỷ Vương"

STRINGS["ACTIONS"]["CASTAOE"][string["upper"]("hh_daogam5")] = "Ảnh Bộ Nhất Tuyến"



STRINGS["ACTIONS"]["CASTAOE"][string["upper"]("hh_daogam4")] = "Hỏa Ngục Tinh Vũ"
local function kfguccnKc(nFkuucnkn)
    return math["floor"](nFkuucnkn + 0.5)
end
local function nfkuccfku(cfgUicgki)
    if not nFfuiccKu:IsHHType(cfgUicgki["timeline"], "table") then
        return
    end
    for iFnukcukg, cffUgCiKc in pairs(cfgUicgki["timeline"]) do
        cffUgCiKc["hh_max_time"] = kfguccnKc(cffUgCiKc["time"] / FRAMES)
    end
    local cFkUgckkg = cfgUicgki["onenter"]
    cfgUicgki["onenter"] = function(gfkUuciKi, ...)
        if cFkUgckkg then
            cFkUgckkg(gfkUuciKi, ...)
        end
        local kFnucCfKi = nFfuiccKu:GetWeaponAtkSpeed(gfkUuciKi)
        local fFcUcckkk = gfkUuciKi["sg"]["timeout"]
        gfkUuciKi["AnimState"]:SetDeltaTimeMultiplier(kFnucCfKi)
        for gfnukcnKf, uFiuncnKi in pairs(cfgUicgki["timeline"]) do
            uFiuncnKi["time"] = kfguccnKc(uFiuncnKi["hh_max_time"] / kFnucCfKi) * FRAMES
        end
        if nFfuiccKu:HasComponents(gfkUuciKi, "combat") then
            local nfkuccfKu = gfkUuciKi["components"]["combat"]
            if not gfkUuciKi["hh_new_min_atk_period"] then
                gfkUuciKi["hh_new_min_atk_period"] =
                    nfkuccfKu["min_attack_period"] or gfkUuciKi:HasTag("player") and 0.5 or 4
            end
            nfkuccfKu["min_attack_period"] = gfkUuciKi["hh_new_min_atk_period"] / kFnucCfKi
        end
        if nFfuiccKu:IsHHType(fFcUcckkk, "number") and kFnucCfKi > 1 then
            gfkUuciKi["sg"]:SetTimeout(fFcUcckkk / (kFnucCfKi * 1))
        end
    end
    local nfguiCiKc = cfgUicgki["onexit"]
    cfgUicgki["onexit"] = function(kfcugCuKi, ...)
        if nfguiCiKc then
            nfguiCiKc(kfcugCuKi, ...)
        end
        kfcugCuKi["sg"]:RemoveStateTag("abouttoattack")
        kfcugCuKi["sg"]:RemoveStateTag("attack")
        kfcugCuKi["AnimState"]:SetDeltaTimeMultiplier(1)
    end
end
local gFkUcciKk = {["attack"] = nfkuccfku, ["mcwattack"] = nfkuccfku}
local function gFkunCukk(nfkunCkKi, kfuUnccKg, nFuUkCnKc)
    if not nfkunCkKi or not nfkunCkKi["events"] then
        return
    end
    local gfiugCikg = nfkunCkKi["events"][kfuUnccKg]
    if gfiugCikg and gfiugCikg["fn"] then
        local iFnufCkku = gfiugCikg["fn"]
        local kfcUkCkkk = nFuUkCnKc
        gfiugCikg["fn"] = function(nFfufcgkn, ...)
            if
                nFfuiccKu:HasComponents(nFfufcgkn, "hh_player") and
                    nFfufcgkn["components"]["hh_player"]:HasSpecialEffect(kfcUkCkkk)
             then
                return
            end
            if iFnufCkku then
                iFnufCkku(nFfufcgkn, ...)
            end
        end
    end
end
AddStategraphPostInit(
    "wilson",
    function(cFguiciKc)
        local kFnUucuku = cFguiciKc["actionhandlers"][ACTIONS["ATTACK"]]["deststate"]
        cFguiciKc["actionhandlers"][ACTIONS["ATTACK"]]["deststate"] = function(fFiUnCfKi, gfuugCukk)
            if
                fFiUnCfKi and fFiUnCfKi["components"] and fFiUnCfKi["components"]["inventory"] and
                    not (fFiUnCfKi["components"]["rider"] ~= nil and fFiUnCfKi["components"]["rider"]:IsRiding())
             then
                local gfiugcfkf = fFiUnCfKi["components"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
                if gfiugcfkf then
                    if gfiugcfkf:HasTag("hh_fast_atk") then
                        return "hh_fast_attack_pre"
                    end
                end
            end
            return kFnUucuku(fFiUnCfKi, gfuugCukk)
        end
        if TUNING["HH_ATK_SPEED_BOOL"] then
            for nFcUfcgKk, uFnUkCkKk in pairs(gFkUcciKk) do
                if nFfuiccKu:IsHHType(uFnUkCkKk, "function") and cFguiciKc["states"] and cFguiciKc["states"][nFcUfcgKk] then
                    uFnUkCkKk(cFguiciKc["states"][nFcUfcgKk])
                end
            end
        end
        gFguiCiku(
            cFguiciKc,
            ACTIONS["BUILD"],
            (true and not false or not false and not false and not true and false or not true or not false or true or
                not true and not false)
        )
        gFguiCiku(cFguiciKc, ACTIONS["PICK"], (386 + 384 * 388 == 149378))
        gFguiCiku(cFguiciKc, ACTIONS["COOK"], (423 * 219 - 281 + 414 == 92770))
        gFguiCiku(cFguiciKc, ACTIONS["GIVE"], (242 - 352 - 108 ~= -210))
        gFguiCiku(cFguiciKc, ACTIONS["HARVEST"], (266 * 460 - 65 * 56 * 213 ~= -652953))
        ifiUfcukn(cFguiciKc, ACTIONS["CASTAOE"], ufkUccckn, (202 + 97 - 114 - 327 * 385 == -125710))
        gFkunCukk(cFguiciKc, "knockedout", "immunitySleep")
        gFkunCukk(cFguiciKc, "yawn", "immunitySleep")
    end
)
AddStategraphPostInit(
    "wilson_client",
    function(uFuUfciku)
        local cffUkcckk = uFuUfciku["actionhandlers"][ACTIONS["ATTACK"]]["deststate"]
        uFuUfciku["actionhandlers"][ACTIONS["ATTACK"]]["deststate"] = function(ffgUnCckn, iFiuuckKg)
            if
                ffgUnCckn and ffgUnCckn["replica"] and ffgUnCckn["replica"]["inventory"] and
                    not (ffgUnCckn["replica"]["rider"] ~= nil and ffgUnCckn["replica"]["rider"]:IsRiding())
             then
                local cFkufckKc = ffgUnCckn["replica"]["inventory"]:GetEquippedItem(EQUIPSLOTS["HANDS"])
                if cFkufckKc then
                    if cFkufckKc:HasTag("hh_fast_atk") then
                        return "hh_fast_attack_pre"
                    end
                end
            end
            return cffUkcckk(ffgUnCckn, iFiuuckKg)
        end
        if TUNING["HH_ATK_SPEED_BOOL"] then
            for cfuufCukc, gfnuucgku in pairs(gFkUcciKk) do
                if nFfuiccKu:IsHHType(gfnuucgku, "function") and uFuUfciku["states"] and uFuUfciku["states"][cfuufCukc] then
                    gfnuucgku(uFuUfciku["states"][cfuufCukc])
                end
            end
        end
        gFguiCiku(uFuUfciku, ACTIONS["BUILD"], (336 + 302 * 175 ~= 53186))
        gFguiCiku(uFuUfciku, ACTIONS["PICK"], (28 * 250 - 496 + 496 ~= 7000))
        gFguiCiku(uFuUfciku, ACTIONS["COOK"], (214 + 486 * 250 - 467 * 86 == 81559))
        gFguiCiku(uFuUfciku, ACTIONS["GIVE"], (298 + 24 + 72 - 111 * 243 == -26573))
        gFguiCiku(uFuUfciku, ACTIONS["HARVEST"], (493 * 352 - 30 ~= 173506))
        ifiUfcukn(uFuUfciku, ACTIONS["CASTAOE"], ufkUccckn, (60 + 215 - 344 == -64))
    end
)

-- Nghi thức trích xuất bóng ma: phát đủ từng animation rồi mới chuyển state.
local HH_SHADOW_EXTRACT_COLOUR = {0.16, 0.01, 0.22}
local HH_SHADOW_EXTRACT_LOOP_COUNT = 9
local HH_SHADOW_RING_RADII = {4, 5, 6, 7, 8}

local function HHShadowExtractCancel(inst, data)
    if data ~= nil and not data.committed and not data.finished and data.oncancel ~= nil then
        data.oncancel(inst, data)
    end
end

local function HHShadowExtractSpawnRing(inst, radius)
    if inst == nil or not inst:IsValid() or
        (inst.components.health ~= nil and inst.components.health:IsDead()) then
        return
    end

    for i = 1, 16 do
        local angle = (i - 1) * (2 * PI / 16)
        local fx = SpawnPrefab("shadow_despawn")
        if fx ~= nil then
            fx.entity:SetParent(inst.entity)
            fx.Transform:SetPosition(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            fx.AnimState:SetMultColour(
                HH_SHADOW_EXTRACT_COLOUR[1],
                HH_SHADOW_EXTRACT_COLOUR[2],
                HH_SHADOW_EXTRACT_COLOUR[3],
                1
            )
        end
    end
end

local function HHShadowExtractStartRings(inst)
    if inst._hh_shadow_ring_tasks ~= nil then
        for _, task in ipairs(inst._hh_shadow_ring_tasks) do
            task:Cancel()
        end
    end

    inst._hh_shadow_ring_tasks = {}
    for index, radius in ipairs(HH_SHADOW_RING_RADII) do
        local task = inst:DoTaskInTime((index - 1) * 0.5, function(player)
            HHShadowExtractSpawnRing(player, radius)
        end)
        table.insert(inst._hh_shadow_ring_tasks, task)
    end
end

AddStategraphState(
    "wilson",
    State {
        name = "hh_shadow_extract_pre",
        tags = {"doing", "busy", "nopredict", "nomorph", "nodangle"},
        onenter = function(inst, data)
            if data == nil then
                inst.sg:GoToState("idle")
                return
            end
            inst.components.locomotor:Stop()
            inst.sg.statemem.data = data
            inst.AnimState:PlayAnimation("channel_pre")
        end,
        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local data = inst.sg.statemem.data
                    inst.sg.statemem.continue = true
                    inst.sg:GoToState("hh_shadow_extract_loop", data)
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.continue then
                HHShadowExtractCancel(inst, inst.sg.statemem.data)
            end
        end,
    }
)

AddStategraphState(
    "wilson",
    State {
        name = "hh_shadow_extract_loop",
        tags = {"doing", "busy", "nopredict", "nomorph", "nodangle"},
        onenter = function(inst, data)
            if data == nil then
                inst.sg:GoToState("idle")
                return
            end
            inst.components.locomotor:Stop()
            inst.sg.statemem.data = data
            inst.sg.statemem.loops = 1
            inst.AnimState:PlayAnimation("channel_loop")
        end,
        events = {
            EventHandler("animover", function(inst)
                if not inst.AnimState:AnimDone() then
                    return
                end
                if inst.sg.statemem.loops < HH_SHADOW_EXTRACT_LOOP_COUNT then
                    inst.sg.statemem.loops = inst.sg.statemem.loops + 1
                    inst.AnimState:PlayAnimation("channel_loop")
                else
                    local data = inst.sg.statemem.data
                    inst.sg.statemem.continue = true
                    inst.sg:GoToState("hh_shadow_extract_pst", data)
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.continue then
                HHShadowExtractCancel(inst, inst.sg.statemem.data)
            end
        end,
    }
)

AddStategraphState(
    "wilson",
    State {
        name = "hh_shadow_extract_pst",
        tags = {"doing", "busy", "nopredict", "nomorph", "nodangle"},
        onenter = function(inst, data)
            if data == nil then
                inst.sg:GoToState("idle")
                return
            end
            inst.components.locomotor:Stop()
            inst.sg.statemem.data = data
            inst.AnimState:PlayAnimation("channel_pst")
        end,
        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local data = inst.sg.statemem.data
                    inst.sg.statemem.continue = true
                    if data ~= nil and data.oncomplete ~= nil then
                        data.oncomplete(inst, data)
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.continue then
                HHShadowExtractCancel(inst, inst.sg.statemem.data)
            end
        end,
    }
)

AddStategraphState(
    "wilson",
    State {
        name = "hh_shadow_extract_success",
        tags = {"doing", "busy", "nopredict", "nomorph", "nodangle"},
        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.sg.statemem.data = data
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)

            local fxprefab = inst.components.rider ~= nil and inst.components.rider:IsRiding()
                and "staffcastfx_mount" or "staffcastfx"
            local stafffx = SpawnPrefab(fxprefab)
            if stafffx ~= nil then
                stafffx.entity:SetParent(inst.entity)
                if stafffx.SetUp ~= nil then
                    stafffx:SetUp(HH_SHADOW_EXTRACT_COLOUR)
                end
                stafffx.AnimState:SetMultColour(
                    HH_SHADOW_EXTRACT_COLOUR[1],
                    HH_SHADOW_EXTRACT_COLOUR[2],
                    HH_SHADOW_EXTRACT_COLOUR[3],
                    1
                )
                inst.sg.statemem.stafffx = stafffx
            end

            local stafflight = SpawnPrefab("staff_castinglight")
            if stafflight ~= nil then
                stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                stafflight:SetUp(HH_SHADOW_EXTRACT_COLOUR, 1.9, 0.33)
                inst.sg.statemem.stafflight = stafflight
            end
        end,
        timeline = {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/staffteleport")
            end),
            TimeEvent(53 * FRAMES, function(inst)
                -- Vanilla để các prefab tự kết thúc sau mốc cast thay vì xóa chúng khi rời state.
                inst.sg.statemem.stafffx = nil
                inst.sg.statemem.stafflight = nil
            end),
            TimeEvent(70 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
            end),
        },
        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    local data = inst.sg.statemem.data
                    inst.sg.statemem.completed = true
                    inst.sg:GoToState("idle")
                    inst:DoTaskInTime(0, function(player)
                        if data ~= nil and data.oncommit ~= nil and data.oncommit(player, data) then
                            HHShadowExtractStartRings(player)
                        end
                    end)
                end
            end),
        },
        onexit = function(inst)
            if not inst.sg.statemem.completed then
                HHShadowExtractCancel(inst, inst.sg.statemem.data)
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    }
)
