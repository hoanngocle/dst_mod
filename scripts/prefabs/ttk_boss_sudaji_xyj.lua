-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_sudaji_xyj.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_suduji_xyjfx.zip")),
	Asset("ATLAS", "images/inventoryimages/xd_sudaji_xyj.xml"),
    Asset("IMAGE", "images/inventoryimages/xd_sudaji_xyj.tex"),
}
local fxassets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_elec_charged_fx.zip")),
}
local prefabs = {
}
local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_elec_charged_fx"))
    inst.AnimState:SetBuild(Boss.Art("xd_elec_charged_fx"))
    inst.AnimState:PlayAnimation("discharged",true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetScale(0.4, 1, 0.4)
    inst.AnimState:SetFinalOffset(3)
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    return inst
end
local function fxfn1()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_suduji_xyjfx"))
    inst.AnimState:SetBuild(Boss.Art("xd_suduji_xyjfx"))
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetScale(2.7, 2.7, 2.7)
    inst.AnimState:SetFinalOffset(1)
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:ListenForEvent("animover",inst.Remove)
    inst:DoTaskInTime(1,inst.Remove)
    return inst
end
return 
    Prefab("ttk_boss_elec_charged_fx", fxfn, fxassets),
    Prefab("ttk_boss_suduji_xyjfx", fxfn1, fxassets)
