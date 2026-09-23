-- Lục Nguyên Kiếm Đồng. Visuals adapted from Tu Tiên 19.7; see docs/CREDITS.md.
local Bridge = require("ttk_lucnguyen_combat")
local Rules = require("ttk_lucnguyen_rules")
local Elements = require("ttk_elemental_combat")

local BASE_DAMAGE = 50
local MAX_USES = 1000
local REPAIR_USES = 100
local FLIGHT_SPEED = 12
local TURN_RATE = 8
local FLIGHT_TIMEOUT = 3
local HIT_DISTANCE = .65
local MAX_FLIGHT_RANGE = 30

local function SetRitualLevel(inst, level)
    level = tonumber(level) or 0
    if level ~= level then level = 0 end
    inst._ttk_ritual_level = math.floor(math.max(0, math.min(9, level)))
end

local function OnSave(inst, data)
    data.ttk_ritual_level = inst._ttk_ritual_level or 0
end

local function OnLoad(inst, data)
    SetRitualLevel(inst, data ~= nil and data.ttk_ritual_level or 0)
end

local ELEMENTS = {
    { bank = "xd_wxj", build = "xd_wxj", anim = "idle", colour = { .85, .9, 1 } },
    { bank = "xd_htz_qzj", build = "xd_htz_qzj", anim = "idle", colour = { .3, .85, .35 } },
    { bank = "xd_xlj", build = "xd_xlj", anim = "idle", colour = { .3, .55, 1 } },
    { bank = "xd_ftj", build = "xd_ftj", anim = "idle", colour = { 1, .35, .08 } },
    { bank = "xd_sword_red", build = "xd_sword_red", anim = "idle", colour = { .8, .62, .2 } },
    { bank = "xd_sword_mo", build = "xd_sword_mo", anim = "idle", colour = { .75, .2, 1 } },
}

local assets = {
    Asset("ANIM", "anim/ttk_lucnguyen_weapon.zip"),
    Asset("ANIM", "anim/ttk_lucnguyen_kim.zip"),
    Asset("ANIM", "anim/ttk_lucnguyen_moc.zip"),
    Asset("ANIM", "anim/ttk_tinhlakiem.zip"),
    Asset("ANIM", "anim/ttk_lucnguyen_hoa.zip"),
    Asset("ANIM", "anim/ttk_lucnguyen_tho.zip"),
    Asset("ANIM", "anim/ttk_lucnguyen_loi.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_lucnguyenkiemdong.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_lucnguyenkiemdong.tex"),
}

local prefabs = { "impact" }
for index = 1, #ELEMENTS do
    table.insert(prefabs, "ttk_lucnguyen_sword_" .. tostring(index))
    table.insert(prefabs, "ttk_lucnguyen_trail_" .. tostring(index))
end

local function IsValid(inst)
    return inst ~= nil and inst:IsValid()
end

local function IsLivingTarget(target)
    return IsValid(target)
        and not target:IsInLimbo()
        and (target.components.health == nil or not target.components.health:IsDead())
end

local function IsLivingOwner(owner)
    return IsValid(owner)
        and not owner:IsInLimbo()
        and not owner:HasTag("playerghost")
        and (owner.components.health == nil or not owner.components.health:IsDead())
end

local function FinishSword(inst, hit)
    if inst._finished then return end
    inst._finished = true
    if inst._update_task ~= nil then
        inst._update_task:Cancel()
        inst._update_task = nil
    end
    if hit and IsLivingOwner(inst._owner) and IsLivingTarget(inst._target) then
        local weapon = IsValid(inst._source_weapon) and inst._source_weapon or nil
        if inst._apply_impact then
            Elements.ApplySwordImpact(
                inst._owner, inst._target, inst._damage, weapon, inst._element
            )
        else
            Bridge.ApplyAuxiliary(inst._owner, inst._target, inst._damage, weapon)
        end
    end
    inst:Remove()
end

local function UpdateSword(inst)
    if not IsLivingOwner(inst._owner) or not IsLivingTarget(inst._target) then
        FinishSword(inst, false)
        return
    end

    local dt = FRAMES
    inst._elapsed = inst._elapsed + dt
    if Rules.IsExpired(inst._elapsed, FLIGHT_TIMEOUT) then
        FinishSword(inst, false)
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local rx, rz = x - inst._origin_x, z - inst._origin_z
    if rx * rx + rz * rz > MAX_FLIGHT_RANGE * MAX_FLIGHT_RANGE then
        FinishSword(inst, false)
        return
    end
    local tx, ty, tz = inst._target.Transform:GetWorldPosition()
    local dx, dz = tx - x, tz - z
    local hit_range = HIT_DISTANCE
        + (inst._target.GetPhysicsRadius ~= nil and inst._target:GetPhysicsRadius(0) or 0)
    if dx * dx + dz * dz <= hit_range * hit_range then
        FinishSword(inst, true)
        return
    end

    local nx, nz, heading, arrived = Rules.Step(
        x, z, inst._heading, tx, tz, dt, FLIGHT_SPEED, TURN_RATE
    )
    inst._heading = heading
    inst.Transform:SetPosition(nx, y + (ty - y) * .15, nz)
    inst.Transform:SetRotation(-heading / DEGREES)
    if arrived then FinishSword(inst, true) end
end

local function LaunchSword(inst, data)
    if inst._launched or type(data) ~= "table" or not IsLivingOwner(data.owner)
        or not IsLivingTarget(data.target) or type(data.damage) ~= "number" then
        inst:Remove()
        return
    end
    inst._launched = true
    inst._owner = data.owner
    inst._target = data.target
    inst._source_weapon = data.weapon
    inst._damage = data.damage
    inst._element = data.element
    inst._apply_impact = data.apply_impact ~= false
    inst._elapsed = 0

    local ox, oy, oz = data.owner.Transform:GetWorldPosition()
    inst._origin_x, inst._origin_z = ox, oz
    local tx, _, tz = data.target.Transform:GetWorldPosition()
    local base_heading = math.atan2(tz - oz, tx - ox)
    local center = (data.count + 1) / 2
    local side = data.index - center
    if math.abs(side) < .01 then
        side = data.element % 2 == 0 and 1 or -1
    end
    local fan = side * .42
    if math.abs(fan) < .65 then
        fan = fan < 0 and -.65 or .65
    end
    inst._heading = base_heading + fan
    inst.Transform:SetPosition(
        ox - math.sin(base_heading) * side * .28,
        oy + 1.2,
        oz + math.cos(base_heading) * side * .28
    )
    inst.Transform:SetRotation(-inst._heading / DEGREES)
    inst._update_task = inst:DoPeriodicTask(FRAMES, UpdateSword, 0)
end

local function MakeTrail(index)
    local envelope = "ttk_lucnguyen_trail_colour_" .. tostring(index)
    local initialized = false
    local colour = ELEMENTS[index].colour
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst.persists = false
        if TheNet:IsDedicated() then return inst end
        if not initialized then
            EnvelopeManager:AddColourEnvelope(envelope, {
                { 0, { colour[1], colour[2], colour[3], .8 } },
                { 1, { colour[1] * .4, colour[2] * .4, colour[3] * .4, 0 } },
            })
            initialized = true
        end
        local effect = inst.entity:AddVFXEffect()
        effect:InitEmitters(1)
        effect:SetRenderResources(0, "fx/sparkle.tex", "shaders/vfx_particle_add.ksh")
        effect:SetUVFrameSize(0, .25, 1)
        effect:SetMaxNumParticles(0, 40)
        effect:SetMaxLifetime(0, .3)
        effect:SetColourEnvelope(0, envelope)
        effect:SetBlendMode(0, BLENDMODE.Additive)
        effect:EnableBloomPass(0, true)
        effect:SetLayer(0, LAYER_GROUND)
        effect:SetSortOrder(0, 1)
        EmitterManager:AddEmitter(inst, nil, function()
            effect:AddParticle(0, .3, 0, .2, 0, 0, 0, 0)
        end)
        return inst
    end
    return Prefab("ttk_lucnguyen_trail_" .. tostring(index), fn)
end

local function MakeSword(index)
    local element = ELEMENTS[index]
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.AnimState:SetBank(element.bank)
        inst.AnimState:SetBuild(element.build)
        inst.AnimState:PlayAnimation(element.anim, true)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLightOverride(.25)
        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")
        inst.persists = false
        inst._trail_prefab = "ttk_lucnguyen_trail_" .. tostring(index)
        if not TheNet:IsDedicated() then
            inst:DoTaskInTime(0, function(sword)
                if sword:IsValid() then sword:SpawnChild(sword._trail_prefab) end
            end)
        end
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst.Launch = LaunchSword
        return inst
    end
    return Prefab("ttk_lucnguyen_sword_" .. tostring(index), fn, assets, prefabs)
end

local function OnPrimaryThrown(inst)
    inst.AnimState:PlayAnimation("dart")
    inst:AddTag("NOCLICK")
    inst.persists = false
end

local function OnPrimaryPreHit(inst, attacker, target)
    Bridge.BeginPrimary(attacker, target, inst, inst, inst._base_damage or BASE_DAMAGE)
end

local function OnPrimaryHit(inst, attacker, target)
    local context = Bridge.EndPrimary(inst)
    if context ~= nil then
        Bridge.LaunchVolley(context.owner, context.target, context.base_damage, nil, function(data)
            data.weapon = inst._source_weapon
            local sword = SpawnPrefab("ttk_lucnguyen_sword_" .. tostring(data.element))
            if sword ~= nil then sword:Launch(data) end
        end)
    end
    local impact = SpawnPrefab("impact")
    if impact ~= nil then impact.Transform:SetPosition(target.Transform:GetWorldPosition()) end
    inst:Remove()
end

local function OnPrimaryMiss(inst)
    Bridge.CancelPrimary(inst)
    inst:Remove()
end

local function PrimaryProjectileFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("xd_jingwei_blowdart")
    inst.AnimState:SetBuild("xd_jingwei_blowdart")
    inst.AnimState:PlayAnimation("dart")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst:AddTag("projectile")
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(BASE_DAMAGE)
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetRange(12)
    inst.components.projectile:SetOnPreHitFn(OnPrimaryPreHit)
    inst.components.projectile:SetOnHitFn(OnPrimaryHit)
    inst.components.projectile:SetOnMissFn(OnPrimaryMiss)
    inst.components.projectile.has_damage_set = true
    inst:ListenForEvent("onthrown", OnPrimaryThrown)
    return inst
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "xd_jingwei_blowdart", "swap_blowdart")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnProjectileLaunched(inst, attacker, target, projectile)
    if projectile == nil then return end
    local uses = inst.components.finiteuses
    if uses == nil or uses:GetUses() <= 0 then
        projectile:Remove()
        return
    end
    -- Apply once to the launch snapshot, leaving Solo's weapon base untouched.
    -- Crit volleys inherit this same pre-crit snapshot after the primary hits.
    local damage = Bridge.DamageSnapshot(inst, attacker, target)
        * (1 + (inst._ttk_ritual_level or 0) * 0.05)
    if not projectile._ttk_lucnguyen_charge_consumed then
        projectile._ttk_lucnguyen_charge_consumed = true
        uses:Use(1)
    end
    projectile._base_damage = damage
    projectile._source_weapon = inst
    projectile.components.weapon:SetDamage(damage)
    -- Retain the shooter directly. Projectile:Throw initially stores the held
    -- weapon as owner, which loses attribution if that weapon is transferred
    -- or removed before impact.
    projectile.components.projectile.owner = attacker
end

local function CanRepair(inst, item, giver, count)
    return item ~= nil and item.prefab == "ttk_lingshi1"
        and (count == nil or count == 1)
        and inst.components.finiteuses:GetUses() < MAX_USES
end

local function OnRepair(inst, giver)
    inst.components.finiteuses:Repair(REPAIR_USES)
    if giver ~= nil and giver.SoundEmitter ~= nil then
        giver.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    end
end

local function WeaponFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "small", .05, { .75, .5, .75 })
    inst.AnimState:SetBank("xd_jingwei_blowdart")
    inst.AnimState:SetBuild("xd_jingwei_blowdart")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("weapon")
    inst:AddTag("rangedweapon")
    inst:AddTag("sharp")
    inst:AddTag("alltrader")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(BASE_DAMAGE)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetProjectile("ttk_lucnguyen_primary_projectile")
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(MAX_USES)
    inst.components.finiteuses:SetUses(MAX_USES)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname =
        "images/inventoryimages/ttk_lucnguyenkiemdong.xml"
    inst.components.inventoryitem.imagename = "ttk_lucnguyenkiemdong"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader:SetAbleToAcceptTest(CanRepair)
    inst.components.trader.onaccept = OnRepair

    inst.TTKApplyRitualLevel = SetRitualLevel
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    SetRitualLevel(inst, 0)

    MakeHauntableLaunch(inst)
    return inst
end

local results = {
    Prefab("ttk_lucnguyenkiemdong", WeaponFn, assets, prefabs),
    Prefab("ttk_lucnguyen_primary_projectile", PrimaryProjectileFn, assets, prefabs),
}
for index = 1, #ELEMENTS do
    table.insert(results, MakeSword(index))
    table.insert(results, MakeTrail(index))
end
return unpack(results)
