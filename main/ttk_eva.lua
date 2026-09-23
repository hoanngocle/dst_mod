-- EVA is bundled; merge its registration lists without replacing host content.
if GLOBAL.rawget(env, "_ttk_eva_loaded") then return end
local index = GLOBAL.KnownModIndex
if index ~= nil and index.GetModsToLoad ~= nil then
    for _, id in ipairs(index:GetModsToLoad(true)) do
        if id ~= modname then
            local info = index.GetModInfo ~= nil and index:GetModInfo(id) or nil
            if info ~= nil and (info.name == "EVA" or info.name == "EVA v1.0") then
                error("Phàm Nhân đã tích hợp EVA. Hãy tắt bản EVA riêng để tránh nạp trùng nhân vật.", 0)
            end
        end
    end
end
local host_prefabs, host_assets = PrefabFiles or {}, Assets or {}
modimport("main/ttk_eva_source.lua")
local seen = {}
for _, name in ipairs(host_prefabs) do seen[name] = true end
for _, name in ipairs(PrefabFiles or {}) do
    if not seen[name] then
        host_prefabs[#host_prefabs + 1] = name
        seen[name] = true
    end
end
for _, asset in ipairs(Assets or {}) do host_assets[#host_assets + 1] = asset end
PrefabFiles, Assets = host_prefabs, host_assets
env._ttk_eva_loaded = true
