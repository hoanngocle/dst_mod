-- Chuyển thể từ 3075429483 (Antaeogo, dayoumingqi, xuopleu), bản 1.1.5.2b.
-- Giữ bộ xử lý túi đồ của game hiện tại, dùng chung số ô ở hai phía mạng.
local G = GLOBAL
local size = 45 -- Cố định; không đọc config cũ của thế giới.
local oldmax = G.GetMaxItemSlots
G.GetMaxItemSlots = function(mode, ...)
    local base = oldmax(mode, ...)
    if mode == "lavaarena" or mode == "quagmire" or base == 0 then
        return base
    end
    return size
end

for _, file in ipairs({"inventory_bg", "back", "neck"}) do
    table.insert(Assets, Asset("ATLAS", "images/ttk_inventory45/" .. file .. ".xml"))
    table.insert(Assets, Asset("IMAGE", "images/ttk_inventory45/" .. file .. ".tex"))
end

-- Bổ sung vào bảng hiện có; game tự tạo mã mạng ổn định sau khi nạp mod.
G.EQUIPSLOTS.BACK = G.EQUIPSLOTS.BACK or "back"
G.EQUIPSLOTS.NECK = G.EQUIPSLOTS.NECK or "neck"

local backpacks = {"icepack", "backpack", "piggyback", "krampus_sack", "spicepack", "candybag", "seedpouch"}
local amulets = {"amulet", "blueamulet", "purpleamulet", "orangeamulet", "greenamulet", "yellowamulet"}
for _, name in ipairs(backpacks) do
    AddPrefabPostInit(name, function(inst)
        if not G.TheWorld.ismastersim then return end
        if inst.components.equippable then inst.components.equippable.equipslot = G.EQUIPSLOTS.BACK end
    end)
end
for _, name in ipairs(amulets) do
    AddPrefabPostInit(name, function(inst)
        if G.TheWorld.ismastersim and inst.components.equippable then
            inst.components.equippable.equipslot = G.EQUIPSLOTS.NECK
        end
    end)
end

AddComponentPostInit("inventory", function(self)
    local oldoverflow = self.GetOverflowContainer
    self.GetOverflowContainer = function(self, ...)
        if self.ignoreoverflow then return end
        local item = self:GetEquippedItem(G.EQUIPSLOTS.BACK)
        local container = item and item.components.container
        if container and container.canbeopened then return container end
        return oldoverflow(self, ...)
    end
end)

-- Mã dự đoán phía máy khách giữ các hàm dùng chung trong upvalue.
-- Thay đúng hàm lấy ba lô, giữ nguyên Has/RemoveIngredients và quy tắc chế tạo.
local client_overflow
AddPrefabPostInit("inventory_classified", function(inst)
    if G.TheWorld.ismastersim or not inst.GetOverflowContainer then return end
    if client_overflow then
        inst.GetOverflowContainer = client_overflow
        return
    end
    local oldoverflow = inst.GetOverflowContainer
    local function overflow(classified, ...)
        if classified.ignoreoverflow then return end
        local item = classified:GetEquippedItem(G.EQUIPSLOTS.BACK)
        if item and item.replica.container then return item.replica.container end
        return oldoverflow(classified, ...)
    end
    local visited = {}
    local function replace(fn)
        if visited[fn] or fn == oldoverflow or fn == overflow then return end
        visited[fn] = true
        local i = 1
        while true do
            local name, value = G.debug.getupvalue(fn, i)
            if not name then break end
            if value == oldoverflow then
                G.debug.setupvalue(fn, i, overflow)
            elseif G.type(value) == "function" then
                replace(value)
            end
            i = i + 1
        end
    end
    for _, fn in pairs(inst) do
        if G.type(fn) == "function" then replace(fn) end
    end
    client_overflow = overflow
    inst.GetOverflowContainer = overflow
end)

-- Bùa đỏ giữ cơ chế hồi sinh bằng ám của DST hiện tại.
if not G.TheNet:IsDedicated() then
    modimport("main/ttk_inventory45_ui.lua")
end
