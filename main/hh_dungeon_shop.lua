local ShopDefs = require("dungeon_shop/hh_dungeon_shop_defs")
local HHUtils = require("utils/hh_utils")
local HHGuideLock = require("utils/hh_guide_lock")
local HHSummaryLock = require("utils/hh_summary_lock")

TUNING.HH_DUNGEON_SHOP = TUNING.HH_DUNGEON_SHOP or {
    RESET_DAYS = 2,
    MAX_COINS = 2000000000,
    OPEN_KEY = KEY_J,
}

local REWARD = {
    spider = 5, spider_hider = 10, spider_dropper = 15, spider_spitter = 15, tallbird = 20, lightninggoat = 30,
    bishop = 20, knight = 20, rook = 20, bishop_nightmare = 20, knight_nightmare = 20, rook_nightmare = 20,
    walrus = 40, warglet = 40,
    hh_dungeon_spider=10, hh_dungeon_firehound=10, hh_dungeon_icehound=10, hh_dungeon_snowhound=15, 
    hh_dungeon_lightninghound=15, hh_dungeon_horrorhound=10, hh_dungeon_pig=20, 
    deerclops=200, bearger=200, dragonfly=200, minotaur=200, spiderqueen=200, leif=200, warg=200,
    hh_igris_dungeon=1000, hh_beru_dungeon=1000, hh_sharkboi = 1000
}

local function IsDungeonEntity(inst)
    return inst ~= nil and (inst.hh_is_dungeon_monster or inst.hh_is_dungeon_boss or inst:HasTag("hh_dungeon_mob"))
end

local function GetReward(victim)
    local base = REWARD[victim.prefab] or 5
    local difficulty = math.max(1, tonumber(victim.hh_dungeon_difficulty) or 1)
    local tier = math.max(1, tonumber(victim.hh_dungeon_reward_tier) or (victim.hh_is_dungeon_boss and 5 or 1))
    local cap = victim.hh_is_dungeon_boss and 5000 or 500
    return math.min(cap, math.max(1, math.floor(base * difficulty * tier)))
end

local function AwardDungeonCoins(victim)
    if victim._hh_dungeon_coins_awarded or not IsDungeonEntity(victim) then return end
    victim._hh_dungeon_coins_awarded = true
    local manager = victim.hh_dungeon_manager or (TheWorld.components and TheWorld.components.dungeon_manager)
    local eligible = {}
    for player in pairs(manager and manager.players_in_dungeon or {}) do
        if player:IsValid() and not player:HasTag("playerghost") and player.components.hh_dungeon_coin then
            table.insert(eligible, player)
        end
    end
    table.sort(eligible, function(a, b) return tostring(a.userid or a.GUID) < tostring(b.userid or b.GUID) end)
    if #eligible == 0 then return end
    local total = GetReward(victim)
    local share, remainder = math.floor(total / #eligible), total % #eligible
    for index, player in ipairs(eligible) do
        local added = player.components.hh_dungeon_coin:Add(
            share + (index <= remainder and 1 or 0), victim.prefab
        )
        if added > 0 then
            HHUtils:SpawnClientStrFx(player, "+" .. tostring(added) .. " Xu Hầm ngục")
        end
    end
end

AddPrefabPostInit("world", function(inst)
    inst:ListenForEvent("hh_dungeon_monster_death", function(_, monster)
        AwardDungeonCoins(monster)
    end)
end)

-- Covers Dungeon summons that are not registered in DungeonManager.monsters.
-- The listener is intentionally a cheap flag check and the reward function is idempotent.
AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then return end
    inst:ListenForEvent("death", function(victim)
        if IsDungeonEntity(victim) then AwardDungeonCoins(victim) end
    end)
end)

local function GetDungeonItemOwner(item)
    local owner = item.components.inventoryitem ~= nil and item.components.inventoryitem.owner or nil
    if owner ~= nil and not owner:HasTag("player") and owner.components ~= nil
        and owner.components.inventoryitem ~= nil then
        owner = owner.components.inventoryitem.owner
    end
    return owner ~= nil and owner:HasTag("player") and owner or nil
end

local REINCARNATION_PAYLOAD_KEY = "hh_solo_leveling_reincarnation"
local REINCARNATION_COMPONENT_LOAD_ORDER = {
    "hh_leveling",
    "hh_rank",
    "hh_shadow_progression",
    "hh_shadow_manager",
    "hh_mana",
    "hh_buff",
    "hh_daily_quest",
    "hh_guild_quest",
    "hh_dungeon_coin",
    "hh_dungeon_effects",
    "hh_sanctuary",
    "hh_godslayer",
    "hh_ruler",
    "hh_king",
    "hh_death_threshold",
    "hh_guild_shop",
    "dungeon_cooldown",
    "hh_slot_lock_penalty",
}

local function CaptureReincarnationState(player)
    local payload = {
        version = 1,
        components = {},
    }
    for _, component_name in ipairs(REINCARNATION_COMPONENT_LOAD_ORDER) do
        local component = player.components[component_name]
        if component ~= nil and component.OnSave ~= nil then
            local saved
            if component_name == "hh_slot_lock_penalty"
                and player._hh_reincarnation_slot_lock_snapshot ~= nil then
                -- This snapshot was captured at ms_playerreroll, before
                -- vanilla DropEverything() can touch the old body.
                saved = player._hh_reincarnation_slot_lock_snapshot
            else
                saved = component:OnSave()
            end
            if saved ~= nil then
                payload.components[component_name] = saved
            end
        end
    end

    -- hh_player already transfers hh_items and monarch storage through
    -- hh_world on ms_playerreroll. Keep only the independent cooldown field.
    local hh_player = player.components.hh_player
    if hh_player ~= nil and hh_player.OnSave ~= nil then
        local saved = hh_player:OnSave()
        if saved ~= nil and saved.protect_carehealth_cd_elapsed ~= nil then
            payload.hh_player = {
                protect_carehealth_cd_elapsed = saved.protect_carehealth_cd_elapsed,
            }
        end
    end
    return payload
end

local function RestoreReincarnationState(player, data)
    if type(data) ~= "table" then
        return
    end
    local payload = data[REINCARNATION_PAYLOAD_KEY]
    if type(payload) ~= "table" then
        return
    end

    local hh_player_data = payload.hh_player
    local hh_player = player.components.hh_player
    if type(hh_player_data) == "table" and hh_player ~= nil and hh_player.OnLoad ~= nil then
        hh_player:OnLoad(hh_player_data)
    end

    if type(payload.components) ~= "table" then
        return
    end
    for _, component_name in ipairs(REINCARNATION_COMPONENT_LOAD_ORDER) do
        local saved = payload.components[component_name]
        local component = player.components[component_name]
        if saved ~= nil and component ~= nil and component.OnLoad ~= nil then
            component:OnLoad(saved)
        end
    end
end

local function InstallReincarnationRerollHooks(player)
    if player._hh_reincarnation_reroll_hooks_installed then
        return
    end

    local old_save_for_reroll = player.SaveForReroll
    local old_load_for_reroll = player.LoadForReroll
    if old_save_for_reroll == nil or old_load_for_reroll == nil then
        return
    end

    player._hh_reincarnation_reroll_hooks_installed = true
    player:ListenForEvent("ms_playerreroll", function(inst)
        if not inst._hh_reincarnation_pending then
            return
        end
        local slot_lock = inst.components.hh_slot_lock_penalty
        if slot_lock ~= nil and slot_lock.PrepareForReincarnation ~= nil then
            -- This event is vanilla's pre-DropEverything commit point.  Strip
            -- only physical lock entities; the component state is retained for
            -- the existing SaveForReroll payload and reconstructed on Load.
            inst._hh_reincarnation_slot_lock_snapshot = slot_lock:PrepareForReincarnation()
        end
        local manager = inst.components.hh_shadow_manager
        if manager ~= nil and manager.PrepareForReincarnation ~= nil then
            manager:PrepareForReincarnation()
        end
    end)

    player.SaveForReroll = function(inst, ...)
        local data = old_save_for_reroll(inst, ...)
        if not inst._hh_reincarnation_pending then
            return data
        end

        local payload = CaptureReincarnationState(inst)
        -- The marker is intentionally transient and must never enter normal
        -- saves or survive beyond this exact reroll snapshot.
        inst._hh_reincarnation_pending = nil
        inst._hh_reincarnation_slot_lock_snapshot = nil
        data = data or {}
        data[REINCARNATION_PAYLOAD_KEY] = payload
        return data
    end

    player.LoadForReroll = function(inst, data, ...)
        -- Vanilla LoadForReroll has no return value; keep its call order and
        -- restore the mod payload only after vanilla state has been applied.
        old_load_for_reroll(inst, data, ...)
        RestoreReincarnationState(inst, data)
    end
end

AddPrefabPostInit("multiplayer_portal_moonrock", function(inst)
    if not TheWorld.ismastersim or inst._hh_reincarnation_onaccept_wrapped then
        return
    end
    local trader = inst.components.moontrader
    if trader == nil or trader.onaccept == nil then
        return
    end

    local old_onaccept = trader.onaccept
    trader.onaccept = function(portal, giver, item)
        if giver ~= nil and item ~= nil and item.prefab == "hh_da_chuyen_sinh" then
            giver._hh_reincarnation_pending = true
        end
        return old_onaccept(portal, giver, item)
    end
    inst._hh_reincarnation_onaccept_wrapped = true
end)

AddComponentPostInit("finiteuses", function(self)
    local old_use = self.Use
    self.Use = function(component, num, ...)
        local owner = GetDungeonItemOwner(component.inst)
        local effects = owner ~= nil and owner.components.hh_dungeon_effects or nil
        if effects ~= nil and effects:ShouldProtectDurability() then return end
        return old_use(component, num, ...)
    end
end)

AddPlayerPostInit(function(inst)
    inst.hh_dungeon_coins = net_int(inst.GUID, "hh_dungeon.coins", "hh_dungeon_coindirty")
    inst.hh_dungeon_coin_pending = net_string(inst.GUID, "hh_dungeon.pending", "hh_dungeon_coin_pendingdirty")
    inst.hh_dungeon_coin_notice = net_string(inst.GUID, "hh_dungeon.notice", "hh_dungeon_coin_noticedirty")
    inst.hh_dungeon_shop_cycle_client = net_int(inst.GUID, "hh_dungeon.player_shop_cycle", "hh_dungeon_shopdirty")
    inst.hh_dungeon_shop_products_client = net_string(inst.GUID, "hh_dungeon.player_shop_products", "hh_dungeon_shopdirty")
    inst.hh_dungeon_shop_stock_client = net_string(inst.GUID, "hh_dungeon.player_shop_stock", "hh_dungeon_shopdirty")
    inst.hh_dungeon_effects_client = net_string(inst.GUID, "hh_dungeon.effects", "hh_dungeon_effectsdirty")
    if not TheWorld.ismastersim then return end
    if inst.components.hh_dungeon_coin == nil then inst:AddComponent("hh_dungeon_coin") end
    if inst.components.hh_dungeon_effects == nil then inst:AddComponent("hh_dungeon_effects") end
    InstallReincarnationRerollHooks(inst)
    inst:DoTaskInTime(1, function()
        if inst.components.hh_dungeon_coin then inst.components.hh_dungeon_coin:ClaimPending() end
    end)
end)

AddPrefabPostInit("world", function(inst)
    inst.hh_dungeon_shop_cycle = net_int(inst.GUID, "hh_dungeon.shop_cycle", "hh_dungeon_shopdirty")
    inst.hh_dungeon_shop_products = net_string(inst.GUID, "hh_dungeon.shop_products", "hh_dungeon_shopdirty")
    inst.hh_dungeon_shop_stock = net_string(inst.GUID, "hh_dungeon.shop_stock", "hh_dungeon_shopdirty")
    if not TheWorld.ismastersim then return end
    if inst.components.hh_dungeon_shop == nil then inst:AddComponent("hh_dungeon_shop") end
    inst.components.hh_dungeon_shop:EnsureCycle()
    inst.components.hh_dungeon_shop:Sync()
end)

local USE_DUNGEON_ITEM = Action({ priority=10, mount_valid=false })
USE_DUNGEON_ITEM.id = "USE_DUNGEON_ITEM"
USE_DUNGEON_ITEM.str = "Sử dụng"
USE_DUNGEON_ITEM.silent_fail = true
USE_DUNGEON_ITEM.fn = function(act)
    local item = act.invobject or act.target
    return item ~= nil and item.UseDungeonItem ~= nil and item:UseDungeonItem(act.doer) or false
end
AddAction(USE_DUNGEON_ITEM)
AddComponentAction("INVENTORY", "inventoryitem", function(inst, doer, actions, right)
    -- ItemTile/GetDescriptionString và GetItemSelfAction thu thập INVENTORY
    -- action mà không luôn truyền right=true (giống ACTIONS.EAT vanilla).
    -- Vì vậy không được khóa action ở tham số `right`; thao tác thực thi vẫn
    -- được DST gán vào CONTROL_SECONDARY cho inventory item.
    if inst:HasTag("hh_dungeon_shop_item") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.USE_DUNGEON_ITEM)
    end
end)
local function GetDungeonItemActionState(_, action)
    local item = action ~= nil and (action.invobject or action.target) or nil
    if item == nil then return "doshortaction" end
    -- Potion → animation uống thuốc
    if item:HasTag("hh_dungeon_potion") then return "drinkelixir" end
    -- Sửa Vũ Khí / Bộ Sửa Giáp → animation khâu (build_pre → build_loop như sewing_tape)
    if item:HasTag("hh_dg_sew") then return "hh_dolongaction" end
    -- Cast spell (Bùa Hồi Chiêu, Bùa Tự Nhặt, Bùa Lao Động, Máy Thu Đồ, Quang Minh Thạch, Bùa Bền Bỉ)
    if item:HasTag("hh_dg_cast") then return "castspell" end
    -- Gift animation (Đèn Hầm Ngục, Túi Tiếp Tế, Bộ Chống Lạnh/Nóng, Nâng Cấp Túi, Khẩu Phần Ăn)
    if item:HasTag("hh_dg_gift") then return "hh_opengift" end
    -- Gift animation đặc biệt cho Trại Dã Chiến (không sound gift, thay bằng VFX spawn)
    if item:HasTag("hh_dg_gift_camp") then return "hh_opengift_camp" end
    -- Phiếu Bổ Sung → animation tung đồng xu
    if item:HasTag("hh_dg_coin") then return "hh_cointosscastspell" end
    return "doshortaction"
end
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.USE_DUNGEON_ITEM, GetDungeonItemActionState))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.USE_DUNGEON_ITEM, GetDungeonItemActionState))

-- ═══════════════════════════════════════════════════════════════════
-- Custom stategraph states cho animation Gift (mở hộp quà)
-- Không dùng opengift vanilla vì nó phụ thuộc giftreceiver/popup UI.
-- ═══════════════════════════════════════════════════════════════════
local GIFT_STATE = State{
    name = "hh_opengift",
    tags = { "doing", "busy" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve/common/player_receives_gift")
        inst.AnimState:PlayAnimation("gift_pre")
        inst.AnimState:PushAnimation("gift_pst", false)
    end,

    timeline = {
        TimeEvent(20 * FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(38 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
    },

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
}

-- Gift animation đặc biệt cho Trại Dã Chiến: đổi sound gift, thêm VFX spawn
local GIFT_CAMP_STATE = State{
    name = "hh_opengift_camp",
    tags = { "doing", "busy" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.SoundEmitter:PlaySound("dontstarve/common/player_receives_gift")
        inst.AnimState:PlayAnimation("gift_pre")
        inst.AnimState:PushAnimation("gift_pst", false)
    end,

    timeline = {
        TimeEvent(20 * FRAMES, function(inst)
            inst:PerformBufferedAction()
        end),
        TimeEvent(38 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
    },

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
}

local COIN_STATE = State{
    name = "hh_cointosscastspell",
    tags = { "doing", "busy", "canrotate" },
    onenter = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        inst.AnimState:PlayAnimation("cointoss_pre")
        inst.AnimState:PushAnimation("cointoss", false)
        inst.components.locomotor:Stop()
    end,
    timeline = {
        TimeEvent(7 * FRAMES, function(inst)
            local fx = SpawnPrefab((inst.components.rider ~= nil and inst.components.rider:IsRiding()) and "cointosscastfx_mount" or "cointosscastfx")
            fx.entity:SetParent(inst.entity)
            fx:SetUp({1, 1, 1})
        end),
        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/pig/mini_game/cointoss")
        end),
        TimeEvent(15 * FRAMES, function(inst)
            local fx = SpawnPrefab("staff_castinglight")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            fx:SetUp({1, 1, 1}, 1.2, 0.33)
            inst:PerformBufferedAction()
        end),
    },
    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
    onexit = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
    end,
}

-- The vanilla client graph uses a prediction-only state for cointoss.  FX
-- prefabs expose SetUp only on the master simulation, so the server timeline
-- above must not be registered on wilson_client.
local COIN_CLIENT_TIMEOUT = 2
local COIN_CLIENT_STATE = State{
    name = "hh_cointosscastspell",
    tags = { "doing", "busy", "canrotate" },
    server_states = { "hh_cointosscastspell" },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("cointoss_pre")
        inst.AnimState:PushAnimation("cointoss_lag", false)
        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(COIN_CLIENT_TIMEOUT)
    end,
    onupdate = function(inst)
        if inst.sg:ServerStateMatches() then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle")
        end
    end,
    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end,
}

local SEW_STATE = State{
    name = "hh_dolongaction",
    tags = { "doing", "busy" },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("build_pre")
        inst.AnimState:PushAnimation("build_loop", true)
        inst.SoundEmitter:PlaySound("dontstarve/HUD/repair_clothing", "make")
    end,
    timeline = {
        TimeEvent(4 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
        TimeEvent(20 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("build_pst")
            inst.SoundEmitter:KillSound("make")
        end),
    },
    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
    onexit = function(inst)
        inst.SoundEmitter:KillSound("make")
    end,
}

AddStategraphState("wilson", GIFT_STATE)
AddStategraphState("wilson_client", GIFT_STATE)
AddStategraphState("wilson", GIFT_CAMP_STATE)
AddStategraphState("wilson_client", GIFT_CAMP_STATE)
AddStategraphState("wilson", COIN_STATE)
AddStategraphState("wilson_client", COIN_CLIENT_STATE)
AddStategraphState("wilson", SEW_STATE)
AddStategraphState("wilson_client", SEW_STATE)

AddClassPostConstruct("components/playeractionpicker", function(self)
    local old_GetInventoryActions = self.GetInventoryActions
    function self:GetInventoryActions(useitem, right)
        local actions = old_GetInventoryActions(self, useitem, right) or {}
        if useitem ~= nil and useitem:HasTag("hh_dungeon_shop_item")
            and not self.inst:HasTag("playerghost") then
            local has_action = false
            for _, buffered_action in ipairs(actions) do
                if buffered_action.action == ACTIONS.USE_DUNGEON_ITEM then
                    has_action = true
                    break
                end
            end
            if not has_action then
                table.insert(actions, 1, GLOBAL.BufferedAction(
                    self.inst, nil, ACTIONS.USE_DUNGEON_ITEM, useitem
                ))
            end
        end
        return actions
    end
end)

local function CanOpen(player)
    if player == nil or not player:IsValid() or player:HasTag("playerghost") then return false end
    if TheWorld:HasTag("cave") or player:HasTag("hh_dungeon_transition") then return false end
    return true
end

AddModRPCHandler("hh_rpc", "hh_dungeon_shop_open", function(player)
    if CanOpen(player) and TheWorld.components.hh_dungeon_shop then
        local shop = TheWorld.components.hh_dungeon_shop
        shop:EnsureCycle()
        shop:SyncToPlayer(player)
        player:PushEvent("hh_dungeon_shop_open_server")
    end
end)

AddModRPCHandler("hh_rpc", "hh_dungeon_shop_buy", function(player, product_id, nonce)
    if not CanOpen(player) or type(product_id) ~= "string" then return end
    nonce = math.floor(tonumber(nonce) or 0)
    if nonce <= (player._hh_dungeon_shop_nonce or 0) then return end
    player._hh_dungeon_shop_nonce = nonce
    local now = GetTime()
    if now - (player._hh_dungeon_shop_rpc_time or 0) < .2 then return end
    player._hh_dungeon_shop_rpc_time = now
    local shop = TheWorld.components.hh_dungeon_shop
    if shop then
        local ok, message = shop:Purchase(player, product_id)
        if not ok and player.components.hh_dungeon_coin then player.components.hh_dungeon_coin:SetNotice(message) end
    end
end)

if not TheNet:IsDedicated() then
    local UnifiedOpen = require("ui/ttk_unified_open")
    local function OpenDungeonShop()
        if HHGuideLock.IsOpen(ThePlayer) then return end
        if ThePlayer == nil or ThePlayer:HasTag("playerghost") or TheWorld:HasTag("cave") then return end
        UnifiedOpen.Open(ThePlayer, "shop")
    end
    TheInput:AddKeyDownHandler(TUNING.HH_DUNGEON_SHOP.OPEN_KEY or KEY_J, OpenDungeonShop)
    AddClassPostConstruct("screens/playerhud", function(self)
        local HUD = require("widgets/hh_dungeon_coin_hud")
        self.hh_dungeon_coin_hud = self:AddChild(HUD(self.owner))
        self.hh_dungeon_coin_hud:SetPosition(-100, 80, 0)
    end)
end
