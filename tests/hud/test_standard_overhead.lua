package.path = "./scripts/?.lua;" .. package.path

SCALEMODE_PROPORTIONAL = "proportional"
SCALEMODE_NONE = "none"
MAX_HUD_SCALE = 1.25
ANCHOR_LEFT = "left"
ANCHOR_BOTTOM = "bottom"
NUMBERFONT = "number"

function Class(base, constructor)
    local class = {_base = base, _ctor = constructor}
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

local Widget = {}
function Widget._ctor(self, name)
    self.name = name
    self.children = {}
    self.shown = true
    self.inst = {
        listeners = {},
        ListenForEvent = function(inst, event, fn) inst.listeners[event] = fn end,
    }
end
function Widget:AddChild(child)
    self.children[#self.children + 1] = child
    child.parent = self
    return child
end
function Widget:SetClickable(value) self.clickable = value end
function Widget:SetScaleMode(value) self.scale_mode = value end
function Widget:SetMaxPropUpscale(value) self.max_prop_upscale = value end
function Widget:SetHAnchor(value) self.h_anchor = value end
function Widget:SetVAnchor(value) self.v_anchor = value end
function Widget:SetPosition(x, y, z)
    if type(x) == "table" then self.position = {x = x.x, y = x.y, z = x.z} return end
    self.position = {x = x, y = y, z = z}
end
function Widget:Show() self.shown = true end
function Widget:Hide() self.shown = false end
function Widget:Kill() self.killed = true end
function Widget:StartUpdating() self.updating = true end
function Widget:StopUpdating() self.updating = false end

local Image = Class(Widget, function(self, atlas, texture)
    Widget._ctor(self, "Image")
    self.atlas, self.texture = atlas, texture
end)
function Image:SetSize(width, height) self.width, self.height = width, height end
function Image:GetSize() return self.width, self.height end
function Image:SetTint(r, g, b, a) self.tint = {r, g, b, a} end
function Image:MoveToFront() self.front = true end

local Text = Class(Widget, function(self, font, size, value)
    Widget._ctor(self, "Text")
    self.font, self.font_size, self.string = font, size, value
end)
function Text:SetString(value) self.string = value end
function Text:SetSize(value) self.font_size = value end
function Text:SetColour(r, g, b, a) self.colour = {r, g, b, a} end
function Text:MoveToFront() self.front = true end

package.preload["widgets/widget"] = function() return Widget end
package.preload["widgets/image"] = function() return Image end
package.preload["widgets/text"] = function() return Text end

local function Vector(x, y, z)
    local value = {x = x or 0, y = y or 0, z = z or 0}
    function value:Get() return self.x, self.y, self.z end
    function value:Dist(other)
        local dx, dy, dz = self.x - other.x, self.y - other.y, self.z - other.z
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end
    return value
end
Vector3 = function(x, y, z)
    if type(x) == "table" then return Vector(x.x, x.y, x.z) end
    return Vector(x, y, z)
end

TheSim = {
    GetScreenSize = function() return 1920, 1080 end,
    GetCameraPos = function() return 0, 30, 0 end,
    GetScreenPos = function() return 100, 200 end,
}

local Standard = require("widgets/ttk_hud_standard_bar")
local function close(actual, expected)
    assert(math.abs(actual - expected) < 0.000001,
        string.format("expected %.9f, got %.9f", expected, actual))
end

local tags = {bird = true, smallcreature = true}
local bird = {
    prefab = "crow",
    components = {}, replica = {},
    HasTag = function(_, tag) return tags[tag] == true end,
    IsValid = function() return true end,
    GetPosition = function() return Vector(0, 0, 0) end,
    AnimState = {GetSymbolPosition = function() return 0, 0, 0 end},
    Transform = {GetWorldPosition = function() return 0, 0, 0 end},
    GetDistanceSqToInst = function() return 1 end,
}
close(Standard.GetEntityWidth(bird), 0.85)
close(Standard.GetEntityHeight(bird), 1.5)

local bar = Standard.Widget()
bar:SetTarget(bird)
bar:SetHBSize(120 * Standard.GetEntityWidth(bird), 22)
bar:SetFontSize(24)
bar:SetOpacity(0.8)
bar:SetValue(31, 31, true)
assert(bar.bg.atlas == "images/ttk_dyc_white.xml")
assert(bar.bg.texture == "ttk_dyc_white.tex")
close(bar.bg.width, 102); close(bar.bg.height, 22)
close(bar.bg2.width, 100); close(bar.bg2.height, 20)
close(bar.bar.width, 96); close(bar.bar.height, 16)
close(bar.bar.position.x, 0)
assert(bar.text.font_size == 24 and bar.text.string == "31/31")
assert(bar.bg.tint[1] == 1 and bar.bg.tint[4] == 0.8)
assert(bar.bg2.tint[1] == 0 and bar.bg2.tint[4] == 0.8)

bar:SetValue(15, 31, false)
close(bar.bar.width, 46.4516129032258)
close(bar.bar.position.x, -24.7741935483871)
assert(#bar.healthReductions == 1)
local reduction = bar.healthReductions[1]
close(reduction.width, 49.5483870967742)
close(reduction.height, 16)
close(reduction.position.x, 23.2258064516129)
close(reduction.tint[4], 0.8)
bar:OnUpdate(0.4)
close(reduction.tint[4], 0.4)

local player = {}
local function colour(owner)
    local r, g, b, a = Standard.ResolveDynamic2(owner, player)
    return {r, g, b, a}
end
local neutral = colour(bird)
close(neutral[1], 0.7); close(neutral[2], 0.7); close(neutral[3], 0.7)
local hostile = colour({components = {}, replica = {}, HasTag = function(_, tag) return tag == "hostile" end})
close(hostile[1], 0.8); close(hostile[2], 0.5); close(hostile[3], 0.1)
local monster = colour({components = {}, replica = {}, HasTag = function(_, tag) return tag == "monster" end})
close(monster[1], 0.7); close(monster[2], 0.7); close(monster[3], 0.1)
local follower = colour({
    components = {follower = {leader = player}}, replica = {},
    HasTag = function() return false end,
})
close(follower[1], 0.1); close(follower[2], 0.7); close(follower[3], 0.2)
local attacker = colour({
    components = {combat = {target = player, defaultdamage = 10}}, replica = {},
    HasTag = function() return false end,
})
close(attacker[1], 0.8); close(attacker[2], 0); close(attacker[3], 0)

bar:OnUpdate(0.01)
close(bar.position.x, 95)
close(bar.position.y, 290)

local Overhead = require("widgets/ttk_hud_overhead")
local parent, other = {}, {}
local epic = {target = parent, shown = true, active = true}
local local_player = {HUD = {controls = {epichealthbar = epic}}}
assert(Overhead.IsEpicDisplayed(parent, local_player) == true)
epic.target = other
assert(Overhead.IsEpicDisplayed(parent, local_player) == false)
epic.target, epic.shown = parent, false
assert(Overhead.IsEpicDisplayed(parent, local_player) == false)
assert(Overhead.IsEpicDisplayed(parent, nil) == false)

TUNING = {TTK_HUD = {
    HIDE_BOSS_OVERHEAD = true,
    SHOW_VALUES = true,
}}
ThePlayer = local_player
local function NetValue(value) return {value = function() return value end} end
local proxy = {
    _visible = NetValue(true),
    _current = NetValue(15),
    _maximum = NetValue(31),
    IsValid = function() return true end,
    entity = {GetParent = function() return bird end},
}
local adapter = Overhead(proxy)
assert(adapter.scale_mode == SCALEMODE_NONE,
    "adapter must not rescale projected screen coordinates")
assert(adapter.standard.scale_mode == SCALEMODE_PROPORTIONAL
    and adapter.standard.max_prop_upscale == 999,
    "source renderer owns the single proportional scale")
adapter:OnUpdate()
assert(adapter.standard.target == bird)
assert(adapter.standard.animHBWidth == 102 and adapter.standard.hbHeight == 22)
assert(adapter.standard.text.string == "15/31")
close(adapter.standard.barColor.r, 0.7)

print("standard overhead: source geometry, trail, colors, camera offset, and local Epic suppression passed")
