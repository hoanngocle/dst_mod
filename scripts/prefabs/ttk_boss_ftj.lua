-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local function SetFxOwner(inst, owner)
    if owner ~= nil then
        inst.blade1.entity:SetParent(owner.entity)
        inst.blade2.entity:SetParent(owner.entity)
        inst.blade1.Follower:FollowSymbol(owner.GUID, "swap_fb_object", nil, nil, nil, true, nil, 0, 3)
        inst.blade2.Follower:FollowSymbol(owner.GUID, "swap_fb_object", nil, nil, nil, true, nil, 5, 8)
        inst.blade1.components.highlightchild:SetOwner(owner)
        inst.blade2.components.highlightchild:SetOwner(owner)
    else
        inst.blade1.entity:SetParent(inst.entity)
        inst.blade2.entity:SetParent(inst.entity)
        inst.blade1.Follower:FollowSymbol(inst.GUID, "swap_spear", nil, nil, nil, true, nil, 0, 3)
        inst.blade2.Follower:FollowSymbol(inst.GUID, "swap_spear", nil, nil, nil, true, nil, 5, 8)
        inst.blade1.components.highlightchild:SetOwner(inst)
        inst.blade2.components.highlightchild:SetOwner(inst)
    end
end
local function PushIdleLoop(inst)
    inst.AnimState:PushAnimation("idle")
end
local function OnStopFloating(inst)
    inst.blade1.AnimState:SetFrame(0)
    inst.blade2.AnimState:SetFrame(0)
    inst:DoTaskInTime(0, PushIdleLoop)
end
local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()
	inst.AnimState:SetBank(Boss.Art("xd_ftj"))
    inst.AnimState:SetBuild(Boss.Art("xd_ftj"))
    inst.AnimState:PlayAnimation("swap",true)
    inst:AddTag("FX")
    inst:AddComponent("highlightchild")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    return inst
end
local assets = {
    Asset("ANIM", Boss.ArtPath("anim/xd_ftj.zip")),
    Asset("ATLAS", "images/inventoryimages/xd_ftj.xml")
}
local function explodefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank(Boss.Art("explode"))
    inst.AnimState:SetBuild(Boss.Art("explode"))
    inst.AnimState:PlayAnimation("small")
    inst:AddTag("fx")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false
    inst:DoTaskInTime(2, inst.Remove)
    return inst
end
return 
    Prefab("ttk_boss_ftj_fx", fxfn),
    Prefab("ttk_boss_ftj_explodefx", explodefn)
