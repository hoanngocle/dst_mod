-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
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
local function isplayerorpet(target)
    return target:HasTag("player") or
    target.owner and target.owner:HasTag("player") or
    target.components.follower and target.components.follower.leader and target.components.follower.leader:HasTag("player")
end
local function invalidtarget(inst,target)
    return target and target:IsValid() and target.components.health and not target.components.health:IsDead()
    and target.components.combat and isplayerorpet(target)
end
local noltags =  {"INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost","ttk_boss_guaiwu"}
local function doaoe(inst,pos)
    pos = pos or inst:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 3.5, {"_combat","_health"},noltags)
    for _,v in ipairs(ents) do
        if v ~= nil and invalidtarget(inst,v) then
            if inst.ismg then
                local spdamage = {ttk_boss_consciousnessdamage = 80}
                v.components.combat:GetAttacked(inst,800,nil,nil,spdamage)
            else
                local spdamage = {ttk_boss_consciousnessdamage = 4}
                v.components.combat:GetAttacked(inst,28,nil,nil,spdamage)
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
    if inst.istqmeteor then
        doaoe(inst,inst:GetPosition())
    elseif inst.damagefn and inst.owner and inst.owner:IsValid() then
        inst.damagefn(inst:GetPosition())
    end
end
local function dostrike(inst)
    inst.striketask = nil
    inst.AnimState:PlayAnimation("crash")
    inst:DoTaskInTime(0.33, onexplode)
    inst:ListenForEvent("animover", inst.Remove)
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
    inst.AnimState:SetBuild(Boss.Art("meteor"))
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.Transform:SetRotation(math.random(360))
    inst.SetSize = SetSize
    inst.striketask = nil
    inst.autosizetask = inst:DoTaskInTime(0, AutoSize)
    inst.persists = false
    return inst
end
return Prefab("ttk_boss_stmeteor", fn, assets, prefabs)
