from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parents[1] / ".superpowers/ttk-solo-integration/lua-runtime"))
from lupa.lua51 import LuaRuntime


module_path = ROOT / "scripts/util/eva_hud_drag.lua"
assert module_path.exists(), "EVA HUD drag module is missing"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().package.path = str(ROOT / "scripts/?.lua").replace("\\", "/") + ";" + lua.globals().package.path
lua.execute(r'''
local Drag = require("util/eva_hud_drag")
local mouse = {x = 10, y = 20, z = 0}
local move_handler, saved, removed
local input = {
    GetScreenPosition = function() return mouse end,
    AddMoveHandler = function(_, fn)
        move_handler = fn
        return {Remove = function() removed = true end}
    end,
}
local sim = {
    GetPersistentString = function(_, _, callback) callback(true, "12.5,-9") end,
    SetPersistentString = function(_, _, value) saved = value end,
}
local widget = {position = {x = -80, y = -40, z = 0}}
function widget:GetPosition() return self.position end
function widget:SetPosition(value, y, z)
    self.position = type(value) == "table" and value or {x = value, y = y, z = z}
end
function widget:GetScale() return {x = 2, y = 2, z = 1} end

Drag.Attach(widget, {
    input = input,
    sim = sim,
    left_button = 1,
    vector = function(x, y, z) return {x = x, y = y, z = z} end,
})
assert(widget.position.x == 12.5 and widget.position.y == -9)
assert(widget:OnMouseButton(1, true))
mouse = {x = 30, y = 50, z = 0}
move_handler(mouse.x, mouse.y)
assert(widget.position.x == 22.5 and widget.position.y == 6)
assert(widget:OnMouseButton(1, false))
assert(removed and saved == "22.5,6")
print("PASS: EVA soul HUD loads, drags and saves its local position")
''')
