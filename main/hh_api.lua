local cffUucfkn = require("utils/hh_utils")
local ShadowProgressionDefs = require("enums/hh_shadow_progression_defs")
local RankDefs = require("guild/hh_rank_defs")
local ifiUnccKk = require("enums/hh_prefab_list")
local nffugciKk = ifiUnccKk["equip"]
local kfgUcCnkg = ifiUnccKk["organism"]
local ifkUgckKi = ifiUnccKk["eboss_monster"]
local uFcufCikn = ifiUnccKk["pig"]
local cFcUiCgkg = ifiUnccKk["fish"]
local cFuuiciKf = ifiUnccKk["monkey"]
local nFgUuCgku = ifiUnccKk["plant"]
local cFguuCnKu = ifiUnccKk["gear"]
local nFuuncgKk = ifiUnccKk["spider"]
local cFkuucgku = ifiUnccKk["dog"]
local uffUgCuKc = ifiUnccKk["frog"]
local nFkufcnKf = ifiUnccKk["insect"]
local ufcUgcnKg = ifiUnccKk["shadow"]
local gFiukccKg = ifiUnccKk["common_monster"]
local kffUncgkc = ifiUnccKk["elite_monster"]
local nfkUiCukg = ifiUnccKk["boss_monster"]
local cFgUccikn = ifiUnccKk["endgameboss_monster"]
local gFfukCfKc = (371 + 52 * 240 ~= 12856)
local function nFfUnCgKc(nFfuiCkkc, iFcUgCgku, ffuUkCfKk, kFfUnCnku)
    local ufuufCgkk = nFfuiCkkc["prefab"]
    if iFcUgCgku[ufuufCgkk] then
        nFfuiCkkc["hh_tags"][ffuUkCfKk] = kFfUnCnku or "Undefined"
    end
end
local function cfnUcCcku(nfgucccKi)
    local cFnUnCiKg = 3
    if cffUucfkn:HasComponents(nfgucccKi, "weapon") or cffUucfkn:HasComponents(nfgucccKi, "armor") then
        cFnUnCiKg = 5
    end
    if cffUucfkn:HasComponents(nfgucccKi, "equippable") then
        if nfgucccKi:HasTag("medal") or nfgucccKi["components"]["equippable"]["equipslot"] == "trshipin" then
            if gFfukCfKc then
                cFnUnCiKg = 1
            else
                cFnUnCiKg = 0
            end
        end
    end
    return cFnUnCiKg
end
local function kFnUuckkg(iFcUnckku)
    if not iFcUnckku["prefab"] then
        return
    end
    if not iFcUnckku["hh_tags"] then
        iFcUnckku["hh_tags"] = {}
    end
    nFfUnCgKc(iFcUnckku, uFcufCikn, "pig", "Heo")
    nFfUnCgKc(iFcUnckku, cFcUiCgkg, "fish", "Cá")
    nFfUnCgKc(iFcUnckku, cFuuiciKf, "monkey", "Khỉ")
    nFfUnCgKc(iFcUnckku, nFgUuCgku, "plant", "Thực vật")
    nFfUnCgKc(iFcUnckku, cFguuCnKu, "gear", "Gears")
    nFfUnCgKc(iFcUnckku, nFuuncgKk, "spider", "Nhện")
    nFfUnCgKc(iFcUnckku, cFkuucgku, "dog", "Sói")
    nFfUnCgKc(iFcUnckku, uffUgCuKc, "frog", "Ếch")
    nFfUnCgKc(iFcUnckku, nFkufcnKf, "insect", "Côn trùng")
    nFfUnCgKc(iFcUnckku, ufcUgcnKg, "shadow", "Svật bóng tối")
    nFfUnCgKc(iFcUnckku, gFiukccKg, "common_monster", "Quái thường")
    nFfUnCgKc(iFcUnckku, kffUncgkc, "elite_monster", "Quái mạnh")
    nFfUnCgKc(iFcUnckku, nfkUiCukg, "boss_monster", "Quái trùm")
    nFfUnCgKc(iFcUnckku, cFgUccikn, "endgameboss_monster", "Trùm cuối")
end
local function gfnUuCuku(nfcucCkKn, ufuunckKi)
    if
        not cffUucfkn:IsHHType(ufuunckKi, "string") or not nfcucCkKn["hh_tags"] or
            not cffUucfkn:IsHHType(nfcucCkKn["hh_tags"], "table")
     then
        return (true and false and not false or true and true and not false and not false and false and false and false or
            false and not false and not false)
    end
    return nfcucCkKn["hh_tags"][ufuunckKi] ~= nil
end
local function HHResolveExpMeta(victim)
    if not victim then return nil end
    local treasure_id = victim.components and victim.components.hh_monster and victim.components.hh_monster.treasure_id
    local meta = treasure_id and TUNING.HH_TREASURE_BOSS_EXP[treasure_id] or nil
    if not meta and victim.hh_is_dungeon_boss then meta = TUNING.HH_DUNGEON_BOSS_EXP[victim.prefab] end
    if meta then return meta end
    local exp = TUNING.HH_MOB_EXP[victim.prefab]
    if not exp then return nil end
    return { exp = exp, level = TUNING.HH_MOB_RECOMMENDED_LEVEL[victim.prefab] or 1,
        class = TUNING.HH_BOSS_PREFABS[victim.prefab] and "boss"
            or TUNING.HH_MINIBOSS_PREFABS[victim.prefab] and "miniboss" or "normal" }
end
local function HHIsEligibleExpPlayer(player)
    return player and player:IsValid() and not player:HasTag("playerghost")
        and player.components and player.components.health and not player.components.health:IsDead()
        and player.components.hh_leveling ~= nil
end
local function HHGetLevelFactor(player, meta)
    if meta.class == "boss" or meta.class == "superboss" then return 1 end
    local gap = (player.components.hh_leveling.level or 1) - (meta.level or 1)
    for _, row in ipairs(TUNING.HH_EXP_BALANCE.LEVEL_FACTORS) do
        if gap >= row.gap then return row.factor end
    end
    return 1
end
local function HHGetExpRecipients(killer, victim)
    local recipients = {}
    if victim.hh_is_dungeon_monster and victim.hh_dungeon_manager then
        for player in pairs(victim.hh_dungeon_manager.players_in_dungeon or {}) do
            if HHIsEligibleExpPlayer(player) then table.insert(recipients, player) end
        end
    else
        local radius_sq = (TUNING.HH_EXP_BALANCE.SHARE_RADIUS or 32) ^ 2
        local x, _, z = victim.Transform:GetWorldPosition()
        for _, player in ipairs(AllPlayers) do
            if HHIsEligibleExpPlayer(player) then
                local px, _, pz = player.Transform:GetWorldPosition()
                local dx, dz = px - x, pz - z
                if dx * dx + dz * dz <= radius_sq then table.insert(recipients, player) end
            end
        end
    end
    if #recipients == 0 and HHIsEligibleExpPlayer(killer) then table.insert(recipients, killer) end
    return recipients
end
local function HHAwardKillExp(killer, victim)
    if not victim or victim.hh_exp_awarded then return end
    local meta = HHResolveExpMeta(victim)
    if not meta or (meta.exp or 0) <= 0 then return end
    victim.hh_exp_awarded = true
    local recipients = HHGetExpRecipients(killer, victim)
    if #recipients == 0 then return end
    local HHUtils = require("utils/hh_utils")
    for _, player in ipairs(recipients) do
        local effects = player.components.hh_dungeon_effects
        local rank = player.components.hh_rank
        local super_growth = TUNING.HH_SUPER_GROWTH or {}
        local rank_multiplier = rank ~= nil and rank:GetRank() >= RankDefs.RANK.S
            and (tonumber(super_growth.KILL_EXP_MULT) or 2) or 1
        local exp_multiplier = effects ~= nil
            and effects:GetExpMultiplier(victim.hh_is_dungeon_monster or victim.hh_is_dungeon_boss) or 1
        local achievement_multiplier = require("achievement/ttk_perk_effects").GetXPMultiplier(player)
        local amount = math.max(1, math.floor(meta.exp * HHGetLevelFactor(player, meta)
            * rank_multiplier * exp_multiplier * achievement_multiplier / #recipients + 0.5))
        if player.components.hh_leveling:AddExp(amount) then
            HHUtils:SpawnClientStrFx(player, "+" .. tostring(amount) .. " EXP")
        end
    end
end

local function HHResolveSharkboiDefeatKiller(attacker)
    return cffUucfkn:GetKillCreditPlayer(attacker)
end

local RULER_TARGETING_RETRY_INTERVAL = 0.05
local RULER_TARGETING_MAX_ATTEMPTS = 40

local function CancelLocalRulerTargetingRetry(player)
    if player ~= nil and player._hh_ruler_targeting_retry ~= nil then
        player._hh_ruler_targeting_retry:Cancel()
        player._hh_ruler_targeting_retry = nil
    end
end

local function IsLocalRulerTargetingPlayer(player)
    return player ~= nil
        and player:IsValid()
        and TheNet ~= nil
        and not TheNet:IsDedicated()
        and ThePlayer ~= nil
        and ThePlayer == player
end

local function IsRulerReticuleActive(controller, caster)
    return controller ~= nil
        and controller.reticule ~= nil
        and controller.reticule.inst == caster
        and controller:IsAOETargeting()
end

local function TryStartLocalRulerTargeting(player)
    if not IsLocalRulerTargetingPlayer(player) then
        return false
    end

    local caster_netvar = player.hh_ruler_caster
    local caster = caster_netvar ~= nil and caster_netvar:value() or nil
    if caster == nil or not caster:IsValid() then
        return false
    end

    local controller = player.components ~= nil and player.components.playercontroller or nil
    if controller == nil then
        return false
    end

    if IsRulerReticuleActive(controller, caster) then
        return true
    end

    if caster.StartRulerTargeting == nil
        or not caster:StartRulerTargeting() then
        return false
    end

    player:PushEvent("hh_ruler_targetingstarted")
    return true
end

local function StartLocalRulerTargeting(player)
    if not IsLocalRulerTargetingPlayer(player) then
        return false
    end

    if TryStartLocalRulerTargeting(player) then
        CancelLocalRulerTargetingRetry(player)
        return true
    end

    if player._hh_ruler_targeting_retry == nil then
        local attempts = 0
        player._hh_ruler_targeting_retry = player:DoPeriodicTask(
            RULER_TARGETING_RETRY_INTERVAL,
            function(inst)
                attempts = attempts + 1

                if not IsLocalRulerTargetingPlayer(inst) then
                    CancelLocalRulerTargetingRetry(inst)
                    return
                end

                local caster_netvar = inst.hh_ruler_caster
                local caster = caster_netvar ~= nil and caster_netvar:value() or nil
                if caster == nil or not caster:IsValid() then
                    CancelLocalRulerTargetingRetry(inst)
                    return
                end

                if TryStartLocalRulerTargeting(inst)
                    or attempts >= RULER_TARGETING_MAX_ATTEMPTS then
                    CancelLocalRulerTargetingRetry(inst)
                end
            end
        )
    end

    return false
end

local function CancelStaleLocalRulerTargeting(player)
    local controller = player ~= nil
        and player.components ~= nil
        and player.components.playercontroller or nil
    local reticule = controller ~= nil and controller.reticule or nil
    if reticule ~= nil
        and reticule.inst ~= nil
        and reticule.inst:HasTag("hh_ruler_caster") then
        controller._hh_ruler_suppress_cancel = true
        controller:CancelAOETargeting()
        controller._hh_ruler_suppress_cancel = nil
    end
end

local function HandleLocalRulerTargetingSignal(player)
    if not IsLocalRulerTargetingPlayer(player) then
        return
    end

    local caster_netvar = player.hh_ruler_caster
    local caster = caster_netvar ~= nil and caster_netvar:value() or nil
    if caster == nil or not caster:IsValid() then
        CancelLocalRulerTargetingRetry(player)
        CancelStaleLocalRulerTargeting(player)
        return
    end

    StartLocalRulerTargeting(player)
end

AddPrefabPostInit(
    "sharkboi",
    function(inst)
        if not TheWorld.ismastersim then return end

        inst:ListenForEvent("minhealth", function(inst, data)
            if inst.hh_sharkboi_minhealth_seen then return end
            inst.hh_sharkboi_minhealth_seen = true
            inst.hh_sharkboi_defeat_afflicter = data and data.afflicter or nil
        end)

        inst:ListenForEvent("newstate", function(inst)
            if inst.hh_sharkboi_defeat_exp_checked
                or not inst.sg
                or not inst.sg:HasStateTag("defeated") then
                return
            end
            inst.hh_sharkboi_defeat_exp_checked = true
            local killer = HHResolveSharkboiDefeatKiller(inst.hh_sharkboi_defeat_afflicter)
            if killer ~= nil then
                HHAwardKillExp(killer, inst)
            end
        end)
    end
)

AddPrefabPostInit(
    "daywalker",
    function(inst)
        if not TheWorld.ismastersim then return end

        inst:ListenForEvent("minhealth", function(inst, data)
            if inst.hh_daywalker_minhealth_seen then return end
            inst.hh_daywalker_minhealth_seen = true
            inst.hh_daywalker_defeat_afflicter = data and data.afflicter or nil
        end)

        inst:ListenForEvent("newstate", function(inst)
            if inst.hh_daywalker_defeat_exp_checked
                or not inst.sg
                or not inst.sg:HasStateTag("defeated") then
                return
            end
            inst.hh_daywalker_defeat_exp_checked = true
            local killer = HHResolveSharkboiDefeatKiller(inst.hh_daywalker_defeat_afflicter)
            if killer ~= nil then
                HHAwardKillExp(killer, inst)
            end
        end)
    end
)

AddPlayerPostInit(
    function(gfkuicnKi)
        gfkuicnKi.hh_arise_cd = net_shortint(gfkuicnKi.GUID, "hh_arise_cd", "hh_arise_cddirty")
        gfkuicnKi.hh_arise_cd_total = net_shortint(gfkuicnKi.GUID, "hh_arise_cd_total", "hh_arise_cd_totaldirty")
        gfkuicnKi.hh_recall_cd = net_shortint(gfkuicnKi.GUID, "hh_recall_cd", "hh_recall_cddirty")
        gfkuicnKi.hh_recall_cd_total = net_shortint(gfkuicnKi.GUID, "hh_recall_cd_total", "hh_recall_cd_totaldirty")
        gfkuicnKi.hh_swap_cd = net_shortint(gfkuicnKi.GUID, "hh_swap_cd", "hh_swap_cddirty")
        gfkuicnKi.hh_swap_cd_total = net_shortint(gfkuicnKi.GUID, "hh_swap_cd_total", "hh_swap_cd_totaldirty")
        gfkuicnKi.hh_sanctuary_cd = net_shortint(gfkuicnKi.GUID, "hh_sanctuary_cd", "hh_sanctuary_cddirty")
        gfkuicnKi.hh_sanctuary_cd_total = net_shortint(gfkuicnKi.GUID, "hh_sanctuary_cd_total", "hh_sanctuary_cd_totaldirty")
        gfkuicnKi.hh_godslayer_cd = net_shortint(gfkuicnKi.GUID, "hh_godslayer_cd", "hh_godslayer_cddirty")
        gfkuicnKi.hh_godslayer_cd_total = net_shortint(gfkuicnKi.GUID, "hh_godslayer_cd_total", "hh_godslayer_cd_totaldirty")
        gfkuicnKi.hh_ruler_cd = net_shortint(gfkuicnKi.GUID, "hh_ruler_cd", "hh_ruler_cddirty")
        gfkuicnKi.hh_ruler_cd_total = net_shortint(gfkuicnKi.GUID, "hh_ruler_cd_total", "hh_ruler_cd_totaldirty")
        gfkuicnKi.hh_ruler_caster = net_entity(gfkuicnKi.GUID, "hh_ruler_caster", "hh_ruler_casterdirty")
        gfkuicnKi.hh_king_cd = net_shortint(gfkuicnKi.GUID, "hh_king_cd", "hh_king_cddirty")
        gfkuicnKi.hh_king_cd_total = net_shortint(gfkuicnKi.GUID, "hh_king_cd_total", "hh_king_cd_totaldirty")
        gfkuicnKi.hh_death_threshold_cd = net_shortint(
            gfkuicnKi.GUID,
            "hh_death_threshold_cd",
            "hh_death_threshold_cddirty"
        )
        gfkuicnKi.hh_shadows_cd = net_string(gfkuicnKi.GUID, "hh_shadows_cd", "hh_shadows_cddirty")
        gfkuicnKi.hh_has_shadows = net_bool(gfkuicnKi.GUID, "hh_has_shadows", "hh_has_shadowsdirty")
        gfkuicnKi.hh_shadow_count = net_tinybyte(gfkuicnKi.GUID, "hh_shadow_count", "hh_shadow_countdirty")
        gfkuicnKi.hh_shadow_max = net_tinybyte(gfkuicnKi.GUID, "hh_shadow_max", "hh_shadow_maxdirty")
        for _, prefab in ipairs(ShadowProgressionDefs.ORDER) do
            local level_field = ShadowProgressionDefs.GetNetField(prefab, "level")
            local exp_field = ShadowProgressionDefs.GetNetField(prefab, "exp")
            local points_field = ShadowProgressionDefs.GetNetField(prefab, "points")
            local talents_field = ShadowProgressionDefs.GetNetField(prefab, "talents")
            gfkuicnKi[level_field] = net_smallbyte(gfkuicnKi.GUID, level_field, "hh_shadow_profiledirty")
            gfkuicnKi[exp_field] = net_int(gfkuicnKi.GUID, exp_field, "hh_shadow_profiledirty")
            gfkuicnKi[points_field] = net_tinybyte(gfkuicnKi.GUID, points_field, "hh_shadow_profiledirty")
            gfkuicnKi[talents_field] = net_ushortint(gfkuicnKi.GUID, talents_field, "hh_shadow_profiledirty")
        end
        
        gfkuicnKi.hh_lv_level = net_shortint(gfkuicnKi.GUID, "hh_lv_level", "hh_lv_leveldirty")
        gfkuicnKi.hh_lv_exp = net_int(gfkuicnKi.GUID, "hh_lv_exp", "hh_lv_expdirty")
        gfkuicnKi.hh_lv_exp_goal = net_int(gfkuicnKi.GUID, "hh_lv_exp_goal", "hh_lv_exp_goaldirty")
        gfkuicnKi.hh_lv_ap = net_shortint(gfkuicnKi.GUID, "hh_lv_ap", "hh_lv_apdirty")
        gfkuicnKi.hh_lv_str = net_shortint(gfkuicnKi.GUID, "hh_lv_str", "hh_lv_strdirty")
        gfkuicnKi.hh_lv_agi = net_shortint(gfkuicnKi.GUID, "hh_lv_agi", "hh_lv_agidirty")
        gfkuicnKi.hh_lv_vit = net_shortint(gfkuicnKi.GUID, "hh_lv_vit", "hh_lv_vitdirty")
        gfkuicnKi.hh_lv_sen = net_shortint(gfkuicnKi.GUID, "hh_lv_sen", "hh_lv_sendirty")
        gfkuicnKi.hh_lv_int = net_shortint(gfkuicnKi.GUID, "hh_lv_int", "hh_lv_intdirty")
        gfkuicnKi.hh_mana_current = net_ushortint(gfkuicnKi.GUID, "hh_mana_current", "hh_mana_currentdirty")
        gfkuicnKi.hh_mana_max = net_ushortint(gfkuicnKi.GUID, "hh_mana_max", "hh_mana_maxdirty")

        gfkuicnKi.hh_exp_seal_deadline = net_int(gfkuicnKi.GUID, 'hh_exp_seal_deadline', 'hh_exp_seal_deadlinedirty')

        gfkuicnKi.hh_quest_id = net_byte(gfkuicnKi.GUID, 'hh_quest_id', 'hh_quest_iddirty')
        gfkuicnKi.hh_quest_progress = net_ushortint(gfkuicnKi.GUID, 'hh_quest_progress', 'hh_quest_progressdirty')
        gfkuicnKi.hh_quest_target = net_ushortint(gfkuicnKi.GUID, 'hh_quest_target', 'hh_quest_targetdirty')
        gfkuicnKi.hh_quest_reward = net_int(gfkuicnKi.GUID, 'hh_quest_reward', 'hh_quest_rewarddirty')
        gfkuicnKi.hh_quest_status = net_tinybyte(gfkuicnKi.GUID, 'hh_quest_status', 'hh_quest_statusdirty')
        gfkuicnKi.hh_quest_deadline = net_int(gfkuicnKi.GUID, 'hh_quest_deadline', 'hh_quest_deadlinedirty')
        gfkuicnKi.hh_quest_failure = net_string(gfkuicnKi.GUID, 'hh_quest_failure', 'hh_quest_failuredirty')

        if TheNet ~= nil and not TheNet:IsDedicated() then
            gfkuicnKi:ListenForEvent("hh_ruler_casterdirty", HandleLocalRulerTargetingSignal)
            gfkuicnKi:ListenForEvent("hh_ruler_targetingready", HandleLocalRulerTargetingSignal)
        end

        if not gfkuicnKi["components"]["hh_client"] then
            gfkuicnKi:AddComponent("hh_client")
        end
        if not TheWorld["ismastersim"] then
            return gfkuicnKi
        end
        gfkuicnKi._hh_kill_credit_disconnected = false
        gfkuicnKi:ListenForEvent("ms_playerleft", function(_, player)
            if player == gfkuicnKi then
                gfkuicnKi._hh_kill_credit_disconnected = true
            end
        end, TheWorld)
        if not gfkuicnKi["components"]["hh_player"] then
            gfkuicnKi:AddComponent("hh_player")
        end
        if not gfkuicnKi["components"]["hh_buff"] then
            gfkuicnKi:AddComponent("hh_buff")
        end
        if not gfkuicnKi["components"]["hh_shadow_manager"] then
            gfkuicnKi:AddComponent("hh_shadow_manager")
        end
        if not gfkuicnKi["components"]["hh_shadow_progression"] then
            gfkuicnKi:AddComponent("hh_shadow_progression")
        end
        if not gfkuicnKi["components"]["hh_leveling"] then
            gfkuicnKi:AddComponent("hh_leveling")
        end
        if not gfkuicnKi["components"]["hh_mana"] then
            gfkuicnKi:AddComponent("hh_mana")
        end
        if not gfkuicnKi['components']['hh_slot_lock_penalty'] then
            gfkuicnKi:AddComponent('hh_slot_lock_penalty')
        end
        if not gfkuicnKi['components']['hh_daily_quest'] then
            gfkuicnKi:AddComponent('hh_daily_quest')
        end
        
        gfkuicnKi:ListenForEvent("killed", function(inst, data)
            if data and data.victim then
                HHAwardKillExp(inst, data.victim)
            end
        end)
        
        gfkuicnKi:ListenForEvent("itemget", function(inst, data)
            if data and data.item and data.item.AddTag then
                data.item:AddTag("hh_player_touched")
            end
        end)
        
        gfkuicnKi:ListenForEvent("dropitem", function(inst, data)
            if data and data.item and data.item.AddTag then
                data.item:AddTag("hh_player_touched")
            end
        end)

        gfkuicnKi["hh_skin_list"] = {}
        local nfnucCcKk = gfkuicnKi["OnPreLoad"]
        gfkuicnKi["OnPreLoad"] = function(gfkuicnKi, ffuufcnki)
            if ffuufcnki and ffuufcnki["hh_skin_list"] then
                gfkuicnKi["hh_skin_list"] = ffuufcnki["hh_skin_list"]
            end
            if nfnucCcKk then
                nfnucCcKk(gfkuicnKi, ffuufcnki)
            end
        end
        local ffuUgCcKg = gfkuicnKi["OnSave"]
        gfkuicnKi["OnSave"] = function(gfkuicnKi, ffguuCfKf)
            if ffguuCfKf and gfkuicnKi["hh_skin_list"] then
                ffguuCfKf["hh_skin_list"] = gfkuicnKi["hh_skin_list"]
            end
            if ffuUgCcKg then
                ffuUgCcKg(gfkuicnKi, ffguuCfKf)
            end
        end
    end
)

-- A locked equipment item must not enter DST's backpack-swap branch.
-- That branch assumes Inventory:Unequip() always returns an item before
-- passing it to Inventory:GiveItem(), but a locked item intentionally returns
-- nil from Unequip(). Reject the pickup during BufferedAction validation so
-- the vanilla action never reaches that unsafe call.
local function HHIsDailySlotLockPickupBlocked(action)
    local doer = action ~= nil and action.doer or nil
    local target = action ~= nil and action.target or nil
    local doer_components = doer ~= nil and doer.components or nil
    local inventory = doer_components ~= nil and doer_components.inventory or nil
    local slot_lock = doer_components ~= nil and doer_components.hh_slot_lock_penalty or nil
    local target_components = target ~= nil and target.components or nil
    local target_inventoryitem = target_components ~= nil and target_components.inventoryitem or nil
    local target_equippable = target_components ~= nil and target_components.equippable or nil

    -- Slot-lock prefabs are internal punishment artifacts, never world loot.
    -- Keep this validation tag-scoped; do not alter pickup rules globally.
    if target ~= nil and target:HasTag("hh_daily_slot_lock") then
        return true
    end

    if doer == nil or inventory == nil or slot_lock == nil
        or target_inventoryitem == nil or target_equippable == nil
        or target_inventoryitem.cangoincontainer
        or target_equippable:IsRestricted(doer) then
        return false
    end

    local equipped = inventory:GetEquippedItem(target_equippable.equipslot)
    return doer.userid ~= nil
        and equipped ~= nil
        and equipped.components ~= nil
        and equipped.components.equippable ~= nil
        and equipped.components.equippable:ShouldPreventUnequipping()
        and slot_lock:IsOwnedLockItem(equipped)
end

if ACTIONS ~= nil and ACTIONS.PICKUP ~= nil
    and not ACTIONS.PICKUP.hh_daily_slot_lock_validfn then
    local previous_pickup_validfn = ACTIONS.PICKUP.validfn
    ACTIONS.PICKUP.validfn = function(action, ...)
        if HHIsDailySlotLockPickupBlocked(action) then
            return false, "hh_daily_slot_locked"
        end
        return previous_pickup_validfn == nil
            or previous_pickup_validfn(action, ...)
    end
    ACTIONS.PICKUP.hh_daily_slot_lock_validfn = true
end

AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim or not TUNING.HH_MOB_EXP[inst.prefab]
        or inst.prefab == "crabking_mob" or inst.prefab == "crabking_mob_knight" then return end
    inst:DoTaskInTime(0, function(monster)
        if not monster:IsValid() or monster.hh_is_dungeon_monster or monster.hh_balance_applied then return end
        if not monster.components.health or not monster.components.combat then return end
        monster.hh_balance_applied = true
        local class = TUNING.HH_BOSS_PREFABS[monster.prefab] and "boss"
            or TUNING.HH_MINIBOSS_PREFABS[monster.prefab] and "miniboss"
            or "normal"
        local balance = TUNING.HH_MONSTER_BALANCE[class]
        if not balance then return end

        local health_percent = monster.components.health:GetPercent()
        monster.components.health:SetMaxHealth(monster.components.health.maxhealth * balance.health)
        monster.components.health:SetPercent(health_percent)
        monster.components.combat.defaultdamage = (monster.components.combat.defaultdamage or 0) * balance.damage
        if monster.hh_damage then monster.hh_damage = monster.hh_damage * balance.damage end
        if monster.hh_magic_damage then monster.hh_magic_damage = monster.hh_magic_damage * balance.damage end
    end)
end)
local gfcUuCikn = (309 - 231 * 438 == -100869)
local kFkuuCgKf = true
TUNING["MODEQUIP"] = true
if kFkuuCgKf then
    AddPrefabPostInitAny(
        function(iffUkcnkg)
            if not TheWorld["ismastersim"] then
                return iffUkcnkg
            end
            if
                cffUucfkn:HasComponents(iffUkcnkg, "equippable") and not cffUucfkn:HasComponents(iffUkcnkg, "stackable") and
                    cffUucfkn:HasComponents(iffUkcnkg, "inspectable") and
                    cffUucfkn:HasComponents(iffUkcnkg, "inventoryitem") and
                    not iffUkcnkg:HasTag("hh_limit")
             then
                if not iffUkcnkg["components"]["hh_equip"] then
                    iffUkcnkg:AddTag("hh_equip")
                    local ffcuiCgKi = cfnUcCcku(iffUkcnkg)
                    iffUkcnkg:AddComponent("hh_equip")
                    iffUkcnkg["components"]["hh_equip"]:SetMaxGemLimit(3)
                    iffUkcnkg["components"]["hh_equip"]:SetEquipBuffLimit(ffcuiCgKi or 1)
                end
            end
        end
    )
else
    for nFfUucfKu, iFfukCikf in ipairs(nffugciKk) do
        if iFfukCikf and iFfukCikf["id"] then
            AddPrefabPostInit(
                iFfukCikf["id"],
                function(cFnUfCiKn)
                    cFnUfCiKn:AddTag("hh_equip")
                    if not TheWorld["ismastersim"] then
                        return cFnUfCiKn
                    end
                    if not cFnUfCiKn["components"]["hh_equip"] then
                        local fFuuncgku = cfnUcCcku(cFnUfCiKn)
                        cFnUfCiKn:AddComponent("hh_equip")
                        cFnUfCiKn["components"]["hh_equip"]:SetMaxGemLimit(3)
                        cFnUfCiKn["components"]["hh_equip"]:SetEquipBuffLimit(fFuuncgku or 1)
                    end
                end
            )
        end
    end
end
if gfcUuCikn then
    for cffUuCcKi, uffuiCnKi in ipairs(kfgUcCnkg) do
        if uffuiCnKi and uffuiCnKi["id"] then
            AddPrefabPostInit(
                uffuiCnKi["id"],
                function(kFuuccckc)
                    if not TheWorld["ismastersim"] then
                        return kFuuccckc
                    end
                    if not kFuuccckc["components"]["hh_monster"] then
                        kFuuccckc:AddComponent("hh_monster")
                        kFnUuckkg(kFuuccckc)
                        kFuuccckc["HasHHTag"] = gfnUuCuku
                    end
                    if not kFuuccckc["components"]["hh_buff"] then
                        kFuuccckc:AddComponent("hh_buff")
                    end
                end
            )
        end
    end
end
if "3" == "1" then -- độ khó cố định ở mức cao nhất ("3"), luôn đi nhánh else
    TUNING["FIRSTHEALTH"] = (153 + 429 + 42 + 345 == 969)
else
    TUNING["FIRSTHEALTH"] = (145 - 153 + 259 + 102 == 363)
end
AddComponentPostInit(
    "health",
    function(self)
        self["hh_base_max"] = 0

        local function IsCrabKingMinion(inst)
            return inst ~= nil
                and (inst.prefab == "crabking_mob" or inst.prefab == "crabking_mob_knight")
        end

        local function IsRulerNoHealActive(inst)
            return inst ~= nil and inst:HasTag("hh_ruler_no_heal")
        end

        local DEATH_THRESHOLD_REGEN_CAUSE = "hh_death_threshold_regen"

        local function ClampRulerNoHealIncrease(health, value, cause)
            if cause ~= DEATH_THRESHOLD_REGEN_CAUSE
                and IsRulerNoHealActive(health["inst"])
                and type(value) == "number"
                and type(health["currenthealth"]) == "number"
                and value > health["currenthealth"] then
                return health["currenthealth"]
            end
            return value
        end

        local old_SetCurrentHealth = self["SetCurrentHealth"]
        self["SetCurrentHealth"] = function(self, value, ...)
            old_SetCurrentHealth(self, ClampRulerNoHealIncrease(self, value, nil), ...)
        end

        local old_SetVal = self["SetVal"]
        self["SetVal"] = function(self, value, ...)
            local death_threshold_guard = self["_hh_death_threshold_guard"]
            local death_threshold = death_threshold_guard ~= nil
                and death_threshold_guard.component or nil
            if death_threshold ~= nil
                and type(value) == "number"
                and value <= 0
                and death_threshold:MarkDamageGuardPrevented(death_threshold_guard) then
                value = 1
            end
            local cause = select(1, ...)
            old_SetVal(self, ClampRulerNoHealIncrease(self, value, cause), ...)
        end

        local old_OnSave = self["OnSave"]
        self["OnSave"] = function(self, ...)
            local data = old_OnSave(self, ...)
            if IsCrabKingMinion(self["inst"])
                and type(data) == "table"
                and type(self["hh_base_max"]) == "number"
                and self["hh_base_max"] > 0 then
                data["hh_base_max"] = self["hh_base_max"]
            end
            return data
        end

        local old_OnLoad = self["OnLoad"]
        self["OnLoad"] = function(self, data, ...)
            old_OnLoad(self, data, ...)
            if IsCrabKingMinion(self["inst"])
                and type(data) == "table"
                and type(data["hh_base_max"]) == "number"
                and data["hh_base_max"] > 0 then
                self["hh_base_max"] = data["hh_base_max"]
            end
        end

        local kFcUccukf = self["SetMaxHealth"]
        self["SetMaxHealth"] = function(self, cfiUiciKi, ...)
            local old_currenthealth = self["currenthealth"]
            self["hh_base_max"] = cfiUiciKi
            if IsRulerNoHealActive(self["inst"]) then
                self["maxhealth"] = cfiUiciKi
                old_SetCurrentHealth(self, math.min(old_currenthealth, self:GetMaxWithPenalty()))
                self:ForceUpdateHUD(true)
            else
                kFcUccukf(self, cfiUiciKi, ...)
            end
            self["inst"]:PushEvent("hh_change_max_health")
        end
        local gfuUgcuKg = self["DoDelta"]
        self["DoDelta"] = function(self, nfnugckkc, iFuugCckg, iFiunckKf, uffunccKu, nffuiCgkc, ...)
            local was_alive = not self:IsDead()
            local is_death_threshold_regen = iFiunckKf == DEATH_THRESHOLD_REGEN_CAUSE
            if not is_death_threshold_regen and IsRulerNoHealActive(self["inst"])
                and type(nfnugckkc) == "number"
                and nfnugckkc > 0 then
                nfnugckkc = 0
            end
            local suppression_player = self.inst.components.hh_player
            local suppression_monster = self.inst.components.hh_monster
            if not is_death_threshold_regen and type(nfnugckkc) == "number" and nfnugckkc > 0
                and ((suppression_player ~= nil and suppression_player:HasSpecialEffect("healthSuppressNum"))
                    or (suppression_monster ~= nil and suppression_monster:HasSpecialEffect("healthSuppressNum"))) then
                nfnugckkc = nfnugckkc * .1
            end
            local previous_death_threshold_guard = self["_hh_death_threshold_guard"]
            local death_threshold = self["inst"]["components"] ~= nil
                and self["inst"]["components"]["hh_death_threshold"] or nil
            local death_threshold_guard = nil
            if not is_death_threshold_regen
                and cffUucfkn:IsHHType(nfnugckkc, "number")
                and nfnugckkc < 0
                and death_threshold ~= nil then
                death_threshold_guard = death_threshold:ArmDamageGuard()
            end
            self["_hh_death_threshold_guard"] = death_threshold_guard

            local iFguucikc = 0
            if gfuUgcuKg then
                iFguucikc = gfuUgcuKg(self, nfnugckkc, iFuugCckg, iFiunckKf, uffunccKu, nffuiCgkc, ...)
            end
            self["_hh_death_threshold_guard"] = previous_death_threshold_guard
            local death_threshold_prevented = death_threshold_guard ~= nil
                and death_threshold_guard.prevented == true
            if death_threshold_guard ~= nil and death_threshold_guard.prevented then
                death_threshold:FinishDamageGuard(death_threshold_guard)
            end
            local hit = require("combat/hh_combat_context").Current(nffuiCgkc, self.inst)
            if hit ~= nil and death_threshold_prevented then hit.death_threshold_prevented = true end
            if cffUucfkn:IsValidCombat(self.inst)
                and require("combat/hh_combat_context").PacketKind() == nil
                and cffUucfkn:HasComponents(nffuiCgkc, "hh_monster")
                and type(iFguucikc) == "number" and iFguucikc < 0 then
                nffuiCgkc.components.hh_monster:HandleBloodSuck(iFguucikc)
            end
            
            local executer = nil
            local function FindPlayerOwner(ent)
                return cffUucfkn:GetKillCreditPlayer(ent)
            end

            executer = FindPlayerOwner(nffuiCgkc)
            
            if not executer then
                if (iFiunckKf == "fire" or iFiunckKf == "shadow_fire" or iFiunckKf == "lunar_fire") and cffUucfkn:HasComponents(self["inst"], "burnable") then
                    executer = FindPlayerOwner(self["inst"]["components"]["burnable"]["attacker"])
                elseif iFiunckKf == "hh_poison" and cffUucfkn:HasComponents(self["inst"], "hh_buff") then
                    executer = FindPlayerOwner(self["inst"]["components"]["hh_buff"]["hh_poison_attacker"])
                end
                
                if not executer and cffUucfkn:HasComponents(self["inst"], "debuffable") and self["inst"]["components"]["debuffable"].debuffs then
                    for k, v in pairs(self["inst"]["components"]["debuffable"].debuffs) do
                        if v and v.inst and (string.find(k, "fire") or string.find(k, "flame") or string.find(k, "burn") or string.find(k, "combust")) then
                            local debuff_owner = FindPlayerOwner(v.inst)
                            if debuff_owner then
                                executer = debuff_owner
                                break
                            end
                        end
                    end
                end
            end


            if was_alive and self:IsDead() then
                local kill_source = nffuiCgkc or executer
                if kill_source ~= nil then
                    cffUucfkn:RelayKillToOwner(
                        kill_source,
                        { ["victim"] = self["inst"], ["attacker"] = kill_source }
                    )
                end
            end
            
            return iFguucikc
        end
        self["DoHHDelta"] = function(self, ufnUfcgkc, uFgucciKu, uFkUkCnkn)
            if
                not cffUucfkn:IsHHType(ufnUfcgkc, "number") or ufnUfcgkc >= 0 or
                    not cffUucfkn:HasComponents(uFgucciKu, "combat")
             then
                return (230 + 233 - 254 == 215)
            end
            local ifcUgckKk = self:GetPercent()
            if
                self["maxdamagetakenperhit"] ~= nil and ufnUfcgkc < self["maxdamagetakenperhit"] and
                    not self["_ignore_maxdamagetakenperhit"]
             then
                ufnUfcgkc = self["maxdamagetakenperhit"]
            end
            if cffUucfkn:IsHHType(uFkUkCnkn, "string") then
                cffUucfkn:SpawnClientStrFx(self["inst"], uFkUkCnkn)
            end
            local iFkukCkKi = "hh_true_damage"
            local previous_death_threshold_guard = self["_hh_death_threshold_guard"]
            local death_threshold = self["inst"]["components"] ~= nil
                and self["inst"]["components"]["hh_death_threshold"] or nil
            local death_threshold_guard = death_threshold ~= nil
                and death_threshold:ArmDamageGuard() or nil
            self["_hh_death_threshold_guard"] = death_threshold_guard
            self:SetVal(self["currenthealth"] + ufnUfcgkc, iFkukCkKi, uFgucciKu)
            self["_hh_death_threshold_guard"] = previous_death_threshold_guard
            if death_threshold_guard ~= nil and death_threshold_guard.prevented then
                death_threshold:FinishDamageGuard(death_threshold_guard)
            end
            self["inst"]:PushEvent(
                "healthdelta",
                {
                    ["oldpercent"] = ifcUgckKk,
                    ["newpercent"] = self:GetPercent(),
                    ["overtime"] = nil,
                    ["cause"] = iFkukCkKi,
                    ["afflicter"] = uFgucciKu,
                    ["amount"] = ufnUfcgkc
                }
            )
            if self["ondelta"] ~= nil then
                self["ondelta"](
                    self["inst"],
                    ifcUgckKk,
                    self:GetPercent(),
                    nil,
                    iFkukCkKi,
                    uFgucciKu,
                    ufnUfcgkc
                )
            end
            if self:IsDead() then
                cffUucfkn:RelayKillToOwner(
                    uFgucciKu,
                    { ["victim"] = self["inst"], ["attacker"] = uFgucciKu }
                )
                uFgucciKu:PushEvent("killed", {["victim"] = self["inst"], ["attacker"] = uFgucciKu})
                if
                    cffUucfkn:HasComponents(self["inst"], "combat") and
                        self["inst"]["components"]["combat"]["onkilledbyother"]
                 then
                    self["inst"]["components"]["combat"]["onkilledbyother"](self["inst"], uFgucciKu)
                end
            end
            return (268 - 192 + 409 * 31 * 268 == 3398048)
        end
    end
)
local HH_FOLLOWER_CRITICAL_PREFABS = {
    hh_igris_shadow = true,
    hh_beru_shadow = true,
    hh_hacanh_shadow = true,
}

local CombatMath = require("combat/hh_combat_math")
local CombatContext = require("combat/hh_combat_context")
local SpDamageUtil = require("components/spdamageutil")
if not SpDamageUtil._SpTypeMap.hh_armor_pierce then
    SpDamageUtil.DefineSpType("hh_armor_pierce", {
        GetDamage = function() return 0 end,
        GetDefense = function() return 0 end,
        GetTakenMult = function(ent)
            local combat = ent.components ~= nil and ent.components.combat or nil
            if combat == nil then return 1 end
            local attacker = combat.lastattacker
            local hit = CombatContext.Current(attacker, combat.redirected_from or ent)
            local mult = combat.externaldamagetakenmultipliers:Get()
            if hit ~= nil and combat.conditionexternaldamagetakenmultipliers ~= nil then
                mult = mult * combat:ApplyConditionExternalDamageTakenMultiplier(1, attacker, hit.weapon)
            end
            -- Combat already applies damage-type resistance to special damage.
            -- These extra factors preserve the non-armor defense of the receiver.
            return mult
        end,
    })
end
if not SpDamageUtil._SpTypeMap.hh_poison then
    SpDamageUtil.DefineSpType("hh_poison", {
        GetDamage = function() return 0 end,
        GetDefense = function() return 0 end,
        GetTakenMult = SpDamageUtil._SpTypeMap.hh_armor_pierce.GetTakenMult,
    })
end
local function PackHitResults(...)
    return {n = select("#", ...), ...}
end

local function ApplyFollowerHitModifier(normal, spdamage, player, modifier)
    local pierce = spdamage ~= nil and spdamage.hh_armor_pierce or 0
    local total = normal + pierce
    local adjusted = modifier(player, total)
    if pierce > 0 and total > 0 then
        local adjusted_pierce = adjusted * pierce / total
        spdamage.hh_armor_pierce = adjusted_pierce
        return adjusted - adjusted_pierce
    end
    return adjusted
end

local function ApplyFollowerCritical(attacker, target, damage, rng)
    if attacker == nil
        or not HH_FOLLOWER_CRITICAL_PREFABS[attacker["prefab"]]
        or not cffUucfkn:IsHHType(damage, "number")
        or damage <= 0
        or not cffUucfkn:NotIsDead(attacker)
        or cffUucfkn:HasComponents(attacker, "hh_monster")
        or not cffUucfkn:HasComponents(attacker, "follower") then
        return damage
    end

    local follower = attacker["components"]["follower"]
    local leader = follower["leader"]
    if not cffUucfkn:HasComponents(leader, "hh_player") then
        return damage
    end

    local player_effects = leader["components"]["hh_player"]
    if not player_effects:HasSpecialEffect("addFollowCritical") then
        return damage
    end

    local critical_rate = player_effects:GetEffectValueByKey("addFollowCritical")
    local critical = CombatMath.RollPercent(critical_rate, rng or math.random)
    local metadata = CombatContext.Current(attacker, target)
    if metadata ~= nil then metadata.critical = critical end
    if critical then
        -- hh_monster uses 2 + criticalHitEffect / 100. These combat Shadow
        -- prefabs intentionally have no hh_monster/effect store, while
        -- followCritical only supplies the chance, so the existing zero-effect
        -- base multiplier is x2. Keep the monster path above unchanged.
        return damage * 2
    end
    return damage
end

AddComponentPostInit(
    "combat",
    function(self)
        local cFfuucgkc = self["GetAttacked"]
        self["GetAttacked"] = function(self, nfkuccnkc, kFuuncgKg, weapon, stimuli, spdamage, ...)
            -- Vanilla forwards an already-resolved packet when mounting/parrying
            -- redirects a hit. Carry its context and rank guard, without rerolls.
            local redirected = self.redirected_from ~= nil
                and CombatContext.Current(nfkuccnkc, self.redirected_from) or nil
            if redirected ~= nil then
                local previous = self.inst._hh_world_rank_combat_damage_source
                self.inst._hh_world_rank_combat_damage_source = self.redirected_from._hh_world_rank_combat_damage_source
                local token = CombatContext.Begin(nfkuccnkc, self.inst, redirected)
                local results = PackHitResults(pcall(cFfuucgkc, self, nfkuccnkc, kFuuncgKg, weapon, stimuli, spdamage, ...))
                self.inst._hh_world_rank_combat_damage_source = previous
                CombatContext.Finish(token)
                if not results[1] then error(results[2], 0) end
                return unpack(results, 2, results.n)
            end
            local packet_kind = CombatContext.PacketKind()
            if packet_kind ~= nil then
                local defender = self.inst.components.hh_player
                local monster = self.inst.components.hh_monster
                local reduction = defender ~= nil and defender:GetPhamNhanReduction()
                    or monster ~= nil and monster:GetEffectValueByKey("reducePercentDamage") or 0
                kFuuncgKg = CombatMath.ApplyReduction(kFuuncgKg or 0, reduction)
                if spdamage ~= nil then
                    local copy = {}
                    for key, value in pairs(spdamage) do
                        copy[key] = key == "hh_poison" and CombatMath.ApplyReduction(value, reduction) or value
                    end
                    spdamage = copy
                end
                local metadata = {attacker = nfkuccnkc, target = self.inst, weapon = weapon}
                local token = CombatContext.Begin(nfkuccnkc, self.inst, metadata)
                local results = PackHitResults(pcall(cFfuucgkc, self, nfkuccnkc, kFuuncgKg, weapon, stimuli, spdamage, ...))
                CombatContext.Finish(token)
                if not results[1] then error(results[2], 0) end
                if packet_kind == "splash" and metadata.event ~= nil
                    and cffUucfkn:HasComponents(nfkuccnkc, "hh_player") then
                    nfkuccnkc.components.hh_player:HandleBloodSuck(metadata.event.damageresolved or 0, "splash")
                end
                return unpack(results, 2, results.n)
            end
            if type(kFuuncgKg) ~= "number" or kFuuncgKg <= 0
                or not cffUucfkn:NotIsDead(nfkuccnkc) or not cffUucfkn:NotIsDead(self.inst) then
                return cFfuucgkc(self, nfkuccnkc, kFuuncgKg, weapon, stimuli, spdamage, ...)
            end
            local defender = self.inst.components.hh_player
            if defender ~= nil and stimuli ~= "hh_unavoidable" and defender:TryDodge(nfkuccnkc) then return false end
            local args = PackHitResults(...)
            local token = CombatContext.Begin(nfkuccnkc, self.inst, {weapon = weapon, critical = false, burst = false})
            local world_rank_target = self.inst
            local previous_world_rank_source = world_rank_target._hh_world_rank_combat_damage_source
            local function ResolveHit()
                -- DST mutates special-damage tables during defense processing.
                if type(spdamage) == "table" then
                    local copy = {}
                    for key, value in pairs(spdamage) do copy[key] = value end
                    spdamage = copy
                end
                if cffUucfkn:HasComponents(nfkuccnkc, "hh_player") then
                    local pierce
                    kFuuncgKg, pierce = nfkuccnkc.components.hh_player:ResolvePrimaryHit(self.inst, kFuuncgKg, weapon)
                    if pierce > 0 then
                        spdamage = spdamage or {}
                        spdamage.hh_armor_pierce = (spdamage.hh_armor_pierce or 0) + pierce
                    end
                elseif cffUucfkn:HasComponents(nfkuccnkc, "hh_monster") then
                    kFuuncgKg = nfkuccnkc["components"]["hh_monster"]:DoAttackDamage(nfkuccnkc, self["inst"], kFuuncgKg)
                else
                    kFuuncgKg = ApplyFollowerCritical(nfkuccnkc, self.inst, kFuuncgKg)
                end
                if defender ~= nil then
                    local reduction = defender:GetPhamNhanReduction()
                    kFuuncgKg = CombatMath.ApplyReduction(kFuuncgKg, reduction)
                    if spdamage ~= nil then
                        for key, value in pairs(spdamage) do
                            if type(key) == "string" and string.sub(key, 1, 3) == "hh_"
                                and key ~= "hh_armor_pierce" and type(value) == "number" then
                                spdamage[key] = CombatMath.ApplyReduction(value, reduction)
                            end
                        end
                    end
                end
                if cffUucfkn:HasComponents(self["inst"], "hh_monster") then
                    local monster = self["inst"]["components"]["hh_monster"]
                    local pre_monster_defense = kFuuncgKg
                    kFuuncgKg = monster:GetBlockDamage(self["inst"], nfkuccnkc, pre_monster_defense)
                    local defense_factor = pre_monster_defense > 0
                        and CombatMath.Clamp(kFuuncgKg / pre_monster_defense, 0, 1) or 0
                    if spdamage ~= nil then
                        local reduction = monster:GetEffectValueByKey("reducePercentDamage")
                        for key, value in pairs(spdamage) do
                            if type(key) == "string" and string.sub(key, 1, 3) == "hh_" and type(value) == "number" then
                                spdamage[key] = key == "hh_armor_pierce"
                                    and value * defense_factor or CombatMath.ApplyReduction(value, reduction)
                            end
                        end
                    end
                end
                if
                    cffUucfkn:HasComponents(nfkuccnkc, "follower") and nfkuccnkc["components"]["follower"]["leader"] and
                        cffUucfkn:HasComponents(nfkuccnkc["components"]["follower"]["leader"], "hh_player")
                 then
                    local gFiuucgKn = nfkuccnkc["components"]["follower"]["leader"]
                    local player = gFiuucgKn.components.hh_player
                    kFuuncgKg = ApplyFollowerHitModifier(kFuuncgKg, spdamage, player, player.GetFollowerDamage)
                end
                if
                    cffUucfkn:HasComponents(self["inst"], "follower") and self["inst"]["components"]["follower"]["leader"] and
                        cffUucfkn:HasComponents(self["inst"]["components"]["follower"]["leader"], "hh_player")
                 then
                    local nfgUucfKu = self["inst"]["components"]["follower"]["leader"]
                    local player = nfgUucfKu.components.hh_player
                    kFuuncgKg = ApplyFollowerHitModifier(kFuuncgKg, spdamage, player, player.GetFollowerArmor)
                end
                kFuuncgKg = math["max"](kFuuncgKg, 0)
                local godslayer =
                    cffUucfkn:HasComponents(nfkuccnkc, "hh_player") and
                    cffUucfkn:HasComponents(nfkuccnkc, "hh_godslayer") and
                    nfkuccnkc["components"]["hh_godslayer"] or nil
                if
                    kFuuncgKg > 0 and
                        godslayer ~= nil and
                        self["inst"]["components"] ~= nil and
                        self["inst"]["components"]["planarentity"] ~= nil
                 then
                    local godslayer_bonus = godslayer:GetBonusDamage(self["inst"])
                    if godslayer_bonus > 0 then
                        local new_spdamage = {}
                        if type(spdamage) == "table" then
                            for k, v in pairs(spdamage) do
                                new_spdamage[k] = v
                            end
                        end
                        new_spdamage["planar"] =
                            (tonumber(new_spdamage["planar"]) or 0) + godslayer_bonus
                        spdamage = new_spdamage
                    end
                end

                -- World rank difficulty is applied after Solo Leveling's custom
                -- attacker/block/critical math, but still before vanilla armor and
                -- damage resistance in the original Combat:GetAttacked path.
                -- Health:DoDelta has a matching guard so this same hit is not
                -- multiplied a second time after mitigation.
                local world_rank_damage_source = nil
                local world_rank = TheWorld ~= nil
                    and TheWorld["components"] ~= nil
                    and TheWorld["components"]["hh_world"] or nil
                if TheWorld ~= nil and TheWorld["ismastersim"]
                    and world_rank ~= nil
                    and world_rank["ResolveWorldRankDamageSource"] ~= nil then
                    local resolved_world_rank_source = world_rank:ResolveWorldRankDamageSource(nfkuccnkc)
                    if resolved_world_rank_source ~= nil then
                        local world_rank_multiplier = world_rank:GetWorldRankDamageMultiplier()
                        if world_rank_multiplier ~= 1 then
                            kFuuncgKg = kFuuncgKg * world_rank_multiplier
                            if type(spdamage) == "table" then
                                local scaled_spdamage = {}
                                for key, value in pairs(spdamage) do
                                    scaled_spdamage[key] = type(value) == "number"
                                        and value * world_rank_multiplier or value
                                end
                                spdamage = scaled_spdamage
                            end
                            world_rank_damage_source = resolved_world_rank_source
                        end
                    end
                end

                if world_rank_damage_source ~= nil then
                    world_rank_target["_hh_world_rank_combat_damage_source"] = world_rank_damage_source
                end
                return cFfuucgkc(self, nfkuccnkc, kFuuncgKg, weapon, stimuli, spdamage, unpack(args, 1, args.n))
            end
            local result = PackHitResults(pcall(ResolveHit))
            world_rank_target._hh_world_rank_combat_damage_source = previous_world_rank_source
            CombatContext.Finish(token)
            if not result[1] then error(result[2], 0) end
            return unpack(result, 2, result.n)
        end
        return (218 * 480 * 238 ~= 24904329)
    end
)
AddComponentPostInit(
    "freezable",
    function(self)
        local cFkuncikc = self["Freeze"]
        self["Freeze"] = function(self, ...)
            if cffUucfkn:HasComponents(self["inst"], "hh_player") then
                if self["inst"]["components"]["hh_player"]:HasSpecialEffect("immuneFreeze") then
                    return
                end
            end
            if cffUucfkn:HasComponents(self["inst"], "hh_monster") then
                if self["inst"]["components"]["hh_monster"]:HasSpecialEffect("immuneFreeze") then
                    return
                end
            end
            if cFkuncikc then
                cFkuncikc(self, ...)
            end
        end
    end
)
AddPrefabPostInit(
    "gestalt",
    function(cFgucCkkn)
        if not TheWorld["ismastersim"] then
            return cFgucCkkn
        end
        if cffUucfkn:HasComponents(cFgucCkkn, "combat") then
            local uFcUkCnkc = cFgucCkkn["components"]["combat"]["targetfn"]
            if uFcUkCnkc then
                cFgucCkkn["components"]["combat"]["targetfn"] = function(cFgucCkkn, ...)
                    if
                        cffUucfkn:HasComponents(cFgucCkkn["tracking_target"], "hh_player") and
                            cFgucCkkn["tracking_target"]["components"]["hh_player"]:HasSpecialEffect("moonCamp")
                     then
                        return nil
                    end
                    return uFcUkCnkc(cFgucCkkn, ...)
                end
            end
        end
    end
)
AddComponentPostInit(
    "shadowsubmissive",
    function(self)
        local nfcUncgKg = self["ShouldSubmitToTarget"]
        self["ShouldSubmitToTarget"] = function(self, nFcugCiKu, ...)
            if
                cffUucfkn:HasComponents(nFcugCiKu, "hh_player") and
                    nFcugCiKu["components"]["hh_player"]:HasSpecialEffect("shadowCamp")
             then
                return (true and not false and not false or
                    not false and not false and false and false and not false and false or
                    true and false and not true and false)
            end
            return nfcUncgKg(self, nFcugCiKu, ...)
        end
    end
)
AddComponentPostInit(
    "workable",
    function(self)
        local uffugcfKn = self["WorkedBy_Internal"]
        self["WorkedBy_Internal"] = function(self, fFguucfkn, nfnUuCkKc, ...)
            if
                cffUucfkn:HasComponents(fFguucfkn, "hh_player") and
                    fFguucfkn["components"]["hh_player"]:HasSpecialEffect("workAddSpeed") and
                    self["action"] ~= ACTIONS["HAMMER"]
             then
                nfnUuCkKc = (tonumber(nfnUuCkKc) or 1) * 2
            end
            return uffugcfKn(self, fFguucfkn, nfnUuCkKc, ...)
        end
    end
)
AddPrefabPostInit(
    "world",
    function(uFguuciki)
        if not TheWorld["ismastersim"] then
            return uFguuciki
        end
        uFguuciki:AddComponent("hh_world")
    end
)
local ufuUgCiKi = "images/hh_icon/hh_items.xml"
local cFgucCikn = "images/dyc_gem_purple"
local gfkugCikk = "images/dyc_gem_enc"
local nFcugCiKi = "images/hh_icon/hh_weapon.xml"
local iFkucCnkf = {
    ["hh_cat_box"] = ufuUgCiKi,
    ["hh_duck_box"] = ufuUgCiKi,
    ["hh_treasure_tally"] = ufuUgCiKi,
    ["hh_effect_stone"] = cFgucCikn,
    ["hh_effect_tally"] = ufuUgCiKi,
    ["hh_remove_stone"] = ufuUgCiKi,
    ["hh_essence"] = gfkugCikk,
    ["hh_quat_long_vu"] = nFcugCiKi,
    ["hh_speed_spear"] = nFcugCiKi,
    ["hh_daogam3"] = nFcugCiKi
}
local function gfnUucgKf(gFfUcCiKn)
    if gFfUcCiKn["components"]["drawable"] then
        local ffcUfCkKf = gFfUcCiKn["components"]["drawable"]["ondrawnfn"] or nil
        gFfUcCiKn["components"]["drawable"]["ondrawnfn"] = function(
            cfguicgKu,
            ifnUgCkkg,
            fFkUcccKn,
            nfuugcnkn,
            ufkugCckc,
            gfuukCfKc,
            ...)
            if ffcUfCkKf ~= nil then
                ffcUfCkKf(cfguicgKu, ifnUgCkkg, fFkUcccKn, nfuugcnkn, ufkugCckc, gfuukCfKc, ...)
            end
            if ifnUgCkkg ~= nil and iFkucCnkf[ifnUgCkkg] then
                if nfuugcnkn == nil then
                    nfuugcnkn = iFkucCnkf[ifnUgCkkg]
                end
                local fffuucukn = resolvefilepath_soft(nfuugcnkn)
                if fffuucukn then
                    cfguicgKu["AnimState"]:OverrideSymbol("SWAP_SIGN", fffuucukn, string["format"]("%s.tex", ifnUgCkkg))
                end
            end
        end
    end
end
AddPrefabPostInit("minisign", gfnUucgKf)
AddPrefabPostInit("minisign_drawn", gfnUucgKf)
AddPrefabPostInit("decor_pictureframe", gfnUucgKf)

-- Giữ nguyên prefab/StateGraph gốc của Lord Fruit Fly. Khi animation death
-- (24 frame ở 30 FPS) kết thúc, tạo một xác riêng cho hệ thống Trỗi Dậy.
AddPrefabPostInit("lordfruitfly", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("death", function(inst)
        if inst._hh_fruitfly_corpse_scheduled then
            return
        end
        inst._hh_fruitfly_corpse_scheduled = true

        local x, y, z = inst.Transform:GetWorldPosition()
        TheWorld:DoTaskInTime(24 * FRAMES, function()
            local corpse = SpawnPrefab("hh_corpse_fruitfly")
            if corpse ~= nil then
                corpse.Transform:SetPosition(x, y, z)
            end
        end)
    end)
end)
