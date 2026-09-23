-- Optional compatibility with an already installed Solo component.
local M = {}

function M.SetBase(inst, base)
    inst.components.weapon:SetDamage(base)
    local s = inst.components.wb_strengthen
    local status = s ~= nil and s.buffs_status and s.buffs_status.damage
    local config = s ~= nil and s.BUFFS_CONFIG and s.BUFFS_CONFIG.damage
    if status and config and config.update_fn ~= nil then
        -- UpdateBuff also re-equips the item. Native state changes only need
        -- damage recalculation, especially for summoned weapons.
        config.update_fn(inst, s.level, status, config)
    end
end

function M.ForwardAttack(inst, attacking, attacker, target, projectile)
    if inst._ttk_forwarding_attack then return end
    local carrier = inst.components.weapon
    local s = inst.components.wb_strengthen
    local loaded = package.loaded["components/wb_strengthen"]
    local configs = s ~= nil and s.BUFFS_CONFIG or loaded and loaded.BUFFS_CONFIG
    local statuses = s ~= nil and s.buffs_status
        or inst._ttk_banner_strengthen and inst._ttk_banner_strengthen.buffs_status
    local callbacks = carrier ~= nil and carrier.__onattackfn_map or nil
    if callbacks == nil and inst._ttk_banner_attack_buffs ~= nil and configs ~= nil then
        callbacks = {}
        for id in pairs(inst._ttk_banner_attack_buffs) do
            local cfg = configs[id]
            if cfg ~= nil then callbacks[id] = cfg.onattackfn end
        end
    end
    if callbacks == nil or statuses == nil or configs == nil then return end
    local get_damage = carrier ~= nil and carrier.GetDamage
    if carrier == nil then
        inst.components.weapon = {
            damage = inst._ttk_banner_damage,
            GetDamage = function(_, ...) return attacking:GetDamage(...) end,
        }
    elseif carrier ~= attacking then
        carrier.GetDamage = function(_, ...) return attacking:GetDamage(...) end
    end
    inst._ttk_forwarding_attack = true
    local ok, err = pcall(function()
        for id, fn in pairs(callbacks) do
            local status, cfg = statuses[id], configs[id]
            if type(fn) == "function" and status ~= nil and cfg ~= nil then
                fn(inst, status.level, status, cfg, attacker, target, projectile)
            end
        end
    end)
    inst._ttk_forwarding_attack = nil
    inst.components.weapon = carrier
    if carrier ~= nil then carrier.GetDamage = get_damage end
    if not ok then error(err, 0) end
end

function M.InstallCommandFilter(combat)
    local attack = combat.DoAttack
    combat.DoAttack = function(self, target, weapon, projectile, ...)
        local held = weapon or self:GetWeapon()
        if projectile == nil and held ~= nil and held._ttk_attack_command ~= nil then
            target = target or self.target
            if target ~= nil and target:IsValid() and self:CanHitTarget(target, held) then
                held._ttk_attack_command(held, self.inst, target)
            end
            return
        end
        return attack(self, target, weapon, projectile, ...)
    end
end

return M
