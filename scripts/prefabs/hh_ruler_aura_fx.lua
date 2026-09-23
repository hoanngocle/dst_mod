local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("aura_dark2")
    inst.AnimState:SetBuild("aura_dark2")
    inst.AnimState:PlayAnimation("blackflashtest", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    return inst
end

return Prefab("hh_ruler_aura_fx", fn)
