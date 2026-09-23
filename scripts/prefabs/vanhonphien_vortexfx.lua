-- Original banner's wisps, isolated from unrelated Tu Tien effects.
local assets = {
    Asset("ANIM", "anim/cloak_fx.zip"),
    Asset("ANIM", "anim/vanhonphien_vortexfx.zip"),
}

local function WispFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("cloakfx")
    inst.AnimState:SetBuild("xd_vortex_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetMultColour(0, 0, 0, 1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    for i = 1, 14 do
        inst.AnimState:Hide("fx" .. i)
    end
    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.AnimState:Show("fx" .. math.random(1, 14))
    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    inst:ListenForEvent("entitysleep", inst.Remove)
    inst:DoTaskInTime(3, inst.Remove)
    return inst
end

local function SpawnWisp(inst)
    if inst.weapon == nil or not inst.weapon:IsValid() or inst.weapon:IsAsleep() then
        return
    end
    local wisp = SpawnPrefab("vanhonphien_vortexfx")
    if wisp ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        wisp.Transform:SetPosition(x + math.random() * .25 - .125, y + 1, z + math.random() * .25 - .125)
    end
end

local function SpawnerFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("FX")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst.persists = false
    -- Server-local controller; only the spawned wisps are networked.
    if TheWorld.ismastersim then
        inst:DoPeriodicTask(.2, SpawnWisp)
    end
    return inst
end

return Prefab("vanhonphien_vortexfx", WispFn, assets),
    Prefab("vanhonphien_vortexspawner", SpawnerFn, nil, { "vanhonphien_vortexfx" })
