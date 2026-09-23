local Common = require "util/eva_fox_common"
local SkillDamage = require "util/eva_skill_damage"

local LIGHTNING_FX = "spear_wathgrithr_lightning_lunge_fx"
local LIGHTNING_SOUND = "meta3/wigfrid/spear_lighting_lunge"
local LIGHTNING_COLOUR = {216 / 255, 239 / 255, 1, 1}

local EvaFoxBlink = Class(function(self, inst)
    self.inst = inst
    self.active = false
    self.cooldown_end = 0
    self.cast_task = nil
    self.cast_state = nil

    self._ondeath = function() self:Stop("death") end
    self._onghost = function() self:Stop("ghost") end
    self._onremove = function() self:Stop("remove") end
    self._onnewstate = function()
        if self.active and ((self.cast_state ~= nil
                and self.inst.sg ~= nil
                and self.inst.sg.currentstate ~= self.cast_state)
            or not Common.CanContinueCast(self.inst)) then
            self:Stop("interrupted")
        end
    end
    inst:ListenForEvent("death", self._ondeath)
    inst:ListenForEvent("ms_becameghost", self._onghost)
    inst:ListenForEvent("onremove", self._onremove)
    inst:ListenForEvent("newstate", self._onnewstate)
end)

function EvaFoxBlink:GetCooldownRemaining()
    return math.max(0, self.cooldown_end - GetTime())
end

function EvaFoxBlink:IsActive()
    return self.active
end

function EvaFoxBlink:_Say(message)
    local talker = self.inst.components ~= nil and self.inst.components.talker or nil
    if talker ~= nil then talker:Say(message) end
end

function EvaFoxBlink:_SpawnLightningFx(x, z, rotation)
    local fx = SpawnPrefab(LIGHTNING_FX)
    if fx == nil then return end
    fx.Transform:SetPosition(x, 0, z)
    fx.Transform:SetRotation(rotation)
    if fx.AnimState ~= nil then
        fx.AnimState:SetMultColour(unpack(LIGHTNING_COLOUR))
    end
end

function EvaFoxBlink:_FinishCast(reason)
    if self.cast_task ~= nil then
        self.cast_task:Cancel()
        self.cast_task = nil
    end
    local was_active = self.active
    self.active = false
    self.inst:RemoveTag("eva_fox_casting")
    local cast_state = self.cast_state
    self.cast_state = nil
    if (reason == "finished" or reason == "destination_invalid"
            or reason == "cast_error")
        and self.inst.sg ~= nil and self.inst.sg.currentstate == cast_state
        and self.inst.sg.GoToState ~= nil then
        self.inst.sg:GoToState("idle")
    end
    return was_active, reason
end

function EvaFoxBlink:_DamagePath(targets)
    local combat = self.inst.components ~= nil and self.inst.components.combat or nil
    local previous_ignore
    if combat ~= nil then
        previous_ignore = combat.ignorehitrange
        combat.ignorehitrange = true
    end
    local ok, problem = pcall(function()
        for _, target in ipairs(targets) do
            if Common.IsValidLungeTarget(self.inst, target) then
                SkillDamage.Apply(
                    self.inst, target, Common.LUNGE_DAMAGE, "eva_fox_blink")
                if self.inst:IsValid() then
                    self.inst:PushEvent("onareaattackother", {target = target})
                end
            end
        end
    end)
    if combat ~= nil then combat.ignorehitrange = previous_ignore end
    if not ok then
        print("[EVA] Thuấn Ảnh path damage failed: " .. tostring(problem))
    end
end

function EvaFoxBlink:_ResolveCast(x, z)
    self.cast_task = nil
    if not self.active or not Common.CanContinueCast(self.inst) then
        self:_FinishCast("interrupted")
        return
    end
    local origin_x, _, origin_z = self.inst.Transform:GetWorldPosition()
    local valid = Common.ValidateDestination(self.inst, x, z, origin_x, origin_z)
    if not valid then
        self:_FinishCast("destination_invalid")
        return
    end

    local targets = Common.FindTargetsAlongPath(
        self.inst, origin_x, origin_z, x, z)
    local ok, problem = pcall(self.inst.Physics.Teleport, self.inst.Physics, x, 0, z)
    if not ok then
        print("[EVA] Thuấn Ảnh teleport failed: " .. tostring(problem))
        self:_FinishCast("cast_error")
        return
    end

    self.cooldown_end = GetTime() + Common.COOLDOWN
    local rotation = math.atan2(origin_z - z, x - origin_x) * RADIANS
    self:_SpawnLightningFx((origin_x + x) * 0.5, (origin_z + z) * 0.5, rotation)
    self:_SpawnLightningFx(x, z, rotation)
    if self.inst.SoundEmitter ~= nil then
        self.inst.SoundEmitter:PlaySound(LIGHTNING_SOUND)
    end
    self:_DamagePath(targets)
    self:_FinishCast("finished")
end

function EvaFoxBlink:CastAt(x, z)
    if TheWorld == nil or not TheWorld.ismastersim then
        return false, "not_master"
    end
    if self.active then return false, "active" end
    local remaining = self:GetCooldownRemaining()
    if remaining > 0 then
        self:_Say("Thuấn Ảnh hồi sau " .. tostring(math.ceil(remaining)) .. " giây.")
        return false, "cooldown"
    end
    if not Common.CanActivate(self.inst) then return false, "invalid_state" end
    local origin_x, _, origin_z = self.inst.Transform:GetWorldPosition()
    local valid, reason = Common.ValidateDestination(
        self.inst, x, z, origin_x, origin_z)
    if not valid then return false, reason end

    self.active = true
    self.cast_state = self.inst.sg ~= nil and self.inst.sg.currentstate or nil
    self.inst:AddTag("eva_fox_casting")
    self.cast_task = self.inst:DoTaskInTime(Common.BLINK_DELAY, function()
        self:_ResolveCast(x, z)
    end)
    self:_Say("Thuấn Ảnh!")
    return true, "cast"
end

function EvaFoxBlink:Stop(reason)
    return self:_FinishCast(reason)
end

function EvaFoxBlink:OnSave()
    local remaining = self:GetCooldownRemaining()
    return remaining > 0 and {cooldown = remaining} or nil
end

function EvaFoxBlink:OnLoad(data)
    self:Stop("load")
    local remaining = data ~= nil and tonumber(data.cooldown) or 0
    if not Common.IsFiniteNumber(remaining) then remaining = 0 end
    self.cooldown_end = GetTime()
        + math.max(0, math.min(Common.COOLDOWN, remaining or 0))
end

function EvaFoxBlink:OnRemoveFromEntity()
    self:Stop("component_removed")
    self.inst:RemoveEventCallback("death", self._ondeath)
    self.inst:RemoveEventCallback("ms_becameghost", self._onghost)
    self.inst:RemoveEventCallback("onremove", self._onremove)
    self.inst:RemoveEventCallback("newstate", self._onnewstate)
end

return EvaFoxBlink
