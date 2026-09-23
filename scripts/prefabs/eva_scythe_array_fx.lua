local Common = require "util/eva_scythe_array_common"
local SkillDamage = require "util/eva_skill_damage"

local assets = {
    Asset("ANIM", "anim/eva_scythe.zip"),
    Asset("ANIM", "anim/wagdrone_laserwire_fx.zip"),
    Asset("ANIM", "anim/wagboss_beam.zip"),
}

local function AddFxTags(inst)
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
end

local function MakeScytheFx(name, scale)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        AddFxTags(inst)
        inst.AnimState:SetBank("eva_scythe")
        inst.AnimState:SetBuild("eva_scythe")
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetMultColour(0.84, 0.7, 1, 1)
        inst.AnimState:SetLightOverride(0.55)
        inst.Transform:SetScale(scale, scale, scale)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        inst.persists = false
        return inst
    end
    return Prefab(name, fn, assets)
end

local function edge_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    inst.AnimState:SetBank("wagdrone_laserwire_fx")
    inst.AnimState:SetBuild("wagdrone_laserwire_fx")
    inst.AnimState:PlayAnimation("beam_1", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetMultColour(0.72, 0.48, 1, 0.8)
    inst.AnimState:SetLightOverride(0.8)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    function inst:SetEdge(x1, z1, x2, z2)
        local dx, dz = x2 - x1, z2 - z1
        local length = math.sqrt(dx * dx + dz * dz)
        self.Transform:SetPosition((x1 + x2) / 2, 0, (z1 + z2) / 2)
        self.Transform:SetRotation(math.atan2(-dz, dx) * RADIANS)
        self.AnimState:SetScale(length / 2, 1)
    end
    return inst
end

local function beam_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    AddFxTags(inst)
    inst.AnimState:SetBank("wagboss_beam")
    inst.AnimState:SetBuild("wagboss_beam")
    inst.AnimState:PlayAnimation("beam_pre")
    inst.AnimState:PushAnimation("beam_loop", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetMultColour(0.7, 0.45, 1, 0.9)
    inst.AnimState:SetLightOverride(0.5)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetFalloff(0.95)
    inst.Light:SetColour(0.45, 0.2, 1)
    inst.Light:SetRadius(3)
    inst.Light:Enable(true)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    inst.SoundEmitter:PlaySound("rifts5/wagstaff_boss/beam_up")
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
    inst.vertices = nil
    inst.tasks = {}
    inst.rooted_targets = {}
    inst.fx = {}
    inst.stopped = false

    local function RemoveEntity(entity)
        if entity ~= nil and entity:IsValid() then entity:Remove() end
    end

    function inst:_TrackFx(fx)
        if fx ~= nil then self.fx[fx] = true end
        return fx
    end

    function inst:_SpawnAt(name, x, z)
        local fx = self:_TrackFx(SpawnPrefab(name))
        if fx ~= nil then fx.Transform:SetPosition(x, 0, z) end
        return fx
    end

    function inst:_ReleaseTarget(target)
        local rooted = target ~= nil and target.components ~= nil
            and target.components.rooted or nil
        if rooted ~= nil then rooted:RemoveSource(self) end
        self.rooted_targets[target] = nil
    end

    function inst:_RefreshRoots()
        if self.stopped or not Common.CanOwnerRemain(self.owner) then
            self:Stop("invalid_owner")
            if self:IsValid() then self:Remove() end
            return
        end
        local keep = {}
        for _, target in ipairs(Common.FindTargetsAt(
                self.owner, self.center_x, self.center_z, Common.PENTAGON_RADIUS)) do
            local tx, _, tz = target.Transform:GetWorldPosition()
            if target.components.locomotor ~= nil
                and Common.PointInPentagon(tx, tz, self.vertices) then
                if target.components.rooted == nil then target:AddComponent("rooted") end
                target.components.rooted:AddSource(self)
                self.rooted_targets[target] = true
                keep[target] = true
            end
        end
        for target in pairs(self.rooted_targets) do
            if not keep[target] then self:_ReleaseTarget(target) end
        end
    end

    function inst:_Damage(amount, cause)
        if self.stopped or not Common.CanOwnerRemain(self.owner) then return end
        for _, target in ipairs(Common.FindTargetsAt(
                self.owner, self.center_x, self.center_z, Common.DAMAGE_RADIUS)) do
            SkillDamage.Apply(self.owner, target, amount, cause)
        end
    end

    function inst:_SpawnPerimeter()
        for index = 1, 5 do
            local current = self.vertices[index]
            local following = self.vertices[index % 5 + 1]
            local edge = self:_TrackFx(SpawnPrefab("eva_scythe_array_edge_fx"))
            if edge ~= nil and edge.SetEdge ~= nil then
                edge:SetEdge(current[1], current[2], following[1], following[2])
            end
        end
    end

    function inst:Start(owner, x, z)
        if self.owner ~= nil or not Common.CanOwnerRemain(owner) then return false end
        self.owner = owner
        self.center_x = x
        self.center_z = z
        self.vertices = Common.BuildVertices(x, z)
        self.Transform:SetPosition(x, 0, z)
        for index, vertex in ipairs(self.vertices) do
            local fx = self:_SpawnAt("eva_scythe_array_small_scythe_fx", vertex[1], vertex[2])
            if fx ~= nil then fx.Transform:SetRotation((index - 1) * 72) end
        end
        self._onownerdeath = function() self:Stop("death"); if self:IsValid() then self:Remove() end end
        self._onownerghost = function() self:Stop("ghost"); if self:IsValid() then self:Remove() end end
        self._onownerremove = function() self:Stop("owner_removed"); if self:IsValid() then self:Remove() end end
        self:ListenForEvent("death", self._onownerdeath, owner)
        self:ListenForEvent("ms_becameghost", self._onownerghost, owner)
        self:ListenForEvent("onremove", self._onownerremove, owner)

        self.tasks.roots = self:DoPeriodicTask(Common.ROOT_PERIOD,
            function() self:_RefreshRoots() end, Common.ROOT_START)
        self.tasks.center = self:DoTaskInTime(Common.CENTER_SCYTHE_TIME, function()
            self:_SpawnPerimeter()
            self:_SpawnAt("eva_scythe_array_center_scythe_fx", self.center_x, self.center_z)
        end)
        self.tasks.strike = self:DoTaskInTime(Common.STRIKE_TIME, function()
            self:_SpawnAt("eva_scythe_array_beam_fx", self.center_x, self.center_z)
            self:_Damage(Common.STRIKE_DAMAGE, "eva_scythe_array_strike")
        end)
        for pulse = 1, Common.BEAM_PULSES - 1 do
            local delay = Common.BEAM_FIRST_HIT + (pulse - 1) * Common.BEAM_PERIOD
            self.tasks["beam_" .. tostring(pulse)] = self:DoTaskInTime(delay, function()
                self:_Damage(Common.BEAM_DAMAGE, "eva_scythe_array_beam")
            end)
        end
        self.tasks.terminal = self:DoTaskInTime(Common.FINISH_TIME, function()
            self:_Damage(Common.BEAM_DAMAGE, "eva_scythe_array_beam")
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
        for target in pairs(self.rooted_targets) do self:_ReleaseTarget(target) end
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

return Prefab("eva_scythe_array_controller", controller_fn, nil, {
        "eva_scythe_array_small_scythe_fx", "eva_scythe_array_center_scythe_fx",
        "eva_scythe_array_edge_fx", "eva_scythe_array_beam_fx",
    }),
    MakeScytheFx("eva_scythe_array_small_scythe_fx", 1.35),
    MakeScytheFx("eva_scythe_array_center_scythe_fx", 3.4),
    Prefab("eva_scythe_array_edge_fx", edge_fn, assets),
    Prefab("eva_scythe_array_beam_fx", beam_fn, assets)
