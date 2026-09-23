local Progression = require "util/eva_progression"
local Panel = {
    NAMESPACE = "EVA_SKILL_PANEL_V1",
    RPC_NAME = "IMMEDIATE",
    FOX_RPC_NAME = "FOX_BLINK",
    HOTKEY_ORDER = {"life", "harvest", "wings", "daydu", "array"},
    DISPLAY_ORDER = {"life", "harvest", "wings", "daydu", "array"},
    SPELL_INDEX = {life = 1, wings = 2, array = 3, harvest = 4, daydu = 5},
    SKILLS = {
        life = {
            label = "Sinh Chi Hoa",
            tooltip = "Sinh Chi Hoa — 10 Hồn Lực · hồi chiêu 60 giây",
            texture = "eva_skill_life.tex",
            atlas = "images/eva_skill_icons.xml",
            cooldown_net = "_eva_skill_cd_life",
        },
        wings = {
            label = "Tinh Vũ Nguyệt Dực",
            tooltip = "Tinh Vũ Nguyệt Dực — bật tốn 100 Hồn Lực · tắt miễn phí",
            texture = "eva_skill_wings.tex",
            atlas = "images/eva_skill_icons.xml",
        },
        array = {
            label = "Trảm Linh",
            tooltip = "Huyền Thiên Trảm Linh Kiếm\n100 Hồn Lực · tầm 12 · hồi 60 giây",
            texture = "eva_skill_array.tex",
            atlas = "images/eva_skill_icons.xml",
            cooldown_net = "_eva_skill_cd_array",
        },
        harvest = {
            label = "Tử Phong Tụ Linh",
            tooltip = "Tử Phong Tụ Linh — 3 Hồn Lực · tầm 12\nBán kính 8 · kéo/thu hoạch 7 giây · hồi 10 giây",
            texture = "eva_skill_harvest.tex",
            atlas = "images/eva_skill_icons.xml",
            cooldown_net = "_eva_skill_cd_harvest",
            range = 12,
        },
        daydu = {
            label = "Dạ Du",
            tooltip = "Dạ Du — 5 Hồn Lực · tầm 12\nĐánh dấu chịu thêm 10% sát thương trong 5 giây · hồi 15 giây",
            texture = "eva_skill_daydu.tex",
            atlas = "images/eva_skill_icons.xml",
            cooldown_net = "_eva_skill_cd_daydu",
            range = 12,
        },
    },
}

Panel.SKILLS.array.range = 12

function Panel.IsSkillUnlocked(player, skill)
    return Progression.IsUnlocked(player, skill)
end

function Panel.GetRequiredLevel(skill)
    return Progression.RequiredLevel(skill)
end

function Panel.GetSkillTooltip(player, skill)
    local definition = Panel.SKILLS[skill]
    local required = Progression.RequiredLevel(skill)
    local prefix = Progression.IsUnlocked(player, skill) and "Cấp EVA " or "Chưa mở — cần cấp EVA "
    return prefix .. tostring(required) .. "\n" .. definition.tooltip
end

local COMPONENTS = {
    array = "eva_scythe_array",
    daydu = "eva_daydu",
    fox = "eva_fox_blink",
    harvest = "eva_harvest",
    life = "eva_life",
    wings = "eva_wings",
}

local POINT_SKILLS = {
    array = true,
    harvest = true,
    daydu = true,
}

local RPC_INTERVAL = 0.2
local client_send_immediate = nil
local client_send_fox = nil

local function IsFiniteNumber(value)
    return type(value) == "number"
        and value == value
        and value ~= math.huge
        and value ~= -math.huge
end

local function IsEva(player)
    return player ~= nil
        and player.IsValid ~= nil
        and player.HasTag ~= nil
        and player:IsValid()
        and player.prefab == "eva"
        and player:HasTag("eva")
        and not player:HasTag("playerghost")
end

local function GetBoundBook(player)
    local book = player ~= nil and player._eva_skillbook_entity or nil
    if (book == nil or not book:IsValid()) and player ~= nil
        and player._eva_skillbook ~= nil then
        book = player._eva_skillbook:value()
    end
    return book ~= nil and book:IsValid() and book or nil
end

local function IsBoundBook(book, player)
    return IsEva(player)
        and book ~= nil
        and book:IsValid()
        and GetBoundBook(player) == book
        and book.GetEvaOwner ~= nil
        and book:GetEvaOwner() == player
end

local function CallComponent(player, book, skill, method, ...)
    if not Progression.Check(player, skill) then return false, "level_locked" end
    local components = player.components or {}
    local component = components[COMPONENTS[skill] or ""]
    if component == nil or component[method] == nil then
        return false, "missing_component"
    end

    local previous_context = player._eva_skill_cast_context
    local previous_book = player._eva_skill_cast_book
    player._eva_skill_cast_context = skill
    player._eva_skill_cast_book = book
    local ok, result, reason = pcall(component[method], component, ...)
    player._eva_skill_cast_context = previous_context
    player._eva_skill_cast_book = previous_book
    if not ok then
        print("[EVA] skill route failed: " .. tostring(result))
        return false, "component_error"
    end
    return result, reason
end

function Panel.GetBoundBook(player)
    return GetBoundBook(player)
end

function Panel.IsBoundBook(book, player)
    return IsBoundBook(book, player)
end

function Panel.CanUsePanel(player, frontend)
    if not IsEva(player) then return false end
    if frontend == nil or frontend:IsControlsDisabled() then return false end
    local screen = frontend:GetActiveScreen()
    if screen == nil or screen.name ~= "HUD" then return false end
    return player.HUD == nil or not player.HUD:HasInputFocus()
end

function Panel.GetCooldownSeconds(player, skill)
    if TheWorld ~= nil and TheWorld.ismastersim and player ~= nil then
        local component_name = COMPONENTS[skill]
        local component = component_name ~= nil and player.components ~= nil
            and player.components[component_name] or nil
        if component ~= nil and component.GetCooldownRemaining ~= nil then
            return math.ceil(component:GetCooldownRemaining())
        end
    end
    local definition = Panel.SKILLS[skill]
    local netvar = definition ~= nil and definition.cooldown_net ~= nil
        and player ~= nil and player[definition.cooldown_net] or nil
    return netvar ~= nil and netvar:value() or 0
end

function Panel.GetFoxCooldownSeconds(player)
    local component = player ~= nil and player.components ~= nil
        and player.components.eva_fox_blink or nil
    if TheWorld ~= nil and TheWorld.ismastersim and component ~= nil
        and component.GetCooldownRemaining ~= nil then
        return math.ceil(component:GetCooldownRemaining())
    end
    local netvar = player ~= nil and player._eva_skill_cd_fox or nil
    return netvar ~= nil and netvar:value() or 0
end

function Panel.GetWingsActive(player)
    return player ~= nil
        and player._eva_wings_active ~= nil
        and player._eva_wings_active:value() == true
end

function Panel.ActivateSkill(player, frontend, skill)
    if not Panel.CanUsePanel(player, frontend) then return false, "invalid_state" end
    if not Panel.IsSkillUnlocked(player, skill) then return false, "level_locked" end
    if skill ~= "wings" and Panel.GetCooldownSeconds(player, skill) > 0 then
        return false, "cooldown"
    end

    local index = Panel.SPELL_INDEX[skill]
    local book = GetBoundBook(player)
    local spellbook = book ~= nil and book.components ~= nil
        and book.components.spellbook or nil
    if index == nil or spellbook == nil or not IsBoundBook(book, player) then
        return false, "missing_book"
    end
    if not spellbook:SelectSpell(index) then return false, "selection_failed" end

    local item = spellbook.items ~= nil and spellbook.items[index] or nil
    if item == nil or item.execute == nil then return false, "missing_spell" end
    item.execute(book)
    return true
end

function Panel.HandleImmediate(player, skill)
    if skill ~= "life" and skill ~= "wings" then
        return false, "invalid_skill"
    end
    local book = GetBoundBook(player)
    if not IsBoundBook(book, player) then return false, "not_owner" end
    local now = GetTime()
    if player._eva_skillpanel_last_rpc ~= nil
        and now - player._eva_skillpanel_last_rpc < RPC_INTERVAL then
        return false, "rate_limited"
    end
    player._eva_skillpanel_last_rpc = now
    return CallComponent(player, nil, skill,
        skill == "life" and "Activate" or "Toggle")
end

function Panel.RequestImmediate(skill)
    if client_send_immediate == nil then return false end
    client_send_immediate(Panel.NAMESPACE, Panel.RPC_NAME, skill)
    return true
end

function Panel.HandleFox(player, x, z)
    if not IsEva(player) or not IsFiniteNumber(x) or not IsFiniteNumber(z) then
        return false, "invalid_state"
    end
    local controller = player.components ~= nil and player.components.playercontroller or nil
    if BufferedAction == nil or Vector3 == nil or ACTIONS == nil
        or ACTIONS.EVA_FOX_BLINK == nil or controller == nil
        or controller.DoAction == nil or controller.IsBusy == nil then
        return false, "missing_action"
    end
    if controller:IsBusy() then return false, "busy" end
    local now = GetTime()
    if player._eva_skillpanel_last_fox_rpc ~= nil
        and now - player._eva_skillpanel_last_fox_rpc < RPC_INTERVAL then
        return false, "rate_limited"
    end
    player._eva_skillpanel_last_fox_rpc = now
    controller:DoAction(BufferedAction(
        player, nil, ACTIONS.EVA_FOX_BLINK, nil, Vector3(x, 0, z)))
    return true, "queued"
end

function Panel.RequestFox(x, z)
    if client_send_fox == nil or not IsFiniteNumber(x) or not IsFiniteNumber(z) then
        return false
    end
    client_send_fox(Panel.NAMESPACE, Panel.FOX_RPC_NAME, x, z)
    return true
end

function Panel.CastAt(book, player, skill, x, z)
    if not POINT_SKILLS[skill] then return false, "invalid_skill" end
    if not IsBoundBook(book, player) then return false, "not_owner" end
    if book._eva_selected_skill ~= skill then return false, "wrong_selection" end
    return CallComponent(player, book, skill, "CastAt", x, z)
end

function Panel.CanEnterNativeCast(player, action)
    local book = action ~= nil and action.invobject or nil
    local selected = book ~= nil and book._eva_selected_skill or nil
    return action ~= nil
        and ACTIONS ~= nil
        and action.action == ACTIONS.CASTAOE
        and POINT_SKILLS[selected] == true
        and Progression.IsUnlocked(player, selected)
        and IsBoundBook(book, player)
end

function Panel.IsAuthorizedNativeCast(player)
    if player == nil or player.sg == nil
        or player.sg.currentstate == nil
        or player.sg.currentstate.name ~= "eva_skill_cast" then
        return false
    end
    local action = player.GetBufferedAction ~= nil and player:GetBufferedAction() or nil
    if action == nil then return false end
    local context = player._eva_skill_cast_context
    if POINT_SKILLS[context] then
        local book = player._eva_skill_cast_book
        return book ~= nil
            and action.invobject == book
            and book._eva_selected_skill == context
            and Panel.CanEnterNativeCast(player, action)
    elseif context == "fox" then
        return player._eva_skill_cast_book == nil
            and ACTIONS.EVA_FOX_BLINK ~= nil
            and action.action == ACTIONS.EVA_FOX_BLINK
    end
    return false
end

local function SetNetByte(netvar, value)
    if netvar ~= nil then
        netvar:set(math.max(0, math.min(255, math.ceil(value or 0))))
    end
end

function Panel.UpdateReplicaState(player)
    local components = player.components or {}
    SetNetByte(player._eva_skill_cd_life,
        components.eva_life ~= nil and components.eva_life:GetCooldownRemaining() or 0)
    SetNetByte(player._eva_skill_cd_array,
        components.eva_scythe_array ~= nil and components.eva_scythe_array:GetCooldownRemaining() or 0)
    SetNetByte(player._eva_skill_cd_harvest,
        components.eva_harvest ~= nil and components.eva_harvest:GetCooldownRemaining() or 0)
    SetNetByte(player._eva_skill_cd_daydu,
        components.eva_daydu ~= nil and components.eva_daydu:GetCooldownRemaining() or 0)
    SetNetByte(player._eva_skill_cd_fox,
        components.eva_fox_blink ~= nil and components.eva_fox_blink:GetCooldownRemaining() or 0)
end

function Panel.InstallReplication(player)
    if player._eva_skillpanel_replication_task ~= nil then return end
    Panel.UpdateReplicaState(player)
    player._eva_skillpanel_replication_task = player:DoPeriodicTask(0.25, function()
        Panel.UpdateReplicaState(player)
    end)
end

function Panel.Install(deps)
    deps.add_rpc(Panel.NAMESPACE, Panel.RPC_NAME, function(player, skill)
        return Panel.HandleImmediate(player, skill)
    end)
    deps.add_rpc(Panel.NAMESPACE, Panel.FOX_RPC_NAME, function(player, x, z)
        return Panel.HandleFox(player, x, z)
    end)
    client_send_immediate = deps.send_rpc
    client_send_fox = deps.send_rpc

    if deps.add_key_handler ~= nil and deps.keys ~= nil then
        for index, skill in ipairs(Panel.HOTKEY_ORDER) do
            local selected_skill = skill
            local key = deps.keys[index]
            if key ~= nil then
                deps.add_key_handler(key, function()
                    return Panel.ActivateSkill(
                        deps.get_player ~= nil and deps.get_player() or nil,
                        deps.get_frontend ~= nil and deps.get_frontend() or nil,
                        selected_skill)
                end)
            end
        end
    end

    if deps.add_key_handler ~= nil and deps.fox_key ~= nil
        and deps.fox_key ~= 0 then
        deps.add_key_handler(deps.fox_key, function()
            local player = deps.get_player ~= nil and deps.get_player() or nil
            local frontend = deps.get_frontend ~= nil and deps.get_frontend() or nil
            local position = deps.get_world_position ~= nil
                and deps.get_world_position() or nil
            if not Panel.CanUseFoxShortcut(player, frontend, position) then
                return false
            end
            return Panel.RequestFox(position.x, position.z)
        end)
    end
end

function Panel.CanUseFoxShortcut(player, frontend, position)
    if not IsEva(player) or not Panel.CanUsePanel(player, frontend) then return false end
    local controller = player.components ~= nil and player.components.playercontroller or nil
    if controller == nil or controller:IsAOETargeting()
        or controller.placer ~= nil or controller.deployplacer ~= nil then
        return false
    end
    local inventory = player.replica ~= nil and player.replica.inventory or nil
    if inventory == nil or inventory:GetActiveItem() ~= nil then return false end
    local rider = player.replica.rider
    if rider ~= nil and rider:IsRiding() then return false end
    if Panel.GetFoxCooldownSeconds(player) > 0 then return false end
    if position == nil or type(position.x) ~= "number" or type(position.z) ~= "number" then
        return false
    end
    return true
end

function Panel.CastFoxAction(action)
    local player = action ~= nil and action.doer or nil
    local point = action ~= nil and action:GetActionPoint() or nil
    if not IsEva(player) or point == nil then return false, "invalid_state" end
    return CallComponent(player, nil, "fox", "CastAt", point.x, point.z)
end

return Panel
