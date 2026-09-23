-- Cosmetic LLT shelf spirit, adapted from xd_qlch_texiao; no boss logic.
local assets = {
    Asset("ANIM", "anim/deer_basic.zip"),
    Asset("ANIM", "anim/deer_action.zip"),
    Asset("ANIM", "anim/ttk_skin_spirit.zip"),
}
local function Fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(1.65, 1.65, 1.65)
    inst.DynamicShadow:SetSize(1.75, .75)
    MakeGhostPhysics(inst, 1, .5)
    inst.AnimState:SetBank("deer")
    inst.AnimState:SetBuild("xd_qlch")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:UsePointFiltering(true)
    inst.AnimState:SetAddColour(128 / 255, 1, 250 / 255, 1)
    inst.AnimState:SetMultColour(1, 1, 1, 0)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("notarget")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 2
    inst:AddComponent("knownlocations")
    inst:AddComponent("colourtweener")
    inst.components.colourtweener:StartTween({1, 1, 1, .3}, .5)
    inst:DoTaskInTime(8, function()
        inst.components.colourtweener:StartTween({1, 1, 1, 0}, .5, inst.Remove)
    end)
    inst:SetBrain(require("brains/ttk_skin_spiritbrain"))
    inst:SetStateGraph("SGttk_skin_spirit")
    return inst
end
return Prefab("ttk_skin_spirit", Fn, assets)
