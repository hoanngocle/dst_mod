-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_baihu_buff.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_baihufire_circle.zip")),
}
local damagemult = {
    [1] = 1.7,
    [2] = 3,
}
local function OnTimeDone(inst)
    if inst.owner then
        inst.owner.ttk_boss_baihu_buff1 = nil
        inst:Remove()
    end
end
local function SetOwner(inst,owner)
    inst.entity:SetParent(owner.entity)
    inst.Transform:SetPosition(0,0.7,0)
    inst.owner = owner
    if inst.owner.ttk_boss_baihu_buff2 and inst.owner.ttk_boss_baihu_buff2:IsValid()
        or inst.owner.ttk_boss_baihu_buff3 and inst.owner.ttk_boss_baihu_buff3:IsValid() then
        inst:Hide()
    end
end
local function AddCount(inst)
    inst.count = math.min(2,inst.count + 1)
end
local function GetDamageMult(inst)
    return damagemult[inst.count] or 1
end
local function fn1()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_baihu_buff"))
    inst.AnimState:SetBuild(Boss.Art("xd_baihu_buff"))
    inst.AnimState:PlayAnimation("idle1")
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(3)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("colourtweener")
    inst.count = 1
    inst.SetOwner = SetOwner
    inst.GetDamageMult = GetDamageMult
    inst.OnTimeDone = OnTimeDone
    inst.AddCount = AddCount
    inst:DoTaskInTime(15,function()
        inst.components.colourtweener:StartTween({1, 1, 1, 0}, 3, function()
            OnTimeDone(inst)
        end)
    end)
    inst.persists = false
    return inst
end
local function OnTimeDone1(inst)
    if inst.owner then
        inst.owner.ttk_boss_baihu_buff2 = nil
        if inst.owner.ttk_boss_baihu_buff1 and inst.owner.ttk_boss_baihu_buff1:IsValid() then
            inst.owner.ttk_boss_baihu_buff1:Show()
        end
        inst:Remove()
    end
end
local function SetOwner1(inst,owner,count)
    inst.entity:SetParent(owner.entity)
    inst.Transform:SetPosition(0,0.7,0)
    inst.owner = owner
    if inst.owner.ttk_boss_baihu_buff1 and inst.owner.ttk_boss_baihu_buff1:IsValid() then
        inst.owner.ttk_boss_baihu_buff1:Hide()
    end
    if count then
        inst.count =  count
        inst.AnimState:PlayAnimation("idle3")
    end
end
local function AddCount1(inst)
    inst.count = math.min(2,inst.count + 1)
    inst.AnimState:PlayAnimation("idle3")
end
local function fn2()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_baihu_buff"))
    inst.AnimState:SetBuild(Boss.Art("xd_baihu_buff"))
    inst.AnimState:PlayAnimation("idle2")
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(3)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.count = 1
    inst.SetOwner = SetOwner1
    inst.persists = false
    inst.AddCount = AddCount1
    inst:AddComponent("colourtweener")
    inst:DoTaskInTime(14,function()
        inst.components.colourtweener:StartTween({1, 1, 1, 0}, 1, function()
            OnTimeDone1(inst)
        end)
    end)
    return inst
end
local function OnTimeDone2(inst)
    if inst.owner then
        inst.owner.ttk_boss_baihu_buff3 = nil
        if inst.owner.ttk_boss_baihu_buff1 and inst.owner.ttk_boss_baihu_buff1:IsValid() then
            inst.owner.ttk_boss_baihu_buff1:Show()
        end
        inst:Remove()
    end
end
local function fn3()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("xd_baihu_buff"))
    inst.AnimState:SetBuild(Boss.Art("xd_baihu_buff"))
    inst.AnimState:PlayAnimation("idle4")
    inst:AddTag("fx")
    inst.AnimState:SetFinalOffset(3)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.count = 1
    inst.SetOwner = SetOwner1
    inst.persists = false
    inst:AddComponent("colourtweener")
    inst:DoTaskInTime(14,function()
        inst.components.colourtweener:StartTween({1, 1, 1, 0}, 1, function()
            OnTimeDone2(inst)
        end)
    end)
    return inst
end
local function CopyFromPlayer(inst,owner,target)
    inst.components.skinner:CopySkinsFromPlayer(target)
    inst.owner = owner
    inst.Transform:SetRotation(target.Transform:GetRotation())
    inst:ListenForEvent("onremove",function()
        if inst.owner and inst.owner.shadowfxs[inst] then
            inst.owner.shadowfxs[inst] = nil
            inst.owner.shadow_count = inst.owner.shadow_count - 1
            inst.owner:CheckShaodows()
        end
    end)
end
local function shadowfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
	inst.Transform:SetFourFaced(inst)
	inst.AnimState:SetBank(Boss.Art("wilson"))
	inst.AnimState:SetBuild(Boss.Art("wilson"))
	inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetMultColour(255/255,166/255, 12/255, 0.5)
    inst.nohighlight = true
    inst.AnimState:AddOverrideBuild(Boss.Art("player_lunge"))
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_spawn"))
	inst.AnimState:AddOverrideBuild(Boss.Art("waxwell_minion_appear"))
	inst.AnimState:AddOverrideBuild(Boss.Art("lavaarena_shadow_lunge"))
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")
	inst.AnimState:Hide("HAT")
	inst.AnimState:Hide("HAIR_HAT")
	inst:AddTag("ttk_boss_baihu_shadowplayer")
	inst:AddTag("NOBLOCK")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("skinner")
	inst.components.skinner:SetupNonPlayerData()
	inst.persists = false
	inst:DoTaskInTime(120, inst.Remove)
    inst.CopyFromPlayer = CopyFromPlayer
	return inst
end
local function OnTimeDone(inst)
    if inst.damagetask then
        inst.damagetask:Cancel()
        inst.damagetask = nil
    end
	inst.AnimState:PlayAnimation("pst")
    if inst.owner and inst.owner.dotfxs[inst] then
        inst.owner.dotfxs[inst] = nil
    end
    inst:ListenForEvent("animover",inst.Remove)
    inst:DoTaskInTime(1.5,inst.Remove)
end
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat","player" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack","ttk_baihu","playerghost"}
local function doattack(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3.8, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
    for i, v in ipairs(ents) do
        if  inst.owner and inst.owner:IsValid() and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
            local damage = 37.5
            damage = Xd_CalcDamage(inst.owner,damage,v)
            v.components.combat:GetAttacked(inst.owner,damage)
        end
    end
end
local function SetOwner(inst,owner)
    inst.owner = owner
    inst:DoTaskInTime(0.7,function()
        if not inst.damagetask then
            inst.damagetask =  inst:DoPeriodicTask(0.5,doattack,0)
        end
    end)
end
local function fn4()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.Transform:SetFourFaced(inst)
	inst.AnimState:SetBank(Boss.Art("deer_fire_circle"))
	inst.AnimState:SetBuild(Boss.Art("xd_baihufire_circle"))
	inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop",false)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst:AddTag("FX")
	inst:AddTag("NOBLOCK")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
	inst:DoTaskInTime(480, OnTimeDone)
    inst.OnTimeDone = OnTimeDone
    inst.SetOwner = SetOwner
	return inst
end
return Prefab("ttk_boss_baihu_buff1", fn1, assets),
    Prefab("ttk_boss_baihu_buff2", fn2, assets),
    Prefab("ttk_boss_baihu_buff3", fn3, assets),
    Prefab("ttk_boss_baihu_shadowplayer", shadowfn, assets),
    Prefab("ttk_boss_baihu_dotfx", fn4, assets)
