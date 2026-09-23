require("prefabutil")
local terrain=require("ttk_tianjimap")
local assets={
    Asset("ANIM","anim/ttk_tianjiwu.zip"),
    Asset("ANIM","anim/ttk_tianji_items.zip"),
    Asset("ATLAS","images/inventoryimages/ttk_tianji_juanzhou.xml"),
    Asset("IMAGE","images/inventoryimages/ttk_tianji_juanzhou.tex"),
    Asset("ATLAS","images/inventoryimages/ttk_tianji_lingpai.xml"),
    Asset("IMAGE","images/inventoryimages/ttk_tianji_lingpai.tex"),
}
local deps={"ttk_tianjiwu","ttk_tianji_juanzhou","ttk_tianji_lingpai","ttk_tianji_room","ttk_tianji_exit",
    "ttk_tianji_floor","ttk_tianji_wallpaper","ttk_tianji_doorart","ttk_tianji_decals","ttk_tianji_wall"}
local function save(inst,data) data.owner=inst._ttk_owner;data.shard=inst._ttk_shard end
local function load(inst,data)
    if data then inst._ttk_owner=data.owner;inst._ttk_shard=data.shard end
end
local function canDeploy(inst,pt,mouseover,deployer)
    return not terrain.Contains(pt.x,pt.z)
        and not (inst._ttk_shard and inst._ttk_shard~=tostring(TheShard:GetShardId()))
        and not (deployer and inst._ttk_owner and inst._ttk_owner~=deployer.userid)
        and TheWorld.Map:CanDeployAtPoint(pt,inst,mouseover)
        and TheWorld.Map:IsAboveGroundAtPoint(pt.x,0,pt.z)
end
local function deploy(inst,pt,deployer)
    if not deployer or not deployer.userid or not deployer.components.inventory or inst._deploying
        or not canDeploy(inst,pt,nil,deployer) then return false end
    local manager=TheWorld.components.ttk_tianjirooms
    if not manager then return false end
    local house=SpawnPrefab("ttk_tianjiwu")
    local token=SpawnPrefab("ttk_tianji_lingpai")
    if not house or not token then
        if house then house:Remove() end
        if token then token:Remove() end
        return false
    end
    if not manager:GetRoom(inst._ttk_owner or deployer.userid) then house:Remove();token:Remove();return false end
    inst._deploying=true
    house._ttk_owner=inst._ttk_owner or deployer.userid
    house._ttk_shard=tostring(TheShard:GetShardId())
    house.Transform:SetPosition(pt.x,0,pt.z)
    deployer.components.inventory:GiveItem(token,nil,pt)
    inst:Remove()
    return true
end
local function accept(inst,item,giver)
    return not inst._packing and giver and giver.userid==inst._ttk_owner
        and giver.components.inventory~=nil and item.prefab=="ttk_tianji_lingpai"
end
local function recall(inst,giver,item)
    if not accept(inst,item,giver) then return end
    local scroll=SpawnPrefab("ttk_tianji_juanzhou")
    -- Trader returns the token unchanged on failure; no consume-before-spawn race.
    if not scroll then giver.components.inventory:GiveItem(item);return end
    inst._packing=true
    inst.components.trader:Disable()
    scroll._ttk_owner=inst._ttk_owner
    scroll._ttk_preserved_skin = inst.AnimState:GetBuild() == "xd_tianjiwu_skins_byj"
        and "ttk_tianjiwu_skins_byj" or nil
    scroll._ttk_shard=inst._ttk_shard or tostring(TheShard:GetShardId())
    giver.components.inventory:GiveItem(scroll,nil,inst:GetPosition())
    item:Remove()
    inst:Remove()
end
local function housefn()
    local inst=CreateEntity()
    inst.entity:AddTransform();inst.entity:AddAnimState();inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity();inst.entity:AddNetwork()
    inst.AnimState:SetBank("xd_tianjiwu");inst.AnimState:SetBuild("xd_tianjiwu");inst.AnimState:PlayAnimation("idle",true)
    inst.MiniMapEntity:SetIcon("ttk_tianjiwu.tex")
    MakeObstaclePhysics(inst,1.5,2,0.75)
    inst:AddTag("structure");inst:AddTag("shelter");inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("ttk_tianji_door");inst:AddTag("nonpackable")
    inst:SetDeployExtraSpacing(4)
    MakeSnowCoveredPristine(inst)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable")
    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(accept)
    inst.components.trader.deleteitemonaccept=false
    inst.components.trader.onaccept=recall
    inst.OnSave=save;inst.OnLoad=load
    MakeSnowCovered(inst)
    return inst
end
local function itemfn(scroll)
    local name=scroll and "juanzhou" or "lingpai"
    local inst=CreateEntity()
    inst.entity:AddTransform();inst.entity:AddAnimState();inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst.AnimState:SetBank("xd_tianji_items");inst.AnimState:SetBuild("xd_tianji_items");inst.AnimState:PlayAnimation(name)
    MakeInventoryFloatable(inst,"med",nil,0.68)
    if scroll then inst:AddTag("portableitem");inst._custom_candeploy_fn=canDeploy end
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("inspectable");inst:AddComponent("tradable");inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname="images/inventoryimages/ttk_tianji_"..name..".xml"
    inst.components.inventoryitem:ChangeImageName("ttk_tianji_"..name)
    if scroll then
        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
        inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LARGE)
        inst.components.deployable.ondeploy=deploy
    end
    inst.OnSave=save;inst.OnLoad=load
    MakeHauntableLaunch(inst)
    return inst
end
return Prefab("ttk_tianjiwu",housefn,assets,deps),
    Prefab("ttk_tianji_juanzhou",function() return itemfn(true) end,assets,deps),
    Prefab("ttk_tianji_lingpai",function() return itemfn(false) end,assets),
    MakePlacer("ttk_tianji_juanzhou_placer","xd_tianjiwu","xd_tianjiwu","idle")
