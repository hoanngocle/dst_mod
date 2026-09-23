-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local XD_GETWOLRDLEVEL = Boss.XD_GETWOLRDLEVEL
local SourceModifierList = require("util/sourcemodifierlist")
local guaiwust  = require("main/ttk_boss_moster_shengti_set")
local function onby(self, by)
	if self.inst.replica.ttk_boss_xuetiao and by then
		self.inst.replica.ttk_boss_xuetiao._benyuan:set(by)
	end
end
local function onsecond_by(self, second_by)
	if self.inst.replica.ttk_boss_xuetiao and second_by then
		self.inst.replica.ttk_boss_xuetiao._se_benyuan:set(second_by)
	end
end
local function onqx(self, qx)
	if self.inst.replica.ttk_boss_xuetiao and qx then
		self.inst.replica.ttk_boss_xuetiao._qingxiang:set(qx)
	end
end
local function onst(self, st)
	if self.inst.replica.ttk_boss_xuetiao and st then
		self.inst.replica.ttk_boss_xuetiao._shengti:set(st)
	end
end
local function noleader(inst)
	return not (inst.components.follower and inst.components.follower.leader and inst.components.follower.leader:HasTag("player") )
	and not (inst.components.health and inst.components.health:IsDead())
end
local ttk_boss_guaiwu_skills = Class(function(self, inst)
    self.inst = inst
    self.by = nil
    self.qx = nil
    self.second_by = nil
    self.second_qx = nil
	self.cds = {}
	self.current = {}
	self.skills = {}
	self.first = true
	self.st = nil
	self.attackfn = function(_,data)
		if noleader(self.inst) and data and data.target and self.invalidtarget and self.invalidtarget(self.inst,data.target) then
			if self.count_listen then
				if not self.last_counttime or (GetTime()- self.last_counttime) > 0.6 then
					self.count_listen = self.count_listen + 1
					self.last_counttime = GetTime()
				end
			end
			for i,v in ipairs(self.current) do
				if not self:InCd(self.qxname..""..i) then
					if v.attackfn  and v.attackfn(self.inst,data.target) then
						self:StartCd(self.qxname..""..i,v.cd)
					elseif v.attackormissfn and v.attackormissfn(self.inst,data.target) then
						self:StartCd(self.qxname..""..i,v.cd)
					elseif self.count_listen and v.countfn and self.count_listen >= (v.countnum or 10) and v.countfn(self.inst,data.target) then
						self.count_listen = 0
					end
				end
			end
		end
	end
	self.missfn = function(_,data)
		if noleader(self.inst) and data and data.target and self.invalidtarget and self.invalidtarget(self.inst,data.target) then
			if self.count_listen then
				if not self.last_counttime or (GetTime()- self.last_counttime) > 0.6 then
					self.count_listen = self.count_listen + 1
					self.last_counttime = GetTime()
				end
			end
			for i,v in ipairs(self.current) do
				if not self:InCd(self.qxname..""..i) then
					if v.missfn  and v.missfn(self.inst,data.target) then
						self:StartCd(self.qxname..""..i,v.cd)
					elseif v.attackormissfn and v.attackormissfn(self.inst,data.target) then
						self:StartCd(self.qxname..""..i,v.cd)
					elseif self.count_listen and v.countfn and self.count_listen >= (v.countnum or 10) and v.countfn(self.inst,data.target) then
						self.count_listen = 0
					end
				end
			end
		end
	end
end,
nil,
{
    by = onby,
	second_by = onsecond_by,
    qx = onqx,
	st = onst,
})
function ttk_boss_guaiwu_skills:InCd(skill)
	return self.cds[skill] ~= nil and (self.cds[skill]-GetTime()) > 0
end
function ttk_boss_guaiwu_skills:GetCdTime(skill)
	if self.cds[skill] then
		return math.ceil(self.cds[skill]-GetTime())
	end
	return 0
end
function ttk_boss_guaiwu_skills:StartCd(name,time)
	if time then
		self.cds[name] = GetTime() + time
	end
end
function ttk_boss_guaiwu_skills:SetSkill(skills,tbl1,tbl2,invalidtarget,chance,sgtbl1,sgtbl2)
	self.skills = skills
	self.invalidtarget = invalidtarget
	self.inst:DoTaskInTime(0,function()
		if self.first then
			self.first = false
			local level = XD_GETWOLRDLEVEL()
			if (not chance or (math.random() < chance)) and self.by == nil then
				if self.inst.ttk_boss_fb_bytbl then
					self.by = self.inst.ttk_boss_fb_bytbl[1]
					self.qx = self.inst.ttk_boss_fb_bytbl[2]
					self:OnInit()
				else
					local ch = weighted_random_choice(tbl2)
					if tbl1[ch] then
						self.by = tbl1[ch][1]
						self.qx = self.inst:HasTag("wolrdboss") and  4 or tbl1[ch][2]
						self:OnInit()
					end
				end
			end
		end
	end)
end
local skills = {"source_2B8082","source_4680B6" ,"source_46EC49","source_F15CB7","source_CEB485","source_4610102BF51C","source_46AB3346385C"}
function ttk_boss_guaiwu_skills:Hoverer(str)
	if self.st and TUNING.XD_GUAIWUSHENGTI[self.st] then
		table.insert(str,{TUNING.XD_GUAIWUSHENGTI[self.st][1],"NIL","NIL",TUNING.XD_GUAIWUSHENGTI[self.st][2]})
	end
	if self.by and TUNING.XD_GUAIWUBENYUAN[self.by] then
		table.insert(str,{"source_4680AC462DE92B0CD4469D80",TUNING.XD_GUAIWUBENYUAN[self.by][1],TUNING.XD_GUAIWUBENYUAN[self.by][2],TUNING.XD_GUAIWUBENYUAN[self.by][2]})
	end
	if self.qx and TUNING.XD_GUAIWUQINGXIANG[self.qx] then
		table.insert(str,{"source_2B0CD4469D80F1B6C92B2DD5",TUNING.XD_GUAIWUQINGXIANG[self.qx][1],TUNING.XD_GUAIWUQINGXIANG[self.qx][2],TUNING.XD_GUAIWUQINGXIANG[self.qx][2]})
	end
end
local function getotherby(by)
    local newskills = {}
    for k, v in ipairs(skills) do
        if k ~= by then
            table.insert(newskills, k)
        end
    end
    return newskills[math.random(#newskills)]
end
local function getrandomst(notbl,notbl2)
	local newskills = {}
	for k = 1,5 do
		if not (notbl and notbl[k]) and not (notbl2 and notbl2[k]) then
            table.insert(newskills, k)
		end
	end
	return newskills[math.random(#newskills)]
end
function ttk_boss_guaiwu_skills:Chososest()
	self.st = getrandomst({})
	self:OnInit()
end
function ttk_boss_guaiwu_skills:OnInit(choosest)
	if self.noskill then
		return
	end
	if self.inst.ttk_boss_jitan_spawned then
		choosest = true
	end
	if choosest then
		if guaiwust.tbl1[self.inst.prefab] and self.qx == 3 and math.random() < 0.5  then
			self.st = getrandomst({[1] = true,[5] = true},guaiwust.tbl3[self.inst.prefab])
		elseif guaiwust.tbl2[self.inst.prefab] and (self.inst.ttk_boss_jitan_spawned or math.random() < 0.5) then
			self.st = getrandomst(nil,guaiwust.tbl3[self.inst.prefab])
		end
		if self.st == 2 then
			self.second_by = getotherby(self.by)
		end
	end
	self.qxname = skills[self.by]
	if self.skills and self.skills[self.qxname] then
		if not self.inst.ttk_boss_fb_skip_main_byskill then
			if self.qx > 3  then
				if self.by == "source_46EC49" or self.by == "source_46AB3346385C" then
					for k = 2,3 do
						table.insert(self.current,self.skills[self.qxname][k])
					end
				else
					for k = 1,3 do
						table.insert(self.current,self.skills[self.qxname][k])
					end
				end
			else
				table.insert(self.current,self.skills[self.qxname][self.qx])
			end
			if self.second_by then
				self.second_qxname = skills[self.second_by]
				if self.second_qxname and self.skills[self.second_qxname] then
					table.insert(self.current,self.skills[self.second_qxname][3])
				end
			end
		end
		if self.inst.other_fb_bytbl then
			for k,v in pairs(self.inst.other_fb_bytbl) do
				for kk = 1,math.min(v[2],3) do
					table.insert(self.current,self.skills[v[1]][kk])
				end
			end
		end
		if TUNING.XD_SHENGTI_SKILLS[self.st] then
			table.insert(self.current,TUNING.XD_SHENGTI_SKILLS[self.st])
		end
		for k, v in ipairs(self.current) do
			if v.attackormissfn then
				self:OnAttack()
				self:OnMiss()
			elseif v.attackfn then
				self:OnAttack()
			elseif v.missfn then
				self:OnMiss()
			end
			if v.healthper then
				self:OnHealthPer(v.healthper)
			end
			if v.timefn then
				self:OnTime()
			end
			if v.countfn then
				self:OnAttack()
				self:OnMiss()
				self:OnCount()
			end
		end
	end
end
function ttk_boss_guaiwu_skills:OnCount()
	if self.count_listen then
		return
	end
	self.count_listen = 0
end
function ttk_boss_guaiwu_skills:OnTime()
	if self.time_listen then
		return
	end
	self.time_listen = true
	self.task = self.inst:DoPeriodicTask(1,function()
		local target = self.inst.components.combat and self.inst.components.combat.target or nil
		if noleader(self.inst) and not self.inst.inlimbo  and target and self.invalidtarget and self.invalidtarget(self,target) then
			for i,v in ipairs(self.current) do
				if not self:InCd(self.qxname..""..i) then
					if v.timefn  and v.timefn(self.inst,target) then
						self:StartCd(self.qxname..""..i,v.cd)
					end
				end
			end
		end
	end)
end
function ttk_boss_guaiwu_skills:OnHealthPer(tbl)
	if not self.inst.components.ttk_boss_healthtrigger then
		self.inst:AddComponent("ttk_boss_healthtrigger")
	end
	for _,v in ipairs(tbl) do
		self.inst.components.ttk_boss_healthtrigger:AddTrigger(v[1], v[2])
	end
end
function ttk_boss_guaiwu_skills:OnAttack()
	if self.attack_listen then
		return
	end
	self.attack_listen = true
	self.inst:ListenForEvent("onattackother",self.attackfn)
end
function ttk_boss_guaiwu_skills:OnMiss()
	if self.miss_listen then
		return
	end
	self.miss_listen = true
	self.inst:ListenForEvent("onmissother",self.missfn)
end
function ttk_boss_guaiwu_skills:OnSave()
    return { first = self.first ,by = self.by,qx = self.qx,st = self.st }
end
function ttk_boss_guaiwu_skills:OnLoad(data)
    if data then
		if data.first ~= nil then
			self.first  = data.first
		end
		if data.by then
			self.by = data.by
		end
		if data.qx then
			self.qx = data.qx
		end
		if data.st then
			self.st = data.st
		end
		if data.by and self.qx then
			self:OnInit()
		end
    end
end
return ttk_boss_guaiwu_skills
