local METEOR_DAMAGE = 1000
local WORK_DAMAGE = 20

local METEOR_ASSETS = {
    Asset("ANIM", "anim/hh_purple_lavaarena_firestaff_meteor.zip"),
}

local FIRE_FX_ASSETS = {
    Asset("ANIM", "anim/hh_purple_lavaarena_fire_fx.zip"),
}

local FIREPUFF_ASSETS = {
    Asset("ANIM", "anim/hh_purple_halloween_embers.zip"),
}

local METEOR_PREFABS = {
    "hh_daogam_fire_splash",
    "hh_daogam_fire_base",
    "burntground",
    "boards",
}

local function FireSplashFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_fire_fx")
    inst.AnimState:SetBuild("hh_purple_lavaarena_fire_fx")
    inst.AnimState:PlayAnimation("firestaff_ult")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    return inst
end

local function FireBaseFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_fire_fx")
    inst.AnimState:SetBuild("hh_purple_lavaarena_fire_fx")
    inst.AnimState:PlayAnimation("firestaff_ult_projection")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    return inst
end

local function MakeFirePuffFn(anim)
    return function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("halloween_embers")
        inst.AnimState:SetBuild("hh_purple_halloween_embers")
        inst.AnimState:PlayAnimation(anim)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetFinalOffset(3)
        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
        inst:ListenForEvent("animover", inst.Remove)
        return inst
    end
end

local function AddBurnableFuel(target)
    local boards = SpawnPrefab("boards")
    if boards == nil then
        return
    end
    if boards.components.fuel ~= nil and boards.components.fuel.fueltype == FUELTYPE.BURNABLE then
        target.components.fueled:TakeFuelItem(boards)
    else
        boards:Remove()
    end
end

local function OnMeteorImpact(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local splash = SpawnPrefab("hh_daogam_fire_splash")
    if splash ~= nil then
        splash.Transform:SetPosition(x, y, z)
        splash.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/meteor_strike")
    end
    local base = SpawnPrefab("hh_daogam_fire_base")
    if base ~= nil then
        base.Transform:SetPosition(x, y, z)
    end
    local burntground = SpawnPrefab("burntground")
    if burntground ~= nil then
        burntground.Transform:SetPosition(x, y, z)
    end
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)

    local author = inst.author
    local added_controlled_burner = author ~= nil and not author:HasTag("controlled_burner")
    if added_controlled_burner then
        author:AddTag("controlled_burner")
    end

    for _, target in pairs(TheSim:FindEntities(
        x,
        y,
        z,
        TUNING.WW_INFERNALSTAFF.SPELL_RADIUS,
        {},
        TUNING.WW_INFERNALSTAFF.SPELL_NOTAGS
    )) do
        if target:IsValid() then
            if target.components.workable ~= nil
                and TUNING.WW_INFERNALSTAFF.SPELL_WORK_ACTIONS[target.components.workable:GetWorkAction()] then
                target.components.workable:WorkedBy(inst, WORK_DAMAGE)
            end

            if target:IsValid() and target.components.combat ~= nil then
                target.components.combat:GetAttacked(inst, METEOR_DAMAGE)
                if target:IsValid() and target.components.burnable ~= nil then
                    if target.components.fueled == nil
                        or (target.components.fueled.fueltype ~= FUELTYPE.BURNABLE
                            and target.components.fueled.secondaryfueltype ~= FUELTYPE.BURNABLE) then
                        if target.components.burnable.canlight or target.components.combat ~= nil then
                            target.components.burnable:Ignite(true, author)
                        end
                    elseif target.components.fueled.accepting then
                        AddBurnableFuel(target)
                    end
                end
            end
        end
    end

    if added_controlled_burner and author:IsValid() then
        author:RemoveTag("controlled_burner")
    end
    inst:Remove()
end

local function FireMeteorFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("lavaarena_firestaff_meteor")
    inst.AnimState:SetBuild("hh_purple_lavaarena_firestaff_meteor")
    inst.AnimState:PlayAnimation("crash")
    inst.AnimState:PushAnimation("crash_pst", false)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", OnMeteorImpact)
    return inst
end

return Prefab("hh_daogam_fire_meteor", FireMeteorFn, METEOR_ASSETS, METEOR_PREFABS),
    Prefab("hh_daogam_fire_splash", FireSplashFn, FIRE_FX_ASSETS),
    Prefab("hh_daogam_fire_base", FireBaseFn, FIRE_FX_ASSETS),
    Prefab("hh_daogam_firepuff_1", MakeFirePuffFn("puff_1"), FIREPUFF_ASSETS),
    Prefab("hh_daogam_firepuff_2", MakeFirePuffFn("puff_2"), FIREPUFF_ASSETS),
    Prefab("hh_daogam_firepuff_3", MakeFirePuffFn("puff_3"), FIREPUFF_ASSETS)
