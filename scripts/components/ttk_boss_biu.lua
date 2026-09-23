-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_GetElectricDamage = Boss.Xd_GetElectricDamage
local DOZE_OFF_TIME = 2
local function onenble(self,enble)
	if enble then
		self.inst:AddTag("canusechenshe")
	else
		self.inst:RemoveTag("canusechenshe")
	end
end
local Projectile = Class(function(self, inst)
    self.inst = inst
    self.owner = nil
    self.target = nil
    self.start = nil
    self.dest = nil
    self.speed = nil
    self.hitdist = 1.5
    self.homing = true
    self.range = nil
    self.onthrown = nil
    self.onhit = nil
    self.onmiss = nil
	self.enble = true
	self.targets ={}
end,
nil,
{
	enble = onenble,
})
function Projectile:SetEnble(bb)
	self.enble = bb
end
function Projectile:OnRemoveFromEntity()
    self.inst:RemoveTag("projectile")
end
function Projectile:SetSpeed(speed)
    self.speed = speed
end
function Projectile:SetRange(range)
    self.range = range
end
function Projectile:SetHitDist(dist)
    self.hitdist = dist
end
function Projectile:SetOnHitFn(fn)
    self.onhit = fn
end
function Projectile:SetOnMissFn(fn)
    self.onmiss = fn
end
function Projectile:SetOnThrownFn(fn)
    self.onthrown = fn
end
function Projectile:SetLaunchOffset(offset)
    self.launchoffset = offset
end
function Projectile:FaShe(pos,doer)
	if self.fashe ~= nil then
		return self.fashe(self.inst,pos,doer)
	end
	return false
end
function Projectile:Throw(attacker,pos,weapon)
    self.owner = attacker
    self.weapon = weapon
    self.start = attacker:GetPosition()
    self.dest = pos
    self:Start()
    if attacker ~= nil and self.launchoffset ~= nil then
        local x, y, z = attacker.Transform:GetWorldPosition()
        local facing_angle = attacker.Transform:GetRotation() * DEGREES
        self.inst.Transform:SetPosition(x + self.launchoffset.x * math.cos(facing_angle), y + self.launchoffset.y, z - self.launchoffset.x * math.sin(facing_angle))
    end
    self:RotateToTarget(self.dest)
    self.inst.Physics:SetMotorVel(self.speed, 1, 0)
    self.inst:StartUpdatingComponent(self)
    if self.onthrown ~= nil then
        self.onthrown(self.inst, attacker)
    end
end
function Projectile:Miss()
    local owner = self.owner
    self:Stop()
    if self.onmiss ~= nil then
        self.onmiss(self.inst,owner)
    end
end
function Projectile:Stop()
	self.inst.Physics:Stop()
    self.inst:StopUpdatingComponent(self)
    self.inst:Remove()
end
function Projectile:Start()
    self.targets = {}
end
function Projectile:SholdReturn()
    if self.doreturn then
        if self.inst:GetDistanceSqToInst(self.owner) < 0.2 then
            return true
        end
    else
        if (self.inst:GetDistanceSqToPoint(self.dest:Get()) < 0.2) or (distsq(self.start, self.inst:GetPosition()) > self.range * self.range) then
            return true
        end
    end
end
function Projectile:DoReturn()
    if self.doreturn then
        self:Stop()
    else
        self:Start()
        self.doreturn =  true
    end
end
function Projectile:OnUpdate(dt)
    if not (self.owner and self.owner:IsValid()) then
        self:Stop()
        return
    end
    if self.doreturn then
        self:RotateToTarget(self.owner:GetPosition())
    end
    self.inst.Physics:SetMotorVel(self.speed, 1, 0)
	local pos = self.inst:GetPosition()
    local ents = XD_GetDamageTargets(pos.x,0,pos.z,self.hitdist)
    for i,v in pairs(ents) do
        if self.owner and self.owner:IsValid() and not self.targets[v]  and v:IsValid() and self.inst:IsValid() and self.inst:IsNear(v, self.hitdist + (v.Physics and v.Physics:GetRadius() or 0)) and v ~= self.owner
            and XD_CanAttackTrget(self.owner,v) then
            self.targets[v]  = true
            SpawnPrefab("electricchargedfx"):SetTarget(v)
            local damage = 200
            if self.weapon and self.weapon:IsValid() then
                damage = self.owner.components.combat:CalcDamage(v, self.weapon,2)
            end
            damage = damage * Xd_GetElectricDamage(self.owner,v)
            v.components.combat:GetAttacked(self.owner,damage)
        end
    end
    if self:SholdReturn() then
        self:DoReturn()
    end
end
function Projectile:RotateToTarget(dest)
    local direction = (dest - self.inst:GetPosition()):GetNormalized()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0))) / DEGREES
    self.inst.Transform:SetRotation(angle)
    self.inst:FacePoint(dest)
end
return Projectile
