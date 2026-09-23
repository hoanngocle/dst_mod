-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/deer_build.zip")),
    Asset("ANIM", Boss.ArtPath("anim/deer_basic.zip")),
    Asset("ANIM", Boss.ArtPath("anim/deer_action.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_qlch.zip")),
}
local prefabs =
{
}
local brain = require("brains/ttk_boss_qlchbrain")
local fsbrain = require("brains/ttk_boss_qlchfsbrain")
local texiaobrain = require("brains/ttk_boss_qlchtxbrain")
SetSharedLootTable('ttk_qlch',
{
    {'greengem',              1.00},
    {'greengem',              1.00},
    {'orangegem',              1.00},
    {'orangegem',              1.00},
    {'yellowgem',              1.00},
    {'yellowgem',              1.00},
    {'goldnugget',              1.00},
    {'goldnugget',              1.00},
    {'goldnugget',              1.00},
    {'goldnugget',              1.00},
    {'goldnugget',              1.00},
})
local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
    and target:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("spawnpoint")) < 60 * 60
end
local function KeepTargetFnFS(inst, target)
    return false
end
local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst:ReSetTuoZhan()
end
local function OnHitOther(inst)
    inst:ReSetTuoZhan()
end
local function OnSpell(inst)
    inst:ReSetTuoZhan()
end
local function ontimerdone(inst, data)
    if data ~= nil then
    end
end
local function DoNothing()
end
local function DoChainIdleSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain_idle", nil, volume)
end
local function DoBellIdleSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell_idle", nil, volume)
end
local function DoChainSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/chain", nil, volume)
end
local function DoBellSound(inst, volume)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/deer/bell", nil, volume)
end
local function SetupSounds(inst)
    if inst.gem == nil then
        inst.DoChainSound = DoNothing
        inst.DoChainIdleSound = DoNothing
        inst.DoBellSound = DoNothing
        inst.DoBellIdleSound = DoNothing
    elseif IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.DoChainSound = DoChainSound
        inst.DoChainIdleSound = DoChainIdleSound
        inst.DoBellSound = DoBellSound
        inst.DoBellIdleSound = DoBellIdleSound
    else
        inst.DoChainSound = DoChainSound
        inst.DoChainIdleSound = DoChainIdleSound
        inst.DoBellSound = DoNothing
        inst.DoBellIdleSound = DoNothing
    end
end
local function bossxiaoci(inst)
    for k = 1,3 do
        local pt = inst:GetPosition()
        local theta = math.random() * 2 * PI
        local radius = GetRandomMinMax(1, 2)
        local offset = FindWalkableOffset(pt, theta, radius, 6, true)
        if offset ~= nil then
            pt.x = pt.x + offset.x
            pt.z = pt.z + offset.z
        end
        local fx = SpawnPrefab("ttk_boss_sandspike")
        fx.caster = inst
        fx.animname = "med"
        fx.boom = true
        fx.damage = 20
        fx.damageradius = 1.3
        fx.Transform:SetPosition(pt.x, 0, pt.z)
    end
end
local function SpawnSandSpike(inst)
    for k = -30 ,30 ,30 do
        local numsteps = 6
        local x, y, z = inst.Transform:GetWorldPosition()
        local angle = (inst.Transform:GetRotation() + 90 + k) * DEGREES
        local step = 3.5
        local offset = 0.5
        local ground = TheWorld.Map
        local i = 0
        local fx, dist, x1, z1
        while i < numsteps do
            i = i + 1
            dist = i * step + offset
            x1 = x + dist * math.sin(angle)
            z1 = z + dist * math.cos(angle)
            fx = SpawnPrefab("ttk_boss_sandspike")
            fx.caster = inst
            fx.Transform:SetPosition(x1, 0, z1)
        end
    end
    bossxiaoci(inst)
end
local function SpawnSandBlock(inst,target)
    if target and target:IsValid() then
        local fx = SpawnAt("ttk_boss_sandblock", target)
        fx.caster = inst
    end
end
local function SpawnShadowMeteor(inst,target)
    if target and target:IsValid() then
        local fx = SpawnAt("ttk_boss_shadowmeteor", target)
        fx.caster = inst
    end
end
local function resetcdtims(inst,time)
    if inst.components.timer:TimerExists("spell_cd") then
        inst.components.timer:SetTimeLeft("spell_cd", time)
    else
        inst.components.timer:StartTimer("spell_cd", time)
    end
end
local function xiaoci(inst,targets)
    local targets = inst.ci_targets or {}
    inst:StartThread(function()
        for k = 1,3 do
            for _,v in ipairs(targets) do
                local pt = Vector3(v.pt.x,0,v.pt.z)
                local theta = math.random() * 2 * PI
                local radius = GetRandomMinMax(0, 1)
                local offset = FindWalkableOffset(pt, theta, radius, 6, true)
                if offset ~= nil then
                    pt.x = pt.x + offset.x
                    pt.z = pt.z + offset.z
                end
                local fx = SpawnPrefab("ttk_boss_sandspike")
                fx.caster = inst
                fx.animname = "med"
                fx.boom = true
                fx.damageradius = 1.3
                fx.Transform:SetPosition(pt.x, 0, pt.z)
            end
            Sleep(0.2)
        end
    end)
end
local function findplayers(inst)
    inst.ci_targets = {}
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 24, {"player","_health","_combat"},{"playerghost"})
    if #ents > 0 then
        for i_,v in ipairs(ents) do
            if not (v.components.health and v.components.health:IsDead()) then
                table.insert(inst.ci_targets,{pt = v:GetPosition(),player = v})
            end
         end
    end
end
local function DoCast(inst, targets,spelltype)
    if inst.skillmode == 1  then
        SpawnSandSpike(inst)
        inst.components.timer:StartTimer("spell_cd", 6.6)
    elseif inst.skillmode == 2  then
        if inst.skillcount == 1 then
            SpawnSandSpike(inst)
        elseif inst.skillcount == 2 then
            SpawnSandBlock(inst,targets)
        elseif  inst.skillcount == 3 then
            SpawnSandSpike(inst)
            SpawnShadowMeteor(inst,targets)
        end
        inst.components.timer:StartTimer("spell_cd", 3.3)
    elseif inst.skillmode == 3  then
        SpawnSandSpike(inst)
        inst.components.timer:StartTimer("spell_cd", 3.3)
    elseif inst.skillmode == 4 then
        if inst.skillcount == 2 then
            SpawnSandSpike(inst)
            SpawnShadowMeteor(inst,targets)
        else
            xiaoci(inst)
            inst:DoTaskInTime(0.65,findplayers)
            inst:DoTaskInTime(1,xiaoci)
            inst:DoTaskInTime(1.65,findplayers)
            inst:DoTaskInTime(2,xiaoci)
            SpawnSandSpike(inst)
        end
        inst.components.timer:StartTimer("spell_cd", 3.3)
    end
    if inst.skillmode == 4 then
        inst.skillcount =  inst.skillcount %2 + 1
    else
        inst.skillcount =  inst.skillcount %3 + 1
    end
    inst:PushEvent("onspell")
    return true
end
local function DoCastFS(inst)
    if inst.skillnum == 1 then
        xiaoci(inst)
        inst:DoTaskInTime(0.65,findplayers)
        inst:DoTaskInTime(1,xiaoci)
        inst:DoTaskInTime(1.65,findplayers)
        inst:DoTaskInTime(2,xiaoci)
    else
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 30, {"player","_health","_combat"},{"playerghost"})
        if #ents > 0 then
            for i_,v in ipairs(ents) do
                if not (v.components.health and v.components.health:IsDead()) then
                    SpawnAt("ttk_boss_qlch_cloud",v)
                end
             end
        end
    end
end
local function OnHealthTrigger1(inst)
    inst.skillmode = 2
    inst.skillcount = 1
end
local function OnHealthTrigger2(inst)
    inst.skillmode = 3
    inst.skillcount = 1
    if  not inst.components.health:IsDead() then
        inst.spawnfs = true
        inst:PushEvent("transition")
    end
end
local function PetFadeIn(inst,remove)
    local fx = SpawnPrefab("ttk_boss_bigspawn_fx_medium_static")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    if remove then
        inst.progress = 0.85
        inst.coltask = inst:DoPeriodicTask(0, function()
            inst.progress = math.max(0,inst.progress - 0.02)
            inst.AnimState:SetMultColour(1, 1, 1, inst.progress)
            if inst.progress  <= 0 then
                inst.coltask:Cancel()
                inst:Remove()
            end
        end)
    else
        inst.AnimState:SetMultColour(1, 1, 1, 0)
        inst.progress = 0
        inst.coltask = inst:DoPeriodicTask(0, function()
            inst.progress = math.min(0.85,inst.progress + 0.02)
            inst.AnimState:SetMultColour(1, 1, 1, inst.progress)
            if inst.progress >= 0.85 then
                inst.coltask:Cancel()
                inst.coltask = nil
            end
        end)
    end
end
local function SummonSpecter(inst)
    inst.spawnfs = false
    inst.petcount = 2
    local pos = inst:GetPosition()
    local rot = inst.Transform:GetRotation()
    local theta = (rot - 90) * DEGREES
    local offset =
        FindWalkableOffset(pos, theta, inst.deer_dist, 5, true, false) or
        FindWalkableOffset(pos, theta, inst.deer_dist * .5, 5, true, false) or
        Vector3(0, 0, 0)
    local deer = SpawnPrefab("ttk_boss_qlch_fs")
    deer.Transform:SetRotation(rot)
    deer.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
    inst.components.commander:AddSoldier(deer)
    deer.skillnum = 1
    deer.persists = false
    PetFadeIn(deer)
    theta = (rot + 90) * DEGREES
    offset =
        FindWalkableOffset(pos, theta, inst.deer_dist, 5, true, false) or
        FindWalkableOffset(pos, theta, inst.deer_dist * .5, 5, true, false) or
        Vector3(0, 0, 0)
    deer = SpawnPrefab("ttk_boss_qlch_fs")
    deer.Transform:SetRotation(rot)
    deer.Transform:SetPosition(pos.x + offset.x, 0, pos.z + offset.z)
    inst.components.commander:AddSoldier(deer)
    deer.skillnum = 2
    deer.persists = false
    PetFadeIn(deer)
    resetcdtims(inst,3)
end
local function ReSet(inst,removepets)
    inst.skillmode = 1
    inst.skillcount = 1
end
local function IsDeadKeeper(keeper)
    return keeper.components.health ~= nil
        and keeper.components.health:IsDead()
end
local function UpdateDeerOffsets(inst)
    if inst.components.commander:GetNumSoldiers() > 0 then
        local deers = inst.components.commander:GetAllSoldiers()
        local theta = inst.Transform:GetRotation() * DEGREES
        local xoffs = inst.deer_dist * math.sin(theta)
        local zoffs = inst.deer_dist * math.cos(theta)
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, z1 = x - xoffs, z - zoffs
        x, z = x + xoffs, z + zoffs
        if #deers > 1 then
            local score1 = deers[1]:GetDistanceSqToPoint(x, 0, z) + deers[2]:GetDistanceSqToPoint(x1, 0, z1)
            local score2 = deers[2]:GetDistanceSqToPoint(x, 0, z) + deers[1]:GetDistanceSqToPoint(x1, 0, z1)
            if score1 < score2 then
                deers[1]:OnUpdateOffset(Vector3(xoffs, 0, zoffs))
                deers[2]:OnUpdateOffset(Vector3(-xoffs, 0, -zoffs))
            else
                deers[2]:OnUpdateOffset(Vector3(xoffs, 0, zoffs))
                deers[1]:OnUpdateOffset(Vector3(-xoffs, 0, -zoffs))
            end
        elseif #deers > 0 then
            deers[1]:OnUpdateOffset(deers[1]:GetDistanceSqToPoint(x, 0, z) < deers[1]:GetDistanceSqToPoint(x1, 0, z1) and Vector3(xoffs, 0, zoffs) or Vector3(-xoffs, 0, -zoffs))
        end
    end
end
local function ShareTargetFn(dude)
    return dude:HasTag("qlchboss")
end
local function GemmedOnAttacked(inst, data)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    if keeper and  not IsDeadKeeper(keeper) then
        inst.components.combat:ShareTarget(data.attacker, 12, ShareTargetFn, 1)
    else
        inst.components.combat:SetTarget(data.attacker)
    end
end
local function OnGotCommander(inst, data)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    if keeper ~= data.commander then
        inst.components.entitytracker:ForgetEntity("keeper")
        inst.components.entitytracker:TrackEntity("keeper", data.commander)
        inst.components.knownlocations:RememberLocation("keeperoffset", inst:GetPosition() - data.commander:GetPosition(), false)
        inst:AddTag("notaunt")
    end
end
local function OnLostCommander(inst, data)
    local keeper = inst.components.entitytracker:GetEntity("keeper")
    if keeper == data.commander then
        inst.components.entitytracker:ForgetEntity("keeper")
        inst.components.knownlocations:ForgetLocation("keeperoffset")
        inst:RemoveTag("notaunt")
    end
end
local function onsoldierschanged(inst)
    if inst.skillmode == 3 and inst.components.commander.numsoldiers == 0 then
        inst.skillmode = 4
        inst.skillcount = 1
    end
end
local function OnUpdateOffset(inst, offset)
    inst.components.knownlocations:RememberLocation("keeperoffset", offset)
end
local function GoHome(inst)
    local fx = SpawnPrefab("ttk_boss_bigspawn_fx_medium_static")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
    inst.sg:GoToState("idle")
    if inst.components.combat ~= nil then
       inst.components.combat:SetTarget(nil)
        inst.components.combat:BlankOutAttacks(1)
    end
    inst.components.health:SetInvincible(true)
    inst.components.colourtweener:StartTween({1, 1, 1, 0}, 0.5, function()
        inst.components.health:SetInvincible(false)
        inst.components.health:SetPercent(1)
        inst.AnimState:SetMultColour(1, 1, 1, 1)
        local pos = inst.components.knownlocations:GetLocation("spawnpoint")
        inst.Transform:SetPosition(inst.components.knownlocations:GetLocation("spawnpoint"):Get())
        inst.reset = false
        inst:ReSet()
    end)
    local Soldiers = inst.components.commander:GetAllSoldiers()
    for k,v in pairs(Soldiers) do
        v.components.health:SetInvincible(true)
        v:AddTag("notarget")
        PetFadeIn(v,true)
    end
end
local function OnDeath(inst)
    local Soldiers = inst.components.commander:GetAllSoldiers()
    for k,v in pairs(Soldiers) do
        v.components.health:Kill()
    end
    if not inst.components.ttk_boss_choujiang_creature and TheWorld and TheWorld.components.ttk_boss_qlchspwner then
        TheWorld.components.ttk_boss_qlchspwner:StartSpawnBoss(TUNING.XD_BOSS_QLCH_RESPAWNTIME)
    end
end
local function ReSetTuoZhan(inst)
    inst.lastattacktime = GetTime()
    if not inst.tuozhantask then
        inst.tuozhantask = inst:DoPeriodicTask(1,function()
            if inst.lastattacktime and (GetTime()- inst.lastattacktime) >= 120 and not inst.components.health:IsDead() then
                inst.tuozhantask:Cancel()
                inst.tuozhantask = nil
                inst.components.health:SetPercent(1)
                inst:ReSet()
                local Soldiers = inst.components.commander:GetAllSoldiers()
                for k,v in pairs(Soldiers) do
                    v.components.health:SetInvincible(true)
                    v:AddTag("notarget")
                    PetFadeIn(v,true)
                end
            end
        end)
    end
end
local function empty()
end
local function common_fn(gem)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.DynamicShadow:SetSize(1.75, .75)
    inst.Transform:SetSixFaced()
    local s  = gem and 1.32 or 1.65
    inst.Transform:SetScale(s, s, s)
    inst:SetPhysicsRadiusOverride(1.5)
	MakeGiantCharacterPhysics(inst, 1000, inst.physicsradiusoverride)
    inst.AnimState:SetBank(Boss.Art("deer"))
    inst.AnimState:SetBuild(Boss.Art("xd_qlch"))
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst:AddTag("animal")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("qlch")
    if gem then
        inst.Physics:ClearCollidesWith(COLLISION.OBSTACLES)
        RemovePhysicsColliders(inst)
        inst:AddTag("qlch_pet")
        inst:AddTag("ttk_boss_skill_pet")
        inst.AnimState:SetAddColour(250/255,250/255, 180/255, 1)
        inst.nohighlight = true
    else
        inst.Physics:ClearCollidesWith(COLLISION.OBSTACLES)
        inst:AddTag("epic")
        inst:AddTag("qlchboss")
    end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.deer_dist = 5
    inst.skillmode = 1
    inst.skillcount = 1
    inst.gem = gem
    inst.DoCast = DoCast
    inst.DoCastFS = DoCastFS
    inst.ReSet = ReSet
    inst.ci_targets = {}
    inst:AddComponent("knownlocations")
    inst:AddComponent("health")
    inst:AddComponent("inspectable")
    inst:AddComponent("timer")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 2
    inst:AddComponent("lootdropper")
    if gem then
        inst:SetBrain(fsbrain)
        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(TUNING.XD_QLCH_FS_DAMAGE)
        inst.components.combat:SetAttackPeriod(5)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFnFS)
        inst.components.health:SetMaxHealth(TUNING.XD_QLCH_FS_HEALTH)
        inst:AddComponent("entitytracker")
        inst:ListenForEvent("gotcommander", OnGotCommander)
        inst:ListenForEvent("lostcommander", OnLostCommander)
        inst:ListenForEvent("attacked", GemmedOnAttacked)
        inst.OnUpdateOffset = OnUpdateOffset
    else
        inst:AddComponent("colourtweener")
        inst.SummonSpecter = SummonSpecter
        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(TUNING.XD_QLCH_DAMAGE)
        inst.components.combat.hiteffectsymbol = "deer_torso"
        inst.components.combat:SetRange(4)
        inst.components.combat:SetAttackPeriod(3)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        inst.components.health:SetMaxHealth(TUNING.XD_QLCH_HEALTH)
        -- Normal health persistence: registry encounters survive save/load.
        inst.ReSetTuoZhan = ReSetTuoZhan
        inst.GoHome = GoHome
        inst:AddComponent("commander")
        inst.components.commander:SetTrackingDistance(30)
        local healthtrigger = inst:AddComponent("healthtrigger")
        healthtrigger:AddTrigger(0.85, OnHealthTrigger1)
        healthtrigger:AddTrigger(0.5, OnHealthTrigger2)
        inst:ListenForEvent("attacked", OnAttacked)
        inst:ListenForEvent("onhitother", OnHitOther)
        inst:ListenForEvent("death", OnDeath)
        inst:ListenForEvent("onspell", OnSpell)
        inst:ListenForEvent("soldierschanged", onsoldierschanged)
        inst.components.lootdropper:SetChanceLootTable('ttk_qlch')
        inst:DoPeriodicTask(.5, UpdateDeerOffsets)
        inst.components.timer:StartTimer("spell_cd", 10)
        inst:SetBrain(brain)
        inst:AddComponent("ttk_boss_guaiwu_skills")
        inst.components.ttk_boss_guaiwu_skills.first = false
        inst.components.ttk_boss_guaiwu_skills.noskill =  true
        inst.components.ttk_boss_guaiwu_skills.by = 7
        inst.components.ttk_boss_guaiwu_skills.qx = 4
    end
    SetupSounds(inst)
    inst:SetStateGraph("SGttk_qlch")
    return inst
end
local function fn()
    return common_fn()
end
local function fsfn()
    return common_fn(true)
end
local function TexiaoPetFadeIn(inst,remove)
    if not remove then
        local fx = SpawnPrefab("ttk_boss_bigspawn_fx_medium_static_nosound")
        if fx ~= nil then
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end
    if remove then
        inst.progress = 0.3
        if inst.coltask then
            inst.coltask:Cancel()
        end
        inst.coltask = inst:DoPeriodicTask(0, function()
            inst.progress = math.max(0,inst.progress - 0.02)
            inst.AnimState:SetMultColour(1, 1, 1, inst.progress)
            if inst.progress  <= 0 then
                if inst.coltask then
                    inst.coltask:Cancel()
                end
                inst:Remove()
            end
        end)
    else
        inst.AnimState:SetMultColour(1, 1, 1, 0)
        inst.progress = 0
        if inst.coltask then
            inst.coltask:Cancel()
        end
        inst.coltask = inst:DoPeriodicTask(0, function()
            inst.progress = math.min(0.3,inst.progress + 0.02)
            inst.AnimState:SetMultColour(1, 1, 1, inst.progress)
            if inst.progress >= 0.3 then
                if inst.coltask then
                    inst.coltask:Cancel()
                    inst.coltask = nil
                end
            end
        end)
    end
end
local function waterowner(owner,size)
	local x, y, z = owner.Transform:GetWorldPosition()
	if TheWorld.Map:IsOceanAtPoint(x, 0, z) and owner.sg ~= nil and owner.sg:HasStateTag("moving")then
		SpawnPrefab("ocean_splash_"..(size or "med")..tostring(math.random(2))).Transform:SetPosition(x, 0, z)
	end
end
local function texiaofn(gem)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.DynamicShadow:SetSize(1.75, .75)
    inst.Transform:SetSixFaced()
    local s  = 1.65
    inst.Transform:SetScale(s, s, s)
    inst:SetPhysicsRadiusOverride(1.5)
	MakeGiantCharacterPhysics(inst, 1000, inst.physicsradiusoverride)
    inst.AnimState:SetBank(Boss.Art("deer"))
    inst.AnimState:SetBuild(Boss.Art("xd_qlch"))
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:UsePointFiltering(true)
    inst:SetPrefabNameOverride("ttk_qlch")
    RemovePhysicsColliders(inst)
    inst.AnimState:SetAddColour(128/255,255/255, 250/255, 1)
    inst:AddTag("fx")
    inst:AddTag("NOBLOCK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 2
    inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true }
    inst:AddComponent("knownlocations")
    inst.persists = false
    inst.PetFadeIn = TexiaoPetFadeIn
    inst:DoTaskInTime(8, function()
        inst:PetFadeIn(true)
    end)
    inst:AddComponent("colourtweener")
    inst:SetBrain(texiaobrain)
    inst:SetStateGraph("SGttk_qlch")
    SetupSounds(inst)
    inst.ttk_boss_water_task = inst:DoPeriodicTask(0.25, waterowner)
    return inst
end
return Prefab("ttk_qlch", fn, assets, prefabs),
    Prefab("ttk_boss_qlch_fs", fsfn, assets, prefabs),
    Prefab("ttk_boss_qlch_texiao", texiaofn, assets)
