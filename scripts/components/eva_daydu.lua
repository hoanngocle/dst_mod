local Common = require "util/eva_combat_common"

local EvaDaydu = Class(function(self, inst)
    self.inst = inst
    self.cooldown_end = 0
    self.projectiles = {}

    self._ondeath = function() self:Stop("death") end
    self._onghost = function() self:Stop("ghost") end
    self._onremove = function() self:Stop("remove") end
    inst:ListenForEvent("death", self._ondeath)
    inst:ListenForEvent("ms_becameghost", self._onghost)
    inst:ListenForEvent("onremove", self._onremove)
end)

function EvaDaydu:GetCooldownRemaining()
    return math.max(0, self.cooldown_end - GetTime())
end

function EvaDaydu:_Say(message)
    local talker = self.inst.components ~= nil and self.inst.components.talker or nil
    if talker ~= nil then talker:Say(message) end
end

function EvaDaydu:_OnProjectileRemoved(projectile)
    self.projectiles[projectile] = nil
end

function EvaDaydu:CastAt(x, z)
    if not require("util/eva_progression").Check(self.inst, "daydu") then return false, "level_locked" end
    if TheWorld == nil or not TheWorld.ismastersim then return false, "not_master" end
    local valid, reason = Common.ValidateCastPoint(self.inst, x, z)
    if not valid then return false, reason end

    local target = Common.FindDayduTarget(self.inst, x, z)
    if target == nil then return false, "no_target" end

    local remaining = self:GetCooldownRemaining()
    if remaining > 0 then
        self:_Say("Dạ Du hồi sau " .. tostring(math.ceil(remaining)) .. " giây.")
        return false, "cooldown"
    end

    local souls = self.inst.components ~= nil and self.inst.components.eva_souls or nil
    if souls == nil or souls.current < Common.DAYDU_COST then
        self:_Say("Cần 5 Hồn Lực để thi triển Dạ Du.")
        return false, "insufficient_souls"
    end

    local projectile = SpawnPrefab("eva_daydu_projectile")
    if projectile == nil then return false, "spawn_failed" end
    self.projectiles[projectile] = true
    if projectile.Launch == nil or not projectile:Launch(self.inst, target, self) then
        self.projectiles[projectile] = nil
        if projectile:IsValid() then projectile:Remove() end
        return false, "spawn_failed"
    end

    souls:DoDelta(-Common.DAYDU_COST)
    self.cooldown_end = GetTime() + Common.DAYDU_COOLDOWN
    self:_Say("Dạ Du!")
    return true, "cast"
end

function EvaDaydu:Stop(reason)
    local stopped = false
    for projectile in pairs(self.projectiles) do
        self.projectiles[projectile] = nil
        if projectile:IsValid() then
            stopped = true
            projectile:Remove()
        end
    end
    return stopped, reason
end

function EvaDaydu:OnSave()
    local remaining = self:GetCooldownRemaining()
    return remaining > 0 and {cooldown = remaining} or nil
end

function EvaDaydu:OnLoad(data)
    self:Stop("load")
    local remaining = data ~= nil and data.cooldown or 0
    self.cooldown_end = GetTime()
        + Common.ClampDuration(remaining, Common.DAYDU_COOLDOWN)
end

function EvaDaydu:OnRemoveFromEntity()
    self:Stop("component_removed")
    self.inst:RemoveEventCallback("death", self._ondeath)
    self.inst:RemoveEventCallback("ms_becameghost", self._onghost)
    self.inst:RemoveEventCallback("onremove", self._onremove)
end

return EvaDaydu
