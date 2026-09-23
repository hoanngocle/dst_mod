-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/sporecloud.zip")),
    Asset("ANIM", Boss.ArtPath("anim/sporecloud_base.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_spiderqueen_cloud.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_spiderqueen_cloud_base.zip")),
}
local prefabs =
{
    "ttk_boss_spiderqueen_cloud_overlay",
}
local FADE_FRAMES = 5
local FADE_INTENSITY = .8
local FADE_RADIUS = 1
local FADE_FALLOFF = .5
local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end
    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
end
local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end
local function FadeOut(inst)
    inst._fade:set(FADE_FRAMES + 1)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
end
local function FadeInImmediately(inst)
    inst._fade:set(FADE_FRAMES)
    OnFadeDirty(inst)
end
local function FadeOutImmediately(inst)
    inst._fade:set(FADE_FRAMES * 2 + 1)
    OnFadeDirty(inst)
end
local OVERLAY_COORDS =
{
    { 0,0,0,               1 },
    { 5/2,0,0,             0.8, 0 },
    { 2.5/2,0,-4.330/2,    0.8 , 5/3*180 },
    { -2.5/2,0,-4.330/2,   0.8, 4/3*180 },
    { -5/2,0,0,            0.8, 3/3*180 },
    { 2.5/2,0,4.330/2,     0.8, 1/3*180 },
    { -2.5/2,0,4.330/2,    0.8, 2/3*180 },
}
local function SpawnOverlayFX(inst, i, set, isnew)
    if i ~= nil then
        inst._overlaytasks[i] = nil
        if next(inst._overlaytasks) == nil then
            inst._overlaytasks = nil
        end
    end
    local fx = SpawnPrefab("ttk_boss_spiderqueen_cloud_overlay")
    fx.entity:SetParent(inst.entity)
    fx.Transform:SetPosition(set[1] * .85, 0, set[3] * .85)
    fx.Transform:SetScale(set[4], set[4], set[4])
    if set[5] ~= nil then
        fx.Transform:SetRotation(set[4])
    end
    if not isnew then
        fx.AnimState:PlayAnimation("sporecloud_overlay_loop")
        fx.AnimState:SetTime(math.random() * .7)
    end
    if inst._overlayfx == nil then
        inst._overlayfx = { fx }
    else
        table.insert(inst._overlayfx, fx)
    end
end
local function CreateBase(isnew)
    local inst = CreateEntity()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank(Boss.Art("sporecloud_base"))
    inst.AnimState:SetBuild(Boss.Art("xd_spiderqueen_cloud_base"))
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetFinalOffset(3)
    if isnew then
        inst.AnimState:PlayAnimation("sporecloud_base_pre")
        inst.AnimState:PushAnimation("sporecloud_base_idle", false)
    else
        inst.AnimState:PlayAnimation("sporecloud_base_idle")
    end
    return inst
end
local function OnStateDirty(inst)
    if inst._state:value() > 0 then
        if inst._inittask ~= nil then
            inst._inittask:Cancel()
            inst._inittask = nil
        end
        if inst._state:value() == 1 then
            if inst._basefx == nil then
                inst._basefx = CreateBase(false)
                inst._basefx.entity:SetParent(inst.entity)
            end
        elseif inst._basefx ~= nil then
            inst._basefx.AnimState:PlayAnimation("sporecloud_base_pst")
        end
    end
end
local function OnAnimOver(inst)
    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(1)
end
local function OnOverlayAnimOver(fx)
    fx.AnimState:PlayAnimation("sporecloud_overlay_loop")
end
local function KillOverlayFX(fx)
    fx:RemoveEventCallback("animover", OnOverlayAnimOver)
    fx.AnimState:PlayAnimation("sporecloud_overlay_pst")
end
local function DisableCloud(inst)
    if inst._spoiltask ~= nil then
        inst._spoiltask:Cancel()
        inst._spoiltask = nil
    end
    inst:RemoveTag("sporecloud")
end
local function DoDisperse(inst)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    DisableCloud(inst)
    inst:RemoveEventCallback("animover", OnAnimOver)
    inst._state:set(2)
    FadeOut(inst)
    inst.AnimState:PlayAnimation("sporecloud_pst")
    inst.SoundEmitter:KillSound("spore_loop")
    inst.persists = false
    inst:DoTaskInTime(3, inst.Remove)
    if inst._basefx ~= nil then
        inst._basefx.AnimState:PlayAnimation("sporecloud_base_pst")
    end
    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:DoTaskInTime(i == 1 and 0 or math.random() * .5, KillOverlayFX)
        end
    end
end
local function OnTimerDone(inst, data)
    if data.name == "disperse" then
        DoDisperse(inst)
    end
end
local function FinishImmediately(inst)
    if inst.components.timer:TimerExists("disperse") then
        inst.components.timer:StopTimer("disperse")
        DoDisperse(inst)
    end
end
local function OnLoad(inst, data)
    if inst._inittask ~= nil then
        inst._inittask:Cancel()
        inst._inittask = nil
    end
    inst:RemoveEventCallback("animover", OnAnimOver)
    if inst._overlaytasks ~= nil then
        for k, v in pairs(inst._overlaytasks) do
            v:Cancel()
        end
        inst._overlaytasks = nil
    end
    if inst._overlayfx ~= nil then
        for i, v in ipairs(inst._overlayfx) do
            v:Remove()
        end
        inst._overlayfx = nil
    end
    local t = inst.components.timer:GetTimeLeft("disperse")
    if t == nil or t <= 0 then
        DisableCloud(inst)
        inst._state:set(2)
        FadeOutImmediately(inst)
        inst.SoundEmitter:KillSound("spore_loop")
        inst:Hide()
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
    else
        inst._state:set(1)
        FadeInImmediately(inst)
        inst.AnimState:PlayAnimation("sporecloud_loop", true)
        if not TheNet:IsDedicated() then
            inst._basefx = CreateBase(false)
            inst._basefx.entity:SetParent(inst.entity)
        end
        for i, v in ipairs(OVERLAY_COORDS) do
            SpawnOverlayFX(inst, nil, v, false)
        end
    end
end
local function InitFX(inst)
    inst._inittask = nil
    if TheWorld.ismastersim then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post")
    end
    if not TheNet:IsDedicated() then
        inst._basefx = CreateBase(true)
        inst._basefx.entity:SetParent(inst.entity)
    end
end
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat","_health" }
local AOE_TARGET_CANT_TAGS = {"structure","INLIMBO", "flight", "invisible", "notarget", "noattack","ttk_boss_spider","playerghost"}
local function DoAreaSpoil(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3.5, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
    for i,v in pairs(ents) do
        if inst.owner and inst.owner:IsValid() and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
            local damage = 40
            damage = Xd_CalcDamage(inst.owner,damage,v)
            v.components.combat:GetAttacked(inst.owner,damage)
        end
    end
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("sporecloud"))
    inst.AnimState:SetBuild(Boss.Art("xd_spiderqueen_cloud"))
    inst.AnimState:PlayAnimation("sporecloud_pre")
    inst.AnimState:SetLightOverride(.3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("notarget")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/spore_cloud_LP", "spore_loop")
    inst._state = net_tinybyte(inst.GUID, "ttk_boss_spiderqueen_cloud._state", "statedirty")
    inst._fade = net_smallbyte(inst.GUID, "ttk_boss_spiderqueen_cloud._fade", "fadedirty")
    inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    inst._inittask = inst:DoTaskInTime(0, InitFX)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        inst:ListenForEvent("statedirty", OnStateDirty)
        inst:ListenForEvent("fadedirty", OnFadeDirty)
        return inst
    end
    inst.targets = {}
    inst._spoiltask = inst:DoPeriodicTask(1, DoAreaSpoil, 1.2)
    inst.AnimState:PushAnimation("sporecloud_loop", true)
    inst:ListenForEvent("animover", OnAnimOver)
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("disperse", 10)
    inst:ListenForEvent("timerdone", OnTimerDone)
    inst.OnLoad = OnLoad
    inst.FadeInImmediately = FadeInImmediately
    inst.FinishImmediately = FinishImmediately
    inst._overlaytasks = {}
    for i, v in ipairs(OVERLAY_COORDS) do
        inst._overlaytasks[i] = inst:DoTaskInTime(i == 1 and 0 or math.random() * .7, SpawnOverlayFX, i, v, true)
    end
    return inst
end
local function overlayfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst.Transform:SetTwoFaced()
    inst.AnimState:SetBank(Boss.Art("sporecloud"))
    inst.AnimState:SetBuild(Boss.Art("xd_spiderqueen_cloud"))
    inst.AnimState:SetLightOverride(.2)
    inst.AnimState:PlayAnimation("sporecloud_overlay_pre")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:ListenForEvent("animover", OnOverlayAnimOver)
    inst.persists = false
    return inst
end
return Prefab("ttk_boss_spiderqueen_cloud", fn, assets, prefabs),
    Prefab("ttk_boss_spiderqueen_cloud_overlay", overlayfn, assets)
