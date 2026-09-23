from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / ".superpowers/ttk-solo-integration/lua-runtime"))
from lupa.lua51 import LuaRuntime


lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
BODYTEXTFONT = "body"
NUMBERFONT = "number"
TheFrontEnd = {}

function Class(base, constructor)
    local class = {}
    class.__index = class
    class._base = base
    setmetatable(class, {
        __index = base,
        __call = function(_, ...)
            local instance = setmetatable({}, class)
            constructor(instance, ...)
            return instance
        end,
    })
    return class
end

local Widget = {}
Widget.__index = Widget
setmetatable(Widget, {__call = function(_, name)
    local instance = setmetatable({}, Widget)
    Widget._ctor(instance, name)
    return instance
end})
function Widget._ctor(self, name)
    self.name = name
    self.children = {}
    self.focus = false
    self.shown = true
    self.clickable = true
end
function Widget:AddChild(child)
    self.children[child] = true
    child.parent = self
    return child
end
function Widget:GetTooltip()
    if self.focus then
        for child in pairs(self.children) do
            local value = child:GetTooltip()
            if value ~= nil then return value end
        end
        return self.tooltip
    end
end
function Widget:SetPosition(...) self.position = {...} end
function Widget:Show() self.shown = true end
function Widget:Hide() self.shown = false end
function Widget:SetClickable(value) self.clickable = value end
function Widget:StartUpdating() self.updating = true end

local Text = Class(Widget, function(self, font, size, value)
    Widget._ctor(self, "Text")
    self.font, self.size, self.string = font, size, value
end)
function Text:SetString(value)
    assert(type(value) == "string", "Text:SetString requires a string")
    self.string = value
end
function Text:SetColour(...) self.colour = {...} end

local ImageButton = Class(Widget, function(self, atlas, texture)
    Widget._ctor(self, "ImageButton")
    self.atlas, self.texture = atlas, texture
end)
function ImageButton:ForceImageSize(width, height) self.image_size = {width, height} end
function ImageButton:SetOnClick(callback) self.onclick = callback end
function ImageButton:SetImageNormalColour(...) self.normal_colour = {...} end

Router = {
    DISPLAY_ORDER = {"life", "harvest", "wings", "daydu", "array"},
    SKILLS = {},
    SPELL_INDEX = {},
    unlocked = {},
    wings_active = false,
}
for index, skill in ipairs(Router.DISPLAY_ORDER) do
    Router.SKILLS[skill] = {texture = skill .. ".tex", atlas = "skills.xml"}
    Router.SPELL_INDEX[skill] = index
end
function Router.GetSkillTooltip(_, skill) return "TIP:" .. skill end
function Router.CanUsePanel() return true end
function Router.IsSkillUnlocked(_, skill) return Router.unlocked[skill] ~= false end
function Router.GetCooldownSeconds() return 0 end
function Router.GetRequiredLevel() return 1 end
function Router.GetWingsActive() return Router.wings_active end
function Router.IsBoundBook() return true end

function GetInventoryItemAtlas() return "inventory.xml" end

local modules = {
    ["widgets/widget"] = Widget,
    ["widgets/imagebutton"] = ImageButton,
    ["widgets/text"] = Text,
    ["util/eva_skillpanel"] = Router,
}
function require(name) return assert(modules[name], "missing stub " .. name) end

function ClearFocus(widget)
    widget.focus = false
    for child in pairs(widget.children) do ClearFocus(child) end
end
function FocusPath(panel, target)
    ClearFocus(panel)
    panel.focus = true
    panel.content.focus = true
    target.focus = true
end
''')

source = (ROOT / "scripts/widgets/eva_skillpanel.lua").read_text(encoding="utf-8-sig")
panel_class = lua.execute(source)
lua.globals().EvaSkillPanel = panel_class
lua.execute(r'''
local panel = EvaSkillPanel({})
local label = panel.skill_tooltip_text or panel.tooltip
assert(label ~= nil, "custom skill tooltip label is missing")
assert(panel.expanded == false and label.shown == false)
for _, button in pairs(panel.icons) do assert(button.shown == false) end

Router.unlocked.life = false
Router.wings_active = true
panel:OnUpdate()
assert(panel.icons.life.state.string == "",
    "locked skills must not show the below-icon level label")
assert(panel.icons.wings.state.string == "ĐANG MỞ",
    "the wings active-state text must remain visible")

FocusPath(panel, panel.collapse)
panel.collapse.ongainfocus()
assert(label.string == "Mở bảng kỹ năng EVA")
local collapse_tooltip = panel:GetTooltip()
assert(collapse_tooltip == nil or type(collapse_tooltip) == "string",
    "collapse hover returned " .. type(collapse_tooltip) .. " instead of nil/string")
panel.collapse.onlosefocus()
assert(label.shown == false)

panel:SetExpanded(true)
assert(panel.expanded == true and label.shown == false)
for _, button in pairs(panel.icons) do assert(button.shown == true) end
FocusPath(panel, panel.collapse)
panel.collapse.ongainfocus()
assert(label.string == "Thu gọn bảng kỹ năng")
assert(panel:GetTooltip() == nil or type(panel:GetTooltip()) == "string")
panel.collapse.onlosefocus()

for skill, button in pairs(panel.icons) do
    FocusPath(panel, button)
    button.ongainfocus()
    assert(label.string == "TIP:" .. skill)
    assert(label.shown == true)
    local tooltip = panel:GetTooltip()
    assert(tooltip == nil or type(tooltip) == "string",
        skill .. " hover returned " .. type(tooltip) .. " instead of nil/string")
    button.onlosefocus()
    assert(label.shown == false)
end

assert(label.clickable == false, "custom tooltip label must not capture mouse focus")
panel:SetExpanded(false)
assert(panel.expanded == false and label.shown == false)
for _, button in pairs(panel.icons) do assert(button.shown == false) end
print("Đạt: EVA skill panel hover tooltip an toàn, nhãn đúng và thu/mở ổn định")
''')
