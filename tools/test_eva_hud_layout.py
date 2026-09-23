from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / ".superpowers/ttk-solo-integration/lua-runtime"))
from lupa.lua51 import LuaRuntime


MODULE = ROOT / "scripts/util/eva_hud_layout.lua"


class EvaHudLayoutTest(unittest.TestCase):
    def setUp(self):
        self.assertTrue(MODULE.exists(), "EVA bottom-left HUD layout adapter is missing")
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(
            r'''
SCALEMODE_PROPORTIONAL = "proportional"
MAX_HUD_SCALE = 1.25
ANCHOR_LEFT = "left"
ANCHOR_BOTTOM = "bottom"
HUD_SCALE = 0.8
TheFrontEnd = {GetHUDScale = function() return HUD_SCALE end}

function Class(base, constructor)
    local class = {}
    class.__index = class
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

Widget = {}
Widget.__index = Widget
setmetatable(Widget, {__call = function(_, name)
    local instance = setmetatable({}, Widget)
    instance.name = name
    instance.children = {}
    return instance
end})
function Widget:AddChild(child)
    if child.parent ~= nil then child.parent.children[child] = nil end
    self.children[child] = child
    child.parent = self
    return child
end
function Widget:SetPosition(x, y, z) self.position = {x = x, y = y, z = z} end
function Widget:SetScale(value) self.scale = value end
function Widget:SetScaleMode(value) self.scale_mode = value end
function Widget:SetMaxPropUpscale(value) self.max_prop_upscale = value end
function Widget:SetHAnchor(value) self.h_anchor = value end
function Widget:SetVAnchor(value) self.v_anchor = value end

local function MakeImage()
    return {
        ScaleToSize = function(self, width, height)
            self.mode, self.width, self.height = "forced", width, height
        end,
        SetScale = function(self, scale)
            self.mode, self.scale = "scaled", scale
        end,
    }
end

function MakeButton()
    local button = Widget("button")
    button.image = MakeImage()
    button.image_normal = "same.tex"
    button.image_focus = "same.tex"
    button.scale_on_focus = true
    button.focus_scale = 1.2
    button.normal_scale = 1
    function button:ForceImageSize(width, height)
        self.image:ScaleToSize(width, height)
    end
    function button:OnGainFocus()
        if self.image_focus == self.image_normal and self.scale_on_focus then
            self.image:SetScale(self.focus_scale)
        end
    end
    function button:OnLoseFocus()
        if self.image_focus == self.image_normal and self.scale_on_focus then
            self.image:SetScale(self.normal_scale)
        end
    end
    return button
end

local Router = {
    DISPLAY_ORDER = {"life", "harvest", "wings", "daydu", "array"},
}
local modules = {
    ["widgets/widget"] = Widget,
    ["util/eva_skillpanel"] = Router,
}
function require(name) return assert(modules[name], "missing stub " .. name) end
'''
        )
        self.module = self.lua.execute(MODULE.read_text(encoding="utf-8-sig"))

    def test_deferred_layout_reparents_existing_widgets_and_opens_right(self):
        result = self.lua.execute(
            r'''
local Layout = ...
local registered_name, registered_callback
Layout.Install(function(name, callback)
    registered_name, registered_callback = name, callback
end)
assert(registered_name == "widgets/controls")

local controls = Widget("controls")
controls.owner = {prefab = "eva"}
controls.inst = {
    DoTaskInTime = function(_, delay, callback)
        assert(delay == 0)
        controls.deferred = callback
    end,
}
controls.SetHUDSize = function(self, ...)
    self.native_hud_size_calls = (self.native_hud_size_calls or 0) + 1
    return "first", nil, "third"
end
controls.status = controls:AddChild(Widget("status"))
controls.bottomright_root = controls:AddChild(Widget("bottomright"))
controls.status.hud_souls = controls.status:AddChild(Widget("souls"))
controls.eva_skillpanel = controls.bottomright_root:AddChild(Widget("panel"))
controls.eva_skillpanel.collapse = MakeButton()
controls.eva_skillpanel.icons = {}
for _, skill in ipairs({"life", "harvest", "wings", "daydu", "array"}) do
    controls.eva_skillpanel.icons[skill] = MakeButton()
end
controls.eva_skillpanel.skill_tooltip_text = Widget("tooltip")

registered_callback(controls)
assert(controls.eva_bottomleft_root == nil, "layout must wait for other postconstruct callbacks")
controls.deferred()

local root = assert(controls.eva_bottomleft_root)
local hud_root = assert(controls.eva_bottomleft_hud_root)
local badge = controls.status.hud_souls
local panel = controls.eva_skillpanel
assert(root.parent == controls)
assert(hud_root.parent == root and hud_root.scale == 0.8)
assert(root.scale_mode == SCALEMODE_PROPORTIONAL)
assert(root.max_prop_upscale == MAX_HUD_SCALE)
assert(root.h_anchor == ANCHOR_LEFT and root.v_anchor == ANCHOR_BOTTOM)
assert(badge.parent == controls.status and controls.status.children[badge] == badge)
assert(panel.parent == hud_root and controls.bottomright_root.children[panel] == nil)
assert(badge.position.x == -40 and badge.position.y == -150)
assert(panel.position.x == 115 and panel.position.y == 190)
assert(panel.collapse.position.x == 0 and panel.collapse.position.y == 0)

local expected_x = {life = 64, harvest = 128, wings = 192, daydu = 256, array = 320}
for skill, button in pairs(panel.icons) do
    assert(button.position.x == expected_x[skill] and button.position.y == 0,
        skill .. " must open horizontally to the right")
end
HUD_SCALE = 1.25
local first, middle, third = controls:SetHUDSize("keep-args")
assert(first == "first" and middle == nil and third == "third",
    "SetHUDSize return values were not preserved")
assert(controls.native_hud_size_calls == 1)
assert(hud_root.scale == 1.25, "HUD scale changes must update only the inner root")
assert(root.scale == nil, "screen anchors must remain unscaled")
assert(badge.position.x == -40 and badge.position.y == -150,
    "HUD scaling must not reset the dragged badge position")
return root, badge, panel
''',
            self.module,
        )
        self.assertIsNotNone(result)

    def test_native_hover_preserves_distinct_toggle_and_skill_sizes(self):
        self.lua.execute(
            r'''
local Layout = ...
local panel = {
    collapse = MakeButton(),
    icons = {
        life = MakeButton(), harvest = MakeButton(), wings = MakeButton(),
        daydu = MakeButton(), array = MakeButton(),
    },
    skill_tooltip_text = Widget("tooltip"),
}
Layout.ConfigurePanel(panel)
local function Check(button)
    assert(button.scale_on_focus == false)
    button:OnGainFocus()
    assert(button.image.mode == "forced", "focus replaced forced pixel sizing")
    button:OnLoseFocus()
    assert(button.image.mode == "forced", "unfocus replaced forced pixel sizing")
end
assert(panel.collapse.image.mode == "forced" and panel.collapse.image.width == 80
    and panel.collapse.image.height == 80)
Check(panel.collapse)
for _, button in pairs(panel.icons) do
    assert(button.image.mode == "forced" and button.image.width == 58.08
        and button.image.height == 58.08)
    Check(button)
end
''',
            self.module,
        )

    def test_non_eva_controls_are_untouched(self):
        self.lua.execute(
            r'''
local Layout = ...
local callback
Layout.Install(function(_, fn) callback = fn end)
local controls = Widget("controls")
controls.owner = {prefab = "wilson"}
controls.inst = {DoTaskInTime = function() error("must not schedule") end}
callback(controls)
assert(controls.eva_bottomleft_root == nil)
''',
            self.module,
        )

    def test_missing_status_returns_false_without_mutating_widgets(self):
        self.lua.execute(
            r'''
local Layout = ...
local controls = Widget("controls")
local old_parent = controls:AddChild(Widget("old_parent"))
local badge = Widget("souls")
local panel = old_parent:AddChild(Widget("panel"))
controls.owner = {prefab = "eva", soulhud = badge}
controls.eva_skillpanel = panel

assert(Layout.Apply(controls) == false)
assert(controls.eva_bottomleft_root == nil)
assert(badge.parent == nil)
assert(panel.parent == old_parent and old_parent.children[panel] == panel)
''',
            self.module,
        )


if __name__ == "__main__":
    unittest.main()
