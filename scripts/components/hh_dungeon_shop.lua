local ShopDefs = require("dungeon_shop/hh_dungeon_shop_defs")
local IsSurfaceAuthority = require("utils/hh_dungeon_authority")

local function GetCycle()
    local days = TUNING.HH_DUNGEON_SHOP and TUNING.HH_DUNGEON_SHOP.RESET_DAYS or 2
    return math.floor((TheWorld.state.cycles or 0) / math.max(1, days))
end

local function EncodeList(values)
    local result = {}
    for _, value in ipairs(values or {}) do
        local index = ShopDefs.GetIndex(value)
        if index ~= nil then table.insert(result, tostring(index)) end
    end
    return table.concat(result, ",")
end

local function EncodeStock(active, stock)
    local result = {}
    for _, id in ipairs(active or {}) do
        local index = ShopDefs.GetIndex(id)
        if index ~= nil then
            table.insert(result, tostring(index) .. ":" .. tostring(math.max(0, math.floor(stock[id] or 0))))
        end
    end
    return table.concat(result, ",")
end

local function DeterministicShuffle(pool, seed)
    for i = #pool, 2, -1 do
        seed = (seed * 1103515245 + 12345) % 2147483648
        local j = (seed % i) + 1
        pool[i], pool[j] = pool[j], pool[i]
    end
end

local HHDungeonShop = Class(function(self, inst)
    self.inst = inst
    self.version = 1
    self.cycle_id = -1
    self.active = {}
    self.stock = {}
end)

function HHDungeonShop:Reset(cycle_id)
    self.cycle_id = cycle_id or GetCycle()
    self.active = {}
    self.stock = {}
    local categories = { "player_potion", "disciple_potion", "qol", "weapon" }
    for category_index, category in ipairs(categories) do
        local pool = {}
        for _, product in ipairs(ShopDefs.list) do
            if product.category == category then table.insert(pool, product.id) end
        end
        DeterministicShuffle(pool, self.cycle_id * 97 + category_index * 7919)
        for index = 1, math.min(10, #pool) do
            local id = pool[index]
            table.insert(self.active, id)
            self.stock[id] = ShopDefs.Get(id).stock or 1
        end
    end
    self:Sync()
end

function HHDungeonShop:EnsureCycle()
    local cycle = GetCycle()
    if self.cycle_id ~= cycle or #self.active == 0 then self:Reset(cycle) end
end

function HHDungeonShop:IsActive(id)
    for _, active_id in ipairs(self.active) do
        if active_id == id then return true end
    end
    return false
end

function HHDungeonShop:RestockOne()
    self:EnsureCycle()
    local changed = false
    local first_id = nil
    for _, id in ipairs(self.active) do
        local product = ShopDefs.Get(id)
        if product ~= nil and self.stock[id] == 0 then
            self.stock[id] = 1
            changed = true
            first_id = first_id or id
        end
    end
    if changed then self:Sync() end
    return changed, first_id
end

function HHDungeonShop:SyncToPlayer(player)
    if player == nil or not player:IsValid() then return end
    if player.hh_dungeon_shop_cycle_client then player.hh_dungeon_shop_cycle_client:set(self.cycle_id) end
    if player.hh_dungeon_shop_products_client then player.hh_dungeon_shop_products_client:set(EncodeList(self.active)) end
    if player.hh_dungeon_shop_stock_client then player.hh_dungeon_shop_stock_client:set(EncodeStock(self.active, self.stock)) end
end

function HHDungeonShop:Sync()
    if self.inst.hh_dungeon_shop_cycle then self.inst.hh_dungeon_shop_cycle:set(self.cycle_id) end
    if self.inst.hh_dungeon_shop_products then self.inst.hh_dungeon_shop_products:set(EncodeList(self.active)) end
    if self.inst.hh_dungeon_shop_stock then self.inst.hh_dungeon_shop_stock:set(EncodeStock(self.active, self.stock)) end
    for _, player in ipairs(AllPlayers or {}) do
        self:SyncToPlayer(player)
    end
end

function HHDungeonShop:Purchase(player, id)
    if not IsSurfaceAuthority(TheWorld) or player == nil or not player:IsValid()
        or not player:HasTag("player") or player:HasTag("playerghost")
        or player:HasTag("hh_dungeon_transition") then return false, "Giao dịch không khả dụng." end
    self:EnsureCycle()
    local product = ShopDefs.Get(id)
    local wallet = player and player.components.hh_dungeon_coin
    if product == nil or wallet == nil or not self:IsActive(id) then return false, "Sản phẩm không khả dụng." end
    if (self.stock[id] or 0) <= 0 then return false, "Món đồ này đã hết hàng, hãy quay lại vào khi khác !" end
    if wallet:GetBalance() < product.price then return false, "Bạn không có đủ xu mà mua cái gì ?" end
    local item = SpawnPrefab(product.prefab_id or "hh_dungeon_potion")
    if item == nil then return false, "Không thể tạo vật phẩm." end
    if product.category ~= "weapon" then
        if item.SetDungeonProduct == nil or not item:SetDungeonProduct(product.id) then
            item:Remove()
            return false, "Không thể cấu hình sản phẩm."
        end
    end
    local inventory = player.components.inventory
    if inventory == nil or not inventory:GiveItem(item) then
        item:Remove()
        return false, "Kho đồ không đủ chỗ."
    end
    if not wallet:Spend(product.price) then
        inventory:RemoveItem(item, true)
        item:Remove()
        return false, "Giao dịch đã hủy."
    end
    self.stock[id] = self.stock[id] - 1
    self:Sync()
    wallet:SetNotice("Đã mua " .. tostring(product.name or id) .. ".")
    player:PushEvent("hh_dungeon_shop_purchased", { product_id=id, cost=product.price })
    return true
end

function HHDungeonShop:OnSave()
    self:EnsureCycle()
    return { version=self.version, cycle_id=self.cycle_id, active=self.active, stock=self.stock }
end

function HHDungeonShop:OnLoad(data)
    self.cycle_id = data and tonumber(data.cycle_id) or -1
    self.active = {}
    self.stock = {}
    for _, id in ipairs(data and data.active or {}) do
        if ShopDefs.Get(id) then
            table.insert(self.active, id)
            local product = ShopDefs.Get(id)
            self.stock[id] = math.max(0, math.min(product.stock or 1, math.floor(tonumber(data.stock and data.stock[id]) or product.stock or 1)))
        end
    end
    self:EnsureCycle()
    self:Sync()
end

return HHDungeonShop
