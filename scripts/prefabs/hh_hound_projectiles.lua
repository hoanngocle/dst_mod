-- Bóc tách đạn và sấm sét của Sói Hầm Ngục để hoạt động độc lập (không phụ thuộc mod Uncom)

local glacial_assets = {
    Asset("ANIM", "anim/glacial_hound_projectile.zip")
}

-- ============================================================================
-- 1. ĐẠN BĂNG CỦA SÓI TUYẾT (hh_hound_glacial_proj)
-- ============================================================================
local function pipethrown(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:PlayAnimation("shoot")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function onhit(inst, attacker, target)
    if not target:IsValid() or target:HasTag("hound") or target:HasTag("warg") or target:HasTag("hh_dungeon_mob") then
        return
    end

    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

    if target.components.freezable ~= nil and target.sg ~= nil and not target.sg:HasStateTag("frozen") then
        target.components.freezable:AddColdness(1.5, 1, true)
        target.components.freezable:SpawnShatterFX()
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
        local dmg = (attacker ~= nil and attacker.components.combat ~= nil) and attacker.components.combat.defaultdamage or 25
        if target.components.combat ~= nil then
            target.components.combat:GetAttacked(attacker, dmg, inst)
        end
    end

    inst:Remove()
end

local function fnglacial_proj()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("glacial_hound_projectile")
    inst.AnimState:SetBuild("glacial_hound_projectile")
    inst.AnimState:PlayAnimation("shoot_side")

    inst:AddTag("NOCLICK")
    inst:AddTag("sharp")
    inst:AddTag("weapon")
    inst:AddTag("projectile")

    RemovePhysicsColliders(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetOnThrownFn(pipethrown)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(math.sqrt(3))
    inst.components.projectile:SetOnHitFn(onhit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetLaunchOffset(Vector3(0, 2, 0))

    inst:DoTaskInTime(5, inst.Remove)

    inst.persists = false

    return inst
end

-- ============================================================================
-- 2. TIA SÉT CỦA SÓI ĐIỆN (hound_lightning / hh_hound_lightning)
-- ============================================================================
local function Sparks(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local x1 = x + math.random(-2, 2)
    local z1 = z + math.random(-2, 2)

    if math.random() >= 0.6 then
        SpawnPrefab("electricchargedfx").Transform:SetPosition(x1, 0, z1)
    end

    SpawnPrefab("sparks").Transform:SetPosition(x1, 0 + 0.25 * math.random(), z1)
end

local function Zap(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local projectile = SpawnPrefab("lightning")
    if projectile ~= nil then
        projectile.Transform:SetPosition(x, y + 2, z)
    end

    for i = 1, 5 do
        local sp = SpawnPrefab("sparks")
        if sp ~= nil then
            sp.Transform:SetPosition(x, y + 0.25 + math.random() * 2, z)
        end
    end

    local ents = TheSim:FindEntities(x, y, z, 3.5, { "_health" }, inst.NoTags)
    for i, v in ipairs(ents) do
        if v ~= nil and v.components.health ~= nil and not v.components.health:IsDead() and v.components.combat ~= nil then
            if not v:HasTag("electricdamageimmune") then
                local insulated = (v:HasTag("electricdamageimmune") or
                    (v.components.inventory ~= nil and v.components.inventory:IsInsulated()))

                local mult = not insulated
                    and (TUNING.ELECTRIC_DAMAGE_MULT or 1.5) + (TUNING.ELECTRIC_WET_DAMAGE_MULT or 1) * (v.components.moisture ~= nil and v.components.moisture:GetMoisturePercent() or (v:GetIsWet() and 1 or 0))
                    or 1

                local damage = -15 * mult

                if v.sg ~= nil and not v.sg:HasStateTag("nointerrupt") and not insulated and v:HasTag("player") and not v:HasTag("playerghost") and v.components.health ~= nil and not v.components.health:IsDead() then
                    v.sg:GoToState("electrocute")
                end

                v.components.health:DoDelta(damage, nil, inst.prefab, nil, inst)
            else
                if v.components.playerlightningtarget ~= nil then
                    v.components.playerlightningtarget:DoStrike()
                end
            end
        end
    end

    inst:DoTaskInTime(0, function(inst) inst:Remove() end)
end

local function fn_lightning_proj()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("hound_lightning")
    inst:AddTag("sharp")
    inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.NoTags = { "INLIMBO", "shadow", "structure", "wall", "hh_dungeon_mob", "hound" }

    inst.task = inst:DoPeriodicTask(0.05, Sparks)

    inst:DoTaskInTime(0, function()
        inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_far")
        Sparks(inst)
        inst:DoTaskInTime(inst.Delay ~= nil and inst.Delay or 1, Zap)
    end)
    return inst
end

return Prefab("hh_hound_glacial_proj", fnglacial_proj, glacial_assets),
    Prefab("hound_lightning", fn_lightning_proj, {}),
    Prefab("hh_hound_lightning", fn_lightning_proj, {})
