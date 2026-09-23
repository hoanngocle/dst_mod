-- Run from the repository root with a Lua 5.1 runtime.
local path = "scripts/ttk_inventorysort.lua"
assert(io.open(path), "Missing inventory/container sorting integration")
local Sort = dofile(path)
local tasks = {}
local function entity(prefab)
    local inst = {prefab = prefab, components = {}, listeners = {}, events = {}, valid = true}
    function inst:IsValid() return self.valid end
    function inst:HasTag(tag) return tag == "player" and self.prefab == "wilson" end
    function inst:ListenForEvent(event, fn)
        self.listeners[event] = self.listeners[event] or {}
        table.insert(self.listeners[event], fn)
    end
    function inst:PushEvent(event, data)
        table.insert(self.events, {event = event, data = data})
        for _, fn in ipairs(self.listeners[event] or {}) do fn(self, data) end
    end
    function inst:DoTaskInTime(delay, fn)
        local task = {fn = function() fn(self) end}
        function task:Cancel() self.cancelled = true end
        table.insert(tasks, task)
        return task
    end
    return inst
end
local function tick()
    local pending = tasks
    tasks = {}
    for _, task in ipairs(pending) do if not task.cancelled then task.fn() end end
end
local function item(name, count, maxsize)
    local inst = entity(name)
    inst.name = name
    inst.components.inventoryitem = {cangoincontainer = true}
    if count then
        local stack = {n = count, maxsize = maxsize or 40, inst = inst}
        function stack:IsFull() return self.n >= self.maxsize end
        function stack:StackSize() return self.n end
        function stack:CanStackWith(other) return other.prefab == self.inst.prefab and other.components.stackable ~= nil end
        function stack:Put(other)
            assert(self:CanStackWith(other))
            local moved = math.min(other.components.stackable.n, self.maxsize - self.n)
            self.n = self.n + moved
            other.components.stackable.n = other.components.stackable.n - moved
            if other.components.stackable.n == 0 then
                other.valid = false
                return nil
            end
            return other
        end
        inst.components.stackable = stack
    end
    return inst
end
local function storage(prefab, size, contents, inventory)
    local inst = entity(prefab)
    local c = {inst = inst, type = "chest", openlist = {}, acceptsstacks = true}
    c[inventory and "itemslots" or "slots"] = contents or {}
    c.equipslots = {}
    function c:GetNumSlots() return size end
    function c:GetItemInSlot(n) return (self.itemslots or self.slots)[n] end
    function c:CanTakeItemInSlot(it, n)
        return not self.readonlycontainer and (not self.itemtestfn or self:itemtestfn(it, n))
    end
    function c:GetOverflowContainer() return self.overflow end
    function c:GetActiveItem() return self.activeitem end
    function c:IsOpenedBy(player) return self.openlist[player] == true end
    function c:RemoveItemBySlot() error("Must not detach items: infinite stacks can spill") end
    function c:GiveItem() error("Must not reinsert items: pickup effects can run") end
    inst.components[inventory and "inventory" or "container"] = c
    for _, it in pairs(contents or {}) do it.components.inventoryitem.owner = inst end
    return c
end

-- Inventory compacts holes, keeps equipment/cursor and owner, merges compatible stacks.
local rocks1, rocks2, apple = item("rocks", 35), item("rocks", 10), item("apple")
local inv = storage("wilson", 15, {[2] = rocks1, [7] = apple, [14] = rocks2}, true)
local equipped = item("spear")
inv.equipslots.hand = equipped
assert(Sort.Sort(inv))
assert(inv:GetItemInSlot(1) == rocks1 and rocks1.components.stackable.n == 40)
assert(inv:GetItemInSlot(2) == rocks2 and rocks2.components.stackable.n == 5)
assert(inv:GetItemInSlot(3) == apple and inv.equipslots.hand == equipped)
assert(apple.components.inventoryitem.owner == inv.inst)
local count = #inv.inst.events
Sort.Sort(inv)
assert(#inv.inst.events == count, "Already sorted storage must not emit a new event cascade")

-- Upgraded Da Bao Cac must preserve arbitrarily large stacks and refresh all eight display slots.
local huge = item("rocks", 10000, math.huge)
local dbg = storage("ttk_dbg", 36, {[1] = item("zzz"), [8] = huge, [36] = item("aaa")})
dbg.infinitestacksize = true
local display, replica = {}, {}
for i = 1, 36 do replica[i] = dbg:GetItemInSlot(i); if i <= 8 then display[i] = replica[i] end end
dbg.inst:ListenForEvent("itemlose", function(_, data) replica[data.slot] = nil; if data.slot <= 8 then display[data.slot] = nil end end)
dbg.inst:ListenForEvent("itemget", function(_, data) replica[data.slot] = data.item; if data.slot <= 8 then display[data.slot] = data.item end end)
Sort.Sort(dbg)
assert(huge.components.stackable.n == 10000 and huge.components.inventoryitem.owner == dbg.inst)
for i = 1, 36 do assert(replica[i] == dbg:GetItemInSlot(i), "Replica mismatch") end
for i = 1, 8 do assert(display[i] == dbg:GetItemInSlot(i), "Display mismatch") end

-- Locked slots, slot-specific devices and read-only containers remain safe.
local locked = item("locked"); locked.components.inventoryitem.islockedinslot = true
local chest = storage("treasurechest", 9, {[1] = locked, [8] = item("rocks"), [9] = item("aaa")})
Sort.Sort(chest)
assert(chest:GetItemInSlot(1) == locked and chest:GetItemInSlot(2).prefab == "rocks")
chest.readonlycontainer = true
local events = #chest.inst.events
assert(not Sort.Sort(chest) and #chest.inst.events == events)
chest.readonlycontainer = false; chest.usespecificslotsforitems = true
assert(not Sort.Sort(chest))
chest.usespecificslotsforitems = false
chest.itemtestfn = function(_, it, slot) return slot == 8 end
assert(not Sort.Sort(chest), "Do not permute slot-filtered items into invalid slots")

-- Missing names and target-dependent weapon damage cannot crash the comparator.
local unnamed = item("custom_weapon"); unnamed.name = nil
unnamed.components.weapon = {damage = function() error("requires combat target") end, GetDamage = function() error("requires target") end}
local lantern = item("lantern")
lantern.HasTag = function(_, tag) return tag == "light" end
lantern.components.fueled = {GetPercent = function() return 0.5 end}
local mixed = storage("treasurechest", 9, {[1] = unnamed, [5] = lantern})
Sort.Sort(mixed)
assert(mixed:GetItemInSlot(1) == lantern)

-- No sorting on load, item events or opening; only a manual request.
local hooks, rpc, key = {}, nil, nil
local now = 1
local g = {TheWorld = {ismastersim = true}, KEY_G = 103, GetTime = function() return now end,
    TheNet = {IsDedicated = function() return true end}}
local registrations = 0
local env = {GLOBAL = g, modname = "test", AddComponentPostInit = function(n, fn) hooks[n] = fn end,
    AddModRPCHandler = function(_, _, fn) rpc = fn; registrations = registrations + 1 end}
Sort.Install(env)
assert(next(hooks) == nil, "Manual sorter must not install automatic component hooks")
assert(rpc and #tasks == 0)
local a, z = item("aaa"), item("zzz")
inv.itemslots = {[10] = a, [14] = item("rocks")}
local pack = storage("backpack", 8, {[5] = z, [8] = item("rocks")})
pack.type = "pack"
inv.overflow = pack
pack.openlist[inv.inst] = true
inv.opencontainers = {[pack.inst] = true}
inv.inst:PushEvent("itemget", {slot = 10, item = a})
pack.inst:PushEvent("onopen", {doer = inv.inst})
tick()
assert(inv:GetItemInSlot(10) == a and pack:GetItemInSlot(5) == z and #tasks == 0)
rpc(inv.inst)
assert(inv:GetItemInSlot(1).prefab == "rocks" and pack:GetItemInSlot(1).prefab == "rocks")

-- An open chest takes precedence: do not change inventory or backpack.
for _, prefab in ipairs({"treasurechest", "ttk_dbg"}) do
    now = now + 1
    inv.itemslots = {[10] = a}
    pack.slots = {[5] = z}
    local open = storage(prefab, 36, {[8] = item("rocks")})
    local closed = storage("treasurechest", 9, {[8] = item("rocks")})
    open.openlist[inv.inst] = true
    inv.opencontainers = {[pack.inst] = true, [open.inst] = true, [closed.inst] = true}
    open.inst:PushEvent("onopen", {doer = inv.inst})
    tick(); assert(open:GetItemInSlot(8) and not open:GetItemInSlot(1))
    rpc(inv.inst)
    assert(open:GetItemInSlot(1) and closed:GetItemInSlot(8))
    assert(inv:GetItemInSlot(10) == a and pack:GetItemInSlot(5) == z,
        "G with a chest open must only sort the chest")
end

-- A held cursor item cancels the request; releasing it must not queue a sort.
now = now + 1
inv.opencontainers = {}
local cursor = item("cursor"); inv.activeitem = cursor
rpc(inv.inst)
assert(inv:GetItemInSlot(10) == a and pack:GetItemInSlot(5) == z)
inv.activeitem = nil
inv.inst:PushEvent("newactiveitem", {item = nil})
tick(); assert(inv:GetItemInSlot(10) == a and #tasks == 0)
Sort.Install(env)
assert(registrations == 1, "Original and merged mods must not register twice")

-- Fully merged stacks conserve quantities; incompatible stacks stay distinct.
local r1, r2 = item("rocks", 10), item("rocks", 5)
local merge = storage("treasurechest", 9, {[3] = r1, [9] = r2})
Sort.Sort(merge)
assert(r1.components.stackable.n == 15 and not r2:IsValid() and merge.slots[2] == nil)
local h1, h2 = item("rocks", 10000, math.huge), item("rocks", 20000, math.huge)
local infinite = storage("ttk_dbg", 36, {[2] = h1, [35] = h2})
infinite.infinitestacksize = true
Sort.Sort(infinite)
assert(h1.components.stackable.n == 30000 and not h2:IsValid() and infinite.slots[1] == h1)
local skin1, skin2 = item("rocks", 2), item("rocks", 3)
skin1.components.stackable.CanStackWith = function() return false end
local skins = storage("treasurechest", 9, {[8] = skin1, [9] = skin2})
Sort.Sort(skins)
assert(skins.slots[1] == skin1 and skins.slots[2] == skin2)

-- Multiplayer client sends an RPC only from HUD; typing/menu never sorts.
local sends = 0
local clientplayer = entity("wilson")
local screen = {name = "ChatInputScreen"}
local cg = {TheWorld = {ismastersim = false}, KEY_G = 103, ThePlayer = clientplayer,
    TheNet = {IsDedicated = function() return false end},
    TheFrontEnd = {GetActiveScreen = function() return screen end},
    TheInput = {AddKeyDownHandler = function(_, code, fn) assert(code == 103); key = fn end}}
Sort.Install({GLOBAL = cg, modname = "client", AddComponentPostInit = function() end,
    AddModRPCHandler = function() end, MOD_RPC = {client = {ttk_sort_inventory = 7}},
    SendModRPCToServer = function(id) assert(id == 7); sends = sends + 1 end})
key(); assert(sends == 0)
screen.name = "HUD"; key(); assert(sends == 1)
print("PASS: inventory, chests, 36-slot display/replica, infinite stacks, filters, manual-only G, chest priority, RPC, duplicate install")
