-- Phàm Nhân Tu Tiên: authoritative evidence adapters and perk installation.
local G = GLOBAL
if rawget(env, "_ttk_achievement_registered") then return end
rawset(env, "_ttk_achievement_registered", true)
AddReplicableComponent("ttk_achievement_progress")

local AchievementCatalog = require("achievement/ttk_achievement_catalog")
local SeasonalCatalog = require("achievement/ttk_seasonal_catalog")
local PerkCatalog = require("achievement/ttk_perk_catalog")
local PerkEffects = require("achievement/ttk_perk_effects")
local RankDefs = require("guild/hh_rank_defs")
local AlchemyDefs = require("alchemy/ttk_alchemy_defs")
local IsDungeonSurfaceAuthority = require("utils/hh_dungeon_authority")
local CHEST_MILESTONES = { 5, 10, 15, 20 }

local function Master()
    return G.TheWorld ~= nil and G.TheWorld.ismastersim == true
end

local function Integer(value, minimum, maximum)
    return type(value) == "number" and value == value and value >= minimum
        and value <= maximum and value == math.floor(value)
end

local function ValidID(id)
    return type(id) == "string" and #id > 0 and #id <= 80 and id:match("^[%w_]+$") ~= nil
end

local function ValidRequest(request_id)
    return type(request_id) == "string" and #request_id > 0 and #request_id <= 96
end

local function ResolveSender(sender)
    if not Master() or sender == nil or not sender:IsValid() or not sender:HasTag("player")
        or sender.components == nil then return nil end
    local component = sender.components.ttk_achievement_progress
    if component == nil or component.inst ~= sender then return nil end
    return component
end

local function Matches(params, evidence)
    for key, value in pairs(params) do
        if key == "prefabs" then
            local found = false
            for _, prefab in ipairs(value) do
                if evidence.prefab == prefab then found = true; break end
            end
            if not found then return false end
        elseif key == "level" or key == "milestone" then
            if type(evidence[key]) ~= "number" or evidence[key] < value then return false end
        elseif key == "category" and value == "any" then
            -- Success rows may count any committed equipment category.
        elseif key == "rank" then
            if RankDefs.RANK[evidence.rank] == nil or RankDefs.RANK[value] == nil
                or RankDefs.RANK[evidence.rank] < RankDefs.RANK[value] then return false end
        elseif evidence[key] ~= value then
            return false
        end
    end
    return true
end

local function AdvanceTo(component, row, value, evidence)
    local saved = component.core.achievements[row.id]
    local progress = saved ~= nil and saved.progress or 0
    local desired = math.min(row.target, value)
    if desired > progress then component:Advance(row.id, desired - progress, evidence) end
end

local function Route(inst, tracker, evidence, amount, absolute)
    local component = ResolveSender(inst)
    if component == nil then return end
    for _, row in ipairs(AchievementCatalog.ByEvent(tracker)) do
        if row.id ~= "food_cultivation_pill_path" and Matches(row.params, evidence) then
            -- Only distinct rows consume the canonical prefab string. Keep the
            -- complete server event evidence for ordinary and seasonal routes.
            local progress_evidence = row.distinct == "prefab" and evidence.prefab or evidence
            if absolute then
                AdvanceTo(component, row, row.target, progress_evidence)
            else
                local saved = component.core.achievements[row.id]
                if saved == nil or saved.progress < row.target then component:Advance(row.id, amount or 1, progress_evidence) end
            end
        end
    end
end

local function Seasonal(inst, event, evidence, amount)
    local component = ResolveSender(inst)
    local seasonal = component ~= nil and component.core.seasonal or nil
    if seasonal == nil or seasonal.season ~= G.TheWorld.state.season then return end
    evidence.event = event
    for _, slot in ipairs(seasonal.slots) do
        local row = SeasonalCatalog.ById(slot.task_id)
        if row ~= nil and row.event == event and Matches(row.params, evidence)
            and slot.progress < row.target and slot.claims < row.max_claims then
            component:AdvanceSeasonal(row.id, amount, evidence)
        end
    end
end

local function Seen(state, kind, identity)
    if type(identity) ~= "table" then return true end
    state[kind] = state[kind] or setmetatable({}, { __mode = "k" })
    if state[kind][identity] then return true end
    state[kind][identity] = true
    return false
end

-- DST components/eater.lua emits oneat before OnEaten/HandleEatRemove.
-- One context per Eat call permits successive units of the same stack while
-- duplicate oneat callbacks cannot credit the same consumption twice.
local function OnEat(inst, data)
    local context = inst._ttk_achievement_eating
    if context == nil or data == nil or data.food ~= context.food or context.observed then return end
    context.observed = true
end

local function InstallEater(eater)
    if not Master() or eater._ttk_achievement_hook then return end
    eater._ttk_achievement_hook = true
    local previous = eater.Eat
    eater.Eat = function(self, food, ...)
        local inst = self.inst
        if ResolveSender(inst) == nil or food == nil then return previous(self, food, ...) end
        local hunger = inst.components.hunger
        local context = { food=food, prefab=food.prefab, starving=hunger ~= nil and hunger:IsStarving() }
        local outer = inst._ttk_achievement_eating
        inst._ttk_achievement_eating = context
        local ok, result = pcall(previous, self, food, ...)
        inst._ttk_achievement_eating = outer
        if not ok then error(result) end
        if result == true and context.observed then
            local evidence = { prefab=context.prefab, starving=context.starving }
            Route(inst, "eat_prefabs", evidence, 1)
            Seasonal(inst, "oneat", evidence, 1)
        end
        return result
    end
end

-- ttk_cultivation:Consume commits stage and consumed before this event.
-- Use the committed prefix, including saved progress, never the event payload.
local function OnCultivation(inst)
    local component = ResolveSender(inst)
    local cultivation = inst.components.ttk_cultivation
    if component == nil or cultivation == nil then return end
    local stage = cultivation:GetStage()
    if not Integer(stage, 1, 15) then return end
    for index = 1, stage do
        local row = AlchemyDefs.GetCultivationStage(index)
        if row == nil or not cultivation.consumed[row.prefab] then return end
    end
    local id = "food_cultivation_pill_path"
    local saved = component.core.achievements[id]
    local progress = saved ~= nil and saved.progress or 0
    if stage > progress then component:Advance(id, stage - progress, { stage=stage }) end
    component:SetCultivationReference(cultivation:OnSave())
end

local function OnProgression(inst)
    local leveling, rank = inst.components.hh_leveling, inst.components.hh_rank
    if leveling ~= nil and Integer(leveling.level, 1, 1000000000) then
        Route(inst, "level_reached", { level=leveling.level }, 1, true)
    end
    if rank ~= nil and RankDefs.IsValidRank(rank:GetRank()) then
        Route(inst, "hunter_rank", { rank=RankDefs.GetName(rank:GetRank()) }, 1, true)
    end
end

-- combat.lua pushes killed on the actual attacker after health reaches zero.
-- Existing Phàm Nhân direct-kill producers (ttk_boss_swordfx.lua) omit attacker;
-- the server event source still identifies the credited killer in that case.
-- Follower events may credit only their current leader; victim identity is
-- shared with direct kills so a pet-forwarded callback cannot award twice.
local function OnKilled(killer, data)
    if not Master() or data == nil or (data.attacker ~= nil and data.attacker ~= killer) then return end
    local inst = killer
    if ResolveSender(inst) == nil then
        local follower = killer.components ~= nil and killer.components.follower or nil
        inst = follower ~= nil and follower:GetLeader() or nil
    end
    if ResolveSender(inst) == nil then return end
    local victim = data.victim
    if victim == nil or victim.components == nil or victim.components.health == nil
        or not victim.components.health:IsDead() then return end
    local state = inst._ttk_achievement_state
    if state == nil or state.kills[victim] then return end
    state.kills[victim] = true
    local evidence = { prefab=victim.prefab }
    local manager = victim.hh_dungeon_manager
    if IsDungeonSurfaceAuthority(G.TheWorld) and manager ~= nil
        and G.TheWorld.components ~= nil and G.TheWorld.components.dungeon_manager == manager
        and victim.hh_dungeon_run_epoch == manager.run_epoch
        and manager.state == "IN_PROGRESS" and manager.players_in_dungeon[inst] == true then
        evidence.context = "dungeon"
    end
    Route(inst, "kill_prefab", evidence, 1)
    Route(inst, "combat_event", evidence, 1)
    Seasonal(inst, "killed", evidence, 1)
end

local function ConfigureXP(inst, component)
    -- EXP calibration belongs to the separate tuning task. Only an explicit
    -- server tuning value enables claims; no default is invented here. Until
    -- configured, Core keeps its nil callback and reports xp_unavailable.
    local SEASONAL_CLAIM_XP = G.TUNING and G.TUNING.TTK_SEASONAL_CLAIM_XP
    if type(SEASONAL_CLAIM_XP) ~= "number" or SEASONAL_CLAIM_XP ~= SEASONAL_CLAIM_XP
        or SEASONAL_CLAIM_XP <= 0 or SEASONAL_CLAIM_XP == math.huge then
        component:SetSeasonalXPCallback(nil)
        return
    end
    component:SetSeasonalXPCallback(function(player, id, kind, number, claim_key, outgoing)
        if not Master() or player ~= inst or ResolveSender(inst) ~= component then return false end
        local row = SeasonalCatalog.ById(id)
        local seasonal = component.core.seasonal
        local slot = component.core:FindSeasonalSlot(id)
        if row == nil or row.kind ~= kind or seasonal == nil or slot == nil
            or (seasonal.season ~= G.TheWorld.state.season
                and not (outgoing == seasonal and seasonal.rollover_pending and component.core.seasonal_busy))
            or row.season ~= seasonal.season
            or not Integer(number, 1, row.max_claims) then return false end
        local expected = seasonal.epoch .. ":" .. id .. ":" .. tostring(number)
        if claim_key ~= expected then return false end
        if number ~= slot.claims + 1 or slot.progress < row.target then return false end
        if slot.xp_receipt == "awarded" then return true end
        if slot.xp_receipt ~= nil then return false end
        local leveling = inst.components.hh_leveling
        if leveling == nil or SEASONAL_CLAIM_XP <= 0 then return false end
        -- Reserve before callbacks. If AddExp throws after changing EXP, retain
        -- the saved slot reservation (fail closed), including after reload,
        -- rather than retrying an uncertain award.
        slot.xp_receipt = "pending"
        local ok = leveling:AddExp(SEASONAL_CLAIM_XP)
        slot.xp_receipt = ok == true and "awarded" or nil
        return ok == true
    end)
end

local function ConfigureSeasonalClaims(inst, component)
    component.core:SetSeasonalClaimCallback(function(player, receipt, state)
        if not Master() or player ~= inst or ResolveSender(inst) ~= component
            or state ~= component.core.seasonal or not component.core.seasonal_busy then return end
        local slot = component.core:FindSeasonalSlot(receipt.id)
        local expected = state.epoch .. ":" .. receipt.id .. ":" .. tostring(receipt.claims)
        if slot == nil or slot.claims ~= receipt.claims or receipt.claim_key ~= expected then return end
        Route(inst, "season_mission_completed", { milestone=state.first_claims }, 1, true)
        Route(inst, "season_mission_claimed", { source="seasonal" }, 1)
        if slot.claims > 1 then Route(inst, "season_mission_repeat", { source="seasonal" }, 1) end
    end)
end

local function RefreshSeason(inst)
    local component = ResolveSender(inst)
    if component == nil then return end
    local state = G.TheWorld.state
    if state == nil or not SeasonalCatalog.IsSeason(state.season)
        or not Integer(state.cycles, 0, 1000000000)
        or not Integer(state.elapseddaysinseason, 0, 1000000000) then return end
    -- worldstate receives elapsed days from seasons:OnSeasonDirty. Defer the
    -- season watcher to let that event finish updating all world-state fields.
    local start_cycle = math.max(0, state.cycles - state.elapseddaysinseason)
    local epoch = state.season .. ":" .. tostring(start_cycle)
    local saved = component.core.seasonal
    if saved ~= nil and saved.season == state.season and saved.epoch == epoch and not saved.rollover_pending then return end
    ConfigureXP(inst, component)
    if component:StartSeason(state.season, epoch) then
        Route(inst, "season_mission_assigned", { source="seasonal" }, 1)
    end
end

-- Inventory:GiveItem emits itemget only for a new slot. Stackable:Put instead
-- emits stacksizechange, and Stackable:Get replaces split units with a new
-- entity. Track receipts per player/unit, carrying them through both operations;
-- fresh event tables, bag transfers, and stack splits are not new acquisitions.
local inventory_depth = 0
local pending_inventory = setmetatable({}, { __mode="k" })
-- Dropped/removed items may outlive their former player; keep neither alive.
local last_inventory_owner = setmetatable({}, { __mode="kv" })

local function ItemAmount(item)
    local stack = item.components ~= nil and item.components.stackable or nil
    local amount = stack ~= nil and stack:StackSize() or 1
    return Integer(amount, 1, 1000000) and amount or 0
end

-- Ownership is a high-water observation of simultaneously held units, never a
-- sum of receipt deltas. Read only physical inventory and its worn overflow.
local function ObserveOwnership(inst)
    local component = ResolveSender(inst)
    local inventory = component ~= nil and inst.components.inventory or nil
    if inventory == nil or inventory.isloading then return end
    local amounts, seen = {}, {}
    local function Add(item)
        if item == nil or seen[item] or not item:IsValid() then return end
        seen[item] = true
        amounts[item.prefab] = (amounts[item.prefab] or 0) + ItemAmount(item)
    end
    for _, item in pairs(inventory.itemslots or {}) do Add(item) end
    for _, item in pairs(inventory.equipslots or {}) do Add(item) end
    Add(inventory.activeitem)
    local overflow = inventory:GetOverflowContainer()
    if overflow ~= nil then for _, item in pairs(overflow.slots or {}) do Add(item) end end
    for _, row in ipairs(AchievementCatalog.ByEvent("own_prefab")) do
        AdvanceTo(component, row, amounts[row.params.prefab] or 0, { prefab=row.params.prefab })
    end
end

local function QueueOwnership(inst)
    if ResolveSender(inst) == nil or inst._ttk_ownership_pending then return end
    inst._ttk_ownership_pending = true
    inst:DoTaskInTime(0, function(player)
        player._ttk_ownership_pending = nil
        ObserveOwnership(player)
    end)
end

local function Receipts(item, amount)
    local receipts = item._ttk_achievement_receipts
    if receipts == nil then
        receipts = setmetatable({}, { __mode="k" })
        item._ttk_achievement_receipts = receipts
    end
    for player, count in pairs(receipts) do receipts[player] = math.min(count, amount) end
    return receipts
end

local function CopyReceipts(item, amount)
    local copy = {}
    for player, count in pairs(Receipts(item, amount)) do copy[player] = count end
    return copy
end

local function CreditInventoryItem(item)
    if item == nil or not item:IsValid() or item.components == nil then return end
    if inventory_depth > 0 then pending_inventory[item] = true; return end
    local inventoryitem = item.components.inventoryitem
    local player = inventoryitem ~= nil and inventoryitem:GetGrandOwner() or nil
    if ResolveSender(player) == nil then return end
    last_inventory_owner[item] = player
    QueueOwnership(player)
    local amount = ItemAmount(item)
    local receipts = Receipts(item, amount)
    local credited = receipts[player] or 0
    receipts[player] = amount -- Commit before Route can invoke other callbacks.
    local inventory = player.components.inventory
    if amount > credited and inventory ~= nil and not inventory.isloading then
        local evidence = { prefab=item.prefab }
        Route(player, "collect_prefab", evidence, amount - credited)
        Route(player, "collect_prefabs", evidence, amount - credited)
        Seasonal(player, "itemget", evidence, amount - credited)
    end
    -- Restored backpack contents get a baseline while Inventory:OnLoad still
    -- has isloading=true; equipping/moving a bag must not collect its contents.
    local container = item.components.container
    if container ~= nil then
        for _, child in pairs(container.slots) do CreditInventoryItem(child) end
    end
end

local function FlushInventory()
    if inventory_depth > 0 then return end
    local pending = pending_inventory
    pending_inventory = setmetatable({}, { __mode="k" })
    for item in pairs(pending) do CreditInventoryItem(item) end
end

local function OnBuild(inst, data, event)
    local state = inst._ttk_achievement_state
    if data == nil or data.item == nil or Seen(state, "builds", data.item) then return end
    local evidence = { prefab=data.item.prefab }
    Route(inst, "crafting_event", evidence, 1)
    Route(inst, "craft_prefab", evidence, 1)
    Seasonal(inst, event, evidence, 1)
end

local function FarmTarget(target)
    return target ~= nil and (target:HasTag("farm_plant") or target:HasTag("soil")
        or (target.components ~= nil and (target.components.crop ~= nil or target.components.grower ~= nil)))
end

local function OnFarmAction(inst, data)
    local act = data ~= nil and data.action or nil
    if ResolveSender(inst) == nil or act == nil or act.doer ~= inst or act.action == nil
        or Seen(inst._ttk_achievement_state, "farm_actions", act) then return end
    local id = act.action.id
    local water = id == "POUR_WATER" or id == "POUR_WATER_GROUNDTILE"
    local deploy = id == "DEPLOY" or id == "DEPLOY_TILEARRIVE"
    if not water and id ~= "FERTILIZE" and not deploy then return end
    local fertilizer = act.invobject ~= nil and act.invobject.components ~= nil
        and act.invobject.components.fertilizer ~= nil
    if not water and not fertilizer then return end
    local eligible = FarmTarget(act.target)
    if act.target == nil and (water or deploy) then
        local pt = act:GetActionPoint()
        eligible = pt ~= nil and G.WORLD_TILES ~= nil
            and G.TheWorld.Map:GetTileAtPoint(pt:Get()) == G.WORLD_TILES.FARMING_SOIL
    end
    if not eligible then return end
    local credited = false
    act:AddSuccessAction(function()
        if credited then return end
        credited = true
        Route(inst, "farm_action", { action=water and "WATER" or "FERTILIZE" }, 1)
    end)
end

local function Living(inst)
    return ResolveSender(inst) ~= nil and not inst:HasTag("playerghost")
        and inst.components.health ~= nil and not inst.components.health:IsDead()
end

local function ObserveTemperature(inst)
    local state = inst._ttk_achievement_state
    if not Living(inst) then state.hot, state.cold = nil, nil; return end
    local temperature = inst.components.temperature
    if temperature == nil then return end
    local hot, cold = temperature:IsOverheating(), temperature:IsFreezing()
    if not hot and not cold then
        if state.hot then Route(inst, "survival_event", { key="heat" }, 1) end
        if state.cold then Route(inst, "survival_event", { key="cold" }, 1) end
        state.hot, state.cold = nil, nil
    else
        state.hot, state.cold = state.hot or hot, state.cold or cold
    end
end

local function InstallPlayer(inst)
    if not Master() or inst._ttk_achievement_installed then return end
    inst._ttk_achievement_installed = true
    if inst.components.ttk_achievement_progress == nil then inst:AddComponent("ttk_achievement_progress") end
    local component = inst.components.ttk_achievement_progress
    PerkEffects.Install(inst)
    component:SetEffectCallback(PerkEffects.Apply)
    ConfigureSeasonalClaims(inst, component)
    component:ReapplyPurchased()
    local state = { kills=setmetatable({}, { __mode="k" }), dead=inst:HasTag("playerghost"),
        season=G.TheWorld.state.season, cycle=G.TheWorld.state.cycles }
    inst._ttk_achievement_state = state
    ConfigureXP(inst, component)
    if inst.components.eater ~= nil then InstallEater(inst.components.eater) end
    inst:ListenForEvent("ttk_cultivation_advanced", OnCultivation)
    inst:ListenForEvent("hh_levelup", OnProgression)
    inst:ListenForEvent("hh_rank_changed", OnProgression)
    -- These receipts are emitted by committed server component methods only.
    local function SurfaceReceipt(event, fn)
        inst:ListenForEvent(event, function(player, data)
            if IsDungeonSurfaceAuthority(G.TheWorld) and ResolveSender(player) ~= nil then fn(player, data) end
        end)
    end
    SurfaceReceipt("hh_guild_quest_assigned", function(player)
        Route(player, "guild_quest_assigned", { event="hh_guild_quest_assigned" }, 1)
    end)
    SurfaceReceipt("hh_guild_quest_completed", function(player)
        Route(player, "guild_quest_completed", { event="hh_guild_quest_completed" }, 1)
    end)
    SurfaceReceipt("hh_rank_changed", function(player, data)
        if data ~= nil and data.source == "claim_exam" then
            Route(player, "guild_rank_exam_passed", { source="hh_rank" }, 1)
        end
    end)
    SurfaceReceipt("hh_guild_opened", function(player)
        Route(player, "guild_opened", { prefab="guild_staff" }, 1)
    end)
    SurfaceReceipt("hh_guild_shop_purchased", function(player, data)
        if data ~= nil and Integer(data.cost, 1, 2000000000) then
            local evidence = { source="hh_guild_shop", currency="credit" }
            Route(player, "guild_shop_purchase", evidence, data.count)
            Route(player, "guild_credit_spent", evidence, data.cost)
        end
    end)
    SurfaceReceipt("hh_dungeon_entered", function(player)
        Route(player, "dungeon_entered", { prefab="dungeon_gate" }, 1)
    end)
    SurfaceReceipt("hh_dungeon_completed", function(player)
        Route(player, "dungeon_completed", { source="dungeon_manager" }, 1)
    end)
    SurfaceReceipt("hh_dungeon_coin_changed", function(player, data)
        if data ~= nil and Integer(data.amount, 1, 2000000000) then
            Route(player, "dungeon_coin_earned", { currency="dungeon_coin" }, data.amount)
        end
    end)
    SurfaceReceipt("hh_dungeon_shop_open_server", function(player)
        Route(player, "dungeon_shop_opened", { source="hh_dungeon_shop" }, 1)
    end)
    SurfaceReceipt("hh_dungeon_shop_purchased", function(player)
        Route(player, "dungeon_shop_purchase", { source="hh_dungeon_shop" }, 1)
    end)
    SurfaceReceipt("hh_dungeon_stock_token_used", function(player)
        Route(player, "dungeon_shop_restocked", { source="hh_dungeon_shop", use_id="dq_stock_token" }, 1)
    end)
    inst:ListenForEvent("ttk_strengthen_gems_spent", function(player, data)
        if data ~= nil and Integer(data.amount, 1, 13) then
            Route(player, "strengthen_gem_spent", { prefab="wb_enhancegem" }, data.amount)
        end
    end)
    inst:ListenForEvent("ttk_strengthen_success", function(player, data)
        if not Master() or data == nil or not Integer(data.level, 1, 13) then return end
        for _, row in ipairs(AchievementCatalog.ByEvent("strengthen_success")) do
            if Matches(row.params, data) then
                if row.params.level ~= nil then AdvanceTo(component, row, row.target, data)
                else component:Advance(row.id, 1, data) end
            end
        end
    end)
    inst:ListenForEvent("ttk_strengthen_protection_used", function(player, data)
        if data ~= nil then Route(player, "strengthen_protection_used", data, 1) end
    end)
    inst:ListenForEvent("ttk_strengthen_scroll_used", function(player, data)
        if data ~= nil then Route(player, "strengthen_scroll_used", data, 1) end
    end)
    inst:ListenForEvent("ttk_slot_spin_committed", function(player, data)
        if data ~= nil then Route(player, "slotmachine_spin", { prefab="ttk_choujiangji" }, 1) end
    end)
    inst:ListenForEvent("ttk_slot_reward_committed", function(player, data)
        if data ~= nil then Route(player, "slotmachine_reward", data, 1) end
    end)
    inst:ListenForEvent("oneat", OnEat)
    inst:ListenForEvent("killed", OnKilled)
    inst:ListenForEvent("builditem", function(player, data) OnBuild(player, data, "builditem") end)
    inst:ListenForEvent("buildstructure", function(player, data) OnBuild(player, data, "buildstructure") end)
    inst:ListenForEvent("finishedwork", function(player, data)
        if data == nil or data.target == nil or data.action == nil or Seen(state, "work", data) then return end
        local evidence = { prefab=data.target.prefab, action=data.action.id, stump=data.target:HasTag("stump") }
        Route(player, "work_action", evidence, 1)
        Seasonal(player, "finishedwork", evidence, 1)
    end)
    inst:ListenForEvent("picksomething", function(player, data)
        if data == nil or data.object == nil or Seen(state, "picks", data) then return end
        local evidence = { prefab=data.object.prefab }
        Route(player, "pick_prefab", evidence, 1)
        Seasonal(player, "picksomething", evidence, 1)
        if data.object:HasTag("farm_plant") then
            Route(player, "harvest_crop", { source="farm", action="HARVEST" }, 1)
        end
    end)
    inst:ListenForEvent("itemget", function(player, data)
        if data ~= nil then CreditInventoryItem(data.item) end
        QueueOwnership(player)
    end)
    for _, event in ipairs({ "itemlose", "newactiveitem", "equip", "unequip" }) do
        inst:ListenForEvent(event, QueueOwnership)
    end
    inst:ListenForEvent("fishingcollect", function(player, data)
        local fish = data ~= nil and data.fish or nil
        if fish == nil or (fish.prefab ~= "fish" and fish.prefab ~= "eel")
            or Seen(state, "fish", fish) then return end
        Route(player, "fish_caught", { source="pond", prefab=fish.prefab }, 1)
    end)
    inst:ListenForEvent("performaction", OnFarmAction)
    inst:ListenForEvent("temperaturedelta", ObserveTemperature)
    -- farmtiller.lua and oar.lua emit these only after the successful action.
    inst:ListenForEvent("tilling", function(player)
        Route(player, "farm_action", { action="TILL" }, 1)
        Seasonal(player, "tilling", { action="TILL" }, 1)
    end)
    inst:ListenForEvent("rowing", function(player) Seasonal(player, "rowing", { action="ROW" }, 1) end)
    inst:ListenForEvent("death", function(player)
        if state.dead or player.components.health == nil or not player.components.health:IsDead() then return end
        state.dead = true
        state.hot, state.cold, state.night = nil, nil, nil
    end)
    inst:ListenForEvent("ms_respawnedfromghost", function(player)
        if not state.dead or not Living(player) then return end
        state.dead = false
        Route(player, "survival_event", { key="revive" }, 1)
    end)
    inst:WatchWorldState("season", function(player)
        local season = G.TheWorld.state.season
        if state.season ~= season then
            if Living(player) then Route(player, "survival_event", { key=state.season }, 1) end
            state.season = season
        end
        player:DoTaskInTime(0, RefreshSeason)
    end)
    inst:WatchWorldState("cycles", function(player)
        local cycle = G.TheWorld.state.cycles
        if type(cycle) ~= "number" then return end
        if state.cycle ~= nil and cycle > state.cycle and Living(player) then
            Route(player, "survival_event", { key="hundred_days" }, 1)
            Route(player, "survival_event", { key="solo_days" }, 1)
        end
        state.cycle = cycle
        local seasonal = component.core.seasonal
        if seasonal ~= nil and seasonal.rollover_pending then player:DoTaskInTime(0, RefreshSeason) end
    end)
    inst:WatchWorldState("isnight", function(player)
        if G.TheWorld.state.isnight then state.night = Living(player) end
    end)
    inst:WatchWorldState("isday", function(player)
        if not G.TheWorld.state.isday then return end
        if state.night and Living(player) then Route(player, "survival_event", { key="night" }, 1) end
        state.night = nil
    end)
    inst:DoTaskInTime(0, function(player)
        state.dead = player:HasTag("playerghost")
            or (player.components.health ~= nil and player.components.health:IsDead())
        RefreshSeason(player)
        OnCultivation(player)
        OnProgression(player)
        ObserveOwnership(player)
    end)
end

AddPlayerPostInit(function(inst)
    inst._ttk_achievement_rpc_namespace = modname
    inst._ttk_achievement_snapshot = G.net_string(inst.GUID, "ttk.achievement.snapshot", "ttk_achievement_netdirty")
    InstallPlayer(inst)
end)
modimport("main/ttk_achievement_perks.lua")
AddComponentPostInit("eater", InstallEater)
AddComponentPostInit("inventoryitem", function(self)
    if not Master() or self._ttk_achievement_hook then return end
    self._ttk_achievement_hook = true
    self.inst:ListenForEvent("onputininventory", function(item) CreditInventoryItem(item) end)
    local function LostOwner(item)
        QueueOwnership(last_inventory_owner[item])
        last_inventory_owner[item] = nil
    end
    self.inst:ListenForEvent("ondropped", LostOwner)
    self.inst:ListenForEvent("onremove", LostOwner)
end)
AddComponentPostInit("container", function(self)
    if not Master() or self._ttk_achievement_hook then return end
    self._ttk_achievement_hook = true
    local function Changed(container)
        local item = container.components.inventoryitem
        local owner = item ~= nil and item:GetGrandOwner() or nil
        QueueOwnership(owner)
    end
    -- Container emits itemlose on the bag, not its player. Deferred observation
    -- waits until removal/transfer has finished and still excludes remote boxes.
    self.inst:ListenForEvent("itemget", Changed)
    self.inst:ListenForEvent("itemlose", Changed)
end)

-- farmplantable.lua returns true only after replacing soil and consuming seed.
-- These are supported native seed prefabs, not string-derived crop evidence.
local SEED_CROPS = {
    seeds="random", carrot_seeds="carrot", pumpkin_seeds="pumpkin", eggplant_seeds="eggplant",
    dragonfruit_seeds="dragonfruit", asparagus_seeds="asparagus", tomato_seeds="tomato",
    potato_seeds="potato", garlic_seeds="garlic", onion_seeds="onion", pepper_seeds="pepper",
    pomegranate_seeds="pomegranate", corn_seeds="corn", durian_seeds="durian", watermelon_seeds="watermelon",
}
AddComponentPostInit("farmplantable", function(self)
    if not Master() or self._ttk_achievement_hook then return end
    self._ttk_achievement_hook = true
    local previous = self.Plant
    self.Plant = function(plantable, target, planter, ...)
        local prefab = plantable.inst.prefab
        local crop = SEED_CROPS[prefab]
        local success = previous(plantable, target, planter, ...)
        if success == true and crop ~= nil then Route(planter, "plant_seed", { prefab=prefab, crop=crop }, 1) end
        return success
    end
end)

-- Native stewer calls ondonecooking before setting done=true. Defer receipt;
-- settle before save/harvest too so those cannot erase a committed product.
AddComponentPostInit("stewer", function(self)
    if not Master() or self.inst.prefab ~= "cookpot" or self._ttk_achievement_cooking_hook then return end
    self._ttk_achievement_cooking_hook = true
    local pending, awarded, callback
    local function Settle()
        if not Master() or pending == nil or awarded or not self.done then return end
        awarded = true
        local receipt = pending
        pending = nil
        for _, player in ipairs(G.AllPlayers or {}) do
            if player.userid == receipt.chef_id then
                Route(player, "cook_product", { cooker="cookpot", prefab=receipt.product }, 1)
                break
            end
        end
    end
    local function HookCallback()
        if callback ~= nil and self.ondonecooking == callback then return end
        local previous = self.ondonecooking
        callback = function(inst, ...)
            if previous ~= nil then previous(inst, ...) end
            if not awarded and self.product ~= nil and self.chef_id ~= nil then
                pending = { chef_id=self.chef_id, product=self.product }
                inst:DoTaskInTime(0, Settle)
            end
        end
        self.ondonecooking = callback
    end
    local start, save, load, harvest = self.StartCooking, self.OnSave, self.OnLoad, self.Harvest
    self.StartCooking = function(stewer, ...)
        Settle()
        if stewer.targettime == nil and stewer.inst.components.container ~= nil then pending, awarded = nil, false end
        HookCallback()
        return start(stewer, ...)
    end
    self.OnSave = function(stewer, ...)
        Settle()
        local data = save(stewer, ...)
        data.ttk_achievement_cook_awarded = awarded == true
        return data
    end
    self.OnLoad = function(stewer, data, ...)
        pending = nil
        awarded = data ~= nil and (data.ttk_achievement_cook_awarded == true or data.done == true)
        HookCallback()
        return load(stewer, data, ...)
    end
    self.Harvest = function(stewer, ...)
        Settle()
        return harvest(stewer, ...)
    end
    self.inst:DoTaskInTime(0, HookCallback)
end)
AddComponentPostInit("stackable", function(self)
    if not Master() or self._ttk_achievement_hook then return end
    self._ttk_achievement_hook = true
    self.inst:ListenForEvent("stacksizechange", function(item) CreditInventoryItem(item) end)
    local previous_get, previous_put = self.Get, self.Put
    self.Get = function(stack, ...)
        local before = CopyReceipts(stack.inst, ItemAmount(stack.inst))
        inventory_depth = inventory_depth + 1
        local ok, child = pcall(previous_get, stack, ...)
        if ok and child ~= nil and child ~= stack.inst then
            local size = ItemAmount(child)
            local original, split = Receipts(stack.inst, ItemAmount(stack.inst)), Receipts(child, size)
            for player, count in pairs(before) do
                local moved = math.min(count, size)
                original[player], split[player] = count - moved, moved
            end
            pending_inventory[child] = true
        end
        inventory_depth = inventory_depth - 1
        FlushInventory()
        if not ok then error(child) end
        return child
    end
    self.Put = function(stack, item, ...)
        local oldsize = ItemAmount(stack.inst)
        local destination, donor = CopyReceipts(stack.inst, oldsize), CopyReceipts(item, ItemAmount(item))
        inventory_depth = inventory_depth + 1
        local ok, leftovers = pcall(previous_put, stack, item, ...)
        if ok then
            local moved = math.max(0, ItemAmount(stack.inst) - oldsize)
            local received = Receipts(stack.inst, ItemAmount(stack.inst))
            local remaining = Receipts(item, item:IsValid() and ItemAmount(item) or 0)
            for player, count in pairs(donor) do
                local carried = math.min(count, moved)
                received[player] = (destination[player] or 0) + carried
                remaining[player] = count - carried
            end
            pending_inventory[stack.inst] = true
        end
        inventory_depth = inventory_depth - 1
        FlushInventory()
        if not ok then error(leftovers) end
        return leftovers
    end
end)
AddComponentPostInit("follower", function(self)
    if not Master() or self._ttk_achievement_hook then return end
    self._ttk_achievement_hook = true
    self.inst:ListenForEvent("killed", OnKilled)
end)
-- deployable.lua's event contains only a prefab string. Capture the real item
-- before Deploy removes it, then route only its successful return value.
AddComponentPostInit("deployable", function(self)
    if not Master() or self._ttk_achievement_hook then return end
    self._ttk_achievement_hook = true
    local previous = self.Deploy
    self.Deploy = function(deployable, pt, deployer, ...)
        local prefab = deployable.inst.prefab
        local fertilizer = deployable.inst.components.fertilizer
        local nutrients = fertilizer ~= nil and fertilizer.nutrients ~= nil
            and { fertilizer.nutrients[1], fertilizer.nutrients[2], fertilizer.nutrients[3] } or nil
        local ok, reason = previous(deployable, pt, deployer, ...)
        if ok == true and ResolveSender(deployer) ~= nil then
            PerkEffects.ApplyFertilizer(deployer, pt, nutrients)
            Seasonal(deployer, "deployitem", { action="DEPLOY", prefab=prefab }, 1)
        end
        return ok, reason
    end
end)

-- RPC boundary: register names on both peers so DST assigns matching RPC IDs;
-- every handler resolves only the engine-provided sender on the master server.
-- Core methods preserve replay records; publish only on success, avoiding the
-- older component ClaimAchievement/PurchasePerk wrappers' failure snapshots.
AddModRPCHandler(modname, "AchievementClaim", function(sender, id, request_id, ...)
    if select("#", ...) ~= 0 or not ValidID(id) or not ValidRequest(request_id) then return end
    local component = ResolveSender(sender)
    if component == nil or AchievementCatalog.ById(id) == nil then return end
    local ok = component.core:ClaimAchievement(id, request_id)
    component:PushSnapshot() -- Also acknowledge rejected requests to release UI pending state.
end)

AddModRPCHandler(modname, "AchievementPerk", function(sender, id, request_id, ...)
    if select("#", ...) ~= 0 or not ValidID(id) or not ValidRequest(request_id) then return end
    local component = ResolveSender(sender)
    if component == nil or PerkCatalog.ById(id) == nil then return end
    local ok = component.core:PurchasePerk(id, request_id)
    component:PushSnapshot()
end)

AddModRPCHandler(modname, "AchievementSeasonal", function(sender, kind, slot_index, id, request_id, ...)
    if select("#", ...) ~= 0 or not ValidID(id) or not ValidRequest(request_id) then return end
    local component = ResolveSender(sender)
    local seasonal = component ~= nil and component.core.seasonal or nil
    if seasonal == nil or seasonal.season ~= G.TheWorld.state.season then return end
    if kind == "task" then
        if not Integer(slot_index, 1, 20) then return end
        local slot = seasonal.slots[slot_index]
        if slot == nil or slot.task_id ~= id then return end
        component:ClaimSeasonal(slot.task_id, request_id)
    elseif kind == "chest" then
        if not Integer(slot_index, 1, 4) then return end
        local milestone = CHEST_MILESTONES[slot_index]
        if id ~= "chest_" .. tostring(milestone) then return end
        component:ClaimChest(seasonal.season, milestone, request_id)
    end
end)

AddModRPCHandler(modname, "AchievementSnapshot", function(sender, request_id, ...)
    if select("#", ...) ~= 0 or not ValidRequest(request_id) then return end
    local component = ResolveSender(sender)
    if component ~= nil then component:PushSnapshot() end
end)
