
local assets =
{
    Asset("ANIM", "anim/ttk_hmsw.zip"),
	Asset("ATLAS", "images/inventoryimages/ttk_hmsw.xml"),
    Asset("IMAGE", "images/inventoryimages/ttk_hmsw.tex"),
}

local prefabs = {"catcoon", "collapse_small",

}

local function onopen(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

local function onclose(inst)
    
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local function onhammered(inst, worker)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
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
    return true
end
local function OnChildKilled(inst, child)
end

local function CacheItemsAtHome(inst, catcoon)
	catcoon.components.inventory:TransferInventory(inst)
end

local function OnRansacked(inst, doer)
    inst.components.activatable.inactive = true

    local drop = false
	for i = 1, inst.components.inventory.maxslots do
		local item = inst.components.inventory:GetItemInSlot(i)
		if item ~= nil then
			inst.components.inventory:DropItem(item, true, true)
			inst._inv_age[i] = 0
			
            drop = true
		end
	end
    if drop then
        return true
    end
	return false, "EMPTY_CATCOONDEN" 
end

local function OnInventoryFull(inst, leftovers)
	if leftovers ~= nil then
		local target_slot, target_age = nil, TheWorld.components.worldstate:GetWorldAge() + 1
		for k, age in pairs(inst._inv_age) do
			if age < target_age then
				target_age = age
				target_slot = k
			end
		end

		if target_slot ~= nil then
			local inv = inst.components.inventory
			local old_item = inv:RemoveItemBySlot(target_slot)
			if old_item ~= nil then
				old_item:Remove()
			end
			inv:GiveItem(leftovers, target_slot)
		end
	end
end

local function OnCachedItemAtHome(inst, data)
	if data ~= nil and data.slot ~= nil and not POPULATING then
		inst._inv_age[data.slot] = TheWorld.components.worldstate:GetWorldAge()
	end
end

local function onsave(inst, data)
	data._inv_age = inst._inv_age
end

local function onload(inst, data)
    if data ~= nil then
		if data._inv_age ~= nil then
			for i = 1, inst.components.inventory.maxslots do
				inst._inv_age[i] = data._inv_age[i] or 0
			end
		end
    end
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

local neutralGiftPrefabs =
{
	{ 
		"wetgoop",
	},
	{ 
		"spoiled_food",
		"wetgoop",
	},
	{ 
		"cutgrass",
		"spoiled_food",
	},
	{ 
		"cutgrass",
		"spoiled_food",
	},
	{ 
		"cutgrass",
		"rocks",
		"petals_evil",
	},
	{ 
		"rocks",
		"flint",
		"petals",
	},
	{ 
		"ice",
		"flint",
		"pinecone",
	},
	{ 
		"flint",
		"pinecone",
		"feather_robin",
	},
	{ 
		"mole",
		"acorn",
	}
}

local friendGiftPrefabs =
{
	{ 
		"carrot_seeds",
		"corn_seeds",
        "potato_seeds",
        "tomato_seeds",
	},
	{ 
		"flint",
		"cutgrass",
		"twigs",
		"rocks",
		"ash",
		"pinecone",
		"petals",
		"petals_evil",
	},
	{ 
		"feather_robin",
		"feather_robin_winter",
		"feather_crow",
		"feather_canary",
		"boneshard",
	},
	{ 
		"pumpkin_seeds",
		"eggplant_seeds",
		"durian_seeds",
		"pomegranate_seeds",
		"dragonfruit_seeds",
		"watermelon_seeds",
        "asparagus_seeds",
        "onion_seeds",
        "garlic_seeds",
        "pepper_seeds",
	},
	{ 
		"ice",
		"batwing",
		"acorn",
		"berries",
		"smallmeat",
		"red_cap",
		"blue_cap",
		"green_cap",
		"pondfish",
		"froglegs",
	},
	{ 
		"mole",
		"rabbit",
		"bee",
		"butterfly",
		"robin",
		"robin_winter",
		"canary",
		"crow",
		"tumbleweed",
	},
	{ 
		"goldnugget",
		"silk",
		"cutreeds",
		"tentaclespots",
		"beefalowool",
		"transistor",
	},
}
local function PickRandomGift(inst)
	local table = math.random() < 0.5 and 
		friendGiftPrefabs or neutralGiftPrefabs
	local rad = math.random(#table)
	return GetRandomItem(table[rad])
end

local function OnDay(inst)
    if inst.components.childspawner:IsFull() then
        local max = math.random() < 0.5 and 2 or 3
        local left = getleftsolt(inst.components.inventory)
        local need = math.min(left,max)
        if need > 0 then
            local item = PickRandomGift(inst)
            for k = 1,need do
                inst.components.inventory:GiveItem(SpawnPrefab(item))
            end
        end
    end
end

local function GetActivateVerb(inst)
	return "TTK_CAT_GIFTS"
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

    inst.AnimState:SetBank("xd_hmsw")
    inst.AnimState:SetBuild("xd_hmsw")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("ttk_hmsw.tex")

    MakeSnowCoveredPristine(inst)

	MakeObstaclePhysics(inst, .5)
	
    inst.GetActivateVerb = GetActivateVerb

    inst:AddTag("structure")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then

        return inst
    end
    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "catcoon"
    inst.components.childspawner:SetRegenPeriod(480)
    inst.components.childspawner:SetSpawnPeriod(TUNING.CATCOONDEN_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner.canspawnfn = canspawn
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner.onchildkilledfn = OnChildKilled

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = TUNING.CATCOONDEN_INV_SIZE
	inst.components.inventory.HandleLeftoversFn = OnInventoryFull
	inst.CacheItemsAtHome = CacheItemsAtHome	
	inst._inv_age = {}
	for i = 1, TUNING.CATCOONDEN_INV_SIZE do
		inst._inv_age[i] = 0					
	end
	inst:ListenForEvent("gotnewitem", OnCachedItemAtHome)
    inst:WatchWorldState("cycles", OnDay)

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnRansacked
    inst.components.activatable.inactive = true

    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)
    
	inst.OnSave = onsave
    inst.OnLoad = onload
    return inst
end

return  Prefab("ttk_hmsw", fn, assets, prefabs),
    MakePlacer("ttk_hmsw_placer", "xd_hmsw", "xd_hmsw", "idle")
