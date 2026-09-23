local ShopDefs = require("guild/hh_guild_shop_defs")
local IsSurfaceAuthority = require("utils/hh_dungeon_authority")

local function GetResetDays()
    return TUNING.HH_GUILD and TUNING.HH_GUILD.SHOP_RESET_DAYS or 4
end

local function GetCurrentCycle()
    local days = math.max(1, GetResetDays())
    local cycles = TheWorld and TheWorld.state and TheWorld.state.cycles or 0
    return math.floor(cycles / days)
end

local function EncodeStock(stock)
    local values = {}
    for _, product in ipairs(ShopDefs.list) do
        table.insert(values, tostring(math.max(0, math.floor(stock[product.id] or 0))))
    end
    return table.concat(values, ",")
end

local function EncodeProductIds(product_ids)
    local values = {}
    for _, product_id in ipairs(product_ids or {}) do
        table.insert(values, tostring(product_id))
    end
    return table.concat(values, ",")
end

local function SelectCycleProducts()
    local selected = {}
    for rank = 1, 6 do
        local pool = {}
        for _, product in ipairs(ShopDefs.list) do
            if product.rank == rank then
                table.insert(pool, product.id)
            end
        end
        for index = #pool, 2, -1 do
            local swap_index = math.random(index)
            pool[index], pool[swap_index] = pool[swap_index], pool[index]
        end
        for index = 1, math.min(6, #pool) do
            table.insert(selected, pool[index])
        end
    end
    return selected
end

local HHGuildShop = Class(function(self, inst)
    self.inst = inst
    self.version = 1
    self.cycle_id = -1
    self.stock = {}
    self.active_products = {}
    self:EnsureCycle()
    self:Sync()
end)

function HHGuildShop:ResetStock(cycle_id)
    self.cycle_id = cycle_id or GetCurrentCycle()
    self.stock = {}
    self.active_products = SelectCycleProducts()
    for _, product in ipairs(ShopDefs.list) do
        self.stock[product.id] = product.stock
    end
    self:Sync()
end

function HHGuildShop:EnsureCycle()
    local current = GetCurrentCycle()
    if self.cycle_id ~= current or #self.active_products == 0 then
        self:ResetStock(current)
        return true
    end
    return false
end

function HHGuildShop:Sync()
    if self.inst.hh_guild_shop_cycle then
        self.inst.hh_guild_shop_cycle:set(self.cycle_id)
    end
    if self.inst.hh_guild_shop_stock then
        self.inst.hh_guild_shop_stock:set(EncodeStock(self.stock))
    end
    if self.inst.hh_guild_shop_products then
        self.inst.hh_guild_shop_products:set(EncodeProductIds(self.active_products))
    end
end

function HHGuildShop:IsProductActive(product_id)
    for _, active_id in ipairs(self.active_products) do
        if active_id == product_id then
            return true
        end
    end
    return false
end

function HHGuildShop:GetStock(product_id)
    self:EnsureCycle()
    return math.max(0, math.floor(self.stock[product_id] or 0))
end

function HHGuildShop:Purchase(product_id, purchase_count)
    if not IsSurfaceAuthority(TheWorld) or not self.inst:IsValid()
        or not self.inst:HasTag("player") or self.inst:HasTag("playerghost") then
        return false, "Giao dịch không khả dụng."
    end
    self:EnsureCycle()
    product_id = tonumber(product_id)
    purchase_count = tonumber(purchase_count) or 1
    if product_id == nil or product_id ~= math.floor(product_id)
        or purchase_count ~= math.floor(purchase_count)
        or purchase_count < 1 or purchase_count > 10 then
        return false, "Yêu cầu mua hàng không hợp lệ."
    end

    local product = ShopDefs.Get(product_id)
    local rank = self.inst.components.hh_rank
    if product == nil or rank == nil then
        return false, "Sản phẩm không tồn tại."
    end
    if not self:IsProductActive(product.id) then
        return false, "Sản phẩm không có trong kỳ cửa hàng hiện tại."
    end
    if rank:GetRank() < product.rank then
        return false, "Rank hiện tại chưa được phép mua sản phẩm này."
    end
    if self:GetStock(product.id) < purchase_count then
        return false, "Sản phẩm đã hết stock cá nhân."
    end

    local total_cost = product.price * purchase_count
    if rank.credit < total_cost then
        return false, "Không đủ Xu Hiệp Hội."
    end

    local items = {
        {
            prefab=product.prefab,
            amount=(product.amount or 1) * purchase_count,
        },
    }
    if not rank:CanReceiveItems(items) then
        return false, "Kho đồ không đủ chỗ."
    end

    local credit_before = rank.credit
    if not rank:GiveItems(items, function() return rank:SpendCredit(total_cost) end) then
        rank.credit = credit_before
        rank:Sync()
        return false, "Không thể tạo vật phẩm. Giao dịch đã hủy."
    end

    self.stock[product.id] = self.stock[product.id] - purchase_count
    self:Sync()
    rank:SetNotice("Đã mua " .. tostring((product.amount or 1) * purchase_count) .. " " .. product.name .. ".")
    self.inst:PushEvent("hh_guild_shop_purchased", { product_id=product.id, count=purchase_count, cost=total_cost })
    return true
end

function HHGuildShop:OnSave()
    self:EnsureCycle()
    return {
        version=self.version,
        cycle_id=self.cycle_id,
        stock=self.stock,
        active_products=self.active_products,
    }
end

function HHGuildShop:OnLoad(data)
    if not data then
        self:EnsureCycle()
        return
    end
    self.cycle_id = tonumber(data.cycle_id) or -1
    self.stock = {}
    self.active_products = {}
    for _, product_id in ipairs(data.active_products or {}) do
        product_id = tonumber(product_id)
        if ShopDefs.Get(product_id) then
            table.insert(self.active_products, product_id)
        end
    end
    for _, product in ipairs(ShopDefs.list) do
        local saved = data.stock and tonumber(data.stock[product.id])
        self.stock[product.id] = math.max(0, math.min(product.stock, math.floor(saved or product.stock)))
    end
    self:EnsureCycle()
    self:Sync()
end

return HHGuildShop
