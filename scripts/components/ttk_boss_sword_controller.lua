-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Controller = Class(function (self,inst)
    self.inst = inst
    self.swordmode = 1
    self.attack_count = 1
    self.attackfj_count = 0
    self.mode = 1
    self.skin = nil
    self.skillmode = 1
    self.attackfn = function(_,data)
        if self.noattack_listen then
            return
        end
        if self.summons then
            if data and data.target and data.target:IsValid() then
                self.attack_count = self.attack_count + 1
                if self.attack_count >=  (self.swordmode == 2 and 7 or 5) then
                    self.attack_count = 0
                    if self.summons[self.mode] and self.summons[self.mode]:IsValid() then
                        self.summons[self.mode]:PushEvent("doattack",{target = data.target,com = self})
                    end
                end
            end
        end
        if self.summons_fj then
            if data and data.target and data.target:IsValid() then
                self.attackfj_count = self.attackfj_count + 1
                if self.attackfj_count >=  5 then
                    self.attackfj_count = 0
                    if self.summons_fj[1] and self.summons_fj[1]:IsValid() then
                        self.summons_fj[1]:PushEvent("doattack",{target = data.target,com = self})
                    end
                end
            end
        end
    end
    self.inst:ListenForEvent("onattackother",self.attackfn)
    self.inst:ListenForEvent("gongdeattack",self.attackfn)
    self.inst:ListenForEvent("death",function()
        self:DeSummon()
    end)
    self.inst:ListenForEvent("timerdone",function(_,data)
        if data and data.name == "ttk_boss_fjcd" then
            self:DeSummonFj()
        end
    end)
end)
local function isbusy(inst)
    return inst.busy or inst.goback or inst.skillon
end
function Controller:UseSkill(pos)
    if not self.summons then
        return
    end
    if self.inst.components.ttk_boss_skillcd and self.inst.components.ttk_boss_skillcd:HasCd("source_F15C2F2BC385F1F838CE0CE3") then
        return
    end
    local sword = self.swordmode == 1 and self.skillmode or 1
    if self.skillmode == 4 then
        for _,v in ipairs(self.summons) do
            if isbusy(v) then
                return
            end
        end
        for _,v in ipairs(self.summons) do
            v:PushEvent("spell_big",{pos = pos,com = self})
        end
    elseif self.summons[sword] and self.summons[sword]:IsValid() then
        self.summons[sword]:PushEvent("spell",{pos = pos,com = self})
    end
end
local swords = {"red","blue","green"}
function Controller:Summon(mode,skin)
    if self.summons then
        self:DeSummon()
        return
    end
    self.skin = skin
    self.swordmode = mode or  self.inst.components.ttk_boss_level.mode or 1
    if  self.swordmode == 1 then
        self.summons = {}
        for i = 1, 3 do
            local fx = SpawnPrefab("ttk_boss_sword_"..swords[i])
            fx.sword = swords[i]
            fx.index = i
            fx.owner = self.inst
            fx.maxpets = 3
            self.summons[i] = fx
            self.inst.components.leader:AddFollower(fx)
            local pos = fx:GetTargetPos(self.inst)
            if pos then
                fx.Transform:SetPosition(pos:Get())
            end
            fx:DoTaskInTime(0,function()
                if self.inst:IsValid() then
                    local pos = fx:GetTargetPos(self.inst)
                    if pos then
                        fx.Transform:SetPosition(pos:Get())
                    end
                end
            end)
            fx:Hide()
            if fx.SetSkin and skin then
                fx:SetSkin(skin)
            end
            self.inst.SoundEmitter:PlaySound("dontstarve/common/spawn/spawnportal_spawnplayer", nil, 0.5)
            fx:DoSpawn()
        end
    else
        self.summons = {}
        for i = 1, 1 do
            local fx = SpawnPrefab("ttk_boss_sword_mo")
            fx.sword = "mo"
            fx.index = i
            fx.owner = self.inst
            fx.maxpets = 1
            self.summons[i] = fx
            self.inst.components.leader:AddFollower(fx)
            local theta = math.random() * TWOPI
            local pt = self.inst:GetPosition()
            local radius = 1
            local offset = FindWalkableOffset(pt, theta, radius, 6, true)
            if offset ~= nil then
                pt.x = pt.x + offset.x
                pt.z = pt.z + offset.z
            end
            fx:Hide()
            if fx.SetSkin and skin then
                fx:SetSkin(skin)
            end
            fx.Transform:SetPosition(pt:Get())
            self.inst.SoundEmitter:PlaySound("dontstarve/common/spawn/spawnportal_spawnplayer", nil, 0.5)
            fx:DoSpawn()
        end
    end
end
function Controller:SummonFj()
    if self.summons_fj then
        self:DeSummonFj()
    end
    self.inst.components.timer:StopTimer("ttk_boss_fjcd")
    self.inst.components.timer:StartTimer("ttk_boss_fjcd",30)
    self.summons_fj = {}
    for i = 1, 1 do
        local fx = SpawnPrefab("ttk_boss_sword_fj")
        fx.sword = "fj"
        fx.index = i
        fx.owner = self.inst
        fx.maxpets = 1
        self.summons_fj[i] = fx
        self.inst.components.leader:AddFollower(fx)
        local pos = fx:GetTargetPos(self.inst)
        if pos then
            fx.Transform:SetPosition(pos:Get())
        end
        fx:DoTaskInTime(0,function()
            if self.inst:IsValid() then
                local pos = fx:GetTargetPos(self.inst)
                if pos then
                    fx.Transform:SetPosition(pos:Get())
                end
            end
        end)
        fx:Hide()
        self.inst.SoundEmitter:PlaySound("dontstarve/common/spawn/spawnportal_spawnplayer", nil, 0.5)
        fx:DoSpawn()
    end
end
function Controller:DeSummon()
    if self.summons then
        for i,v in ipairs(self.summons) do
            if v and v:IsValid() then
                v:DeSpawn(true)
            end
        end
        self.summons = nil
    end
end
function Controller:DeSummonFj()
    if self.summons_fj then
        for i,v in ipairs(self.summons_fj) do
            if v and v:IsValid() then
                v:DeSpawn(true)
            end
        end
        self.summons_fj = nil
    end
end
function Controller:DeSummonSword()
    self:DeSummon()
    self:DeSummonFj()
end
function Controller:OnSave()
    local data = {fj = self.summons_fj ~= nil}
    if self.summons ~= nil then
        data.swordmode = self.swordmode
        data.skin = self.skin
    end
    return data
end
function Controller:OnLoad(data)
    if data then
        if  data.swordmode then
            self:Summon(data.swordmode,data.skin)
        end
        if data.fj then
            self:SummonFj()
        end
    end
end
Controller.OnRemoveEntity = Controller.DeSummonSword
return Controller
