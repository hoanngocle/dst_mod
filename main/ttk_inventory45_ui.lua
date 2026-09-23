local G = GLOBAL
local Image = G.require("widgets/image")
local layout = G.require("ttk_inventory45_layout")
local first_top = false -- Ô đầu ở góc dưới trái.
local spacing = 15 -- Giữ khoảng cách chia nhóm.

AddClassPostConstruct("widgets/inventorybar", function(self)
    local mode = G.TheNet:GetServerGameMode()
    if mode == "lavaarena" or mode == "quagmire" then return end
    local function addslot(slot, image)
        for _, info in ipairs(self.equipslotinfo) do
            if info.slot == slot then return end
        end
        self:AddEquipSlot(slot, "images/ttk_inventory45/" .. image .. ".xml", image .. ".tex")
    end
    addslot(G.EQUIPSLOTS.BACK, "back")
    addslot(G.EQUIPSLOTS.NECK, "neck")

    local function arrange()
        local size = self.owner.replica.inventory:GetNumSlots()
        if size ~= 25 and size ~= 45 then return end
        if not self.inv or not self.inv[size] then return end
        if not self.ttk_inventory_bg then
            self.ttk_inventory_bg = self.root:AddChild(Image("images/ttk_inventory45/inventory_bg.xml", "inventory_bg.tex"))
            self.ttk_inventory_bg:SetVRegPoint(G.ANCHOR_BOTTOM)
            self.ttk_inventory_bg:MoveToBack()
        end
        self.bg:Hide(); self.bgcover:Hide()
        local hasbackpack = self.backpack ~= nil and self.integrated_backpack
        local shift = hasbackpack and 35.5 or 0
        self.toprow:SetPosition(0, 0, 0)
        self.bottomrow:SetPosition(0, -71, 0)
        for i = 1, size do
            local x, y = layout.Slot(size, i, first_top, spacing)
            self.inv[i]:SetPosition(x, y + shift, 0)
        end
        for i, info in ipairs(self.equipslotinfo) do
            local slot = self.equip[info.slot]
            if slot then
                local x, y = layout.Equipment(size, #self.equipslotinfo, i, spacing)
                slot:SetPosition(x, y + shift, 0)
                if info.slot == G.EQUIPSLOTS.HANDS then
                    self.hand_inv:SetPosition(x, y + shift, 0)
                end
            end
        end
        local columns = layout.Dimensions(size)
        local rows = math.max(1, math.ceil(#self.backpackinv / columns))
        for i, slot in ipairs(self.backpackinv) do
            local column = (i - 1) % columns
            local row = math.floor((i - 1) / columns)
            local rowcount = math.min(columns, #self.backpackinv - row * columns)
            slot:SetPosition((column - (rowcount - 1) / 2) * 71, -row * 71, 0)
        end
        self.ttk_inventory_bg:SetScale(size == 45 and 1.4425 or .89,
            hasbackpack and 1.335 + (rows - 1) * .42 or 1.13, 1)
        self.ttk_inventory_bg:SetPosition(0, -93 - (hasbackpack and (rows - 1) * 71 or 0), 0)
        self.hudcompass:SetPosition(0, 155 + shift, 0)
        if self.inspectcontrol then
            local x = layout.Slot(size, columns, false, spacing)
            self.inspectcontrol:SetPosition(x, 144 + shift, 0)
        end
        if self.openhint then self.openhint:Hide() end
        if self.medal_inv and self.hand_inv and G.EQUIPSLOTS.MEDAL then
            local slot = self.equip[G.EQUIPSLOTS.MEDAL]
            if slot then self.medal_inv:SetPosition(slot:GetPosition()) end
        end
        self:UpdateCursor()
    end
    local rebuild = self.Rebuild
    self.Rebuild = function(self, ...)
        rebuild(self, ...)
        arrange()
    end
    local refresh = self.RefreshIntegratedContainer
    if refresh then self.RefreshIntegratedContainer = function(self, ...)
        refresh(self, ...)
        arrange()
    end end
    self.rebuild_pending = true
end)
