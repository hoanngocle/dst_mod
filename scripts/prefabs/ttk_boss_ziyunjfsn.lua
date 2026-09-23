-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/malbatross_basic.zip")),
    Asset("ANIM", Boss.ArtPath("anim/malbatross_actions.zip")),
    Asset("ANIM", Boss.ArtPath("anim/malbatross_build.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_jfsn.zip")),
    Asset("ANIM", Boss.ArtPath("anim/meteor.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_jfsnmeteor.zip")),
    Asset("ANIM", Boss.ArtPath("anim/warning_shadow.zip")),
    Asset("ANIM", Boss.ArtPath("anim/meteor_shadow.zip")),
}
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    local s  = 1.30
    inst.Transform:SetScale(s, s, s)
    MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
    inst.AnimState:SetBank(Boss.Art("malbatross"))
    inst.AnimState:SetBuild(Boss.Art("xd_jfsn"))
    inst:AddTag("fx")
    inst.Transform:SetSixFaced()
    inst.AnimState:PlayAnimation("despawn")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 4
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true }
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(100)
    inst:SetStateGraph("SGttk_boss_ziyunjfsn")
    inst.persists = false
    return inst
end
local function doxd_fireringdamage(inst,pt,points)
    SpawnPrefab("firering_fx").Transform:SetPosition(pt:Get())
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab("firesplash_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end
end
local function onexplode(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/meteor_impact")
    if inst.warnshadow ~= nil then
        inst.warnshadow:Remove()
        inst.warnshadow = nil
    end
    local shakeduration = .7 * inst.size
    local shakespeed = .02 * inst.size
    local shakescale = .5 * inst.size
    local shakemaxdist = 40 * inst.size
    ShakeAllCameras(CAMERASHAKE.FULL, shakeduration, shakespeed, shakescale, inst, shakemaxdist)
    local pt = inst:GetPosition()
    if inst.owner and inst.owner:IsValid() then
        inst.owner:DoAoeAttck(pt,3.5,inst.damage)
    end
    local points = XD_GetGroundPoints(pt,3,1.5,1.5)
    local tauntfx = SpawnPrefab("tauntfire_fx")
    tauntfx.Transform:SetPosition(pt:Get())
    tauntfx.Transform:SetRotation(inst.Transform:GetRotation())
    inst:DoTaskInTime(2*FRAMES,function()
        doxd_fireringdamage(inst,pt,points)
        if inst.owner and inst.owner:IsValid() then
            inst.owner:DoAoeAttck(pt,8,inst.damage)
        end
    end)
    inst:DoTaskInTime(9*FRAMES,function()
        doxd_fireringdamage(inst,pt,points)
        if inst.owner and inst.owner:IsValid() then
            inst.owner:DoAoeAttck(pt,8,inst.damage)
        end
    end)
    inst:DoTaskInTime(12*FRAMES,function()
        doxd_fireringdamage(inst,pt,points)
        if inst.owner and inst.owner:IsValid() then
            inst.owner:DoAoeAttck(pt,8,inst.damage)
        end
    end)
    local jfsn = SpawnAt("ttk_boss_ziyunjfsn",inst)
    jfsn.owner = inst.owner
    if inst.iscanying then
        jfsn.AnimState:SetAddColour(250/255,250/255, 180/255, 1)
        jfsn.iscanying  = true
    end
    if inst.damage then
        jfsn.damage = inst.damage
        jfsn.components.combat:SetDefaultDamage(inst.damage)
    end
    if inst.firedamage then
        jfsn.firedamage = inst.firedamage
    end
end
local function dostrike(inst)
    inst.striketask = nil
    inst.AnimState:PlayAnimation("crash")
    inst:DoTaskInTime(0.33, onexplode)
    inst:DoTaskInTime(3, inst.Remove)
end
local warntime = 1
local sizes =
{
    small = .7,
    medium = 1,
    large = 1.3,
}
local function SetSize(inst, sz, mod)
    if inst.autosizetask ~= nil then
        inst.autosizetask:Cancel()
        inst.autosizetask = nil
    end
    if inst.striketask ~= nil then
        return
    end
    inst.size = sizes[sz]
    inst.warnshadow = SpawnPrefab("meteorwarning")
    inst.Transform:SetScale(inst.size, inst.size, inst.size)
    inst.warnshadow.Transform:SetScale(inst.size, inst.size, inst.size)
    inst.striketask = inst:DoTaskInTime(warntime, dostrike)
    inst.warnshadow.entity:SetParent(inst.entity)
    inst.warnshadow:startfn(warntime, .33, 1)
end
local function AutoSize(inst)
    inst.autosizetask = nil
    inst:SetSize("medium")
end
local function OnSpawnedBy(inst, stalker)
    if stalker then
        inst.owner = stalker
        inst.damage =  20
        inst.firedamage =  30
    end
end
local function meteorfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.Transform:SetTwoFaced()
    inst.AnimState:SetBank(Boss.Art("meteor"))
    inst.AnimState:SetBuild(Boss.Art("xd_jfsnmeteor"))
    inst:AddTag("NOCLICK")
    inst:SetPrefabNameOverride("ttk_jfsn")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.Transform:SetRotation(math.random(360))
    inst.SetSize = SetSize
    inst.striketask = nil
    inst.autosizetask = inst:DoTaskInTime(0, AutoSize)
    inst.OnSpawnedBy = OnSpawnedBy
    inst.persists = false
    return inst
end
local heats = { 30, 70, 120, 180, 220, 240 }
local function GetHeatFn(inst)
    return 220
end
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function dodamage(inst,damage)
    if  inst.owner and inst.owner:IsValid() and inst.owner.components.health and not inst.owner.components.health:IsDead() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents =  TheSim:FindEntities(x, y, z, 3, attacktag,noltags)
        for i, v in ipairs(ents) do
            if v and  v:IsValid() and (not v.ziyun_jfsndamagetime or (GetTime() - v.ziyun_jfsndamagetime) > 0.5) and not (v.components.health ~= nil and v.components.health:IsDead()) and XD_CanAttackTrget(inst.owner,v) then
                v.ziyun_jfsndamagetime = GetTime()
                local damage = inst.damage or 35
                damage = Xd_CalcDamage(inst.owner,damage,v)
                v.components.combat:GetAttacked(inst.owner,damage)
            end
        end
    end
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
local function firefn()
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
    inst.AnimState:PlayAnimation("level5", true)
    inst:AddTag("FX")
    inst:AddTag("HASHEATER")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn
    inst.damage_task = inst:DoPeriodicTask(0.5,dodamage,0.2)
    inst.removetask = inst:DoTaskInTime(3.1,doremove)
    inst.persists = false
    return inst
end
return Prefab("ttk_boss_ziyunjfsn", fn, assets),
    Prefab("ttk_boss_ziyunjfsn_meteor", meteorfn, assets),
    Prefab("ttk_boss_ziyunjfsn_fire", firefn, assets)
