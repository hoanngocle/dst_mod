local assets = {}
local prefabs = { "collapse_small" }

local function LinkPrivateContainer(inst, private)
    private._ttk_llbx = inst
    inst._ttk_private[private._owner_userid] = private
    private.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function GetRewardContainer(inst, player, create)
    local userid = player ~= nil and player.userid or nil
    if type(userid) ~= "string" or userid == "" then return nil end
    local private = inst._ttk_private[userid]
    if private ~= nil and private:IsValid() then return private end
    inst._ttk_private[userid] = nil
    if not create then return nil end
    private = SpawnPrefab("ttk_llbx_container")
    if private == nil then return nil end
    private._owner_userid = userid
    LinkPrivateContainer(inst, private)
    return private
end

local function PrivateContainersEmpty(inst)
    for userid, private in pairs(inst._ttk_private) do
        if private == nil or not private:IsValid() then
            inst._ttk_private[userid] = nil
        elseif not private.components.container:IsEmpty() then
            return false
        end
    end
    return true
end

local function SayLocked(worker, message)
    if worker ~= nil and worker.components ~= nil and worker.components.talker ~= nil then
        worker.components.talker:Say(message)
    end
end

local function OnHammered(inst, worker)
    local rewards = inst.components.ttk_jitan_rewards
    if not inst.components.container:IsEmpty() or not PrivateContainersEmpty(inst) or rewards:HasPending() then
        inst.components.workable:SetWorkLeft(3)
        SayLocked(worker, "Rương còn vật phẩm hoặc phần thưởng chưa nhận.")
        return
    end
    local fx = SpawnPrefab("collapse_small")
    if fx ~= nil then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if fx.SetMaterial ~= nil then fx:SetMaterial("metal") end
    end
    inst:Remove()
end

local function OnOpen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function OnClose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function OnSave(inst, data)
    data.ttk_private_containers = {}
    for _, private in pairs(inst._ttk_private) do
        if private ~= nil and private:IsValid() then
            local record = private:GetSaveRecord()
            if record ~= nil then table.insert(data.ttk_private_containers, record) end
        end
    end
end

local function OnLoad(inst, data)
    for _, record in ipairs(data ~= nil and data.ttk_private_containers or {}) do
        local private = SpawnSaveRecord(record)
        if private ~= nil and type(private._owner_userid) == "string" then
            LinkPrivateContainer(inst, private)
        elseif private ~= nil then
            private:Remove()
        end
    end
end

local function OnRemove(inst)
    inst.components.ttk_jitan_rewards:BackupToAuthorities(inst._ttk_private)
    for _, private in pairs(inst._ttk_private) do
        if private ~= nil and private:IsValid() then private:Remove() end
    end
end

local function RelinkAuthorities(inst)
    if not inst:IsValid() then return end
    local x, y, z = inst.Transform:GetWorldPosition()
    for _, altar in ipairs(TheSim:FindEntities(x, y, z, 32, { "ttk_jitan" })) do
        local trial = altar.components ~= nil and altar.components.ttk_jitan_trial or nil
        if trial ~= nil then
            inst.components.ttk_jitan_rewards:SetAuthority(trial.altar_id, trial)
            trial:FlushRewardBackups(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .7)
    inst.AnimState:SetBank("xd_llbx")
    inst.AnimState:SetBuild("xd_llbx")
    inst.AnimState:PlayAnimation("closed")
    inst.MiniMapEntity:SetIcon("ttk_llbx.tex")
    inst:AddTag("structure")
    inst:AddTag("ttk_llbx")
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ttk_llbx")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
    inst:AddComponent("ttk_jitan_rewards")
    inst._ttk_private = {}
    inst.GetRewardContainer = GetRewardContainer

    inst.components.container.Open = function(container, doer)
        if not inst.components.ttk_jitan_rewards:CanUse(doer) then return false end
        -- A rebuilt chest can recover the nearby altar's persisted queue on
        -- first use; the player does not need to submit another offering.
        RelinkAuthorities(inst)
        inst.components.ttk_jitan_rewards:Claim(doer)
        local private = inst:GetRewardContainer(doer, true)
        if private == nil then return false end
        private.components.container:Open(doer)
        return true
    end
    inst.CanUse = function(_, player)
        return inst.components.ttk_jitan_rewards:CanUse(player)
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst:ListenForEvent("onremove", OnRemove)
    inst:DoTaskInTime(0, RelinkAuthorities)
    MakeSnowCovered(inst)
    MakeHauntableWork(inst)
    return inst
end

local function privatefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    inst:AddTag("ttk_llbx_private")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.persists = false
    inst:AddComponent("container")
    -- A separate widget contract keeps facade insertion disabled while these
    -- hidden per-user compartments accept queued reward items.
    inst.components.container:WidgetSetup("ttk_llbx_private")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipopensnd = true
    inst.components.container.skipclosesnd = true
    local Open = inst.components.container.Open
    inst.components.container.Open = function(container, doer)
        if doer == nil or doer.userid ~= inst._owner_userid then return false end
        Open(container, doer)
        return true
    end
    inst.OnSave = function(private, data) data.owner_userid = private._owner_userid end
    inst.OnLoad = function(private, data)
        private._owner_userid = data ~= nil and data.owner_userid or nil
    end
    return inst
end

return Prefab("ttk_llbx", fn, assets, prefabs),
    Prefab("ttk_llbx_container", privatefn, assets, prefabs),
    MakePlacer("ttk_llbx_placer", "xd_llbx", "xd_llbx", "closed")
