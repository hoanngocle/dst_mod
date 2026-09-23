local assets_scorched = {
    Asset("ANIM", "anim/scorched_skeletons.zip"),
}

local assets_normal = {
    Asset("ANIM", "anim/skeletons.zip"),
}

local function common_decor_fn(bank, build, anim_min, anim_max)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("decor")

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    
    local animnum = math.random(anim_min, anim_max)
    inst.AnimState:PlayAnimation("idle"..tostring(animnum))

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = true

    inst.animnum = animnum
    inst.OnSave = function(inst, data)
        data.animnum = inst.animnum
    end
    inst.OnLoad = function(inst, data)
        if data ~= nil and data.animnum ~= nil then
            inst.animnum = data.animnum
            inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))
        end
    end

    return inst
end

local function scorched()
    return common_decor_fn("skeleton", "scorched_skeletons", 1, 6)
end

local function pig()
    return common_decor_fn("skeleton", "skeletons", 7, 7)
end

local function merm()
    return common_decor_fn("skeleton", "skeletons", 8, 8)
end

return Prefab("hh_decor_scorched_skeleton", scorched, assets_scorched),
       Prefab("hh_decor_skeleton_pig", pig, assets_normal),
       Prefab("hh_decor_skeleton_merm", merm, assets_normal)
