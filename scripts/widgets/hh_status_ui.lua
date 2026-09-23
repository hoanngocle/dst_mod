local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"
local QuestDefs = require "quests/hh_daily_quest_defs"
local GuildQuestDefs = require "guild/hh_guild_quest_defs"
local RankDefs = require "guild/hh_rank_defs"
local ExamDefs = require "guild/hh_rank_exam_defs"
local HHGuideLock = require "utils/hh_guide_lock"
local HHSummaryLock = require "utils/hh_summary_lock"
local Theme = require "widgets/hh_ui/ttk_unified_theme"
local UIFONT = Theme.GetFont()
local TITLEFONT = Theme.GetFont()

-- Scale chung cho background và toàn bộ widget trong hệ tọa độ artwork 1536x1024.
local HUD_SCALE = 0.55
local PLUS_BUTTON_AAA_X = -56
local PLUS_BUTTON_AAA_Y = -15
local PLUS_BUTTON_AAA_SCALE = 1.1
local PLUS_BUTTON_TEXT_X = -63
local PLUS_BUTTON_TEXT_Y = -5
local PLUS_BUTTON_TEXT_SIZE = 80
local CLOSE_BUTTON_AAA_X = 10
local CLOSE_BUTTON_AAA_Y = 960
local CLOSE_BUTTON_AAA_SCALE = 1.3
local CLOSE_BUTTON_TEXT_X = 3
local CLOSE_BUTTON_TEXT_Y = 965
local CLOSE_BUTTON_TEXT_SIZE = 80

local SHADOW_UPGRADE_BUTTON_AAA_SCALE_X = 3.2
local SHADOW_UPGRADE_BUTTON_AAA_SCALE_Y = 1.15
local SHADOW_UPGRADE_BUTTON_AAA_IMAGE_X = 5
local SHADOW_UPGRADE_BUTTON_AAA_IMAGE_Y = -8
local SHADOW_UPGRADE_BUTTON_AAA_IMAGE_SCALE_X = 0.9
local SHADOW_UPGRADE_BUTTON_AAA_IMAGE_SCALE_Y = 0.7

local function HSVToRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    elseif i == 5 then return v, p, q
    end
end

local HHStatusUI = Class(Screen, function(self, owner, on_close, options)
    Screen._ctor(self, "HHStatusUI")
    options = options or {}
    self.owner = owner
    self.on_close = on_close
    self.embedded = options.embedded == true
    self.content_mode = options.content_mode or "character"
    self.select_tab = options.select_tab

    self.root = self:AddChild(Widget("root"))
    self.root:SetPosition(0, 0, 0)
    if not self.embedded then
        self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.root:SetHAnchor(ANCHOR_MIDDLE)
        self.root:SetVAnchor(ANCHOR_MIDDLE)
    end

    -- Mọi widget dùng chung hệ tọa độ artwork 1536x1024.
    self.panel = self.root:AddChild(Widget("status_panel"))
    self.panel:SetScale(self.embedded and 1 or HUD_SCALE, self.embedded and 1 or HUD_SCALE, 1)

    if self.embedded then
        self.bg = self.panel:AddChild(Image("images/ttk_forge/frame.xml", "frame.tex"))
        self.bg:SetSize(1280, 680)
        self.bg:SetTint(unpack(Theme.colours.panel))
    else
        self.bg = self.panel:AddChild(Image("images/hh_icon/hud_status.xml", "hud_status.tex"))
    end

    -- Title
    self.title = self.panel:AddChild(Text(TITLEFONT, 54))
    self.title:SetPosition(0, 330, 0)
    self.title:SetString(STRINGS.HH_LEVELING.TITLE)
    
    self.inst:DoPeriodicTask(0, function()
        if self.embedded then return end
        local hue = (GetTime() * 0.2) % 1
        local r, g, b = HSVToRGB(hue, 1, 1)
        self.title:SetColour(r, g, b, 1)
    end)

    -- Close Button
    self.close_btn = self.panel:AddChild(ImageButton(
        "images/frontend.xml",
        "button_square.tex",
        "button_square_halfshadow.tex",
        "button_square_disabled.tex",
        "button_square_halfshadow.tex",
        "button_square_disabled.tex",
        { CLOSE_BUTTON_AAA_SCALE, CLOSE_BUTTON_AAA_SCALE },
        { 0, 0 }
    ))
    self.close_btn:SetPosition(630, -338, 0)
    self.close_btn:SetScale(0.7)
    self.close_btn:SetText("X")
    self.close_btn:SetTextSize(CLOSE_BUTTON_TEXT_SIZE)
    self.close_btn.text:SetPosition(CLOSE_BUTTON_TEXT_X, CLOSE_BUTTON_TEXT_Y, 0)
    self.close_btn.image:SetPosition(CLOSE_BUTTON_AAA_X, CLOSE_BUTTON_AAA_Y, 0)
    self.close_btn.normal_scale = { CLOSE_BUTTON_AAA_SCALE, CLOSE_BUTTON_AAA_SCALE, 1 }
    self.close_btn.focus_scale = { CLOSE_BUTTON_AAA_SCALE * 1.2, CLOSE_BUTTON_AAA_SCALE * 1.2, 1 }
    self.close_btn.image:SetScale(CLOSE_BUTTON_AAA_SCALE, CLOSE_BUTTON_AAA_SCALE, 1)
    self.close_btn:SetOnClick(function()
        if self.embedded then
            if options.close ~= nil then options.close() end
        else
            TheFrontEnd:PopScreen(self)
        end
    end)
    if self.embedded then self.close_btn:Hide() end

    -- Basic Info
    self.level_text = self.panel:AddChild(Text(UIFONT, 30))
    self.level_text:SetPosition(-610, 330, 0)

    self.current_rank_text = self.panel:AddChild(Text(UIFONT, 30, ""))
    self.current_rank_text:SetPosition(-500, 330, 0)
    
    self.exp_text = self.panel:AddChild(Text(UIFONT, 30))
    self.exp_text:SetPosition(-350, 330, 0)

    self.ap_text = self.panel:AddChild(Text(UIFONT, 40))
    self.ap_text:SetPosition(-510, 243, 0)
    self.ap_text:SetColour(1, 1, 0, 1)

    self.quest_panel = self.panel:AddChild(Widget("quest_panel"))
    self.rank_exam_header = self.quest_panel:AddChild(Text(TITLEFONT, 45, "NHIỆM VỤ RANK"))
    self.rank_exam_header:SetPosition(185, 0, 0)
    self.rank_exam_header:SetColour(0.85, 0.35, 1, 1)

    self.rank_exam_text = self.quest_panel:AddChild(Text(UIFONT, 35, ""))
    self.rank_exam_text:SetPosition(360, -55, 0)
    self.rank_exam_text:SetRegionSize(540, 100)
    self.rank_exam_text:EnableWordWrap(true)

    -- Stats Container
    self.stats = {}
    local start_y = 160
    local spacing = -113

    self:CreateStatRow("str", STRINGS.HH_LEVELING.STR, STRINGS.HH_LEVELING.STR_DESC, TUNING.HH_LEVELING.STR_GAIN, start_y)
    self:CreateStatRow("agi", STRINGS.HH_LEVELING.AGI, STRINGS.HH_LEVELING.AGI_DESC, TUNING.HH_LEVELING.AGI_GAIN, start_y + spacing)
    self:CreateStatRow("vit", STRINGS.HH_LEVELING.VIT, STRINGS.HH_LEVELING.VIT_DESC, TUNING.HH_LEVELING.VIT_GAIN, start_y + spacing * 2)
    self:CreateStatRow("sen", STRINGS.HH_LEVELING.SEN, STRINGS.HH_LEVELING.SEN_DESC, TUNING.HH_LEVELING.SEN_CRIT_RATE, TUNING.HH_LEVELING.SEN_CRIT_DMG, start_y + spacing * 3)
    self:CreateStatRow("int", STRINGS.HH_LEVELING.INT, STRINGS.HH_LEVELING.INT_DESC, TUNING.HH_LEVELING.INT_CD_REDUCE, TUNING.HH_LEVELING.INT_SHADOW_REDUCE, start_y + spacing * 4)

    -- Daily quest column
    self.quest_header = self.quest_panel:AddChild(Text(TITLEFONT, 45))
    self.quest_header:SetPosition(360, 230, 0)
    self.quest_header:SetString(STRINGS.HH_DAILY_QUEST.TITLE)
    self.quest_header:SetColour(0.3, 0.75, 1, 1)

    self.quest_desc = self.quest_panel:AddChild(Text(UIFONT, 35))
    self.quest_desc:SetPosition(360, 180, 0)
    self.quest_desc:SetRegionSize(540, 105)
    self.quest_desc:EnableWordWrap(true)

    self.quest_remaining = self.quest_panel:AddChild(Text(UIFONT, 35))
    self.quest_remaining:SetPosition(360, 120, 0)

    self.quest_reward = self.quest_panel:AddChild(Text(UIFONT, 35))
    self.quest_reward:SetPosition(360, 90, 0)
    self.quest_reward:SetColour(1, 0.85, 0.2, 1)

    self.exp_seal = self.quest_panel:AddChild(Text(UIFONT, 35))
    self.exp_seal:SetPosition(360, 90, 0)
    self.exp_seal:SetColour(1, 0.35, 0.2, 1)
    self.exp_seal:Hide()

    self.quest_failure = self.quest_panel:AddChild(Text(UIFONT, 35))
    self.quest_failure:SetPosition(360, 120, 0)
    self.quest_failure:SetRegionSize(520, 65)
    self.quest_failure:EnableWordWrap(true)
    self.quest_failure:SetColour(1, 0.25, 0.25, 1)

    self.guild_quest_header = self.quest_panel:AddChild(Text(TITLEFONT, 45, "GUILD QUEST"))
    self.guild_quest_header:SetPosition(360, -160, 0)
    self.guild_quest_header:SetColour(1, 0.5, 0, 1)

    self.guild_quest_desc = self.quest_panel:AddChild(Text(UIFONT, 35, ""))
    self.guild_quest_desc:SetPosition(360, -265, 0)
    self.guild_quest_desc:SetRegionSize(540, 190)
    self.guild_quest_desc:EnableWordWrap(true)

    self.shadow_upgrade_btn = self.panel:AddChild(ImageButton())
    self.shadow_upgrade_btn:SetPosition(420, 340, 0)
    self.shadow_upgrade_btn:SetScale(1.05)
    self.shadow_upgrade_btn:SetText("Nâng cấp Quân Đoàn")
    self.shadow_upgrade_btn.normal_scale = { SHADOW_UPGRADE_BUTTON_AAA_SCALE_X, SHADOW_UPGRADE_BUTTON_AAA_SCALE_Y, 1 }
    self.shadow_upgrade_btn.focus_scale = { SHADOW_UPGRADE_BUTTON_AAA_SCALE_X * 1.2, SHADOW_UPGRADE_BUTTON_AAA_SCALE_Y * 1.2, 1 }
    self.shadow_upgrade_btn.image:SetPosition(SHADOW_UPGRADE_BUTTON_AAA_IMAGE_X, SHADOW_UPGRADE_BUTTON_AAA_IMAGE_Y, 0)
    self.shadow_upgrade_btn.image:SetScale(SHADOW_UPGRADE_BUTTON_AAA_IMAGE_SCALE_X, SHADOW_UPGRADE_BUTTON_AAA_IMAGE_SCALE_Y, 1)
    self.shadow_upgrade_btn:SetOnClick(function()
        if self.embedded and self.select_tab ~= nil then
            self.select_tab("army")
            return
        end
        if HHGuideLock.IsOpen(self.owner) or HHSummaryLock.IsOpen(self.owner) then
            return
        end
        local HHShadowUpgradeScreen = require("screens/hh_shadow_upgrade_screen")
        local owner = self.owner
        TheFrontEnd:PopScreen(self)
        TheFrontEnd:PushScreen(HHShadowUpgradeScreen(owner))
    end)

    self.progression_btn = self.panel:AddChild(require("widgets/textbutton")())
    self.progression_btn:SetPosition(345, -355)
    self.progression_btn:SetText("Thành tựu · Mùa · Đặc quyền")
    self.progression_btn:SetTextSize(28)
    self.progression_btn:SetOnClick(function()
        if TheNet:IsDedicated() or HHGuideLock.IsOpen(self.owner) or HHSummaryLock.IsOpen(self.owner) then return end
        local ProgressionScreen = require("screens/ttk_progression_screen")
        local owner = self.owner
        TheFrontEnd:PopScreen(self)
        TheFrontEnd:PushScreen(ProgressionScreen(owner))
    end)

    self.portrait_picker = self.panel:AddChild(require("widgets/ttk_eva_portrait_picker")())
    self.portrait_picker:SetPosition(345, -20)
    self.quest_panel:Hide()
    self.portrait_toggle = self.panel:AddChild(require("widgets/textbutton")())
    self.portrait_toggle:SetPosition(100, 340)
    self.portrait_toggle:SetText("Nhiệm vụ")
    self.portrait_toggle:SetTextSize(26)
    self.portrait_toggle:SetOnClick(function()
        if self.embedded and self.select_tab ~= nil then
            self.select_tab("quests")
            return
        end
        self.showing_quests = not self.showing_quests
        if self.showing_quests then
            self.portrait_picker:Hide()
            self.quest_panel:Show()
            self.portrait_toggle:SetText("Ảnh EVA")
        else
            self.quest_panel:Hide()
            self.portrait_picker:Show()
            self.portrait_toggle:SetText("Nhiệm vụ")
        end
    end)

    -- Listeners
    self.inst:ListenForEvent("hh_lv_leveldirty", function() self:Refresh() end, self.owner)
    self.inst:ListenForEvent("hh_lv_expdirty", function() self:Refresh() end, self.owner)
    self.inst:ListenForEvent("hh_lv_apdirty", function() self:Refresh() end, self.owner)
    self.inst:ListenForEvent("hh_lv_strdirty", function() self:Refresh() end, self.owner)
    self.inst:ListenForEvent("hh_lv_agidirty", function() self:Refresh() end, self.owner)
    self.inst:ListenForEvent("hh_lv_vitdirty", function() self:Refresh() end, self.owner)
    self.inst:ListenForEvent("hh_lv_sendirty", function() self:Refresh() end, self.owner)
    self.inst:ListenForEvent("hh_lv_intdirty", function() self:Refresh() end, self.owner)
    local quest_dirty_events = {
        'hh_quest_iddirty', 'hh_quest_progressdirty', 'hh_quest_targetdirty',
        'hh_quest_rewarddirty', 'hh_quest_statusdirty', 'hh_quest_deadlinedirty',
        'hh_quest_failuredirty', 'hh_exp_seal_deadlinedirty',
    }
    for _, event in ipairs(quest_dirty_events) do
        self.inst:ListenForEvent(event, function() self:RefreshQuest() end, self.owner)
    end
    local guild_quest_dirty_events = {
        "hh_guild_questdirty", "hh_guild_rankdirty", "hh_guild_creditdirty", "hh_guild_examdirty",
    }
    for _, event in ipairs(guild_quest_dirty_events) do
        self.inst:ListenForEvent(event, function()
            self:Refresh()
            self:RefreshGuildQuest()
            self:RefreshRankExam()
        end, self.owner)
    end
    self.inst:DoPeriodicTask(1, function()
        if self.shown then
            self:RefreshQuest()
            self:RefreshGuildQuest()
            self:RefreshRankExam()
        end
    end)
    if self.embedded and self.content_mode == "character" then
        self.quest_panel:Hide()
        self.portrait_picker:Show()
    elseif self.embedded and self.content_mode == "quests" then
        for _, row in pairs(self.stats) do row:Hide() end
        self.portrait_picker:Hide()
        self.portrait_toggle:Hide()
        self.shadow_upgrade_btn:Hide()
        self.quest_panel:Show()
    end

    self:Refresh()
    self:RefreshQuest()
    self:RefreshGuildQuest()
    self:RefreshRankExam()
end)

function HHStatusUI:SetQuestFocus()
    self.quest_panel:Show()
    self:RefreshQuest()
    self:RefreshGuildQuest()
    self:RefreshRankExam()
end

function HHStatusUI:ShowPanel()
    self:Show()
    self:Refresh()
    if self.content_mode == "quests" then self:SetQuestFocus("daily") end
end

function HHStatusUI:HidePanel()
    self:Hide()
end

function HHStatusUI:DisposePanel()
    self:Kill()
end

function HHStatusUI:CreateStatRow(key, name, desc_format, val1, val2, y)
    if not y then 
        y = val2 
        val2 = nil
    end

    local row = self.panel:AddChild(Widget(key))
    row:SetPosition(-320, y, 0)

    row.label = row:AddChild(Text(UIFONT, 45))
    row.label:SetPosition(-190, 24, 0)
    row.label:SetHAlign(ANCHOR_LEFT)

    row.desc = row:AddChild(Text(UIFONT, 35))
    row.desc:SetPosition(-100, -10, 0)
    row.desc:SetRegionSize(430, 38)
    row.desc:SetHAlign(ANCHOR_LEFT)
    row.desc:SetColour(0.7, 0.7, 0.7, 1)
    if val2 then
        row.desc:SetString(string.format(desc_format, val1, val2))
    else
        row.desc:SetString(string.format(desc_format, val1))
    end
    if key == "int" then
        row.mana_desc = row:AddChild(Text(UIFONT, 35))
        row.mana_desc:SetPosition(-117, -47, 0)
        row.mana_desc:SetHAlign(ANCHOR_LEFT)
        row.mana_desc:SetString("+20 Mana tối đa / +0.15 Mana mỗi giây")
        row.mana_desc:SetColour(0.7, 0.7, 0.7, 1)
    end

    row.btn = row:AddChild(ImageButton(
        "images/frontend.xml",
        "button_square.tex",
        "button_square_halfshadow.tex",
        "button_square_disabled.tex",
        "button_square_halfshadow.tex",
        "button_square_disabled.tex",
        { PLUS_BUTTON_AAA_SCALE, PLUS_BUTTON_AAA_SCALE },
        { 0, 0 }
    ))
    row.btn:SetPosition(255, 0, 0)
    row.btn:SetScale(0.6)
    row.btn:SetText("+")
    row.btn:SetTextSize(PLUS_BUTTON_TEXT_SIZE)
    row.btn.text:SetPosition(PLUS_BUTTON_TEXT_X, PLUS_BUTTON_TEXT_Y, 0)
    row.btn.image:SetPosition(PLUS_BUTTON_AAA_X, PLUS_BUTTON_AAA_Y, 0)
    row.btn.normal_scale = { PLUS_BUTTON_AAA_SCALE, PLUS_BUTTON_AAA_SCALE, 1 }
    row.btn.focus_scale = { PLUS_BUTTON_AAA_SCALE * 1.2, PLUS_BUTTON_AAA_SCALE * 1.2, 1 }
    row.btn.image:SetScale(PLUS_BUTTON_AAA_SCALE, PLUS_BUTTON_AAA_SCALE, 1)
    row.btn:SetOnClick(function()
        SendModRPCToServer(GetModRPC("hh_rpc", "hh_pick_stat"), key)
    end)

    self.stats[key] = row
end

function HHStatusUI:Refresh()
    if not self.owner then return end

    local lv = self.owner.hh_lv_level and self.owner.hh_lv_level:value() or 1
    local exp = self.owner.hh_lv_exp and self.owner.hh_lv_exp:value() or 0
    local exp_goal = self.owner.hh_lv_exp_goal and self.owner.hh_lv_exp_goal:value() or 100
    local ap = self.owner.hh_lv_ap and self.owner.hh_lv_ap:value() or 0
    local rank = self.owner.hh_guild_rank and self.owner.hh_guild_rank:value() or RankDefs.RANK.E

    self.level_text:SetString(STRINGS.HH_LEVELING.LEVEL .. ": " .. tostring(lv))
    self.current_rank_text:SetString("Rank: " .. RankDefs.GetName(rank))
    self.exp_text:SetString("EXP " .. tostring(exp) .. " / " .. tostring(exp_goal))
    
    self.ap_text:SetString("Điểm Tiềm Năng: " .. tostring(ap))
    self.ap_text:Show()

    local stat_vals = {
        str = self.owner.hh_lv_str and self.owner.hh_lv_str:value() or 0,
        agi = self.owner.hh_lv_agi and self.owner.hh_lv_agi:value() or 0,
        vit = self.owner.hh_lv_vit and self.owner.hh_lv_vit:value() or 0,
        sen = self.owner.hh_lv_sen and self.owner.hh_lv_sen:value() or 0,
        int = self.owner.hh_lv_int and self.owner.hh_lv_int:value() or 0,
    }

    for k, row in pairs(self.stats) do
        local cap = TUNING.HH_LEVELING.STAT_CAPS and TUNING.HH_LEVELING.STAT_CAPS[string.upper(k)]
        local suffix = cap and (" / " .. tostring(cap)) or ""
        row.label:SetString(STRINGS.HH_LEVELING[string.upper(k)] .. ": " .. tostring(stat_vals[k]) .. suffix)
        if ap > 0 and (not cap or stat_vals[k] < cap) then
            row.btn:Show()
        else
            row.btn:Hide()
        end
    end
end

local function GetClientWorldSeconds()
    local cycles = TheWorld and TheWorld.state and TheWorld.state.cycles or 0
    local time = TheWorld and TheWorld.state and TheWorld.state.time or 0
    return math.floor((cycles + time) * TUNING.TOTAL_DAY_TIME)
end

local function FormatRemaining(seconds)
    seconds = math.max(0, math.floor(seconds))
    local days = math.floor(seconds / TUNING.TOTAL_DAY_TIME)
    local rest = seconds - days * TUNING.TOTAL_DAY_TIME
    local minutes = math.floor(rest / 60)
    local secs = rest % 60
    return string.format('%d ngày %d phút %d giây', days, minutes, secs)
end

local function FormatDeliveryRequirements(requirements)
    local names = STRINGS and STRINGS.NAMES
    local items = {}
    for _, requirement in ipairs(requirements or {}) do
        local prefab = requirement.prefab
        local name = prefab and names and names[string.upper(prefab)] or prefab or "?"
        table.insert(items, name .. " x" .. tostring(requirement.amount or 1))
    end
    return table.concat(items, ", ")
end

function HHStatusUI:RefreshQuest()
    if not self.owner or not self.quest_desc then return end
    local id = self.owner.hh_quest_id and self.owner.hh_quest_id:value() or 0
    local progress = self.owner.hh_quest_progress and self.owner.hh_quest_progress:value() or 0
    local target = self.owner.hh_quest_target and self.owner.hh_quest_target:value() or 0
    local reward = self.owner.hh_quest_reward and self.owner.hh_quest_reward:value() or 0
    local status = self.owner.hh_quest_status and self.owner.hh_quest_status:value() or 0
    local deadline = self.owner.hh_quest_deadline and self.owner.hh_quest_deadline:value() or 0
    local failure = self.owner.hh_quest_failure and self.owner.hh_quest_failure:value() or ''
    local quest = QuestDefs.Get(id)
    local strings = STRINGS.HH_DAILY_QUEST
    local now = GetClientWorldSeconds()
    local exp_seal_deadline = self.owner.hh_exp_seal_deadline and self.owner.hh_exp_seal_deadline:value() or 0
    local exp_seal_remaining = math.max(0, math.ceil(exp_seal_deadline - now))

    if exp_seal_remaining > 0 then
        self.exp_seal:SetString(string.format(strings.EXP_SEAL, exp_seal_remaining))
        self.exp_seal:Show()
    else
        self.exp_seal:Hide()
    end

    self.quest_desc:SetString(quest
        and string.format('%s: %s (%d/%d)', quest.title, quest.description, progress, target)
        or strings.STATUS[0])
    if status == 1 and quest then
        self.quest_reward:SetString(string.format('%s: %d EXP', strings.REWARD, reward))
        self.quest_reward:Show()
    else
        self.quest_reward:Hide()
    end
    if quest then
        self.quest_remaining:SetString(strings.REMAINING .. ': ' .. FormatRemaining(deadline - now))
    else
        self.quest_remaining:Hide()
    end

    if status == 3 then
        self.quest_desc:SetColour(1, 0.2, 0.2, 1)
        self.quest_failure:SetString(strings.FAILURE[failure] or failure)
        self.quest_remaining:Hide()
        self.quest_failure:Show()
    elseif status == 2 then
        self.quest_desc:SetColour(0.2, 1, 0.3, 1)
        self.quest_remaining:Hide()
        self.quest_failure:Hide()
    else
        self.quest_desc:SetColour(0.9, 0.9, 0.9, 1)
        if quest then
            self.quest_remaining:Show()
        else
            self.quest_remaining:Hide()
        end
        self.quest_failure:Hide()
    end
end

function HHStatusUI:RefreshGuildQuest()
    if not self.owner or not self.guild_quest_desc then
        return
    end

    local id = self.owner.hh_guild_quest_id and self.owner.hh_guild_quest_id:value() or 0
    local progress = self.owner.hh_guild_quest_progress and self.owner.hh_guild_quest_progress:value() or 0
    local target = self.owner.hh_guild_quest_target and self.owner.hh_guild_quest_target:value() or 0
    local reward = self.owner.hh_guild_quest_reward and self.owner.hh_guild_quest_reward:value() or 0
    local status = self.owner.hh_guild_quest_status and self.owner.hh_guild_quest_status:value() or 0
    local remaining = self.owner.hh_guild_quest_remaining and self.owner.hh_guild_quest_remaining:value() or 0
    local cooldown = self.owner.hh_guild_quest_cooldown and self.owner.hh_guild_quest_cooldown:value() or 0
    local failure = self.owner.hh_guild_quest_failure and self.owner.hh_guild_quest_failure:value() or ""
    local quest = GuildQuestDefs.Get(id)

    if status == 1 and quest then
        local text = string.format("%s\n%s\nTiến độ: %d/%d | Còn lại: %s\nThưởng: %d Xu",
            quest.title, quest.description, progress, target, FormatRemaining(remaining), reward)
        if quest.requirements and #quest.requirements > 0 then
            text = text
                .. "\nVật phẩm cần giao: " .. FormatDeliveryRequirements(quest.requirements)
                .. "\nGiao tại: Nhân Viên Hiệp Hội"
        end
        self.guild_quest_desc:SetString(text)
        self.guild_quest_desc:SetColour(0.9, 0.9, 0.9, 1)
    elseif cooldown > 0 then
        self.guild_quest_desc:SetString(failure == "reward_cooldown"
            and ("Hiện tại chưa có nhiệm vụ nào ! Thợ săn hãy dành thời gian này để nghỉ ngơi\nNhiệm vụ mới sau: " .. FormatRemaining(cooldown))
            or ("Guild Quest đang bị khóa sau khi hủy.\nCó thể nhận lại sau: " .. FormatRemaining(cooldown)))
        self.guild_quest_desc:SetColour(1, 0.75, 0.25, 1)
    elseif status == 2 and quest then
        self.guild_quest_desc:SetString(quest.title .. "\nĐÃ HOÀN THÀNH - thưởng đã cộng Xu Hiệp Hội.")
        self.guild_quest_desc:SetColour(0.2, 1, 0.3, 1)
    elseif status == 3 and quest then
        self.guild_quest_desc:SetString(quest.title .. "\nGuild Quest đã thất bại.")
        self.guild_quest_desc:SetColour(1, 0.25, 0.25, 1)
    else
        self.guild_quest_desc:SetString("Chưa nhận Guild Quest.")
        self.guild_quest_desc:SetColour(0.75, 0.75, 0.75, 1)
    end
end

function HHStatusUI:RefreshRankExam()
    if not self.owner or not self.rank_exam_text then
        return
    end
    local rank = self.owner.hh_guild_rank and self.owner.hh_guild_rank:value() or 1
    local exam_id = self.owner.hh_guild_exam_id and self.owner.hh_guild_exam_id:value() or 0
    local status = self.owner.hh_guild_exam_status and self.owner.hh_guild_exam_status:value() or 0
    local progress = self.owner.hh_guild_exam_progress and self.owner.hh_guild_exam_progress:value() or 0
    local target = self.owner.hh_guild_exam_target and self.owner.hh_guild_exam_target:value() or 0
    local exam = ExamDefs.Get(exam_id)
    local text = ""
    local quest_text = exam and (exam.description .. "\n") or ""
    if exam and status == 1 then
        text = quest_text .. "Rank " .. RankDefs.GetName(rank) .. " | Đã đủ điều kiện nhận " .. exam.title .. " tại Nhân Viên Hiệp Hội"
    elseif exam and status == 2 then
        text = quest_text .. string.format("Rank %s | %s: %d/%d", RankDefs.GetName(rank), exam.title, progress, target)
    elseif exam and status == 3 then
        text = quest_text .. "Rank " .. RankDefs.GetName(rank) .. " | NHIỆM VỤ RANK hoàn thành, hãy xác nhận tại Hiệp Hội"
    end
    self.rank_exam_text:SetString(text)
end

function HHStatusUI:OnDestroy()
    if self.on_close ~= nil then
        local callback = self.on_close
        self.on_close = nil
        callback()
    end
    HHStatusUI._base.OnDestroy(self)
end

function HHStatusUI:OnControl(control, down)
    if HHStatusUI._base.OnControl(self, control, down) then return true end
    if self.embedded then return false end
    if not down and (control == CONTROL_CANCEL or control == KEY_B) then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

return HHStatusUI
