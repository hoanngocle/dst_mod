local AURA_SCALE = 1.75

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("aura_nhavua")
    inst.AnimState:SetBuild("aura_nhavua")
    inst.Transform:SetScale(AURA_SCALE, AURA_SCALE, AURA_SCALE)
    inst.AnimState:SetFinalOffset(-3)
    inst.AnimState:PlayAnimation("aura_nhavua", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    return inst
end

return Prefab("hh_king_aura_macanh_fx", fn)
