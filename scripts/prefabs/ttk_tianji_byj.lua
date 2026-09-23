local assets = {
    Asset("ANIM", "anim/rocky.zip"),
    Asset("ANIM", "anim/ttk_futu.zip"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.DynamicShadow:SetSize(3.5, 1.5)
    inst.AnimState:SetBank("rocky")
    inst.AnimState:SetBuild("xd_futu")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.Transform:SetScale(1.52, 1.52, 1.52)
    inst.AnimState:SetAddColour(250/255, 250/255, 180/255, .3)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("ttk_tianjiwu_baihufx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    inst:AddComponent("colourtweener")
    inst.AnimState:SetMultColour(1, 1, 1, 0)
    inst.components.colourtweener:StartTween({1, 1, 1, 1}, .5)
    inst:DoPeriodicTask(.25, function(pet)
        local home = pet._ttk_home
        if home == nil or not home:IsValid() then pet:Remove(); return end
        if pet._ttk_origin == nil then pet._ttk_origin = pet:GetPosition() end
        local angle = GetTime() * .7
        pet.Transform:SetPosition(pet._ttk_origin.x + math.cos(angle) * .8, pet._ttk_origin.y + .1,
            pet._ttk_origin.z + math.sin(angle) * .8)
    end)
    inst:DoTaskInTime(7.5, function(pet)
        if pet:IsValid() then
            pet.components.colourtweener:StartTween({1, 1, 1, 0}, .5, function()
                if pet:IsValid() then pet:Remove() end
            end)
        end
    end)
    return inst
end

return Prefab("ttk_tianjiwu_baihufx", fn, assets)
