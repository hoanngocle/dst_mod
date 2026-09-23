local Widget = require("widgets/widget")
local TextButton = require("widgets/textbutton")
local Theme = require("widgets/hh_ui/ttk_unified_theme")

local MODES = {
    { id = "daily", label = "Hằng ngày" },
    { id = "guild", label = "Hiệp Hội" },
    { id = "promotion", label = "Thăng hạng" },
}

local TTKQuestPanel = Class(Widget, function(self, owner, options)
    Widget._ctor(self, "ttk_quest_panel")
    options = options or {}
    self.owner = owner
    self.mode = "daily"
    self.disposed = false

    local status_factory = options.status_factory or function(parent)
        local UI = require("widgets/hh_status_ui")
        return parent:AddChild(UI(owner, nil, { embedded = true, content_mode = "quests" }))
    end
    local guild_factory = options.guild_factory or function(parent)
        local UI = require("widgets/hh_guild_ui")
        return parent:AddChild(UI(owner, nil, { embedded = true }))
    end
    self.status = status_factory(self)
    self.guild = guild_factory(self)
    self.status:SetPosition(0, -34, 0)
    self.guild:SetPosition(0, -32, 0)

    self.tabs = {}
    for index, mode in ipairs(MODES) do
        local button = self:AddChild(TextButton())
        button:SetPosition((index - 2) * 260, 286, 5)
        button:SetFont(Theme.GetFont())
        button:SetTextSize(23)
        button:SetText(mode.label)
        button:SetTextColour(unpack(Theme.colours.text))
        button:SetTextFocusColour(unpack(Theme.colours.purple_soft))
        button.text:SetRegionSize(240, 42)
        button:SetOnClick(function() self:SetMode(mode.id) end)
        self.tabs[index] = button
    end
    self:SetMode("daily")
end)

function TTKQuestPanel:SetMode(mode)
    if self.disposed then return end
    self.mode = mode
    local daily = mode == "daily"
    if daily then
        self.guild:Hide()
        self.status:Show()
        if self.status.SetQuestFocus ~= nil then self.status:SetQuestFocus(mode) end
    else
        self.status:Hide()
        self.guild:Show()
        if self.guild.SetQuestFocus ~= nil then self.guild:SetQuestFocus(mode) end
    end
    for index, entry in ipairs(MODES) do
        self.tabs[index]:SetTextColour(unpack(entry.id == mode and Theme.colours.purple_soft or Theme.colours.text))
    end
end

function TTKQuestPanel:ShowPanel()
    self:Show()
    self:SetMode(self.mode)
    local child = self.mode == "daily" and self.status or self.guild
    if child.ShowPanel ~= nil then child:ShowPanel() end
end

function TTKQuestPanel:HidePanel()
    if self.status.HidePanel ~= nil then self.status:HidePanel() end
    if self.guild.HidePanel ~= nil then self.guild:HidePanel() end
    self.status:Hide()
    self.guild:Hide()
    self:Hide()
end

function TTKQuestPanel:DisposePanel()
    if self.disposed then return end
    self.disposed = true
    if self.status.DisposePanel ~= nil then self.status:DisposePanel() else self.status:Kill() end
    if self.guild.DisposePanel ~= nil then self.guild:DisposePanel() else self.guild:Kill() end
    self:Kill()
end

return TTKQuestPanel
