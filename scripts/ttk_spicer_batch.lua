local cooking = require("cooking")
return function(inst)
    local stewer, container = inst.components.stewer, inst.components.container
    local start = stewer.StartCooking
    stewer.StartCooking = function(self, doer, ...)
        if self:IsCooking() or self:IsDone() or not container:IsFull()
            or inst:HasTag("burnt") then return false end
        if doer ~= nil and (not doer:IsValid() or doer:HasTag("playerghost")) then return false end
        local ingredients, count = {}, 120
        for slot = 1, container:GetNumSlots() do
            local item = container:GetItemInSlot(slot)
            if item == nil or not container:CanTakeItemInSlot(item, slot) then return false end
            ingredients[#ingredients + 1] = item.prefab
            count = math.min(count, item.components.stackable ~= nil and item.components.stackable:StackSize() or 1)
        end
        local product = cooking.CalculateRecipe(inst.prefab, ingredients)
        if product == nil or cooking.GetRecipe(inst.prefab, product) == nil then return false end
        self._ttk_batch = math.max(1, math.floor(count))
        inst._ttk_consuming_batch = true
        start(self, doer, ...)
        inst._ttk_consuming_batch = nil
        return self:IsCooking()
    end
    local destroy = container.DestroyContents
    container.DestroyContents = function(self, ...)
        if not inst._ttk_consuming_batch then return destroy(self, ...) end
        -- Iterate fixed slots: removing a stack mutates container.slots.
        for slot = 1, self:GetNumSlots() do
            local item = self:GetItemInSlot(slot)
            if item ~= nil then
                if item.components.stackable ~= nil then
                    item.components.stackable:Get(stewer._ttk_batch):Remove()
                else item:Remove() end
            end
        end
    end
    local harvest = stewer.Harvest
    stewer.Harvest = function(self, harvester, ...)
        if not self.done or self.product == nil then return harvest(self, harvester, ...) end
        local product, count = self.product, self._ttk_batch or 1
        local recipe = cooking.GetRecipe(inst.prefab, product)
        local amount = recipe ~= nil and recipe.stacksize or 1
        local freshness = self.spoiltime ~= nil and self.spoiltime > 0 and self.product_spoilage ~= nil
            and self.product_spoilage * self:GetTimeToSpoil() / self.spoiltime or nil
        self._ttk_batch = nil
        local result = harvest(self, harvester, ...)
        if result then
            for _ = 2, count do
                local loot = SpawnPrefab(product)
                if loot ~= nil then
                    if loot.components.stackable ~= nil then loot.components.stackable:SetStackSize(amount) end
                    if freshness ~= nil and loot.components.perishable ~= nil then
                        loot.components.perishable:SetPercent(math.clamp(freshness, 0, 1))
                        loot.components.perishable:StartPerishing()
                    end
                    if harvester ~= nil and harvester.components.inventory ~= nil then
                        harvester.components.inventory:GiveItem(loot, nil, inst:GetPosition())
                    else LaunchAt(loot, inst, nil, 1, 1) end
                end
            end
        end
        return result
    end
    local save, load = stewer.OnSave, stewer.OnLoad
    stewer.OnSave = function(self, ...)
        local data = save(self, ...) or {}
        data.ttk_batch = self._ttk_batch
        return data
    end
    stewer.OnLoad = function(self, data, ...)
        load(self, data or {}, ...)
        self._ttk_batch = data ~= nil and math.clamp(math.floor(tonumber(data.ttk_batch) or 1), 1, 120) or 1
    end
end
