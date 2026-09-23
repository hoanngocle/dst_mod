-- Presentation only. All mutable state and purchase quotes come from the replica.
if TheNet ~= nil and TheNet:IsDedicated() then return nil end

local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local TextButton = require("widgets/textbutton")

local PAGE_SIZE = 6
local TABS = { "achievement", "seasonal", "perk" }
local TAB_LABELS = { achievement="Thành tựu", seasonal="Nhiệm vụ mùa", perk="Đặc quyền" }
local ACHIEVEMENT_GROUPS = {
    { "survival", "Sinh tồn" }, { "food", "Ẩm thực" },
    { "collection", "Thu thập" }, { "labor", "Lao động" },
    { "crafting", "Chế tạo" }, { "farming", "Nông nghiệp" },
    { "combat", "Chiến đấu" }, { "boss", "Thủ lĩnh" },
    { "level_rank", "Cấp & Rank" }, { "enhancement", "Cường hóa" },
    { "dungeon_guild", "Hầm ngục & Hội" }, { "seasonal", "Theo mùa" },
    { "gacha_shop", "Rút thưởng & Shop" },
}
local PERK_GROUPS = { { "stats", "Chỉ số" }, { "ability", "Năng lực" }, { "craft", "Chế tạo" } }
local STATUS = { claimed="Đã nhận", locked="Chưa hoàn thành", active="Đang thực hiện",
    completed_unclaimed="Có thể nhận", ready_to_claim="Có thể nhận" }
local serial = 0
local nonce_session = tostring({}):gsub("[^%w]", "")
local function NewNonce()
    serial = serial + 1
    return "ui:" .. nonce_session .. ":" .. tostring(GetTime()) .. ":" .. tostring(serial)
end

local function ValidSlot(value, maximum)
    return type(value) == "number" and value >= 1 and value <= maximum and value == math.floor(value)
end

local function Label(parent, size, x, y, width, height)
    local label = parent:AddChild(Text(UIFONT, size, ""))
    label:SetPosition(x, y)
    label:SetRegionSize(width, height)
    label:EnableWordWrap(true)
    return label
end

local function Button(parent, text, x, y, width, click)
    local button = parent:AddChild(TextButton())
    button:SetPosition(x, y)
    button:SetFont(UIFONT)
    button:SetTextSize(23)
    button:SetText(text)
    button.text:SetRegionSize(width, 34)
    button:SetOnClick(click)
    return button
end

local TtkProgressionScreen = Class(Screen, function(self, owner)
    Screen._ctor(self, "TtkProgressionScreen")
    self.owner = owner
    self.tab, self.group, self.page = "achievement", nil, 1
    self.pending = false
    self.snapshot = { balance=0, achievement_rows={}, perk_rows={} }
    self.root = self:AddChild(Widget("progression_root"))
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.background = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.background:SetSize(1120, 690)
    self.background:SetTint(.045, .055, .075, .97)
    self.title = Label(self.root, 30, -210, 306, 650, 40)
    self.title:SetString("Phàm Nhân — Thành tựu & Đặc quyền")
    self.stars = Label(self.root, 26, 360, 306, 280, 40)
    self.stars:SetColour(1, .83, .3, 1)
    self.close_btn = Button(self.root, "X", 526, 310, 42, function() TheFrontEnd:PopScreen(self) end)
    self.tabs = {}
    for index, tab in ipairs(TABS) do
        self.tabs[index] = Button(self.root, TAB_LABELS[tab], -350 + (index - 1) * 270, 251, 245,
            function() self:SetTab(tab) end)
    end
    self.filters, self.rows, self.chests = {}, {}, {}
    self.filters[1] = Button(self.root, "Tất cả", -428, 194, 220, function() self:SetGroup(nil) end)
    for index, group in ipairs(ACHIEVEMENT_GROUPS) do
        self.filters[index + 1] = Button(self.root, group[2], -428, 194 - index * 28, 220,
            function() self:SetGroup(group[1]) end)
    end
    -- Reuse a fixed six-row pool; changing pages never builds 231 widgets.
    for index = 1, PAGE_SIZE do
        local row = self.root:AddChild(Widget("progression_row"))
        row:SetPosition(75, 181 - (index - 1) * 75)
        row.title = Label(row, 23, -100, 15, 535, 30)
        row.detail = Label(row, 18, -85, -16, 565, 43)
        row.action = Button(row, "Nhận", 352, 0, 155, function() self:ActivateRow(self.visible_rows[index]) end)
        self.rows[index] = row
    end
    for index = 1, 4 do
        self.chests[index] = Button(self.root, "", -190 + (index - 1) * 210, -269, 200,
            function() self:ActivateChest(index) end)
    end
    self.notice = Label(self.root, 19, 30, -237, 920, 30)
    self.previous = Button(self.root, "< Trước", -160, -315, 140, function() self:SetPage(self.page - 1) end)
    self.page_label = Label(self.root, 21, 35, -315, 180, 30)
    self.next = Button(self.root, "Sau >", 230, -315, 140, function() self:SetPage(self.page + 1) end)
    self.refresh = Button(self.root, "Làm mới", -430, -315, 170, function() self:RequestSnapshot() end)
    self.inst:ListenForEvent("ttk_achievement_snapshot", function() self:OnSnapshot() end, owner)
    self:Render()
    self:OnSnapshot()
    self:RequestSnapshot()
end)

function TtkProgressionScreen:Send(name, ...)
    if self.owner == nil or self.owner._ttk_achievement_rpc_namespace == nil then return false end
    SendModRPCToServer(GetModRPC(self.owner._ttk_achievement_rpc_namespace, name), ...)
    return true
end

function TtkProgressionScreen:RequestSnapshot()
    self:Send("AchievementSnapshot", NewNonce())
end

function TtkProgressionScreen:OnSnapshot()
    local replica = self.owner and self.owner.replica and self.owner.replica.ttk_achievement_progress
    if replica == nil then return end
    self.snapshot = replica:GetSnapshot()
    self.pending = false
    self:Render()
end

function TtkProgressionScreen:SetTab(tab)
    if tab ~= "achievement" and tab ~= "seasonal" and tab ~= "perk" then return end
    self.tab, self.group, self.page = tab, nil, 1
    self:Render()
end

function TtkProgressionScreen:SetGroup(group)
    self.group, self.page = group, 1
    self:Render()
end

function TtkProgressionScreen:SetPage(page)
    self.page = math.max(1, math.min(self.pages or 1, page))
    self:Render()
end

function TtkProgressionScreen:Render()
    self.stars:SetString("Star: " .. tostring(self.snapshot.balance))
    local groups = self.tab == "achievement" and ACHIEVEMENT_GROUPS or self.tab == "perk" and PERK_GROUPS or {}
    for index, button in ipairs(self.filters) do
        local group = groups[index - 1]
        if self.tab ~= "seasonal" and (index == 1 or group ~= nil) then
            button:Show()
            button:SetText(index == 1 and "Tất cả" or group[2])
            local id = group and group[1] or nil
            button:SetOnClick(function() self:SetGroup(id) end)
            if self.group == id then button:Disable() else button:Enable() end
        else button:Hide() end
    end
    for index, button in ipairs(self.tabs) do
        if TABS[index] == self.tab then button:Disable() else button:Enable() end
    end
    local seasonal = self.snapshot.seasonal
    local source = self.tab == "achievement" and self.snapshot.achievement_rows
        or self.tab == "perk" and self.snapshot.perk_rows or seasonal and seasonal.slots or {}
    local selected = {}
    for _, row in ipairs(source or {}) do
        if self.group == nil or row.group == self.group then selected[#selected + 1] = row end
    end
    self.pages = math.max(1, math.ceil(#selected / PAGE_SIZE))
    self.page = math.min(self.page, self.pages)
    self.page_label:SetString(tostring(self.page) .. " / " .. tostring(self.pages))
    if self.page > 1 then self.previous:Enable() else self.previous:Disable() end
    if self.page < self.pages then self.next:Enable() else self.next:Disable() end
    self.visible_rows = {}
    for index, widget in ipairs(self.rows) do
        local row = selected[(self.page - 1) * PAGE_SIZE + index]
        self.visible_rows[index] = row
        if row == nil then widget:Hide() else
            widget:Show()
            widget.title:SetString(row.name)
            local detail
            if self.tab == "perk" then
                local effect = row.repeatable and tostring(row.current_effect) .. " → " .. tostring(row.next_effect)
                    or (row.current_effect == 1 and "Đã mở khóa" or "Chưa mở → Mở khóa " .. row.name)
                detail = "Cấp " .. tostring(row.level) .. "/" .. tostring(row.max_level) .. " | Hiệu ứng: " .. effect
                    .. "\nGiá cấp hiện tại: " .. tostring(row.current_cost) .. " | Kế tiếp: " .. tostring(row.next_cost) .. " Star"
                widget.action:SetText(row.status == "claimed" and "Tối đa" or "Mua")
            else
                detail = row.description .. "\n" .. tostring(row.progress) .. "/" .. tostring(row.target)
                if self.tab == "seasonal" then
                    detail = detail .. " | Đã nhận: " .. tostring(row.claims) .. "/" .. tostring(row.max_claims)
                else detail = detail .. " | " .. tostring(row.reward) .. " Star" end
                widget.action:SetText(STATUS[row.status] or "Nhận")
            end
            widget.detail:SetString(detail)
            if row.can_claim and not self.pending then widget.action:Enable() else widget.action:Disable() end
        end
    end
    for index, button in ipairs(self.chests) do
        local row = self.tab == "seasonal" and seasonal and seasonal.chests[index] or nil
        if row == nil then button:Hide() else
            button:Show()
            button:SetText("Rương " .. tostring(row.milestone) .. (row.status == "claimed" and " · Đã nhận" or " · Nhận"))
            if row.can_claim and not self.pending then button:Enable() else button:Disable() end
        end
    end
    self.notice:SetString(self.pending and "Đang chờ máy chủ…"
        or self.tab == "seasonal" and (seasonal and (seasonal.season .. " | 20 nhiệm vụ cố định · Đã nhận lần đầu: " .. tostring(seasonal.first_claims)) or "Đang chờ nhiệm vụ mùa từ máy chủ…")
        or #selected == 0 and "Đang chờ dữ liệu từ máy chủ…" or "")
end

function TtkProgressionScreen:ActivateRow(row)
    if row == nil then return end
    if self.pending or not row.can_claim then return end
    if self.tab == "seasonal" then
        if not ValidSlot(row.slot, 20) or self.snapshot.seasonal == nil
            or self.snapshot.seasonal.slots[row.slot] ~= row then return end
    end
    self.pending = true
    self:Render()
    local nonce = NewNonce()
    if self.tab == "achievement" then self:Send("AchievementClaim", row.id, nonce)
    elseif self.tab == "perk" then self:Send("AchievementPerk", row.id, nonce)
    else self:Send("AchievementSeasonal", "task", row.slot, row.id, nonce) end
end

function TtkProgressionScreen:ActivateChest(index)
    local seasonal = self.snapshot.seasonal
    local row = seasonal and seasonal.chests[index]
    if row == nil then return end
    if self.pending or not row.can_claim then return end
    if not ValidSlot(row.slot, 4) or row.slot ~= index or row.id ~= "chest_" .. tostring(row.milestone) then return end
    self.pending = true
    self:Render()
    local nonce = NewNonce()
    self:Send("AchievementSeasonal", "chest", row.slot, row.id, nonce)
end

function TtkProgressionScreen:OnControl(control, down)
    if TtkProgressionScreen._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

return TtkProgressionScreen
