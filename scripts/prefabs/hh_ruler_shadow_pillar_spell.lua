local prefabs =
{
    "hh_ruler_shadow_pillar_target",
    "shadow_pillar",
    "shadow_pillar_base_fx",
    "shadow_glob_fx",
    "sanity_raise",
    "sanity_lower",
    "ocean_splash_med1",
    "ocean_splash_med2",
    "reticuleaoe",
    "reticuleaoeping",
    "reticuleaoecctarget",
}

local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    if player == nil or player.entity == nil then
        return nil
    end

    local ground = TheWorld.Map
    local pos = Vector3()
    -- Maxwell's current targeting leaves room inside the native CASTAOE range.
    for r = 7, 0, -0.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos.x, 0, pos.z, true)
            and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function CopyReticuleSettings(inst)
    if inst.components.reticule == nil then
        inst:AddComponent("reticule")
        for key, value in pairs(inst.components.aoetargeting.reticule) do
            inst.components.reticule[key] = value
        end
    end
end

local function StartRulerTargeting(inst)
    local owner = ThePlayer
    if owner == nil or inst.hh_ruler_owner == nil
        or inst.hh_ruler_owner:value() ~= owner then
        return false
    end

    local controller = owner.components ~= nil and owner.components.playercontroller or nil
    local aoetargeting = inst.components ~= nil and inst.components.aoetargeting or nil
    if controller == nil or aoetargeting == nil or not aoetargeting:IsEnabled() then
        return false
    end

    if controller:IsAOETargeting() then
        if controller.reticule ~= nil and controller.reticule.inst == inst then
            return true
        end
        return false
    end

    -- Native AOETargeting intentionally requires a grand-owned inventory item.
    -- This proxy has no inventory slot, so its replica ownership check is
    -- narrowed to this entity and the server-provided owner netvar only.
    local inventoryitem = inst.replica ~= nil and inst.replica.inventoryitem or nil
    if inventoryitem ~= nil and inventoryitem.IsGrandOwner ~= nil then
        if inst._hh_ruler_original_is_grand_owner == nil then
            inst._hh_ruler_original_is_grand_owner = inventoryitem.IsGrandOwner
        end
        inventoryitem.IsGrandOwner = function(_, guy)
            return guy == owner and inst.hh_ruler_owner:value() == guy
        end
    end

    -- Use the native StartTargeting path first. The explicit fallback copies
    -- only the vanilla reticule setup because a classified proxy may not have
    -- its inventory replica in the same frame as the owner netvar.
    aoetargeting:StartTargeting()
    if inst.components.reticule == nil then
        CopyReticuleSettings(inst)
        controller:RefreshReticule(inst)
    end

    return controller:IsAOETargeting()
        and controller.reticule ~= nil
        and controller.reticule.inst == inst
end

local function RulerCasterFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("hh_ruler_caster")

    inst.hh_ruler_owner = net_entity(inst.GUID, "hh_ruler_owner", "hh_ruler_owner_dirty")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting:SetRange((TUNING.HH_RULER and TUNING.HH_RULER.CAST_RANGE) or 8)
    inst.components.aoetargeting:SetTargetFX("reticuleaoecctarget")
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
    inst.components.aoetargeting.reticule.validcolour = { 1, 0.75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { 0.5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting.reticule.twinstickmode = 1
    inst.components.aoetargeting.reticule.twinstickrange = 8
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"

    inst:AddComponent("spellbook")
    inst.components.spellbook:SetItems({
        {
            label = STRINGS ~= nil and STRINGS.HH_RULER ~= nil
                and STRINGS.HH_RULER.NAME or "Kẻ Thống Trị",
        },
    })
    inst.components.spellbook:SetSpellName(
        STRINGS ~= nil and STRINGS.HH_RULER ~= nil
            and STRINGS.HH_RULER.NAME or "Kẻ Thống Trị")
    inst.components.spellbook:SelectSpell(1)

    inst.StartRulerTargeting = StartRulerTargeting

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:SetOnDroppedFn(function(dropped)
        if dropped:IsValid() then
            dropped:Remove()
        end
    end)

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(function(_, doer, pos)
        local ruler = doer ~= nil and doer.components ~= nil and doer.components.hh_ruler or nil
        return ruler ~= nil and ruler:CastAt(pos, inst) or false
    end)

    inst.persists = false
    return inst
end

--------------------------------------------------------------------------
-- The following section mirrors the current vanilla shadow_pillar_spell.
-- It is a separate controller so the vanilla prefab is never modified.

local TRAIL_TAGS = { "shadowtrail" }

local function TryFX(inst, offsets, map)
    local offs1, offs2, offs3 = unpack(offsets)
    while true do
        local offset = table.remove(offs1, math.random(#offs1))
        local x, y, z = inst.entity:LocalToWorldSpaceIncParent(offset:Get())
        table.insert(offs3, offset)
        if map:IsPassableAtPoint(x, 0, z, true)
            and not map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
            if #TheSim:FindEntities(x, 0, z, 0.7, TRAIL_TAGS) <= 0 then
                local fx = SpawnPrefab("shadow_glob_fx")
                if map:IsOceanAtPoint(x, 0, z, true) then
                    local platform = map:GetPlatformAtPoint(x, z)
                    if platform ~= nil then
                        fx.entity:SetParent(platform.entity)
                        x, y, z = platform.entity:WorldToLocalSpace(x, 0, z)
                    else
                        fx:EnableRipples(true)
                    end
                end
                fx.Transform:SetPosition(x, 0, z)
            end
            break
        elseif #offs1 <= 0 then
            if #offs2 > 0 then
                offsets[1] = offs2
                offsets[2] = offs1
                offs1 = offs2
                offs2 = offsets[2]
            else
                offsets[1] = offs3
                offsets[3] = offs1
                return
            end
        end
    end

    for i = 1, #offs3 do
        table.insert(offs2, offs3[i])
        offs3[i] = nil
    end
    if #offs1 <= 0 then
        offsets[1] = offs2
        offsets[2] = offs1
    end
end

local function StartFX(inst)
    local angle = math.random() * PI2
    local offsets = {}
    for i = 1, 3 do
        local radius = (i - 1) * 1.6
        local count = i > 1 and i * i - 1 or 1
        local delta = PI2 / count
        for j = 1, count do
            angle = angle + delta
            table.insert(offsets, Vector3(math.cos(angle) * radius, 0, -math.sin(angle) * radius))
        end
        angle = angle + delta * 0.5
    end
    inst:DoPeriodicTask(2 * FRAMES, TryFX, 0, { offsets, {}, {} }, TheWorld.Map)
end

local function IsNearOther(pt, newpillars)
    for _, value in ipairs(newpillars) do
        if distsq(pt.x, pt.z, value.x, value.z) < 1 then
            return true
        end
    end
    return false
end

local function DoPillarsTarget(target, caster, item, newpillars, map, x0, z0)
    target:PushEvent("dispell_shadow_pillars")

    local padding =
        (target:HasTag("epic") and 1) or
        (target:HasTag("smallcreature") and 0) or
        0.75
    local radius = math.max(1, target:GetPhysicsRadius(0) + padding)
    local circ = PI2 * radius
    local num = math.floor(circ / 1.4 + 0.5)

    local period = 1 / num
    local delays = {}
    for i = 0, num - 1 do
        table.insert(delays, i * period)
    end

    local platform = target:GetCurrentPlatform()
    local flying = not platform and target:HasTag("flying")

    local ent = SpawnPrefab("hh_ruler_shadow_pillar_target")
    if ent == nil then
        return
    end
    ent.Transform:SetPosition(x0, 0, z0)
    ent:SetDelay(delays[#delays])
    ent:SetTarget(target, radius, platform ~= nil, caster)

    local theta = math.random() * PI2
    local delta = PI2 / num
    for i = 1, num do
        local pt = Vector3(x0 + math.cos(theta) * radius, 0, z0 - math.sin(theta) * radius)
        if not IsNearOther(pt, newpillars)
            and map:IsPassableAtPoint(pt.x, 0, pt.z, true)
            and flying or (map:GetPlatformAtPoint(pt.x, pt.z) == platform)
            and not map:IsGroundTargetBlocked(pt) then
            ent = SpawnPrefab("shadow_pillar")
            if ent ~= nil then
                ent.Transform:SetPosition(pt:Get())
                ent:SetDelay(table.remove(delays, math.random(#delays)))
                ent:SetTarget(target, platform ~= nil)
                newpillars[ent] = pt
            end
        end
        theta = theta + delta
    end

    if not (target.sg ~= nil and target.sg:HasStateTag("noattack")) then
        target:PushEvent("attacked", { attacker = caster, damage = 0, weapon = item })
    end
end

local AOE_RADIUS = 4
local SPELL_MUST_TAGS = { "_health" }
local SPELL_NO_TAGS_PVP = { "INLIMBO", "notarget", "flight", "invisible", "projectile", "structure", "wall", "object" }
local SPELL_NO_TAGS = deepcopy(SPELL_NO_TAGS_PVP)
table.insert(SPELL_NO_TAGS, "player")

local function DoPillars(inst, targets, newpillars)
    local map = TheWorld.Map
    local caster = inst.caster ~= nil and inst.caster:IsValid() and inst.caster or nil
    if caster == nil then
        inst:Remove()
        return
    end
    local castercombat = caster ~= nil and caster.components.combat or nil
    local item = inst.item ~= nil and inst.item:IsValid() and inst.item or nil
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(
        x, 0, z, (TUNING.HH_RULER and TUNING.HH_RULER.AOE_RADIUS) or AOE_RADIUS,
        SPELL_MUST_TAGS,
        TheNet:GetPVPEnabled() and SPELL_NO_TAGS_PVP or SPELL_NO_TAGS)

    for _, target in ipairs(ents) do
        local health = target.components ~= nil and target.components.health or nil
        if target ~= caster and target:IsValid() and not targets[target]
            and target.entity:IsVisible()
            and health ~= nil and not health:IsDead()
            and not (castercombat ~= nil and castercombat:IsAlly(target)) then
            x, y, z = target.Transform:GetWorldPosition()
            targets[target] = true
            DoPillarsTarget(target, caster, item, newpillars, map, x, z)
        end
    end
end

local function StopTask(inst, task)
    if task ~= nil then
        task:Cancel()
    end
    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:KillSound("loop")
    end
end

local function RulerSpellFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SoundEmitter:PlaySound("maxwell_rework/shadow_magic/shadow_goop_ground", "loop")
    StartFX(inst)
    local task = inst:DoPeriodicTask(0.25, DoPillars, 0, {}, {})
    inst:DoTaskInTime(1.25, StopTask, task)
    inst:DoTaskInTime(1.5, inst.Remove)
    inst.persists = false

    return inst
end

return Prefab("hh_ruler_caster", RulerCasterFn, nil, prefabs),
    Prefab("hh_ruler_shadow_pillar_spell", RulerSpellFn, nil, prefabs)
