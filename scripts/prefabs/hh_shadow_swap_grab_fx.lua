local assets =
{
    Asset("ANIM", "anim/rne_grabbylarge.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("fx")

    inst.AnimState:SetBank("wanda_time_fx")
    inst.AnimState:SetBuild("rne_grabbylarge")
    inst.AnimState:PlayAnimation("younger_top")
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(10, inst.Remove)
    inst.persists = false

    return inst
end

return Prefab("hh_shadow_swap_grab_fx", fn, assets)
