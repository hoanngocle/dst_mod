local Widget = require("widgets/widget")
local Text = require("widgets/text")
local Image = require("widgets/image")
local Theme = require("widgets/hh_ui/ttk_unified_theme")
local Primitive = require("widgets/hh_ui/ttk_artifact_primitives")

local PAGE_SIZE = 40
local COLUMNS = 8
local ROWS = 5
local TOTAL_SLOTS = 120
local SLOT_SCALE = .82
local SKIN = "images/ttk_forge/controls.xml"

local TTKStorageUI = Class(Widget, function(self, owner, container)
    Widget._ctor(self, "ttk_storage_ui")
    self.owner = owner
    self.container = container
    self.page = 1
    self.max_page = math.ceil(TOTAL_SLOTS / PAGE_SIZE)

    self.frame = Primitive.Frame(self, 0, 0, 900, 600, Theme.colours.panel)
    self.title = Primitive.Label(self, "KHO QUÂN VƯƠNG", 35, 0, 238, Theme.colours.silver)
    self.subtitle = Primitive.Label(self, "120 ô lưu trữ • giữ Alt + chuột phải để khóa", 17, 0, 197, Theme.colours.muted)
    Primitive.Divider(self, 760, 0, 171)

    self.previous = Primitive.Button(self, "‹", 54, 42, -110, -244, function() self:SetPage(self.page - 1) end)
    self.next = Primitive.Button(self, "›", 54, 42, 110, -244, function() self:SetPage(self.page + 1) end)
    self.page_text = Primitive.Label(self, "1 / 3", 20, 0, -244, Theme.colours.silver)
    self.status = Primitive.Label(self, "", 16, 0, -205, Theme.colours.muted, 760)
    self.close = Primitive.Button(self, "Đóng", 150, 42, 325, -244, function()
        SendModRPCToServer(MOD_RPC.hh_rpc.hh_monarch_storage_close)
    end)
end)

function TTKStorageUI:GetSlotPage(index)
    index = tonumber(index)
    if index == nil or index < 1 or index > TOTAL_SLOTS then return nil end
    return math.ceil(index / PAGE_SIZE)
end

function TTKStorageUI:AttachContainerWidget(native)
    self.native = native
    for index, slot in ipairs(native.inv or {}) do
        slot:SetScale(SLOT_SCALE)
        slot.base_scale, slot.highlight_scale = SLOT_SCALE, SLOT_SCALE
        slot.bgimage:SetTexture(SKIN, "slot.tex")
        slot.bgimage:SetSize(64 / SLOT_SCALE, 64 / SLOT_SCALE)
        slot:SetHoverText("Kho Quân Vương • Ô " .. tostring(index), {
            font = Theme.GetFont(), font_size = 17,
        })
    end
    self:RefreshSlots()
end

function TTKStorageUI:SetPage(page)
    self.page = math.max(1, math.min(self.max_page, tonumber(page) or 1))
    self:RefreshSlots()
end

function TTKStorageUI:RefreshSlots()
    self.page_text:SetString(string.format("%d / %d", self.page, self.max_page))
    if self.native == nil then
        self.status:SetString("Đang chờ dữ liệu kho…")
        return
    end
    local first = (self.page - 1) * PAGE_SIZE + 1
    local last = math.min(first + PAGE_SIZE - 1, #self.native.inv)
    for index, slot in ipairs(self.native.inv) do
        if index >= first and index <= last then
            local local_index = index - first
            local column = local_index % COLUMNS
            local row = math.floor(local_index / COLUMNS)
            slot:SetPosition(-259 + column * 74, 125 - row * 69)
            slot:Show()
            slot:MoveToFront()
        else
            slot:Hide()
        end
    end
    self.status:SetString(string.format("Hiển thị ô %d–%d / %d", first, last, #self.native.inv))
end

function TTKStorageUI:OnControl(control, down)
    if TTKStorageUI._base.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_PREVVALUE then self:SetPage(self.page - 1); return true end
    if not down and control == CONTROL_NEXTVALUE then self:SetPage(self.page + 1); return true end
end

return TTKStorageUI
