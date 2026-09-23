-- Built-in combat HUD for Phàm Nhân Tu Tiên.
-- Epic's compatibility utilities execute in a child mod environment because
-- their loader intentionally replaces PrefabFiles/Assets and helper symbols.
local G = GLOBAL

if G.rawget(G, "SCHUD_STANDALONE_OWNER") ~= nil then
    G.print("[Phàm Nhân] Combat HUD tích hợp không nạp vì bản SoloCombatHUD độc lập đã nạp trước.")
    return
end
if G.rawget(G, "TTK_COMBAT_HUD_OWNER") ~= nil then return end
G.TTK_COMBAT_HUD_OWNER = modname

-- HUD luôn bật theo thiết lập cố định; không đọc config cũ.

G.TUNING.TTK_HUD = {
    ENABLED = true,
    BOSS_BAR = true,
    OVERHEAD_BAR = true,
    HIDE_BOSS_OVERHEAD = true,
    SHOW_VALUES = true,
    DAMAGE_NUMBERS = true,
    SHOW_OTHERS = false,
}

-- Solo combat phrases are replaced by typed HUD popups. The bridge selectively
-- restores EXP, quest and level notifications through their existing APIs.
G.TUNING.HH_CAN_SHOW_TEXT_FX = false

local runtime_files = {
    "main/ttk_combat_hud.lua",
    "scripts/ttk_hud/core.lua", "scripts/ttk_hud/epic_runtime.lua",
    "scripts/ttk_hud/overhead.lua", "scripts/ttk_hud/resolver.lua",
    "scripts/ttk_hud/server_damage.lua", "scripts/ttk_hud/solo_bridge.lua",
    "scripts/util/ttk_hud_modutil.lua", "scripts/util/ttk_hud_simutil.lua",
    "scripts/util/ttk_hud_persistentdata.lua",
    "scripts/widgets/ttk_hud_epichealthbar.lua", "scripts/widgets/ttk_hud_overhead.lua",
    "scripts/widgets/ttk_hud_standard_bar.lua",
    "scripts/prefabs/ttk_hud_damage_number.lua", "scripts/prefabs/ttk_hud_epichealth_proxy.lua",
    "scripts/prefabs/ttk_hud_overhead_proxy.lua",
}
for _, path in G.ipairs(runtime_files) do
    G.ManifestManager:AddFileToModManifest(modname, path)
end

local function append_unique(list, value)
    for _, existing in G.ipairs(list) do if existing == value then return end end
    list[#list + 1] = value
end

local child = {
    GLOBAL = G, env = nil, modname = modname, MODROOT = MODROOT, modinfo = modinfo,
    PrefabFiles = {}, Assets = {}, postinitfns = {}, postinitdata = {},
}
child.env = child
G.setmetatable(child, { __index = function(_, key)
    local value = G.rawget(env, key)
    if value ~= nil then return value end
    return G.rawget(G, key)
end })

local function load_child(path)
    local chunk = G.kleiloadlua(MODROOT .. path)
    if G.type(chunk) ~= "function" then G.error(chunk or ("Không nạp được " .. path)) end
    G.setfenv(chunk, child)
    return chunk()
end

G.TTK_HUDCore = require("ttk_hud/core")
child.TTK_HUDCore = G.TTK_HUDCore
load_child("scripts/util/ttk_hud_modutil.lua")
load_child("scripts/util/ttk_hud_simutil.lua")
if G.TUNING.TTK_HUD.BOSS_BAR then load_child("scripts/ttk_hud/epic_runtime.lua") end

for _, prefab in G.ipairs(child.PrefabFiles or {}) do append_unique(PrefabFiles, prefab) end
append_unique(PrefabFiles, "ttk_hud_damage_number")
append_unique(PrefabFiles, "ttk_hud_overhead_proxy")
for _, asset in G.ipairs(child.Assets or {}) do Assets[#Assets + 1] = asset end
Assets[#Assets + 1] = Asset("ATLAS", "images/ttk_dyc_white.xml")
Assets[#Assets + 1] = Asset("IMAGE", "images/ttk_dyc_white.tex")

if not G.TheNet:IsDedicated() and G.TUNING.TTK_HUD.OVERHEAD_BAR then
    child.AddClassPostInit("widgets/controls", function(self)
        local Bar = require("widgets/ttk_hud_overhead")
        self._ttk_hud_overhead_widgets = G.setmetatable({}, { __mode = "k" })
        local function eligible(parent)
            if parent == nil or G.ThePlayer == nil or parent:GetDistanceSqToInst(G.ThePlayer) > 1225 then return false end
            local x, y, z = parent.Transform:GetWorldPosition()
            local sx, sy = G.TheSim:GetScreenPos(x, y + 2.7, z)
            local width, height = G.TheSim:GetScreenSize()
            return sx ~= nil and sy ~= nil and sx >= -80 and sy >= -80 and sx <= width + 80 and sy <= height + 80
        end
        self.inst:DoPeriodicTask(0.25, function()
            local count = 0
            for proxy, widget in G.pairs(self._ttk_hud_overhead_widgets) do
                local parent = proxy:IsValid() and proxy.entity:GetParent() or nil
                if not proxy._visible:value() or not eligible(parent) then
                    widget:Kill()
                    self._ttk_hud_overhead_widgets[proxy] = nil
                else
                    count = count + 1
                end
            end
            for proxy in G.pairs(G.rawget(G, "TTK_HUD_OVERHEAD_PROXIES") or {}) do
                local parent = proxy.entity:GetParent()
                if count < 32 and self._ttk_hud_overhead_widgets[proxy] == nil
                    and proxy._visible:value() and eligible(parent) then
                    self._ttk_hud_overhead_widgets[proxy] = self:AddChild(Bar(proxy))
                    count = count + 1
                end
            end
        end)
    end)
end

if G.TheNet:GetIsServer() then require("ttk_hud/server_damage").install(env) end

AddClientModRPCHandler("ttk_hud", "damage", function(guid, amount, kind, x, y, z)
    if not G.TUNING.TTK_HUD.DAMAGE_NUMBERS then return end
    local active = G.rawget(G, "TTK_HUD_POPUPS")
    if active == nil then
        active = {}
        G.rawset(G, "TTK_HUD_POPUPS", active)
    end
    for i = #active, 1, -1 do if not active[i]:IsValid() then G.table.remove(active, i) end end
    if #active >= 32 then active[1]:Remove(); G.table.remove(active, 1) end
    local same_target = 0
    for _, popup in G.ipairs(active) do if popup._target_guid == guid then same_target = same_target + 1 end end
    local fx = G.SpawnPrefab("ttk_hud_damage_number")
    if fx ~= nil then
        fx._target_guid = guid
        fx:Display(guid, amount, kind, x + (same_target % 3 - 1) * 0.35, y, z)
        active[#active + 1] = fx
    end
end)

require("ttk_hud/overhead").install(env)
