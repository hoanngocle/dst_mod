local function run(config, standalone_owner)
    local manifests, rpc, damage_handler = {}, nil, nil
    local host_prefabs, host_assets = { "host_prefab" }, { "host_asset" }
    local game = {
        TUNING = { HH_CAN_SHOW_TEXT_FX = true },
        rawget = rawget, rawset = rawset, setmetatable = setmetatable, setfenv = setfenv,
        ipairs = ipairs, pairs = pairs, type = type, error = error, print = function() end,
        table = table,
        ManifestManager = { AddFileToModManifest = function(_, _, path) manifests[#manifests + 1] = path end },
        TheNet = { IsDedicated = function() return true end, GetIsServer = function() return false end },
        kleiloadlua = function(path)
            if path:find("ttk_hud_modutil", 1, true) then
                return loadstring("PrefabFiles = {}; Assets = {}; postinitfns.private=true; function AddClassPostInit() end")
            elseif path:find("ttk_hud_simutil", 1, true) then
                return loadstring("")
            elseif path:find("epic_runtime", 1, true) then
                return loadstring("PrefabFiles[#PrefabFiles+1]='ttk_hud_epichealth_proxy'; Assets[#Assets+1]='epic_asset'")
            end
        end,
    }
    game.SCHUD_STANDALONE_OWNER = standalone_owner
    GLOBAL, env, modname, MODROOT, modinfo = game,
        { postinitfns = { host = true }, postinitdata = { host = true }, false_sentinel = false },
        "PhamNhanTuTien", "mods/PhamNhanTuTien/", {}
    PrefabFiles, Assets = host_prefabs, host_assets
    GetModConfigData = function(name) error("HUD must not read removed config: " .. name) end
    Asset = function(kind, path) return kind .. ":" .. path end
    AddClientModRPCHandler = function(namespace, name, fn) rpc = namespace .. ":" .. name; damage_handler = fn end
    package.preload["ttk_hud/core"] = function() return {} end
    package.preload["ttk_hud/overhead"] = function() return { install = function() end } end
    package.preload["ttk_hud/server_damage"] = function() return { install = function() end } end
    dofile("main/ttk_combat_hud.lua")
    return game, host_prefabs, host_assets, manifests, rpc, env, damage_handler
end

local fixed, prefabs = run({ ttk_hud_enabled = false, ttk_hud_show_others = true })
assert(fixed.TTK_COMBAT_HUD_OWNER == "PhamNhanTuTien" and #prefabs > 1, "old config cannot disable integrated HUD")
for _, key in ipairs({"ENABLED", "BOSS_BAR", "OVERHEAD_BAR", "HIDE_BOSS_OVERHEAD", "SHOW_VALUES", "DAMAGE_NUMBERS"}) do
    assert(fixed.TUNING.TTK_HUD[key] == true, key .. " must stay enabled")
end
assert(fixed.TUNING.TTK_HUD.SHOW_OTHERS == false, "old config cannot enable teammate damage")

local blocked, blocked_prefabs = run({}, "SoloCombatHUD")
assert(blocked.TTK_COMBAT_HUD_OWNER == nil and #blocked_prefabs == 1, "standalone-first guard prevents duplicate integrated hooks")

local game, prefabs, assets, manifests, rpc, host_env, damage_handler = run({})
assert(game.TTK_COMBAT_HUD_OWNER == "PhamNhanTuTien", "integrated owner marker set")
assert(game.TUNING.TTK_HUD.ENABLED and game.TUNING.TTK_HUD.BOSS_BAR, "HUD defaults enabled")
assert(game.TUNING.TTK_HUD.SHOW_OTHERS == false, "nearby teammate popups default off")
assert(game.TUNING.HH_CAN_SHOW_TEXT_FX == false, "combat text disabled only when HUD loads")
assert(prefabs[1] == "host_prefab" and prefabs[2] == "ttk_hud_epichealth_proxy"
    and prefabs[3] == "ttk_hud_damage_number", "host prefab array preserved and HUD appended")
assert(assets[1] == "host_asset" and #assets >= 4, "host asset array preserved and HUD appended")
assert(#manifests >= 15, "HUD runtime registered with ManifestManager")
assert(rpc == "ttk_hud:damage", "integrated RPC namespace registered")
assert(host_env.postinitfns.host and host_env.postinitfns.private == nil and host_env.postinitdata.host,
    "child helper registries do not mutate host mod environment")
assert(host_env.false_sentinel == false, "child fallback preserves false host values")

game.SpawnPrefab = function()
    return { IsValid = function() return true end, Display = function() end }
end
setmetatable(game, {
    __index = function(_, key) error("variable '" .. key .. "' is not declared", 2) end,
    __newindex = function(_, key) error("assign to undeclared variable '" .. key .. "'", 2) end,
})
damage_handler(1, 10, 'normal', 0, 0, 0)
damage_handler(1, 10, 'normal', 0, 0, 0)
assert(#rawget(game, 'TTK_HUD_POPUPS') == 2, 'first damage initializes and reuses popup registry')

local modmain = assert(io.open("modmain.lua", "r")):read("*all")
local solo_at = assert(modmain:find('modimport%("main/ttk_solo_bootstrap.lua"%)'))
local hud_at = assert(modmain:find('modimport%("main/ttk_combat_hud.lua"%)'))
assert(solo_at < hud_at, "HUD loads after integrated Solo bootstrap")

local standalone = assert(io.open("../SoloCombatHUD/modmain.lua", "r")):read("*all")
local owner_guard = assert(standalone:find('rawget%(G, "TTK_COMBAT_HUD_OWNER"%)'))
local standalone_marker = assert(standalone:find('G%.SCHUD_STANDALONE_OWNER = modname'))
assert(owner_guard < standalone_marker, "standalone HUD exits before hooks when integrated owner loaded first")

print("Phàm Nhân HUD bootstrap: isolation, arrays, defaults, guard, ordering passed")
