local Common = require "util/eva_life_common"
local SkillDamage = require "util/eva_skill_damage"

local assets = {
    Asset("ANIM", "anim/forcefield.zip"),
    Asset("ANIM", "anim/eva_life_flower_circle.zip"),
    Asset("ANIM", "anim/eva_life_flower_projectile.zip"),
}

local function AddFxTags(inst)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
end

local function MakeForcefieldFx(name, scale, r, g, b, alpha)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        AddFxTags(inst)
        inst.AnimState:SetBank("forcefield")
        inst.AnimState:SetBuild("forcefield")
        inst.AnimState:PlayAnimation("open")
        inst.AnimState:PushAnimation("idle_loop", true)
        inst.AnimState:SetMultColour(r, g, b, alpha)
        inst.AnimState:SetLightOverride(0.65)
        inst.Transform:SetScale(scale, scale, scale)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst.persists = false
        return inst
    end
    return Prefab(name, fn, assets)
end

local function MakeFlowerFx(name, build, scale, alpha, ground, duration)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        AddFxTags(inst)
        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetMultColour(1, 1, 1, alpha)
        inst.AnimState:SetLightOverride(0.8)
        if ground then
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.AnimState:SetSortOrder(3)
        end
        inst.Transform:SetScale(scale, scale, scale)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst.persists = false
        if duration ~= nil then
            local started = GetTime()
            inst:DoPeriodicTask(0.05, function()
                local progress = math.min(1, (GetTime() - started) / duration)
                local size = scale * (1 + progress * 0.35)
                inst.Transform:SetScale(size, size, size)
                inst.AnimState:SetMultColour(1, 1, 1, alpha * (1 - progress))
            end)
            inst:DoTaskInTime(duration, inst.Remove)
        end
        return inst
    end
    return Prefab(name, fn, assets)
end

local PROJECTILE_SPEED = 20
local PROJECTILE_HIT_DISTANCE = 0.55
local PROJECTILE_LIFETIME = 1.5

local function projectile_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    inst.AnimState:SetBank("eva_life_flower_projectile")
    inst.AnimState:SetBuild("eva_life_flower_projectile")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0.95)
    inst.AnimState:SetLightOverride(0.85)
    inst.Transform:SetScale(0.7, 0.7, 0.7)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst.persists = false
    inst.owner = nil
    inst.target = nil
    inst.controller = nil
    inst.update_task = nil
    inst.timeout_task = nil

    local function RemoveProjectile()
        if inst:IsValid() then inst:Remove() end
    end

    local function Impact()
        local owner = inst.owner
        local target = inst.target
        if Common.IsValidTarget(owner, target, Common.PROJECTILE_RANGE) then
            SkillDamage.Apply(owner, target, Common.PROJECTILE_DAMAGE, "eva_life_projectile")
            local fx = SpawnPrefab("eva_life_hit_fx")
            if fx ~= nil then
                fx.Transform:SetPosition(target.Transform:GetWorldPosition())
            end
        end
        RemoveProjectile()
    end

    local function Update()
        local owner = inst.owner
        local target = inst.target
        if not Common.IsValidTarget(owner, target, Common.PROJECTILE_RANGE) then
            RemoveProjectile()
            return
        end
        local x, y, z = inst.Transform:GetWorldPosition()
        local tx, ty, tz = target.Transform:GetWorldPosition()
        local dx, dz = tx - x, tz - z
        local distance = math.sqrt(dx * dx + dz * dz)
        local step = PROJECTILE_SPEED * FRAMES
        if distance <= PROJECTILE_HIT_DISTANCE or step >= distance then
            inst.Transform:SetPosition(tx, ty, tz)
            Impact()
            return
        end
        inst.Transform:SetRotation(inst:GetAngleToPoint(tx, ty, tz))
        inst.Transform:SetPosition(x + dx / distance * step, y, z + dz / distance * step)
    end

    function inst:Launch(owner, target, controller)
        self.owner = owner
        self.target = target
        self.controller = controller
        self.Transform:SetPosition(owner.Transform:GetWorldPosition())
        self.update_task = self:DoPeriodicTask(FRAMES, Update, 0)
        self.timeout_task = self:DoTaskInTime(PROJECTILE_LIFETIME, RemoveProjectile)
    end

    inst.OnRemoveEntity = function()
        if inst.update_task ~= nil then inst.update_task:Cancel() end
        if inst.timeout_task ~= nil then inst.timeout_task:Cancel() end
        if inst.controller ~= nil then inst.controller:_OnProjectileRemoved(inst) end
        inst.owner = nil
        inst.target = nil
        inst.controller = nil
    end
    return inst
end

return Prefab("eva_life_projectile", projectile_fn, assets, {"eva_life_hit_fx"}),
    MakeFlowerFx("eva_life_aura_fx", "eva_life_flower_circle", 6, 0.2, true),
    MakeForcefieldFx("eva_life_shield_fx", 0.82, 0.9, 0.82, 1, 0.45),
    MakeFlowerFx("eva_life_hit_fx", "eva_life_flower_projectile", 0.9, 0.8, false, 0.4),
    MakeFlowerFx("eva_life_heal_fx", "eva_life_flower_projectile", 1.1, 0.65, false, 0.65)
