require "prefabutil"

local function on_remove_wall(inst)
    if inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function on_add_wall(inst)
    if inst:IsValid() then
        if inst._pfpos == nil then
            inst._pfpos = inst:GetPosition()
            TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
        end
    elseif inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst:AddTag("blocker")
    inst:AddTag("NOBLOCK")
    inst:AddTag("birdblocker")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0)
    phys:SetCollisionGroup(COLLISION.WORLD)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:SetCapsule(0.5, 50)
    -- Keep the physical wall alive while the arena is sleeping.  The
    -- Pathfinder wall is registered separately on the next tick, so letting
    -- physics remove this entity would leave a collision/pathing mismatch
    -- when the arena wakes up again.
    phys:SetDontRemoveOnSleep(true)
    
    inst.AnimState:SetBank("wall")
    inst.AnimState:SetBuild("wall_ruins_2")
    inst.AnimState:PlayAnimation("half")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:DoTaskInTime(0, on_add_wall)
    inst:ListenForEvent("onremove", on_remove_wall)

    inst.persists = true

    return inst
end

return Prefab("dungeon_wall_ruins", fn, {Asset("ANIM", "anim/wall.zip"), Asset("ANIM", "anim/wall_ruins_2.zip")})
