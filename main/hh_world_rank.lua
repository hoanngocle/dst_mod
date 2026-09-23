local RankDefs = require "guild/hh_rank_defs"

local WORLD_RANK_RPC_NAMESPACE = "hh_world_rank"
local WORLD_RANK_REQUEST_RPC = nil
local WORLD_RANK_RECONCILE_RPC = nil
local WORLD_RANK_STAGE_RPC = nil

local STAGE_ANNOUNCEMENTS = {
    [1] = "Đã có thợ săn đột phá sức mạnh lên hạng B, quái vật sẽ trở nên mạnh hơn một chút",
    [2] = "Đã có thợ săn đột phá sức mạnh lên hạng S, quái vật sẽ trở nên mạnh hơn đáng kể",
}

local function GetWorldRankComponent()
    return TheWorld ~= nil
        and TheWorld.components ~= nil
        and TheWorld.components.hh_world or nil
end

local function IsMasterShard(world)
    return world ~= nil and world.IsMasterShard ~= nil and world:IsMasterShard()
end

local function ApplyWorldRankToExistingEntities(world)
    if world == nil or not world["inst"]["ismastersim"] then
        return
    end

    for _, inst in pairs(Ents or {}) do
        world:ApplyWorldRankToEntity(inst)
    end
end

local function SendWorldRankStageToShard(shard_id, stage)
    if WORLD_RANK_STAGE_RPC == nil or SendModRPCToShard == nil or shard_id == nil then
        return
    end
    SendModRPCToShard(WORLD_RANK_STAGE_RPC, tostring(shard_id), stage)
end

local function BroadcastWorldRankStage(world, stage)
    if world == nil or not IsMasterShard(world) or WORLD_RANK_STAGE_RPC == nil
        or SendModRPCToShard == nil then
        return
    end
    SendModRPCToShard(WORLD_RANK_STAGE_RPC, nil, stage)
end

local function AnnounceWorldRankStages(world, old_stage, new_stage)
    if world == nil or not IsMasterShard(world) or TheNet == nil then
        return
    end

    old_stage = tonumber(old_stage) or 0
    new_stage = tonumber(new_stage) or old_stage
    for stage = old_stage + 1, new_stage do
        if STAGE_ANNOUNCEMENTS[stage] ~= nil
            and world:ShouldAnnounceWorldRankStage(stage) then
            -- Mark before announcing so a re-entrant save/event cannot repeat it.
            world:MarkWorldRankStageAnnounced(stage)
            TheNet:Announce(STAGE_ANNOUNCEMENTS[stage])
        end
    end
end

local function OnWorldRankStageChanged(world, data)
    local stage = data ~= nil and data.stage or world:GetWorldRankStage()
    ApplyWorldRankToExistingEntities(world)

    if IsMasterShard(world) then
        BroadcastWorldRankStage(world, stage)
        if data == nil or data.silent ~= true then
            AnnounceWorldRankStages(world, data ~= nil and data.old_stage or 0, stage)
        end
    end
end

local function RequestWorldRankStageFromMaster()
    local world = GetWorldRankComponent()
    if world == nil or IsMasterShard(world) or WORLD_RANK_REQUEST_RPC == nil
        or SendModRPCToShard == nil or SHARDID == nil then
        return
    end
    SendModRPCToShard(WORLD_RANK_REQUEST_RPC, SHARDID.MASTER)
end

local function ForwardRankToMaster(rank)
    local world = GetWorldRankComponent()
    if world == nil or IsMasterShard(world) or WORLD_RANK_REQUEST_RPC == nil
        or SendModRPCToShard == nil or SHARDID == nil then
        return
    end
    SendModRPCToShard(WORLD_RANK_REQUEST_RPC, SHARDID.MASTER, tonumber(rank))
end

local function ForwardRankReconcileToMaster(rank)
    local world = GetWorldRankComponent()
    if world == nil or IsMasterShard(world) or WORLD_RANK_RECONCILE_RPC == nil
        or SendModRPCToShard == nil or SHARDID == nil then
        return
    end
    SendModRPCToShard(WORLD_RANK_RECONCILE_RPC, SHARDID.MASTER, tonumber(rank))
end

local function IsMasterShardSender(sender)
    return sender ~= nil and SHARDID ~= nil
        and tostring(sender) == tostring(SHARDID.MASTER)
end

if AddShardModRPCHandler ~= nil then
    AddShardModRPCHandler(WORLD_RANK_RPC_NAMESPACE, "request", function(sender, rank)
        local world = GetWorldRankComponent()
        if world == nil or not IsMasterShard(world) or sender == nil then
            return
        end

        if rank ~= nil then
            world:AdvanceWorldRankForRank(rank, "cave_rank_request")
        end

        SendWorldRankStageToShard(sender, world:GetWorldRankStage())
    end)

    AddShardModRPCHandler(WORLD_RANK_RPC_NAMESPACE, "reconcile", function(sender, rank)
        local world = GetWorldRankComponent()
        if world == nil or not IsMasterShard(world) or sender == nil then
            return
        end

        if rank ~= nil then
            world:AdvanceWorldRankForRank(rank, "rank_reconcile", true)
        end

        SendWorldRankStageToShard(sender, world:GetWorldRankStage())
    end)

    AddShardModRPCHandler(WORLD_RANK_RPC_NAMESPACE, "stage", function(sender, stage)
        local world = GetWorldRankComponent()
        if world == nil or IsMasterShard(world) or not IsMasterShardSender(sender) then
            return
        end
        world:SetSyncedWorldRankStage(stage, "master_sync")
    end)

    WORLD_RANK_REQUEST_RPC = GetShardModRPC(WORLD_RANK_RPC_NAMESPACE, "request")
    WORLD_RANK_RECONCILE_RPC = GetShardModRPC(WORLD_RANK_RPC_NAMESPACE, "reconcile")
    WORLD_RANK_STAGE_RPC = GetShardModRPC(WORLD_RANK_RPC_NAMESPACE, "stage")
end

-- The vanilla hook is the authoritative notification that a secondary shard
-- is ready. Sending the current stage here covers Cave startup even when its
-- one-shot request happens before the shard connection is usable.
if GLOBAL ~= nil and GLOBAL.Shard_OnShardConnected ~= nil
    and rawget(GLOBAL, "_hh_world_rank_shard_hooked") ~= true then
    local old_Shard_OnShardConnected = GLOBAL.Shard_OnShardConnected
    GLOBAL.Shard_OnShardConnected = function(world_id, tags, world_data, shard_name)
        old_Shard_OnShardConnected(world_id, tags, world_data, shard_name)
        local world = GetWorldRankComponent()
        if world ~= nil and IsMasterShard(world) then
            SendWorldRankStageToShard(world_id, world:GetWorldRankStage())
        end
    end
    rawset(GLOBAL, "_hh_world_rank_shard_hooked", true)
end

AddPrefabPostInit("world", function(inst)
    if not inst.ismastersim or inst.components.hh_world == nil then
        return
    end

    if not inst._hh_world_rank_listener then
        inst._hh_world_rank_listener = true
        inst:ListenForEvent("hh_world_rank_stage_changed", function(_, data)
            OnWorldRankStageChanged(inst.components.hh_world, data)
        end)
    end

    inst:DoTaskInTime(0, function(world_inst)
        local world = world_inst.components.hh_world
        if world == nil then
            return
        end
        ApplyWorldRankToExistingEntities(world)
        if not IsMasterShard(world) then
            RequestWorldRankStageFromMaster()
        end
    end)
end)

AddPrefabPostInitAny(function(inst)
    if TheWorld == nil or not TheWorld.ismastersim then
        return
    end

    local world = GetWorldRankComponent()
    if world == nil or not world:IsWorldRankEnemy(inst) then
        return
    end

    -- hh_monster and dungeon_manager both finish their existing scaling in
    -- zero-delay tasks/calls. Apply after those paths so the saved base is the
    -- already-Solo-Leveling-scaled maximum health.
    inst:DoTaskInTime(0, function(entity)
        local current_world = GetWorldRankComponent()
        if current_world ~= nil and current_world:IsWorldRankEnemy(entity) then
            current_world:ApplyWorldRankToEntity(entity)
        end
    end)
end)

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("hh_rank_changed", function(_, data)
        if data == nil or data.new_rank == nil then
            return
        end

        local world = GetWorldRankComponent()
        if world == nil then
            return
        end

        if IsMasterShard(world) then
            world:AdvanceWorldRankForRank(data.new_rank, "rank_changed")
        else
            ForwardRankToMaster(data.new_rank)
        end
    end)

    -- Reconcile a rank that was already saved before this world-stage state
    -- existed. Secondary shards still send it to Master; they never advance
    -- their own source of truth.
    inst:DoTaskInTime(0, function(player)
        local rank_component = player.components ~= nil and player.components.hh_rank or nil
        local rank = rank_component ~= nil and rank_component.rank or nil
        if rank == nil then
            return
        end

        local world = GetWorldRankComponent()
        if world ~= nil and IsMasterShard(world) then
            world:AdvanceWorldRankForRank(rank, "rank_reconcile", true)
        else
            ForwardRankReconcileToMaster(rank)
        end
    end)
end)

local function ResolveWorldRankDamageSource(source, world)
    return world ~= nil and world.ResolveWorldRankDamageSource ~= nil
        and world:ResolveWorldRankDamageSource(source) or nil
end

AddComponentPostInit("health", function(self)
    if self._hh_world_rank_wrapped then
        return
    end
    self._hh_world_rank_wrapped = true

    local old_DoDelta = self.DoDelta
    local old_DoFireDamage = self.DoFireDamage
    local old_SetMaxHealth = self.SetMaxHealth
    local old_SetPercent = self.SetPercent
    local old_OnSave = self.OnSave
    local old_OnLoad = self.OnLoad

    local function GetActiveStage(health)
        local world = GetWorldRankComponent()
        local inst = health.inst
        if world == nil or not TheWorld.ismastersim
            or not world:IsWorldRankEnemy(inst) then
            return nil, nil
        end

        local stage = tonumber(inst.hh_world_rank_stage)
        if stage == nil then
            return nil, world
        end
        return math.max(stage, world:GetWorldRankStage()), world
    end

    self.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ...)
        if not self._hh_world_rank_resizing
            and type(amount) == "number"
            and amount < 0
            and TheWorld ~= nil
            and TheWorld.ismastersim then
            local world = GetWorldRankComponent()
            if world ~= nil then
                local source = ResolveWorldRankDamageSource(afflicter, world)
                local buff = self.inst.components ~= nil and self.inst.components.hh_buff or nil
                if source == nil and buff ~= nil and buff.HasBuff ~= nil then
                    if cause == "hh_poison" and buff:HasBuff("poison") then
                        source = ResolveWorldRankDamageSource(buff.hh_poison_attacker, world)
                    elseif cause == "hh_turret_poison" and buff:HasBuff("turret_poison") then
                        source = ResolveWorldRankDamageSource(buff.hh_turret_poison_attacker, world)
                    end
                end
                local combat_source = self.inst._hh_world_rank_combat_damage_source
                local fire_source = self.inst._hh_world_rank_fire_damage_source
                if source ~= nil and source ~= combat_source and source ~= fire_source then
                    amount = amount * world:GetWorldRankDamageMultiplier()
                end
            end
        end
        return old_DoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ...)
    end

    self.DoFireDamage = function(self, amount, doer, instant, ...)
        local fire_source = nil
        if type(amount) == "number" and amount > 0
            and TheWorld ~= nil and TheWorld.ismastersim then
            local world = GetWorldRankComponent()
            if world ~= nil then
                local propagator = self.inst.components ~= nil and self.inst.components.propagator or nil
                local buff = self.inst.components ~= nil and self.inst.components.hh_buff or nil
                local source_candidate = doer
                    or (buff ~= nil and buff.hh_turret_fire_attacker or nil)
                    or self.inst.hh_turret_fire_attacker
                    or (propagator ~= nil and propagator.source or nil)
                fire_source = ResolveWorldRankDamageSource(source_candidate, world)
                if fire_source ~= nil then
                    amount = amount * world:GetWorldRankDamageMultiplier()
                end
            end
        end
        local previous_fire_source = self.inst._hh_world_rank_fire_damage_source
        if fire_source ~= nil then
            self.inst._hh_world_rank_fire_damage_source = fire_source
        end
        local result = { old_DoFireDamage(self, amount, doer, instant, ...) }
        if fire_source ~= nil then
            self.inst._hh_world_rank_fire_damage_source = previous_fire_source
        end
        return unpack(result)
    end

    self.SetMaxHealth = function(self, amount, ...)
        local active_stage, world = GetActiveStage(self)
        local previous_resizing = self._hh_world_rank_resizing
        if active_stage ~= nil then
            self._hh_world_rank_resizing = true
        end

        local result = { old_SetMaxHealth(self, amount, ...) }
        self._hh_world_rank_resizing = previous_resizing

        if active_stage ~= nil and world ~= nil and type(amount) == "number" and amount > 0 then
            self.inst.hh_world_rank_base_maxhealth = amount
            local target_maxhealth = amount * world:GetWorldRankHealthMultiplier(active_stage)
            if math.abs(self.maxhealth - target_maxhealth) > math.max(0.0001, target_maxhealth * 0.000001) then
                self.maxhealth = target_maxhealth
                self._hh_world_rank_resizing = true
                old_SetPercent(self, 1, true, "hh_world_rank_stage")
                self._hh_world_rank_resizing = previous_resizing
            end
        end
        return unpack(result)
    end

    self.SetPercent = function(self, percent, ...)
        local result = { old_SetPercent(self, percent, ...) }
        if self._hh_world_rank_resizing then
            return unpack(result)
        end

        local active_stage, world = GetActiveStage(self)
        local base_maxhealth = tonumber(self.inst.hh_world_rank_base_maxhealth)
        if active_stage ~= nil and world ~= nil and base_maxhealth ~= nil and base_maxhealth > 0 then
            local target_maxhealth = base_maxhealth * world:GetWorldRankHealthMultiplier(active_stage)
            if math.abs(self.maxhealth - target_maxhealth) > math.max(0.0001, target_maxhealth * 0.000001) then
                -- hh_monster legitimately rebuilds maxhealth by direct field
                -- assignment before calling SetPercent. Treat that new max as
                -- the existing-Solo-Leveling base, then restore the same pct.
                local health_percent = self:GetPercent()
                self.inst.hh_world_rank_base_maxhealth = self.maxhealth
                target_maxhealth = self.maxhealth * world:GetWorldRankHealthMultiplier(active_stage)
                self.maxhealth = target_maxhealth
                local previous_resizing = self._hh_world_rank_resizing
                self._hh_world_rank_resizing = true
                old_SetPercent(self, health_percent, true, "hh_world_rank_stage")
                self._hh_world_rank_resizing = previous_resizing
            end
        end
        return unpack(result)
    end

    self.OnSave = function(self, ...)
        local data = old_OnSave(self, ...)
        local world = GetWorldRankComponent()
        local inst = self.inst
        local base_maxhealth = tonumber(inst.hh_world_rank_base_maxhealth)
        local stage = tonumber(inst.hh_world_rank_stage)
        if world ~= nil and world:IsWorldRankEnemy(inst)
            and base_maxhealth ~= nil and base_maxhealth > 0 and stage ~= nil then
            data = data or {}
            data.hh_world_rank_base_maxhealth = base_maxhealth
            data.hh_world_rank_stage = math.clamp(math.floor(stage), 0, 2)
        end
        return data
    end

    self.OnLoad = function(self, data, ...)
        old_OnLoad(self, data, ...)
        if type(data) ~= "table" then
            return
        end

        local base_maxhealth = tonumber(data.hh_world_rank_base_maxhealth)
        local stage = tonumber(data.hh_world_rank_stage)
        if base_maxhealth == nil or base_maxhealth <= 0 or stage == nil then
            return
        end

        self.inst.hh_world_rank_base_maxhealth = base_maxhealth
        self.inst.hh_world_rank_stage = math.clamp(math.floor(stage), 0, 2)
        self.inst:DoTaskInTime(0, function(entity)
            local world = GetWorldRankComponent()
            if world ~= nil and world:IsWorldRankEnemy(entity) then
                world:ApplyWorldRankToEntity(entity)
            end
        end)
    end
end)

local function IsRawCookableEdible(food)
    if food == nil or food.IsValid == nil or not food:IsValid() then
        return false
    end

    local components = food.components
    local edible = components ~= nil and components.edible or nil
    local cookable = components ~= nil and components.cookable or nil
    if edible == nil or cookable == nil
        or (type(cookable.product) ~= "string" and type(cookable.product) ~= "function") then
        return false
    end

    -- These tags identify dishes, pre-prepared food, potions and drinks in
    -- vanilla. Raw ingredients use the cookable component without them.
    return not food:HasTag("preparedfood")
        and not food:HasTag("spicedfood")
        and not food:HasTag("pre-preparedfood")
        and not food:HasTag("potion")
        and not food:HasTag("fooddrink")
        and not food:HasTag("cooked")
end

AddComponentPostInit("eater", function(self)
    if self._hh_raw_food_poison_wrapped then
        return
    end
    self._hh_raw_food_poison_wrapped = true

    local old_Eat = self.Eat
    self.Eat = function(self, food, feeder, ...)
        local should_roll = TheWorld ~= nil
            and TheWorld.ismastersim
            and self.inst ~= nil
            and self.inst:HasTag("player")
            and IsRawCookableEdible(food)

        local result = { old_Eat(self, food, feeder, ...) }
        if result[1] == true and should_roll and math.random() < 0.10 then
            local buff = self.inst.components ~= nil and self.inst.components.hh_buff or nil
            if buff ~= nil then
                -- hh_buff:AddBuff refreshes an existing buff by name, so this
                -- creates no stack and always uses the existing poison API.
                local existing_source = buff.hh_turret_poison_attacker
                buff:AddBuff("turret_poison", 10)
                -- Keep an already active enemy attribution across the refresh;
                -- otherwise eating raw food while an enemy turret poison is
                -- active would silently remove that enemy's damage source.
                buff.hh_turret_poison_attacker = existing_source
            end
        end
        return unpack(result)
    end
end)

local function IsLowSanityPlayer(doer)
    if TheWorld == nil or not TheWorld.ismastersim
        or doer == nil or not doer:HasTag("player") then
        return false
    end

    local sanity = doer.components ~= nil and doer.components.sanity or nil
    local current = sanity ~= nil and tonumber(sanity.current) or nil
    local maximum = sanity ~= nil and tonumber(sanity.max) or nil
    return maximum ~= nil and maximum > 0 and current ~= nil and current / maximum < 0.15
end

local function WrapSanityMissAction(action, marker)
    if action == nil or action.fn == nil or action[marker] then
        return
    end

    local old_fn = action.fn
    action.fn = function(act, ...)
        if act ~= nil and IsLowSanityPlayer(act.doer) and math.random() < 0.10 then
            -- BufferedAction:Do treats this as a successful action, so the
            -- normal finiteuses OnUsedAsItem path still consumes durability.
            -- No target component is touched, therefore no drops/progress.
            return true
        end
        return old_fn(act, ...)
    end
    action[marker] = true
end

if ACTIONS ~= nil then
    WrapSanityMissAction(ACTIONS.CHOP, "_hh_low_sanity_miss_wrapped")
    WrapSanityMissAction(ACTIONS.MINE, "_hh_low_sanity_miss_wrapped")
    WrapSanityMissAction(ACTIONS.DIG, "_hh_low_sanity_miss_wrapped")
    WrapSanityMissAction(ACTIONS.HARVEST, "_hh_low_sanity_miss_wrapped")
end
