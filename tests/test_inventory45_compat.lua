local hooks, classes, components = {}, {}, {}
GLOBAL = _G
EQUIPSLOTS = {BODY = "body", BACK = "back", NECK = "neck", HANDS = "hands"}
TheWorld = {ismastersim = true}
TheNet = {IsDedicated = function() return false end}
function AddPrefabPostInit(name, fn) hooks[name] = fn end
function AddClassPostConstruct(name, fn) classes[name] = fn end
function AddComponentPostInit(name, fn) components[name] = fn end

-- Chạy từ thư mục gốc của workspace, cùng quy ước với test_inventorysort.lua.
dofile("mods/PhamNhanTuTien/main/ttk_inventory45_compat.lua")

local calls, body = 0, {}
local anim = {build = "armor_skin", symbol = "armor", skin = true}
function anim:GetSymbolOverride(slot) if slot == "swap_body_tall" then return self.tallbuild, self.tallsymbol end; return self.build, self.symbol end
function anim:IsSkinBuild(build) return self.skin end
function anim:OverrideSkinSymbol(slot, build, symbol) self:OverrideSymbol(slot, build, symbol); self.restoredskin = true end
function anim:OverrideSymbol(slot, build, symbol) if slot == "swap_body_tall" then self.tallbuild, self.tallsymbol = build, symbol else self.build, self.symbol = build, symbol end end
function anim:ClearOverrideSymbol(slot) self:OverrideSymbol(slot, nil, nil) end
local backpack, necklace
local owner = {AnimState = anim, components = {inventory = {GetEquippedItem = function(self, slot) return slot == "body" and body or slot == "back" and backpack or slot == "neck" and necklace or nil end}}}
local amulet = {components = {equippable = {equipslot = "neck"}}}
local eq = amulet.components.equippable
eq.onequipfn = function(inst, player) calls = calls + 1; player.AnimState:OverrideSymbol("swap_body", "amulets", "green") end
eq.onunequipfn = function(inst, player) calls = calls + 1; player.AnimState:ClearOverrideSymbol("swap_body") end
if hooks.greenamulet then hooks.greenamulet(amulet) end
eq.onequipfn(amulet, owner)
assert(anim.build == "armor_skin" and anim.symbol == "armor", "necklace equip overwrote body armor")
assert(anim.restoredskin, "armor skin was restored as an ordinary build")
eq.onunequipfn(amulet, owner)
assert(anim.build == "armor_skin" and calls == 2, "unequip cleared armor or replayed gameplay callback")
body = nil
eq.onequipfn(amulet, owner)
assert(anim.build == "amulets", "necklace without body equipment must remain visible")
eq.onunequipfn(amulet, owner)
assert(anim.build == nil, "unequipped necklace must disappear")
body = {}; anim.skin = false; anim.build, anim.symbol = "armorwood", "swap_body"
eq.onequipfn(amulet, owner)
assert(anim.build == "armorwood", "unskinned armor was not preserved")
anim.build, anim.symbol = nil, nil
eq.onequipfn(amulet, owner)
assert(anim.build == nil, "body equipment without a symbol must not acquire an amulet symbol")
local broken = {components = {equippable = {equipslot = "neck", onequipfn = function(inst, player)
    player.AnimState:ClearOverrideSymbol("swap_body")
    error("equip failure")
end}}}
hooks.greenamulet(broken)
anim.build, anim.symbol = "armorwood", "swap_body"
local ok, err = pcall(broken.components.equippable.onequipfn, broken, owner)
assert(not ok and string.find(err, "equip failure") and anim.build == "armorwood", "callback error must propagate after restoring armor")

backpack = {components = {equippable = {equipslot = "back"}}}
backpack.components.equippable.onequipfn = function(inst, player)
    calls = calls + 1
    player.AnimState:OverrideSymbol("swap_body", "swap_backpack", "swap_body")
end
backpack.components.equippable.onunequipfn = function(inst, player)
    calls = calls + 1
    player.AnimState:ClearOverrideSymbol("swap_body")
end
if hooks.backpack then hooks.backpack(backpack) end
anim.tallbuild, anim.tallsymbol = "armor_tall", "tall"
backpack.components.equippable.onequipfn(backpack, owner)
assert(anim.build == "armorwood" and anim.tallbuild == "armor_tall", "backpack overwrote body armor")
local events = {}
function owner:ListenForEvent(event, fn) events[event] = fn end
owner.components.inventory.inst = owner
if components.inventory then components.inventory(owner.components.inventory) end
body = nil
anim:ClearOverrideSymbol("swap_body")
anim:ClearOverrideSymbol("swap_body_tall")
local before = calls
if events.unequip then events.unequip(owner, {eslot = "body"}) end
assert(anim.build == "swap_backpack" and anim.tallbuild == nil and calls == before, "body removal must restore backpack appearance without replaying equip")
necklace = amulet
eq.onequipfn(amulet, owner)
assert(anim.build == "swap_backpack", "necklace overwrote remaining backpack")
local removedbackpack = backpack
backpack = nil
removedbackpack.components.equippable.onunequipfn(removedbackpack, owner)
if events.unequip then events.unequip(owner, {eslot = "back"}) end
assert(anim.build == "amulets", "backpack removal must restore remaining necklace")

local function checkwidget(path, method, strict)
    local seen
    local widget = {recipe = {}, owner = {replica = {inventory = {
        GetEquippedItem = function(self, slot) seen = slot; return slot == "neck" and {prefab = "greenamulet"} or nil end,
    }}}}
    widget[method] = function(self)
        local item = self.owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        self.showamulet = item and item.prefab == "greenamulet"
    end
    if strict then
        local original = {EQUIPSLOTS = EQUIPSLOTS}
        setmetatable(original, {__index = function(_, key)
            error("variable '" .. key .. "' is not declared", 2)
        end})
        setfenv(widget[method], original)
    end
    local constructor = assert(classes[path], path .. " post-constructor was not registered")
    local ok, err = pcall(constructor, widget)
    assert(ok, path .. " crashed under its original function environment: " .. tostring(err))
    widget[method](widget, widget.recipe)
    assert(widget.showamulet and seen == "neck", path .. " did not find green necklace")
    assert(EQUIPSLOTS.BODY == "body", "UI compatibility changed global equipment slots")
end
checkwidget("widgets/redux/craftingmenu_ingredients", "SetRecipe", true)
checkwidget("widgets/recipepopup", "Refresh")
print("inventory45 compatibility tests passed")
