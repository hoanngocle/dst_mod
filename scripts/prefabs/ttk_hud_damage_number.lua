local COLOURS = {
    normal = { 1, 1, 1, 1 },
    crit = { 1, 0.55, 0.08, 1 },
    ["true"] = { 0.15, 0.9, 1, 1 },
}
local function format_amount(value)
    value = math.floor((tonumber(value) or 0) + 0.5)
    if value >= 1000000000 then return string.format("%.2fB", value / 1000000000) end
    if value >= 1000000 then return string.format("%.2fM", value / 1000000) end
    if value >= 10000 then return string.format("%.1fK", value / 1000) end
    return tostring(value)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddLabel()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.persists = false
    inst.Label:SetFont(NUMBERFONT)
    inst.Label:SetFontSize(36)
    inst.Label:Enable(true)

    function inst:Display(guid, amount, kind, x, y, z)
        local colour = COLOURS[kind] or COLOURS.normal
        self.Label:SetColour(unpack(colour))
        self.Label:SetFontSize(kind == "crit" and 43 or 36)
        self.Label:SetText(format_amount(amount))
        self.Transform:SetPosition(x or 0, (y or 0) + 2.4, z or 0)
        local target = Ents[guid]
        self._target = target ~= nil and target:IsValid() and target.Transform ~= nil and target or nil
        if self._target ~= nil then
            local tx, _, tz = self._target.Transform:GetWorldPosition()
            self._offset_x, self._offset_z = (x or tx) - tx, (z or tz) - tz
        else
            self._offset_x, self._offset_z = 0, 0
        end
        self:DoPeriodicTask(FRAMES, function(fx)
            if fx._target ~= nil and fx._target:IsValid() and fx._target.Transform ~= nil then
                local tx, ty, tz = fx._target.Transform:GetWorldPosition()
                fx.Transform:SetPosition(tx + fx._offset_x, ty + 2.4, tz + fx._offset_z)
            end
        end)
        self:DoTaskInTime(0.8, self.Remove)
    end
    return inst
end

return Prefab("ttk_hud_damage_number", fn)
