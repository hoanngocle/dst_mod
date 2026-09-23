local assets={Asset("ANIM","anim/xd_zcyseed.zip"),
    Asset("ATLAS","images/inventoryimages/xd_zcyseed.xml"),
    Asset("IMAGE","images/inventoryimages/xd_zcyseed.tex"),
    Asset("ANIM","anim/xd_zuichunyan_green.zip")}
local prefabs={"ttk_zuichunyan_green_sapling","ttk_zuichunyan_purple_sapling","spoiled_food"}
local function OnDeploy(inst,pt,deployer)
    local tree=SpawnPrefab(math.random()<.5 and "ttk_zuichunyan_green_sapling" or "ttk_zuichunyan_purple_sapling")
    if tree==nil then return end
    tree.Transform:SetPosition(pt:Get())
    inst.components.stackable:Get():Remove()
    if deployer and deployer.SoundEmitter then deployer.SoundEmitter:PlaySound("dontstarve/common/plant") end
end
local function fn()
    local inst=CreateEntity()
    inst.entity:AddTransform();inst.entity:AddAnimState();inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("xd_zcyseed");inst.AnimState:SetBuild("xd_zcyseed");inst.AnimState:PlayAnimation("idle")
    MakeInventoryFloatable(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname="images/inventoryimages/xd_zcyseed.xml"
    inst.components.inventoryitem:ChangeImageName("xd_zcyseed")
    inst:AddComponent("stackable");inst.components.stackable.maxsize=TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("tradable")
    inst:AddComponent("edible");inst.components.edible.foodtype=FOODTYPE.SEEDS
    inst.components.edible.healthvalue=5;inst.components.edible.hungervalue=12;inst.components.edible.sanityvalue=2
    inst:AddComponent("perishable");inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    inst.components.perishable:StartPerishing();inst.components.perishable.onperishreplacement="spoiled_food"
    inst:AddComponent("deployable");inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable.ondeploy=OnDeploy
    MakeHauntableLaunchAndPerish(inst)
    return inst
end
return Prefab("ttk_boss_zcyseed",fn,assets,prefabs),
    MakePlacer("ttk_boss_zcyseed_placer","xd_zuichunyan_green","xd_zuichunyan_green","sapling")
