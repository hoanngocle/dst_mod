local HHDaogamDurability = require("utils/hh_daogam_durability")
local HHUtils = require("utils/hh_utils")

local assets =
{
    Asset("ANIM", "anim/hh_daogam.zip"),
	Asset("ANIM", "anim/hh_daogam_swap.zip"),
	Asset("ANIM", "anim/curseshot.zip"),
	Asset("ANIM", "anim/hh_purple_electric_fx.zip"),
	Asset("ANIM", "anim/hh_purple_mosling_spin_fx.zip"),
	Asset("ANIM", "anim/hh_purple_deer_ice_charge.zip"),
	Asset("IMAGE", "fx/sparkle.tex"),
	Asset("SHADER", "shaders/vfx_particle_add.ksh"),

    Asset("ATLAS", "images/inventoryimages/hh_daogam.xml"),
    Asset("IMAGE", "images/inventoryimages/hh_daogam.tex"),
}

local attack_damage = 64
local extra_damage = 10
local fire_skill_cooldown = 15
local fire_skill_durability_cost = 8
local fire_passive_damage = 50
local fire_passive_chance = 0.7
local fire_passive_puffs = {
    "hh_daogam_firepuff_1",
    "hh_daogam_firepuff_2",
    "hh_daogam_firepuff_3",
}
local fire_passive_exclude_tags = {
    "INLIMBO",
    "NOCLICK",
    "notarget",
    "player",
    "noattack",
    "playerghost",
    "wall",
    "structure",
    "balloon",
    "companion",
    "glommer",
    "friendlyfruitfly",
    "abigail",
    "shadowminion",
}

local function onequip(inst, owner)
    -- Hết độ bền (< 1%) thì không thể cầm lên tay: bật lại về túi/balo ngay
    if inst.components.finiteuses ~= nil and inst.components.finiteuses:GetPercent() < 0.01 then
        inst:DoTaskInTime(0, function()
            if owner ~= nil and owner.components.inventory ~= nil and inst.components.equippable ~= nil then
                local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
                if item ~= nil then
                    owner.components.inventory:GiveItem(item)
                end
                if owner.components.talker ~= nil then
                    owner.components.talker:Say("Kiếm chưa được sửa chữa, không thể cầm lên!")
                end
            end
        end)
        return
    end
    -- Kiếm hiển thị qua swap_object chuẩn của DST (build hh_daogam_swap được dựng với pivot
    -- tại cán giống swap_glasscutter vanilla) — tự động đúng hướng nhìn 4 phía, đúng lớp
    -- trước/sau nhân vật và vung theo cung khi tấn công như mọi vũ khí khác
    owner.AnimState:OverrideSymbol("swap_object", "hh_daogam_swap", "swap_daogam")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    -- Combo hiệu ứng khi cầm lên tay: sao chép y hệt Thiên Gia Thần Kiếm (factory hh_weapon.lua)
    -- deer_ice_charge = quầng hào quang + âm thanh sạc; cane_victorian_fx = hào quang lấp lánh;
    -- sparks1_fx/sparks2_fx (FX nội bộ mod) = tia điện quanh người nhân vật
    if inst.fx00 ~= nil then
        inst.fx00:Remove()
        inst.fx00 = nil
    end
    inst.fx00 = SpawnPrefab("deer_ice_charge")
    if inst.fx00 then
        inst.fx00.AnimState:SetBuild("hh_purple_deer_ice_charge")
        inst.fx00.entity:AddFollower()
        inst.fx00.entity:SetParent(owner.entity)
        inst.fx00.Follower:FollowSymbol(owner.GUID, "swap_object", 10, -100, 0)
    end
    if inst.fx0 ~= nil then
        inst.fx0:Remove()
        inst.fx0 = nil
    end
    -- Hào quang lấp lánh TÍM ĐEN: bản sao hệ thống hạt của cane_victorian_fx với màu tím
    -- (fx gốc là VFX particle KHÔNG có AnimState nên không thể nhuộm bằng SetMultColour)
    inst.fx0 = SpawnPrefab("hh_daogam_sparkle_fx")
    if inst.fx0 then
        inst.fx0.entity:AddFollower()
        inst.fx0.entity:SetParent(owner.entity)
        inst.fx0.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -60, 0)
    end
    local sparks2 = owner:SpawnChild("sparks2_fx")
    if sparks2 then
        sparks2.AnimState:SetBuild("hh_purple_mosling_spin_fx")
        owner:AddChild(sparks2)
        sparks2.Transform:SetPosition(0, 0, 0)
        owner.fx1 = sparks2
    end
    local sparks1 = owner:SpawnChild("sparks1_fx")
    if sparks1 then
        sparks1.AnimState:SetBuild("hh_purple_electric_fx")
        owner:AddChild(sparks1)
        sparks1.Transform:SetPosition(0, -1, 0)
        owner.fx2 = sparks1
    end

	owner:AddTag("stronggrip")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    -- Gỡ combo hiệu ứng (y hệt phần unequip của Thiên Gia Thần Kiếm)
    if inst.fx00 ~= nil then
        inst.fx00:Remove()
        inst.fx00 = nil
    end
    if inst.fx0 ~= nil then
        inst.fx0:Remove()
        inst.fx0 = nil
    end
    if owner.fx1 then
        owner:RemoveChild(owner.fx1)
        owner.fx1:Remove()
        owner.fx1 = nil
    end
    if owner.fx2 then
        owner:RemoveChild(owner.fx2)
        owner.fx2:Remove()
        owner.fx2 = nil
    end

	owner:RemoveTag("stronggrip")
end

local function StopFirePassive(attacker)
    if attacker._hh_daogam_fire_task ~= nil then
        attacker._hh_daogam_fire_task:Cancel()
        attacker._hh_daogam_fire_task = nil
    end
    attacker._hh_daogam_fire_targets = nil
end

local function TryFirePassive(inst, attacker, target)
    if math.random() > fire_passive_chance
        or attacker == nil
        or not attacker:IsValid()
        or attacker.components.combat == nil
        or target == nil
        or not target:IsValid()
        or target.Transform == nil
        or attacker._hh_daogam_fire_task ~= nil then
        return
    end

    local step = 0
    local attacker_pos = attacker:GetPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local angle = attacker:GetAngleToPoint(Vector3(tx, ty, tz))
    if angle < 0 then
        angle = angle + 360
    end
    angle = -angle

    attacker._hh_daogam_fire_targets = {}
    if target.GUID ~= nil then
        attacker._hh_daogam_fire_targets[target.GUID] = true
    end

    attacker._hh_daogam_fire_task = attacker:DoPeriodicTask(0.05, function(owner)
        if owner == nil or not owner:IsValid() or owner.components.combat == nil then
            if owner ~= nil then
                StopFirePassive(owner)
            end
            return
        end

        local distance = 1.5 * step
        for lane = 1, 3 do
            local lane_angle = angle + (lane == 1 and -30 or lane == 3 and 30 or 0)
            local x = attacker_pos.x + distance * math.cos(lane_angle * DEGREES)
            local z = attacker_pos.z + distance * math.sin(lane_angle * DEGREES)
            local puff = SpawnPrefab(fire_passive_puffs[math.random(#fire_passive_puffs)])
            if puff ~= nil and puff.Transform ~= nil then
                puff.Transform:SetPosition(x, 0, z)
            end

            for _, victim in ipairs(TheSim:FindEntities(x, 0, z, 1.7, {"_combat"}, fire_passive_exclude_tags)) do
                if victim ~= target
                    and victim.GUID ~= nil
                    and victim:IsValid()
                    and owner._hh_daogam_fire_targets ~= nil
                    and not owner._hh_daogam_fire_targets[victim.GUID]
                    and victim.components.combat ~= nil
                    and HHUtils:NotIsDead(victim)
                    and HHUtils:CanHitTarget(owner, victim)
                    and owner.components.combat:IsValidTarget(victim) then
                    victim.components.combat:GetAttacked(owner, fire_passive_damage)
                    owner._hh_daogam_fire_targets[victim.GUID] = true
                end
            end
        end

        step = step + 1
        if step > 8 then
            StopFirePassive(owner)
        end
    end)
end

local function onattack(inst, attacker, target)
    TryFirePassive(inst, attacker, target)
    local slash = SpawnPrefab("hh_daogam_knife_ef")
    local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1, 0.5)
	slash.Transform:SetPosition(pt:Get())
	inst:DoTaskInTime(0.2,function()
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        local slash = SpawnPrefab("hh_daogam_knife_ef")
        local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1, 0.5)
        slash.Transform:SetPosition(pt:Get())
		-- DST: combat.damagemultiplier mặc định là nil (mod lamb chỉ chạy được vì nhân vật lambofthecult tự set = 1)
		local total_attack = extra_damage * (attacker.components.combat.damagemultiplier or 1)
		target.components.combat:GetAttacked(attacker, total_attack, nil)
    end
	end)
	inst:DoTaskInTime(0.4,function()
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        local slash = SpawnPrefab("hh_daogam_knife_ef")
        local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1,0.5)
        slash.Transform:SetPosition(pt:Get())
		-- DST: combat.damagemultiplier mặc định là nil (mod lamb chỉ chạy được vì nhân vật lambofthecult tự set = 1)
		local total_attack = extra_damage * (attacker.components.combat.damagemultiplier or 1)
		target.components.combat:GetAttacked(attacker, total_attack, nil)
    end
	end)
	inst:DoTaskInTime(0.6,function()
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        local slash = SpawnPrefab("hh_daogam_knife_ef")
        local pt = Vector3(target.Transform:GetWorldPosition()) + Vector3(math.random() * 2 - 1, 1 + math.random() * 2 - 1, 0.5)
        slash.Transform:SetPosition(pt:Get())
		-- DST: combat.damagemultiplier mặc định là nil (mod lamb chỉ chạy được vì nhân vật lambofthecult tự set = 1)
		local total_attack = extra_damage * (attacker.components.combat.damagemultiplier or 1)
		target.components.combat:GetAttacked(attacker, total_attack, nil)
    end
	end)
end

local function FireSkillTargetFn()
    local player = ThePlayer
    local map = TheWorld.Map
    local targetpos = Vector3()
    if player == nil then
        return targetpos
    end
    for distance = 7, 0, -0.25 do
        targetpos.x, targetpos.y, targetpos.z = player.entity:LocalToWorldSpace(distance, 0, 0)
        if map:IsPassableAtPoint(targetpos:Get()) and not map:IsGroundTargetBlocked(targetpos) then
            return targetpos
        end
    end
    return targetpos
end

local function SetupFireSkillClient(inst)
    inst:AddTag("rechargeable")
    inst:AddTag("bookcabinet_item")
    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetTargetFX("weaponsparks")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = FireSkillTargetFn
    inst.components.aoetargeting.reticule.validcolour = {126 / 255, 240 / 255, 165 / 255, 1}
    inst.components.aoetargeting.reticule.invalidcolour = {178 / 255, 100 / 255, 50 / 255, 1}
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting:SetRange(12)
end

local function SetupFireSkillServer(inst)
    inst.hh_spell_cd = fire_skill_cooldown
    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(function(weapon, doer, pos)
        weapon.components.rechargeable:Discharge(weapon.hh_spell_cd)
        local meteor = SpawnPrefab("hh_daogam_fire_meteor")
        if meteor ~= nil then
            meteor.author = doer
            meteor.Transform:SetPosition(pos.x, pos.y, pos.z)
        end
        if weapon.components.finiteuses ~= nil then
            weapon.components.finiteuses:Use(math.min(weapon.components.finiteuses:GetUses(), fire_skill_durability_cost))
        end
    end)

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(function(weapon)
        weapon.components.aoetargeting:SetEnabled(false)
    end)
    inst.components.rechargeable:SetOnChargedFn(function(weapon)
        weapon.components.aoetargeting:SetEnabled(true)
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("xd_skin_xuanyuan")
    inst.AnimState:SetBuild("hh_daogam")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("sharp")
	inst:AddTag("hh_daogam_item")
	SetupFireSkillClient(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst:AddComponent("damagetypebonus")
    inst.components.damagetypebonus:AddBonus("lunar_aligned", inst, TUNING.WEAPONS_VOIDCLOTH_VS_LUNAR_BONUS)
    inst.components.damagetypebonus:AddBonus("shadow_aligned", inst, TUNING.WEAPONS_LUNARPLANT_VS_SHADOW_BONUS)
    inst.components.weapon:SetDamage(attack_damage)
	inst.components.weapon:SetOnAttack(onattack)

	HHDaogamDurability.AddTo(inst, nil)
	SetupFireSkillServer(inst)

	-- Tooltip khung trang bị (hoverer đọc qua GetHHSpDesc01..05, cùng cơ chế với Thiên Gia Thần Kiếm)
	inst.GetHHSpDesc01 = function(inst, viewer)
		return {["title"] = "Chủ động", ["desc"] = "Nhấn " .. STRINGS["RMB"] .. " để thi triển Thiên Phạt Quỷ Vương (20 mana, cd: 15s, tốn tối đa 8 độ bền)"}
	end
	inst.GetHHSpDesc02 = function(inst, viewer)
		return {["title"] = "Bị động", ["desc"] = "Mỗi đòn đánh tạo thêm 3 vệt chém, mỗi vệt gây 10 sát thương\nTam Ảnh Trảm: Tấn công có 70% kích hoạt, gây 50 sát thương mỗi mục tiêu"}
	end
    inst.GetHHSpDesc03 = function(inst, viewer)
		return {["title"] = "Sửa chữa", ["desc"] = HHDaogamDurability.GetRepairDescription()}
	end
	inst.GetHHSpDesc04 = function() return {title = "Hệ đồ", desc = "Tối Thượng", rainbow = true} end

    -------
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "hh_daogam"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/hh_daogam.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    --MakeHauntableLaunch(inst)

    return inst
end

local function daogam_knife_effn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    --MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("curseshot")
    inst.AnimState:SetBuild("curseshot")
    inst.AnimState:PlayAnimation("knifeslash")

	inst:AddTag("FX")
	inst:DoTaskInTime(.36, inst.Remove)

    --inst.entity:SetPristine()

	if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

-- Hào quang lấp lánh tím đen: sao chép 100% hệ thống hạt của cane_victorian_fx (game gốc),
-- chỉ đổi tên envelope (đăng ký toàn cục nên phải là tên riêng) và màu hạt vàng -> tím
local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local COLOUR_ENVELOPE_NAME = "hh_daogam_sparkle_colourenvelope"
local SCALE_ENVELOPE_NAME = "hh_daogam_sparkle_scaleenvelope"

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 1 do
        table.insert(envs, { t, IntColour(150, 60, 235, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(60, 15, 110, 0) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(60, 15, 110, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, envs)

    local sparkle_max_scale = .4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,    { sparkle_max_scale, sparkle_max_scale } },
            { 1,    { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local SPARKLE_MAX_LIFETIME = 1.75

local function emit_sparkle_fn(effect, sphere_emitter)
    local vx, vy, vz = .012 * UnitRand(), 0, .012 * UnitRand()
    local lifetime = SPARKLE_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz,         -- velocity
        angle, ang_vel,     -- angle, angular_velocity
        uv_offset, 0        -- uv offset
    )
end

local function sparkle_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 256)
    effect:SetMaxLifetime(0, SPARKLE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local sparkle_desired_pps_low = 5
    local sparkle_desired_pps_high = 50
    local low_per_tick = sparkle_desired_pps_low * tick_time
    local high_per_tick = sparkle_desired_pps_high * tick_time
    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.25)
    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move*6, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)

        inst.last_pos = inst:GetPosition()

        num_to_emit = num_to_emit + per_tick * math.random() * 3
        while num_to_emit > 1 do
            emit_sparkle_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("hh_daogam", fn, assets),
Prefab("hh_daogam_knife_ef", daogam_knife_effn, assets),
Prefab("hh_daogam_sparkle_fx", sparkle_fn, assets)
