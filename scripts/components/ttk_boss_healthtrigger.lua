-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local function isleader(inst,target)
	if inst and target and
    ((inst.ttk_boss_summoner == target or target.ttk_boss_summoner == inst) or
    (inst.ttk_boss_summoner and  inst.ttk_boss_summoner == target.ttk_boss_summoner) or
    (target.ttk_boss_summoner and target.ttk_boss_summoner == inst.ttk_boss_summoner))
    then
        return true
    end
end
local function isplayerorpet(target)
    return target:HasTag("player") or
    target.owner and target.owner:HasTag("player") or
    target.components.follower and target.components.follower.leader and target.components.follower.leader:HasTag("player")
end
local function hookcombat(inst,summoner)
    local self = inst.components.combat
    if self then
        if self.ttk_boss_summoner_hooked then
            return
        end
        self.ttk_boss_summoner_hooked = true
        local old_GetAttacked =  self.GetAttacked
        function self:GetAttacked(attacker,...)
            if isleader(self.inst,attacker) then
                return false
            end
            return old_GetAttacked(self,attacker,...)
        end
        local old_SetTarget =  self.SetTarget
        function self:SetTarget(target,...)
            if isleader(self.inst,target) then
                return false
            end
            return old_SetTarget(self,target,...)
        end
        local old_SuggestTarget =  self.SuggestTarget
        function self:SuggestTarget(target,...)
            if isleader(self.inst,target) then
                return false
            end
            return old_SuggestTarget(self,target,...)
        end
        local old_CanTarget =  self.CanTarget
        function self:CanTarget(target,...)
            if isleader(self.inst,target) then
                return false
            end
            return old_CanTarget(self,target,...)
        end
        inst:DoPeriodicTask(1,function(_inst)
            if not _inst:IsAsleep() and  not (_inst.components.health and _inst.components.health:IsDead()) and _inst.components.combat then
                if not  _inst.components.combat.target or not isplayerorpet(_inst.components.combat.target) then
                    local x,y,z = _inst.Transform:GetWorldPosition()
                    local player = FindClosestPlayer(x, y, z,32,true)
                    if player and _inst.components.combat:IsValidTarget(player) then
                        _inst.components.combat:SetTarget(player)
                    end
                end
            end
            if not summoner then
                if inst:IsValid() and inst.ttk_boss_summoner and inst.ttk_boss_summoner:IsValid() then
                    if not inst:IsNear(inst.ttk_boss_summoner,28) then
                        local theta = math.random() * TWOPI
                        local pt = inst.ttk_boss_summoner:GetPosition()
                        local radius = math.random(3)
                        local offset = FindWalkableOffset(pt, theta, radius, 6, true)
                        if offset ~= nil then
                            pt.x = pt.x + offset.x
                            pt.z = pt.z + offset.z
                        end
                        if inst.Physics ~= nil then
                            inst.Physics:Teleport(pt.x, pt.y, pt.z)
                        elseif inst.Transform ~= nil then
                            inst.Transform:SetPosition(pt.x, pt.y, pt.z)
                        end
                        SpawnAt("ttk_boss_bigspawn_fx_medium_static_new",pt)
                    end
                end
            end
        end)
    end
    if not summoner then
        inst:AddTag("no_drop_xdlingshi")
        inst:AddTag("no_dtexp")
        if inst.components.lootdropper then
            inst.components.lootdropper.GenerateLoot = function(...) return {} end
        end
    end
end
local function OnHealthDelta(inst, data)
    inst.components.ttk_boss_healthtrigger:OnHealthDelta(data)
end
local HealthTrigger = Class(function(self, inst)
    self.inst = inst
    self.deathed_boss = {}
    self.aplay_per = {}
	self.add_component_if_missing = true
    self.triggers = {}
    self.inst:DoTaskInTime(0.1,function()
        if next(self.aplay_per) ~= nil then
            self:OnInit()
        end
    end)
    self.inst:ListenForEvent("healthdelta", OnHealthDelta)
end)
function HealthTrigger:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("healthdelta", OnHealthDelta)
end
function HealthTrigger:AddTrigger(amount, fn)
    self.triggers[amount] = fn
end
local function descending(a, b)
    return a > b
end
function HealthTrigger:OnHealthDelta(data)
    local totrigger = {}
    for k, v in pairs(self.triggers) do
        if (data.oldpercent > k and data.newpercent <= k) or
            (data.oldpercent < k and data.newpercent >= k) then
            table.insert(totrigger, k)
        end
    end
    if self.inst.components.health and self.inst.components.health:IsDead() then
        return
    end
    if #totrigger > 0 then
        table.sort(totrigger, data.oldpercent > data.newpercent and descending or nil)
        for i, v in ipairs(totrigger) do
            if not self.aplay_per[v] then
                local bosss = self.triggers[v](self.inst,self.deathed_boss)
                self.aplay_per[v] = true
                for _,v in pairs(bosss) do
                    if v.components.ttk_boss_guaiwu_skills then
                        v.components.ttk_boss_guaiwu_skills.first = false
                    end
                    v.ttk_boss_summoner = self.inst
                    hookcombat(v)
                    self.inst:ListenForEvent("death",function()
                        self.deathed_boss[v.prefab] = true
                    end,v)
                    v:ListenForEvent("death",function()
                        if v and v:IsValid() and v.components.health and not v.components.health:IsDead() then
                            v.components.health:Kill()
                        end
                    end,self.inst)
                    v:ListenForEvent("ttk_boss_lilian_over",function()
                        if v and v:IsValid() and v.components.health and not v.components.health:IsDead() then
                            v.components.health:Kill()
                        end
                    end,self.inst)
                    v:ListenForEvent("ttk_boss_entity_death",function()
                        if v and v:IsValid() and v.components.health and not v.components.health:IsDead() then
                            v.components.health:Kill()
                        end
                    end,self.inst)
                    v.persists = false
                end
                if next(bosss) ~= nil then
                    hookcombat(self.inst,true)
                end
            end
        end
    end
end
function HealthTrigger:OnInit()
    for time in pairs(self.aplay_per) do
        if self.triggers[time] then
            local bosss = self.triggers[time](self.inst,self.deathed_boss)
            for _,v in pairs(bosss) do
                if v.components.ttk_boss_guaiwu_skills then
                    v.components.ttk_boss_guaiwu_skills.first = false
                end
                v.ttk_boss_summoner = self.inst
                hookcombat(v)
                self.inst:ListenForEvent("death",function()
                    self.deathed_boss[v.prefab] = true
                end,v)
                v:ListenForEvent("death",function()
                    if v and v:IsValid() and v.components.health and not v.components.health:IsDead() then
                        v.components.health:Kill()
                    end
                end,self.inst)
                v:ListenForEvent("ttk_boss_lilian_over",function()
                    if v and v:IsValid() and v.components.health and not v.components.health:IsDead() then
                        v.components.health:Kill()
                    end
                end,self.inst)
                v:ListenForEvent("ttk_boss_entity_death",function()
                    if v and v:IsValid() and v.components.health and not v.components.health:IsDead() then
                        v.components.health:Kill()
                    end
                end,self.inst)
                v.persists = false
            end
            if next(bosss) ~= nil then
                hookcombat(self.inst,true)
            end
        end
    end
end
function HealthTrigger:OnSave()
    return  {deathed_boss = self.deathed_boss , add_component_if_missing = self.add_component_if_missing,aplay_per = self.aplay_per }
end
function HealthTrigger:OnLoad(data)
    if data then
	 	if data.add_component_if_missing ~= nil then
        	self.add_component_if_missing = data.add_component_if_missing
		end
		if data.deathed_boss then
			self.deathed_boss =  data.deathed_boss
		end
        if data.aplay_per  then
			self.aplay_per = data.aplay_per
		end
    end
end
return HealthTrigger
