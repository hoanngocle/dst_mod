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
    Asset("ANIM", Boss.ArtPath("anim/xd_sudaji_fox.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sudaji_flyout.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sudaji_flyin.zip")),
    Asset("ANIM", Boss.ArtPath("anim/lavaarena_creature_teleport.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sudaji_shanjifx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sudaji_lungehitfx.zip")),
}
local function infn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_sudaji_flyin"))
    inst.AnimState:SetBuild(Boss.Art("xd_sudaji_flyin"))
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetTwoFaced()
    inst.SoundEmitter:PlaySound("xd_sudaji_sound/xd_sudaji_sound/fly",nil,0.3)
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:ListenForEvent("ainmover",inst.Remove)
    inst:DoTaskInTime(1.5,inst.Remove)
    return inst
end
local function outfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_sudaji_flyout"))
    inst.AnimState:SetBuild(Boss.Art("xd_sudaji_flyout"))
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:ListenForEvent("ainmover",inst.Remove)
    inst:DoTaskInTime(1.5,inst.Remove)
    return inst
end
local s  = 0.8
local TWEEN_TARGET = {1, 1, 1, 0}
local TWEEN_TIME = 0.145
local function dodespawn(inst)
    if not inst.doremove then
        inst.doremove = true
        if inst.components.container then
            inst.components.container:Close()
            inst.components.container.canbeopened = false
        end
        inst.components.colourtweener:StartTween(TWEEN_TARGET, TWEEN_TIME, inst.Remove)
    end
end
local function foxinfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_sudaji_fox"))
    inst.AnimState:SetBuild(Boss.Art("xd_sudaji_fox"))
    inst.AnimState:SetMultColour(1, 1, 1, .4)
    inst.AnimState:SetScale(s, s, s)
    inst.Transform:SetTwoFaced()
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:AddComponent("colourtweener")
    inst.Start = function(inst)
        inst:DoTaskInTime(0,function()
            inst.AnimState:PlayAnimation("in")
        end)
    end
    inst:DoTaskInTime(1.5,inst.Remove)
    inst:DoTaskInTime(0.15,dodespawn)
    return inst
end
local function foxoutfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_sudaji_fox"))
    inst.AnimState:SetBuild(Boss.Art("xd_sudaji_fox"))
    inst.AnimState:SetMultColour(1, 1, 1, .4)
    inst.AnimState:SetScale(s, s, s)
    inst.Transform:SetTwoFaced()
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:DoTaskInTime(1.5,inst.Remove)
    inst:DoTaskInTime(0.15,dodespawn)
    inst.Start = function(inst)
        inst.AnimState:PlayAnimation("out")
    end
    inst:AddComponent("colourtweener")
    return inst
end
local function preparefxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("lavaarena_creature_teleport"))
    inst.AnimState:SetBuild(Boss.Art("lavaarena_creature_teleport"))
    inst.AnimState:PlayAnimation("spawn_medium")
    inst.AnimState:HideSymbol("blast")
    inst.AnimState:HideSymbol("smoke1")
    inst.AnimState:HideSymbol("smoke3")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetMultColour(255/255,200/255,54/255,1)
    inst.SoundEmitter:PlaySound("xd_sudaji_sound/xd_sudaji_sound/lighting",nil,0.7)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:ListenForEvent("animover",inst.Remove)
    inst:DoTaskInTime(1.5,inst.Remove)
    inst:DoTaskInTime(0.2,function()
    end)
    return inst
end
local function lungefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.Transform:SetEightFaced()
    inst.AnimState:SetBank(Boss.Art("xd_sudaji_shanjifx"))
    inst.AnimState:SetBuild(Boss.Art("xd_sudaji_shanjifx"))
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(1)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    local scale = 1.3
    inst.Transform:SetScale(scale, scale, scale)
    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    inst:AddComponent("colourtweener")
    inst:DoTaskInTime(0.96,function()
        inst.components.colourtweener:StartTween(TWEEN_TARGET, inst.AnimState:GetCurrentAnimationLength()-0.96, inst.Remove)
    end)
    return inst
end
local function dohitdamage(inst)
    if inst.owner and inst.owner:IsValid() then
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = XD_GetDamageTargets(x,y,z, 4)
        for i,v in pairs(ents) do
            if  v:IsValid() and  XD_CanAttackTrget(inst.owner,v) then
                local damage = inst.damage or (inst.owner.sudaji_damage and inst.owner.sudaji_damage[2] and inst.owner.sudaji_damage[2][2]) or 56.4
                damage = Xd_CalcDamage(inst.owner,damage,v)
                inst.owner.skillattack = true
                v.components.combat:GetAttacked(inst.owner,damage)
                inst.owner.skillattack = false
                inst.owner:PushEvent("onareaattackother", { target = v})
            end
        end
    end
end
local function lungehitfx()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_sudaji_lungehitfx"))
    inst.AnimState:SetBuild(Boss.Art("xd_sudaji_lungehitfx"))
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(3)
    inst.SoundEmitter:PlaySound("meta3/wigfrid/spear_lighting_lunge_thunder")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:ListenForEvent("animover",inst.Remove)
    inst:DoTaskInTime(1.5,inst.Remove)
    inst:DoTaskInTime(0.18,dohitdamage)
    inst:DoTaskInTime(0.46,dohitdamage)
    inst:DoTaskInTime(0.64,dohitdamage)
    return inst
end
return Prefab("ttk_boss_sudaji_flyin", infn,assets),
    Prefab("ttk_boss_sudaji_flyout", outfn,assets),
    Prefab("ttk_boss_sudaji_foxin", foxinfn,assets),
    Prefab("ttk_boss_sudaji_foxout", foxoutfn,assets),
    Prefab("ttk_boss_sudaji_hitfx", preparefxfn,assets),
    Prefab("ttk_boss_sudaji_lungefx", lungefn,assets),
    Prefab("ttk_boss_sudaji_lungehitfx", lungehitfx,assets)
