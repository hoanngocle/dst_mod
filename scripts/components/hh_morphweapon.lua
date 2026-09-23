local HhMorphWeapon = Class(function(self, inst)
    self.inst = inst
    self.current_mode = "sword"
    self.modes = {
        sword = { name = STRINGS.NAMES.HH_DAOGAM6_SWORD or "Tà Thuật Đen - Vũ Khí", symbol = "sword", action = nil, base_damage = 80 },
        axe = { name = STRINGS.NAMES.HH_DAOGAM6_AXE or "Tà Thuật Đen - Rìu", symbol = "axe", action = ACTIONS.CHOP, base_damage = 50 },
        pickaxe = {
            name = STRINGS.NAMES.HH_DAOGAM6_PICKAXE or "Tà Thuật Đen - Cúp",
            symbol = "pickaxe",
            action = ACTIONS.MINE,
            base_damage = 50,
            effectiveness = TUNING.MULTITOOL_AXE_PICKAXE_EFFICIENCY,
            tough_work = true,
        },
        shovel = { name = STRINGS.NAMES.HH_DAOGAM6_SHOVEL or "Tà Thuật Đen - Xẻng", symbol = "shovel", action = ACTIONS.DIG, base_damage = 50 },
        hoe = { name = STRINGS.NAMES.HH_DAOGAM6_HOE or "Tà Thuật Đen - Cuốc", symbol = "hoe", action = nil, is_hoe = true, base_damage = 50 },
    }
end)

function HhMorphWeapon:GetBaseDamage(mode)
    local data = self.modes[mode or self.current_mode]
    return data and data.base_damage or nil
end

function HhMorphWeapon:GetCurrentBaseDamage()
    return self:GetBaseDamage(self.current_mode)
end

function HhMorphWeapon:GetStrengthenBaseDamage()
    return self.modes.sword.base_damage
end

function HhMorphWeapon:OnSave()
    return { current_mode = self.current_mode }
end

function HhMorphWeapon:OnLoad(data)
    if data and data.current_mode then
        self:SetMode(data.current_mode)
    end
end

function HhMorphWeapon:SetMode(mode)
    local data = self.modes[mode]
    if not data then return end
    self.current_mode = mode

    -- Clean up previous components
    self.inst:RemoveComponent("tool")
    self.inst:RemoveComponent("farmtiller")

    -- Add relevant component
    if data.action then
        self.inst:AddComponent("tool")
        self.inst.components.tool:SetAction(data.action, data.effectiveness or 1)
        if data.tough_work then
            self.inst.components.tool:EnableToughWork(true)
        end
    elseif data.is_hoe then
        self.inst:AddComponent("farmtiller")
    end

    if self.inst.components.weapon then
        local handled_by_strengthen = false
        local strengthen = self.inst.components.wb_strengthen
        if strengthen and strengthen.SetMorphModeBaseDamage then
            handled_by_strengthen = strengthen:SetMorphModeBaseDamage(data.base_damage) == true
        end
        if not handled_by_strengthen then
            self.inst.components.weapon:SetDamage(data.base_damage)
        end
    end

    -- Update Name
    if self.inst.components.named then
        self.inst.components.named:SetName(data.name)
    end

    -- Update Image
    if self.inst.components.inventoryitem then
        self.inst.components.inventoryitem:ChangeImageName("hh_daogam6_" .. mode)
    end

    -- Update Equippable visuals if held
    if self.inst.components.equippable and self.inst.components.equippable:IsEquipped() then
        local owner = self.inst.components.inventoryitem.owner
        if owner and owner.AnimState then
            owner.AnimState:OverrideSymbol("swap_object", "hh_daogam6", data.symbol)
        end
    end
end

function HhMorphWeapon:Target(doer, target, pos)
    if not target then
        if pos then
            local tile = TheWorld.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
            if tile == WORLD_TILES.FARMING_SOIL then
                self:SetMode("hoe")
            else
                self:SetMode("sword")
            end
        else
            self:SetMode("sword")
        end
        return true
    end

    if target.prefab == "farm_soil" then
        self:SetMode("hoe")
        return true
    end

    if not target.components.workable then
        self:SetMode("sword")
        return true
    end

    local action = target.components.workable:GetWorkAction()
    if action == ACTIONS.CHOP then
        self:SetMode("axe")
    elseif action == ACTIONS.MINE then
        self:SetMode("pickaxe")
    elseif action == ACTIONS.DIG then
        self:SetMode("shovel")
    elseif action == ACTIONS.TILL then
        self:SetMode("hoe")
    else
        self:SetMode("sword")
    end

    return true
end

return HhMorphWeapon
