-- Three independent breeding slots. DST Timer owns elapsed time and save/load.
local function TimerName(slot) return "ttk_fish_" .. slot end
local FishPond = Class(function(self, inst)
    self.inst = inst
    self.fish = {}
end)

function FishPond:HasSpace()
    for i = 1, 3 do if self.fish[i] == nil then return true end end
    return false
end

function FishPond:AddFish(prefab)
    for i = 1, 3 do
        if self.fish[i] == nil then
            self.fish[i] = prefab
            local timer = self.inst.components.timer
            timer:StopTimer(TimerName(i))
            timer:StartTimer(TimerName(i), 7 * TUNING.TOTAL_DAY_TIME)
            return true
        end
    end
    return false
end

function FishPond:IsReady(slot)
    if self.fish[slot] == nil then return false end
    local left = self.inst.components.timer:GetTimeLeft(TimerName(slot))
    return left == nil or left <= 0
end

function FishPond:Harvest(doer)
    local harvested = false
    for i = 1, 3 do
        if self:IsReady(i) then
            local prefab = self.fish[i]
            self.fish[i] = nil
            self.inst.components.timer:StopTimer(TimerName(i))
            for _ = 1, 4 do
                local fish = SpawnPrefab(prefab)
                if fish ~= nil then
                    fish.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
                    if doer ~= nil and doer.components.inventory ~= nil then
                        doer.components.inventory:GiveItem(fish, nil, self.inst:GetPosition())
                    end
                end
            end
            harvested = true
        end
    end
    return harvested
end

function FishPond:ReleaseAll()
    self:Harvest(nil)
    for i = 1, 3 do
        if self.fish[i] ~= nil then
            local fish = SpawnPrefab(self.fish[i])
            if fish ~= nil then fish.Transform:SetPosition(self.inst.Transform:GetWorldPosition()) end
            self.fish[i] = nil
            self.inst.components.timer:StopTimer(TimerName(i))
        end
    end
end

function FishPond:OnSave()
    local fish = {}
    for i = 1, 3 do fish[tostring(i)] = self.fish[i] end
    return {fish = fish}
end

function FishPond:OnLoad(data)
    self.fish = {}
    for i = 1, 3 do
        local prefab = data ~= nil and data.fish ~= nil and data.fish[tostring(i)] or nil
        if type(prefab) == "string" then self.fish[i] = prefab end
    end
end

return FishPond
