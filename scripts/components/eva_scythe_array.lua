local Common = require "util/eva_scythe_array_common"

local EvaScytheArray = Class(function(self, inst)
    self.inst = inst
    self.cooldown_end = 0
    self.controller = nil

    self._ondeath = function() self:Stop("death") end
    self._onghost = function() self:Stop("ghost") end
    self._onremove = function() self:Stop("remove") end
    inst:ListenForEvent("death", self._ondeath)
    inst:ListenForEvent("ms_becameghost", self._onghost)
    inst:ListenForEvent("onremove", self._onremove)
end)

function EvaScytheArray:GetCooldownRemaining()
    return math.max(0, self.cooldown_end - GetTime())
end

function EvaScytheArray:_Say(message)
    local talker = self.inst.components ~= nil and self.inst.components.talker or nil
    if talker ~= nil then talker:Say(message) end
end

function EvaScytheArray:_OnControllerRemoved(controller)
    if self.controller == controller then self.controller = nil end
end

function EvaScytheArray:CastAt(x, z)
    if not require("util/eva_progression").Check(self.inst, "array") then return false, "level_locked" end
    local valid, reason = Common.ValidateCenter(self.inst, x, z)
    if not valid then return false, reason end

    local remaining = self:GetCooldownRemaining()
    if remaining > 0 then
        self:_Say("Huyền Thiên Trảm Linh Kiếm hồi sau "
            .. tostring(math.ceil(remaining)) .. " giây.")
        return false, "cooldown"
    end
    local souls = self.inst.components ~= nil and self.inst.components.eva_souls or nil
    if souls == nil or souls.current < Common.SOUL_COST then
        self:_Say("Cần " .. tostring(Common.SOUL_COST) .. " Hồn Lực để thi triển Huyền Thiên Trảm Linh Kiếm.")
        return false, "insufficient_souls"
    end

    local controller = SpawnPrefab("eva_scythe_array_controller")
    if controller == nil then return false, "spawn_failed" end
    controller.Transform:SetPosition(x, 0, z)
    controller.owner_component = self
    if controller.Start == nil or not controller:Start(self.inst, x, z) then
        if controller:IsValid() then controller:Remove() end
        return false, "spawn_failed"
    end

    self.controller = controller
    souls:DoDelta(-Common.SOUL_COST)
    self.cooldown_end = GetTime() + Common.COOLDOWN
    self:_Say("Huyền Thiên Trảm Linh Kiếm!")
    return true, "cast"
end

function EvaScytheArray:Stop(reason)
    local controller = self.controller
    self.controller = nil
    if controller ~= nil and controller:IsValid() then
        if controller.Stop ~= nil then controller:Stop(reason) end
        controller:Remove()
    end
    return controller ~= nil, reason
end

function EvaScytheArray:OnSave()
    local remaining = self:GetCooldownRemaining()
    return remaining > 0 and {cooldown = remaining} or nil
end

function EvaScytheArray:OnLoad(data)
    self:Stop("load")
    local remaining = data ~= nil and tonumber(data.cooldown) or 0
    self.cooldown_end = GetTime()
        + math.max(0, math.min(Common.COOLDOWN, remaining or 0))
end

function EvaScytheArray:OnRemoveFromEntity()
    self:Stop("component_removed")
    self.inst:RemoveEventCallback("death", self._ondeath)
    self.inst:RemoveEventCallback("ms_becameghost", self._onghost)
    self.inst:RemoveEventCallback("onremove", self._onremove)
end

return EvaScytheArray
