local VALID_PLANTS = {
    ttk_plant_hsc = true,
    ttk_plant_dms = true,
    ttk_plant_qfx = true,
    ttk_plant_cyh = true,
    ttk_plant_lmg = true,
    ttk_plant_yhh = true,
}

local function OnCrop(self, crop, old)
    if crop ~= nil then
        self.inst.AnimState:PlayAnimation("idle_full", true)
        self.inst:RemoveTag("ttk_ylxq_grower")
    elseif old ~= nil then
        self.inst.AnimState:PlayAnimation("idle", true)
        self.inst:AddTag("ttk_ylxq_grower")
    end
end

local Grower = Class(function(self, inst)
    self.inst = inst
    self.crop = nil
    self.current = 0
    self.max = 100
    inst:AddTag("ttk_ylxq_grower")
    inst:AddTag("ttk_ylxq_chargeable")
    inst:WatchWorldState("cycles", function()
        self:AddCharge(-1)
    end)
end, nil, {crop = OnCrop})

local function SetCrop(self, crop)
    if crop == nil then return false end
    self.crop = crop
    crop.persists = false
    crop._ttk_ylxq = self.inst
    if crop.Follower == nil then
        crop.entity:AddFollower()
    end
    crop.Follower:FollowSymbol(self.inst.GUID, "plant", 0, 0, 0, true)
    if crop.components.herdmember ~= nil then
        crop.components.herdmember:Enable(false)
    end
    crop:ListenForEvent("onremove", function()
        if self.crop == crop then self.crop = nil end
    end)
    crop:ListenForEvent("ttk_lingqi_delta", function()
        if crop.OnCheckGrowing ~= nil then crop:OnCheckGrowing() end
    end, self.inst)
    if crop.OnCheckGrowing ~= nil then crop:OnCheckGrowing() end
    return true
end

function Grower:OnRemoveFromEntity()
    self.inst:RemoveTag("ttk_ylxq_grower")
    self.inst:RemoveTag("ttk_ylxq_chargeable")
end

function Grower:AddCharge(amount)
    amount = tonumber(amount) or 0
    local old = self.current
    self.current = math.clamp(old + amount, 0, self.max)
    if self.current >= self.max then
        self.inst:RemoveTag("ttk_ylxq_chargeable")
    else
        self.inst:AddTag("ttk_ylxq_chargeable")
    end
    if self.current ~= old then
        self.inst:PushEvent("ttk_lingqi_delta", {current = self.current, old = old})
        return true
    end
    return false
end

function Grower:IsEmpty()
    return self.crop == nil
end

function Grower:PlantItem(item, doer)
    if not self:IsEmpty() or item == nil or not item:IsValid() or not item:HasTag("ttk_lc_seed") then
        return false
    end
    local plant_prefab = item.ttk_lc_plant
    if type(plant_prefab) ~= "string" or not VALID_PLANTS[plant_prefab] then
        return false
    end
    local plant = SpawnPrefab(plant_prefab)
    if plant == nil then return false end
    plant:PushEvent("on_planted", {doer = doer, seed = item})
    if plant.SoundEmitter ~= nil then
        plant.SoundEmitter:PlaySound("dontstarve/common/plant")
    end
    if not SetCrop(self, plant) then
        plant:Remove()
        return false
    end
    if type(TUNING.AddItemPermission) == "function" and doer ~= nil then
        TUNING.AddItemPermission(plant, doer)
    end
    if item.components.stackable ~= nil then
        item.components.stackable:Get():Remove()
    else
        item:Remove()
    end
    TheWorld:PushEvent("itemplanted", {doer = doer, pos = self.inst:GetPosition()})
    return true
end

function Grower:DoDrop()
    if self.crop ~= nil and self.crop:IsValid() then
        if self.crop.components.lootdropper ~= nil then
            self.crop.components.lootdropper:SpawnLootPrefab(self.crop.ttk_primary_product or "seeds")
        end
        self.crop:Remove()
    end
end

function Grower:OnSave()
    local data = {current = self.current}
    if self.crop ~= nil and self.crop:IsValid() then
        data.crop = self.crop:GetSaveRecord()
    end
    return data
end

function Grower:OnLoad(data, newents)
    if data == nil then return end
    self.current = math.clamp(tonumber(data.current) or 0, 0, self.max)
    if self.current >= self.max then
        self.inst:RemoveTag("ttk_ylxq_chargeable")
    else
        self.inst:AddTag("ttk_ylxq_chargeable")
    end
    if data.crop ~= nil then
        local crop = SpawnSaveRecord(data.crop, newents)
        if crop ~= nil then SetCrop(self, crop) end
    end
end

return Grower
