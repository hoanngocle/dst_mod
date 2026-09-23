local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local ImageButton = require("widgets/imagebutton")
local Utils = require("utils/hh_utils")
local Rules = require("utils/ttk_forge_rules")
local Effects = require("enums/hh_enchant").HH_EQUIP_BUFF_LIST
local Theme = require("widgets/hh_ui/ttk_unified_theme")

local WHITE = { .94, .91, .96, 1 }
local MUTED = { .73, .70, .79, 1 }
local SILVER = { .54, .49, .62, 1 }
local PURPLE = { .64, .49, .80, 1 }
local DARK = { .12, .11, .16, 1 }
local WARN = { 1, .72, .42, 1 }
local function Font() return Theme.GetFont() end
-- Compiled atlas line height is 99px; the design uses an 80px em.
local FONT_SCALE = 99 / 80
local SKIN = "images/ttk_forge/controls.xml"
local EFFECT_SKIN = "images/ttk_forge/effect_row.xml"
local EFFECTS_PER_PAGE = 3
local SOLID_ATLAS, SOLID_IMAGE = "images/hh_icon/hh_white.xml", "hh_white.tex"
local ITEM_ATLAS = "images/hh_icon/hh_items.xml"
local TABS = {
    { id = "cleanse", name = "Thanh Tẩy", action = "THANH TẨY" },
    { id = "stone_change", name = "Đúc Linh", action = "ĐÚC LINH" },
    { id = "equip_inherit", name = "Kế Thừa", action = "KẾ THỪA" },
}
-- Upper slot is a read-only preview. Every real input stays below it.
local LAYOUTS = {
    cleanse = {
        { slot = 1, x = -270, label = "Trang bị", hint = "Trang bị cần xóa dòng thuộc tính" },
    },
    stone_change = {
        { slot = 2, x = -270, label = "Đá Thuộc Tính", prefab = "hh_effect_stone", count = 1,
          hint = "Chỉ nhận Đá Thuộc Tính; chỉ đúc lại đá thường" },
        { slot = 3, x = -20, label = "Linh Thạch", prefab = "hh_essence", count = 5,
          hint = "Chỉ nhận Linh Thạch (hh_essence)" },
    },
    equip_inherit = {
        { slot = 2, x = -335, label = "A · Nguồn", hint = "Trang bị A có thuộc tính; sẽ bị tiêu hao" },
        { slot = 3, x = -205, label = "B · Nhận", hint = "Trang bị B chưa có dòng thuộc tính" },
        { slot = 4, x = -75, label = "Linh Thạch", prefab = "hh_essence", count = 20,
          hint = "Chỉ nhận Linh Thạch (hh_essence)" },
        { slot = 5, x = 55, label = "Ác Mộng", prefab = "nightmarefuel", count = 20,
          hint = "Chỉ nhận Nhiên Liệu Ác Mộng" },
    },
}

local function Rect(parent, x, y, w, h, colour)
    local image = parent:AddChild(Image(SOLID_ATLAS, SOLID_IMAGE))
    image:SetPosition(x, y)
    image:SetSize(w, h)
    image:SetTint(unpack(colour))
    image:SetClickable(false)
    return image
end

local function Label(parent, text, x, y, size, colour, width, lines)
    local label = parent:AddChild(Text(Font(), (size or 22) * FONT_SCALE, text, colour or WHITE))
    label:SetPosition(x, y)
    label:SetClickable(false)
    if width then label:SetMultilineTruncatedString(text, lines or 1, width, nil, true) end
    return label
end

local function Skin(parent, name, x, y, w, h)
    local image = parent:AddChild(Image(SKIN, name .. ".tex"))
    image:SetPosition(x, y)
    image:SetSize(w, h)
    image:SetClickable(false)
    return image
end

local function Divider(parent, x, y, width)
    Rect(parent, x, y, width, .65, SILVER)
    Skin(parent, "diamond", x, y, 10, 10)
end

local function Button(parent, text, x, y, w, h, click, style)
    local texture = style == "primary" and "primary.tex" or style == "square" and "slot.tex" or "tab_idle.tex"
    local button = parent:AddChild(ImageButton(SKIN, texture))
    button:SetPosition(x, y)
    button:ForceImageSize(w, h)
    button:SetNormalScale(1)
    button:SetFocusScale(1.015)
    button:SetFont(Font())
    button:SetDisabledFont(Font())
    button:SetTextSize((style == "primary" and 27 or 23) * FONT_SCALE)
    button:SetText(text)
    button:SetTextColour(unpack(WHITE))
    button:SetTextFocusColour(1, 1, 1, 1)
    button:SetTextDisabledColour(.56, .53, .62, 1)
    button:SetImageNormalColour(1, 1, 1, 1)
    button:SetImageFocusColour(1, .94, 1, 1)
    button:SetImageDisabledColour(1, 1, 1, 1)
    if style == "primary" then button.text:SetPosition(0, 5) end
    button:SetOnClick(click)
    return button
end

local function FixedIcon(prefab)
    if prefab == "hh_essence" then return "images/vat_pham_inventory_so_1.xml", "linh_thach_inventory.tex" end
    if prefab == "hh_effect_stone" then return "images/dyc_gem_purple.xml", "dyc_gem_purple.tex" end
    return GetInventoryItemAtlas("nightmarefuel.tex"), "nightmarefuel.tex"
end

local function Count(item)
    return item and item.replica and item.replica.stackable and item.replica.stackable:StackSize()
        or (item and 1 or 0)
end

local function ItemID(item)
    -- Lua GUIDs are local to each peer. Network IDs identify the same item remotely.
    return item and item.Network and tostring(item.Network:GetNetworkID()) or ""
end

local function EffectText(effect)
    local cfg = Effects[effect.name] or {}
    if cfg.desc then
        local ok, description = pcall(string.format, cfg.desc, effect.value)
        if ok then return description:gsub("\n", " ") end
    end
    local name = cfg.name or effect.name or "Thuộc tính"
    return effect.value ~= nil and (name .. " · " .. tostring(effect.value)) or name
end

local ForgeUI = Class(Widget, function(self, owner, container)
    Widget._ctor(self, "Thần Binh Phổ")
    self.owner, self.container = owner, container
    self.surface_scale = Theme.GetSurfaceScale("forge")
    self.mode = Rules.GetMode(container)
    self.selected, self.effects, self.page = {}, {}, 1
    self.elapsed, self.ready = 0, false
    self.frame = self:AddChild(Image("images/ttk_forge/frame.xml", "frame.tex"))
    self.frame:SetSize(900, 600)
    -- The opaque panel consumes pointer hits so blank space cannot walk.
    Label(self, "THẦN BINH PHỔ", 0, 240, 37)
    self.close = Button(self, "×", 386, 230, 28, 28, function()
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_ui_container, "forge_container")
    end, "square")
    self.tabs = {}
    for i, tab in ipairs(TABS) do
        local id = tab.id
        self.tabs[id] = Button(self, tab.name, (i - 2) * 256, 181, 254, 45,
            function() self:RequestMode(id) end)
    end
    Rect(self, 0, 151, 786, 1, SILVER)
    Rect(self, 120, -23, 1, 320, SILVER)
    Skin(self, "diamond", 120, 137, 10, 10)
    Skin(self, "diamond", 120, -183, 10, 10)
    Rect(self, 0, -203, 786, 1, SILVER)
    self.status = Label(self, "Đặt vật phẩm vào các ô bên dưới", 0, -221, 18, MUTED, 730)
    self.action = Button(self, "THANH TẨY", 0, -263, 290, 58, function() self:Submit() end, "primary")
    self:BuildBody()
    self.inst:ListenForEvent("ttk_forge_state", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_items", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_forge_equip", function() self:Refresh() end, owner)
    if container then
        self.inst:ListenForEvent("ttk_forge_mode_dirty", function() self:Refresh() end, container)
        self.inst:ListenForEvent("itemget", function() self:Refresh() end, container)
        self.inst:ListenForEvent("itemlose", function() self:Refresh() end, container)
    end
    self:StartUpdating()
    self:Refresh()
end)

function ForgeUI:GetItem(slot)
    local replica = self.container and self.container.replica and self.container.replica.container
    return replica and replica:GetItemInSlot(slot) or nil
end

function ForgeUI:GetModeLayout(mode)
    local layout = { slots = {} }
    for _, info in ipairs(LAYOUTS[mode] or {}) do
        layout.slots[#layout.slots + 1] = {
            container_slot = info.slot,
            prefab = info.prefab,
            count = info.count,
            x = info.x,
            label = info.label,
        }
    end
    return layout
end

function ForgeUI:BuildBody()
    if self.body then self.body:Kill() end
    self.body = self:AddChild(Widget("forge_body"))
    self.slot_labels, self.slot_counts = {}, {}
    self.preview_title = Label(self.body, "XEM TRƯỚC KẾT QUẢ", -145, 132, 21, WHITE)
    Divider(self.body, -322, 132, 68)
    Divider(self.body, 32, 132, 68)
    Skin(self.body, "slot", -145, 58, 120, 118)
    self.preview_icon = self.body:AddChild(Image(ITEM_ATLAS, "hh_effect_stone.tex"))
    self.preview_icon:SetPosition(-145, 57)
    self.preview_icon:SetSize(94, 94)
    self.preview_icon:SetClickable(false)
    self.preview_empty = Label(self.body, "?", -145, 57, 43, MUTED)
    self.preview_note = Label(self.body, "", -145, -19, 21, WHITE, 465, 2)
    self.preview_detail = Label(self.body, "", -145, -42, 18, MUTED, 465)
    Label(self.body, "↑", -145, -58, 26, PURPLE)
    for _, info in ipairs(LAYOUTS[self.mode]) do
        self.slot_labels[info.slot] = Label(self.body, info.label, info.x, -79, 19, WHITE,
            self.mode == "equip_inherit" and 124 or 210)
        self.slot_counts[info.slot] = Label(self.body, "", info.x, -181, 18, MUTED, 124)
    end
    self.right_title = Label(self.body, "", 265, 124, 28, WHITE, 266)
    Divider(self.body, 265, 105, 239)
    self.info_text = Label(self.body, "", 265, 35, 20, WHITE, 256, 5)
    self.cost_text = Label(self.body, "", 265, -99, 20, WHITE, 256, 2)
    self.warning = Label(self.body, "", 265, -158, 18, WARN, 256, 3)
    self.effect_buttons = {}
    if self.mode == "cleanse" then
        self.right_title:SetString("Chọn dòng cần xóa")
        for row = 1, EFFECTS_PER_PAGE do
            local r = row
            self.effect_buttons[row] = Button(self.body, "", 265, 73 - (row - 1) * 49, 253, 53,
                function() self:ToggleEffect((self.page - 1) * EFFECTS_PER_PAGE + r) end)
            local button = self.effect_buttons[row]
            button:SetTextures(EFFECT_SKIN, "selected.tex")
            button:SetTextSize(22 * FONT_SCALE)
            -- Selected artwork includes the rounded check and gold deletion marker.
            -- This row only selects; the separate Thanh Tẩy action performs deletion.
            button.emptycheck = button:AddChild(Widget("unchecked_effect"))
            Rect(button.emptycheck, -91, 0, 25, 25, WHITE)
            Rect(button.emptycheck, -91, 0, 22, 22, DARK)
        end
        self.previous = Button(self.body, "‹", 158, -59, 28, 22, function()
            self.page = math.max(1, self.page - 1); self:Refresh()
        end)
        self.next = Button(self.body, "›", 372, -59, 28, 22, function()
            self.page = math.min(math.ceil(#self.effects / EFFECTS_PER_PAGE), self.page + 1); self:Refresh()
        end)
        self.page_text = Label(self.body, "", 265, -59, 16, MUTED)
        Label(self.body, "Bùa Tẩy", -20, -79, 19, WHITE)
        Skin(self.body, "slot", -20, -132, 90, 88)
        self.currency_icon = self.body:AddChild(Image(ITEM_ATLAS, "hh_effect_tally.tex"))
        self.currency_icon:SetSize(65, 65)
        self.currency_icon:SetPosition(-20, -132)
        self.currency_icon:SetClickable(false)
        self.currency_count = Label(self.body, "", -20, -181, 18, MUTED, 130)
        self.warning:SetString("Chỉ xóa dòng đã chọn.\nBùa Tẩy dùng từ số dư\ncủa nhân vật.")
    elseif self.mode == "stone_change" then
        self.right_title:SetString("Đúc lại thuộc tính")
        self.info_text:SetString("Đặt 1 đá thường\nvà 5 Linh Thạch.\n\nNhận một đá thuộc tính\nngẫu nhiên sau mỗi lần đúc.")
        self.cost_text:SetString("Tiêu hao mỗi lần\n1 đá + 5 Linh Thạch")
        self.warning:SetString("Đá mới trả về ô đá bên trái.\nKhông đúc lại đá hiếm.")
    else
        self.right_title:SetString("Chuyển từ A sang B")
        self.info_text:SetString("A: trang bị có thuộc tính.\nB: trang bị chưa có dòng.\n\nChuyển dòng thuộc tính\nvà châu báu sang B.")
        self.cost_text:SetString("20 Linh Thạch\n20 Nhiên Liệu Ác Mộng")
        self.warning:SetString("Trang bị A sẽ bị tiêu hao.\nKhông chuyển cấp cường hóa.")
    end
    self:LayoutSlots()
end

function ForgeUI:AttachContainerWidget(widget)
    self.native = widget
    -- Native widgets retain drag/drop, item tiles, inventory controls and tooltips.
    for _, slot in ipairs(widget.inv) do
        slot:SetScale(1)
        slot.base_scale, slot.highlight_scale = 1, 1
        slot:SetOnTileChangedFn(function() self:RefreshGhosts() end)
    end
    self:LayoutSlots()
    self:Refresh()
end

function ForgeUI:LayoutSlots()
    if not self.native then return end
    for _, slot in ipairs(self.native.inv) do
        slot:Hide()
        slot:SetBGImage2(nil)
    end
    for _, info in ipairs(LAYOUTS[self.mode]) do
        local slot = self.native.inv[info.slot]
        slot:Show()
        slot:SetPosition(info.x, -132)
        slot:SetHoverText(info.hint, { font = Font(), font_size = 18 * FONT_SCALE })
        slot.bgimage:SetTexture(SKIN, "slot.tex")
        slot.bgimage:SetSize(90, 88)
        slot.bgimage:SetTint(1, 1, 1, 1)
        if info.prefab then
            local atlas, image = FixedIcon(info.prefab)
            slot:SetBGImage2(atlas, image, { 1, 1, 1, .36 })
            slot.bgimage2:SetSize(60, 60)
            slot.bgimage2:SetClickable(false)
        end
    end
    self:RefreshGhosts()
end

function ForgeUI:RefreshGhosts()
    if not self.native then return end
    for _, info in ipairs(LAYOUTS[self.mode]) do
        local ghost = self.native.inv[info.slot].bgimage2
        if ghost then
            if self:GetItem(info.slot) then ghost:Hide() else ghost:Show() end
        end
    end
end

function ForgeUI:RequestMode(mode)
    if not Rules.MODES[mode] or mode == self.mode or self.pending then return end
    self.pending, self.pending_since = mode, GetTime()
    SendModRPCToServer(MOD_RPC.hh_rpc.hh_handle_equip, "ForgeTab", mode)
    self:Refresh()
end

function ForgeUI:ToggleEffect(index)
    if self.mode ~= "cleanse" or not self.effects[index] then return end
    self.selected[index] = not self.selected[index]
    self:Refresh()
end

function ForgeUI:RefreshPreview(item)
    local inv = item and item.replica and item.replica.inventoryitem
    if inv then
        self.preview_icon:SetTexture(inv:GetAtlas(), inv:GetImage())
        self.preview_icon:Show()
        self.preview_empty:Hide()
    else
        self.preview_icon:Hide()
        self.preview_empty:Show()
    end
end

function ForgeUI:Refresh()
    local mode = Rules.GetMode(self.container)
    if mode ~= self.mode then
        self.mode, self.selected, self.effects, self.page = mode, {}, {}, 1
        self:BuildBody()
    end
    if self.pending and (self.pending == mode or GetTime() - self.pending_since > 3) then self.pending = nil end
    local state = Utils:GetClientValue(self.owner, "ttk_forge_state") or {}
    if self.pending_action and state.revision ~= self.pending_action then self.pending_action = nil end
    local message, ready = "Đặt vật phẩm vào các ô bên dưới", false
    for _, tab in ipairs(TABS) do
        local active = tab.id == mode
        if self.tabs[tab.id]._active_skin ~= active then
            self.tabs[tab.id]:SetTextures(SKIN, active and "tab_active.tex" or "tab_idle.tex")
            self.tabs[tab.id]._active_skin = active
        end
        self.tabs[tab.id]:SetTextColour(unpack(active and DARK or WHITE))
        if self.pending then self.tabs[tab.id]:Disable() else self.tabs[tab.id]:Enable() end
        if active then self.action:SetText(tab.action) end
    end
    for _, info in ipairs(LAYOUTS[mode]) do
        local amount = Count(self:GetItem(info.slot))
        self.slot_counts[info.slot]:SetString(info.count and (amount .. " / " .. info.count) or (amount > 0 and "Đã đặt" or "Đặt trang bị"))
        self.slot_counts[info.slot]:SetColour(unpack(info.count and amount < info.count and WARN or MUTED))
    end
    if mode == "cleanse" then
        local item = self:GetItem(1)
        local effects = item and state.mode == mode and state.clean_id == ItemID(item) and state.clean_effects or {}
        local signature = tostring(item and item.GUID or 0)
        for _, effect in ipairs(effects) do signature = signature .. ":" .. tostring(effect.name) .. "=" .. tostring(effect.value) end
        if signature ~= self.effect_signature then self.selected, self.page, self.effect_signature = {}, 1, signature end
        self.effects = effects
        local chosen = 0
        for i in ipairs(effects) do if self.selected[i] then chosen = chosen + 1 end end
        local items = Utils:GetClientValue(self.owner, "hh_items") or {}
        local balance = 0
        -- hh_items is the filtered {id, num} list also used by the equipment UI.
        for _, entry in ipairs(items) do
            if entry.id == "ad_cleanStone" then balance = tonumber(entry.num) or 0; break end
        end
        self.currency_count:SetString(balance .. " Bùa Tẩy")
        self.currency_icon:SetTint(1, 1, 1, balance > 0 and 1 or .28)
        self.cost_text:SetString("Đã chọn " .. chosen .. " dòng\nTiêu hao: " .. chosen .. " Bùa Tẩy")
        self.info_text:SetString(#effects == 0 and "Chưa có dòng thuộc tính" or "")
        for row, button in ipairs(self.effect_buttons) do
            local index = (self.page - 1) * EFFECTS_PER_PAGE + row
            local effect = effects[index]
            if effect then
                button:Show()
                button:SetText(EffectText(effect))
                button.text:SetTruncatedString(EffectText(effect), 151, nil, true)
                local text_width = button.text:GetRegionSize()
                button.text:SetPosition(-68 + text_width / 2, 0)
                if self.selected[index] then button.emptycheck:Hide() else button.emptycheck:Show() end
                local cfg = Effects[effect.name] or {}
                local ok, desc = pcall(string.format, cfg.desc or cfg.name or effect.name, effect.value)
                button:SetHoverText(ok and desc or EffectText(effect), { font = Font(), font_size = 18 * FONT_SCALE })
                button:SetImageNormalColour(1, 1, 1, self.selected[index] and 1 or 0)
                button:SetImageFocusColour(1, 1, 1, self.selected[index] and 1 or 0)
            else button:Hide() end
        end
        if #effects > EFFECTS_PER_PAGE then
            self.previous:Show(); self.next:Show(); self.page_text:SetString(self.page .. " / " .. math.ceil(#effects / EFFECTS_PER_PAGE))
        else self.previous:Hide(); self.next:Hide(); self.page_text:SetString("") end
        self:RefreshPreview(item)
        self.preview_note:SetString(item and ("Giữ lại " .. (#effects - chosen) .. " dòng thuộc tính") or "Chưa đặt trang bị")
        self.preview_detail:SetString("Xem trước · giữ nguyên trang bị")
        ready = item ~= nil and chosen > 0 and balance >= chosen
        if not item then message = "Đặt trang bị cần thanh tẩy vào ô bên dưới"
        elseif #effects == 0 then message = "Trang bị chưa có dòng để thanh tẩy"
        elseif chosen == 0 then message = "Chọn dòng muốn xóa ở bên phải"
        elseif balance < chosen then message = "Chưa đủ Bùa Tẩy trong số dư nhân vật"
        else message = "Sẵn sàng thanh tẩy " .. chosen .. " dòng đã chọn" end
    elseif mode == "stone_change" then
        local stone = self:GetItem(2)
        local common = stone and state.mode == mode and state.stone_id == ItemID(stone) and state.stone_common
        self:RefreshPreview(nil)
        self.preview_note:SetString("Đá Thuộc Tính ngẫu nhiên")
        self.preview_detail:SetString("Kết quả được xác định khi đúc")
        ready = common == true and Count(self:GetItem(3)) >= 5
        if not stone then message = "Đặt Đá Thuộc Tính thường và 5 Linh Thạch"
        elseif state.stone_id ~= ItemID(stone) then message = "Đang kiểm tra Đá Thuộc Tính…"
        elseif not common then message = "Đá này không phải đá thường; hãy lấy ra"
        elseif not ready then message = "Cần đủ 5 Linh Thạch trong ô nguyên liệu"
        else message = "Sẵn sàng · tiêu hao 1 đá và 5 Linh Thạch" end
    else
        local source, target = self:GetItem(2), self:GetItem(3)
        local synced = source and target and state.mode == mode and state.source_id == ItemID(source) and state.target_id == ItemID(target)
        self:RefreshPreview(target)
        self.preview_note:SetString(target and "Trang bị B sau kế thừa" or "Đặt trang bị nhận vào ô B")
        self.preview_detail:SetString("Xem trước · nhận thuộc tính và châu báu từ A")
        ready = synced and (state.source_effects or 0) > 0 and state.target_effects == 0
            and Count(self:GetItem(4)) >= 20 and Count(self:GetItem(5)) >= 20
        if not source or not target then message = "Đặt trang bị nguồn A và trang bị nhận B"
        elseif not synced then message = "Đang kiểm tra hai trang bị…"
        elseif (state.source_effects or 0) == 0 then message = "Trang bị A phải có dòng thuộc tính"
        elseif state.target_effects ~= 0 then message = "Trang bị B phải chưa có dòng thuộc tính"
        elseif not ready then message = "Cần 20 Linh Thạch và 20 Nhiên Liệu Ác Mộng"
        else message = "Sẵn sàng · trang bị A sẽ bị tiêu hao" end
    end
    if self.pending then message, ready = "Đang đổi tab và trả vật phẩm về túi…", false end
    if self.pending_action then message, ready = "Đang chờ kết quả từ máy chủ…", false end
    if state.revision == nil then ready = false end
    self.ready = ready == true
    if self.ready then self.action:Enable() else self.action:Disable() end
    self.status:SetString(message)
    self.status:SetColour(unpack(self.ready and WHITE or MUTED))
    self:RefreshGhosts()
end

function ForgeUI:Submit()
    self:Refresh()
    if not self.ready then return end
    local revision = (Utils:GetClientValue(self.owner, "ttk_forge_state") or {}).revision
    self.pending_action = revision
    if self.mode == "cleanse" then
        -- Keep a dense array for the existing RPC serializer.
        local choice = {}
        for i in ipairs(self.effects) do choice[i] = self.selected[i] == true end
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_handle_equip, "CleanEffect", Utils:TableToStr(choice), revision)
    else
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_handle_equip,
            self.mode == "stone_change" and "ReplaceStone" or "EquipInherit", nil, revision)
    end
    self:Refresh()
end

function ForgeUI:OnUpdate(dt)
    self.elapsed = self.elapsed + dt
    if self.elapsed >= .15 then self.elapsed = 0; self:Refresh() end
end

return ForgeUI
