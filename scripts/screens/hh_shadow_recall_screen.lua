local Screen = require('widgets/screen')
local Image = require('widgets/image')
local Text = require('widgets/text')
local Widget = require('widgets/widget')
local Menu = require('widgets/menu')
local ShadowDefs = require('enums/hh_shadow_progression_defs')

local function GetEntries(owner)
    local entries = {}
    local netvar = owner ~= nil and owner.hh_shadows_cd or nil
    local encoded = netvar ~= nil and netvar:value() or ''
    for chunk in string.gmatch(encoded or '', '([^|]+)') do
        local prefab, cooldown = string.match(chunk, '([^:]+):([%d%-]+)')
        if prefab ~= nil and cooldown ~= nil then
            local cd = tonumber(cooldown) or 0
            if cd == -1 then
                table.insert(entries, {
                    prefab = prefab,
                    cooldown = cd
                })
            end
        end
    end
    return entries
end

local function GetShadowName(prefab)
    local def = ShadowDefs.Get(prefab)
    if def ~= nil and def.name ~= nil then
        return def.name
    end
    return STRINGS.NAMES[string.upper(prefab)] or prefab
end

local function GetShadowRole(prefab)
    local def = ShadowDefs.Get(prefab)
    return def ~= nil and def.role or 'Đệ tử bóng tối'
end

local function GetSummonCost(prefab)
    local tuning = TUNING
    local mana_defs = tuning ~= nil and tuning.HH_MANA or nil
    local costs = mana_defs ~= nil and mana_defs.ARISE_COSTS or nil
    return (costs ~= nil and costs[prefab]) or (mana_defs ~= nil and mana_defs.ARISE_COST) or 40
end

local function GetStatusText(entry, global_cooldown)
    if global_cooldown > 0 then
        return string.format(STRINGS.HH_SHADOW_SUMMON.GLOBAL_COOLDOWN, global_cooldown)
    elseif entry.cooldown == -1 then
        return STRINGS.HH_SHADOW_SUMMON.ACTIVE
    elseif entry.cooldown > 0 then
        return string.format(STRINGS.HH_SHADOW_SUMMON.RECOVERING, entry.cooldown)
    end
    return STRINGS.HH_SHADOW_SUMMON.READY
end

local HHShadowRecallScreen = Class(Screen, function(self, owner)
    Screen._ctor(self, 'HHShadowRecallScreen')
    self.owner = owner

    -- self.black = self:AddChild(Image('images/global.xml', 'square.tex'))
    -- self.black:SetVRegPoint(ANCHOR_MIDDLE)
    -- self.black:SetHRegPoint(ANCHOR_MIDDLE)
    -- self.black:SetVAnchor(ANCHOR_MIDDLE)
    -- self.black:SetHAnchor(ANCHOR_MIDDLE)
    -- self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    -- self.black:SetTint(0, 0, 0, .78)

    self.root = self:AddChild(Widget('hh_shadow_summon_root'))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    self.scaler = self.root:AddChild(Widget('hh_shadow_summon_scaler'))
    self.scaler:SetScale(0.8, 0.8, 1)

    --self.panel = self.scaler:AddChild(Image('images/hud_troi_day.xml', 'hud_troi_day.tex'))
    --self.panel:SetSize(1100, 660)
    --self.panel:SetPosition(0, 20, 0)

    --self.title = self.scaler:AddChild(Text(TITLEFONT, 48, STRINGS.HH_SHADOW_SUMMON.TITLE))
    --self.title:SetPosition(0, 275, 0)
    --self.title:SetColour(.35, .75, 1, 1)

    --self.hint = self.scaler:AddChild(Text(UIFONT, 24, STRINGS.HH_SHADOW_SUMMON.HINT))
    --self.hint:SetPosition(0, 225, 0)
    --self.hint:SetColour(.70, .80, .95, 1)

    self.menu = self.scaler:AddChild(Menu(nil, -50, false, 'carny_xlong', false, 30))
    self.menu:SetPosition(-230, -120, 0)

    self.empty_text = self.scaler:AddChild(Text(UIFONT, 30, STRINGS.HH_SHADOW_SUMMON.EMPTY))
    self.empty_text:SetPosition(0, 40, 0)
    self.empty_text:SetColour(.85, .70, .70, 1)

    if owner ~= nil then
        self.inst:ListenForEvent('hh_shadows_cddirty', function() self:Refresh() end, owner)
        self.inst:ListenForEvent('hh_recall_cddirty', function() self:Refresh() end, owner)
    end

    self:Refresh()
end)

function HHShadowRecallScreen:Refresh()
    if self.owner == nil then
        return
    end

    self.menu:Clear()
    local entries = GetEntries(self.owner)
    local global_cooldown = self.owner.hh_recall_cd ~= nil and self.owner.hh_recall_cd:value() or 0
    local first_enabled_button = nil
    self.empty_text:Hide()

    if #entries == 0 then
        self.empty_text:Show()
    else
        for _, entry in ipairs(entries) do
            local selected_prefab = entry.prefab
            local status = GetStatusText(entry, global_cooldown)
            
            -- Create an empty button first
            local button = self.menu:AddItem("", function()
                SendModRPCToServer(GetModRPC('hh_rpc', 'hh_recall'), selected_prefab)
                TheFrontEnd:PopScreen(self)
            end, nil, 'carny_xlong', 28)
            
            -- Add individual text widgets to the button for independent positioning and styling
            button.shadow_name = button:AddChild(Text(UIFONT, 30, GetShadowName(entry.prefab)))
            button.shadow_name:SetPosition(-90, -1, 0)
            button.shadow_name:SetColour(1, 1, 1, 1)

            --button.shadow_role = button:AddChild(Text(UIFONT, 24, GetShadowRole(entry.prefab)))
            --button.shadow_role:SetPosition(0, 10, 0)
            --button.shadow_role:SetColour(0.8, 0.8, 0.8, 1)

            --button.status = button:AddChild(Text(UIFONT, 24, status))
            --button.status:SetPosition(0, -10, 0)
            --button.status:SetColour(0.6, 0.9, 0.6, 1)

            button.action_text = button:AddChild(Text(UIFONT, 25, "Thu hồi"))
            button.action_text:SetPosition(45, -1, 0)
            button.action_text:SetColour(0.9, 0.4, 0.4, 1)

            if global_cooldown > 0 then
                button:Disable()
            elseif first_enabled_button == nil then
                first_enabled_button = button
            end
        end
    end

    -- Hoàn toàn loại bỏ nút Đóng ra khỏi Menu để không ai bấm được
    -- local close_btn = self.menu:AddItem("", function()
    --     TheFrontEnd:PopScreen(self)
    -- end, nil, 'carny_long', 30)
    
    --close_btn.close_text = close_btn:AddChild(Text(UIFONT, 30, STRINGS.HH_SHADOW_SUMMON.CLOSE))
    --close_btn.close_text:SetPosition(0, 0, 0)
    --close_btn.close_text:SetColour(1, 1, 1, 1)
    self.menu:DoFocusHookups()
    self.default_focus = first_enabled_button or self.menu.items[#self.menu.items]
end

function HHShadowRecallScreen:OnControl(control, down)
    if HHShadowRecallScreen._base.OnControl(self, control, down) then
        return true
    end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function HHShadowRecallScreen:GetHelpText()
    return TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_CANCEL) .. ' Đóng'
end

return HHShadowRecallScreen
