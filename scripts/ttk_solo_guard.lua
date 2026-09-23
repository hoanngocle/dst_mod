-- Run before either entrypoint installs hooks. Keep the original Solo disabled.
local M = {}

function M.Check(g, current_mod)
    local index = g.KnownModIndex
    if index == nil or index.GetModsToLoad == nil then return end
    -- Worldgen has no TheSim. This is the same cached index used by the loader.
    for _, id in ipairs(index:GetModsToLoad(true)) do
        if id ~= current_mod then
            local info = index.GetModInfo ~= nil and index:GetModInfo(id) or nil
            local name = info ~= nil and info.name or ""
            local normalized = string.lower(name):gsub("%s+", "")
            if id == "workshop-3780347550" or id == "3780347550"
                or string.lower(id) == "sololeveling"
                or normalized == "sololeveling" or normalized == "【sololeveling】" then
                error("Phàm Nhân Tu Tiên đã tích hợp Solo Leveling. Hãy tắt mod Solo riêng ("
                    .. id .. ") và chỉ bật Phàm Nhân Tu Tiên để tránh chạy trùng hệ thống.", 0)
            end
        end
    end
end

return M
