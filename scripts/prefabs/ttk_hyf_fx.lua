local assets = {
    Asset("ANIM", "anim/ttk_lunar_fx.zip"),
    Asset("ANIM", "anim/moonbase_fx.zip"),
}

local function MakeLunarFx(name, anim, final_offset, sound_volume)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        if sound_volume ~= nil then
            inst.entity:AddSoundEmitter()
        end
        inst.entity:AddNetwork()

        -- The copied archive intentionally keeps the source bank name.
        inst.AnimState:SetBank("xd_lunar_fx")
        inst.AnimState:SetBuild("moonbase_fx")
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(final_offset)
        inst.AnimState:SetMultColour(1, 238 / 255, 144 / 255, 1)
        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        if sound_volume ~= nil then
            inst:DoTaskInTime(0, function()
                if not inst.nosound then
                    inst.SoundEmitter:PlaySound(
                        "dontstarve/common/together/moonbase/beam_stop_fail",
                        nil,
                        inst.soundsize or sound_volume
                    )
                end
            end)
        end
        inst:ListenForEvent("animover", inst.Remove)
        return inst
    end
    return Prefab(name, fn, assets)
end

return MakeLunarFx("ttk_hyf_fullfx", "lunar_full_pst", 2),
    MakeLunarFx("ttk_hyf_frontfx", "lunar_front_pst", 3, 1),
    MakeLunarFx("ttk_hyf_frontfx_small", "lunar_front_pst", 3, 0.3)
