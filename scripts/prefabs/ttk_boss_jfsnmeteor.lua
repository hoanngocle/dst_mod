-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
require "regrowthutil"
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/meteor.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_jfsnmeteor.zip")),
    Asset("ANIM", Boss.ArtPath("anim/warning_shadow.zip")),
    Asset("ANIM", Boss.ArtPath("anim/meteor_shadow.zip")),
}
local prefabs =
{
    "meteorwarning",
    "splash_ocean",
}
local function doxd_fireringdamage(inst,pt,points,ignite,damage,range)
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
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z,range or 8,{"_health","_combat"},{ "FX", "NOCLICK", "DECOR", "INLIMBO","avoid_jfsnfire" })
    for k,v in pairs(ents) do
        if v.components.health ~= nil and not v.components.health:IsDead() then
            local attacker = inst.owner and inst.owner:IsValid() and inst.owner or inst
            if attacker and attacker.components.combat and attacker.components.combat:CanTarget(v) then
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
                if ignite and not (v.components.health and v.components.health:IsDead()) and v.components.burnable then
                    if not v.components.burnable:IsBurning() and (v.components.burnable.canlight or v.components.combat ~= nil) then
                        v.components.burnable:Ignite(true, attacker)
                    end
                end
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
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z,3.5,{"_health","_combat"},{ "FX", "NOCLICK", "DECOR", "INLIMBO","avoid_jfsndamage"})
    for k,v in pairs(ents) do
        if v.components.health ~= nil and not v.components.health:IsDead() and inst.components.combat:CanTarget(v) then
            if inst.owner ~= nil and inst.owner:IsValid() then
                inst.owner.components.combat.ignorehitrange = true
                inst.owner.components.combat:DoAttack(v)
                inst.owner.components.combat.ignorehitrange = false
            else
                inst.components.combat:DoAttack(v)
            end
        end
    end
    local points = XD_GetGroundPoints(pt,3,1.5,1.5)
    local tauntfx = SpawnPrefab("tauntfire_fx")
    tauntfx.Transform:SetPosition(pt:Get())
    tauntfx.Transform:SetRotation(inst.Transform:GetRotation())
    inst:DoTaskInTime(2*FRAMES,function()
        doxd_fireringdamage(inst,pt,points,false,TUNING.XD_JFSN_YUNSHIDAMAGE1)
    end)
    inst:DoTaskInTime(9*FRAMES,function()
        doxd_fireringdamage(inst,pt,points,false,TUNING.XD_JFSN_YUNSHIDAMAGE1)
    end)
    inst:DoTaskInTime(12*FRAMES,function()
        doxd_fireringdamage(inst,pt,points,false,TUNING.XD_JFSN_YUNSHIDAMAGE1)
    end)
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
local function KeepTargetFn()
    return false
end
local function AutoSize(inst)
    inst.autosizetask = nil
    inst:SetSize("medium")
end
local function fn()
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
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(150)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.autosizetask = inst:DoTaskInTime(0, AutoSize)
    inst.persists = false
    return inst
end
return Prefab("ttk_boss_jfsnmeteor", fn, assets, prefabs)
