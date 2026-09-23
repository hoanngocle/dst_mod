local terrain=require("ttk_tianjimap")
local assets={}
for _,name in ipairs({"floortjw","walltjw","door_exittjw","door_exittjw_heng","wall_decals_tjw"}) do
    table.insert(assets,Asset("ANIM","anim/ttk_"..name..".zip"))
end
local function roomfn()
    local inst=CreateEntity()
    inst.entity:AddTransform();inst.entity:AddLight();inst.entity:AddNetwork()
    for _,tag in ipairs({"NOCLICK","NOBLOCK","ttk_tianji_room","shadecanopy","lightningrod","antlion_sinkhole_blocker"}) do inst:AddTag(tag) end
    inst.pitch=36;inst.distance=45;inst.current_x=3;inst.fov=35
    inst.Light:SetFalloff(.4);inst.Light:SetIntensity(.8);inst.Light:SetRadius(30)
    inst.Light:SetColour(180/255,195/255,150/255);inst.Light:Enable(true)
    -- Clients learn room geometry from this replicated marker.
    inst:DoTaskInTime(0,function()
        if inst:IsValid() then local x,_,z=inst.Transform:GetWorldPosition();terrain.Register(x,z) end
    end)
    inst:ListenForEvent("onremove",function()
        local x,_,z=inst.Transform:GetWorldPosition();terrain.Remove(x,z)
    end)
    inst:AddComponent("temperatureoverrider")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then return inst end
    inst.components.temperatureoverrider:SetRadius(22)
    inst.components.temperatureoverrider:SetTemperature(32);inst.components.temperatureoverrider:Enable()
    inst:AddComponent("lightningblocker")
    inst.components.lightningblocker:SetBlockRange(22)
    inst.components.lightningblocker:SetOnLightningStrike(function() end)
    return inst
end
local function wallfn()
    local inst=CreateEntity()
    inst.entity:AddTransform();inst.entity:AddNetwork()
    local phys=inst.entity:AddPhysics()
    phys:SetMass(0);phys:SetCollisionGroup(COLLISION.WORLD);phys:ClearCollisionMask()
    for k,v in pairs(COLLISION) do if k~="SANITY" then phys:CollidesWith(v) end end
    phys:SetCapsule(.5,10);phys:SetDontRemoveOnSleep(true)
    inst:AddTag("NOCLICK");inst:AddTag("NOBLOCK");inst:AddTag("blocker");inst:AddTag("birdblocker")
    inst.entity:SetPristine()
    inst:DoTaskInTime(0,function() TheWorld.Pathfinder:AddWall(inst.Transform:GetWorldPosition()) end)
    inst:ListenForEvent("onremove",function() TheWorld.Pathfinder:RemoveWall(inst.Transform:GetWorldPosition()) end)
    return inst
end
local function decoration(name,build,kind)
    local function fn()
        local inst=CreateEntity()
        inst.entity:AddTransform();inst.entity:AddAnimState();inst.entity:AddNetwork()
        inst.AnimState:SetBank(build);inst.AnimState:SetBuild(build);inst.AnimState:PlayAnimation("idle")
        inst:AddTag("NOBLOCK")
        if kind=="exit" then
            inst:AddTag("ttk_tianji_door");inst:AddTag("ttk_tianji_exit")
            inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND);inst.AnimState:SetScale(1.12,1.12,1.12)
        else inst:AddTag("NOCLICK") end
        if kind=="floor" then
            inst.Transform:SetScale(1.7,1.7,1.68)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_BELOW_GROUND);inst.AnimState:SetSortOrder(0)
        elseif kind=="wallpaper" then
            inst.AnimState:SetLayer(LAYER_BELOW_GROUND);inst.AnimState:SetSortOrder(1)
        elseif kind=="decals" then inst.AnimState:SetScale(1.01,1.01,1.01) end
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then return inst end
        if kind=="exit" then inst:AddComponent("inspectable") end
        if kind=="decals" then
            inst.OnSave=function(item,data) data.mirror=item._ttk_mirror end
            inst.OnLoad=function(item,data)
                if data and data.mirror then item._ttk_mirror=true;item.Transform:SetScale(-1,1,1) end
            end
        end
        return inst
    end
    return Prefab(name,fn,assets)
end
return Prefab("ttk_tianji_room",roomfn),Prefab("ttk_tianji_wall",wallfn),
    decoration("ttk_tianji_exit","xd_door_exittjw","exit"),
    decoration("ttk_tianji_floor","xd_floortjw","floor"),
    decoration("ttk_tianji_wallpaper","xd_walltjw","wallpaper"),
    decoration("ttk_tianji_doorart","xd_door_exittjw_heng","doorart"),
    decoration("ttk_tianji_decals","xd_wall_decals_tjw","decals")
