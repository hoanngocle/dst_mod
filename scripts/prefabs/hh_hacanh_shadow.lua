local brain = require("brains/hh_hacanh_shadow_brain")
local HH_UTILS = require("utils/hh_utils")

local assets = {
    Asset("ANIM", "anim/hh_macanh_shadow.zip"),
    Asset("ANIM", "anim/waxwell_minion_spawn.zip"),
    Asset("ANIM", "anim/waxwell_minion_appear.zip"),
    Asset("ANIM", "anim/swap_nightmaresword_shadow.zip"),
}

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
end

local function IsFriendlyDamage(inst, amount, overtime, cause, ignore_invincible, afflicter)
    if amount >= 0 or afflicter == nil then return false end
    local leader = GetLeader(inst)
    if leader == nil or not HH_UTILS:IsShadowOwnerAlly(inst, afflicter) then
        return false
    end
    return not HH_UTILS:CanShadowDealIntentionalAllyDamage(inst, afflicter)
end

local function Retarget(inst)
    local leader = GetLeader(inst)
    if leader == nil or inst.sg:HasStateTag("dancing") then return nil end
    return FindEntity(leader, TUNING.SHADOWWAXWELL_TARGET_DIST, function(target)
        return target ~= inst
            and target.entity:IsVisible()
            and target.components.combat ~= nil
            and (target.components.combat:TargetIs(leader) or target.components.combat:TargetIs(inst))
            and inst.components.combat:CanTarget(target)
            and HH_UTILS:CanShadowDamageTarget(inst, target)
    end, { "_combat" }, { "playerghost", "INLIMBO", "companion" })
end

local function KeepTarget(inst, target)
    local leader = GetLeader(inst)
    return leader ~= nil and inst:IsNear(leader, 14)
        and inst.components.combat:CanTarget(target)
        and HH_UTILS:CanShadowDamageTarget(inst, target)
        and target.components.minigame_participator == nil
end

local function DropAggro(inst)
    local leader = GetLeader(inst)
    if leader ~= nil and (leader.components.health:IsDead()
        or (leader.sg ~= nil and leader.sg:HasStateTag("hiding"))
        or not inst:IsNear(leader, TUNING.SHADOWWAXWELL_PROTECTOR_TRANSFER_AGGRO_RANGE)
        or not leader.entity:IsVisible() or leader:HasTag("playerghost")) then
        leader = nil
    end
    inst:PushEvent("transfercombattarget", leader)
end

local function OnLoad(inst)
    inst:DoTaskInTime(0, inst.Remove)
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
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("hh_macanh_shadow")
    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
    inst.AnimState:PlayAnimation("minion_spawn")
    inst.AnimState:SetMultColour(0, 0, 0, .5)
    inst.AnimState:UsePointFiltering(true)
    inst.AnimState:AddOverrideBuild("waxwell_minion_spawn")
    inst.AnimState:AddOverrideBuild("waxwell_minion_appear")
    inst.AnimState:OverrideSymbol("swap_object", "swap_nightmaresword_shadow", "swap_nightmaresword_shadow")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.MiniMapEntity:SetIcon("hh_hacanh_shadow.tex")
    inst.MiniMapEntity:SetPriority(10)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst:AddTag("scarytoprey")
    inst:AddTag("shadowminion")
    inst:AddTag("companion")
    inst:AddTag("NOBLOCK")
    inst:AddTag("hh_hacanh_shadow")
    inst:AddTag("inspectable")
    inst:SetPrefabNameOverride("hh_hacanh_shadow")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

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
    inst.components.health:SetMaxHealth(TUNING.HH_HACANH_SHADOW.MAX_HEALTH)
    inst.components.health.nofadeout = true
    inst.components.health.redirect = IsFriendlyDamage
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "torso"
    inst.components.combat:SetRange(2)
    inst.components.combat:SetDefaultDamage(TUNING.HH_HACANH_SHADOW.DAMAGE)

    local old_DoAttack = inst.components.combat.DoAttack
    inst.components.combat.DoAttack = function(combat, target, ...)
        local actual_target = target or combat.target
        if not HH_UTILS:CanShadowDamageTarget(inst, actual_target) then
            if combat.target == actual_target then
                combat:DropTarget()
            end
            return false
        end
        return old_DoAttack(combat, target, ...)
    end
    
    inst._hh_expected_damage = TUNING.HH_HACANH_SHADOW.DAMAGE
    -- Hack: Chặn SGshadowwaxwell gốc ghi đè lại sát thương thành 20 khi đánh
    local old_SetDefaultDamage = inst.components.combat.SetDefaultDamage
    inst.components.combat.SetDefaultDamage = function(self, damage)
        if inst._hh_expected_damage and damage ~= inst._hh_expected_damage then return end
        old_SetDefaultDamage(self, damage)
    end

    inst.components.combat:SetAttackPeriod(TUNING.HH_HACANH_SHADOW.ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(2, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true
    inst:ListenForEvent("killed", function(shadow, data)
        HH_UTILS:RelayKillToOwner(shadow, data)
    end)
    inst._hh_separation_task = inst:DoPeriodicTask(.5, function(shadow)
        if shadow.sg ~= nil and shadow.sg:HasStateTag("busy") then return end
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
    inst:AddComponent("globaltrackingicon")
    inst._hh_attack_count = 0
    inst:ListenForEvent("onattackother", function(shadow)
        inst._hh_attack_count = inst._hh_attack_count + 1
        local leader = GetLeader(inst)
        local manager = leader ~= nil and leader.components.hh_shadow_manager or nil
        local attacks_per_mana = manager ~= nil
            and manager:GetHacanhAttacksPerMana()
            or TUNING.HH_HACANH_SHADOW.ATTACKS_PER_MANA
        if inst._hh_attack_count >= attacks_per_mana then
            inst._hh_attack_count = 0
            if manager ~= nil then
                manager:TrySpendHacanhMana(inst, 1, "hacanh_attack")
            end
        end
    end)
    inst:SetBrain(brain)
    inst:SetStateGraph("SGshadowwaxwell")
    inst.DropAggro = DropAggro
    inst:ListenForEvent("death", DropAggro)
    inst.OnLoad = OnLoad
    return inst
end

local function MapIconCommonPostInit(inst)
    inst:AddTag("hh_hacanh_shadow_mapicon")
    inst:SetPrefabNameOverride("hh_hacanh_shadow")
    inst._hh_owner_name = net_string(inst.GUID, "hh_hacanh_shadow_mapicon.owner_name")
    inst._hh_status = net_string(inst.GUID, "hh_hacanh_shadow_mapicon.status")
    local function ApplyCustomIcon(icon)
        if icon.iconnear ~= nil then icon.iconnear.MiniMapEntity:SetIcon("hh_hacanh_shadow.tex") end
        if icon.iconfar ~= nil then icon.iconfar.MiniMapEntity:SetIcon("hh_hacanh_shadow.tex") end
        if icon.icon ~= nil then icon.icon.MiniMapEntity:SetIcon("hh_hacanh_shadow.tex") end
    end
    inst:DoTaskInTime(0, ApplyCustomIcon)
    inst:ListenForEvent("dirty", ApplyCustomIcon)
end

local function MapIconMasterPostInit(inst)
    local old_TrackEntity = inst.TrackEntity
    inst.TrackEntity = function(icon, target, ...)
        old_TrackEntity(icon, target, ...)
        local leader = target.components.follower ~= nil and target.components.follower.leader or nil
        icon._hh_owner_name:set(leader ~= nil and leader:IsValid() and leader:GetDisplayName() or "")
        icon._hh_status:set("Đang theo chủ")
    end
end

local globalicon, revealableicon = MakeGlobalTrackingIcons("hh_hacanh_shadow", {
    icondata = { icon = "hh_hacanh_shadow", globalicon = "hh_hacanh_shadow", priority = 10 },
    global_common_postinit = MapIconCommonPostInit,
    revealable_common_postinit = MapIconCommonPostInit,
    global_master_postinit = MapIconMasterPostInit,
    revealable_master_postinit = MapIconMasterPostInit,
})

return Prefab("hh_hacanh_shadow", fn, assets), globalicon, revealableicon





