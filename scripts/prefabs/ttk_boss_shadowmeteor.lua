-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
require "regrowthutil"
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/meteor.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_meteor.zip")),
    Asset("ANIM", Boss.ArtPath("anim/warning_shadow.zip")),
    Asset("ANIM", Boss.ArtPath("anim/meteor_shadow.zip")),
    Asset("ANIM", Boss.ArtPath("anim/burntground.zip")),
}
local prefabs =
{
    "ttk_boss_meteorwarning",
}
local NON_SMASHABLE_TAGS = { "qlch","ttk_boss_sandblock","shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
local DENSITY = 0.1
local FIVERADIUS = CalculateFiveRadius(DENSITY)
local EXCLUDE_RADIUS = 3
local BOULDER_TAGS = {"boulder"}
local BOULDERSPAWNBLOCKER_TAGS = { "NOBLOCK", "FX" }
local function getpoints(inst,shadow)
    local delay = 0
    local pos = inst:GetPosition()
    for i = 1, 3 do
        inst:DoTaskInTime(delay, function()
            local points = {}
            local radius = 1
            for i = 1, 5 do
                local theta = 0
                local numPoints = 0.5 * PI * radius
                for p = 1, numPoints do
                    if not points[i] then
                        points[i] = {}
                    end
                    local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
                    local point = pos + offset
                    table.insert(points[i], point)
                    theta = theta - (2 * PI / numPoints)
                end
                radius = radius + 4
            end
            for k, v in pairs(points[i]) do
                SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end)
        delay = delay + 0.2
    end
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 12,{ "_combat", "_health"}, NON_SMASHABLE_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() and not v:IsInLimbo() and not (v.components.health and v.components.health:IsDead()) then
            if v.components.combat ~= nil then
                local attacker = shadow.caster and shadow.caster:IsValid() and shadow.caster or shadow
                if attacker and attacker.components.combat and attacker.components.combat:CanTarget(v) then
                    local damage = TUNING.XD_QLCH_YUNSHIDAMAGE2
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
    if inst.onhitfn then
        inst.onhitfn(inst)
        inst:Remove()
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    if not inst:IsOnValidGround() then
        local splash = SpawnPrefab("splash_ocean")
        if splash ~= nil then
            splash.Transform:SetPosition(x, y, z)
        end
    else
        local scorch = SpawnPrefab("ttk_boss_burntground")
        if scorch ~= nil then
            scorch.Transform:SetPosition(x, y, z)
            local scale = inst.size * 1.3
            scorch.Transform:SetScale(scale, scale, scale)
        end
        local launched = {}
        local ents = TheSim:FindEntities(x, y, z, inst.size * TUNING.METEOR_RADIUS,{ "_combat", "_health"}, NON_SMASHABLE_TAGS)
        for i, v in ipairs(ents) do
            if v:IsValid() and not v:IsInLimbo() then
                if v:IsValid() and not v:IsInLimbo() and not (v.components.health and v.components.health:IsDead()) then
                    local attacker = inst.caster and inst.caster:IsValid() and inst.caster or inst
                    if attacker and attacker.components.combat and attacker.components.combat:CanTarget(v) then
                        local damage = TUNING.XD_QLCH_YUNSHIDAMAGE1
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
                    end
                end
            end
        end
        inst:DoTaskInTime(0.3,function()
            local ent = FindEntity(inst, 3.5, nil, {"ttk_boss_sandblock"})
            if not (ent and ent:IsValid()) then
                local ents = TheSim:FindEntities(x,y,z, 14, {"player","_health","_combat"},{"playerghost"})
                if #ents > 0 then
                    for i_,v in ipairs(ents) do
                        if not (v.components.health and v.components.health:IsDead()) then
                            SpawnAt("groundpoundring_fx",v)
                            getpoints(v,inst)
                        end
                     end
                end
            else
                SpawnAt("ttk_boss_explode_small",ent)
                ent:Remove()
            end
            inst:Remove()
        end)
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
local function SetPeripheral(inst, peripheral)
    inst.peripheral = peripheral
end
local function SetSize(inst, sz, mod)
    if inst.autosizetask ~= nil then
        inst.autosizetask:Cancel()
        inst.autosizetask = nil
    end
    if inst.striketask ~= nil then
        return
    end
    if sizes[sz] == nil then
        sz = "small"
    end
    inst.size = sizes[sz]
    inst.warnshadow = SpawnPrefab("ttk_boss_meteorwarning")
    inst.Transform:SetScale(inst.size, inst.size, inst.size)
    inst.warnshadow.Transform:SetScale(inst.size, inst.size, inst.size)
    inst.striketask = inst:DoTaskInTime(warntime, dostrike)
    inst.warnshadow.entity:SetParent(inst.entity)
    inst.warnshadow:startfn(warntime, .33, 1)
end
local function AutoSize(inst)
    inst.autosizetask = nil
    inst:SetSize(inst.setsize or "medium")
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.Transform:SetTwoFaced()
    inst.AnimState:SetBank(Boss.Art("meteor"))
    inst.AnimState:SetBuild(Boss.Art("xd_meteor"))
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.Transform:SetRotation(math.random(360))
    inst.SetSize = SetSize
    inst.SetPeripheral = SetPeripheral
    inst.striketask = nil
    inst.autosizetask = inst:DoTaskInTime(0, AutoSize)
    inst.persists = false
    return inst
end
local shadowassets =
{
    Asset("ANIM", Boss.ArtPath("anim/meteor_shadow.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_meteor_shadow.zip")),
}
local function AlphaToFade(alpha)
    return math.floor(alpha * 63 + .5)
end
local function FadeToAlpha(fade)
    return fade / 63
end
local function CalculatePeriod(time, starttint, endtint)
    return time / math.max(1, AlphaToFade(endtint) - AlphaToFade(starttint))
end
local DEFAULT_START = .33
local DEFAULT_END = 1
local DEFAULT_DURATION = 1
local DEFAULT_PERIOD = CalculatePeriod(DEFAULT_DURATION, DEFAULT_START, DEFAULT_END)
local function PushAlpha(inst)
    local alpha = FadeToAlpha(inst._fade:value())
    inst.AnimState:OverrideMultColour(1, 1, 1, alpha)
end
local function UpdateFade(inst)
    if inst._fade:value() < inst._fadeend:value() then
        inst._fade:set_local(inst._fade:value() + 1)
        PushAlpha(inst)
    end
    if inst._fade:value() >= inst._fadeend:value() and inst._task ~= nil then
        inst._task:Cancel()
        inst._task = nil
    end
end
local function OnFadeDirty(inst)
    PushAlpha(inst)
    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoPeriodicTask(inst._period:value(), UpdateFade)
end
local function startshadow(inst, time, starttint, endtint)
    if time ~= DEFAULT_DURATION or starttint ~= DEFAULT_START or endtint ~= DEFAULT_END then
        inst._fade:set(AlphaToFade(starttint))
        inst._fadeend:set(AlphaToFade(endtint))
        inst._period:set(CalculatePeriod(time, starttint, endtint))
        OnFadeDirty(inst)
    end
end
local function PlayMeteorSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/meteor_spawn")
end
local function warningfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("warning_shadow"))
    inst.AnimState:SetBuild(Boss.Art("xd_meteor_shadow"))
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetFinalOffset(3)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst._fade = net_smallbyte(inst.GUID, "ttk_boss_meteorwarning._fade", "fadedirty")
    inst._fadeend = net_smallbyte(inst.GUID, "ttk_boss_meteorwarning._fadeend", "fadedirty")
    inst._period = net_float(inst.GUID, "ttk_boss_meteorwarning._period", "fadedirty")
    inst._fade:set(AlphaToFade(DEFAULT_START))
    inst._fadeend:set(AlphaToFade(DEFAULT_END))
    inst._period:set(DEFAULT_PERIOD)
    inst._task = nil
    OnFadeDirty(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)
        return inst
    end
    inst:DoTaskInTime(0, PlayMeteorSound)
    inst.startfn = startshadow
    inst.persists = false
    return inst
end
local FADE_INTERVAL = TUNING.TOTAL_DAY_TIME * 2 / 64
local function OnFadeDirty(inst)
    local alpha = (64 - inst._fade:value()) / 65
    inst.AnimState:OverrideMultColour(1, 1, 1, alpha)
end
local function UpdateFade(inst)
    if inst._fade:value() < 63 then
        inst._fade:set_local(inst._fade:value() + 1)
        OnFadeDirty(inst)
    elseif TheWorld.ismastersim then
        inst:Remove()
    else
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)
    end
end
local function OnSave(inst, data)
    data.fade = inst._fade:value() > 0 and inst._fade:value() or nil
    data.rotation = inst.Transform:GetRotation()
    data.scale = { inst.Transform:GetScale() }
end
local function OnLoad(inst, data)
    if data ~= nil then
        if data.rotation ~= nil then
            inst.Transform:SetRotation(data.rotation)
        end
        if data.scale ~= nil then
            inst.Transform:SetScale(data.scale[1] or 1, data.scale[2] or 2, data.scale[3] or 3)
        end
        if data.fade ~= nil and data.fade > 0 then
            inst._fade:set(math.min(data.fade, 63))
            OnFadeDirty(inst)
        end
    end
end
local function makeburntground(name, initial_fade)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.AnimState:SetBuild(Boss.Art("burntground"))
        inst.AnimState:SetBank(Boss.Art("burntground"))
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_GROUND)
        inst.AnimState:SetSortOrder(3)
        inst:AddTag("NOCLICK")
        inst:AddTag("FX")
        inst._fade = net_smallbyte(inst.GUID, "ttk_boss_burntground._fade", "fadedirty")
        inst:SetPrefabName("burntground")
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            inst:DoPeriodicTask(FADE_INTERVAL, UpdateFade, math.random())
            inst:ListenForEvent("fadedirty", OnFadeDirty)
            inst._fade:set_local(initial_fade or 0)
            OnFadeDirty(inst)
            return inst
        end
        inst:DoPeriodicTask(FADE_INTERVAL, UpdateFade, math.max(0, FADE_INTERVAL - math.random()))
        inst._fade:set(initial_fade or 0)
        OnFadeDirty(inst)
        inst.Transform:SetRotation(math.random() * 360)
        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        return inst
    end
    return Prefab(name, fn, assets)
end
return Prefab("ttk_boss_shadowmeteor", fn, assets, prefabs),
    Prefab("ttk_boss_meteorwarning", warningfn, shadowassets),
    makeburntground("ttk_boss_burntground")
