local path = "mods/PhamNhanTuTien/scripts/ttk_bossindicators.lua"
assert(io.open(path), "Missing boss indicator integration")
local Bosses = dofile(path)

local function entity(prefab, tags, x, z)
    local listeners = {}
    local inst = {
        prefab = prefab,
        GUID = prefab .. tostring(x or 0),
        valid = true,
        tags = tags or {epic = true},
        replica = {health = {IsDead = function() return false end}},
    }
    inst.Transform = {GetWorldPosition = function() return x or 0, 0, z or 0 end}
    inst.entity = {
        IsVisible = function() return true end,
        FrustumCheck = function() return (x or 0) == 10 end,
    }
    function inst:IsValid() return self.valid end
    function inst:HasTag(tag) return self.tags[tag] == true end
    function inst:GetDisplayName() return self.displayname end
    function inst:ListenForEvent(event, fn)
        listeners[event] = listeners[event] or {}
        table.insert(listeners[event], fn)
    end
    function inst:RemoveEventCallback(event, fn)
        local list = listeners[event] or {}
        for i = #list, 1, -1 do if list[i] == fn then table.remove(list, i) end end
    end
    function inst:PushEvent(event)
        for _, fn in ipairs(listeners[event] or {}) do fn(self) end
    end
    inst.listeners = listeners
    return inst
end

local globals = {
    TUNING = {MAX_INDICATOR_RANGE = 30},
    STRINGS = {NAMES = {HH_IGRIS_DUNGEON = "Igris"}},
    TheSim = {},
}
local major = entity("alterguardian_phase4_lunarrift", nil, 10, 0)
local solo = entity("hh_igris_dungeon", nil, 12, 0)
local future = entity("cosmic_horror_overlord", nil, 14, 0)
local minor = entity("lordfruitfly", nil, 16, 0)
local summon = entity("friendly_shadow", {epic = true, shadow_minion = true}, 18, 0)
local dead = entity("deerclops", nil, 20, 0)
dead.replica.health.IsDead = function() return true end
local tagged_dead = entity("bearger", {epic = true, dead = true}, 22, 0)
tagged_dead.replica.health = nil
local hiding = entity("dragonfly", {epic = true, hiding = true}, 24, 0)
local opted_out = entity("custom_raid_boss", {epic = true, nobossindicator = true}, 26, 0)
assert(Bosses.ShouldTrack(major, globals), "new major base boss was rejected")
assert(Bosses.ShouldTrack(solo, globals), "Solo boss was rejected")
assert(Bosses.ShouldTrack(future, globals), "unknown epic boss lost forward-compatible fallback")
assert(not Bosses.ShouldTrack(minor, globals), "known miniboss entered the large-boss HUD")
assert(not Bosses.ShouldTrack(summon, globals), "friendly summon entered the boss HUD")
assert(not Bosses.ShouldTrack(dead, globals), "dead boss entered the HUD")
assert(not Bosses.ShouldTrack(tagged_dead, globals), "dead tag fallback was ignored")
assert(not Bosses.ShouldTrack(hiding, globals), "hidden boss entered the HUD")
assert(not Bosses.ShouldTrack(opted_out, globals), "boss opt-out tag was ignored")

assert(Bosses.GetDisplayName(solo, globals) == "Igris")
assert(Bosses.GetDisplayName(future, globals) == "Cosmic Horror Overlord")
local antlion_icon = Bosses.GetIndicatorConfig(entity("antlion"), globals)
assert(antlion_icon.atlas == "images/ttk_bossindicators.xml" and antlion_icon.image == "Antlion.tex")
local fallback = Bosses.GetIndicatorConfig(future, globals)
assert(fallback.atlas == "images/avatars.xml" and fallback.image == "avatar_unknown.tex")

local owner = entity("wilson", {player = true}, 0, 0)
local hud = {owner = owner, under_root = {}}
local nearby = {major, solo, future, minor, summon, dead}
globals.TheSim.FindEntities = function(_, x, y, z, range, must, cant)
    assert(range == 45 and must[1] == "epic")
    return nearby
end
local created, killed = 0, 0
local function factory(target, config)
    created = created + 1
    assert(config.name == Bosses.GetDisplayName(target, globals))
    return {Kill = function() killed = killed + 1 end}
end
Bosses.RefreshHUD(hud, globals, factory)
assert(created == 2, "only off-screen trackable bosses should create indicators")
Bosses.RefreshHUD(hud, globals, factory)
assert(created == 2, "repeat scan duplicated indicators")
future:PushEvent("death")
assert(killed == 1, "death did not remove the stale indicator immediately")
nearby = {}
Bosses.RefreshHUD(hud, globals, factory)
assert(killed == 2 and next(hud._ttk_bossindicators) == nil, "range/despawn cleanup failed")

nearby = {solo}
Bosses.RefreshHUD(hud, globals, factory)
Bosses.CleanupHUD(hud)
assert(killed == 3 and hud._ttk_bossindicators == nil, "HUD teardown leaked indicators")

-- The delivered widget must call the current TargetIndicator constructor and
-- replace its label with the controller's safe display name.
Class = function(base, ctor)
    local class = {_ctor = ctor}
    setmetatable(class, {
        __index = base,
        __call = function(_, ...)
            local instance = setmetatable({}, {__index = class})
            ctor(instance, ...)
            return instance
        end,
    })
    return class
end
local base_ctor_calls = 0
package.preload["widgets/targetindicator"] = function()
    return {_ctor = function(self, widget_owner, target, data)
        base_ctor_calls = base_ctor_calls + 1
        self.owner, self.target, self.config_data = widget_owner, target, data
        self.name_label = {SetString = function(label, value) label.value = value end}
    end}
end
local BossIndicator = dofile("mods/PhamNhanTuTien/scripts/widgets/ttk_bossindicator.lua")
package.preload["widgets/ttk_bossindicator"] = function() return BossIndicator end
local actual_widget = BossIndicator(owner, future, {name = "Cosmic Horror Overlord"})
assert(base_ctor_calls == 1 and actual_widget.name_label.value == "Cosmic Horror Overlord",
    "widget does not honor the current TargetIndicator constructor contract")

local registrations = 0
local dedicated = {GLOBAL = {TheNet = {IsDedicated = function() return true end}}}
dedicated.AddClassPostConstruct = function() registrations = registrations + 1 end
assert(not Bosses.Install(dedicated) and registrations == 0, "dedicated server installed HUD code")
local installed_hook
local client_global = {
    TheNet = {IsDedicated = function() return false end},
    TheSim = {FindEntities = function() return {solo} end},
    TUNING = {MAX_INDICATOR_RANGE = 30},
    STRINGS = globals.STRINGS,
}
-- DST's strict GLOBAL rejects undeclared reads and writes inside Install.
-- A plain table hides the client startup crash (dedicated servers skip it).
setmetatable(client_global, {
    __index = function(_, name)
        error("variable '" .. name .. "' is not declared", 2)
    end,
    __newindex = function(_, name)
        error("assign to undeclared variable '" .. name .. "'", 2)
    end,
})
local client = {GLOBAL = client_global, AddClassPostConstruct = function(pathname, fn)
    assert(pathname == "screens/playerhud" and type(fn) == "function")
    installed_hook = fn
    registrations = registrations + 1
end}
assert(Bosses.Install(client) and registrations == 1)
assert(not Bosses.Install(client) and registrations == 1, "duplicate install registered another HUD hook")
local updates, destroys, hud_kills = 0, 0, 0
local live_hud = {
    owner = owner,
    under_root = {AddChild = function(_, widget)
        widget.Kill = function() hud_kills = hud_kills + 1 end
        return widget
    end},
    OnUpdate = function() updates = updates + 1 end,
    OnDestroy = function() destroys = destroys + 1 end,
}
installed_hook(live_hud)
live_hud:OnUpdate(0)
assert(updates == 1 and live_hud._ttk_bossindicators[solo] ~= nil,
    "installed HUD update did not preserve the original or create an indicator")
live_hud:OnDestroy()
assert(destroys == 1 and hud_kills == 1 and live_hud._ttk_bossindicators == nil,
    "installed HUD destroy did not clean up before preserving the original")

print("boss indicator tests passed")
