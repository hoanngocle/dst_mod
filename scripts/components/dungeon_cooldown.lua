local DungeonCooldown = Class(function(self, inst)
    self.inst = inst
    self.timer = 0
end)

function DungeonCooldown:StartTimer(time)
    self.timer = time
    if self.task then
        self.task:Cancel()
    end
    self.task = self.inst:DoPeriodicTask(1, function()
        self.timer = self.timer - 1
        if self.timer <= 0 then
            self.timer = 0
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
        end
    end)
end

function DungeonCooldown:GetTime()
    return self.timer
end

function DungeonCooldown:OnSave()
    return {timer = self.timer}
end

function DungeonCooldown:OnLoad(data)
    if data and data.timer then
        self:StartTimer(data.timer)
    end
end

return DungeonCooldown
