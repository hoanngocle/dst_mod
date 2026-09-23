
local assets =
{
    Asset("ANIM", "anim/ttk_klxw.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_klxw.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_klxw.tex"),
}

local prefabs = { "ttk_koalefant", "collapse_small", "trunk_summer", "trunk_winter",

}

local function onhammered(inst, worker)
    if inst.components.childspawner ~= nil then
        local spawner = inst.components.childspawner
        local old_can_spawn = spawner.canspawnfn
        spawner.canspawnfn = nil -- demolition must also release livestock at night
        spawner:ReleaseAllChildren()
        spawner.canspawnfn = old_can_spawn
        if spawner.childreninside > 0 then
            -- No valid exit: keep the house and remaining animals for another try.
            inst.components.workable:SetWorkLeft(1)
            return
        end
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

local function CacheItemsAtHome(inst, catcoon)
end

local function OnRansacked(inst, doer)
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
    if inst.components.childspawner:IsFull() then
		inst.day_count = inst.day_count + 1
		if inst.day_count >= 3 then
            inst.day_count = 0
			local left = getleftsolt(inst.components.inventory)
			if left > 0 then
                inst.components.inventory:GiveItem(SpawnPrefab(math.random() < 0.5 and "trunk_summer" or "trunk_winter"))
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

    inst.AnimState:SetBank("xd_klxw")
    inst.AnimState:SetBuild("xd_klxw")
    inst.AnimState:PlayAnimation("idle")

	MakeObstaclePhysics(inst, .8)

    inst.MiniMapEntity:SetIcon("ttk_klxw.tex")

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
    inst.components.childspawner.childname = "ttk_koalefant"
    inst.components.childspawner:SetRegenPeriod(480)
    inst.components.childspawner:SetSpawnPeriod(5)
    inst.components.childspawner:SetMaxChildren(2)
    inst.components.childspawner.canspawnfn = canspawn
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner.onchildkilledfn = OnChildKilled

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = TUNING.CATCOONDEN_INV_SIZE
    inst:WatchWorldState("cycles", OnDay)

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnRansacked
    inst.components.activatable.inactive = true

    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)

    inst.OnSave = function(inst,data)
		data.day_count = inst.day_count
	end
	inst.OnLoad = function(inst,data)
		if data then
            if data.day_count then
                inst.day_count = data.day_count
            end
		end
	end

    return inst
end

return  Prefab("ttk_klxw", fn, assets, prefabs),
    MakePlacer("ttk_klxw_placer", "xd_klxw", "xd_klxw", "idle")
