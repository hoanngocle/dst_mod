local env = env
GLOBAL.setfenv(1, GLOBAL)

local function hit_recovery_delay(inst, delay, max_hitreacts, skip_cooldown_fn)
    local on_cooldown = false
    if (inst._last_hitreact_time ~= nil and inst._last_hitreact_time + (delay or inst.hit_recovery or TUNING.DEFAULT_HIT_RECOVERY) >= GetTime()) then 
        max_hitreacts = max_hitreacts or inst._max_hitreacts
        if max_hitreacts then
            if inst._hitreact_count == nil then
                inst._hitreact_count = 2
                return false
            elseif inst._hitreact_count < max_hitreacts then
                inst._hitreact_count = inst._hitreact_count + 1
                return false
            end
        end

        skip_cooldown_fn = skip_cooldown_fn or inst._hitreact_skip_cooldown_fn
        if skip_cooldown_fn ~= nil then
            on_cooldown = not skip_cooldown_fn(inst, inst._last_hitreact_time, delay)
        elseif inst.components.combat ~= nil then
            on_cooldown = not (inst.components.combat:InCooldown() and inst.sg:HasStateTag("idle")) 
        else
            on_cooldown = true
        end
    end

    if inst._hitreact_count ~= nil and not on_cooldown then
        inst._hitreact_count = 1
    end
    return on_cooldown
end

env.AddStategraphPostInit("pig", function(sg)
    local _OldDoAttack = sg.events["doattack"]
    sg.events["doattack"] = EventHandler("doattack", function(inst, data)
        if inst:HasTag("hh_dungeon_mob") then
            if inst:HasTag("pigattacker") and data.target:HasTag("pigattacker") and not data.target:HasTag("werepig") or inst:HasTag("manrabbit") and data.target:HasTag("manrabbit") then
                inst.sg:GoToState("refuse", data.target)
                inst.components.combat:SetTarget(nil)
            else
                local nstate = "attack"
                if inst.sg:HasStateTag("charging") then
                    nstate = "charge_attack"
                end
                if inst.components.health and not inst.components.health:IsDead()
                    and not inst.sg:HasStateTag("busy") then
                    inst.sg:GoToState(nstate)
                end
            end
        else
            if _OldDoAttack and _OldDoAttack.fn then
                _OldDoAttack.fn(inst, data)
            end
        end
    end)

    local _OldAttacked = sg.events["attacked"]
    sg.events["attacked"] = EventHandler("attacked", function(inst, data)
        if inst:HasTag("hh_dungeon_mob") then
            if inst:HasTag("pigattacker") and not inst:HasTag("werepig") and inst.components.health ~= nil and not inst.components.health:IsDead() and not inst.sg:HasStateTag("counter") then
                if inst.counter ~= nil then
                    inst.counter = inst.counter + 1
                    if inst.countertask ~= nil then
                        inst.countertask:Cancel()
                        inst.countertask = nil
                    end
                else
                    inst.counter = 1
                end

                inst.countertask = inst:DoTaskInTime(10, function(inst) inst.counter = 0 end)

                if inst.counter ~= nil and inst.counter >= math.random(3, 4) then
                    if inst.countertask ~= nil then
                        inst.countertask:Cancel()
                        inst.countertask = nil
                    end
                    inst.counter = 0
                    inst.sg:GoToState("counterattack_pre")
                    return
                end
            end

            if inst.components.health ~= nil and not inst.components.health:IsDead()
                and not hit_recovery_delay(inst)
                and (not inst.sg:HasStateTag("busy")
                    or inst.sg:HasStateTag("caninterrupt")
                    or inst.sg:HasStateTag("frozen")) then
                        inst.sg:GoToState("hit")
            end 
        else
            if _OldAttacked and _OldAttacked.fn then
                _OldAttacked.fn(inst, data)
            end
        end
    end)

    -- ADD STATES
    local states = {
        State {
            name = "counterattack_pre",
            tags = { "attack", "busy", "counter" },

            onenter = function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
                inst.components.combat:StartAttack()
                inst.Physics:Stop()
                inst.sg:SetTimeout(0.5)
                inst.AnimState:PlayAnimation("idle_angry")
            end,

            ontimeout = function(inst)
                inst.sg:GoToState("counterattack")
            end,

            events =
            {
                EventHandler("animover", function(inst)
                    inst.sg:GoToState("counterattack")
                end),
            },
        },

        State {
            name = "counterattack",
            tags = { "attack", "busy", "counter" },

            onenter = function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/pig/attack")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
                inst.components.combat:StartAttack()
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("counter_atk")
            end,

            timeline =
            {
                TimeEvent(9 * FRAMES, function(inst)
                    local target = inst.components.combat.target

                    if target ~= nil and distsq(target:GetPosition(), inst:GetPosition()) <= inst.components.combat:CalcAttackRangeSq(target) then
                        target.components.combat:GetAttacked(inst, 33)

                        if target ~= nil and target.components.inventory ~= nil and not target:HasTag("fat_gang") and not target:HasTag("foodknockbackimmune") and not (target.components.rider ~= nil and target.components.rider:IsRiding()) and
                            (target.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) == nil or not target.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY):HasTag("marble") and not target.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY):HasTag("knockback_protection")) then
                            target:PushEvent("knockback", { knocker = inst, radius = 150, strengthmult = 1 })
                        end
                    end

                    inst.sg:RemoveStateTag("attack")
                    inst.sg:RemoveStateTag("busy")
                    inst.sg:RemoveStateTag("counter")
                end),
            },

            events =
            {
                EventHandler("animover", function(inst)
                    inst.sg:GoToState("charge_pre")
                end),
            },
        },

        State {
            name = "charge_antic_pre",
            tags = { "attack", "busy", "moving", "charging", "busy", "atk_pre", "canrotate" },

            onenter = function(inst)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("paw_pre")
            end,

            events =
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("charge_antic_loop") end),
            },
        },

        State {
            name = "charge_antic_loop",
            tags = { "attack", "busy", "moving", "charging", "busy", "atk_pre", "canrotate" },

            onenter = function(inst)
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("paw_loop", true)
                inst.sg:SetTimeout(1.5)
            end,

            ontimeout = function(inst)
                inst.sg:GoToState("charge_pre")
                inst:PushEvent("attackstart")
            end,
        },

        State {
            name = "charge_pre",
            tags = { "busy", "charging", "moving", "running" },

            onenter = function(inst)
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("charge_pre")
            end,

            events =
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("charge_loop") end),
            },
        },

        State {
            name = "charge_loop",
            tags = { "charging", "moving", "running" },

            onenter = function(inst)
                inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED + 8
                inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED + 8

                inst.components.locomotor:WalkForward()
                inst.AnimState:PlayAnimation("charge_loop")
            end,

            onexit = function(inst)
                inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED
                inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED
            end,

            events =
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("charge_attack") end),
            },
        },

        State {
            name = "charge_pst",
            tags = { "canrotate", "idle" },

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("charge_pst")
            end,

            events =
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
            },
        },

        State {
            name = "charge_attack",
            tags = { "chargingattack" },

            onenter = function(inst)
                inst.components.combat:StartAttack()
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("charge_atk")
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/wild_boar/charge_attack")
            end,

            timeline =
            {
                TimeEvent(12 * FRAMES, function(inst)
                    inst.components.combat:DoAttack()
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
                end),
            },

            events =
            {
                EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
            },
        }
    }

    for k, v in pairs(states) do
        sg.states[v.name] = v
    end
end)

env.AddStategraphPostInit("spider", function(sg)
    local function SoundPath(inst, event)
        local creature = "spider"
        if inst:HasTag("spider_moon") then
            return "turnoftides/creatures/together/spider_moon/" .. event
        elseif inst:HasTag("spider_warrior") then
            creature = "spiderwarrior"
        elseif inst:HasTag("spider_hider") or inst:HasTag("spider_spitter") then
            creature = "cavespider"
        else
            creature = "spider"
        end
        return "dontstarve/creatures/" .. creature .. "/" .. event
    end

    local _OldAttackEvent = sg.events["doattack"] and sg.events["doattack"].fn
    if _OldAttackEvent then
        sg.events["doattack"] = EventHandler("doattack", function(inst, data, ...)
            if inst:HasTag("hh_dungeon_mob") then
                if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
                    if inst:HasTag("spider_regular") then
                        inst.sg:GoToState(data.target:IsValid() and not (inst:IsNear(data.target, TUNING.SPIDER_WARRIOR_MELEE_RANGE)
                            or (TUNING.REGSPIDERJUMP == false and inst:HasTag("spider_regular"))) and "warrior_attack" or "attack", data.target) 
                        return
                    end
                end
            end
            return _OldAttackEvent(inst, data, ...)
        end)
    end

    local _OldAttackedEvent = sg.events["attacked"] and sg.events["attacked"].fn
    if _OldAttackedEvent then
        sg.events["attacked"] = EventHandler("attacked", function(inst, ...)
            if inst:HasTag("hh_dungeon_mob") then
                if not inst.components.health:IsDead() and inst:HasTag("spider_warrior") then
                    if not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("evade") then
                        if inst:HasTag("spider_warrior") and not inst:HasTag("trapdoorspider") and
                            inst.components.combat.target ~= nil then
                            inst.sg:GoToState("evade_loop")
                            return
                        end
                    end
                end
            end
            return _OldAttackedEvent(inst, ...)
        end)
    end

    local states = {
        State {
            name = "shield",
            tags = { "busy", "shield" },
            onenter = function(inst)
                if inst.components.health then
                    inst.components.health:SetAbsorptionAmount(TUNING.SPIDER_HIDER_SHELL_ABSORB)
                end
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("hide")
                inst.AnimState:PushAnimation("hide_loop")
                if inst.components.workable ~= nil then
                    inst.components.workable:SetWorkLeft(1)
                end
                inst:AddTag("hiding")
            end,
            onexit = function(inst)
                if inst.components.health then
                    inst.components.health:SetAbsorptionAmount(0)
                end
                if inst.components.workable ~= nil then
                    inst.components.workable:SetWorkLeft(0)
                end
                inst:RemoveTag("hiding")
            end,
        },
        State {
            name = "evade",
            tags = { "busy", "evade", "no_stun" },
            onenter = function(inst)
                inst.components.locomotor:Stop()
            end,
            events = {
                EventHandler("animover", function(inst)
                    if inst.components.combat.target ~= nil then
                        inst.sg:GoToState("evade_loop")
                    else
                        inst.sg:GoToState("hit")
                    end
                end),
            },
        },
        State {
            name = "evade_loop",
            tags = { "busy", "evade", "no_stun" },
            onenter = function(inst)
                if inst ~= nil then
                    inst.sg:SetTimeout(0.1)
                    if inst.components.combat.target and inst.components.combat.target:IsValid() then
                        inst:ForceFacePoint(inst.components.combat.target:GetPosition())
                    else
                        inst.sg:GoToState("hit")
                    end
                    inst.components.locomotor:Stop()
                    inst.AnimState:PlayAnimation("evade", true)
                    inst.Physics:SetMotorVelOverride(-30, 0, 0)
                    if inst.components.locomotor then
                        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
                    end
                end
            end,
            timeline = {
                TimeEvent(3 * FRAMES, function(inst) inst.Physics:SetMotorVel(-20, 0, 0) end),
            },
            ontimeout = function(inst)
                inst.sg:GoToState("evade_pst")
            end,
            onexit = function(inst)
                if inst.components.locomotor then
                    inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                    inst.components.locomotor:Stop()
                end
                inst.Physics:ClearMotorVelOverride()
            end,
        },
        State {
            name = "evade_pst",
            tags = { "busy", "evade", "no_stun" },
            onenter = function(inst)
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition())
                end
                inst.components.locomotor:Stop()
            end,
            events = {
                EventHandler("animover", function(inst)
                    if inst.components.combat.target and inst.components.combat.target:IsValid() then
                        local JUMP_DISTANCE = 3
                        local distance = inst:GetDistanceSqToInst(inst.components.combat.target)
                        if distance > JUMP_DISTANCE * JUMP_DISTANCE then
                            inst.sg:GoToState("warrior_attack", inst.components.combat.target)
                        else
                            inst.sg:GoToState("attack", inst.components.combat.target)
                        end
                    else
                        inst.sg:GoToState("idle")
                    end
                end),
            },
            onexit = function(inst)
                if inst.components.locomotor then
                    inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                    inst.components.locomotor:Stop()
                end
                inst.Physics:ClearMotorVelOverride()
            end,
        },
    }

    for k, v in pairs(states) do
        sg.states[v.name] = v
    end
end)
