local MAX_COINS = 2000000000

local HHDungeonCoin = Class(function(self, inst)
    self.inst = inst
    self.version = 1
    self.coins = 0
    self.pending = {}
    self.notice = ""
end)

local function Clamp(value)
    return math.max(0, math.min(MAX_COINS, math.floor(tonumber(value) or 0)))
end

function HHDungeonCoin:Sync()
    if self.inst.hh_dungeon_coins then
        self.inst.hh_dungeon_coins:set(Clamp(self.coins))
    end
    if self.inst.hh_dungeon_coin_pending then
        local values = {}
        for reward_id, amount in pairs(self.pending) do
            table.insert(values, tostring(reward_id) .. ":" .. tostring(Clamp(amount)))
        end
        table.sort(values)
        self.inst.hh_dungeon_coin_pending:set(table.concat(values, ","))
    end
    if self.inst.hh_dungeon_coin_notice then
        self.inst.hh_dungeon_coin_notice:set(self.notice or "")
    end
end

function HHDungeonCoin:GetBalance()
    return Clamp(self.coins)
end

function HHDungeonCoin:Add(amount, reason)
    amount = Clamp(amount)
    if amount <= 0 then return 0 end
    local before = self:GetBalance()
    self.coins = Clamp(before + amount)
    local added = self.coins - before
    if added > 0 then
        self.notice = "+" .. tostring(added) .. " Xu Hầm ngục"
        self.inst:PushEvent("hh_dungeon_coin_changed", { amount = added, reason = reason })
        self:Sync()
    end
    return added
end

function HHDungeonCoin:Spend(amount)
    amount = Clamp(amount)
    if amount <= 0 or self:GetBalance() < amount then
        return false
    end
    self.coins = self.coins - amount
    self:Sync()
    return true
end

function HHDungeonCoin:AddPending(reward_id, amount)
    if reward_id == nil then return false end
    amount = Clamp(amount)
    if amount <= 0 then return false end
    reward_id = tostring(reward_id)
    self.pending[reward_id] = Clamp((self.pending[reward_id] or 0) + amount)
    self:Sync()
    return true
end

function HHDungeonCoin:ClaimPending()
    local total = 0
    for reward_id, amount in pairs(self.pending) do
        total = total + Clamp(amount)
        self.pending[reward_id] = nil
    end
    if total > 0 then
        self:Add(total, "pending_reward")
    else
        self:Sync()
    end
    return total
end

function HHDungeonCoin:SetNotice(message)
    self.notice = tostring(message or "")
    self:Sync()
end

function HHDungeonCoin:OnSave()
    return {
        version = self.version,
        coins = Clamp(self.coins),
        pending = self.pending,
    }
end

function HHDungeonCoin:OnLoad(data)
    if data == nil then
        self:Sync()
        return
    end
    self.coins = Clamp(data.coins)
    self.pending = {}
    for reward_id, amount in pairs(data.pending or {}) do
        local value = Clamp(amount)
        if value > 0 then
            self.pending[tostring(reward_id)] = value
        end
    end
    self:Sync()
end

return HHDungeonCoin
