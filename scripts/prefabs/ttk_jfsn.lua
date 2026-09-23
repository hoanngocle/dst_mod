-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_GETWOLRDLEVEL = Boss.XD_GETWOLRDLEVEL
local brain = require "brains/ttk_boss_jfsnbrain"
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/malbatross_basic.zip")),
    Asset("ANIM", Boss.ArtPath("anim/malbatross_actions.zip")),
    Asset("ANIM", Boss.ArtPath("anim/malbatross_build.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_jfsn.zip")),
}
local prefabs =
{
}
local TARGET_DIST = 16
local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "wall","INLIMBO","avoid_jfsnfire" }
local function RetargetFn(inst)
    local range = inst:GetPhysicsRadius(0) + 8
    return FindEntity(
            inst,
            TARGET_DIST,
            function(guy)
                return inst.components.combat:CanTarget(guy)
                    and (   guy.components.combat:TargetIs(inst) or
                            guy:IsNear(inst, range)
                        )
            end,
            RETARGET_MUST_TAGS,
            RETARGET_CANT_TAGS
        )
end
local function KeepTargetFn(inst, target)
    local home = inst.components.knownlocations:GetLocation("home")
    if home and inst:GetDistanceSqToPoint(home:Get()) > 240 * 240 then
        return false
    end
    return inst.components.combat:CanTarget(target)
end
local function ShouldSleep(inst)
    return false
end
local function ShouldWake(inst)
    return true
end
local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        local target = inst.components.combat.target
        if not (target ~= nil and
                target:HasTag("player") and
                target:IsNear(inst, TUNING.DRAGONFLY_ATTACK_RANGE + target:GetPhysicsRadius(0))) then
            inst.components.combat:SetTarget(data.attacker)
        end
    end
    inst:ReSetTuoZhan()
end
local function OnHitOther(inst,data)
    inst:ReSetTuoZhan()
    if  not inst.components.combat.areahitdisabled and data and data.target and data.target:IsValid() then
        if not (data.target.components.health and data.target.components.health:IsDead()) and data.target.components.burnable then
            if not data.target.components.burnable:IsBurning() and (data.target.components.burnable.canlight or data.target.components.combat ~= nil) then
                data.target.components.burnable:Ignite(true, inst)
            end
        end
    end
end
local function OnAreaAttackOther(inst,data)
    if not inst.components.combat.areahitdisabled and data and data.target and data.target:IsValid() then
        if not (data.target.components.health and data.target.components.health:IsDead()) and data.target.components.burnable then
            if not data.target.components.burnable:IsBurning() and (data.target.components.burnable.canlight or data.target.components.combat ~= nil) then
                data.target.components.burnable:Ignite(true, inst)
            end
        end
    end
end
local function OnSave(inst, data)
end
local function OnLoad(inst, data)
end
SetSharedLootTable('ttk_jfsn',
{
    {'greengem',                                1.00},
    {'greengem',                                1.00},
    {'orangegem',                                1.00},
    {'orangegem',                                1.00},
    {'yellowgem',                                1.00},
    {'yellowgem',                                1.00},
    {'purplegem',                                1.00},
    {'purplegem',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
    {'goldnugget',                                1.00},
})
local function isinrange(inst,target,rd)
    local ang = inst.Transform:GetRotation()
    local x,y,z = target.Transform:GetWorldPosition()
    local angle = inst:GetAngleToPoint( x,0,z )
    local drot = math.abs( ang - angle )
    while drot > 180 do
        drot = math.abs(drot - 360)
    end
    return drot < (rd or 30)
end
local function DoCast(inst,time)
    if inst.skillmode == 1  then
        inst.components.timer:StartTimer("spell_cd", time or 9.9)
    elseif inst.skillmode == 2  then
        inst.components.timer:StartTimer("spell_cd", time or 10)
    elseif inst.skillmode == 3  then
        inst.components.timer:StartTimer("spell_cd", time or 6.6)
    end
    if inst.skillmode == 2 then
        inst.skillcount =  inst.skillcount %4 + 1
    else
        inst.skillcount =  inst.skillcount %3 + 1
    end
    inst:PushEvent("onspell")
    return true
end
local SPOREBOMBTARGET_MUST_TAGS = { "player" }
local SPOREBOMBTARGET_CANT_TAGS = { "ghost", "playerghost", "shadow", "shadowminion", "noauradamage", "INLIMBO" }
local function FindTargets(inst)
    local targets = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, SPOREBOMBTARGET_MUST_TAGS, SPOREBOMBTARGET_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v.entity:IsVisible() and
        v:DebuffsEnabled() and not v.jfsn_bird_task and
        not (v.components.health ~= nil and v.components.health:IsDead()) then
            table.insert(targets, v)
        end
    end
    return targets
end
local function SpawnFX(inst,boss)
    local fxdata =  inst.components.burnable  and inst.components.burnable.fxdata  or {{ x = 0, y = 0, z = 0, level = 2 }}
    local fxoffset = inst.components.burnable  and inst.components.burnable.fxoffset or Vector3(0, 0, 0)
    local level =  inst.components.burnable and inst.components.burnable.fxlevel or 2
    for k, v in pairs(fxdata) do
        local fx = SpawnPrefab("ttk_boss_jcbird_fire")
        if fx ~= nil then
            if v.finaloffset ~= nil then
                fx.AnimState:SetFinalOffset(v.finaloffset)
            end
            local scale = inst.Transform:GetScale()
            if v.scale then
                scale = scale * v.scale
            end
            fx.Transform:SetScale(scale,scale,scale)
            local xoffs, yoffs, zoffs = v.x + fxoffset.x, v.y + fxoffset.y, v.z + fxoffset.z
            if v.follow ~= nil then
                inst:AddChild(fx)
                fx.entity:AddFollower()
                fx.Follower:FollowSymbol(inst.GUID, v.follow, xoffs, yoffs, zoffs)
            else
                inst:AddChild(fx)
                fx.Transform:SetPosition(xoffs, yoffs, zoffs)
            end
            fx.persists = false
            fx.AnimState:PlayAnimation("level"..level.."_controlled_burn",true)
            fx:DoTaskInTime(3,fx.Remove)
            inst:DoTaskInTime(3,function()
                local new = SpawnPrefab("ttk_boss_jcbird_fire_over")
                if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
                    new.AnimState:SetBank(Boss.Art("wilsonbeefalo"))
                end
                new.entity:SetParent(inst.entity)
                new.owner = inst
                new.boss = boss
            end)
            break
        end
    end
end
local function ZhaoHuan(inst)
    inst:DoCast()
    local targets = FindTargets(inst)
    if next(targets) then
        shuffleArray(targets)
        for k= 1,math.min(2,#targets) do
            if targets[k] then
                targets[k].jfsn_bird_task =  true
                SpawnFX(targets[k],inst)
            end
        end
    end
end
local function ReSet(inst,removepets)
    inst.components.health:SetPercent(1)
    inst.attack_count = 0
    inst.skillmode = 1
    inst.skillcount = 1
    inst:PushEvent("reset")
    inst.pet_count = 0
    inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1+ 0.08 *inst.pet_count)
end
local function ReSetTuoZhan(inst)
    inst.lastattacktime = GetTime()
    if not inst.tuozhantask then
        inst.tuozhantask = inst:DoPeriodicTask(1,function()
            if inst.lastattacktime and (GetTime()- inst.lastattacktime) >= 120 and not inst.components.health:IsDead() then
                inst.tuozhantask:Cancel()
                inst.tuozhantask = nil
                inst:ReSet()
            end
        end)
    end
end
local function OnPetDeath(inst)
    inst.pet_count = math.min(20,inst.pet_count + 1)
    inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1+ 0.08 *inst.pet_count)
end
local function GoHome(inst)
    inst:ReSet()
    inst.sg:GoToState("shengtian")
    if inst.components.combat ~= nil then
       inst.components.combat:SetTarget(nil)
        inst.components.combat:BlankOutAttacks(2)
    end
end
local function OnHealthTrigger1(inst)
    inst.skillmode = 2
    inst.skillcount = 1
end
local function OnHealthTrigger2(inst)
    inst.skillmode = 3
    inst.skillcount = 1
end
local function empty()
end
local function OnDeath(inst)
    if not inst.components.ttk_boss_choujiang_creature and TheWorld and TheWorld.components.ttk_boss_jfsnspwner then
        TheWorld.components.ttk_boss_jfsnspwner:StartSpawnBoss(TUNING.XD_BOSS_JFSN_RESPAWNTIME)
    end
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    MakeTinyFlyingCharacterPhysics(inst,1000, 1.5)
    local s  = 1.30
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetBank(Boss.Art("malbatross"))
    inst.AnimState:SetBuild(Boss.Art("xd_jfsn"))
    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("ttk_jfsn")
    inst:AddTag("avoid_jfsnfire")
    inst:AddTag("avoid_jfsndamage")
    inst.DynamicShadow:SetSize(6, 2)
    inst.Transform:SetSixFaced()
    inst.AnimState:PlayAnimation("idle_loop", true)
    MakeInventoryFloatable(inst, "large")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.pet_count = 0
    inst.skillmode = 1
    inst.skillcount = 1
    inst.attack_count = 0
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true }
    inst:SetStateGraph("SGttk_jfsn")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.XD_JFSN_HEALTH)
    inst.components.health.destroytime = 5
    -- Normal health persistence: registry encounters survive save/load.
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.XD_JFSN_DAMAGE)
    inst.components.combat.playerdamagepercent = 1
    inst.components.combat.battlecryenabled = false
    inst.components.combat:SetRange(5)
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetAreaDamage(8.5, 1,function(target,inst)
        return isinrange(inst,target,30) and target.prefab ~= "ttk_boss_jcbird_spitter"
    end)
    inst.components.combat:EnableAreaDamage(false)
    local healthtrigger = inst:AddComponent("healthtrigger")
    healthtrigger:AddTrigger(0.8, OnHealthTrigger1)
    healthtrigger:AddTrigger(0.35, OnHealthTrigger2)
    inst:AddComponent("inventory")
    inst:AddComponent("explosiveresist")
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ttk_jfsn')
    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("spell_cd", 9.9)
    inst:AddComponent("knownlocations")
    inst:AddComponent("entitytracker")
    inst:AddComponent("ttk_boss_guaiwu_skills")
    inst.components.ttk_boss_guaiwu_skills.first = false
    inst.components.ttk_boss_guaiwu_skills.noskill =  true
    inst.components.ttk_boss_guaiwu_skills.by = 4
    inst.components.ttk_boss_guaiwu_skills.qx = 4
    inst:SetBrain(brain)
    inst:ListenForEvent("onareaattackother",OnAreaAttackOther)
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDeath)
    local level = XD_GETWOLRDLEVEL()
    if TUNING.XD_SET1 and level >= 9 and TUNING.XD_KAIQISHENGGE then
        inst:AddComponent("ttk_boss_guaiwu_skills")
        inst.components.ttk_boss_guaiwu_skills.first = false
        inst.components.ttk_boss_guaiwu_skills:Chososest()
    end
    inst.ReSetTuoZhan = ReSetTuoZhan
    inst.OnPetDeath = OnPetDeath
    inst.ZhaoHuan = ZhaoHuan
    inst.ReSet = ReSet
    inst.GoHome = GoHome
    inst.DoCast = DoCast
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    return inst
end
return Prefab("ttk_jfsn", fn, assets, prefabs)
