local Screen = require("widgets/screen")
local Widget = require("widgets/widget")
local Text = require("widgets/text")
local TextButton = require("widgets/textbutton")
local Image = require("widgets/image")
local DungeonShopLayout = require("dungeon_shop/hh_dungeon_shop_layout")
local RequestGate = require("ui/ttk_request_gate")
local Theme = require("widgets/hh_ui/ttk_unified_theme")
local UIFONT = Theme.GetFont()
local TITLEFONT = Theme.GetFont()

local NONCE = 0

local PANEL_W = 1050
local PANEL_H = 700
local HUD_LAYOUT = DungeonShopLayout.hud or {}


local CATEGORY_LAYOUT = {
    { id = "player_potion", name = "Thuốc Thợ Săn" },
    { id = "disciple_potion", name = "Thuốc Đệ Tử" },
    { id = "qol", name = "Vật Phẩm" },
    { id = "weapon", name = "Vũ Khí" },
}

local function Split(value, separator)
    local result = {}
    for part in string.gmatch(value or "", "([^" .. separator .. "]+)") do
        table.insert(result, part)
    end
    return result
end

local function DecodeStock(value, defs)
    local result = {}
    for _, entry in ipairs(Split(value, ",")) do
        local index, amount = string.match(entry, "^(%d+):(%d+)$")
        local product = index ~= nil and defs.GetByIndex(index) or nil
        if product ~= nil then
            result[product.id] = tonumber(amount) or 0
        end
    end
    return result
end

local function DisplayName(product)
    if product.name then
        return product.name
    end
    local value = string.gsub(product.id or "", "^dp_", "")
    value = string.gsub(value, "^dq_", "")
    return string.gsub(value, "_", " ")
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

local function AddTextButton(parent, x, y, width, height, font_size)
    local button = parent:AddChild(TextButton())
    button:SetPosition(x, y, 0)
    button:SetFont(UIFONT)
    button:SetTextSize(font_size or 18)
    button:SetTextColour(.78, .86, 1, 1)
    button:SetTextFocusColour(.35, .8, 1, 1)
    button:SetTextDisabledColour(.35, .4, .5, 1)
    button:SetTextSelectedColour(1, .82, .2, 1)
    button.text:SetRegionSize(width, height)
    button.text:EnableWordWrap(true)
    button.clickoffset = Vector3(0, -1, 0)
    return button
end


local function ApplyTextLayout(widget, config)
    config = config or {}
    widget:SetPosition(config.x or 0, config.y or 0, 0)
    widget:SetFont(config.font or UIFONT)
    widget:SetSize(config.size or 18)
    widget:SetRegionSize(config.width or 100, config.height or 30)
    widget:EnableWordWrap(true)
    widget:SetHAlign(config.halign or ANCHOR_MIDDLE)
end

local function ApplyButtonLayout(button, config)
    config = config or {}
    button:SetPosition(config.x or 0, config.y or 0, 0)
    button:SetFont(config.font or UIFONT)
    button:SetTextSize(config.size or 17)
    button.text:SetRegionSize(config.width or 100, config.height or 30)
    button.text:EnableWordWrap(true)
end

local function ApplyTabLayout(tab, config) 
    config = config or {}
    tab:SetPosition(config.x or 0, config.y or 0, 0)
    ApplyButtonLayout(tab.button, {
        x = config.button_x or 0,
        y = config.button_y or 0,
        width = config.width or 148,
        height = config.height or 50,
        font = config.font,
        size = config.size or 17,
    })
end

local function ApplyCardLayout(card, category, index)
    local category_layout = DungeonShopLayout[category] or DungeonShopLayout.player_potion
    local config = category_layout[index] or DungeonShopLayout.player_potion[index]
    if config == nil then return end

    card:SetPosition(config.card.x or 0, config.card.y or 0, 0)
    card.icon:SetPosition(config.icon.x or 0, config.icon.y or 0, 0)
    card.icon:SetSize(config.icon.size or 72, config.icon.size or 72)
    card.icon:SetScale(config.icon.scale or 1, config.icon.scale or 1, 1)
    ApplyTextLayout(card.name, config.name)
    ApplyTextLayout(card.desc, config.desc)
    ApplyTextLayout(card.price, config.price)
    ApplyTextLayout(card.stock, config.stock)
    ApplyButtonLayout(card.buy, config.buy)
end

local HHDungeonShopScreen = Class(Screen, function(self, owner, defs, on_close, options)
    Screen._ctor(self, "HHDungeonShopScreen")
    options = options or {}
    self.owner = owner
    self.defs = defs
    self.on_close = on_close
    self.embedded = options.embedded == true
    self.request_gate = RequestGate()
    self.open_gate = RequestGate()
    self.open_request = options.open_request or function()
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_dungeon_shop_open)
    end
    self.category = "player_potion"


    self.root = self:AddChild(Widget("dungeon_shop_root"))
    if not self.embedded then
        self.root:SetVAnchor(ANCHOR_MIDDLE)
        self.root:SetHAnchor(ANCHOR_MIDDLE)
        self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    end
    self.root:SetPosition(0, 0, 0)

    local panel_atlas = self.embedded and "images/ttk_forge/frame.xml" or "images/hud_dungeon_store.xml"
    local panel_texture = self.embedded and "frame.tex" or "hud_dungeon_store.tex"
    self.panel = self.root:AddChild(Image(panel_atlas, panel_texture))
    self.panel:SetSize(PANEL_W, PANEL_H)
    if self.embedded then self.panel:SetTint(unpack(Theme.colours.panel)) end

    self.title = self.root:AddChild(Text(TITLEFONT, 44, "CỬA HÀNG HẦM NGỤC"))
    ApplyTextLayout(self.title, HUD_LAYOUT.title)
    self.title:SetColour(unpack(self.embedded and Theme.colours.purple_soft or { .55, .78, 1, 1 }))

    self.coins = AddText(self.root, 316, 276, 294, 42, 28, { 1, .84, .25, 1 })
    ApplyTextLayout(self.coins, HUD_LAYOUT.coins)
    self.cycle = AddText(self.root, -231, 276, 320, 36, 18, { .65, .75, .85, 1 }, ANCHOR_LEFT)
    ApplyTextLayout(self.cycle, HUD_LAYOUT.cycle)

    self.category_buttons = {}
    for index, entry in ipairs(CATEGORY_LAYOUT) do
        local tab = self.root:AddChild(Widget("dungeon_shop_tab_" .. tostring(index)))
        tab.button = AddTextButton(tab, 0, 0, 148, 50, 17)
        local tab_layout = self.embedded
            and { x = -285 + (index - 1) * 190, y = 210, width = 180, height = 50, font = UIFONT, size = 18 }
            or HUD_LAYOUT[entry.id]
            or { x = -438, y = 190 - (index - 1) * 78, width = 148, height = 50, font = UIFONT, size = 17 }
        ApplyTabLayout(tab, tab_layout)
        tab.button:SetText(entry.name)
        local category_id = entry.id
        tab.category_id = category_id
        tab.button:SetOnClick(function()
            self.category = category_id
            self:Refresh()
        end)
        table.insert(self.category_buttons, tab)
    end

    self.cards = {}
    for index = 1, 10 do
        local card_index = index
        local layout = DungeonShopLayout.player_potion[index]
        local card = self.root:AddChild(Widget("dungeon_shop_card_" .. tostring(index)))
        card:SetPosition(layout.card.x, layout.card.y, 0)

        card.icon = card:AddChild(Image("images/inventoryimages.xml", "healingsalve.tex"))
        card.icon:SetPosition(layout.icon.x, layout.icon.y, 0)
        card.icon:SetSize(layout.icon.size, layout.icon.size)
        card.icon:SetScale(layout.icon.scale, layout.icon.scale, 1)
        card.name = AddText(card, layout.name.x, layout.name.y, layout.name.width, layout.name.height, layout.name.size, { .92, .92, .98, 1 }, layout.name.halign)
        card.desc = AddText(card, layout.desc.x, layout.desc.y, layout.desc.width, layout.desc.height, layout.desc.size, { .68, .73, .82, 1 }, layout.desc.halign)
        card.price = AddText(card, layout.price.x, layout.price.y, layout.price.width, layout.price.height, layout.price.size, { 1, .84, .25, 1 }, layout.price.halign)
        card.stock = AddText(card, layout.stock.x, layout.stock.y, layout.stock.width, layout.stock.height, layout.stock.size, { .72, .86, .92, 1 }, layout.stock.halign)
        card.buy = AddTextButton(card, layout.buy.x, layout.buy.y, layout.buy.width, layout.buy.height, layout.buy.size)
        card.buy:SetText("Mua")
        card._product = nil
        self.cards[card_index] = card
    end

    self.empty = AddText(self.root, 107, -30, 641, 80, 25, { .65, .72, .82, 1 })
    self.empty:SetString("Không có sản phẩm trong chu kỳ này.")
    self.empty:Hide()

    self.notice = AddText(self.root, 0, -313, 650, 34, 19, { .45, .85, 1, 1 })
    ApplyTextLayout(self.notice, HUD_LAYOUT.notice)
    self.close = AddTextButton(self.root, 445, -313, 89, 38, 20)
    ApplyButtonLayout(self.close, HUD_LAYOUT.close)
    self.close:SetText("Đóng")
    self.close:SetOnClick(function()
        if self.embedded then
            if options.close ~= nil then options.close() end
        else
            TheFrontEnd:PopScreen(self)
        end
    end)
    if self.embedded then self.close:Hide() end

    local function OnShopDirty()
        self.request_gate:Acknowledge()
        self.open_gate:Acknowledge()
        if self.shown then self:Refresh() end
    end
    self.inst:ListenForEvent("hh_dungeon_coindirty", OnShopDirty, owner)
    self.inst:ListenForEvent("hh_dungeon_coin_noticedirty", OnShopDirty, owner)
    self.inst:ListenForEvent("hh_dungeon_shopdirty", OnShopDirty, owner)
    self:Refresh()
end)

function HHDungeonShopScreen:OnDestroy()
    self.request_gate:Dispose()
    self.open_gate:Dispose()
    if self.on_close ~= nil then
        local callback = self.on_close
        self.on_close = nil
        callback()
    end
    HHDungeonShopScreen._base.OnDestroy(self)
end

function HHDungeonShopScreen:ShowPanel()
    self:Show()
    self.open_gate:Try(self.open_request)
    self:Refresh()
end

function HHDungeonShopScreen:HidePanel()
    self.open_gate:Acknowledge()
    self:Hide()
end

function HHDungeonShopScreen:DisposePanel()
    self:Kill()
end

function HHDungeonShopScreen:Refresh()
    if self.owner == nil then return end

    local balance = self.owner.hh_dungeon_coins and self.owner.hh_dungeon_coins:value() or 0
    self.coins:SetString("Số Xu: " .. tostring(balance))

    local cycle = self.owner.hh_dungeon_shop_cycle_client
        and self.owner.hh_dungeon_shop_cycle_client:value() or 0
    self.cycle:SetString("Stock luân phiên • Chu kỳ " .. tostring(cycle))

    local notice = self.owner.hh_dungeon_coin_notice
        and self.owner.hh_dungeon_coin_notice:value() or ""
    self.notice:SetString(notice)

    for _, tab in ipairs(self.category_buttons) do
        if tab.category_id == self.category then
            tab.button:SetTextColour(1, .85, .25, 1)
        else
            tab.button:SetTextColour(.72, .80, .92, 1)
        end
    end

    local active = {}
    local encoded_products = self.owner.hh_dungeon_shop_products_client
        and self.owner.hh_dungeon_shop_products_client:value() or ""
    for _, encoded_index in ipairs(Split(encoded_products, ",")) do
        local product = self.defs.GetByIndex(encoded_index)
        if product ~= nil and product.category == self.category then
            table.insert(active, product)
        end
    end

    local stock = DecodeStock(
        self.owner.hh_dungeon_shop_stock_client
            and self.owner.hh_dungeon_shop_stock_client:value() or "",
        self.defs
    )
    if #active == 0 then self.empty:Show() else self.empty:Hide() end

    for index, card in ipairs(self.cards) do
        ApplyCardLayout(card, self.category, index)
        local product = active[index]
        card._product = product
        if product ~= nil then
            card:Show()
            local icon_name = product.shop_icon or product.icon or product.prefab or "healingsalve"
            local icon_atlas = product.shop_atlas or product.atlas or GetInventoryItemAtlas(icon_name)
            card.icon:SetTexture(icon_atlas, icon_name .. ".tex")
            card.name:SetString(DisplayName(product))
            card.desc:SetString(product.desc or "")
            local amount = math.max(0, tonumber(stock[product.id] or product.stock or 0) or 0)
            local affordable = balance >= (tonumber(product.price) or 0)
            card.price:SetString(string.format("%d Xu", product.price or 0))
            card.stock:SetString("Stock " .. tostring(amount))
            card.stock:SetColour(amount > 0 and .72 or 1, amount > 0 and .86 or .28, amount > 0 and .92 or .28, 1)

            local pending = self.request_gate:IsPending()
            if pending then
                card.buy:SetText("Đang mua…")
                card.buy:SetTextColour(unpack(Theme.colours.muted))
            elseif amount <= 0 then
                card.buy:SetText("Hết")
                card.buy:SetTextColour(.55, .35, .35, 1)
            elseif not affordable then
                card.buy:SetText("Thiếu xu")
                card.buy:SetTextColour(.85, .45, .35, 1)
            else
                card.buy:SetText("Mua")
                card.buy:SetTextColour(.78, .86, 1, 1)
            end

            card.buy:SetOnClick(function()
                if amount > 0 and affordable then
                    self.request_gate:Try(function()
                        NONCE = NONCE + 1
                        SendModRPCToServer(MOD_RPC.hh_rpc.hh_dungeon_shop_buy, product.id, NONCE)
                    end)
                    self:Refresh()
                end
            end)
        else
            card:Hide()
        end
    end
end

function HHDungeonShopScreen:OnControl(control, down)
    if HHDungeonShopScreen._base.OnControl(self, control, down) then return true end
    if self.embedded then return false end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

return HHDungeonShopScreen
