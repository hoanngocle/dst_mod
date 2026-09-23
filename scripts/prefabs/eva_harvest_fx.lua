local Common = require "util/eva_harvest_common"

local assets = {
    Asset("ANIM", "anim/tornado.zip"),
}

local function AddFxTags(inst)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
end

local function vortex_fx_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    inst.AnimState:SetBank("tornado")
    inst.AnimState:SetBuild("tornado")
    inst.AnimState:PlayAnimation("tornado_pre")
    inst.AnimState:PushAnimation("tornado_loop", true)
    inst.AnimState:SetMultColour(0.72, 0.58, 1, 0.78)
    inst.AnimState:SetLightOverride(0.45)
    inst.Transform:SetScale(0.72, 0.72, 0.72)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    return inst
end

local function controller_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    AddFxTags(inst)
    inst.persists = false
    inst.owner = nil
    inst.owner_component = nil
    inst.center_x = nil
    inst.center_z = nil
    inst.tasks = {}
    inst.fx = {}
    inst.stopped = false
    inst.petal_index = 0

    local function RemoveEntity(entity)
        if entity ~= nil and entity.IsValid ~= nil and entity:IsValid() then entity:Remove() end
    end

    function inst:_TrackFx(fx)
        if fx ~= nil then self.fx[fx] = true end
        return fx
    end

    function inst:_StopIfOwnerInvalid()
        if self.stopped then return true end
        if Common.CanOwnerRemain(self.owner) then return false end
        self:Stop("invalid_owner")
        if self:IsValid() then self:Remove() end
        return true
    end

    function inst:_HarvestPulse()
        if self:_StopIfOwnerInvalid() then return end
        for _, target in ipairs(Common.FindHarvestables(self.center_x, self.center_z)) do
            if target ~= nil and target.IsValid ~= nil and target:IsValid() then
                Common.HarvestEntity(self.owner, target)
            end
        end
    end

    function inst:_PullPulse()
        if self:_StopIfOwnerInvalid() then return end
        for _, item in ipairs(Common.FindPullItems(self.center_x, self.center_z)) do
            if item ~= nil and item.IsValid ~= nil and item:IsValid() then
                Common.PullItemStep(item, self.center_x, self.center_z)
            end
        end
    end

    function inst:_PetalPulse()
        if self:_StopIfOwnerInvalid() then return end
        self.petal_index = self.petal_index + 1
        local angle = self.petal_index * 2.3999632297287
        local radius = 1.5 + self.petal_index % 4 * 0.75
        local fx = self:_TrackFx(SpawnPrefab("rose_petals_fx"))
        if fx ~= nil then
            fx.Transform:SetPosition(
                self.center_x + math.cos(angle) * radius, 0,
                self.center_z + math.sin(angle) * radius)
            local silver = self.petal_index % 2 == 0
            if fx.AnimState ~= nil then
                if silver then
                    fx.AnimState:SetMultColour(0.84, 0.86, 1, 0.82)
                else
                    fx.AnimState:SetMultColour(0.65, 0.38, 1, 0.82)
                end
            end
        end
    end

    function inst:Start(owner, x, z)
        if self.owner ~= nil then return false end
        local valid = Common.ValidateCenter(owner, x, z)
        if not valid or not Common.CanOwnerRemain(owner) then return false end

        self.owner = owner
        self.center_x = x
        self.center_z = z
        self.Transform:SetPosition(x, 0, z)

        local vortex = self:_TrackFx(SpawnPrefab("eva_harvest_vortex_fx"))
        if vortex ~= nil then vortex.Transform:SetPosition(x, 0, z) end

        self._onownerdeath = function()
            self:Stop("death")
            if self:IsValid() then self:Remove() end
        end
        self._onownerghost = function()
            self:Stop("ghost")
            if self:IsValid() then self:Remove() end
        end
        self._onownerremove = function()
            self:Stop("owner_removed")
            if self:IsValid() then self:Remove() end
        end
        self:ListenForEvent("death", self._onownerdeath, owner)
        self:ListenForEvent("ms_becameghost", self._onownerghost, owner)
        self:ListenForEvent("onremove", self._onownerremove, owner)

        self.tasks.harvest = self:DoPeriodicTask(
            Common.HARVEST_PERIOD, function() self:_HarvestPulse() end, 0)
        self.tasks.pull = self:DoPeriodicTask(
            Common.PULL_PERIOD, function() self:_PullPulse() end, 0)
        self.tasks.petals = self:DoPeriodicTask(0.7, function() self:_PetalPulse() end, 0)
        self.tasks.terminal = self:DoTaskInTime(Common.DURATION, function()
            self:Stop("expired")
            if self:IsValid() then self:Remove() end
        end)
        return true
    end

    function inst:Stop()
        if self.stopped then return false end
        self.stopped = true
        for key, task in pairs(self.tasks) do
            if task ~= nil then task:Cancel() end
            self.tasks[key] = nil
        end
        for fx in pairs(self.fx) do
            RemoveEntity(fx)
            self.fx[fx] = nil
        end
        local owner = self.owner
        if owner ~= nil then
            self:RemoveEventCallback("death", self._onownerdeath, owner)
            self:RemoveEventCallback("ms_becameghost", self._onownerghost, owner)
            self:RemoveEventCallback("onremove", self._onownerremove, owner)
        end
        self.owner = nil
        return true
    end

    inst.OnRemoveEntity = function(self)
        self:Stop("removed")
        local component = self.owner_component
        self.owner_component = nil
        if component ~= nil then component:_OnControllerRemoved(self) end
    end
    return inst
end

return Prefab("eva_harvest_controller", controller_fn, nil, {
        "eva_harvest_vortex_fx", "rose_petals_fx",
    }),
    Prefab("eva_harvest_vortex_fx", vortex_fx_fn, assets)
