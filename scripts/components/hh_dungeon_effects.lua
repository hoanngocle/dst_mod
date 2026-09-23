local HHDungeonEffects = Class(function(self, inst)
    self.inst = inst
    self.version = 2
    self.effects = {}
    self.target_state = setmetatable({}, { __mode = "k" })
    self.lightfx = nil
    self.next_taunt_time = 0
    self.pickup_task = inst:DoPeriodicTask(0.33, function()
        if self:IsActive("utility_pickup") then self:OrangeAmuletPickup() end
    end)
    self.task = inst:DoPeriodicTask(1, function() self:Update() end)
end)

local PLAYER_TARGET_EFFECTS = {
    player_power={ damage=1.15 },
    player_health={ health=1.20 },
}

local SHADOW_TARGET_EFFECTS = {
    shadow_health={ health=1.20 },
    shadow_damage={ damage=1.15 },
    shadow_guard={ absorb=.12 },
    shadow_speed={ speed=1.12 },
    shadow_attack_speed={ attack=1.10 },
    igris_guard={ absorb=.15, prefab="hh_igris_shadow" },
    macanh_work={ speed=1.20, prefab="hh_macanh_shadow" },
}

local HH_PLAYER_KEYS = {
    player_speed={ { key="addSpeedPercent", value=15 } },
    player_attack_speed={ { key="atk_speed", value=12 } },
    player_guard={ { key="absorbDamage", value=12 } },
    player_allround={
        { key="addComDamagePercent", value=8 },
        { key="addSpeedPercent", value=8 },
        { key="absorbDamage", value=8 },
    },
    player_crit={ { key="criticalHitRate", value=8 } },
    player_lifesteal={ { key="bloodSuck", value=5 } },
    player_cc_guard={
        { key="immuneFreeze", value=1 },
        { key="immuneReduceSpeed", value=1 },
        { key="immuneSuppressNum", value=1 },
    },
    shadow_damage={ { key="addFollowDamage", value=15 } },
    shadow_guard={ { key="addFollowReduceDamage", value=12 } },
    utility_work={ { key="workAddSpeed", value=1 } },
}

local SHADOW_MANA_REASONS = {
    "arise_", "macanh", "fruitfly", "hacanh", "shadow", "recall_",
}

local function Now()
    return GetTime()
end

function HHDungeonEffects:SyncClient()
    if self.inst.hh_dungeon_effects_client == nil then return end

    local now = Now()
    local active = {}
    for effect_id, expires in pairs(self.effects) do
        local remaining = math.ceil(expires - now)
        if remaining > 0 then
            table.insert(active, tostring(effect_id) .. ":" .. tostring(remaining))
        end
    end
    table.sort(active)
    self.inst.hh_dungeon_effects_client:set(table.concat(active, "|"))
end

local function IsValidLiving(inst)
    return inst ~= nil and inst:IsValid()
        and inst.components ~= nil and inst.components.health ~= nil
        and not inst.components.health:IsDead()
end

local function IsBoss(inst)
    return inst ~= nil and inst:IsValid()
        and (inst:HasTag("epic") or inst.hh_is_dungeon_boss or inst:HasTag("hh_dungeon_boss"))
end

local function IsShadowManaReason(reason)
    reason = tostring(reason or "")
    for _, prefix in ipairs(SHADOW_MANA_REASONS) do
        if string.find(reason, prefix, 1, true) ~= nil then return true end
    end
    return false
end

local function GetShadowOwner(shadow)
    return shadow ~= nil and shadow.components ~= nil and shadow.components.follower ~= nil
        and shadow.components.follower:GetLeader() or nil
end

local function GetEffectsForShadow(shadow)
    local owner = GetShadowOwner(shadow)
    return owner ~= nil and owner.components ~= nil and owner.components.hh_dungeon_effects or nil
end

local function ApplyHHPlayerKeys(inst, effect_id, enabled)
    local entries = HH_PLAYER_KEYS[effect_id]
    local player = inst.components.hh_player
    if entries == nil or player == nil then return end
    for _, entry in ipairs(entries) do
        if enabled then player:AddEffectValueByKey(entry.key, entry.value)
        else player:ReduceEffectValueByKey(entry.key, entry.value) end
        if entry.key == "atk_speed" then
            require("utils/hh_utils"):HHClientRpc(inst, "hh_atk_speed", player:GetEffectValueByKey("atk_speed"))
        end
    end
    inst:PushEvent("handle_equip_to_player")
end

local function EnsureShadowHooks(shadow)
    if shadow == nil or not shadow:IsValid() or shadow._hh_dungeon_hooks then return end
    shadow._hh_dungeon_hooks = true

    if shadow.prefab == "hh_beru_shadow" and shadow.components.combat ~= nil then
        local old_calc_damage = shadow.components.combat.CalcDamage
        shadow.components.combat.CalcDamage = function(combat, target, weapon, multiplier, ...)
            local effects = GetEffectsForShadow(shadow)
            if effects ~= nil and effects:IsActive("beru_boss") and IsBoss(target) then
                multiplier = (tonumber(multiplier) or 1) * 1.20
            end
            return old_calc_damage(combat, target, weapon, multiplier, ...)
        end
        shadow:ListenForEvent("onhitother", function(inst, data)
            local effects = GetEffectsForShadow(inst)
            if effects ~= nil and effects:IsActive("beru_lifesteal")
                and inst.components.health ~= nil and not inst.components.health:IsDead() then
                local damage = math.max(0, tonumber(data and (data.damageresolved or data.damage)) or 0)
                if damage > 0 then inst.components.health:DoDelta(damage * .15, false, "hh_dungeon_beru_lifesteal") end
            end
        end)
    end
end

local function ApplyTargetEffect(self, target, effect_id, values, enabled)
    if target == nil or not target:IsValid() then return end
    local states = self.target_state[target]
    if states == nil then
        states = {}
        self.target_state[target] = states
    end
    local state = states[effect_id]
    if enabled and state ~= nil then return end
    if not enabled and state == nil then return end

    local key = "hh_dungeon_" .. effect_id
    local shadow_unit = target.components ~= nil and target.components.hh_shadow_unit or nil
    local composed_shadow_health = effect_id == "shadow_health"
        and shadow_unit ~= nil
        and shadow_unit.SetDungeonHealthMultiplier ~= nil
    local composed_shadow_attack_speed = effect_id == "shadow_attack_speed"
        and shadow_unit ~= nil
        and shadow_unit.SetDungeonAttackSpeedMultiplier ~= nil
    if enabled then
        state = {}
        states[effect_id] = state
        if target.components.locomotor ~= nil and values.speed ~= nil then
            target.components.locomotor:SetExternalSpeedMultiplier(target, key, values.speed)
        end
        if target.components.combat ~= nil then
            if values.damage ~= nil and target.components.combat.externaldamagemultipliers ~= nil then
                target.components.combat.externaldamagemultipliers:SetModifier(target, values.damage, key)
            end
            if values.attack ~= nil then
                if composed_shadow_attack_speed then
                    shadow_unit:SetDungeonAttackSpeedMultiplier(values.attack)
                else
                    state.attack_period = target.components.combat.min_attack_period
                    target.components.combat:SetAttackPeriod(math.max(.2, state.attack_period / values.attack))
                end
            end
        end
        if target.components.health ~= nil then
            if values.absorb ~= nil and target.components.health.externalabsorbmodifiers ~= nil then
                target.components.health.externalabsorbmodifiers:SetModifier(target, values.absorb, key)
            end
            if values.health ~= nil then
                if composed_shadow_health then
                    shadow_unit:SetDungeonHealthMultiplier(values.health)
                else
                    state.health_bonus = math.max(1, target.components.health.maxhealth * (values.health - 1))
                    target.components.health:SetMaxHealth(target.components.health.maxhealth + state.health_bonus)
                    target.components.health:DoDelta(state.health_bonus, false, key)
                end
            end
        end
    else
        if target.components.locomotor ~= nil and values.speed ~= nil then
            target.components.locomotor:RemoveExternalSpeedMultiplier(target, key)
        end
        if target.components.combat ~= nil then
            if values.damage ~= nil and target.components.combat.externaldamagemultipliers ~= nil then
                target.components.combat.externaldamagemultipliers:RemoveModifier(target, key)
            end
            if state.attack_period ~= nil then
                target.components.combat:SetAttackPeriod(state.attack_period)
            elseif composed_shadow_attack_speed then
                shadow_unit:SetDungeonAttackSpeedMultiplier(1)
            end
        end
        if target.components.health ~= nil then
            if values.absorb ~= nil and target.components.health.externalabsorbmodifiers ~= nil then
                target.components.health.externalabsorbmodifiers:RemoveModifier(target, key)
            end
            if state.health_bonus ~= nil then
                target.components.health:SetMaxHealth(math.max(1, target.components.health.maxhealth - state.health_bonus))
            elseif composed_shadow_health then
                shadow_unit:SetDungeonHealthMultiplier(1)
            end
        end
        states[effect_id] = nil
    end
end

local function SyncTargetEffects(self, target, definitions)
    if target == nil or not target:IsValid() then return end
    for effect_id, values in pairs(definitions) do
        local applies = self:IsActive(effect_id)
            and (values.prefab == nil or values.prefab == target.prefab)
        ApplyTargetEffect(self, target, effect_id, values, applies)
    end
end

local function GetActiveShadows(self)
    local result = {}
    local manager = self.inst.components.hh_shadow_manager
    for _, shadow_data in ipairs(manager and manager.shadows or {}) do
        local shadow = shadow_data.is_spawned and shadow_data.inst or nil
        if shadow ~= nil and shadow:IsValid() then table.insert(result, shadow) end
    end
    return result
end



function HHDungeonEffects:IsActive(effect_id)
    return (self.effects[tostring(effect_id or "")] or 0) > Now()
end

function HHDungeonEffects:GetExpMultiplier(is_dungeon)
    local multiplier = 1
    if is_dungeon then
        if self:IsActive("player_dungeon_exp") then multiplier = multiplier * 1.35 end
    elseif self:IsActive("player_exp") then
        multiplier = multiplier * 1.25
    end
    return multiplier
end

function HHDungeonEffects:GetManaCostMultiplier(reason)
    local multiplier = self:IsActive("player_mana_save") and .80 or 1
    if self:IsActive("shadow_mana") and IsShadowManaReason(reason) then
        multiplier = multiplier * .75
    end
    return math.max(.50, multiplier)
end

function HHDungeonEffects:ShouldProtectDurability()
    return self:IsActive("utility_durability") and math.random() < .50
end

function HHDungeonEffects:AddEffect(effect_id, duration)
    effect_id = tostring(effect_id or "")
    if effect_id == "" then return false end
    duration = math.max(1, math.floor(tonumber(duration) or 1))
    if self.effects[effect_id] ~= nil and self.effects[effect_id] <= Now() then
        ApplyHHPlayerKeys(self.inst, effect_id, false)
        self.effects[effect_id] = nil
    end
    local is_new = not self:IsActive(effect_id)
    self.effects[effect_id] = Now() + duration
    if is_new then ApplyHHPlayerKeys(self.inst, effect_id, true) end
    self:RefreshTargets()
    self:SyncClient()
    self.inst:PushEvent("hh_dungeon_effects_changed", { effect_id=effect_id, refreshed=not is_new })
    return true
end

function HHDungeonEffects:RefreshTargets()
    SyncTargetEffects(self, self.inst, PLAYER_TARGET_EFFECTS)
    local shadows = GetActiveShadows(self)
    for _, shadow in ipairs(shadows) do
        EnsureShadowHooks(shadow)
        SyncTargetEffects(self, shadow, SHADOW_TARGET_EFFECTS)
        local dungeon_work_radius = nil
        if shadow.prefab == "hh_fruitfly_shadow" then
            dungeon_work_radius = self:IsActive("fruitfly_radius") and 30 or nil
            shadow._hh_dungeon_fruitfly_care = self:IsActive("fruitfly_care") or nil
        elseif shadow.prefab == "hh_macanh_shadow" then
            dungeon_work_radius = self:IsActive("macanh_work")
                and math.max((TUNING.HH_MACANH_SHADOW and TUNING.HH_MACANH_SHADOW.WORK_RADIUS or 15) * 1.5, 20) or nil
        end
        local shadow_unit = shadow.components ~= nil and shadow.components.hh_shadow_unit or nil
        if shadow_unit ~= nil and shadow_unit.SetDungeonWorkRadius ~= nil then
            shadow_unit:SetDungeonWorkRadius(dungeon_work_radius)
        end
    end
    self:UpdateLight()
end

function HHDungeonEffects:UpdateLight()
    if self:IsActive("utility_light") then
        if self.lightfx == nil or not self.lightfx:IsValid() then
            self.lightfx = SpawnPrefab("minerhatlight")
            if self.lightfx ~= nil then self.lightfx.entity:SetParent(self.inst.entity) end
        end
    elseif self.lightfx ~= nil then
        if self.lightfx:IsValid() then self.lightfx:Remove() end
        self.lightfx = nil
    end
end

local function VacuumItems(player, radius, limit)
    local inventory = player.components.inventory
    if inventory == nil then return 0 end
    local x, y, z = player.Transform:GetWorldPosition()
    local count = 0
    for _, item in ipairs(TheSim:FindEntities(x, y, z, radius, { "_inventoryitem" }, { "INLIMBO", "NOCLICK" })) do
        if count >= limit then break end
        local inventoryitem = item.components.inventoryitem
        if item ~= player and inventoryitem ~= nil and inventoryitem.owner == nil
            and item.components.health == nil and inventory:GiveItem(item) then
            count = count + 1
        end
    end
    return count
end

-- Cơ chế nhặt đồ giống 100% orangeamulet (chỉ nhặt, không hồi tinh thần, không hao độ bền)
local PICKUP_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "irreplaceable", "knockbackdelayinteraction", "event_trigger",
    "minesprung", "mineactive", "catchable",
    "fire", "light", "spider", "cursed", "paired", "bundle",
    "heatrock", "deploykititem", "boatbuilder", "singingshell",
    "archive_lockbox", "simplebook", "furnituredecor",
    "flower", "gemsocket", "structure",
    "donotautopick",
}
local PICKUP_MUST_ONEOF_TAGS = { "_inventoryitem" }

function HHDungeonEffects:OrangeAmuletPickup()
    local player = self.inst
    local inventory = player.components.inventory
    if inventory == nil then return end
    local ba = player:GetBufferedAction()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 4, nil, PICKUP_CANT_TAGS, PICKUP_MUST_ONEOF_TAGS)
    for _, v in ipairs(ents) do
        -- Bỏ qua trang bị, vũ khí, công cụ, kim may, giấy xóa
        if not (v.components.armor or v.components.weapon or v.components.tool
            or v.components.equippable or v.components.sewing or v.components.erasablepaper) then
            -- Chỉ nhặt item nằm trên đất (không đang bị ai giữ)
            if v.components.inventoryitem ~= nil
                and v.components.inventoryitem.canbepickedup
                and v.components.inventoryitem.cangoincontainer
                and not v.components.inventoryitem:IsHeld()
                and v.components.container == nil
                and v.components.bundlemaker == nil
                and not (v.components.bait ~= nil and v.components.bait.trap ~= nil)
                and not (v.components.trap ~= nil and not (v.components.trap:IsSprung() and v.components.trap:HasLoot()))
                and inventory:CanAcceptCount(v, 1) > 0
                and not (ba ~= nil and ba.target == v and (ba.action == ACTIONS.PICKUP or ba.action == ACTIONS.CHECKTRAP)) then
                -- VFX sand_puff giống orangeamulet
                SpawnPrefab("sand_puff").Transform:SetPosition(v.Transform:GetWorldPosition())
                -- Nhặt trap
                if v.components.trap ~= nil then
                    v.components.trap:Harvest(player)
                    return
                end
                -- Lấy 1 từ stack nếu stackable
                local item_pos = v:GetPosition()
                local item = v
                if v.components.stackable ~= nil then
                    item = v.components.stackable:Get()
                end
                inventory:GiveItem(item, nil, item_pos)
                return
            end
        end
    end
end

local function ForEachCarriedItem(player, fn)
    local seen = {}
    local inventory = player.components.inventory
    if inventory == nil then return end
    inventory:ForEachItem(function(item)
        if item ~= nil and not seen[item] then seen[item] = true; fn(item) end
    end)
end

local function RepairCarried(player, armor_only)
    local repaired = 0
    ForEachCarriedItem(player, function(item)
        if armor_only then
            if item.components.armor ~= nil and item.components.armor:GetPercent() < 1 then
                item.components.armor:SetPercent(math.min(1, item.components.armor:GetPercent() + .35))
                repaired = repaired + 1
            end
        elseif item.components.armor == nil and item.components.finiteuses ~= nil
            and item.components.finiteuses:GetPercent() < 1 then
            item.components.finiteuses:SetPercent(math.min(1, item.components.finiteuses:GetPercent() + .35))
            repaired = repaired + 1
        end
    end)
    return repaired
end

local function GiveSpawnedItem(player, prefab, setupfn)
    local item = SpawnPrefab(prefab)
    if item == nil then return false end
    if setupfn ~= nil then setupfn(item) end
    local inventory = player.components.inventory
    if inventory ~= nil and inventory:GiveItem(item) then return true end
    item.Transform:SetPosition(player.Transform:GetWorldPosition())
    return true
end

local function SpawnDungeonBag(player)
    return GiveSpawnedItem(player, "backpack", function(bag)
        local container = bag.components.container
        if container == nil then return end
        local items = {
            { "torch", 1 },
            { "healingsalve", 8 },
            { "perogies", 3 },
            { "rope", 2 },
        }
        for _, data in ipairs(items) do
            local item = SpawnPrefab(data[1])
            if item ~= nil then
                if data[2] > 1 and item.components.stackable ~= nil then
                    item.components.stackable:SetStackSize(data[2])
                end
                if not container:GiveItem(item) then item:Remove() end
            end
        end
    end)
end

local function SpawnCamp(player)
    local position = player:GetPosition()
    local offset = FindWalkableOffset(position, math.random() * math.pi * 2, 3, 12, true, false)
    local camp = SpawnPrefab("tent")
    if camp == nil then return false end
    if offset ~= nil then position = position + offset end
    camp.Transform:SetPosition(position:Get())
    local smoke = SpawnPrefab("spawn_fx_medium")
    if smoke ~= nil then smoke.Transform:SetPosition(position:Get()) end
    return true
end

local function UpgradeBackpack(player)
    local inventory = player.components.inventory
    if inventory == nil then return false end
    local old = inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if old == nil or old.prefab ~= "backpack" then
        if player.components.talker ~= nil then
            player.components.talker:Say("Bạn cần phải đeo Balo thường lên người đã !")
        end
        return false
    end
    local upgraded = SpawnPrefab("icepack") or SpawnPrefab("insulatedpack")
    if upgraded == nil then return false end
    if old.components.container ~= nil and upgraded.components.container ~= nil then
        inventory:Unequip(EQUIPSLOTS.BODY)
        local moving = {}
        for slot, item in pairs(old.components.container.slots or {}) do table.insert(moving, { slot=slot, item=item }) end
        for _, data in ipairs(moving) do
            local item = old.components.container:RemoveItemBySlot(data.slot)
            if item ~= nil and not upgraded.components.container:GiveItem(item) then inventory:GiveItem(item) end
        end
        inventory:RemoveItem(old, true)
        old:Remove()
    end
    if inventory:GiveItem(upgraded) then
        inventory:Equip(upgraded)
        return true
    end
    upgraded.Transform:SetPosition(player.Transform:GetWorldPosition())
    return true
end

function HHDungeonEffects:UseUtility(use_id, duration)
    local player = self.inst
    if use_id == "dq_dungeon_lamp" then
        local ok = GiveSpawnedItem(player, "lantern", function(item)
            if item.components.fueled ~= nil then item.components.fueled:SetPercent(1) end
        end)
        if ok then
            GiveSpawnedItem(player, "lightbulb", function(item)
                if item.components.stackable ~= nil then
                    item.components.stackable:SetStackSize(40)
                end
            end)
        end
        return ok
    elseif use_id == "dq_weapon_repair" then
        local count = RepairCarried(player, false)
        if count == 0 and player.components.talker ~= nil then player.components.talker:Say("Không có vũ khí hoặc công cụ cần sửa.") end
        return count > 0
    elseif use_id == "dq_armor_repair" then
        local count = RepairCarried(player, true)
        if count == 0 and player.components.talker ~= nil then player.components.talker:Say("Không có giáp cần sửa.") end
        return count > 0
    elseif use_id == "dq_cooldown_charm" then
        local manager = player.components.hh_shadow_manager
        if manager == nil then return false end
        local now = Now()
        manager.arise_ready_time = 0
        manager.recall_ready_time = 0
        manager.swap_ready_time = 0
        for _, data in ipairs(manager.shadows or {}) do
            if not data.is_spawned then data.ready_time = math.min(data.ready_time or 0, now) end
        end
        local sanctuary = player.components.hh_sanctuary
        if sanctuary ~= nil then
            sanctuary.ready_time = 0
            sanctuary:SyncCooldown(now)
        end
        local godslayer = player.components.hh_godslayer
        if godslayer ~= nil then
            godslayer.ready_time = 0
            godslayer:SyncCooldown(now)
        end
        local ruler = player.components.hh_ruler
        if ruler ~= nil then
            ruler.ready_time = 0
            ruler:SyncCooldown(now)
        end
        local king = player.components.hh_king
        if king ~= nil then
            king.ready_time = 0
            king:SyncCooldown(now)
        end
        if manager.SyncCooldowns ~= nil then manager:SyncCooldowns() end
        return true
    elseif use_id == "dq_pickup_charm" then
        return self:AddEffect("utility_pickup", duration or 300)
    elseif use_id == "dq_dungeon_bag" then
        return SpawnDungeonBag(player)
    elseif use_id == "dq_fast_camp" then
        return SpawnCamp(player)
    elseif use_id == "dq_cold_kit" then
        if player.components.temperature ~= nil then player.components.temperature:SetTemperature(40) end
        return self:AddEffect("utility_warm", duration or 240)
    elseif use_id == "dq_heat_kit" then
        if player.components.temperature ~= nil then player.components.temperature:SetTemperature(30) end
        return self:AddEffect("utility_cool", duration or 240)
    elseif use_id == "dq_work_charm" then
        return self:AddEffect("utility_work", duration or 480)
    elseif use_id == "dq_loot_collector" then
        VacuumItems(player, 20, 80)
        return true
    elseif use_id == "dq_container_upgrade" then
        return UpgradeBackpack(player)
    elseif use_id == "dq_dungeon_food" then
        if player.components.health ~= nil then player.components.health:DoDelta(60, false, "dungeon_food") end
        if player.components.hunger ~= nil then player.components.hunger:DoDelta(100) end
        if player.components.sanity ~= nil then player.components.sanity:DoDelta(40) end
        if player.components.hh_mana ~= nil then player.components.hh_mana:DoDelta(40) end
        return true
    elseif use_id == "dq_dungeon_light" then
        return self:AddEffect("utility_light", duration or 600)
    elseif use_id == "dq_durability_charm" then
        return self:AddEffect("utility_durability", duration or 600)
    elseif use_id == "dq_stock_token" then
        if not require("utils/hh_dungeon_authority")(TheWorld) then return false end
        local shop = TheWorld.components.hh_dungeon_shop
        local changed = shop ~= nil and shop:RestockOne() or false
        if changed then player:PushEvent("hh_dungeon_stock_token_used", { use_id=use_id }) end
        return changed
    end
    return false
end

function HHDungeonEffects:Update()
    local now = Now()
    local changed = false
    for effect_id, expires in pairs(self.effects) do
        if expires <= now then
            ApplyHHPlayerKeys(self.inst, effect_id, false)
            self.effects[effect_id] = nil
            changed = true
        end
    end

    if self:IsActive("player_regen") and self.inst.components.health ~= nil then
        self.inst.components.health:DoDelta(1, false, "hh_dungeon_player_regen")
    end
    if self:IsActive("player_sanity") and self.inst.components.sanity ~= nil then
        self.inst.components.sanity:DoDelta(1)
    end
    if self:IsActive("player_mana") and self.inst.components.hh_mana ~= nil then
        self.inst.components.hh_mana:DoDelta(1)
    end
    if self:IsActive("utility_warm") and self.inst.components.temperature ~= nil
        and self.inst.components.temperature:GetCurrent() < 30 then
        self.inst.components.temperature:SetTemperature(30)
    end
    if self:IsActive("utility_cool") and self.inst.components.temperature ~= nil
        and self.inst.components.temperature:GetCurrent() > 45 then
        self.inst.components.temperature:SetTemperature(45)
    end
    local shadows = GetActiveShadows(self)
    if self:IsActive("shadow_regen") then
        for _, shadow in ipairs(shadows) do
            if IsValidLiving(shadow) then
                shadow.components.health:DoDelta(math.max(1, shadow.components.health.maxhealth * .01), false, "hh_dungeon_shadow_regen")
            end
        end
    end
    if self:IsActive("igris_taunt") and now >= self.next_taunt_time then
        self.next_taunt_time = now + 2
        for _, igris in ipairs(shadows) do
            if igris.prefab == "hh_igris_shadow" and IsValidLiving(igris) then
                local x, y, z = igris.Transform:GetWorldPosition()
                local affected = 0
                for _, enemy in ipairs(TheSim:FindEntities(x, y, z, 12, { "_combat", "_health" }, { "player", "companion", "INLIMBO", "notarget" })) do
                    if affected >= 8 then break end
                    if enemy ~= igris and enemy.components.combat ~= nil and enemy.components.combat:CanTarget(igris) then
                        enemy.components.combat:SetTarget(igris)
                        affected = affected + 1
                    end
                end
            end
        end
    end

    self:UpdateLight()
    if changed then
        self:RefreshTargets()
        self:SyncClient()
    end
end

function HHDungeonEffects:OnSave()
    local remaining = {}
    local now = Now()
    for id, expires in pairs(self.effects) do
        if expires > now then remaining[id] = expires - now end
    end
    return { version=self.version, remaining=remaining }
end

function HHDungeonEffects:OnLoad(data)
    local now = Now()
    for id, remaining in pairs(data and data.remaining or {}) do
        local seconds = math.max(0, tonumber(remaining) or 0)
        if seconds > 0 then
            self.effects[id] = now + seconds
            ApplyHHPlayerKeys(self.inst, id, true)
        end
    end
    self:SyncClient()
    self.inst:DoTaskInTime(0, function()
        if self.inst:IsValid() then
            self:RefreshTargets()
            self:SyncClient()
        end
    end)
end

function HHDungeonEffects:OnRemoveFromEntity()
    if self.task ~= nil then self.task:Cancel(); self.task = nil end
    for effect_id in pairs(self.effects) do ApplyHHPlayerKeys(self.inst, effect_id, false) end
    self.effects = {}
    if self.inst.hh_dungeon_effects_client ~= nil then
        self.inst.hh_dungeon_effects_client:set("")
    end
    self:RefreshTargets()
    if self.lightfx ~= nil and self.lightfx:IsValid() then self.lightfx:Remove() end
    self.lightfx = nil
end

return HHDungeonEffects
