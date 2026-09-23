-- Private combat helpers for the statically ported Tu Tien encounters.
-- No source helper is installed into GLOBAL or the shared TUNING table.
local M = {}
function M.Art(name)
    return type(name)=="string" and name:gsub("^ttk_boss_","xd_"):gsub("^ttk_","xd_") or name
end
-- Return one path only: gsub's replacement count must never become Asset.param.
local ART_PATH_ALIASES = {
    ["anim/nn_well.zip"] = "anim/hh_hac_nguyet_ho.zip",
    ["anim/ttk_lucnguyen_thuy.zip"] = "anim/ttk_tinhlakiem.zip",
    ["anim/vanhonphien_cloakfx.zip"] = "anim/cloak_fx.zip",
    ["anim/xd_ftj.zip"] = "anim/ttk_lucnguyen_hoa.zip",
    ["anim/xd_futu.zip"] = "anim/ttk_futu.zip",
    ["anim/xd_jingwei_blowdart.zip"] = "anim/ttk_lucnguyen_weapon.zip",
    ["anim/xd_lunar_fx.zip"] = "anim/ttk_lunar_fx.zip",
    ["anim/xd_npxsz.zip"] = "anim/ttk_npxsz.zip",
    ["anim/xd_pog_fire.zip"] = "anim/ttk_pog_fire.zip",
    ["anim/xd_pog_firefire.zip"] = "anim/ttk_pog_firefire.zip",
    ["anim/xd_qlch.zip"] = "anim/ttk_skin_spirit.zip",
    ["anim/xd_slow_buff_ent.zip"] = "anim/ttk_slow_buff_ent.zip",
    ["anim/xd_spider.zip"] = "anim/ttk_spider.zip",
    ["anim/xd_spider_leg.zip"] = "anim/ttk_spider_leg.zip",
    ["anim/xd_spider_pro.zip"] = "anim/ttk_spider_pro.zip",
    ["anim/xd_spider_puff.zip"] = "anim/ttk_spider_puff.zip",
    ["anim/xd_spiderden.zip"] = "anim/ttk_spiderden.zip",
    ["anim/xd_sword_mo.zip"] = "anim/ttk_lucnguyen_loi.zip",
    ["anim/xd_sword_red.zip"] = "anim/ttk_lucnguyen_tho.zip",
    ["anim/xd_tianjiwu.zip"] = "anim/ttk_tianjiwu.zip",
    ["anim/xd_tianjiwu_skins_byj.zip"] = "anim/ttk_tianjiwu_skins_byj.zip",
    ["anim/xd_vortex_fx.zip"] = "anim/vanhonphien_vortexfx.zip",
    ["anim/xd_xlj.zip"] = "anim/ttk_tinhlakiem.zip",
}
function M.ArtPath(path)
    local resolved = path:gsub("ttk_boss_", "xd_")
    return ART_PATH_ALIASES[resolved] or resolved
end
M.TUNING = setmetatable({
    XD_QLCH_HEALTH=28000, XD_QLCH_DAMAGE=60,
    XD_QLCH_FS_HEALTH=13500, XD_QLCH_FS_DAMAGE=100,
    XD_QLCH_YUNSHIDAMAGE1=10, XD_QLCH_YUNSHIDAMAGE2=120,
    XD_JFSN_HEALTH=30000, XD_JFSN_DAMAGE=75, XD_JFSN_YUNSHIDAMAGE1=50,
    XD_SET1=false, XD_KAIQISHENGGE=false, XD_ZIYUNBOSS_COUNT=0,
    XD_SHENGTI_SKILLS={}, XD_GUAIWUSHENGTI={}, XD_GUAIWUBENYUAN={}, XD_GUAIWUQINGXIANG={},
}, {__index=TUNING})
M.STRINGS = setmetatable({NAMES=setmetatable({
    XD_QXDX_TALKS={"Dừng bước!", "Hãy xem bản lĩnh của ngươi!", "Chưa kết thúc đâu!", "Đạo pháp vô biên!", "Kiếm trận!"},
    XD_ZIYUNBOSS_TALKS={"Hồn phách, thức tỉnh!", "Hắc ám giáng lâm!", "Trận chiến đã kết thúc...", "Tử Vân Ma Quân"},
},{__index=STRINGS.NAMES})},{__index=STRINGS})

function M.IsDormant(inst)
    local seen={}
    for _=1,8 do
        if not inst or seen[inst] then return false end
        seen[inst]=true
        if inst._ttk_boss_main then
            return (inst.prefab=="ttk_qxdx" or inst.prefab=="ttk_futu" or inst.prefab=="ttk_ziyunboss")
                and not inst._ttk_boss_provoked
        end
        inst=inst.owner or (inst.components.follower and inst.components.follower.leader)
    end
    return false
end

function M.XD_CanAttackTrget(inst,target)
    if not inst or not target or M.IsDormant(inst) then return false end
    local c,t=inst.components,target.components
    local leader=c.follower and c.follower.leader
    return inst:IsValid() and target:IsValid() and inst~=target
        and t.health and not t.health:IsDead() and t.combat and c.combat
        and c.combat:IsValidTarget(target) and target~=inst.owner
        and not (inst.owner and target.owner==inst.owner)
        and not (c.petleash and c.petleash:IsPet(target))
        and not (inst.owner and inst.owner.components.petleash and inst.owner.components.petleash:IsPet(target))
        and not (t.follower and (t.follower.leader==inst or (leader and t.follower.leader==leader)))
        and not (inst.replica.combat and inst.replica.combat:IsAlly(target))
end

function M.XD_GetDamageTargets(x,y,z,range,excluded)
    -- These helpers belong to hostile bosses, so PvP being off must not exclude players.
    return TheSim:FindEntities(x,y,z,range,{"_combat","_health"},excluded or
        {"INLIMBO","wall","notarget","noattack","flight","invisible","playerghost"})
end

function M.Xd_GetElectricDamage(inst,target)
    return inst.components.electricattacks and not (target:HasTag("electricdamageimmune") or
        (target.components.inventory and target.components.inventory:IsInsulated())) and
        TUNING.ELECTRIC_DAMAGE_MULT + TUNING.ELECTRIC_WET_DAMAGE_MULT *
        (target.components.moisture and target.components.moisture:GetMoisturePercent() or (target:GetIsWet() and 1 or 0)) or 1
end

function M.Xd_CalcDamage(inst,damage,target,multiplier,base)
    if M.IsDormant(inst) or target:HasTag("alwaysblock") then return 0 end
    local c=inst.components.combat
    return (damage or c.defaultdamage or 0) * M.Xd_GetElectricDamage(inst,target)
        * (base or c.damagemultiplier or 1) * c.externaldamagemultipliers:Get()
        * (multiplier or 1) * (target:HasTag("player") and c.playerdamagepercent or 1)
        * (target:HasTag("player") and inst:HasTag("player") and c.pvp_damagemod or 1)
end

function M.XD_Get_OwnerCalcDamage(inst,rate)
    local old=inst.components.combat.CalcDamage
    inst.components.combat.CalcDamage=function(c,target,weapon,multiplier,...)
        local owner=inst.owner or (inst.components.follower and inst.components.follower.leader)
        if owner and owner:IsValid() and owner.components.combat then
            return M.Xd_CalcDamage(owner,c.defaultdamage,target,nil,rate)
        end
        return old(c,target,weapon,multiplier,...)
    end
end

function M.XD_GETWOLRDLEVEL() return 0 end -- Source fallback without cultivation component.
function M.XD_SAY(inst,str) if inst.components.talker then inst.components.talker:Say(str) end end

function M.XD_GetGroundPoints(pt,numRings,initialRadius,fxRadiusOffset,radiusStepDistance)
    local points={}
    local radius=initialRadius or 1
    for i=1,numRings or 3 do
        local r=math.max(0,radius+(fxRadiusOffset or 0))
        local count=math.floor(TWOPI*r*.25)
        if i==1 and count<=4 then count=1 end
        points[i]={}
        if count>1 then
            for p=1,count do local theta=TWOPI/count*p
                table.insert(points[i],Vector3(pt.x+r*math.cos(theta),0,pt.z+r*math.sin(theta)))
            end
        else table.insert(points[i],Vector3(pt.x,0,pt.z)) end
        radius=radius+(radiusStepDistance or 2)
    end
    return points
end

function M.XD_RANDOM_ANGLES(count,gap)
    local angles={}
    while #angles<count do
        local angle=math.random(-180,180)
        local valid=true
        for _,other in ipairs(angles) do
            local diff=math.abs(angle-other);if diff>180 then diff=360-diff end
            if diff<=(gap or 30) then valid=false;break end
        end
        if valid then table.insert(angles,angle) end
    end
    return angles
end

function M.XD_TELE_PLAYER(player,pos,pet)
    local function teleport(ent)
        if ent.Physics then ent.Physics:Teleport(pos.x,0,pos.z) else ent.Transform:SetPosition(pos:Get()) end
    end
    teleport(player)
    if pet and player.components.leader then
        for follower in pairs(player.components.leader.followers) do teleport(follower) end
    end
end

function M.XD_RECORDCOMBAT(inst,timeout)
    inst.maxtime_dropcombattime=timeout or 10
    local function start()
        if inst.ttk_boss_droptarget_task then inst.ttk_boss_droptarget_task:Cancel();inst.ttk_boss_droptarget_task=nil end
        inst.ttk_boss_combatstarttime=inst.ttk_boss_combatstarttime or GetTime()
    end
    inst:ListenForEvent("droppedtarget",function()
        if not inst.ttk_boss_droptarget_task then
            inst.ttk_boss_droptarget_task=inst:DoTaskInTime(inst.maxtime_dropcombattime,function()
                inst.ttk_boss_droptarget_task=nil;inst.ttk_boss_combatstarttime=nil;inst:PushEvent("ttk_boss_dropcombat")
            end)
        end
    end)
    for _,event in ipairs({"onattackother","onhitother","onmissother"}) do inst:ListenForEvent(event,start) end
end

local main={ttk_baihu=true,ttk_jfsn=true,ttk_qlch=true,ttk_qxdx=true,ttk_futu=true,
    ttk_spiderqueen=true,ttk_ziyunboss=true,ttk_stalke_fuben=true,ttk_deerclops_ziyun=true}
function M.Prefab(name,fn,assets,deps,...)
    local function construct(...)
        local inst=fn(...)
        if not inst then return inst end
        inst._ttk_boss_auxiliary=not main[name] or nil
        if main[name] and inst.SetPrefabNameOverride then inst:SetPrefabNameOverride(name) end
        if main[name] and TheWorld.ismastersim then
            inst.persists=true
            if not inst.components.knownlocations then inst:AddComponent("knownlocations") end
            inst:DoTaskInTime(0,function()
                if not inst.components.knownlocations:GetLocation("home") then
                    inst.components.knownlocations:RememberLocation("home",inst:GetPosition())
                end
            end)
            if name=="ttk_ziyunboss" or name=="ttk_qxdx" then
                local save,load=inst.OnSave,inst.OnLoad
                inst.OnSave=function(self,data,...)
                    local refs=save and save(self,data,...) or nil
                    data.ttk_boss_mode=self.mode
                    local pet=(self.mode==2 and self.mode2_pet or self.mode==3 and self.mode3_pet) or nil
                    data.ttk_boss_phase_alive=pet~=nil and pet:IsValid() and not pet.components.health:IsDead()
                    data.ttk_boss_phase_pending=self.sg and (self.sg.currentstate.name=="fly_down" or self.sg.currentstate.name=="resurrect") or false
                    data.ttk_boss_phase_health=data.ttk_boss_phase_alive and pet.components.health:GetPercent() or nil
                    return refs
                end
                inst.OnLoad=function(self,data,...)
                    if load then load(self,data,...) end
                    if data and not data.ttk_boss_rewarded and data.ttk_boss_mode and data.ttk_boss_mode>1 then
                        self:DoTaskInTime(0,function()
                            if not self:IsValid() then return end
                            self:ChangeMode(data.ttk_boss_mode)
                            if name=="ttk_ziyunboss" then
                                self.components.health:SetCurrentHealth(math.max(1,self.components.health.currenthealth))
                                self.sg:GoToState(self.mode==2 and "idle_fly" or "idle")
                                if data.ttk_boss_phase_alive or data.ttk_boss_phase_pending then
                                    local pet=SpawnPrefab(self.mode==2 and "ttk_boss_deerclops_ziyun_aux" or "ttk_boss_ziyunboss_channeler")
                                    if pet then
                                        pet.Transform:SetPosition(self.Transform:GetWorldPosition())
                                        pet:OnSpawnedBy(self)
                                        if data.ttk_boss_phase_health then pet.components.health:SetPercent(data.ttk_boss_phase_health) end
                                    end
                                elseif self.mode==2 then
                                    self:PushEvent("gotophase3")
                                else
                                    self.components.health:SetInvincible(false)
                                    self:RemoveTag("notarget")
                                end
                            end
                        end)
                    end
                end
            end
            if name=="ttk_ziyunboss" then
                local health=inst.components.health
                local delta,kill=health.DoDelta,health.Kill
                health.DoDelta=function(h,amount,...)
                    if inst.mode==1 and amount<0 and h.currenthealth+amount<=0 then inst._ttk_boss_phase_transition=true end
                    return delta(h,amount,...)
                end
                health.Kill=function(h,...)
                    if inst.mode==1 then inst._ttk_boss_phase_transition=true end
                    return kill(h,...)
                end
            end
            -- Vanilla healthtrigger only fires when a threshold is crossed.
            -- Preserve skill stages so reloading below a threshold cannot reset
            -- the boss to stage one permanently.
            local save,load=inst.OnSave,inst.OnLoad
            local fields={"skillmode","skillcount","attack_count","attack_round","pet_count","petcount","spawnfs"}
            inst.OnSave=function(self,data,...)
                local refs=save and save(self,data,...) or nil
                local state={}
                for _,field in ipairs(fields) do state[field]=self[field] end
                if name=="ttk_qlch" then
                    state.soldiers={}
                    for _,soldier in pairs(self.components.commander:GetAllSoldiers()) do
                        if soldier:IsValid() and not soldier.components.health:IsDead() then
                            table.insert(state.soldiers,{skillnum=soldier.skillnum,health=soldier.components.health:GetPercent()})
                        end
                    end
                end
                data.ttk_boss_combatstate=state
                return refs
            end
            inst.OnLoad=function(self,data,...)
                if load then load(self,data,...) end
                local state=data and data.ttk_boss_combatstate
                if not state then return end
                for _,field in ipairs(fields) do if state[field]~=nil then self[field]=state[field] end end
                if name=="ttk_qlch" and not data.ttk_boss_rewarded and state.soldiers then
                    self:DoTaskInTime(0,function()
                        for _,entry in ipairs(state.soldiers) do
                            local soldier=SpawnPrefab("ttk_boss_qlch_fs")
                            if soldier then
                                local x,y,z=self.Transform:GetWorldPosition()
                                soldier.Transform:SetPosition(x+(entry.skillnum==1 and 4 or -4),0,z)
                                soldier.skillnum=entry.skillnum
                                soldier.persists=false
                                self.components.commander:AddSoldier(soldier)
                                soldier.components.health:SetPercent(entry.health)
                                soldier.AnimState:SetMultColour(1,1,1,.85)
                            end
                        end
                        if self.skillmode==3 and #state.soldiers==0 and not self.spawnfs then self.skillmode=4 end
                    end)
                end
            end
        end
        return inst
    end
    return Prefab(name,construct,assets,deps,...)
end
return M
