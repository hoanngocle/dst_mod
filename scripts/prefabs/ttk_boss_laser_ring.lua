-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_laser_ring_fx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_gongdeshadow_fx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_laser_explosion.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_qy_explosion.zip")),
}
local prefabs =
{
}
local function Scorch_OnUpdateFade(inst)
    inst.alpha = math.max(0, inst.alpha - (1/90) )
    inst.AnimState:SetMultColour(1, 1, 1,  inst.alpha)
    if inst.alpha == 0 then
        inst:Remove()
    end
end
local function scorchfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBuild(Boss.Art("xd_laser_ring_fx"))
    inst.AnimState:SetBank(Boss.Art("xd_laser_ring_fx"))
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst.Transform:SetScale(0.85,0.85,0.85)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.alpha = 1
    inst:DoTaskInTime(0.7,function()
        inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    end)
    inst.Transform:SetRotation(math.random() * 360)
    return inst
end
local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBuild(Boss.Art("xd_gongdeshadow_fx"))
    inst.AnimState:SetBank(Boss.Art("xd_laser_ring_fx"))
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst.Transform:SetScale(1.25,1.25,1.25)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.alpha = 1
    inst:DoTaskInTime(0.7,function()
        inst:DoPeriodicTask(0, Scorch_OnUpdateFade)
    end)
    inst.Transform:SetRotation(math.random() * 360)
    return inst
end
local function explosionfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBuild(Boss.Art("xd_laser_explosion"))
    inst.AnimState:SetBank(Boss.Art("xd_laser_explosion"))
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst.Transform:SetScale(0.85,0.85,0.85)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)
	inst:ListenForEvent("entitysleep", inst.Remove)
    return inst
end
local function qy_explosionfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBuild(Boss.Art("xd_laser_explosion"))
    inst.AnimState:SetBank(Boss.Art("xd_qy_explosion"))
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    local s = 1.42
    inst.Transform:SetScale(s,s,s)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)
	inst:ListenForEvent("entitysleep", inst.Remove)
    return inst
end
return Prefab("ttk_boss_laser_ring", scorchfn, assets, prefabs),
        Prefab("ttk_boss_gongdeshadow_fx", fxfn, assets, prefabs),
       Prefab("ttk_boss_laser_explosion", explosionfn, assets, prefabs),
       Prefab("ttk_boss_qy_explosion", qy_explosionfn, assets, prefabs)
