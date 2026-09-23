-- Keep the unpaid queue in save data, including saves during the spin animation.
local prizes = require("ttk_slot_prizes")
local function Master() return TheWorld ~= nil and TheWorld.ismastersim == true end
local SlotMachine = Class(function(self, inst)
    self.inst = inst
    self.busy = false
    self.sequence = 0
end)

function SlotMachine:Receipt(event, data)
    if not Master() or self.actor_id == nil then return end
    for _, actor in ipairs(AllPlayers or {}) do
        if actor.userid == self.actor_id and actor:IsValid() then
            data.receipt_id = self.receipt_id .. ":" .. tostring(data.index or "spin")
            actor:PushEvent(event, data)
            return
        end
    end
end

function SlotMachine:CanAccept(item)
    return not self.busy and item ~= nil and item.prefab == "ttk_lingshi2"
end

function SlotMachine:Start(prize, actor)
    if not Master() or self.busy or prize == nil or prize.items == nil or #prize.items == 0
        or actor == nil or not actor:IsValid() or not actor:HasTag("player") or actor.userid == nil then return false end
    self.queue = {}
    for _, item in ipairs(prize.items) do
        for i = 1, item.count do self.queue[#self.queue + 1] = item.prefab end
    end
    self.category = prize.category
    self.nextitem = 1
    self.sequence = self.sequence + 1
    self.actor_id = actor.userid
    self.receipt_id = tostring(self.inst.GUID) .. ":" .. tostring(self.sequence)
    self.busy = true
    self:Receipt("ttk_slot_spin_committed", {})
    self.inst:PushEvent("ttk_slot_spin", {category = self.category})
    return true
end

function SlotMachine:Pay()
    if not Master() or not self.busy or self.task ~= nil then return end
    local index, receipt = self.nextitem, self.receipt_id
    self.task = self.inst:DoTaskInTime(.25, function()
        if not Master() or not self.busy or self.nextitem ~= index or self.receipt_id ~= receipt then return end
        self.task = nil
        local name = self.queue[self.nextitem]
        if name ~= nil then
            local item = self.inst:DispensePrize(name)
            if item == nil then self:Pay(); return end
            -- Commit the cursor before publishing: retries and save/load cannot replay this item.
            self.nextitem = self.nextitem + 1
            self:Receipt("ttk_slot_reward_committed", { prefab=item.prefab,
                source="ttk_choujiangji", kind=prizes.Classify(item.prefab), index=index })
        end
        if self.nextitem > #self.queue then
            self.busy = false
            self.queue = nil
            self.inst:PushEvent("ttk_slot_done")
        else
            self:Pay()
        end
    end)
end

function SlotMachine:OnSave()
    local queue = nil
    if self.busy then
        queue = {}
        for i, name in ipairs(self.queue) do queue[i] = name end
    end
    return {queue=queue, category=self.category, nextitem=self.nextitem,
        actor_id=self.actor_id, receipt_id=self.receipt_id, sequence=self.sequence}
end

function SlotMachine:OnLoad(data)
    if not Master() then return end
    if self.task ~= nil then self.task:Cancel(); self.task=nil end
    self.sequence = data ~= nil and data.sequence or 0
    if data == nil or data.queue == nil or #data.queue == 0 then return end
    self.queue = data.queue
    self.category = data.category
    self.nextitem = data.nextitem or 1
    self.actor_id = data.actor_id
    self.receipt_id = data.receipt_id
    self.busy = self.nextitem <= #self.queue
    if self.busy then self:Pay() end
end

function SlotMachine:OnRemoveFromEntity()
    if self.task ~= nil then self.task:Cancel(); self.task = nil end
end

return SlotMachine
