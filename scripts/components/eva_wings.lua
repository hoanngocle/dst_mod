local SOUL_COST = 100
local SPEED_MULTIPLIER = 1.08
local SPEED_KEY = "eva_wings_speed"

local function HasCollisionBit(mask, value)
    return mask % (value * 2) >= value
end

local EvaWings = Class(function(self, inst)
    self.inst = inst
    self.active = false
    self.fx = nil
    self._surface_applied = false
    self._restore_boat_limit = false
    self._restore_land_ocean_limit = false
    self._pathcaps = nil
    self._locomotor = nil
    self._pathcaps_had_table = false
    self._previous_allowocean = nil
    self._previous_allow_platform_hopping = nil
    self._drownable = nil
    self._previous_should_drown = nil
    self._drown_wrapper = nil

    self._ondeath = function() self:ForceDisable("death", false) end
    self._onghost = function() self:ForceDisable("ghost", false) end
    self._onremove = function() self:ForceDisable("remove", false) end
    self._onnewstate = function() self:_ValidateActiveState() end
    inst:ListenForEvent("death", self._ondeath)
    inst:ListenForEvent("ms_becameghost", self._onghost)
    inst:ListenForEvent("onremove", self._onremove)
    inst:ListenForEvent("newstate", self._onnewstate)
end)

local function IsSurfaceWorld()
    return TheWorld ~= nil and not TheWorld:HasTag("cave")
end

local function IsAliveHuman(inst)
    local health = inst.components ~= nil and inst.components.health or nil
    return inst:IsValid()
        and not inst:HasTag("playerghost")
        and health ~= nil
        and not health:IsDead()
end

local function HasStateTag(inst, tag)
    return inst.sg ~= nil and inst.sg:HasStateTag(tag)
end

local function IsIncompatibleActivationState(inst)
    local components = inst.components or {}
    return (components.rider ~= nil and components.rider:IsRiding())
        or (components.locomotor ~= nil and (components.locomotor.hopping == true
            or (components.locomotor.IsHopping ~= nil and components.locomotor:IsHopping())))
        or (components.freezable ~= nil and components.freezable:IsFrozen())
        or HasStateTag(inst, "busy")
        or HasStateTag(inst, "knockout")
        or HasStateTag(inst, "frozen")
        or HasStateTag(inst, "swimming")
        or HasStateTag(inst, "hopping")
        or HasStateTag(inst, "jumping")
        or HasStateTag(inst, "mounting")
        or HasStateTag(inst, "dismounting")
end

local function IsMountedState(inst)
    local rider = inst.components ~= nil and inst.components.rider or nil
    return (rider ~= nil and rider:IsRiding())
        or HasStateTag(inst, "mounting")
        or HasStateTag(inst, "dismounting")
end

local function IsOverOpenOcean(inst)
    if not IsSurfaceWorld() or inst:GetCurrentPlatform() ~= nil then
        return false
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    return TheWorld.Map:IsOceanAtPoint(x, y, z)
end

function EvaWings:IsActive()
    return self.active
end

function EvaWings:_Say(message)
    local talker = self.inst.components ~= nil and self.inst.components.talker or nil
    if talker ~= nil then talker:Say(message) end
end

function EvaWings:_SetNetActive(value)
    if self.inst._eva_wings_active ~= nil then
        self.inst._eva_wings_active:set(value == true)
    end
end

function EvaWings:_InstallDrowningGuard()
    local drownable = self.inst.components.drownable
    if drownable == nil or self._drown_wrapper ~= nil then return end
    local previous = drownable.ShouldDrown
    local wrapper
    wrapper = function(component, ...)
        local should_drown = previous(component, ...)
        if should_drown and self.active and IsOverOpenOcean(self.inst) then
            return false
        end
        return should_drown
    end
    self._drownable = drownable
    self._previous_should_drown = previous
    self._drown_wrapper = wrapper
    drownable.ShouldDrown = wrapper
end

function EvaWings:_RemoveDrowningGuard()
    if self._drownable ~= nil
        and self._drownable.ShouldDrown == self._drown_wrapper then
        self._drownable.ShouldDrown = self._previous_should_drown
    end
    self._drownable = nil
    self._previous_should_drown = nil
    self._drown_wrapper = nil
end

function EvaWings:_ApplySurfaceTraversal()
    if not IsSurfaceWorld() then return end
    local physics = self.inst.Physics
    local locomotor = self.inst.components.locomotor
    if physics == nil or locomotor == nil then return end

    if not self._surface_applied then
        local mask = physics:GetCollisionMask()
        self._restore_boat_limit = HasCollisionBit(mask, COLLISION.BOAT_LIMITS)
        self._restore_land_ocean_limit = HasCollisionBit(mask, COLLISION.LAND_OCEAN_LIMITS)
        self._surface_applied = true
    end
    physics:ClearCollidesWith(COLLISION.LIMITS)

    if self._locomotor ~= locomotor or self._pathcaps ~= locomotor.pathcaps then
        self._locomotor = locomotor
        self._pathcaps_had_table = locomotor.pathcaps ~= nil
        if locomotor.pathcaps == nil then locomotor.pathcaps = {} end
        self._pathcaps = locomotor.pathcaps
        self._previous_allowocean = locomotor.pathcaps.allowocean
        self._previous_allow_platform_hopping = locomotor.allow_platform_hopping
    end
    locomotor.pathcaps.allowocean = true
    locomotor:SetAllowPlatformHopping(false)
    self:_InstallDrowningGuard()
end

function EvaWings:_RemoveSurfaceTraversal(restore_physics)
    self:_RemoveDrowningGuard()
    local locomotor = self.inst.components ~= nil and self.inst.components.locomotor or nil
    if locomotor ~= nil and locomotor == self._locomotor
        and locomotor.pathcaps == self._pathcaps then
        locomotor.pathcaps.allowocean = self._previous_allowocean
        if not self._pathcaps_had_table and next(locomotor.pathcaps) == nil then
            locomotor.pathcaps = nil
        end
        locomotor:SetAllowPlatformHopping(self._previous_allow_platform_hopping)
    end
    if self._surface_applied and restore_physics and self.inst.Physics ~= nil then
        if self._restore_boat_limit then
            self.inst.Physics:CollidesWith(COLLISION.BOAT_LIMITS)
        end
        if self._restore_land_ocean_limit then
            self.inst.Physics:CollidesWith(COLLISION.LAND_OCEAN_LIMITS)
        end
    end
    self._surface_applied = false
    self._restore_boat_limit = false
    self._restore_land_ocean_limit = false
    self._pathcaps = nil
    self._locomotor = nil
    self._pathcaps_had_table = false
    self._previous_allowocean = nil
    self._previous_allow_platform_hopping = nil
end

function EvaWings:_SpawnFx()
    if self.fx ~= nil and self.fx:IsValid() then return end
    local fx = SpawnPrefab("eva_wings_fx")
    if fx ~= nil then
        fx:AttachToOwner(self.inst)
        self.fx = fx
    end
end

function EvaWings:_RemoveFx()
    if self.fx ~= nil and self.fx:IsValid() then self.fx:Remove() end
    self.fx = nil
end

function EvaWings:_CanEnable()
    if not require("util/eva_progression").Check(self.inst, "wings") then return false, "level_locked" end
    if not IsAliveHuman(self.inst) then return false, "invalid_state" end
    if IsIncompatibleActivationState(self.inst) then return false, "incompatible_state" end
    if self.inst.components.locomotor == nil then return false, "missing_locomotor" end
    local souls = self.inst.components.eva_souls
    if souls == nil or souls.current < SOUL_COST then
        return false, "insufficient_souls"
    end
    return true
end

function EvaWings:_EnableWithoutCost()
    if self.active then return true, "active" end
    if not require("util/eva_progression").Check(self.inst, "wings") then return false, "level_locked" end
    if not IsAliveHuman(self.inst) or self.inst.components.locomotor == nil then
        return false, "invalid_state"
    end
    self.active = true
    self.inst.components.locomotor:SetExternalSpeedMultiplier(
        self.inst, SPEED_KEY, SPEED_MULTIPLIER)
    self:_ApplySurfaceTraversal()
    self:_SpawnFx()
    self:_SetNetActive(true)
    return true
end

function EvaWings:Enable()
    if self.active then return true, "active" end
    local allowed, reason = self:_CanEnable()
    if not allowed then
        if reason == "insufficient_souls" then self:_Say("Cần 100 Hồn Lực để mở Tinh Vũ Nguyệt Dực.") end
        return false, reason
    end
    local ok, enable_reason = self:_EnableWithoutCost()
    if not ok then return false, enable_reason end
    self.inst.components.eva_souls:DoDelta(-SOUL_COST)
    return true
end

function EvaWings:Disable(manual)
    if not self.active then return true, "inactive" end
    if manual and IsOverOpenOcean(self.inst) then
        self:_Say("Hãy trở lại đất liền hoặc thuyền trước khi khép Tinh Vũ Nguyệt Dực.")
        return false, "over_water"
    end
    self.active = false
    local locomotor = self.inst.components ~= nil and self.inst.components.locomotor or nil
    if locomotor ~= nil then
        locomotor:RemoveExternalSpeedMultiplier(self.inst, SPEED_KEY)
    end
    self:_RemoveSurfaceTraversal(IsAliveHuman(self.inst) and not IsMountedState(self.inst))
    self:_RemoveFx()
    self:_SetNetActive(false)
    return true
end

function EvaWings:ForceDisable(_, restore_physics)
    if not self.active then
        self:_SetNetActive(false)
        return true
    end
    self.active = false
    local locomotor = self.inst.components ~= nil and self.inst.components.locomotor or nil
    if locomotor ~= nil then locomotor:RemoveExternalSpeedMultiplier(self.inst, SPEED_KEY) end
    self:_RemoveSurfaceTraversal(restore_physics == true)
    self:_RemoveFx()
    self:_SetNetActive(false)
    return true
end

function EvaWings:Toggle()
    if self.active then
        return self:Disable(true)
    end
    return self:Enable()
end

function EvaWings:_ValidateActiveState()
    if not self.active then return end
    if not IsAliveHuman(self.inst) or IsMountedState(self.inst) then
        self:ForceDisable("incompatible_state", false)
    else
        self.inst.components.locomotor:SetExternalSpeedMultiplier(
            self.inst, SPEED_KEY, SPEED_MULTIPLIER)
        self:_ApplySurfaceTraversal()
    end
end

function EvaWings:OnRemoveFromEntity()
    if self._load_task ~= nil then self._load_task:Cancel() end
    self:ForceDisable("component_removed", IsAliveHuman(self.inst) and not IsMountedState(self.inst))
    self.inst:RemoveEventCallback("death", self._ondeath)
    self.inst:RemoveEventCallback("ms_becameghost", self._onghost)
    self.inst:RemoveEventCallback("onremove", self._onremove)
    self.inst:RemoveEventCallback("newstate", self._onnewstate)
end

function EvaWings:OnSave()
    return {active = self.active}
end

function EvaWings:OnLoad(data)
    if self._load_task ~= nil then self._load_task:Cancel(); self._load_task = nil end
    if data ~= nil and data.active == true and IsAliveHuman(self.inst) then
        -- All component saves (including EVA's level) must load before the gate.
        self._load_task = self.inst:DoTaskInTime(0, function()
            self._load_task = nil
            local souls = self.inst.components.eva_souls
            if souls ~= nil and souls.RefreshLevel ~= nil then souls:RefreshLevel() end
            if IsAliveHuman(self.inst) then self:_EnableWithoutCost() end
        end)
    else
        self:ForceDisable("load_inactive", false)
    end
end

return EvaWings
