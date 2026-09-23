BODYTEXTFONT = "font_viethoa"
UIFONT = "ui"
TTK_FORGE_SERIF = nil
package.loaded["widgets/hh_ui/ttk_unified_theme"] = nil
local Theme = require("widgets/hh_ui/ttk_unified_theme")
assert(Theme.GetFont() == "font_viethoa", "theme resolves the native Vietnamese fallback lazily")
TTK_FORGE_SERIF = "ttk_forge_serif"
assert(Theme.GetFont() == "ttk_forge_serif", "theme observes the custom alias after SimPostInit")
assert(Theme.GetSurfaceScale("forge") == .7, "Solo forge surfaces retain their native scale")
assert(Theme.GetSurfaceScale("shell") == 1, "shell surfaces use design-space scale")

local scale_mode_calls = 0
local Node = {}
Node.__index = Node
function Node.new(kind, ...)
    return setmetatable({ kind = kind, args = { ... }, children = {} }, Node)
end
function Node:AddChild(child) table.insert(self.children, child); child.parent = self; return child end
function Node:SetPosition(...) self.position = { ... } end
function Node:SetSize(...) self.size = { ... } end
function Node:SetTint(...) self.tint = { ... } end
function Node:SetColour(...) self.colour = { ... } end
function Node:SetRegionSize(...) self.region = { ... } end
function Node:SetHAlign(value) self.align = value end
function Node:SetString(value) self.value = value end
function Node:SetFont(value) self.font = value end
function Node:SetText(value) self.value = value end
function Node:SetTextSize(value) self.text_size = value end
function Node:SetTextColour(...) self.text_colour = { ... } end
function Node:SetTextFocusColour(...) self.focus_colour = { ... } end
function Node:SetOnClick(fn) self.onclick = fn end
function Node:SetClickable(value) self.clickable = value end
function Node:MoveToBack() self.moved_to_back = true end
function Node:SetScaleMode() scale_mode_calls = scale_mode_calls + 1 end

local function factory(kind)
    return function(...)
        local node = Node.new(kind, ...)
        if kind == "button" then
            node.SetSize = false
            node.text = Node.new("button_text")
            node.image = Node.new("button_hitbox")
        end
        return node
    end
end
package.preload["widgets/widget"] = function() return factory("widget") end
package.preload["widgets/image"] = function() return factory("image") end
package.preload["widgets/text"] = function() return factory("text") end
package.preload["widgets/textbutton"] = function() return factory("button") end
package.loaded["widgets/widget"] = nil
package.loaded["widgets/image"] = nil
package.loaded["widgets/text"] = nil
package.loaded["widgets/textbutton"] = nil
package.loaded["widgets/hh_ui/ttk_artifact_primitives"] = nil

local Primitive = require("widgets/hh_ui/ttk_artifact_primitives")
local root = Node.new("root")
local frame = Primitive.Frame(root, 0, 0, 420, 240)
local label = Primitive.Label(root, "Xin chào", 28, 10, 20)
local button = Primitive.Button(root, "CƯỜNG HÓA", 320, 58, 0, -80, function() end, "primary")
local divider = Primitive.Divider(root, 500, 0, 60)
local slot = Primitive.SlotSkin(root, 96, -160, 0)

assert(frame.parent == root and frame.size[1] == 420, "frame uses explicit local dimensions")
assert(label.font == "ttk_forge_serif" and label.value == "Xin chào", "label resolves font at construction time")
assert(button.parent == root and button.onclick ~= nil, "button owns its callback")
assert(button.text.region[1] == 320 and button.text.region[2] == 58, "button sizes its native text region")
assert(button.image.size[1] == 320 and button.image.size[2] == 58, "button sizes its native hitbox image")
assert(button.background.clickable == false and button.background.moved_to_back, "button background never steals input")
assert(divider.parent == root and slot.parent == root, "divider and slot stay in the supplied local parent")
assert(scale_mode_calls == 0, "artifact primitives never introduce nested ScaleMode roots")

print("Artifact theme and primitive checks PASS")
