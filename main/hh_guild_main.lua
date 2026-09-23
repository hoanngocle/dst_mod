local HHGuideLock = require("utils/hh_guide_lock")
local HHSummaryLock = require("utils/hh_summary_lock")
local RankDefs = require("guild/hh_rank_defs")

TUNING.HH_GUILD = TUNING.HH_GUILD or {
    SHOP_RESET_DAYS = 2,
    INTERACT_DISTANCE = 8,
    STAFF_OFFSET_X = 16,
    STAFF_OFFSET_Z = 0,
    STAFF_SPAWN_RETRIES = 12,
    STAFF_WANDER_RADIUS = 40,
    STAFF_WALK_SPEED = 2.5,
}

local function IsNight()
    return TheWorld ~= nil and TheWorld.state ~= nil and TheWorld.state.phase == "night"
end

local function CanInteract(doer, staff)
    if doer == nil or staff == nil or not staff:IsValid() then
        return false
    end
    if doer:HasTag("playerghost") or not staff:HasTag("hh_guild_employee") or IsNight() then
        return false
    end
    return true
end

local HH_GUILD_OPEN = Action({ priority=10, mount_valid=false })
HH_GUILD_OPEN.id = "HH_GUILD_OPEN"
HH_GUILD_OPEN.str = "Làm việc với Hiệp Hội"
HH_GUILD_OPEN.fn = function(act)
    local doer = act.doer
    local staff = act.target
    if not CanInteract(doer, staff) then
        if doer and doer.components.talker then
            doer.components.talker:Say(IsNight()
                and "Nhân Viên Hiệp Hội đã đi ngủ."
                or "Không thể sử dụng Hiệp Hội lúc này.")
        end
        return false
    end

    local rank = doer.components.hh_rank
    local shop = doer.components.hh_guild_shop
    if rank == nil or shop == nil then
        return false
    end
    local quest = doer.components.hh_guild_quest
    if quest then
        quest:EnsureOffers()
    end
    shop:EnsureCycle()
    rank:RefreshExamAvailability()
    rank:OpenInterface(staff)
    rank:SetNotice("Chào mừng đến với Hiệp Hội.")
    return true
end
AddAction(HH_GUILD_OPEN)

AddComponentAction("SCENE", "inspectable", function(inst, doer, actions, right)
    if right
        and inst ~= nil
        and inst:HasTag("hh_guild_employee")
        and doer ~= nil
        and not doer:HasTag("playerghost")
        and not IsNight() then
        table.insert(actions, ACTIONS.HH_GUILD_OPEN)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.HH_GUILD_OPEN, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.HH_GUILD_OPEN, "doshortaction"))

AddPlayerPostInit(function(inst)
    inst.hh_guild_rank = net_smallbyte(inst.GUID, "hh_guild.rank", "hh_guild_rankdirty")
    inst.hh_guild_credit = net_int(inst.GUID, "hh_guild.credit", "hh_guild_creditdirty")
    inst.hh_guild_exam_id = net_tinybyte(inst.GUID, "hh_guild.exam_id", "hh_guild_examdirty")
    inst.hh_guild_exam_status = net_tinybyte(inst.GUID, "hh_guild.exam_status", "hh_guild_examdirty")
    inst.hh_guild_exam_progress = net_ushortint(inst.GUID, "hh_guild.exam_progress", "hh_guild_examdirty")
    inst.hh_guild_exam_target = net_ushortint(inst.GUID, "hh_guild.exam_target", "hh_guild_examdirty")
    inst.hh_guild_exam_states = net_string(inst.GUID, "hh_guild.exam_states", "hh_guild_examdirty")

    inst.hh_guild_quest_id = net_byte(inst.GUID, "hh_guild.quest_id", "hh_guild_questdirty")
    inst.hh_guild_quest_status = net_tinybyte(inst.GUID, "hh_guild.quest_status", "hh_guild_questdirty")
    inst.hh_guild_quest_progress = net_ushortint(inst.GUID, "hh_guild.quest_progress", "hh_guild_questdirty")
    inst.hh_guild_quest_target = net_ushortint(inst.GUID, "hh_guild.quest_target", "hh_guild_questdirty")
    inst.hh_guild_quest_remaining = net_int(inst.GUID, "hh_guild.quest_remaining", "hh_guild_questdirty")
    inst.hh_guild_quest_reward = net_int(inst.GUID, "hh_guild.quest_reward", "hh_guild_questdirty")
    inst.hh_guild_quest_failure = net_string(inst.GUID, "hh_guild.quest_failure", "hh_guild_questdirty")
    inst.hh_guild_quest_offers = net_string(inst.GUID, "hh_guild.quest_offers", "hh_guild_questdirty")
    inst.hh_guild_quest_cooldown = net_int(inst.GUID, "hh_guild.quest_cooldown", "hh_guild_questdirty")
    inst.hh_guild_quest_completed_count = net_int(inst.GUID, "hh_guild.quest_completed_count", "hh_guild_questdirty")
    inst.hh_guild_quest_failed_count = net_int(inst.GUID, "hh_guild.quest_failed_count", "hh_guild_questdirty")

    inst.hh_guild_shop_cycle = net_int(inst.GUID, "hh_guild.shop_cycle", "hh_guild_shopdirty")
    inst.hh_guild_shop_stock = net_string(inst.GUID, "hh_guild.shop_stock", "hh_guild_shopdirty")
    inst.hh_guild_shop_products = net_string(inst.GUID, "hh_guild.shop_products", "hh_guild_shopdirty")
    inst.hh_guild_pending_reward = net_string(inst.GUID, "hh_guild.pending_reward", "hh_guild_pendingdirty")
    inst.hh_guild_notice = net_string(inst.GUID, "hh_guild.notice", "hh_guild_noticedirty")
    inst.hh_guild_ui_open = net_bool(inst.GUID, "hh_guild.ui_open", "hh_guild_ui_opendirty")

    if not TheWorld.ismastersim then
        return
    end

    if inst.components.hh_rank == nil then
        inst:AddComponent("hh_rank")
    end
    if inst.components.hh_sanctuary == nil then
        inst:AddComponent("hh_sanctuary")
    end
    if inst.components.hh_godslayer == nil then
        inst:AddComponent("hh_godslayer")
    end
    if inst.components.hh_ruler == nil then
        inst:AddComponent("hh_ruler")
    end
    if inst.components.hh_king == nil then
        inst:AddComponent("hh_king")
    end
    if inst.components.hh_death_threshold == nil then
        inst:AddComponent("hh_death_threshold")
    end
    if inst.components.hh_guild_shop == nil then
        inst:AddComponent("hh_guild_shop")
    end
    if inst.components.hh_guild_quest == nil then
        inst:AddComponent("hh_guild_quest")
    end

    if not inst._hh_rank_s_announcement_listener then
        inst._hh_rank_s_announcement_listener = true
        inst:ListenForEvent("hh_rank_changed", function(_, data)
            if data == nil
                or data.source ~= "claim_exam"
                or data.old_rank ~= RankDefs.RANK.A
                or data.new_rank ~= RankDefs.RANK.S then
                return
            end

            local display_name = inst:GetDisplayName()
            local king_strings = STRINGS ~= nil and STRINGS.HH_KING or nil
            local death_strings = STRINGS ~= nil and STRINGS.HH_DEATH_THRESHOLD or nil
            local growth_strings = STRINGS ~= nil and STRINGS.HH_SUPER_GROWTH or nil
            local king_template = king_strings ~= nil and king_strings.ANNOUNCEMENT
                or "Thợ săn %s đã mở khóa kỹ năng Nhà Vua"
            local death_template = death_strings ~= nil and death_strings.ANNOUNCEMENT
                or "Thợ săn %s đã mở khóa kỹ năng bị động Ngưỡng Sinh Tử"
            local growth_template = growth_strings ~= nil and growth_strings.ANNOUNCEMENT
                or "Thợ săn %s đã mở khóa kỹ năng bị động Siêu Tăng Trưởng"
            TheNet:Announce(string.format(king_template, display_name))
            TheNet:Announce(string.format(death_template, display_name))
            TheNet:Announce(string.format(growth_template, display_name))
        end)
    end
end)

local function FindPigKing()
    local king = TheSim:FindFirstEntityWithTag("king")
    if king ~= nil and king.prefab == "pigking" then
        return king
    end
    return nil
end

local function SpawnGuildStaff(world, retry)
    if world == nil or not world:IsValid() or world:HasTag("cave") then
        return
    end
    local pigking = FindPigKing()
    if pigking == nil then
        retry = (retry or 0) + 1
        if retry <= (TUNING.HH_GUILD.STAFF_SPAWN_RETRIES or 12) then
            world:DoTaskInTime(5, function()
                SpawnGuildStaff(world, retry)
            end)
        end
        return
    end

    local x, y, z = pigking.Transform:GetWorldPosition()
    local staff = TheSim:FindFirstEntityWithTag("hh_guild_employee")
    local spawned = staff == nil
    if spawned then
        staff = SpawnPrefab("guild_staff")
    end
    if staff ~= nil then
        local knownlocations = staff.components ~= nil and staff.components.knownlocations or nil
        if spawned then
            staff.Transform:SetPosition(
                x + (TUNING.HH_GUILD.STAFF_OFFSET_X or 4),
                y,
                z + (TUNING.HH_GUILD.STAFF_OFFSET_Z or 0)
            )
            if knownlocations ~= nil then
                knownlocations:RememberLocation("home", Point(x, y, z))
            end
        elseif knownlocations ~= nil then
            local staff_x, _, staff_z = staff.Transform:GetWorldPosition()
            knownlocations:RememberLocation("home", Point(staff_x, 0, staff_z))
        end
    end
end

local function GetShopCycle(cycles, reset_days)
    return math.floor(
        (tonumber(cycles) or 0) / math.max(1, tonumber(reset_days) or 1)
    )
end

local function InstallShopCycleWatcher(world)
    if world._hh_shop_cycle_watcher_installed then
        return
    end
    world._hh_shop_cycle_watcher_installed = true

    local guild_days = TUNING.HH_GUILD ~= nil and TUNING.HH_GUILD.SHOP_RESET_DAYS or 2
    local dungeon_days = TUNING.HH_DUNGEON_SHOP ~= nil and TUNING.HH_DUNGEON_SHOP.RESET_DAYS or 2
    local cycles = world.state ~= nil and world.state.cycles or 0
    local last_guild_cycle = GetShopCycle(cycles, guild_days)
    local last_dungeon_cycle = GetShopCycle(cycles, dungeon_days)
    local transition_cycles = nil
    local announce_reset
    local world_component = world.components ~= nil and world.components.hh_world or nil
    if world_component ~= nil and world_component.IsMasterShard ~= nil then
        announce_reset = world_component:IsMasterShard()
    else
        announce_reset = not world:HasTag("cave")
    end

    world:ListenForEvent("ms_cyclecomplete", function(_, completed_cycles)
        transition_cycles = tonumber(completed_cycles)
    end)

    world:WatchWorldState("cycles", function(_, current_cycles)
        current_cycles = tonumber(current_cycles) or 0
        local is_real_transition = transition_cycles ~= nil and transition_cycles == current_cycles
        transition_cycles = nil

        if not is_real_transition then
            last_guild_cycle = GetShopCycle(current_cycles, guild_days)
            last_dungeon_cycle = GetShopCycle(current_cycles, dungeon_days)
            return
        end

        local guild_cycle = GetShopCycle(current_cycles, guild_days)
        local dungeon_cycle = GetShopCycle(current_cycles, dungeon_days)
        if guild_cycle ~= last_guild_cycle then
            for _, player in ipairs(AllPlayers or {}) do
                if player ~= nil and player:IsValid()
                    and player.components ~= nil
                    and player.components.hh_guild_shop ~= nil
                then
                    player.components.hh_guild_shop:EnsureCycle()
                end
            end
            last_guild_cycle = guild_cycle
            if announce_reset then
                TheNet:Announce("Cửa hàng hiệp hội đã được làm mới")
            end
        end

        if dungeon_cycle ~= last_dungeon_cycle then
            local shop = world.components ~= nil and world.components.hh_dungeon_shop or nil
            if shop ~= nil then
                shop:EnsureCycle()
                shop:Sync()
            end
            last_dungeon_cycle = dungeon_cycle
            if announce_reset then
                TheNet:Announce("Cửa hàng hầm ngục đã được làm mới")
            end
        end
    end)
end

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    InstallShopCycleWatcher(inst)
    if inst:HasTag("cave") then
        return
    end
    inst:DoTaskInTime(3, function()
        SpawnGuildStaff(inst, 0)
    end)
end)

if not TheNet:IsDedicated() then
    local UnifiedOpen = require("ui/ttk_unified_open")
    local UnifiedRegistry = require("ui/ttk_unified_registry")
    AddClassPostConstruct("widgets/controls", function(self)
        self.inst:ListenForEvent("hh_guild_ui_opendirty", function()
            local owner = self.owner
            if owner and owner.hh_guild_ui_open and owner.hh_guild_ui_open:value() then
                if HHGuideLock.IsOpen(owner) or HHSummaryLock.IsOpen(owner) then
                    return
                end
                UnifiedOpen.Open(owner, "quests")
            else
                local screen = UnifiedRegistry.Get(owner)
                if screen ~= nil and screen.active_tab == "quests" then
                    screen:Close()
                end
            end
        end, self.owner)
    end)
end

local GUILD_STAFF_MAPICON_HIT_RADIUS = 24

local function GetGuildStaffMapIconHoverText(screen)
    if screen == nil or screen.GetCursorPosition == nil or screen.minimap == nil
        or FindClosestMapIconInRange == nil then
        return nil
    end

    local cursor_x, cursor_y = screen:GetCursorPosition()
    local screen_width = TheSim:GetScreenSize()
    if screen_width == nil or screen_width <= 0 then
        return nil
    end

    local world_x, world_z = screen.minimap:MapPosToWorldPos(cursor_x, cursor_y, 0)
    local edge_x, edge_z = screen.minimap:MapPosToWorldPos(
        cursor_x + (2 * GUILD_STAFF_MAPICON_HIT_RADIUS / screen_width),
        cursor_y,
        0
    )
    if world_x == nil or world_z == nil or edge_x == nil or edge_z == nil then
        return nil
    end

    local dx, dz = edge_x - world_x, edge_z - world_z
    local range = math.sqrt(dx * dx + dz * dz)
    local target = FindClosestMapIconInRange("guild_staff", world_x, 0, world_z, range)
    if target == nil or not target:IsValid() then
        return nil
    end
    return target:GetDisplayName() or (STRINGS.NAMES.GUILD_STAFF or "Nhân Viên Hiệp Hội")
end

AddClassPostConstruct("components/playercontroller", function(self)
    local old_GetHoverTextOverride = self.GetHoverTextOverride
    self.GetHoverTextOverride = function(controller, ...)
        local text = old_GetHoverTextOverride(controller, ...)
        if text ~= nil then
            return text
        end
        local screen = TheFrontEnd ~= nil and TheFrontEnd:GetActiveScreen() or nil
        if screen == nil or screen.name ~= "MapScreen" then
            return nil
        end
        return GetGuildStaffMapIconHoverText(screen)
    end
end)
