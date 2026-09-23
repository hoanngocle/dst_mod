local function update(inst)
    -- HUD widgets consume the replicated values directly.
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.persists = false
    inst.Transform:SetPosition(0, 2.35, 0)

    inst._current = net_float(inst.GUID, "ttk_hud.overhead.current", "ttk_hud_overhead_dirty")
    inst._maximum = net_float(inst.GUID, "ttk_hud.overhead.maximum", "ttk_hud_overhead_dirty")
    inst._visible = net_bool(inst.GUID, "ttk_hud.overhead.visible", "ttk_hud_overhead_dirty")
    inst:ListenForEvent("ttk_hud_overhead_dirty", update)
    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        local proxies = rawget(_G, "TTK_HUD_OVERHEAD_PROXIES")
        if proxies == nil then
            proxies = setmetatable({}, { __mode = "k" })
            rawset(_G, "TTK_HUD_OVERHEAD_PROXIES", proxies)
        end
        proxies[inst] = true
        inst:ListenForEvent("onremove", function() proxies[inst] = nil end)
    end

    if not TheWorld.ismastersim then
        return inst
    end

    function inst:Refresh()
        local health = self._parent ~= nil and self._parent.components.health or nil
        if health == nil then self:Remove() return end
        self._current:set(math.max(0, health.currenthealth))
        self._maximum:set(math.max(1, health.maxhealth))
        self._visible:set(true)
        if self._hide_task ~= nil then self._hide_task:Cancel() end
        self._hide_task = self:DoTaskInTime(8, function(proxy) proxy._visible:set(false) end)
    end
    return inst
end

return Prefab("ttk_hud_overhead_proxy", fn)
