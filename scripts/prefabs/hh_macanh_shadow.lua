local brain = require("brains/hh_macanh_shadow_brain")
local HH_UTILS = require("utils/hh_utils")

local assets = {
    Asset("ANIM", "anim/hh_macanh_shadow.zip"),
    Asset("ANIM", "anim/waxwell_minion_spawn.zip"),
    Asset("ANIM", "anim/waxwell_minion_appear.zip"),
    Asset("ANIM", "anim/splash_weregoose_fx.zip"),
    Asset("ANIM", "anim/splash_water_drop.zip"),
    Asset("ANIM", "anim/swap_axe.zip"),
    Asset("ANIM", "anim/swap_pickaxe.zip"),
    Asset("ANIM", "anim/swap_shovel.zip"),
}

local prefabs = {
    "hh_macanh_shadow_globalicon",
    "hh_macanh_shadow_revealableicon",
    "shadow_despawn",
    "shadow_glob_fx",
    "statue_transition_2",
    "ocean_splash_med1",
    "ocean_splash_med2",
    "ocean_splash_small1",
    "ocean_splash_small2",
}

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
end

local function IsFriendlyDamage(inst, amount, overtime, cause, ignore_invincible, afflicter)
    if amount >= 0 or afflicter == nil then
        return false
    end
    local leader = GetLeader(inst)
    if leader == nil then
        return false
    end
    if not HH_UTILS:IsShadowOwnerAlly(inst, afflicter) then
        return false
    end
    return not HH_UTILS:CanShadowDealIntentionalAllyDamage(inst, afflicter)
end

local function KeepNoCombatTarget()
    return false
end

-- SGshadowwaxwell's disappear state calls this method when the shadow is hit.
-- Keep the vanilla Maxwell implementation so the inherited state remains valid.
local function DropAggro(inst)
    local leader = inst.components.follower:GetLeader()
    if leader ~= nil and
        ((leader.components.health ~= nil and leader.components.health:IsDead()) or
        (leader.sg ~= nil and leader.sg:HasStateTag("hiding")) or
        not inst:IsNear(leader, TUNING.SHADOWWAXWELL_PROTECTOR_TRANSFER_AGGRO_RANGE) or
        not leader.entity:IsVisible() or
        leader:HasTag("playerghost")) then
        leader = nil
    end
    inst:PushEvent("transfercombattarget", leader)
end

local function SetHHStatus(inst, status)
    status = status or "Đang theo chủ"
    if inst._hh_status_text ~= status then
        inst._hh_status_text = status
        inst:PushEvent("hh_macanh_statusdirty", { status = status })
    end
end

local function HasCarriedItems(inst)
    local inventory = inst.components.inventory
    return inventory ~= nil
        and (inventory:GetFirstItemInAnySlot() ~= nil or inventory:GetActiveItem() ~= nil)
end

local function ResetMacanhCommandRecovery(inst)
    inst._hh_macanh_failed_targets = nil
    inst._hh_macanh_progress_target = nil
    inst._hh_macanh_progress_action = nil
    inst._hh_macanh_progress_last_x = nil
    inst._hh_macanh_progress_last_z = nil
    inst._hh_macanh_progress_last_distance = nil
    inst._hh_macanh_progress_current_distance = nil
    inst._hh_macanh_progress_best_distance = nil
    inst._hh_macanh_progress_target_x = nil
    inst._hh_macanh_progress_target_z = nil
    inst._hh_macanh_progress_last_path_step = nil
    inst._hh_macanh_progress_last_time = nil
    inst._hh_macanh_give_failed = nil
    inst._hh_macanh_give_movement_failed = nil
    inst._hh_macanh_drop_failed = nil
    inst._hh_macanh_drop_retry_time = nil
    inst._hh_macanh_follow_recovery_until = nil
end

local function StopMacanhMovement(inst)
    local previous = inst._hh_macanh_clearing_action
    inst._hh_macanh_clearing_action = true

    local locomotor = inst.components.locomotor
    if locomotor ~= nil and locomotor.bufferedaction ~= nil then
        locomotor:SetBufferedAction(nil)
    end
    inst:ClearBufferedAction()
    if locomotor ~= nil then
        locomotor:Stop()
    end

    inst._hh_macanh_clearing_action = previous
end

local function BumpMacanhCommandGeneration(inst)
    inst._hh_work_generation = (inst._hh_work_generation or 0) + 1
    inst:PushEvent("hh_macanh_command_changed", {
        generation = inst._hh_work_generation,
    })
end

local function SetHHWorkCommand(inst, action_id, prefab)
    if action_id ~= "CHOP" and action_id ~= "MINE"
        and action_id ~= "DIG" and action_id ~= "PICK" then
        return false
    end
    if type(prefab) ~= "string" or prefab == "" then
        return false
    end

    local current_changed = inst._hh_work_action ~= action_id
        or inst._hh_work_prefab ~= prefab
    local has_pending = inst._hh_pending_work_action ~= nil
        or inst._hh_pending_work_prefab ~= nil
    local latest_action = has_pending and inst._hh_pending_work_action
        or inst._hh_work_action
    local latest_prefab = has_pending and inst._hh_pending_work_prefab
        or inst._hh_work_prefab
    local latest_changed = latest_action ~= action_id
        or latest_prefab ~= prefab

    if inst._hh_macanh_delivery or HasCarriedItems(inst) then
        -- Delivery/cargo is an exclusive state: compare the incoming command
        -- with the effective latest intent and never fall through to the
        -- current-command activation branch while cargo is unresolved.
        if not latest_changed then
            return true
        end

        inst._hh_macanh_delivery = true
        inst._hh_macanh_delivery_reason = "command_changed"
        inst._hh_pending_work_action = action_id
        inst._hh_pending_work_prefab = prefab
        ResetMacanhCommandRecovery(inst)
        StopMacanhMovement(inst)
        BumpMacanhCommandGeneration(inst)
        return true
    end

    if current_changed then
        inst._hh_work_action = action_id
        inst._hh_work_prefab = prefab
        inst._hh_pending_work_action = nil
        inst._hh_pending_work_prefab = nil
        ResetMacanhCommandRecovery(inst)
        StopMacanhMovement(inst)
        BumpMacanhCommandGeneration(inst)
    end
    return true
end

local function CancelHHWorkCommand(inst)
    inst._hh_work_action = nil
    inst._hh_work_prefab = nil
    inst._hh_pending_work_action = nil
    inst._hh_pending_work_prefab = nil
    ResetMacanhCommandRecovery(inst)
    StopMacanhMovement(inst)
    BumpMacanhCommandGeneration(inst)
end

local function ChargeCompletedTarget(inst, data)
    local leader = GetLeader(inst)
    local manager = leader ~= nil and leader.components.hh_shadow_manager or nil
    if manager ~= nil then
        manager:OnMacanhTargetCompleted(inst, data)
    end
end

local function ChargeCompletedPickTarget(inst, data)
    local leader = GetLeader(inst)
    local manager = leader ~= nil and leader.components.hh_shadow_manager or nil
    if manager ~= nil then
        manager:OnMacanhTargetCompleted(inst, data, ACTIONS.PICK)
    end
end

local function OnNewState(inst, data)
    local state = data ~= nil and data.statename or nil
    if state == "take" then
        SetHHStatus(inst, "Đang nhặt vật phẩm")
    elseif state == "give" then
        SetHHStatus(inst, "Đang theo chủ")
    end
end

local function OnLoad(inst)
    -- Summoned disciples are always reconstructed by HHShadowManager.
    inst:DoTaskInTime(0, inst.Remove)
end

local function RefillSpeechBag(inst)
    inst._hh_speech_bag = {}
    for i, _ in ipairs(STRINGS.HH_MACANH_SHADOW.SPEECH) do
        table.insert(inst._hh_speech_bag, i)
    end
    for i = #inst._hh_speech_bag, 2, -1 do
        local j = math.random(i)
        inst._hh_speech_bag[i], inst._hh_speech_bag[j] =
            inst._hh_speech_bag[j], inst._hh_speech_bag[i]
    end
    if #inst._hh_speech_bag > 1
        and inst._hh_speech_bag[#inst._hh_speech_bag] == inst._hh_last_speech_index then
        inst._hh_speech_bag[#inst._hh_speech_bag], inst._hh_speech_bag[#inst._hh_speech_bag - 1] =
            inst._hh_speech_bag[#inst._hh_speech_bag - 1], inst._hh_speech_bag[#inst._hh_speech_bag]
    end
end

local function SayRandomSpeech(inst)
    if inst.components.talker == nil then
        return
    end
    if inst._hh_speech_bag == nil or #inst._hh_speech_bag == 0 then
        RefillSpeechBag(inst)
    end
    local index = table.remove(inst._hh_speech_bag)
    inst._hh_last_speech_index = index
    inst.components.talker:Say(STRINGS.HH_MACANH_SHADOW.SPEECH[index])
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

    inst:SetPhysicsRadiusOverride(.5)
    MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)
    inst.Physics:ClearCollidesWith(COLLISION.CHARACTERS)
    inst.Physics:ClearCollidesWith(COLLISION.GIANTS)
    inst.Transform:SetFourFaced(inst)
    inst.Transform:SetScale(TUNING.HH_MACANH_SHADOW.SCALE,
        TUNING.HH_MACANH_SHADOW.SCALE, TUNING.HH_MACANH_SHADOW.SCALE)

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("hh_macanh_shadow")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:PlayAnimation("minion_spawn")
    inst.AnimState:SetMultColour(0, 0, 0, .5)
    inst.AnimState:UsePointFiltering(true)
    inst.AnimState:AddOverrideBuild("waxwell_minion_spawn")
    inst.AnimState:AddOverrideBuild("waxwell_minion_appear")
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")

    inst.MiniMapEntity:SetIcon("hh_macanh_shadow.tex")
    inst.MiniMapEntity:SetPriority(10)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst:AddTag("scarytoprey")
    inst:AddTag("shadowminion")
    inst:AddTag("companion")
    inst:AddTag("NOBLOCK")
    inst:AddTag("hh_macanh_shadow")
    inst:AddTag("inspectable")
    inst:SetPrefabNameOverride("hh_macanh_shadow")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst:AddComponent("skinner")
    inst.components.skinner:SetupNonPlayerData()



    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true, ignorewalls = true }
    inst.components.locomotor:SetSlowMultiplier(.6)


    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HH_MACANH_SHADOW.MAX_HEALTH)
    inst.components.health.nofadeout = true
    inst.components.health.redirect = IsFriendlyDamage

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetRange(2)
    inst.components.combat:SetKeepTargetFunction(KeepNoCombatTarget)

    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true
    local function IsFreeForSeparation(shadow)
        local sg = shadow.sg
        if sg ~= nil and
            (sg:HasStateTag("busy")
                or sg:HasStateTag("doing")
                or sg:HasStateTag("working")
                or sg:HasStateTag("moving")) then
            return false
        end
        if shadow.bufferedaction ~= nil
            or shadow._hh_macanh_delivery
            or shadow._hh_macanh_danger_active
            or (shadow._hh_macanh_follow_recovery_until or 0) > GetTime()
            or (shadow._hh_macanh_danger_recovery_until or 0) > GetTime() then
            return false
        end
        local locomotor = shadow.components.locomotor
        if locomotor == nil
            or locomotor.bufferedaction ~= nil
            or locomotor.dest ~= nil
            or locomotor.wantstomoveforward then
            return false
        end
        return shadow:GetBufferedAction() == nil
    end

    inst._hh_separation_task = inst:DoPeriodicTask(.5, function(shadow)
        if not IsFreeForSeparation(shadow) then
            return
        end
        local x, y, z = shadow.Transform:GetWorldPosition()
        local nearby = TheSim:FindEntities(x, y, z, 2.0, nil, { "INLIMBO" }, { "hh_macanh_shadow", "hh_hacanh_shadow" })
        for _, other in ipairs(nearby) do
            if other ~= shadow and other:IsValid() then
                local ox, oy, oz = other.Transform:GetWorldPosition()
                local dx, dz = x - ox, z - oz
                local dist_sq = dx * dx + dz * dz
                if dist_sq > 0 and dist_sq < 1.6 * 1.6 then
                    shadow.components.locomotor:RunInDirection(math.atan2(dz, dx) / DEGREES)
                    break
                end
            end
        end
    end)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1

    local old_GiveItem = inst.components.inventory.GiveItem
    inst.components.inventory.GiveItem = function(self, item, slot, src_pos, ...)
        if inst._hh_double_loot_chance and inst._hh_double_loot_chance > 0 and not inst._hh_is_duping then
            -- Prevent exploiting player-dropped items: only dupe if the item has never been in a player's inventory
            if item and not item:HasTag("hh_player_touched") then
                if math.random() < inst._hh_double_loot_chance then
                    if item:IsValid() and item.prefab then
                        local dupe = SpawnPrefab(item.prefab)
                        if dupe then
                            if dupe.components.stackable and item.components.stackable then
                                dupe.components.stackable:SetStackSize(item.components.stackable:StackSize())
                            end
                            inst._hh_is_duping = true
                            self:GiveItem(dupe, nil, src_pos)
                            inst._hh_is_duping = false
                        end
                    end
                end
            end
        end
        return old_GiveItem(self, item, slot, src_pos, ...)
    end

    inst:AddComponent("talker")
    inst:AddComponent("globaltrackingicon")

    MakeMediumFreezableCharacter(inst, "torso")
    MakeMediumBurnableCharacter(inst, "torso")

    inst._hh_status_text = "Đang theo chủ"
    inst._hh_work_generation = 0
    inst.SetHHStatus = SetHHStatus
    inst.SetHHWorkCommand = SetHHWorkCommand
    inst.CancelHHWorkCommand = CancelHHWorkCommand
    inst.DropAggro = DropAggro

    inst:ListenForEvent("finishedwork", ChargeCompletedTarget)
    inst:ListenForEvent("picksomething", ChargeCompletedPickTarget)
    inst:ListenForEvent("braincommon_pickup_success", function(shadow, action)
        local leader = GetLeader(shadow)
        local manager = leader ~= nil and leader.components.hh_shadow_manager or nil
        if manager ~= nil then
            manager:OnMacanhGroundPickupCompleted(shadow, action)
        end
    end)
    local function DropItems(inst)
        if inst.components.inventory ~= nil then
            inst.components.inventory:DropEverything()
        end
    end
    local function CleanupMacanhAI(inst)
        if inst._hh_separation_task ~= nil then
            inst._hh_separation_task:Cancel()
            inst._hh_separation_task = nil
        end
        if inst._hh_speech_task ~= nil then
            inst._hh_speech_task:Cancel()
            inst._hh_speech_task = nil
        end
        inst._hh_macanh_delivery = nil
        inst._hh_macanh_delivery_reason = nil
        inst._hh_macanh_returning_to_owner = nil
        inst._hh_pending_work_action = nil
        inst._hh_pending_work_prefab = nil
        inst._hh_work_action = nil
        inst._hh_work_prefab = nil
        inst._hh_macanh_failed_targets = nil
        inst._hh_macanh_progress_target = nil
        inst._hh_macanh_progress_action = nil
        inst._hh_macanh_progress_last_x = nil
        inst._hh_macanh_progress_last_z = nil
        inst._hh_macanh_progress_last_distance = nil
        inst._hh_macanh_progress_current_distance = nil
        inst._hh_macanh_progress_best_distance = nil
        inst._hh_macanh_progress_target_x = nil
        inst._hh_macanh_progress_target_z = nil
        inst._hh_macanh_progress_last_path_step = nil
        inst._hh_macanh_progress_last_time = nil
        inst._hh_macanh_give_failed = nil
        inst._hh_macanh_give_movement_failed = nil
        inst._hh_macanh_drop_failed = nil
        inst._hh_macanh_drop_retry_time = nil
        inst._hh_macanh_follow_recovery_until = nil
        inst._hh_macanh_danger_recovery_until = nil
        inst._hh_macanh_danger_active = nil
    end

    inst:ListenForEvent("newstate", OnNewState)
    inst:ListenForEvent("death", DropAggro)
    inst:ListenForEvent("death", DropItems)
    inst:ListenForEvent("death", CleanupMacanhAI)
    inst:ListenForEvent("onremove", DropItems)
    inst:ListenForEvent("onremove", CleanupMacanhAI)
    inst._hh_speech_task = inst:DoPeriodicTask(
        TUNING.HH_MACANH_SHADOW.SPEECH_INTERVAL,
        SayRandomSpeech,
        TUNING.HH_MACANH_SHADOW.SPEECH_INTERVAL
    )

    inst:SetBrain(brain)
    inst:SetStateGraph("SGhh_macanh_shadow")
    inst.OnLoad = OnLoad

    return inst
end

local function MapIconCommonPostInit(inst)
    inst:AddTag("hh_macanh_shadow_mapicon")
    inst:SetPrefabNameOverride("hh_macanh_shadow")
    inst._hh_owner_name = net_string(inst.GUID, "hh_macanh_shadow_mapicon.owner_name")
    inst._hh_status = net_string(inst.GUID, "hh_macanh_shadow_mapicon.status")
    local function ApplyCustomIcon(icon)
        if icon.iconnear ~= nil then icon.iconnear.MiniMapEntity:SetIcon("hh_macanh_shadow.tex") end
        if icon.iconfar ~= nil then icon.iconfar.MiniMapEntity:SetIcon("hh_macanh_shadow.tex") end
        if icon.icon ~= nil then icon.icon.MiniMapEntity:SetIcon("hh_macanh_shadow.tex") end
    end
    inst:DoTaskInTime(0, ApplyCustomIcon)
    inst:ListenForEvent("dirty", ApplyCustomIcon)
    inst:ListenForEvent("mapselected", ApplyCustomIcon)
    inst:ListenForEvent("cancelmaptarget", ApplyCustomIcon)
end

local function MapIconMasterPostInit(inst)
    local old_TrackEntity = inst.TrackEntity
    inst.TrackEntity = function(icon, target, ...)
        old_TrackEntity(icon, target, ...)

        local function Refresh()
            local leader = target.components.follower ~= nil and target.components.follower.leader or nil
            icon._hh_owner_name:set(leader ~= nil and leader:IsValid() and leader:GetDisplayName() or "")
            icon._hh_status:set(target._hh_status_text or "Đang theo chủ")
        end

        icon:ListenForEvent("hh_macanh_statusdirty", Refresh, target)
        Refresh()
    end
end

local globalicon, revealableicon = MakeGlobalTrackingIcons("hh_macanh_shadow", {
    icondata = {
        icon = "friendlyfruitfly",
        globalicon = "friendlyfruitfly",
        priority = 10,
    },
    global_common_postinit = MapIconCommonPostInit,
    revealable_common_postinit = MapIconCommonPostInit,
    global_master_postinit = MapIconMasterPostInit,
    revealable_master_postinit = MapIconMasterPostInit,
})

return Prefab("hh_macanh_shadow", fn, assets, prefabs), globalicon, revealableicon
