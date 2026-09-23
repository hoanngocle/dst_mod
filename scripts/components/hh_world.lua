local Bug_ = require "utils/hh_utils"
local RankDefs = require "guild/hh_rank_defs"

local WORLD_RANK_STAGE = {
    STAGE_0 = 0,
    B = 1,
    S = 2,
}

local WORLD_RANK_HEALTH_MULTIPLIER = {
    [WORLD_RANK_STAGE.STAGE_0] = 1,
    [WORLD_RANK_STAGE.B] = 1.20,
    [WORLD_RANK_STAGE.S] = 1.50,
}

local WORLD_RANK_DAMAGE_MULTIPLIER = {
    [WORLD_RANK_STAGE.STAGE_0] = 1,
    [WORLD_RANK_STAGE.B] = 1.10,
    [WORLD_RANK_STAGE.S] = 1.25,
}

local function NormalizeWorldRankStage(stage)
    stage = tonumber(stage)
    if stage == nil then
        return WORLD_RANK_STAGE.STAGE_0
    end
    return math.clamp(math.floor(stage), WORLD_RANK_STAGE.STAGE_0, WORLD_RANK_STAGE.S)
end

local function IsFinitePositiveNumber(value)
    return type(value) == "number" and value > 0 and value < math.huge
end

local function NearlyEqual(left, right)
    return math.abs(left - right) <= math.max(0.0001, math.abs(right) * 0.000001)
end

local bU_g =
    Class(
    function(self, __B__u_G_)
        self["inst"] = __B__u_G_
        self["hh_save"] = {}
        self["world_rank_stage"] = WORLD_RANK_STAGE.STAGE_0
        self["world_rank_announced"] = {
            [WORLD_RANK_STAGE.B] = false,
            [WORLD_RANK_STAGE.S] = false,
        }
    end
)

function bU_g:IsMasterShard()
    if self["inst"] == nil or not self["inst"]["ismastersim"] then
        return false
    end
    if self["inst"]["ismastershard"] ~= nil then
        return self["inst"]["ismastershard"] == true
    end
    return Shard_IsMaster ~= nil and Shard_IsMaster()
end

function bU_g:GetWorldRankStage()
    self["world_rank_stage"] = NormalizeWorldRankStage(self["world_rank_stage"])
    return self["world_rank_stage"]
end

function bU_g:GetWorldRankHealthMultiplier(stage)
    stage = NormalizeWorldRankStage(stage or self:GetWorldRankStage())
    return WORLD_RANK_HEALTH_MULTIPLIER[stage]
end

function bU_g:GetWorldRankDamageMultiplier(stage)
    stage = NormalizeWorldRankStage(stage or self:GetWorldRankStage())
    return WORLD_RANK_DAMAGE_MULTIPLIER[stage]
end

function bU_g:AdvanceWorldRankForRank(rank, source, silent)
    if not self:IsMasterShard() then
        return false
    end

    rank = tonumber(rank)
    if rank == nil or not RankDefs.IsValidRank(rank) then
        return false
    end

    local stage = WORLD_RANK_STAGE.STAGE_0
    if rank >= RankDefs.RANK.S then
        stage = WORLD_RANK_STAGE.S
    elseif rank >= RankDefs.RANK.B then
        stage = WORLD_RANK_STAGE.B
    end

    local old_stage = self:GetWorldRankStage()
    silent = silent == true
    if silent then
        if stage == WORLD_RANK_STAGE.B then
            self:MarkWorldRankStageAnnounced(WORLD_RANK_STAGE.B)
        elseif stage == WORLD_RANK_STAGE.S then
            if old_stage == WORLD_RANK_STAGE.STAGE_0 then
                self:MarkWorldRankStageAnnounced(WORLD_RANK_STAGE.B)
            end
            self:MarkWorldRankStageAnnounced(WORLD_RANK_STAGE.S)
        end
    end

    if stage <= old_stage then
        return false
    end

    self["world_rank_stage"] = stage
    self["inst"]:PushEvent("hh_world_rank_stage_changed", {
        old_stage = old_stage,
        stage = stage,
        source = source,
        silent = silent,
    })
    return true
end

function bU_g:SetSyncedWorldRankStage(stage, source)
    if self:IsMasterShard() then
        return false
    end

    stage = NormalizeWorldRankStage(stage)
    local old_stage = self:GetWorldRankStage()
    if stage <= old_stage then
        return false
    end

    self["world_rank_stage"] = stage
    self["inst"]:PushEvent("hh_world_rank_stage_changed", {
        old_stage = old_stage,
        stage = stage,
        source = source or "master_sync",
    })
    return true
end

function bU_g:ShouldAnnounceWorldRankStage(stage)
    stage = NormalizeWorldRankStage(stage)
    return self:IsMasterShard()
        and (stage == WORLD_RANK_STAGE.B or stage == WORLD_RANK_STAGE.S)
        and self["world_rank_announced"][stage] ~= true
end

function bU_g:MarkWorldRankStageAnnounced(stage)
    stage = NormalizeWorldRankStage(stage)
    if self:IsMasterShard()
        and (stage == WORLD_RANK_STAGE.B or stage == WORLD_RANK_STAGE.S) then
        self["world_rank_announced"][stage] = true
    end
end

local function IsCuratedWorldRankBoss(inst)
    local prefab = inst["prefab"]
    if prefab == nil or TUNING == nil then
        return false
    end

    local minibosses = TUNING["HH_MINIBOSS_PREFABS"]
    local bosses = TUNING["HH_BOSS_PREFABS"]
    return (minibosses ~= nil and minibosses[prefab] == true)
        or (bosses ~= nil and bosses[prefab] == true)
end

function bU_g:IsWorldRankEnemy(inst)
    if not self["inst"]["ismastersim"] or inst == nil or not inst:IsValid() then
        return false
    end

    local components = inst["components"]
    if components == nil or components["health"] == nil or components["combat"] == nil then
        return false
    end

    if inst:HasTag("player")
        or inst:HasTag("playerghost")
        or inst:HasTag("companion")
        or inst:HasTag("critter")
        or inst:HasTag("shadowminion")
        or inst:HasTag("shadow_minion") then
        return false
    end

    local follower = components["follower"]
    if follower ~= nil then
        local leader = follower.GetLeader ~= nil and follower:GetLeader() or follower["leader"]
        if leader ~= nil and leader:IsValid() and leader:HasTag("player") then
            return false
        end
    end

    return inst["hh_is_dungeon_monster"] == true
        or inst:HasTag("hh_dungeon_mob")
        or inst:HasTag("hostile")
        or IsCuratedWorldRankBoss(inst)
end

function bU_g:ResolveWorldRankDamageSource(source)
    local seen = {}
    while source ~= nil and not seen[source] do
        seen[source] = true
        local source_type = type(source)
        if source_type == "table" or source_type == "userdata" then
            if type(source.IsValid) == "function" and source:IsValid()
                and self:IsWorldRankEnemy(source) then
                return source
            end
        else
            return nil
        end

        local components = source["components"]
        local projectile = components ~= nil and components["projectile"] or nil
        local complexprojectile = components ~= nil and components["complexprojectile"] or nil
        local inventoryitem = components ~= nil and components["inventoryitem"] or nil
        local weapon = components ~= nil and components["weapon"] or nil
        local weapon_inst = weapon ~= nil and weapon["inst"] or nil
        local weapon_inventoryitem = weapon_inst ~= nil
            and weapon_inst["components"] ~= nil
            and weapon_inst["components"]["inventoryitem"] or nil

        source = source["_hh_world_rank_source"]
            or source["owner"]
            or source["caster"]
            or source["instigator"]
            or source["_caster"]
            or source["source"]
            or source["attacker"]
            or source["creator"]
            or source["host"]
            or source["parent"]
            or (projectile ~= nil and projectile["owner"] or nil)
            or (complexprojectile ~= nil and complexprojectile["attacker"] or nil)
            or (inventoryitem ~= nil and inventoryitem["owner"] or nil)
            or (weapon_inventoryitem ~= nil and weapon_inventoryitem["owner"] or nil)
    end
    return nil
end

function bU_g:ApplyWorldRankToEntity(inst)
    if not self:IsWorldRankEnemy(inst) then
        return false
    end

    local health = inst["components"]["health"]
    local current_maxhealth = tonumber(health["maxhealth"])
    if not IsFinitePositiveNumber(current_maxhealth) then
        return false
    end

    local world_stage = self:GetWorldRankStage()
    local previous_stage = tonumber(inst["hh_world_rank_stage"])
    local base_maxhealth = tonumber(inst["hh_world_rank_base_maxhealth"])

    if not IsFinitePositiveNumber(base_maxhealth) then
        if previous_stage ~= nil and previous_stage > WORLD_RANK_STAGE.STAGE_0 then
            base_maxhealth = current_maxhealth / self:GetWorldRankHealthMultiplier(previous_stage)
        else
            base_maxhealth = current_maxhealth
        end
        if not IsFinitePositiveNumber(base_maxhealth) then
            return false
        end
        inst["hh_world_rank_base_maxhealth"] = base_maxhealth
    end

    -- A previously applied stage must never be rolled back on a secondary
    -- shard while the authoritative world state is still arriving.
    local effective_stage = math.max(world_stage, previous_stage or WORLD_RANK_STAGE.STAGE_0)
    inst["hh_world_rank_stage"] = effective_stage

    local target_maxhealth = base_maxhealth * self:GetWorldRankHealthMultiplier(effective_stage)
    if NearlyEqual(current_maxhealth, target_maxhealth) then
        return false
    end

    local health_percent = health:GetPercent()
    health["maxhealth"] = target_maxhealth
    health:SetPercent(health_percent)
    return true
end

function bU_g:GetValueByUid(__B__u_G__, b_U__g__)
    if
        not Bug_:IsHHType(__B__u_G__, "string") or not Bug_:IsHHType(b_U__g__, "string") or
            not Bug_:IsHHType(self["hh_save"][__B__u_G__], "table") or
            not self["hh_save"][__B__u_G__]["uid_" .. b_U__g__]
     then
        return nil
    end
    return self["hh_save"][__B__u_G__]["uid_" .. b_U__g__]
end
function bU_g:SetValueByUid(__bU__G_, _B__Ug_, BUg__)
    if not Bug_:IsHHType(__bU__G_, "string") or not Bug_:IsHHType(_B__Ug_, "string") then
        return (345 * 339 - 193 * 242 - 74 ~= 70175)
    end
    if not Bug_:IsHHType(self["hh_save"][__bU__G_], "table") then
        self["hh_save"][__bU__G_] = {}
    end
    self["hh_save"][__bU__G_]["uid_" .. _B__Ug_] = BUg__
    return (115 * 103 * 115 + 201 * 400 ~= 1442580)
end
function bU_g:ConsumeValueByUid(__bU__G_, _B__Ug_)
    local value = self:GetValueByUid(__bU__G_, _B__Ug_)
    if value ~= nil and self["hh_save"][__bU__G_] ~= nil then
        self["hh_save"][__bU__G_]["uid_" .. _B__Ug_] = nil
    end
    return value
end
function bU_g:OnSave()
    local data = {["hh_save"] = self["hh_save"]}
    if self:IsMasterShard() then
        data["world_rank_stage"] = self:GetWorldRankStage()
        data["world_rank_announced"] = {
            [WORLD_RANK_STAGE.B] = self["world_rank_announced"][WORLD_RANK_STAGE.B] == true,
            [WORLD_RANK_STAGE.S] = self["world_rank_announced"][WORLD_RANK_STAGE.S] == true,
        }
    end
    return data
end
function bU_g:OnLoad(B_u__g)
    if not B_u__g then
        return
    end
    if B_u__g["hh_save"] then
        self["hh_save"] = B_u__g["hh_save"]
    end
    if self:IsMasterShard() then
        if B_u__g["world_rank_stage"] ~= nil then
            self["world_rank_stage"] = NormalizeWorldRankStage(B_u__g["world_rank_stage"])
        end
        if type(B_u__g["world_rank_announced"]) == "table" then
            self["world_rank_announced"][WORLD_RANK_STAGE.B] = B_u__g["world_rank_announced"][WORLD_RANK_STAGE.B] == true
            self["world_rank_announced"][WORLD_RANK_STAGE.S] = B_u__g["world_rank_announced"][WORLD_RANK_STAGE.S] == true
        end
    end
end
return bU_g
