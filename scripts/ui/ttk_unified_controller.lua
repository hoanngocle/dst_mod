local UnifiedController = Class(function(self, factories)
    self.factories = factories or {}
    self.panels = {}
    self.panel_order = {}
    self.active_id = nil
    self.active_panel = nil
    self.native_generation = 0
    self.native_closer = nil
    self.native_open = false
    self.disposed = false
end)

function UnifiedController:GetPanel(id)
    local panel = self.panels[id]
    if panel == nil and self.factories[id] ~= nil then
        panel = self.factories[id]()
        self.panels[id] = panel
        table.insert(self.panel_order, id)
    end
    return panel
end

function UnifiedController:Show(id)
    if self.disposed or id == self.active_id or self.factories[id] == nil then
        return false
    end

    self.native_generation = self.native_generation + 1
    if self.active_panel ~= nil and self.active_panel.HidePanel ~= nil then
        self.active_panel:HidePanel()
    end

    self.active_id = id
    self.active_panel = self:GetPanel(id)
    if self.active_panel ~= nil and self.active_panel.ShowPanel ~= nil then
        self.active_panel:ShowPanel()
    end
    return true
end

function UnifiedController:BeginNativeOpen(panel_id, prefab)
    self.native_generation = self.native_generation + 1
    return {
        generation = self.native_generation,
        panel_id = panel_id,
        prefab = prefab,
    }
end

function UnifiedController:CancelNativeOpen()
    self.native_generation = self.native_generation + 1
end

function UnifiedController:AcceptNativeOpen(token, panel_id, prefab)
    return not self.disposed
        and token ~= nil
        and token.generation == self.native_generation
        and token.panel_id == panel_id
        and token.prefab == prefab
        and self.active_id == panel_id
end

function UnifiedController:SetNativeCloser(closer)
    self.native_closer = closer
    self.native_open = closer ~= nil
end

function UnifiedController:NativeClosed()
    local had_native = self.native_open or self.native_closer ~= nil
    self.native_open = false
    self.native_closer = nil
    self.native_generation = self.native_generation + 1
    return had_native
end

function UnifiedController:CloseNative()
    if not self.native_open then
        return false
    end
    self.native_open = false
    local closer = self.native_closer
    self.native_closer = nil
    if closer ~= nil then
        closer()
    end
    return true
end

function UnifiedController:Dispose()
    if self.disposed then
        return
    end
    self.disposed = true
    self.native_generation = self.native_generation + 1
    self:CloseNative()

    if self.active_panel ~= nil and self.active_panel.HidePanel ~= nil then
        self.active_panel:HidePanel()
    end
    for _, id in ipairs(self.panel_order) do
        local panel = self.panels[id]
        if panel ~= nil and panel.DisposePanel ~= nil then
            panel:DisposePanel()
        end
    end
    self.active_id = nil
    self.active_panel = nil
end

return UnifiedController
