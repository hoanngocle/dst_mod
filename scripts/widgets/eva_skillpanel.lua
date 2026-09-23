local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Router = require "util/eva_skillpanel"

local ORDER = Router.DISPLAY_ORDER
local ICON_SIZE = 48
local ICON_GAP = 56

local EvaSkillPanel = Class(Widget, function(self, owner)
    Widget._ctor(self, "EvaSkillPanel")
    self.owner = owner
    self.expanded = false
    self.content = self:AddChild(Widget("EvaSkillPanelContent"))
    self.icons = {}

    self.collapse = self.content:AddChild(ImageButton(
        "images/eva_skill_toggle.xml", "eva_skill_toggle.tex"))
    self.collapse:SetPosition(-#ORDER * ICON_GAP, 0)
    self.collapse:ForceImageSize(ICON_SIZE, ICON_SIZE)
    self.collapse:SetOnClick(function() self:SetExpanded(not self.expanded) end)

    self.skill_tooltip_text = self.content:AddChild(Text(BODYTEXTFONT, 24, ""))
    self.skill_tooltip_text:SetPosition(-168, 52)
    self.skill_tooltip_text:SetColour(0.9, 0.82, 1, 1)
    self.skill_tooltip_text:SetClickable(false)
    self.skill_tooltip_text:Hide()

    for index, skill in ipairs(ORDER) do
        local definition = Router.SKILLS[skill]
        local button = self.content:AddChild(ImageButton(
            definition.atlas or GetInventoryItemAtlas(definition.texture),
            definition.texture))
        button:SetPosition(-(#ORDER - index) * ICON_GAP, 0)
        button:ForceImageSize(ICON_SIZE, ICON_SIZE)
        button.cooldown = button:AddChild(Text(NUMBERFONT, 28, ""))
        button.cooldown:SetColour(1, 1, 1, 1)
        button.state = button:AddChild(Text(BODYTEXTFONT, 18, ""))
        button.state:SetPosition(0, -31)
        button.state:SetColour(0.65, 1, 0.78, 1)
        button:SetOnClick(function() self:ActivateSkill(skill) end)
        button.ongainfocus = function()
            self.skill_tooltip_text:SetString(Router.GetSkillTooltip(self.owner, skill))
            self.skill_tooltip_text:Show()
        end
        button.onlosefocus = function() self.skill_tooltip_text:Hide() end
        self.icons[skill] = button
    end
    self.collapse.ongainfocus = function()
        self.skill_tooltip_text:SetString(self.expanded and "Thu gọn bảng kỹ năng" or "Mở bảng kỹ năng EVA")
        self.skill_tooltip_text:Show()
    end
    self.collapse.onlosefocus = function() self.skill_tooltip_text:Hide() end
    self:SetExpanded(false)
    self:StartUpdating()
end)

function EvaSkillPanel:SetExpanded(expanded)
    self.expanded = expanded == true
    for _, button in pairs(self.icons) do
        if self.expanded then button:Show() else button:Hide() end
    end
    self.skill_tooltip_text:Hide()
end

function EvaSkillPanel:ActivateSkill(skill)
    return Router.ActivateSkill(self.owner, TheFrontEnd, skill)
end

function EvaSkillPanel:OnUpdate()
    local usable = Router.CanUsePanel(self.owner, TheFrontEnd)
    if usable then self.content:Show() else self.content:Hide() end
    if not usable then return end

    for _, skill in ipairs(ORDER) do
        local button = self.icons[skill]
        local cooldown = Router.GetCooldownSeconds(self.owner, skill)
        local unlocked = Router.IsSkillUnlocked(self.owner, skill)
        button.cooldown:SetString(unlocked and cooldown > 0 and tostring(cooldown) or "")
        button.state:SetString(unlocked and skill == "wings"
            and Router.GetWingsActive(self.owner) and "ĐANG MỞ" or "")
        if not unlocked or cooldown > 0 then
            button:SetImageNormalColour(0.38, 0.38, 0.42, 0.9)
        else
            button:SetImageNormalColour(1, 1, 1, 1)
        end
    end
end

return EvaSkillPanel
