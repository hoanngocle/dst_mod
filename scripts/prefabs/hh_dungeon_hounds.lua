
local assets = {
    Asset("ANIM", "anim/hh_hound_fire.zip"),
    Asset("ANIM", "anim/hh_hound_snow.zip"),
    Asset("ANIM", "anim/hh_hound_lightning.zip"),
    Asset("ANIM", "anim/hh_hound_horror.zip"),
}

local prefabs = {
    "hh_hound_glacial_proj",
    "hound_lightning",
    "deer_fire_circle",
    "deer_ice_circle",
    "deer_ice_flakes",
    "electricchargedfx",
    "sparks"
}

local SHARE_TARGET_DIST = 30

-- Hằng số an toàn phòng trường hợp biến TUNING nil
local SAFE_HOUND_HEALTH = TUNING.HOUND_HEALTH or 150
local SAFE_HOUND_DAMAGE = TUNING.HOUND_DAMAGE or 20
local SAFE_HOUND_SPEED = TUNING.HOUND_SPEED or 10

-- ============================================================================
-- BẢNG CẤU HÌNH HỆ SỐ CHỈ SỐ SÓI HẦM NGỤC (NHÂN SO VỚI GỐC KLEI)
-- Bạn có thể chỉnh sửa trực tiếp các hệ số máu (hp), sát thương (dmg), tốc chạy (speed) tại đây:
-- ============================================================================
local HOUND_DUNGEON_STATS = {
    FIRE      = { hp = 4, dmg = 1.4,  speed = 1.0 },  -- Sói Lửa
    ICE       = { hp = 4, dmg = 1.4,  speed = 1.0 },  -- Sói Băng
    GLACIAL   = { hp = 4, dmg = 1.4,  speed = 1.05 }, -- Sói Tuyết
    LIGHTNING = { hp = 4, dmg = 1.4, speed = 1.1 },  -- Sói Điện
    HORROR    = { hp = 4, dmg = 1.4, speed = 1.15 }, -- Sói Bóng Đêm
}

-- ============================================================================
-- HÀM THIẾT LẬP CHUNG HẦM NGỤC (DUNGEON MOB SETUP)
-- ============================================================================
local function setup_dungeon_mob(inst, mult_hp, mult_dmg, mult_speed)
    inst:AddTag("hh_dungeon_mob")

    if not TheWorld.ismastersim then
        return
    end

    if inst.components.health ~= nil then
        local base_hp = inst.components.health.maxhealth or SAFE_HOUND_HEALTH
        inst.components.health:SetMaxHealth(base_hp * (mult_hp or 1))
    end

    if inst.components.combat ~= nil then
        local base_dmg = inst.components.combat.defaultdamage or SAFE_HOUND_DAMAGE
        inst.components.combat:SetDefaultDamage(base_dmg * (mult_dmg or 1))
    end

    if inst.components.locomotor ~= nil and mult_speed ~= nil then
        inst.components.locomotor.runspeed = (inst.components.locomotor.runspeed or SAFE_HOUND_SPEED) * mult_speed
    end

    -- Kháng Friendly Fire từ quái hầm ngục khác
    inst:ListenForEvent("attacked", function(inst, data)
        if data ~= nil and data.attacker ~= nil then
            if data.attacker:HasTag("hh_dungeon_mob") and data.attacker ~= inst then
                return
            end
            inst.components.combat:SetTarget(data.attacker)
            inst.components.combat:ShareTarget(
                data.attacker,
                SHARE_TARGET_DIST,
                function(dude)
                    return dude:HasTag("hh_dungeon_mob") and not dude.components.health:IsDead()
                end,
                5
            )
        end
    end)
end

local function is_valid_enemy(target)
    return target ~= nil
        and target:IsValid()
        and not target:HasTag("hh_dungeon_mob")
        and not target:HasTag("hound")
        and (target.components.health == nil or not target.components.health:IsDead())
end

-- ============================================================================
-- A. SÓI LỬA (hh_dungeon_firehound)
-- ============================================================================
local function OnHitOther_Fire(inst, data)
    local target = data ~= nil and data.target or nil
    if is_valid_enemy(target) then
        if target.components.burnable ~= nil and not target.components.burnable:IsBurning() then
            target.components.burnable:Ignite(true, inst)
        end
    end
end

local function fn_fire()
    local inst = Prefabs["firehound"].fn()

    inst.AnimState:SetBuild("hh_hound_fire")
    inst:AddTag("hh_dungeon_mob")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("onhitother", OnHitOther_Fire)
    setup_dungeon_mob(inst, HOUND_DUNGEON_STATS.FIRE.hp, HOUND_DUNGEON_STATS.FIRE.dmg, HOUND_DUNGEON_STATS.FIRE.speed)

    return inst
end

-- ============================================================================
-- B. SÓI BĂNG (hh_dungeon_icehound)
-- ============================================================================
local function OnHitOther_Ice(inst, data)
    local target = data ~= nil and data.target or nil
    if is_valid_enemy(target) then
        if target.components.freezable ~= nil then
            target.components.freezable:AddColdness(3)
            target.components.freezable:SpawnShatterFX()
        end
    end
end

local function fn_ice()
    local inst = Prefabs["icehound"].fn()

    inst:AddTag("hh_dungeon_mob")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("onhitother", OnHitOther_Ice)
    setup_dungeon_mob(inst, HOUND_DUNGEON_STATS.ICE.hp, HOUND_DUNGEON_STATS.ICE.dmg, HOUND_DUNGEON_STATS.ICE.speed)

    return inst
end

-- ============================================================================
-- C. SÓI TUYẾT (hh_dungeon_snowhound)
-- ============================================================================
local function GlacialProjectile(inst, target)
    if target ~= nil and target:IsValid() then
        local proj = SpawnPrefab("hh_hound_glacial_proj")
        if proj ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            proj.Transform:SetPosition(x, y, z)
            if proj.components.projectile ~= nil then
                proj.components.projectile:Throw(inst, target, inst)
            end
        end
    end
end

local function ChargingGlacial(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1 = x + (math.random() - 0.5) * 2
    local z1 = z + (math.random() - 0.5) * 2
    if math.random() >= 0.5 then
        local fx = SpawnPrefab("deer_ice_flakes")
        if fx ~= nil then
            fx.Transform:SetPosition(x1, 0, z1)
            inst._glacial_fx = inst._glacial_fx or {}
            table.insert(inst._glacial_fx, fx)
            fx:DoTaskInTime(1.0, function(f)
                if f:IsValid() then
                    if f.KillFX ~= nil then
                        f:KillFX()
                    else
                        f:Remove()
                    end
                end
            end)
        end
    end
end

local function ChargeGlacial(inst)
    inst._glacial_fx = inst._glacial_fx or {}
    inst.task = inst:DoPeriodicTask(0.15, function(inst) ChargingGlacial(inst) end)
end

local function CancelChargeGlacial(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    if inst._glacial_fx ~= nil then
        for _, fx in ipairs(inst._glacial_fx) do
            if fx ~= nil and fx:IsValid() then
                if fx.KillFX ~= nil then
                    fx:KillFX()
                else
                    fx:Remove()
                end
            end
        end
        inst._glacial_fx = nil
    end
end

local function OnHitOther_Glacial(inst, data)
    local target = data ~= nil and data.target or nil
    if is_valid_enemy(target) then
        if target.components.freezable ~= nil then
            target.components.freezable:AddColdness(2)
            target.components.freezable:SpawnShatterFX()
        end
    end
end

local function ontimerdone(inst, data)
    if data ~= nil and data.name == "lightningshot_cooldown" then
        inst.lightningshot = true
    end
end

local function fn_glacial()
    local inst = Prefabs["icehound"].fn()

    inst.AnimState:SetBuild("hh_hound_snow")
    inst:AddTag("hh_dungeon_mob")
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    if not TheWorld.ismastersim then
        return inst
    end

    if inst.components.timer == nil then
        inst:AddComponent("timer")
    end
    inst:ListenForEvent("timerdone", ontimerdone)

    inst.LaunchProjectile = GlacialProjectile
    inst.CancelCharge = CancelChargeGlacial
    inst.Charge = ChargeGlacial
    inst.lightningshot = true
    inst.task = nil

    inst:SetStateGraph("SGhh_snowhound")

    if inst.components.combat ~= nil then
        inst.components.combat:SetRange(8, 3)
    end

    inst:ListenForEvent("onhitother", OnHitOther_Glacial)
    setup_dungeon_mob(inst, HOUND_DUNGEON_STATS.GLACIAL.hp, HOUND_DUNGEON_STATS.GLACIAL.dmg, HOUND_DUNGEON_STATS.GLACIAL.speed)

    return inst
end

-- ============================================================================
-- D. SÓI ĐIỆN (hh_dungeon_lightninghound)
-- ============================================================================
local function Zap(posx, posz, source)
    local x = posx + (math.random() - 0.5) * 4
    local z = posz + (math.random() - 0.5) * 4
    local sinkhole = SpawnPrefab("hound_lightning")
    if sinkhole ~= nil then
        sinkhole.NoTags = { "INLIMBO", "shadow", "hound", "hh_dungeon_mob" }
        sinkhole._hh_world_rank_source = source
        sinkhole.Transform:SetPosition(x, 0, z)
    end
end

local function LaunchLightningProjectile(inst, targetpos)
    if targetpos ~= nil and targetpos.Transform ~= nil then
        local x, y, z = targetpos.Transform:GetWorldPosition()
        inst:DoTaskInTime(0, function() Zap(x, z, inst) end)
        inst:DoTaskInTime(0.4, function() Zap(x, z, inst) end)
        inst:DoTaskInTime(0.8, function() Zap(x, z, inst) end)
    end
end

local function ChargingLightning(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1 = x + (math.random() - 0.5) * 2
    local z1 = z + (math.random() - 0.5) * 2
    if math.random() >= 0.7 then
        local fx = SpawnPrefab("electricchargedfx")
        if fx ~= nil then
            fx.Transform:SetPosition(x1, 0, z1)
        end
    end
end

local function ChargeLightning(inst)
    inst.task = inst:DoPeriodicTask(0.15, function(inst) ChargingLightning(inst) end)
end

local function CancelChargeLightning(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function OnHitOther_Lightning(inst, data)
    local target = data ~= nil and data.target or nil
    if is_valid_enemy(target) then
        local fx = SpawnPrefab("sparks")
        if fx ~= nil then
            fx.Transform:SetPosition(target.Transform:GetWorldPosition())
        end
    end
end

local function DoLightningExplosion(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local bolt = SpawnPrefab("hound_lightning")
    if bolt ~= nil then
        bolt._hh_world_rank_source = inst
        bolt.Transform:SetPosition(x, y, z)
    end
end

local function fn_lightning()
    local inst = Prefabs["hound"].fn()

    inst.AnimState:SetBuild("hh_hound_lightning")
    inst:AddTag("hh_dungeon_mob")
    inst:AddTag("electricdamageimmune")

    if not TheWorld.ismastersim then
        return inst
    end

    if inst.components.timer == nil then
        inst:AddComponent("timer")
    end
    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("death", DoLightningExplosion)

    inst.LaunchProjectile = LaunchLightningProjectile
    inst.CancelCharge = CancelChargeLightning
    inst.Charge = ChargeLightning
    inst.lightningshot = true
    inst.task = nil

    inst:SetStateGraph("SGhh_lightninghound")

    if inst.components.combat ~= nil then
        inst.components.combat:SetRange(10, 3)
    end

    inst:ListenForEvent("onhitother", OnHitOther_Lightning)
    setup_dungeon_mob(inst, HOUND_DUNGEON_STATS.LIGHTNING.hp, HOUND_DUNGEON_STATS.LIGHTNING.dmg, HOUND_DUNGEON_STATS.LIGHTNING.speed)

    return inst
end

-- ============================================================================
-- E. SÓI BÓNG ĐÊM (hh_dungeon_horrorhound)
-- ============================================================================
local function OnHitOther_Horror(inst, data)
    local target = data ~= nil and data.target or nil
    if is_valid_enemy(target) then
        if target.components.sanity ~= nil then
            target.components.sanity:DoDelta(-30)
        end
    end
end

local function fn_horror()
    local inst = Prefabs["mutatedhound"].fn()

    inst.AnimState:SetBuild("hh_hound_horror")
    inst:AddTag("hh_dungeon_mob")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("onhitother", OnHitOther_Horror)
    setup_dungeon_mob(inst, HOUND_DUNGEON_STATS.HORROR.hp, HOUND_DUNGEON_STATS.HORROR.dmg, HOUND_DUNGEON_STATS.HORROR.speed)

    return inst
end

return Prefab("hh_dungeon_firehound", fn_fire, assets, prefabs),
    Prefab("hh_dungeon_icehound", fn_ice, assets, prefabs),
    Prefab("hh_dungeon_snowhound", fn_glacial, assets, prefabs),
    Prefab("hh_dungeon_lightninghound", fn_lightning, assets, prefabs),
    Prefab("hh_dungeon_horrorhound", fn_horror, assets, prefabs)
