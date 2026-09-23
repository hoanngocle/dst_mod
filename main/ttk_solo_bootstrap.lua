-- Preserve the original order: TuTienKy (priority 0), then Solo (priority -10).
-- Solo assigns its own PrefabFiles/Assets; merge them back into the host lists.
if GLOBAL.rawget(env, "_ttk_solo_loaded") then return end
local host_prefabs = PrefabFiles or {}
local host_assets = Assets or {}

modimport("main/ttk_solo_source.lua")

local seen = {}
for _, name in ipairs(host_prefabs) do seen[name] = true end
for _, name in ipairs(PrefabFiles or {}) do
    if not seen[name] then
        host_prefabs[#host_prefabs + 1] = name
        seen[name] = true
    end
end
for _, asset in ipairs(Assets or {}) do
    host_assets[#host_assets + 1] = asset
end
PrefabFiles = host_prefabs
Assets = host_assets
env._ttk_solo_loaded = true
