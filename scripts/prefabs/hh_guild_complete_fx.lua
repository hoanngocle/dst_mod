local assets = {
    Asset("ANIM", "anim/seffc.zip"),
    Asset("SOUNDPACKAGE", "sound/seffcsound.fev"),
    Asset("SOUND", "sound/seffcsound.fsb"),
}

local function AnimateLight(inst, from_radius, to_radius, steps, duration)
    for step = 1, steps do
        inst:DoTaskInTime(duration * step / steps, function()
            if inst:IsValid() then
                inst.Light:SetRadius(from_radius + (to_radius - from_radius) * step / steps)
            end
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")

    inst.AnimState:SetBank("seffc")
    inst.AnimState:SetBuild("seffc")
    inst.AnimState:PlayAnimation("anim")

    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(0)
    inst.Light:SetColour(1, 1, 1)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    AnimateLight(inst, 0, 2, 25, .125)
    inst:DoTaskInTime(1.5, function()
        if inst:IsValid() then
            AnimateLight(inst, 2, 0, 25, .5)
        end
    end)
    inst.SoundEmitter:PlaySound("dontstarve/common/shrine/sadwork_fire")
    inst:DoTaskInTime(26 / 30, function()
        if inst:IsValid() then
            inst.SoundEmitter:PlaySound("dontstarve/common/shrine/sadwork_explo")
        end
    end)
    inst:DoTaskInTime(2.1, inst.Remove)

    return inst
end

return Prefab("hh_guild_complete_fx", fn, assets)
