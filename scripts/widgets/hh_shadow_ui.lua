local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ShadowProgressionDefs = require "enums/hh_shadow_progression_defs"
local ShopDefs = require "dungeon_shop/hh_dungeon_shop_defs"

local UTILITY_EFFECT_BY_USE_ID = {
    dq_pickup_charm = "utility_pickup",
    dq_cold_kit = "utility_warm",
    dq_heat_kit = "utility_cool",
    dq_work_charm = "utility_work",
    dq_dungeon_light = "utility_light",
    dq_durability_charm = "utility_durability",
}

local DURATION_EFFECT_NAMES = {}
for _, product in ipairs(ShopDefs.list or {}) do
    if (tonumber(product.duration) or 0) > 0 then
        local effect_id = product.effect_id or UTILITY_EFFECT_BY_USE_ID[product.use_id]
        if effect_id ~= nil then
            DURATION_EFFECT_NAMES[effect_id] = product.name or product.id or effect_id
        end
    end
end

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

local HHShadowUI = Class(Widget, function(self, owner)
    Widget._ctor(self, "HHShadowUI")
    self.owner = owner

    -- Background
    self.root = self:AddChild(Widget("root"))
    
    -- The parent controls widget uses the same screen-space anchors as the
    -- vanilla HUD.  Right/bottom anchoring keeps this list visible when the
    -- screen is narrower than the old fixed 2180px left offset.
    self:SetHAnchor(ANCHOR_RIGHT)
    self:SetVAnchor(ANCHOR_BOTTOM)


    -- self.title = self.root:AddChild(Text(BODYTEXTFONT, 50, "ĐỘI QUÂN BÓNG TỐI"))
    -- self.title:SetPosition(0, 60, 0)

    -- self.arise_text = self.root:AddChild(Text(BODYTEXTFONT, 40, ""))
    -- -- self.arise_text = self.root:AddChild(Text(BODYTEXTFONT, 40, "Trỗi Dậy: Sẵn sàng!"))
    -- self.arise_text:SetPosition(0, 20, 0)
    
    -- self.recall_text = self.root:AddChild(Text(BODYTEXTFONT, 40, ""))
    -- -- self.recall_text = self.root:AddChild(Text(BODYTEXTFONT, 40, "Thu Hồi (B): Không khả dụng"))
    -- self.recall_text:SetPosition(0, -10, 0)
    
    -- self.shadows_text = self.root:AddChild(Text(BODYTEXTFONT, 40, ""))
    -- -- self.shadows_text = self.root:AddChild(Text(BODYTEXTFONT, 40, "Chưa có bóng ma nào."))
    -- self.shadows_text:SetPosition(0, -40, 0)

    self.inst:ListenForEvent("hh_arise_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_shadows_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_has_shadowsdirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_shadow_profiledirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_recall_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_swap_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_sanctuary_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_godslayer_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_ruler_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_king_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_death_threshold_cddirty", function() self:Refresh() end, owner)
    self.inst:ListenForEvent("hh_dungeon_effectsdirty", function()
        self.duration_sync_pending = true
        self:Refresh()
    end, owner)

    self.duration_task = self.inst:DoPeriodicTask(1, function() self:RefreshDurationLines() end)
    self:Refresh()
end)

function HHShadowUI:OnDestroy()
    if self.duration_task ~= nil then
        self.duration_task:Cancel()
        self.duration_task = nil
    end
    HHShadowUI._base.OnDestroy(self)
end

function HHShadowUI:RefreshDurationLines()
    if self.duration_lines == nil then return end

    local now = GetTime()
    local expired = false
    for effect_id, line in pairs(self.duration_lines) do
        local remaining = math.ceil((self.duration_expiry[effect_id] or now) - now)
        if remaining <= 0 then
            expired = true
        else
            line.suffix:SetString(" còn " .. tostring(remaining) .. "s")
        end
    end
    if expired then self:Refresh() end
end

function HHShadowUI:Refresh()
    if not self.owner then return end

    local previous_duration_expiry = self.duration_expiry or {}
    local sync_durations = self.duration_sync_pending == true
    self.duration_sync_pending = nil
    local now = GetTime()
    
    -- Xoá toàn bộ các widget cũ
    if self.shadow_lines then
        for _, line in ipairs(self.shadow_lines) do
            line:Kill()
        end
    end
    self.shadow_lines = {}
    self.duration_lines = {}
    self.duration_expiry = {}
    
    -- Danh sách tên đệ tử hiển thị cầu vồng
    local rainbow_names = {
        ["Igris"] = true,
        ["Beru"] = true,
        -- sau này có thể thêm các tên đệ tử bóng tối khác vào đây
    }

    local active_cds = {}

    -- 1. Kỹ năng Trỗi Dậy
    if self.owner.hh_arise_cd then
        local cd = self.owner.hh_arise_cd:value()
        if cd > 0 then
            table.insert(active_cds, { name = "Kỹ năng Trỗi Dậy", suffix = " hồi lại sau " .. tostring(cd) .. "s" })
        end
    end

    -- 2. Kỹ năng Thu Hồi
    if self.owner.hh_recall_cd then
        local cd = self.owner.hh_recall_cd:value()
        if cd > 0 then
            table.insert(active_cds, { name = "Kỹ năng Thu Hồi", suffix = " hồi lại sau " .. tostring(cd) .. "s" })
        end
    end

    -- 2.6 Kỹ năng Hoán Đổi
    if self.owner.hh_swap_cd then
        local cd = self.owner.hh_swap_cd:value()
        if cd > 0 then
            table.insert(active_cds, { name = "Kỹ năng Hoán Đổi", suffix = " hồi lại sau " .. tostring(cd) .. "s" })
        end
    end

    -- 2.7 Kỹ năng Thánh Vực Hồi Phục
    if self.owner.hh_sanctuary_cd then
        local cd = self.owner.hh_sanctuary_cd:value()
        if cd > 0 then
            table.insert(active_cds, {
                name = "" .. STRINGS.HH_SANCTUARY.NAME,
                suffix = " hồi lại sau " .. tostring(cd) .. "s",
            })
        end
    end

    -- 2.8 Kỹ năng Diệt Thần
    if self.owner.hh_godslayer_cd then
        local cd = self.owner.hh_godslayer_cd:value()
        if cd > 0 then
            table.insert(active_cds, {
                name = "" .. STRINGS.HH_GODSLAYER.NAME,
                suffix = " hồi lại sau " .. tostring(cd) .. "s",
            })
        end
    end

    -- 2.9 Kỹ năng Kẻ Thống Trị
    if self.owner.hh_ruler_cd then
        local cd = self.owner.hh_ruler_cd:value()
        if cd > 0 then
            table.insert(active_cds, {
                name = "" .. STRINGS.HH_RULER.NAME,
                suffix = " hồi lại sau " .. tostring(cd) .. "s",
            })
        end
    end

    -- 2.10 Kỹ năng Nhà Vua
    if self.owner.hh_king_cd then
        local cd = self.owner.hh_king_cd:value()
        if cd > 0 then
            table.insert(active_cds, {
                name = "" .. STRINGS.HH_KING.NAME,
                suffix = " hồi lại sau " .. tostring(cd) .. "s",
            })
        end
    end

    -- 2.11 Nội tại Ngưỡng Sinh Tử
    if self.owner.hh_death_threshold_cd then
        local cd = self.owner.hh_death_threshold_cd:value()
        if cd > 0 then
            table.insert(active_cds, {
                name = "" .. STRINGS.HH_DEATH_THRESHOLD.NAME,
                suffix = " hồi lại sau " .. tostring(cd) .. "s",
            })
        end
    end

    -- 3. Các Đệ tử Bóng tối
    if self.owner.hh_shadows_cd then
        local str = self.owner.hh_shadows_cd:value()
        if str and str ~= "" then
            for chunk in string.gmatch(str, "([^|]+)") do
                local parts = {}
                for p in string.gmatch(chunk, "([^:]+)") do
                    table.insert(parts, p)
                end
                if #parts == 2 then
                    local prefab = parts[1]
                    local cd = tonumber(parts[2]) or 0
                    local name = STRINGS.NAMES[string.upper(prefab)] or prefab
                    local level_field = ShadowProgressionDefs.GetNetField(prefab, "level")
                    local level_netvar = level_field ~= nil and self.owner[level_field] or nil
                    local level = level_netvar ~= nil and level_netvar:value() or 0
                    if level > 0 then
                        name = name .. " [Lv." .. tostring(level) .. "]"
                    end
                    if cd > 0 then
                        table.insert(active_cds, { name = name, suffix = " phục hồi sau " .. tostring(cd) .. "s" })
                    end
                end
            end
        end
    end

    -- 4. Thời gian hiệu lực của thuốc/vật phẩm Dungeon
    if self.owner.hh_dungeon_effects_client then
        local str = self.owner.hh_dungeon_effects_client:value()
        if str and str ~= "" then
            for chunk in string.gmatch(str, "([^|]+)") do
                local effect_id, remaining = string.match(chunk, "^([^:]+):(%d+)$")
                local name = effect_id ~= nil and DURATION_EFFECT_NAMES[effect_id] or nil
                remaining = tonumber(remaining) or 0
                if name ~= nil and remaining > 0 then
                    local expiry = previous_duration_expiry[effect_id]
                    if sync_durations or expiry == nil then
                        expiry = now + remaining
                    end
                    if expiry > now then
                        local remaining_now = math.ceil(expiry - now)
                        table.insert(active_cds, {
                            name = name,
                            suffix = " còn " .. tostring(remaining_now) .. "s",
                            duration_id = effect_id,
                            duration_seconds = remaining_now,
                        })
                    end
                end
            end
        end
    end

    -- 5. Render danh sách động
    local total_lines = #active_cds
    for i, data in ipairs(active_cds) do
        local line_widget = self.root:AddChild(Widget("cd_line_" .. i))
        table.insert(self.shadow_lines, line_widget)
        
        local text_size = data.duration_id ~= nil and 30 or 40
        local name_text = line_widget:AddChild(Text(BODYTEXTFONT, text_size, data.name))
        
        -- Xử lý màu sắc
        if rainbow_names[data.name] then
            local init_hue = (GetTime() * 0.2) % 1
            local ir, ig, ib = HSVToRGB(init_hue, 1, 1)
            name_text:SetColour(ir, ig, ib, 1)
            
            name_text.inst:DoPeriodicTask(0, function()
                local hue = (GetTime() * 0.2) % 1
                local r, g, b = HSVToRGB(hue, 1, 1)
                name_text:SetColour(r, g, b, 1)
            end)
        elseif data.duration_id ~= nil then
            name_text:SetColour(.55, .82, 1, 1)
        else
            name_text:SetColour(1, 1, 1, 1)
        end
        
        local w1, _ = name_text:GetRegionSize()
        
        local cd_text = line_widget:AddChild(Text(BODYTEXTFONT, text_size, data.suffix))
        cd_text:SetColour(1, 1, 1, 1)
        local w2, _ = cd_text:GetRegionSize()
        
        -- Căn giữa nguyên câu
        name_text:SetPosition(-w2/2, 0, 0)
        cd_text:SetPosition(w1/2, 0, 0)
        
        -- Tọa độ Y: Cố định dòng cuối cùng tại Y = -40, các dòng xếp chồng lên trên cách nhau 45 pixel.
        -- Khi một dòng biến mất, danh sách tự động tính lại tổng số dòng và tụt các dòng trên xuống.
        local index_from_bottom = total_lines - i
        line_widget:SetPosition(0, -40 + (index_from_bottom * 45), 0)

        if data.duration_id ~= nil then
            self.duration_lines = self.duration_lines or {}
            self.duration_expiry = self.duration_expiry or {}
            self.duration_lines[data.duration_id] = { suffix = cd_text }
            self.duration_expiry[data.duration_id] = now + data.duration_seconds
        end
    end
end

return HHShadowUI
