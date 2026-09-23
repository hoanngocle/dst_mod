-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets=
{
    Asset("ANIM", Boss.ArtPath("anim/cloak_fx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_vortex_fx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_vortex_fx_white.zip")),
}
local baihuassets = {
    Asset("ANIM", Boss.ArtPath("anim/xd_baidu_actions.zip")),
}
local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("cloakfx"))
    inst.AnimState:SetBuild(Boss.Art("xd_vortex_fx"))
    inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetMultColour(255/255, 176/255, 91/255, 1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    for i=1,14 do
        inst.AnimState:Hide("fx"..i)
    end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.AnimState:Show("fx"..math.random(1,14))
    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    inst:ListenForEvent("entitysleep", inst.Remove)
    return inst
end
local function spawnwisp(owner)
    if owner:IsValid() then
        local wisp = SpawnPrefab("ttk_boss_vortex_fx")
        if owner.colour then
            wisp.AnimState:SetBuild(Boss.Art("xd_vortex_fx_white"))
            wisp.AnimState:SetMultColour(unpack(owner.colour))
        end
        local x,y,z = owner.Transform:GetWorldPosition()
        wisp.Transform:SetPosition(x+math.random()*0.25 -0.25/2,y,z+math.random()*0.25 -0.25/2)
    end
end
local function spawnerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.faxtask = inst:DoPeriodicTask(0.2,spawnwisp)
    return inst
end
local TWEEN_TARGET = {255/255, 224/255, 133/255, 0}
local TWEEN_TIME = 1.2
local function doremove(inst,time)
    if not inst.doremove then
        inst.doremove = true
        if inst.isfgy then
            inst.SoundEmitter:PlaySound("xd_jfsnsound/xd_jfsnsound/jiao", nil, 0.3)
        end
        inst.components.colourtweener:StartTween(TWEEN_TARGET, time or TWEEN_TIME, inst.Remove)
    end
end
local function fenghuang()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    local s  = 1.30 *0.75
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetBank(Boss.Art("malbatross"))
    inst.AnimState:SetBuild(Boss.Art("xd_jfsn"))
    inst.AnimState:PlayAnimation("eatfish", true)
    inst.AnimState:SetFinalOffset(-2)
    inst.AnimState:SetAddColour(255/255, 224/255, 133/255, 1)
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.isfgy = true
    inst:AddComponent("colourtweener")
    inst:DoTaskInTime(0.6,doremove)
    inst.persists = false
    return inst
end
local function duanzui_baihu()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.footstep = "daywalker/action/step"
	inst.AnimState:SetBank(Boss.Art("daywalker"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihu"))
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:Hide("ARM_CARRY")
	inst.AnimState:SetSymbolLightOverride("ww_armlower_red", .6)
	inst.AnimState:SetSymbolLightOverride("flake", .6)
    inst.AnimState:UsePointFiltering(true)
    inst.AnimState:SetAddColour(255/255, 224/255, 133/255, 1)
    inst.AnimState:SetFinalOffset(-2)
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("colourtweener")
    inst:SetStateGraph("SGttk_boss_weapon_fx")
    inst:DoTaskInTime(0,function()
        inst.sg:GoToState("taunt")
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength()-1.2,doremove)
    end)
    inst.persists = false
    return inst
end
local function mojun()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	inst.AnimState:SetBank(Boss.Art("wilson"))
    inst.AnimState:SetBuild(Boss.Art("xd_ziyunboss"))
	inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:UsePointFiltering(true)
    inst.AnimState:Hide("HAT")
    inst.AnimState:Hide("HAIR_HAT")
    inst.AnimState:OverrideSymbol("swap_object","xd_ziyunboss_weapon", "swap")
    inst.AnimState:Hide("ARM_normal")
    inst.AnimState:SetMultColour(0, 0, 0, 0)
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("colourtweener")
    inst:SetStateGraph("SGttk_boss_weapon_fx")
    inst:DoTaskInTime(0,function()
        inst.sg:GoToState("castspell")
    end)
    inst.persists = false
    return inst
end
return Prefab( "ttk_boss_vortex_fx", fxfn, assets),
    Prefab( "ttk_boss_vortex_spawner", spawnerfn),
    Prefab( "ttk_boss_fgy_fx", fenghuang),
    Prefab( "ttk_boss_duanzui_baihu_fx", duanzui_baihu,baihuassets),
    Prefab( "ttk_boss_duanzui_mojun_fx", mojun)
