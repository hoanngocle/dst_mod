-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/fire.zip")),
    Asset("SOUND", "sound/common.fsb"),
}
local prefabs =
{
    "firefx_light",
}
local heats = { 30, 70, 120, 180, 220, 240 }
local function GetHeatFn(inst)
    return 220
end
local function dodamage(inst,damage)
    local x,y,z = inst.Transform:GetWorldPosition()
    if inst.doattackfn and type(inst.doattackfn) == "function" then
        inst.doattackfn(inst,x,y,z)
        return
    end
    if inst.owner and (inst.owner.isplayer or inst.owner.ttk_boss_playeritem)  then
        local ents = XD_GetDamageTargets(x,y,z, 3)
        for i,v in pairs(ents) do
            if  v:IsValid() and inst.owner and inst.owner:IsValid() and  XD_CanAttackTrget(inst.owner,v) then
                local tick = GetTime()
                if v.wukong_firedamage == nil or (tick - v.wukong_firedamage) >= 0.4 then
                    v.wukong_firedamage = tick
                    local damage = inst.damage or 100
                    damage = Xd_CalcDamage(inst.owner,damage,v)
                    v.components.combat:GetAttacked(inst,damage)
                    inst:PushEvent("onareaattackother", { target = v})
                end
            end
        end
    else
        local notags = inst.isbird and { "FX", "NOCLICK", "DECOR", "INLIMBO","avoid_jfsnfire" }
        or { "FX", "NOCLICK", "DECOR", "INLIMBO","avoid_jfsndamage" }
        local ents = TheSim:FindEntities(x,y,z,inst.range or 3,{"_health","_combat"},notags)
        for k,v in pairs(ents) do
            if v.components.health ~= nil and not v.components.health:IsDead() then
                local attacker = inst.owner and inst.owner:IsValid() and inst.owner or inst
                if attacker and attacker.components.combat and attacker.components.combat:CanTarget(v)
                and (not v.last_xd_jfsn_fire_damagetime or (GetTime()-v.last_xd_jfsn_fire_damagetime)> 0.5) then
                    local damage = damage or 25
                    local olddamage
                    if damage ~= attacker.components.combat.defaultdamage then
                        olddamage = attacker.components.combat.defaultdamage
                        attacker.components.combat:SetDefaultDamage(damage)
                    end
                    attacker.components.combat.ignorehitrange = true
                    attacker.components.combat:DoAttack(v)
                    attacker.components.combat.ignorehitrange = false
                    if olddamage and attacker.components.combat then
                        attacker.components.combat:SetDefaultDamage(olddamage)
                    end
                    v.last_xd_jfsn_fire_damagetime = GetTime()
                end
            end
        end
    end
end
local function KeepTargetFn()
    return false
end
local function doremove(inst)
    if inst.damage_task then
        inst.damage_task:Cancel()
    end
    inst.SoundEmitter:KillSound("fire_loop")
    inst.AnimState:PlayAnimation("level3")
    inst:DoTaskInTime(0.3,function()
        inst.AnimState:PlayAnimation("level1")
        inst:DoTaskInTime(0.3,inst.Remove)
    end)
end
local function setother(inst)
    if inst.doremove then
        return
    end
    if inst.damage_task then
        inst.damage_task:Cancel()
    end
    inst.doremove = true
    local s  = 1/1.33
    inst.Transform:SetScale(s, s, s)
    inst.range = 2.2
    inst.isbird =  true
    dodamage(inst,20)
    inst.damage_task = inst:DoPeriodicTask(1,dodamage,1,20)
end
local function Count(boss,bird)
    local count = 0
    local x,y,z = boss.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 32, "ttk_boss_jfsnpet")
    for k,v in pairs(ents) do
        if v and v.prefab == bird  and v.boss == boss then
            count = count + 1
        end
    end
    return count
end
local function SetLavae(inst)
    if inst.damage_task then
        inst.damage_task:Cancel()
    end
    local s  = 0.3
    inst.Transform:SetScale(s, s, s)
    inst:DoTaskInTime(1.5,function()
        if inst.bossfn then
            inst:bossfn()
        end
    end)
end
local function setbird(inst,bird,boss)
    if inst.damage_task then
        inst.damage_task:Cancel()
    end
    local s  = 0.9/1.33
    inst.Transform:SetScale(s, s, s)
    inst:DoTaskInTime(1.5,function()
        if inst.bossfn then
            inst:bossfn()
        else
            if boss and boss:IsValid() and not boss.components.health:IsDead() then
                local count = Count(boss,bird)
                if count < 7 then
                    local bird = SpawnAt(bird,inst)
                    bird.components.entitytracker:TrackEntity("ttk_jfsn", boss)
                    bird:ListenForEvent("death",function()
                        bird.components.entitytracker:ForgetEntity("ttk_jfsn")
                        if bird.components.health and not bird.components.health:IsDead() then
                            bird.components.health.nofadeout = false
                            bird.components.health.minhealth =  0
                            bird.components.health:Kill()
                        end
                    end,boss)
                    bird:ListenForEvent("reset",function()
                        bird.components.entitytracker:ForgetEntity("ttk_jfsn")
                        if bird.components.health and not bird.components.health:IsDead() then
                            bird.components.health.nofadeout = false
                            bird.components.health.minhealth =  0
                            bird.components.health:Kill()
                        end
                    end,boss)
                    bird:ListenForEvent("onremove",function()
                        if bird:IsValid() then
                            bird:Remove()
                        end
                    end,boss)
                    bird.sg:GoToState("respawn")
                    bird.boss = boss
                    bird:DoPeriodicTask(1,function()
                        if bird:IsValid() and boss and boss:IsValid() and not bird:IsNear(boss,32) then
                            if not bird.components.health:IsDead() then
                                bird.components.health.nofadeout = false
                                bird.components.health.minhealth =  0
                                bird.components.health:Kill()
                            end
                        end
                    end)
                end
            end
        end
    end)
    inst:DoTaskInTime(2,doremove)
end
local function setchongsheng(inst,bird,boss)
    if inst.damage_task then
        inst.damage_task:Cancel()
    end
    if inst.removetask then
        inst.removetask:Cancel()
    end
    local s  = 1/1.33
    inst.Transform:SetScale(s, s, s)
    inst:DoTaskInTime(7,doremove)
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank(Boss.Art("fire"))
    inst.AnimState:SetBuild(Boss.Art("fire"))
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(FINALOFFSET_MAX)
    inst:SetPrefabNameOverride("ttk_jfsn")
    inst.SoundEmitter:PlaySound("dontstarve/common/forestfire","fire_loop")
    local s  = 1.33
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:PlayAnimation("level5", true)
    inst:AddTag("FX")
    inst:AddTag("HASHEATER")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(40)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn
    inst.damage_task = inst:DoPeriodicTask(0.5,dodamage,0.2)
    inst.SetOther = setother
    inst.SetBird = setbird
    inst.SetLavae = SetLavae
    inst.SetChongSheng = setchongsheng
    inst.removetask = inst:DoTaskInTime(3.1,doremove)
    inst.persists = false
    return inst
end
return Prefab("ttk_boss_jfsn_fire", fn, assets, prefabs)
