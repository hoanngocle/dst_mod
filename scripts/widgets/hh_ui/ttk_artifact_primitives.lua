local Widget = require("widgets/widget")
local Image = require("widgets/image")
local Text = require("widgets/text")
local TextButton = require("widgets/textbutton")
local Theme = require("widgets/hh_ui/ttk_unified_theme")

local Primitive = {}
local FRAME_ATLAS = "images/ttk_forge/frame.xml"
local CONTROL_ATLAS = "images/ttk_forge/controls.xml"

local function position(node, x, y)
    node:SetPosition(x or 0, y or 0)
    return node
end

function Primitive.Frame(parent, x, y, width, height, tint)
    local frame = parent:AddChild(Image(FRAME_ATLAS, "frame.tex"))
    frame:SetSize(width, height)
    if tint then frame:SetTint(unpack(tint)) end
    return position(frame, x, y)
end

function Primitive.Label(parent, value, size, x, y, colour, width, align)
    local label = parent:AddChild(Text(Theme.GetFont(), size or 28, value or ""))
    label:SetFont(Theme.GetFont())
    label:SetString(value or "")
    if width then label:SetRegionSize(width, (size or 28) * 2) end
    if align then label:SetHAlign(align) end
    if colour then label:SetColour(unpack(colour)) end
    return position(label, x, y)
end

function Primitive.Button(parent, value, width, height, x, y, onclick, variant)
    local texture = variant == "primary" and "primary.tex"
        or variant == "active" and "tab_active.tex"
        or "tab_idle.tex"
    local button = parent:AddChild(TextButton())
    local background = button:AddChild(Image(CONTROL_ATLAS, texture))
    background:SetSize(width, height)
    if background.SetClickable ~= nil then background:SetClickable(false) end
    if background.MoveToBack ~= nil then background:MoveToBack() end
    button.background = background
    button:SetText(value or "")
    if button.text ~= nil and button.text.SetRegionSize ~= nil then
        button.text:SetRegionSize(width, height)
    end
    if button.image ~= nil and button.image.SetSize ~= nil then
        button.image:SetSize(width, height)
    end
    button:SetFont(Theme.GetFont())
    button:SetTextSize(math.floor((height or 54) * .48))
    button:SetTextColour(unpack(Theme.colours.text))
    button:SetTextFocusColour(unpack(Theme.colours.purple_soft))
    button:SetOnClick(onclick or function() end)
    return position(button, x, y)
end

function Primitive.Divider(parent, width, x, y)
    local divider = parent:AddChild(Widget("artifact_divider"))
    position(divider, x, y)
    local line = divider:AddChild(Image("images/hh_icon/hh_white.xml", "hh_white.tex"))
    line:SetSize(width, 2)
    line:SetTint(unpack(Theme.colours.line))
    local diamond = divider:AddChild(Image(CONTROL_ATLAS, "diamond.tex"))
    diamond:SetSize(18, 18)
    return divider
end

function Primitive.SlotSkin(parent, size, x, y, tint)
    local slot = parent:AddChild(Image(CONTROL_ATLAS, "slot.tex"))
    slot:SetSize(size, size)
    if tint then slot:SetTint(unpack(tint)) end
    return position(slot, x, y)
end

return Primitive
