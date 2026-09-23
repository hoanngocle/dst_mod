local friendlybrain = require("brains/hh_fruitfly_shadow_brain")

STRINGS.NAMES.HH_FRUITFLY_SHADOW = STRINGS.NAMES.HH_FRUITFLY_SHADOW or "Fruitfly"

local HH_UTILS = require("utils/hh_utils")

local function IsFriendlyDamage(inst, amount, overtime, cause, ignore_invincible, afflicter)
    if amount >= 0 or afflicter == nil then
        return false
    end
    if not HH_UTILS:IsShadowOwnerAlly(inst, afflicter) then
        return false
    end
    return not HH_UTILS:CanShadowDealIntentionalAllyDamage(inst, afflicter)
end

local friendlysounds = {
    flap = "farming/creatures/fruitfly/LP",
    hurt = "farming/creatures/fruitfly/hit",
    die = "farming/creatures/fruitfly/die",
    die_ground = "farming/creatures/fruitfly/die",
    sleep = "farming/creatures/fruitfly/sleep",
    buzz = "farming/creatures/fruitfly/hit",
}

local PLANT_SPEECH = {
    "Cây nhỏ, lớn nhanh lên nhé!",
    "Bóng tối cũng biết chăm cây đấy!",
    "Một chút quan tâm cho mùa màng.",
    "Ngoan nào, hãy lớn thật khỏe mạnh.",
    "Chủ nhân sẽ thích vụ mùa này.",
    "Ta nghe thấy cây đang vui!",
    "Thêm một mầm sống được chăm sóc.",
    "Lớn lên đi, đừng phụ công ta nhé!",
    "Khu vườn này thuộc về bóng tối!",
    "Xong rồi! Tiếp theo là cây nào?",
}

local IDLE_SPEECH = {
    "Hôm nay khu vườn yên tĩnh quá.",
    "Chủ nhân, ta đang chờ mệnh lệnh.",
    "Không có cây nào cần ta sao?",
    "Ta có thể đứng đây cả ngày đấy.",
    "Gió đang kể chuyện với những chiếc lá.",
    "Bóng tối cũng cần nghỉ ngơi đôi chút.",
    "Mọi cây trồng trong khu vực đều ổn.",
    "Ta sẽ canh giữ khu vườn này.",
    "Bao giờ chúng ta gieo thêm hạt giống?",
    "Nếu cần ta, hãy gọi bằng phím L.",
}

local COMMAND_UPDATE_PERIOD = 0.5
local COMMAND_STUCK_TIME = 10
local COMMAND_PROGRESS_DISTANCE_SQ = 0.5 * 0.5
local COMMAND_REACHED_DISTANCE_SQ = 1 * 1
local WORK_STATION_IDLE_DISTANCE_SQ = 1.5 * 1.5
local IDLE_SPEECH_INTERVAL = 10
local COMMAND_MANA_DISTANCE = 10

local function PickNonRepeatingLine(lines, previous)
    if #lines <= 1 then
        return lines[1]
    end

    local line = lines[math.random(#lines)]
    while line == previous do
        line = lines[math.random(#lines)]
    end
    return line
end

local function CopyPoint(point)
    return point ~= nil and Vector3(point.x, point.y or 0, point.z) or nil
end

local function StopCommandTask(inst)
    if inst._hh_command_task ~= nil then
        inst._hh_command_task:Cancel()
        inst._hh_command_task = nil
    end
end

local function ClearCommand(inst)
    StopCommandTask(inst)
    inst._hh_is_relocating = false
    inst._hh_is_returning = false
    inst._hh_command_position = nil
    inst._hh_previous_work_position = nil
    inst._hh_last_progress_position = nil
    inst._hh_last_progress_time = nil
    inst._hh_last_command_cost_position = nil
end

local function FinishCommand(inst, destination)
    local reached_new_position = not inst._hh_is_returning
    inst.components.locomotor:Stop()
    inst._hh_work_position = CopyPoint(destination)
    ClearCommand(inst)
    if reached_new_position then
        local owner = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
        if owner ~= nil and owner:IsValid() and owner.components.talker ~= nil then
            owner.components.talker:Say("FruitFly đã di chuyển tới vị trí mới rồi !")
        end
    end
end

local function UpdateCommand(inst)
    if not inst._hh_is_relocating or inst.components.locomotor == nil then
        ClearCommand(inst)
        return
    end

    local destination = inst._hh_is_returning and inst._hh_previous_work_position or inst._hh_command_position
    if destination == nil then
        ClearCommand(inst)
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local dx = destination.x - x
    local dz = destination.z - z
    if dx * dx + dz * dz <= COMMAND_REACHED_DISTANCE_SQ then
        FinishCommand(inst, destination)
        return
    end

    local current = Vector3(x, y, z)
    if not inst._hh_is_returning then
        local costpos = inst._hh_last_command_cost_position
        if costpos ~= nil then
            local cdx, cdz = x - costpos.x, z - costpos.z
            local step_distance = math.sqrt(cdx * cdx + cdz * cdz)
            local walk_speed = inst.components.locomotor.walkspeed or 0
            local maximum_normal_step = math.max(2, walk_speed * COMMAND_UPDATE_PERIOD * 2)
            if step_distance <= maximum_normal_step then
                inst._hh_command_mana_distance = (inst._hh_command_mana_distance or 0) + step_distance
                while inst._hh_command_mana_distance >= COMMAND_MANA_DISTANCE do
                    inst._hh_command_mana_distance = inst._hh_command_mana_distance - COMMAND_MANA_DISTANCE
                    local owner = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
                    local manager = owner ~= nil and owner.components.hh_shadow_manager or nil
                    if manager == nil or not manager:TrySpendFruitFlyMana(inst, 1, "fruitfly_travel") then return end
                end
            end
        end
        inst._hh_last_command_cost_position = current
    else
        inst._hh_last_command_cost_position = nil
    end

    local last = inst._hh_last_progress_position
    if last == nil then
        inst._hh_last_progress_position = current
        inst._hh_last_progress_time = GetTime()
    else
        local pdx = current.x - last.x
        local pdz = current.z - last.z
        if pdx * pdx + pdz * pdz >= COMMAND_PROGRESS_DISTANCE_SQ then
            inst._hh_last_progress_position = current
            inst._hh_last_progress_time = GetTime()
        elseif GetTime() - (inst._hh_last_progress_time or GetTime()) >= COMMAND_STUCK_TIME then
            if not inst._hh_is_returning and inst._hh_previous_work_position ~= nil then
                inst._hh_is_returning = true
                inst._hh_last_command_cost_position = nil
                inst._hh_last_progress_position = current
                inst._hh_last_progress_time = GetTime()
                local owner = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
                if owner ~= nil and owner:IsValid() and owner.components.talker ~= nil then
                    owner.components.talker:Say("FruitFly gặp chướng ngại vật nên đã quay đầu về chổ cũ ~~")
                end
            else
                inst.components.locomotor:Stop()
                ClearCommand(inst)
                return
            end
        end
    end

    destination = inst._hh_is_returning and inst._hh_previous_work_position or inst._hh_command_position
    if destination ~= nil then
        inst.components.locomotor:GoToPoint(destination, nil, false)
    end
end

local function UpdateIdleSpeech(inst)
    local is_idle = not inst._hh_is_relocating and inst.sg ~= nil and inst.sg:HasStateTag("idle")
    if not is_idle then
        inst._hh_idle_timer_started = false
        return
    end

    local workpos = inst._hh_work_position
    if workpos == nil then
        inst._hh_idle_timer_started = false
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local dx = workpos.x - x
    local dz = workpos.z - z
    if dx * dx + dz * dz > WORK_STATION_IDLE_DISTANCE_SQ then
        inst._hh_idle_timer_started = false
        return
    end

    if not inst._hh_idle_timer_started then
        inst._hh_idle_timer_started = true
        inst._hh_next_idle_speech_time = GetTime() + IDLE_SPEECH_INTERVAL
        return
    end

    if GetTime() >= (inst._hh_next_idle_speech_time or 0) then
        local line = PickNonRepeatingLine(IDLE_SPEECH, inst._hh_last_idle_speech)
        inst._hh_last_idle_speech = line
        inst.components.talker:Say(line)
        inst._hh_next_idle_speech_time = GetTime() + IDLE_SPEECH_INTERVAL
    end
end

local function GetHHWorkPosition(inst)
    return CopyPoint(inst._hh_work_position) or inst:GetPosition()
end

local function SetHHWorkPosition(inst, x, y, z)
    inst._hh_work_position = Vector3(x, y or 0, z)
end

local function CommandToPosition(inst, x, y, z)
    if inst.components.locomotor == nil then
        return false
    end

    StopCommandTask(inst)
    inst:ClearBufferedAction()
    inst.components.locomotor:Stop()
    inst.planttarget = nil
    inst._hh_previous_work_position = GetHHWorkPosition(inst)
    inst._hh_command_position = Vector3(x, y or 0, z)
    inst._hh_is_relocating = true
    inst._hh_is_returning = false
    inst._hh_last_progress_position = inst:GetPosition()
    inst._hh_last_progress_time = GetTime()
    inst._hh_last_command_cost_position = inst:GetPosition()
    inst._hh_idle_timer_started = false
    inst._hh_command_task = inst:DoPeriodicTask(COMMAND_UPDATE_PERIOD, UpdateCommand, 0)
    return true
end

local function SayHHPlantLine(inst)
    if inst.components.talker ~= nil then
        local line = PickNonRepeatingLine(PLANT_SPEECH, inst._hh_last_plant_speech)
        inst._hh_last_plant_speech = line
        inst.components.talker:Say(line)
    end
    inst._hh_idle_timer_started = false
    inst._hh_tended_plant_count = (inst._hh_tended_plant_count or 0) + 1
    local owner = inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
    local manager = owner ~= nil and owner.components.hh_shadow_manager or nil
    if manager ~= nil then
        manager:AwardShadowActionExp("hh_fruitfly_shadow", 4, "plant_tending")
    end
    local plants_per_mana = inst._hh_dungeon_fruitfly_care and 4 or 2
    if inst._hh_tended_plant_count >= plants_per_mana then
        inst._hh_tended_plant_count = 0
        if manager ~= nil then manager:TrySpendFruitFlyMana(inst, 1, "fruitfly_tending") end
    end
end

local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
require "prefabs/veggies"
local function pickseed()
    local season = TheWorld.state.season
    local weights = {}
    local season_mod = TUNING.SEED_WEIGHT_SEASON_MOD

    for k, v in pairs(VEGGIES) do
        weights[k] = v.seed_weight * ((PLANT_DEFS[k] and PLANT_DEFS[k].good_seasons[season]) and season_mod or 1)
    end

    return weighted_random_choice(weights).."_seeds"
end

SetSharedLootTable("lordfruitfly",
{
    {'plantmeat',             1.00},
})

local function common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.Transform:SetFourFaced()

    MakeGhostPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("fruitfly")

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("small")

    return inst
end

local function common_server(inst)
    inst:AddComponent("inspectable")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.pathcaps = {allowocean = true}

    MakeMediumFreezableCharacter(inst, "fruit2")
    MakeMediumBurnableCharacter(inst, "fruit2")
    inst.components.burnable:SetBurnTime(8 * TUNING.PLANTMOB_BURNTIME_MULT)

    MakeHauntablePanic(inst)

    return inst
end

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function FriendlyShouldWakeUp(inst)
    return DefaultWakeTest(inst)
        or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function FriendlyShouldSleep(inst)
    return DefaultSleepTest(inst)
        and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE)
end

local function FriendlyShouldKeepTarget()
    return false
end

local function OnLoad(inst)
    -- Legacy cleanup: older versions saved summoned Fruit Flies as standalone
    -- world entities. Their owner/manager link is not restored, so remove them.
    inst:DoTaskInTime(0, inst.Remove)
end

local function OnStopFollowing(inst)
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    if inst.components.follower.leader:HasTag("fruitflyfruit") then -- Getting leader directly special case.
        inst:AddTag("companion")
    end
end

local friendlyassets =
{
    Asset("ANIM", "anim/fruitfly.zip"),
    Asset("ANIM", "anim/hh_fruitfly_shadow.zip"),
    Asset("ANIM", "anim/fruitfly_evil.zip"),
}

local friendlyprefabs =
{
    "hh_fruitfly_shadow_globalicon",
    "hh_fruitfly_shadow_revealableicon",
}

local function friendlyfn()
    local inst = common()

    inst.DynamicShadow:SetSize(1 * 0.75, 0.375 * 0.75)

    inst.sounds = friendlysounds

    inst.AnimState:SetBuild("hh_fruitfly_shadow")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(0.75, 0.75, 0.75)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("friendlyfruitfly.png")
    inst.MiniMapEntity:SetPriority(10)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst:AddTag("hh_fruitfly_shadow")
    inst:AddTag("companion")
    inst:AddTag("cattoyairborne")

    MakeInventoryFloatable(inst, "med")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetCanSleep(false)

	inst.override_combat_fx_size = "tiny"
	inst.override_combat_fx_height = ""

    common_server(inst)

    inst:AddComponent("follower")
    inst.components.follower.noleashing = true
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("globaltrackingicon")

    inst:AddComponent("health")
    inst.components.health.fire_damage_scale = TUNING.PLANTMOB_FIRE_DAMAGE_SCALE
    inst.components.health.redirect = IsFriendlyDamage
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "fruit2"
    inst.components.combat:SetKeepTargetFunction(FriendlyShouldKeepTarget)
    -- FruitFly is a work companion. Keep the combat component for vanilla
    -- hit/death handling, but do not let a stray combat event turn it into an
    -- attacker; plant actions use BufferedAction instead of DoAttack().
    inst.components.combat.DoAttack = function(combat, target, ...)
        return false
    end

    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(FriendlyShouldSleep)
    inst.components.sleeper:SetWakeTest(FriendlyShouldWakeUp)

    inst:AddComponent("lootdropper")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY

    inst:AddComponent("talker")

    inst:SetBrain(friendlybrain)
    inst:SetStateGraph("SGhh_fruitfly_shadow")
    inst.OnLoad = OnLoad
	inst.sg.mem.burn_on_electrocute = true

    inst.GetHHWorkPosition = GetHHWorkPosition
    inst.SetHHWorkPosition = SetHHWorkPosition
    inst.CommandToPosition = CommandToPosition
    inst.SayHHPlantLine = SayHHPlantLine
    inst._hh_is_relocating = false
    inst._hh_is_returning = false
    inst._hh_work_position = inst:GetPosition()
    inst._hh_idle_timer_started = false
    inst._hh_command_mana_distance = 0
    inst._hh_tended_plant_count = 0
    inst._hh_idle_speech_task = inst:DoPeriodicTask(1, UpdateIdleSpeech)
    inst:ListenForEvent("onremove", function()
        StopCommandTask(inst)
        if inst._hh_idle_speech_task ~= nil then
            inst._hh_idle_speech_task:Cancel()
            inst._hh_idle_speech_task = nil
        end
    end)

    return inst
end

local function MakeCorpse()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.5)
    inst.Transform:SetScale(2, 2, 2)
    inst.AnimState:SetBank("fruitfly")
    inst.AnimState:SetBuild("fruitfly_evil")
    inst.AnimState:PlayAnimation("death")
    inst.AnimState:SetPercent("death", 1)

    inst:AddTag("shadow_corpse")
    inst.name = "Xác Chúa Ruồi Trái Cây"
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.persists = false
    inst:DoTaskInTime(40, inst.Remove)
    return inst
end

local function FruitflyMapIconCommonPostInit(inst)
    inst:AddTag("hh_fruitfly_shadow_mapicon")
    inst:SetPrefabNameOverride("hh_fruitfly_shadow")
    inst._hh_owner_name = net_string(inst.GUID, "hh_fruitfly_shadow_mapicon.owner_name")
end

local function FruitflyMapIconMasterPostInit(inst)
    local old_TrackEntity = inst.TrackEntity
    inst.TrackEntity = function(icon, target, ...)
        old_TrackEntity(icon, target, ...)

        local leader = target.components.follower ~= nil and
            target.components.follower.leader or nil
        icon._hh_owner_name:set(
            leader ~= nil and leader:IsValid() and leader:GetDisplayName() or ""
        )
    end
end

local fruitfly_globalicon, fruitfly_revealableicon =
    MakeGlobalTrackingIcons("hh_fruitfly_shadow", {
        icondata = {
            icon = "friendlyfruitfly",
            globalicon = "friendlyfruitfly",
            priority = 10,
        },
        global_common_postinit = FruitflyMapIconCommonPostInit,
        revealable_common_postinit = FruitflyMapIconCommonPostInit,
        global_master_postinit = FruitflyMapIconMasterPostInit,
        revealable_master_postinit = FruitflyMapIconMasterPostInit,
    })

return Prefab("hh_fruitfly_shadow", friendlyfn, friendlyassets, friendlyprefabs),
       Prefab("hh_corpse_fruitfly", MakeCorpse, friendlyassets),
       fruitfly_globalicon,
       fruitfly_revealableicon
