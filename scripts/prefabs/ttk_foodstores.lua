require "prefabutil"

local prefabs =
{
    "collapse_small", "collapsed_treasurechest", "chestupgrade_stacksize_fx",
}

local function onopen(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onhammered(inst, worker)
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end
    if inst.components.container then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.container then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
end

local function onbuilt(inst)

end

local function makecangku(name)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
        Asset("ANIM", "anim/ttk_ui_6x6.zip"),
        Asset( "ATLAS", "images/inventoryimages/"..name..".xml" ),
    }
    
    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
    
        inst.MiniMapEntity:SetIcon(name..".tex")
    
        inst:AddTag("structure")
    
        inst.AnimState:SetBank(string.gsub(name, "^ttk_", "xd_"))
        inst.AnimState:SetBuild(string.gsub(name, "^ttk_", "xd_"))
        inst.AnimState:PlayAnimation("idle")
    
        MakeObstaclePhysics(inst, 1.5)
        MakeSnowCoveredPristine(inst)
        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("inspectable")
    
        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose
        inst.components.container.skipclosesnd = true
        inst.components.container.skipopensnd = true
    
        inst:AddComponent("lootdropper")
    
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit) 
    
        inst:AddComponent("preserver")
        inst.components.preserver:SetPerishRateMultiplier(-0.2)
    
        MakeLargeBurnable(inst)
        MakeLargePropagator(inst)
    
        MakeSnowCovered(inst)
        AddHauntableDropItemOrWork(inst)
        require("ttk_chestupgrade")(inst)
        return inst
    end
    
    return Prefab(name, fn, assets, prefabs)
end

local flowers = {    
    "ttk_crc",
    "ttk_sgc",
}
local a = {}
for k, v in pairs(flowers) do
    table.insert(a,makecangku(v))
    table.insert(a,MakePlacer(v.."_placer", string.gsub(v, "^ttk_", "xd_"), string.gsub(v, "^ttk_", "xd_"), "idle"))
end
return unpack(a)
