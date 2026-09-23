local assets = {
    Asset("ANIM", "anim/monkey_island_portal1.zip"),
    Asset("ANIM", "anim/monkey_island_portal2.zip"),
    Asset("ANIM", "anim/monkey_island_portal3.zip"),
    Asset("ANIM", "anim/monkey_island_portal_fx.zip"),
}

local prefabs = {
    "rock_flintless",
}

local function OnStateChanged(inst, data)
    if not data then return end
    if data.state == "COOLDOWN" then
        inst.AnimState:SetBank("monkey_island_porta3")
        inst.AnimState:SetBuild("monkey_island_porta3")
        inst.AnimState:PlayAnimation("out_idle", true)
    elseif data.state == "READY" or data.state == "IN_PROGRESS" then
        if data.stages and data.stages >= 6 then
            inst.AnimState:SetBank("monkey_island_porta2")
            inst.AnimState:SetBuild("monkey_island_porta2")
            inst.AnimState:PlayAnimation("out_idle", true)
        else
            inst.AnimState:SetBank("monkey_island_porta1")
            inst.AnimState:SetBuild("monkey_island_porta1")
            inst.AnimState:PlayAnimation("out_idle", true)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("monkey_island_porta1")
    inst.AnimState:SetBuild("monkey_island_porta1")
    inst.AnimState:PlayAnimation("out_idle", true)
    
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    
    inst:AddTag("dungeon_exit")

    inst.name = "Lối thoát Hầm Ngục"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:ListenForEvent("dungeon_state_changed", function(world, data)
        OnStateChanged(inst, data)
    end, TheWorld)

    MakeHauntable(inst)

    return inst
end

return Prefab("dungeon_exit", fn, assets, prefabs)

