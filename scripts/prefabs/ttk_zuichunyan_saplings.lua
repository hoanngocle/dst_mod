-- Source sapling growth: 960 seconds, timer persists across saves.
local pinecone_assets =
{
    Asset("ANIM", "anim/xd_zuichunyan_green.zip"),
    Asset("ANIM", "anim/xd_zuichunyan_purple.zip"),
}
local function growtree(inst)
    local tree = SpawnPrefab(inst.growprefab)
    if tree then
        tree.Transform:SetPosition(inst.Transform:GetWorldPosition())
        tree:growfromseed()
        inst:Remove()
    end
end
local function stopgrowing(inst)
    inst.components.timer:StopTimer("grow")
end
local function startgrowing(inst)
    if not inst.components.timer:TimerExists("grow") then
        local growtime = 960
        inst.components.timer:StartTimer("grow", growtime)
    end
end
local function ontimerdone(inst, data)
    if data.name == "grow" then
        growtree(inst)
    end
end
local function digup(inst, digger)
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end
local function sapling_fn(build, anim, growprefab, tag, fireproof, overrideloot, override_deploy_smart_radius,nameoverride,bank)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
		inst:SetDeploySmartRadius(override_deploy_smart_radius or DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2)
        inst.AnimState:SetBank(bank or build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim)
        if not fireproof then
            inst:AddTag("plant")
        end
        if  nameoverride  then
            inst:SetPrefabNameOverride(nameoverride)
        end
        MakeSnowCoveredPristine(inst)
        if tag then
            inst:AddTag(tag)
        end
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst.growprefab = growprefab
        inst.StartGrowing = startgrowing
        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", ontimerdone)
        startgrowing(inst)
        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot(overrideloot or {"twigs"})
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(digup)
        inst.components.workable:SetWorkLeft(1)
        if not fireproof then
            MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
            inst:ListenForEvent("onignite", stopgrowing)
            inst:ListenForEvent("onextinguish", startgrowing)
            MakeSmallPropagator(inst)
            MakeHauntableIgnite(inst)
        else
            MakeHauntableWork(inst)
        end
        MakeSnowCovered(inst)
        MakeWaxablePlant(inst)
        return inst
    end
    return fn
end
return
    Prefab("ttk_zuichunyan_green_sapling",sapling_fn("xd_zuichunyan_green", "sapling", "ttk_zuichunyan_green_short",nil,nil,nil,nil,"ttk_zuichunyan_sapling"), pinecone_assets, {"ttk_zuichunyan_green_short", "ttk_zuichunyan_purple_short"}),
    Prefab("ttk_zuichunyan_purple_sapling",sapling_fn("xd_zuichunyan_purple", "sapling", "ttk_zuichunyan_purple_short",nil,nil,nil,nil,"ttk_zuichunyan_sapling","xd_zuichunyan_green"), pinecone_assets, {"ttk_zuichunyan_green_short", "ttk_zuichunyan_purple_short"})
