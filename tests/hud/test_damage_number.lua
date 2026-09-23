local positions = {}
local periodic

Ents = {}
NUMBERFONT = "numberfont"
FRAMES = 1 / 30

function CreateEntity()
    local inst = {
        entity = {
            AddTransform = function() end,
            AddLabel = function() end,
        },
        Transform = {
            SetPosition = function(_, x, y, z)
                positions[#positions + 1] = { x, y, z }
            end,
        },
        Label = {
            SetFont = function() end,
            SetFontSize = function() end,
            Enable = function() end,
            SetColour = function() end,
            SetText = function() end,
        },
        AddTag = function() end,
        DoPeriodicTask = function(_, _, fn) periodic = fn end,
        DoTaskInTime = function() end,
        Remove = function() end,
    }
    return inst
end

function Prefab(name, fn)
    return { name = name, fn = fn }
end

local target = {
    IsValid = function() return true end,
}
Ents[119912] = target

local prefab = dofile("scripts/prefabs/ttk_hud_damage_number.lua")
local popup = prefab.fn()
popup:Display(119912, 68, "normal", 164, 0, -181)

assert(#positions == 1, "transformless target uses the RPC snapshot position")
assert(positions[1][1] == 164 and positions[1][2] == 2.4 and positions[1][3] == -181,
    "damage number preserves the RPC snapshot coordinates")
assert(type(periodic) == "function", "damage number schedules its normal lifetime update")
periodic(popup)
assert(#positions == 1, "transformless target remains detached during periodic updates")

print("damage number: transformless target falls back to RPC position")
