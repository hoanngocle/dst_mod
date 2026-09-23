local Screen = require('widgets/screen')
local Image = require('widgets/image')
local Text = require('widgets/text')
local TextButton = require('widgets/textbutton')
local Widget = require('widgets/widget')
local ShadowDefs = require('enums/hh_shadow_progression_defs')
local ShadowUpgradeLayout = require('shadow_upgrade/hh_shadow_upgrade_layout')
local Theme = require('widgets/hh_ui/ttk_unified_theme')
local UIFONT = Theme.GetFont()
local TITLEFONT = Theme.GetFont()
local NUMBERFONT = Theme.GetFont()

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

local function GetNetValue(owner, prefab, field, default)
    local net_name = ShadowDefs.GetNetField(prefab, field)
    local netvar = owner ~= nil and net_name ~= nil and owner[net_name] or nil
    return netvar ~= nil and netvar:value() or default
end

local function ApplyTextLayout(widget, config)
    config = config or {}
    widget:SetPosition(config.x or 0, config.y or 0, 0)
    widget:SetFont(config.font or UIFONT)
    widget:SetSize(config.size or 18)
    widget:SetRegionSize(config.width or 100, config.height or 30)
    widget:EnableWordWrap(true)
    widget:SetHAlign(config.halign or ANCHOR_LEFT)
    if config.colour ~= nil then
        widget:SetColour(unpack(config.colour))
    end
end

local function ApplyButtonLayout(button, config)
    config = config or {}
    button:SetPosition(config.x or 0, config.y or 0, 0)
    button:SetFont(config.font or UIFONT)
    button:SetTextSize(config.size or 18)
    button:SetTextColour(.82, .88, 1, 1)
    button:SetTextFocusColour(.35, .85, 1, 1)
    button:SetTextDisabledColour(.40, .45, .55, 1)
    button.text:SetRegionSize(config.width or 100, config.height or 30)
    button.text:EnableWordWrap(true)
    button.text:SetHAlign(config.halign or ANCHOR_MIDDLE)
end

local function ApplyIconLayout(icon, config)
    config = config or {}
    icon:SetPosition(config.x or 0, config.y or 0, 0)
    icon:SetSize(config.size or 52, config.size or 52)
    icon:SetScale(config.scale or 1, config.scale or 1, 1)
    if config.atlas ~= nil and config.tex ~= nil then
        icon:SetTexture(config.atlas, config.tex)
    end
end

local function ApplyTalentRowLayout(row, config)
    config = config or {}
    ApplyIconLayout(row.icon, config.icon)
    ApplyTextLayout(row.level_text, config.level)
    ApplyTextLayout(row.name_text, config.name)
    ApplyTextLayout(row.status_text, config.status)
    ApplyTextLayout(row.desc_text, config.desc)
    row:SetPosition(config.row and config.row.x or 0, config.row and config.row.y or 0, 0)
end

local HHShadowUpgradeScreen = Class(Screen, function(self, owner, options)
    Screen._ctor(self, 'HHShadowUpgradeScreen')
    options = options or {}
    self.owner = owner
    self.embedded = options.embedded == true
    self.selected_prefab = ShadowDefs.ORDER[1]
    self.disciple_buttons = {}
    self.talent_rows = {}

    for _, prefab in ipairs(ShadowDefs.ORDER) do
        if GetNetValue(owner, prefab, 'level', 0) > 0 then
            self.selected_prefab = prefab
            break
        end
    end

    self.root = self:AddChild(Widget('shadow_upgrade_root'))
    if not self.embedded then
        self.root:SetVAnchor(ANCHOR_MIDDLE)
        self.root:SetHAnchor(ANCHOR_MIDDLE)
        self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    end
    self.scaler = self.root:AddChild(Widget("scaler"))
    self.scaler:SetScale(self.embedded and 1 or .7)

    local panel_atlas = self.embedded and 'images/ttk_forge/frame.xml' or 'images/hud_nang_cap_quan_doan.xml'
    local panel_texture = self.embedded and 'frame.tex' or 'hud_nang_cap_quan_doan.tex'
    self.panel = self.scaler:AddChild(Image(panel_atlas, panel_texture))
    self.panel:SetSize(1180, 700)
    if self.embedded then self.panel:SetTint(unpack(Theme.colours.panel)) end

    self.title = self.scaler:AddChild(Text(TITLEFONT, 48, 'QUÂN ĐOÀN'))
    ApplyTextLayout(self.title, ShadowUpgradeLayout.hud.title)

    self.close_button = self.scaler:AddChild(TextButton())
    ApplyButtonLayout(self.close_button, ShadowUpgradeLayout.hud.close)
    self.close_button:SetText('Đóng')
    self.close_button:SetOnClick(function()
        if self.embedded then
            if options.close ~= nil then options.close() end
        else
            TheFrontEnd:PopScreen(self)
        end
    end)
    if self.embedded then self.close_button:Hide() end

    for _, prefab in ipairs(ShadowDefs.ORDER) do
        local selected_prefab = prefab
        local button = self.scaler:AddChild(TextButton())
        ApplyButtonLayout(button, ShadowUpgradeLayout.hud.tabs[prefab])
        button:SetOnClick(function()
            self.selected_prefab = selected_prefab
            self:Refresh()
        end)
        self.disciple_buttons[prefab] = button
    end

    self.name_text = self.scaler:AddChild(Text(TITLEFONT, 38, ''))
    self.role_text = self.scaler:AddChild(Text(UIFONT, 24, ''))
    self.level_text = self.scaler:AddChild(Text(UIFONT, 30, ''))
    self.exp_text = self.scaler:AddChild(Text(UIFONT, 25, ''))
    self.progress_text = self.scaler:AddChild(Text(UIFONT, 24, ''))
    self.stats_text = self.scaler:AddChild(Text(UIFONT, 22, ''))

    for index = 1, 6 do
        local row = self.scaler:AddChild(Widget(string.format('talent_row_%d', index)))
        row.icon = row:AddChild(Image('images/prayer_symbol.xml', 'prayer_symbol.tex'))
        row.level_text = row:AddChild(Text(NUMBERFONT, 16, ''))
        row.name_text = row:AddChild(Text(UIFONT, 18, ''))
        row.status_text = row:AddChild(Text(UIFONT, 15, ''))
        row.desc_text = row:AddChild(Text(UIFONT, 15, ''))
        self.talent_rows[index] = row
    end

    self.inst:ListenForEvent('hh_shadow_profiledirty', function()
        self:Refresh()
    end, owner)
    self.inst:ListenForEvent('hh_shadows_cddirty', function()
        self:Refresh()
    end, owner)

    self.default_focus = self.disciple_buttons[self.selected_prefab] or self.close_button
    self:Refresh()
end)

function HHShadowUpgradeScreen:Refresh()
    if self.owner == nil then return end

    for _, prefab in ipairs(ShadowDefs.ORDER) do
        local def = ShadowDefs.Get(prefab)
        local level = GetNetValue(self.owner, prefab, 'level', 0)
        local button = self.disciple_buttons[prefab]
        local label = level > 0
            and string.format('%s  Lv.%d', def.name, level)
            or string.format('%s  [%s]', def.name, 'Khóa')
        button:SetText(label)
        if prefab == self.selected_prefab then
            button:SetTextColour(unpack(Theme.colours.purple_soft))
        else
            button:SetTextColour(unpack(Theme.colours.silver))
        end
    end

    local prefab = self.selected_prefab
    local def = ShadowDefs.Get(prefab)
    local layout = ShadowUpgradeLayout[prefab]
    if def == nil or layout == nil then return end

    ApplyTextLayout(self.name_text, layout.profile.name)
    ApplyTextLayout(self.role_text, layout.profile.role)
    ApplyTextLayout(self.level_text, layout.profile.level)
    ApplyTextLayout(self.exp_text, layout.profile.exp)
    ApplyTextLayout(self.progress_text, layout.profile.progress)
    ApplyTextLayout(self.stats_text, layout.profile.stats)

    local level = GetNetValue(self.owner, prefab, 'level', 0)
    local exp = GetNetValue(self.owner, prefab, 'exp', 0)
    local talents = GetNetValue(self.owner, prefab, 'talents', 0)
    local owned = level > 0
    local display_level = owned and level or 1

    self.name_text:SetString(owned and def.name or string.format('%s — Chưa sở hữu', def.name))

    if self.star_widgets then
        for _, star in ipairs(self.star_widgets) do
            star:Kill()
        end
    end
    self.star_widgets = {}

    if owned then
        local num_stars = math.floor(level / 5)
        if num_stars > 0 then
            local dummy = Text(TITLEFONT, 38, def.name)
            local name_w = dummy:GetRegionSize()
            dummy:Kill()
            local dummy_star = Text(TITLEFONT, 38, "★")
            local star_w = dummy_star:GetRegionSize()
            dummy_star:Kill()

            local start_x = layout.profile.name.x - layout.profile.name.width / 2 + name_w + 15 + star_w / 2
            for i = 1, num_stars do
                local star_container = self.scaler:AddChild(Widget("star_container"))
                star_container:SetPosition(start_x, layout.profile.name.y, 0)
                
                local offsets = { {-2, 0}, {2, 0}, {0, -2}, {0, 2}, {-1.5, -1.5}, {1.5, 1.5}, {-1.5, 1.5}, {1.5, -1.5} }
                for _, offset in ipairs(offsets) do
                    local shadow = star_container:AddChild(Text(TITLEFONT, 38, "★"))
                    shadow:SetColour(0, 0, 0, 1)
                    shadow:SetPosition(offset[1], offset[2], 0)
                end

                local main_star = star_container:AddChild(Text(TITLEFONT, 38, "★"))
                main_star:SetColour(unpack(Theme.colours.purple_soft))

                table.insert(self.star_widgets, star_container)
                start_x = start_x + star_w + 10
            end
        end
    end
    self.role_text:SetString(def.role)
    self.level_text:SetString(string.format('Cấp %d / %d', owned and level or 0, ShadowDefs.GetMaxLevel()))
    if owned and level < ShadowDefs.GetMaxLevel() then
        self.exp_text:SetString(string.format('EXP: %d / %d', exp, ShadowDefs.GetExpForNextLevel(level)))
    elseif owned then
        self.exp_text:SetString('EXP: Tối đa')
    else
        self.exp_text:SetString('EXP: —')
    end
    self.progress_text:SetString(string.format('Kỹ năng đã mở: %d / %d',
        ShadowDefs.CountTalents(talents), #def.talents))
    self.stats_text:SetString(ShadowDefs.GetGrowthText(prefab, display_level, talents))

    for index, row in ipairs(self.talent_rows) do
        local talent = def.talents[index]
        local row_layout = layout.talent_rows[index]
        ApplyTalentRowLayout(row, row_layout)

        local unlocked = ShadowDefs.HasTalent(talents, index)
        local status = unlocked and 'Đã Sở Hữu' or 'Chưa sở hữu'

        row.level_text:SetString(string.format('Lv.%d', talent.level))
        row.name_text:SetString(talent.name)
        row.status_text:SetString(status)
        row.desc_text:SetString(talent.desc)

        if row.name_text.rainbow_task then
            row.name_text.rainbow_task:Cancel()
            row.name_text.rainbow_task = nil
        end

        if unlocked then
            row.status_text:SetColour(unpack(Theme.colours.purple_soft))
            row.icon:SetTint(1, 1, 1, 1)
            row.desc_text:SetColour(.72, .76, .84, 1)
            row.name_text:SetColour(unpack(Theme.colours.purple_soft))
        else
            row.status_text:SetColour(.55, .58, .65, 1)
            row.icon:SetTint(.40, .40, .45, 1)
            row.name_text:SetColour(.55, .58, .65, 1)
            row.desc_text:SetColour(.55, .58, .65, 1)
        end
    end

    if not self.intro_text then
        self.intro_text = self.scaler:AddChild(Text(UIFONT, 25, ''))
        self.intro_text:SetPosition(250, -210, 0)
        self.intro_text:SetColour(.8, .8, .8, 1)
    end
    
    local intro_strings = {
        hh_igris_shadow = "Kỵ sĩ hộ vệ trung thành. Lưỡi kiếm của Igris luôn là bức tường thành\nvững chãi bảo vệ chủ nhân.",
        hh_beru_shadow = "Vị vua của loài heo, hiện thân của sự tàn sát. Vuốt sắc của Beru sinh ra\nđể xé nát mọi con mồi hùng mạnh nhất.",
        hh_fruitfly_shadow = "Kẻ cai quản mầm sống thiên nhiên. Một đôi tay cần mẫn mang đến\nnhững vụ mùa trù phú vô tận.",
        hh_macanh_shadow = "Phân thân bóng tối thầm lặng. Nhanh nhẹn và tháo vát, thu thập tài\nnguyên và tối ưu hóa sức lao động.",
        hh_hacanh_shadow = "Cánh tay phải ẩn trong màn đêm. Lướt đi như gió, tung đòn như chớp\nluôn sẵn sàng trừng phạt kẻ địch.",
    }
    self.intro_text:SetString(intro_strings[prefab] or "")

    if not self.anim then
        local UIAnim = require('widgets/uianim')
        self.anim = self.scaler:AddChild(UIAnim())

        self.anim.inst:ListenForEvent("animqueueover", function()
            if self.selected_prefab == "hh_beru_shadow" then
                self.anim:GetAnimState():PlayAnimation("attack1", false)
                self.anim:GetAnimState():PushAnimation("attack2", false)
                self.anim:GetAnimState():PushAnimation("attack3", false)
            end
        end)
    end

    -- Cấu hình vị trí (x, y) và scale riêng cho từng đệ tử
    local anim_configs = {
        hh_igris_shadow    = { x = -330, y = -50, scale = 0.20 },
        hh_beru_shadow     = { x = -330, y = -50, scale = 0.19 },
        hh_fruitfly_shadow = { x = -330, y = -50, scale = 0.6 },
        hh_macanh_shadow   = { x = -330, y = -50, scale = 0.6 },
        hh_hacanh_shadow   = { x = -330, y = -50, scale = 0.6 },
    }
    local cfg = anim_configs[prefab] or { x = -330, y = -50, scale = 0.20 }
    self.anim:SetPosition(cfg.x, cfg.y, 0)
    self.anim:SetScale(cfg.scale, cfg.scale, cfg.scale)

    local animstate = self.anim:GetAnimState()
    animstate:ClearAllOverrideSymbols()
    animstate:SetMultColour(1, 1, 1, 1)
    self.anim:SetFacing(FACING_DOWN)

    if prefab == "hh_igris_shadow" then
        animstate:SetBank("boarrior")
        animstate:SetBuild("igris_shadow")
        animstate:PlayAnimation("idle_loop", true)
    elseif prefab == "hh_beru_shadow" then
        animstate:SetBank("beetletaur")
        animstate:SetBuild("beru_shadow")
        animstate:AddOverrideBuild("lavaarena_beetletaur_basic")
        animstate:PlayAnimation("idle_loop", true)
    elseif prefab == "hh_fruitfly_shadow" then
        animstate:SetBank("fruitfly")
        animstate:SetBuild("hh_fruitfly_shadow")
        animstate:AddOverrideBuild("fruitfly")
        animstate:PlayAnimation("idle", true)
    elseif prefab == "hh_macanh_shadow" then
        animstate:SetBank("wilson")
        animstate:SetBuild("hh_macanh_shadow")
        animstate:AddOverrideBuild("player_idles")
        animstate:Hide("ARM_carry")
        animstate:Hide("HAT")
        animstate:Hide("HAIR_HAT")
        animstate:PlayAnimation("idle_loop", true)
        animstate:SetMultColour(0, 0, 0, .5)
    elseif prefab == "hh_hacanh_shadow" then
        animstate:SetBank("wilson")
        animstate:SetBuild("hh_macanh_shadow")
        animstate:AddOverrideBuild("player_idles")
        animstate:Hide("ARM_carry")
        animstate:Hide("HAT")
        animstate:Hide("HAIR_HAT")
        animstate:PlayAnimation("idle_loop", true)
        animstate:SetMultColour(0, 0, 0, .5)
    end
end

function HHShadowUpgradeScreen:ShowPanel()
    self:Show()
    self:Refresh()
end

function HHShadowUpgradeScreen:HidePanel()
    self:Hide()
end

function HHShadowUpgradeScreen:DisposePanel()
    self:Kill()
end

function HHShadowUpgradeScreen:OnControl(control, down)
    if HHShadowUpgradeScreen._base.OnControl(self, control, down) then
        return true
    end
    if self.embedded then return false end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function HHShadowUpgradeScreen:GetHelpText()
    return string.format('%s Đóng',
        TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_CANCEL))
end

return HHShadowUpgradeScreen
