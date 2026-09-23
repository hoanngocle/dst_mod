
local util = require("ttk_batch19_houseutil")

local assets =
{
    Asset("ANIM", "anim/ttk_lycx.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_lycx.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_lycx.tex"),
}

local prefabs = {
    "ttk_dragonfly", "collapse_small", "dragon_scales", "yellowgem", "greengem",
    "orangegem", "redgem", "bluegem", "purplegem",
}

local function onhammered(inst, worker)
    if not util.ReleaseChildrenForHammer(inst) then
        return
    end
    inst.components.lootdropper:DropLoot()
    inst.components.inventory:DropEverything(false, true)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")

    inst:Remove()
end

local function onhit(inst, worker)
end

local function canspawn(inst)
    return not TheWorld.state.isnight 
end

local function OnChildKilled(inst, child)
end

local function OnChildSpawned(inst, child)
    if child ~= nil then
        child._ttk_owner_userid = inst._ttk_owner_userid
        child._ttk_owner_name = inst._ttk_owner_name
        if child.components.homeseeker ~= nil then
            child.components.homeseeker:SetHome(inst)
        end
    end
end

local function CacheItemsAtHome(inst, catcoon)
end

local function OnRansacked(inst, doer)
    if inst.components.activatable == nil or inst.components.inventory == nil then
        return false
    end
    inst.components.activatable.inactive = true
    local drop = false
	for i = 1, inst.components.inventory.maxslots do
		local item = inst.components.inventory:GetItemInSlot(i)
		if item ~= nil then
			inst.components.inventory:DropItem(item, true, true)
            drop = true
		end
	end
    if drop then
        return true
    end
	return false, "TTK_EMPTY_HOUSE" 
end

local function getleftsolt(self)
    local left = 0
    for k = 1, self.maxslots do
        if not self.itemslots[k] then
            left = left + 1
        end
    end
    return left
end

local function OnDay(inst)
    if inst.components.childspawner ~= nil and inst.components.childspawner:IsFull() then
		inst.day_count = inst.day_count + 1
		if inst.day_count >= 10 then
            inst.day_count = 0
			local left = getleftsolt(inst.components.inventory)
			if left > 9 then
                inst.components.inventory:GiveItem(SpawnPrefab("dragon_scales"))
                inst.components.inventory:GiveItem(SpawnPrefab("yellowgem"))
                inst.components.inventory:GiveItem(SpawnPrefab("greengem"))
                inst.components.inventory:GiveItem(SpawnPrefab("orangegem"))
                inst.components.inventory:GiveItem(SpawnPrefab("redgem"))
                inst.components.inventory:GiveItem(SpawnPrefab("redgem"))
                inst.components.inventory:GiveItem(SpawnPrefab("bluegem"))
                inst.components.inventory:GiveItem(SpawnPrefab("bluegem"))
                inst.components.inventory:GiveItem(SpawnPrefab("purplegem"))
                inst.components.inventory:GiveItem(SpawnPrefab("purplegem"))
			end
		end
    end
end

local function GetActivateVerb(inst)
	return "TTK_HARVEST_HOUSE"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("xd_lycx")
    inst.AnimState:SetBuild("xd_lycx")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(1.3, 1.3, 1.3)

	MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("ttk_lycx.tex")

    MakeSnowCoveredPristine(inst)

    inst.GetActivateVerb = GetActivateVerb

    inst:AddTag("structure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then

        return inst
    end
	inst.day_count = 0
    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ttk_dragonfly"
    inst.components.childspawner:SetRegenPeriod(5*480)
    inst.components.childspawner:SetSpawnPeriod(5)
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner.canspawnfn = canspawn
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner.onchildkilledfn = OnChildKilled
    inst.components.childspawner:SetSpawnedFn(OnChildSpawned)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 12
    inst:WatchWorldState("cycles", OnDay)

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnRansacked
    inst.components.activatable.inactive = true

    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)

    util.BindOnBuilt(inst)

	inst.OnSave = function(inst,data)
		data.day_count = inst.day_count
		util.SaveOwner(inst, data)
	end
	inst.OnLoad = function(inst,data)
		if data then
            if data.day_count then
                inst.day_count = data.day_count
            end
		end
		util.LoadOwner(inst, data)
	end

    return inst
end

return  Prefab("ttk_lycx", fn, assets, prefabs),
    MakePlacer("ttk_lycx_placer", "xd_lycx", "xd_lycx", "idle",nil,nil,nil,1.3)
