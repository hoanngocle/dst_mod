local assets = {
    Asset("ANIM", "anim/eva_wings.zip"),
}

local function CreateWingFrame(index)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.AnimState:SetBank("eva_moon_wings")
    inst.AnimState:SetBuild("eva_moon_wings")
    inst.AnimState:PlayAnimation("idle" .. index, true)
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    inst.AnimState:SetLightOverride(0.12)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(2)
    inst:AddComponent("highlightchild")
    inst.persists = false
    return inst
end

local function RemoveFrames(inst)
    for _, frame in ipairs(inst.frames or {}) do
        if frame:IsValid() then frame:Remove() end
    end
    inst.frames = nil
end

local function OnColourChanged(inst, r, g, b, a)
    for _, frame in ipairs(inst.frames or {}) do
        frame.AnimState:SetAddColour(r, g, b, a)
    end
end

local function SpawnFrames(inst, owner)
    RemoveFrames(inst)
    inst.frames = {}
    for index = 6, 10 do
        local frame = CreateWingFrame(index)
        frame.entity:SetParent(owner.entity)
        frame.Follower:FollowSymbol(
            owner.GUID, "swap_body_tall", index == 10 and -50 or 0, -70, 0, true, nil, index)
        frame.components.highlightchild:SetOwner(owner)
        inst.frames[#inst.frames + 1] = frame
    end
    inst.components.colouraddersync:SetColourChangedFn(OnColourChanged)
    inst.OnRemoveEntity = RemoveFrames
end

local function OnEntityReplicated(inst)
    local owner = inst.entity:GetParent()
    if owner ~= nil then SpawnFrames(inst, owner) end
end

local function AttachToOwner(inst, owner)
    inst.entity:SetParent(owner.entity)
    if owner.components.colouradder ~= nil then
        owner.components.colouradder:AttachChild(inst)
    end
    if not TheNet:IsDedicated() then SpawnFrames(inst, owner) end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddComponent("colouraddersync")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnEntityReplicated
        return inst
    end
    inst.AttachToOwner = AttachToOwner
    inst.persists = false
    return inst
end

return Prefab("eva_wings_fx", fn, assets)
