local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local Button = require("widgets/button")
local RankDefs = require("guild/hh_rank_defs")
local ExamDefs = require("guild/hh_rank_exam_defs")
local QuestDefs = require("guild/hh_guild_quest_defs")
local ShopDefs = require("guild/hh_guild_shop_defs")
local RequestGate = require("ui/ttk_request_gate")
local Theme = require("widgets/hh_ui/ttk_unified_theme")
local UIFONT = Theme.GetFont()
local TITLEFONT = Theme.GetFont()

local ITEMS_PER_PAGE = 5
local REQUEST_NONCE = 0
local HUD_ATLAS = "images/hh_icon/guild_hud.xml"
local HUD_TEXTURE = "guild_hud.tex"
local HUD_SCALE = 0.65
local HUD_ROOT_SCALE = 0.6
local QUEST_TEXT_WIDTH = 230
local QUEST_TEXT_HEIGHT = 270
local QUEST_TEXT_MAX_LINES = 12
local QUEST_TEXT_FONT_SIZE = 18
local QUEST_TEXT_MIN_FONT_SIZE = 14

local function AddTextButton(parent, x, y, width, height, font_size)
    local button = parent:AddChild(require([[widgets/textbutton]])())
    button:SetPosition(x, y, 0)
    button:SetFont(UIFONT)
    button:SetTextSize(font_size or 18)
    button:SetTextColour(0.78, 0.86, 1, 1)
    button:SetTextFocusColour(0.35, 0.8, 1, 1)
    button:SetTextDisabledColour(0.35, 0.4, 0.5, 1)
    button:SetTextSelectedColour(1, 0.82, 0.2, 1)
    button.text:SetRegionSize(width, height)
    button.text:EnableWordWrap(true)
    button.clickoffset = Vector3(0, -1, 0)
    return button
end

local function AddText(parent, x, y, width, height, font_size, colour, halign)
    local text = parent:AddChild(Text(UIFONT, font_size or 18, ""))
    text:SetPosition(x, y, 0)
    text:SetRegionSize(width, height)
    text:EnableWordWrap(true)
    text:SetHAlign(halign or ANCHOR_MIDDLE)
    if colour ~= nil then
        text:SetColour(unpack(colour))
    end
    return text
end

local function SetQuestText(text, value)
    value = value or ""
    if text._hh_wrapped_source == value then
        return
    end
    text._hh_wrapped_source = value
    text:SetSize(QUEST_TEXT_FONT_SIZE)
    text:ResetRegionSize()
    text:SetMultilineTruncatedString(
        value,
        QUEST_TEXT_MAX_LINES,
        QUEST_TEXT_WIDTH,
        nil,
        true,
        true,
        QUEST_TEXT_MIN_FONT_SIZE
    )
    text:SetRegionSize(QUEST_TEXT_WIDTH, QUEST_TEXT_HEIGHT)
end

local function ContainsId(ids, wanted)
    if wanted == nil then
        return false
    end
    for _, id in ipairs(ids or {}) do
        if id == wanted then
            return true
        end
    end
    return false
end

local function NetValue(owner, field, default)
    local netvar = owner and owner[field]
    return netvar and netvar:value() or default
end

local function ParseStock(value)
    local stock = {}
    local index = 1
    for token in string.gmatch(value or "", "[^,]+") do
        stock[index] = math.max(0, tonumber(token) or 0)
        index = index + 1
    end
    return stock
end

local function ParseIdList(value)
    local ids = {}
    for token in string.gmatch(value or "", "[^,]+") do
        local id = tonumber(token)
        if id ~= nil then
            table.insert(ids, id)
        end
    end
    return ids
end

local function FormatRequirements(requirements)
    local parts = {}
    for _, requirement in ipairs(requirements or {}) do
        local names = STRINGS and STRINGS.NAMES
        local display_name = names and names[string.upper(requirement.prefab)] or requirement.prefab
        table.insert(parts, tostring(display_name) .. " x" .. tostring(requirement.amount))
    end
    return table.concat(parts, ", ")
end

local function FormatRemaining(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local days = math.floor(seconds / TUNING.TOTAL_DAY_TIME)
    local rest = seconds - days * TUNING.TOTAL_DAY_TIME
    local minutes = math.floor(rest / 60)
    local secs = rest % 60
    return string.format("%d ngày %02d:%02d", days, minutes, secs)
end

local function SendAction(action, value)
    if MOD_RPC ~= nil
        and MOD_RPC.hh_rpc
        and MOD_RPC.hh_rpc.hh_guild_action then
        REQUEST_NONCE = REQUEST_NONCE + 1
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_guild_action, action, value or 0, REQUEST_NONCE)
    end
end

local HHGuildUI = Class(Screen, function(self, owner, on_close, options)
    Screen._ctor(self, "HHGuildUI")
    options = options or {}
    self.owner = owner
    self.on_close = on_close
    self.embedded = options.embedded == true
    self.request_gate = RequestGate()
    self.server_closed = false
    self.page = 1
    self.max_page = 1
    self.selected_offer_id = nil

    self.root = self:AddChild(Widget("root"))
    if not self.embedded then
        self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.root:SetHAnchor(ANCHOR_MIDDLE)
        self.root:SetVAnchor(ANCHOR_MIDDLE)
    end
    local root_scale = self.embedded and 1.05 or HUD_ROOT_SCALE
    self.root:SetScale(root_scale, root_scale, 1)

    if self.embedded then
        self.bg = self.root:AddChild(Image("images/ttk_forge/frame.xml", "frame.tex"))
        self.bg:SetSize(900, 600)
        self.bg:SetTint(unpack(Theme.colours.panel))
    else
        self.bg = self.root:AddChild(Image(HUD_ATLAS, HUD_TEXTURE))
        self.bg:SetScale(HUD_SCALE, HUD_SCALE, 1)
    end

    self.title = self.root:AddChild(Text(TITLEFONT, 45, "HIỆP HỘI THỢ SĂN"))
    self.title:SetPosition(0, 255, 0)
    self.title:SetColour(0.35, 0.75, 1, 1)

    self.close_btn = AddTextButton(self.root, 290, 240, 48, 48, 28)
    self.close_btn:SetText("X")
    self.close_btn:SetOnClick(function()
        self:CloseRemote()
        if self.embedded then
            if options.close ~= nil then options.close() end
        else
            TheFrontEnd:PopScreen(self)
        end
    end)
    if self.embedded then self.close_btn:Hide() end

    self.rank_current_text = AddText(self.root, -155, 195, 235, 34, 20, nil, ANCHOR_LEFT)
    self.rank_requirement_text = AddText(self.root, -175, 165, 235, 34, 20, nil, ANCHOR_LEFT)
    self.rank_completed_text = AddText(self.root, -175, 135, 235, 34, 20, nil, ANCHOR_LEFT)
    self.rank_failed_text = AddText(self.root, -175, 105, 235, 34, 20, nil, ANCHOR_LEFT)

    self.credit_text = AddText(self.root, 210, 195, 225, 50, 30)
    self.credit_text:SetColour(1, .82, .2, 1)

    self.exam_header = self.root:AddChild(Text(TITLEFONT, 22, "Thử Thách Thăng Hạng"))
    self.exam_header:SetPosition(10, 200, 0)
    self.exam_text = AddText(self.root, 10, 150, 270, 95, 18)

    self.exam_start_btn = AddTextButton(self.root, -45, 97, 115, 34, 20)
    self.exam_start_btn:SetText("Chấp Nhận")
    self.exam_start_btn:SetOnClick(function() self:RequestAction("exam_start") end)

    self.exam_claim_btn = AddTextButton(self.root, 60, 97, 115, 34, 17)
    self.exam_claim_btn:SetText("Xác Nhận Rank")
    self.exam_claim_btn:SetOnClick(function() self:RequestAction("exam_claim") end)

    self.quest_header = self.root:AddChild(Text(TITLEFONT, 40, "NHIỆM VỤ"))
    self.quest_header:SetPosition(-185, 48, 0)
    self.quest_header:SetColour(1, .82, .2, 1)
    self.quest_text = AddText(self.root, -180, -45, QUEST_TEXT_WIDTH, QUEST_TEXT_HEIGHT, QUEST_TEXT_FONT_SIZE, nil, ANCHOR_LEFT)
    self.quest_text:EnableWordWrap(false)

    -- Vi tri rieng cho chu/nut Quest 1 den Quest 8 tren Guild HUD.
    -- Tang x: sang phai, giam x: sang trai; tang y: len tren, giam y: xuong duoi.
    local quest_offer_layout = {
        { x = -22, y = 20 },   -- Quest 1
        { x = 38,  y = 20 },   -- Quest 2
        { x = -22, y = -30 },  -- Quest 3
        { x = 38,  y = -30 },  -- Quest 4
        { x = -22, y = -80 }, -- Quest 5
        { x = 38,  y = -80 }, -- Quest 6
        { x = -22, y = -130 }, -- Quest 7
        { x = 38,  y = -130 }, -- Quest 8
    }

    self.offer_ids = {}
    self.quest_offer_buttons = {}
    for index = 1, 8 do
        local offer_index = index
        local layout = quest_offer_layout[index]
        local button = AddTextButton(self.root, layout.x, layout.y, 72, 54, 16)
        button:SetText("Q" .. tostring(index))
        button:SetOnClick(function()
            local quest_id = self.offer_ids[offer_index]
            if quest_id ~= nil then
                self.selected_offer_id = quest_id
                self:Refresh()
            end
        end)
        self.quest_offer_buttons[index] = button
    end

    self.quest_primary_btn = AddTextButton(self.root, -220, -193, 185, 35, 19)
    self.quest_primary_btn:SetOnClick(function()
        if self.quest_primary_action ~= nil then
            self:RequestAction(self.quest_primary_action, self.quest_primary_value)
        end
    end)

    self.quest_abandon_btn = AddTextButton(self.root, -40, -193, 205, 35, 19)
    self.quest_abandon_btn:SetText("Hủy Quest (Thất Bại)")
    self.quest_abandon_btn:SetOnClick(function() self:RequestAction("quest_abandon") end)

    self.reward_header = self.root:AddChild(Text(TITLEFONT, 20, "PHẦN THƯỞNG"))
    self.reward_header:SetPosition(220, 148, 0)
    self.reward_text = AddText(self.root, 220, 135, 220, 35, 15)

    self.reward_btn = AddTextButton(self.root, 220, 101, 210, 30, 18)
    self.reward_btn:SetText("Nhận Phần Thưởng")
    self.reward_btn:SetOnClick(function()
        if self:RequestAction("reward_claim") and not self.embedded then
            TheFrontEnd:PopScreen(self)
        end
    end)

 -- self.shop_header = self.root:AddChild(Text(TITLEFONT, 24, "CỬA HÀNG GUILD"))
 -- self.shop_header:SetPosition(255, 82, 0)
-- Mỗi bảng là một hàng Shop: toàn bộ số bên trong có thể chỉnh độc lập.
    local shop_row_layout = {
        -- row_x, row_y: vị trí cả hàng | label_*: chữ sản phẩm | buy_*: nút Mua.
        { row_x = 250, row_y = 36,   label_x = -45, label_y = 0, label_width = 220, label_height = 48, label_font = 15, buy_x = 25, buy_y = 3, buy_width = 54, buy_height = 42, buy_font = 25 },
        { row_x = 250, row_y = -6,   label_x = -45, label_y = 0, label_width = 220, label_height = 48, label_font = 15, buy_x = 25, buy_y = 3, buy_width = 54, buy_height = 42, buy_font = 25 },
        { row_x = 250, row_y = -48,  label_x = -45, label_y = 0, label_width = 220, label_height = 48, label_font = 15, buy_x = 25, buy_y = 3, buy_width = 54, buy_height = 42, buy_font = 25 },
        { row_x = 250, row_y = -90,  label_x = -45, label_y = 0, label_width = 220, label_height = 48, label_font = 15, buy_x = 25, buy_y = 3, buy_width = 54, buy_height = 42, buy_font = 25 },
        { row_x = 250, row_y = -132, label_x = -45, label_y = 0, label_width = 220, label_height = 48, label_font = 15, buy_x = 25, buy_y = 3, buy_width = 54, buy_height = 42, buy_font = 25 },
    }

    self.shop_rows = {}
    for row_index = 1, ITEMS_PER_PAGE do
        local layout = shop_row_layout[row_index]
        local row = self.root:AddChild(Widget("shop_row_" .. tostring(row_index)))
        row:SetPosition(layout.row_x, layout.row_y, 0)
        row.label = row:AddChild(Text(UIFONT, layout.label_font, ""))
        row.label:SetPosition(layout.label_x, layout.label_y, 0)
        row.label:SetRegionSize(layout.label_width, layout.label_height)
        row.label:EnableWordWrap(true)
        row.label:SetHAlign(ANCHOR_LEFT)
        row.buy = AddTextButton(row, layout.buy_x, layout.buy_y,
            layout.buy_width, layout.buy_height, layout.buy_font)
        row.buy:SetText("Mua")
        self.shop_rows[row_index] = row
    end

    self.prev_btn = AddTextButton(self.root, 137, -173, 40, 40, 24)
    self.prev_btn:SetText("<")
    self.prev_btn:SetOnClick(function()
        self.page = math.max(1, self.page - 1)
        self:Refresh()
    end)

    self.page_text = AddText(self.root, 193, -173, 80, 38, 18)

    self.next_btn = AddTextButton(self.root, 249, -173, 40, 40, 24)
    self.next_btn:SetText(">")
    self.next_btn:SetOnClick(function()
        self.page = math.min(self.max_page, self.page + 1)
        self:Refresh()
    end)

    self.notice_text = AddText(self.root, 0, -240, 760, 45, 20)
    self.notice_text:SetColour(.45, .85, 1, 1)

    local dirty_events = {
        "hh_guild_rankdirty",
        "hh_guild_creditdirty",
        "hh_guild_examdirty",
        "hh_guild_questdirty",
        "hh_guild_shopdirty",
        "hh_guild_pendingdirty",
        "hh_guild_noticedirty",
    }
    for _, event_name in ipairs(dirty_events) do
        self.inst:ListenForEvent(event_name, function()
            self.request_gate:Acknowledge()
            if self.shown then self:Refresh() end
        end, owner)
    end

    SendAction("refresh")

    self.inst:DoPeriodicTask(1, function()
        if self.shown then
            self:Refresh()
        end
    end)

    self:Refresh()
end)

function HHGuildUI:RequestAction(action, value)
    return self.request_gate:Try(function() SendAction(action, value) end)
end

function HHGuildUI:SetQuestFocus(mode)
    local Theme = require("widgets/hh_ui/ttk_unified_theme")
    self.quest_header:SetColour(unpack(mode == "guild" and Theme.colours.purple_soft or Theme.colours.silver))
    self.exam_header:SetColour(unpack(mode == "promotion" and Theme.colours.purple_soft or Theme.colours.silver))
end

function HHGuildUI:CloseRemote()
    if not self.server_closed then
        self.server_closed = true
        SendAction("close")
    end
end

function HHGuildUI:ShowPanel()
    self:Show()
    SendAction("refresh")
end

function HHGuildUI:HidePanel()
    self:Hide()
end

function HHGuildUI:DisposePanel()
    self:CloseRemote()
    self:Kill()
end

function HHGuildUI:Refresh()
    local rank = NetValue(self.owner, "hh_guild_rank", 1)
    local credit = NetValue(self.owner, "hh_guild_credit", 0)
    local completed_count = NetValue(self.owner, "hh_guild_quest_completed_count", 0)
    local failed_count = NetValue(self.owner, "hh_guild_quest_failed_count", 0)
    local next_rank = RankDefs.GetNextRank(rank)
    local promotion_line = next_rank ~= nil
        and string.format("Cần Level %d để lên Rank %s",
            RankDefs.GetRequiredLevel(next_rank), RankDefs.GetName(next_rank))
        or "Đã đạt bậc Rank tối đa"
    self.rank_current_text:SetString("Mức Rank hiện tại: " .. RankDefs.GetName(rank))
    self.rank_requirement_text:SetString(promotion_line)
    self.rank_completed_text:SetString("Quest đã hoàn thành: " .. tostring(completed_count))
    self.rank_failed_text:SetString("Quest đã thất bại: " .. tostring(failed_count))
    self.credit_text:SetString("Xu Hiệp Hội: " .. tostring(credit))

    local exam_id = NetValue(self.owner, "hh_guild_exam_id", 0)
    local exam_status = NetValue(self.owner, "hh_guild_exam_status", 0)
    local exam_progress = NetValue(self.owner, "hh_guild_exam_progress", 0)
    local exam_target = NetValue(self.owner, "hh_guild_exam_target", 0)
    local exam = ExamDefs.Get(exam_id)
    local exam_visible = exam ~= nil and exam_status >= 1 and exam_status <= 3
    if exam_visible then
        local required_level = RankDefs.GetRequiredLevel(exam.rank)
        self.exam_header:Show()
        self.exam_text:Show()
        if exam_status == 1 then
            self.exam_text:SetString(string.format("%s\n%s\nYêu cầu Lv.%d",
                exam.title, exam.description, required_level))
        elseif exam_status == 2 then
            self.exam_text:SetString(string.format("%s\n%s\nTiến độ: %d/%d",
                exam.title, exam.description, exam_progress, exam_target))
        else
            self.exam_text:SetString(string.format("%s\nĐã hoàn thành: %d/%d\nHãy xác nhận thăng Rank.",
                exam.title, exam_progress, exam_target))
        end
    else
        self.exam_header:Hide()
        self.exam_text:Hide()
    end
    if exam_status == 1 then self.exam_start_btn:Show() else self.exam_start_btn:Hide() end
    if exam_status == 3 then self.exam_claim_btn:Show() else self.exam_claim_btn:Hide() end

    local quest_id = NetValue(self.owner, "hh_guild_quest_id", 0)
    local quest_status = NetValue(self.owner, "hh_guild_quest_status", 0)
    local progress = NetValue(self.owner, "hh_guild_quest_progress", 0)
    local target = NetValue(self.owner, "hh_guild_quest_target", 0)
    local remaining = NetValue(self.owner, "hh_guild_quest_remaining", 0)
    local reward = NetValue(self.owner, "hh_guild_quest_reward", 0)
    local cooldown = NetValue(self.owner, "hh_guild_quest_cooldown", 0)
    local failure = NetValue(self.owner, "hh_guild_quest_failure", "")
    self.offer_ids = ParseIdList(NetValue(self.owner, "hh_guild_quest_offers", ""))
    local quest = QuestDefs.Get(quest_id)
    if not ContainsId(self.offer_ids, self.selected_offer_id) then
        self.selected_offer_id = self.offer_ids[1]
    end
    local selected_offer = QuestDefs.Get(self.selected_offer_id)
    if quest and quest_status == 1 then
        local description = string.format("%s\n%s\nTiến độ: %d/%d\nThời gian còn lại: %s\nPhần thưởng: %d Xu Hiệp Hội",
            quest.title, quest.description, progress, target, FormatRemaining(remaining), reward)
        if quest.tracker == "delivery" then
            description = description .. "\nVật phẩm cần giao: " .. FormatRequirements(quest.requirements)
                .. "\nGiao trực tiếp trong bảng Hiệp Hội"
        end
        SetQuestText(self.quest_text, description)
    elseif quest and quest_status == 2 then
        SetQuestText(self.quest_text, quest.title .. "\nĐÃ HOÀN THÀNH")
    elseif quest and quest_status == 3 and cooldown > 0 then
        SetQuestText(self.quest_text, quest.title .. "\nĐÃ HỦY\nCó thể nhận quest mới sau: " .. FormatRemaining(cooldown))
    elseif cooldown > 0 then
        if failure == "reward_cooldown" then
            SetQuestText(self.quest_text, "Hiện tại chưa có nhiệm vụ nào ! Thợ săn hãy dành thời gian này để nghỉ ngơi\nNhiệm vụ mới sau: " .. FormatRemaining(cooldown))
        else
            SetQuestText(self.quest_text, "Đã hủy Guild Quest.\nCó thể nhận quest mới sau: " .. FormatRemaining(cooldown))
        end
    elseif selected_offer ~= nil then
        local description = string.format(
            "[Rank %s] %s\n%s\nThời hạn: %d ngày\nPhần thưởng: %d Xu Hiệp Hội",
            RankDefs.GetName(selected_offer.rank), selected_offer.title, selected_offer.description,
            selected_offer.duration_days or 3, selected_offer.reward_credit or 0)
        if selected_offer.tracker == "delivery" then
            description = description .. "\nVật phẩm cần giao: " .. FormatRequirements(selected_offer.requirements)
                .. "\nGiao trực tiếp trong bảng Hiệp Hội"
        end
        SetQuestText(self.quest_text, description)
    else
        SetQuestText(self.quest_text, "Chưa có Guild Quest khả dụng.\nHãy chờ Hiệp Hội cập nhật danh sách nhiệm vụ.")
    end

    self.quest_primary_action = nil
    self.quest_primary_value = nil
    self.quest_primary_btn:Hide()
    self.quest_abandon_btn:Hide()
    for _, button in ipairs(self.quest_offer_buttons) do
        button:Hide()
        button:SetHoverText("")
    end
    if quest_status == 1 then
        self.quest_abandon_btn:Show()
        if quest and quest.tracker == "delivery" then
            self.quest_primary_action = "quest_submit"
            self.quest_primary_btn:SetText("Giao vật phẩm")
            self.quest_primary_btn:Show()
        end
    elseif cooldown <= 0 then
        for index, offer_id in ipairs(self.offer_ids) do
            if index <= #self.quest_offer_buttons and QuestDefs.Get(offer_id) then
                local offer = QuestDefs.Get(offer_id)
                local button = self.quest_offer_buttons[index]
                button:SetText(string.format("Quest %d\nRank %s", index, RankDefs.GetName(offer.rank)))
                button:SetTextColour(offer_id == self.selected_offer_id and {1, .82, .2, 1}
                    or {.78, .86, 1, 1})
                button:SetHoverText(string.format("[Rank %s] %s\n%s\nThời hạn: %d ngày | Thưởng: %d Xu",
                    RankDefs.GetName(offer.rank), offer.title, offer.description,
                    offer.duration_days or 3, offer.reward_credit or 0))
                button:Show()
            end
        end
        if selected_offer ~= nil then
            self.quest_primary_action = "quest_accept"
            self.quest_primary_value = self.selected_offer_id
            self.quest_primary_btn:SetText("Nhận Quest Đã Chọn")
            self.quest_primary_btn:Show()
        end
    end

    local pending = NetValue(self.owner, "hh_guild_pending_reward", "")
    self.reward_text:SetString(pending ~= "" and ("" .. pending) or "Không có phần thưởng đang chờ.")
    if pending ~= "" then self.reward_btn:Show() else self.reward_btn:Hide() end

    local stock = ParseStock(NetValue(self.owner, "hh_guild_shop_stock", ""))
    local active_ids = ParseIdList(NetValue(self.owner, "hh_guild_shop_products", ""))
    local active_products = {}
    for _, product_id in ipairs(active_ids) do
        local product = ShopDefs.Get(product_id)
        if product then
            table.insert(active_products, product)
        end
    end
    self.max_page = math.max(1, math.ceil(#active_products / ITEMS_PER_PAGE))
    self.page = math.min(self.page, self.max_page)
    local start_index = (self.page - 1) * ITEMS_PER_PAGE + 1
    for row_index, row in ipairs(self.shop_rows) do
        local product = active_products[start_index + row_index - 1]
        if product then
            local current_stock = stock[product.id] or 0
            row:Show()
            row.label:SetString(string.format("[Rank %s] %s x%d\n%d Xu | Stock %d",
                RankDefs.GetName(product.rank), product.name, product.amount or 1, product.price, current_stock))
            row.buy:SetOnClick(function()
                self:RequestAction("shop_buy", product.id)
            end)
            if rank >= product.rank and current_stock > 0 then
                row.buy:Show()
            else
                row.buy:Hide()
            end
        else
            row:Hide()
        end
    end
    self.page_text:SetString(string.format("%d / %d", self.page, self.max_page))
    self.notice_text:SetString(NetValue(self.owner, "hh_guild_notice", ""))
end

function HHGuildUI:OnDestroy()
    self.request_gate:Dispose()
    if self.on_close ~= nil then
        local callback = self.on_close
        self.on_close = nil
        callback()
    end
    HHGuildUI._base.OnDestroy(self)
end

function HHGuildUI:OnControl(control, down)
    if HHGuildUI._base.OnControl(self, control, down) then return true end
    if self.embedded then return false end
    if not down and control == CONTROL_CANCEL then
        self:CloseRemote()
        TheFrontEnd:PopScreen(self)
        return true
    end
end

return HHGuildUI
