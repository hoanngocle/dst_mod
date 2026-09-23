require "prefabutil"

local assets = {
	Asset("ANIM", "anim/deluxe_firepit.zip"),
	Asset("ANIM", "anim/deluxe_firepit_fire.zip")
}

local prefabs = {
	"deluxe_firepit_fire"
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	local ash = SpawnPrefab("ash")
	ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
	local charcoal = SpawnPrefab("charcoal")
	charcoal.Transform:SetPosition(inst.Transform:GetWorldPosition())
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
end

local function onignite(inst)
	if not inst.components.cooker then
		inst:AddComponent("cooker")
	end
end

local function onextinguish(inst, addLootItems)
	if inst.components.cooker then
		inst:RemoveComponent("cooker")
	end
	if inst.components.fueled then
		inst.components.fueled:InitializeFuelLevel(0)
	end
	local bonus = ttk_vhth_dropLootFirepit
	if bonus == "nooverride" then
		bonus = ttk_vhth_dropLoot
	end
	if bonus == "no" then -- Fix for using old value
		bonus = 0
	elseif bonus == "yes" then
		bonus = 2
	end

	if bonus > 0 then
		if addLootItems == 4 then -- flame max level 4
			inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.components.lootdropper:SpawnLootPrefab("ash")
			if math.random(0, bonus) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("charcoal")
				inst.components.lootdropper:SpawnLootPrefab("ash")
			end
			if math.random(0, bonus - 1) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("charcoal")
			end
			if math.random(0, bonus - 1) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("ash")
			end
			if math.random(0, bonus - 2) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("charcoal")
			end
		elseif addLootItems == 3 then -- flame max level 3
			inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.components.lootdropper:SpawnLootPrefab("ash")
			if math.random(0, bonus) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("ash")
			end
			if math.random(0, bonus - 1) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("charcoal")
			end
			if math.random(0, bonus - 2) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("charcoal")
			end
		elseif addLootItems > 0 then
			if math.random(0, bonus) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("ash")
			end
			if math.random(0, bonus - 1) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("ash")
			end
		end
	end
	--[[if bonus ~= "no" then
		if addLootItems == 4 then -- flame max level 4
            inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.components.lootdropper:SpawnLootPrefab("ash")
		elseif addLootItems == 3 then -- flame max level 3
            inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.components.lootdropper:SpawnLootPrefab("charcoal")
			inst.components.lootdropper:SpawnLootPrefab("ash")
		elseif addLootItems > 0 then
			inst.components.lootdropper:SpawnLootPrefab("ash")
		end
	end]]
	addLootItems = 0
end

local function ontakefuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function updatefuelrate(inst)
	inst.components.fueled.rate =
		TheWorld.state.israining and ttk_vhth_burnRateFirepit + TUNING.FIREPIT_RAIN_RATE * TheWorld.state.precipitationrate or
		ttk_vhth_burnRateFirepit
end

local function onupdatefueled(inst)
	if inst.components.burnable ~= nil and inst.components.fueled ~= nil then
		updatefuelrate(inst)
		inst.components.burnable:SetFXLevel(
			inst.components.fueled:GetCurrentSection(),
			inst.components.fueled:GetSectionPercent()
		)
	end
end

local function getstatus(inst)
	local sec = inst.components.fueled:GetCurrentSection()
	if sec == 0 then
		return "OUT"
	elseif sec <= 4 then
		local t = {"EMBERS", "LOW", "NORMAL", "HIGH"}
		return t[sec]
	end
end

local function fn()
	local flameFullyLoaded = "false"
	local addLootItems = 0
	local inst = CreateEntity()
	local bonus = 1

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	bonus = ttk_vhth_structureSizeFirepit
	if bonus == "nooverride" then
		bonus = ttk_vhth_structureSize
	end
	MakeObstaclePhysics(inst, 0.8 * bonus) -- Old value = 0.5

	inst.MiniMapEntity:SetIcon("deluxe_firepit.tex")
	inst.MiniMapEntity:SetPriority(1)

	inst.AnimState:SetBank("deluxe_firepit")
	inst.AnimState:SetBuild("deluxe_firepit")
	inst.AnimState:PlayAnimation("idle", false)
	inst:AddTag("campfire")
	-- Native DST exclusion: Flingomatic detection and snowball splash (also offscreen).
	inst:AddTag("shadow_fire")
	inst:AddTag("structure")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	-----------------------
	inst:AddComponent("burnable")
	--inst.components.burnable:SetFXLevel(2)
	inst.components.burnable:AddBurnFX("deluxe_firepit_fire", Vector3(0, 0, 0))
	inst:ListenForEvent(
		"onextinguish",
		function()
			onextinguish(inst, addLootItems)
		end
	)
	inst:ListenForEvent("onignite", onignite)

	-------------------------
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	-------------------------
	inst:AddComponent("fueled")
	bonus = ttk_vhth_maxFuelFirepit
	if bonus == "nooverride" then
		bonus = ttk_vhth_maxFuel
	end
	inst.components.fueled.maxfuel = TUNING.FIREPIT_FUEL_MAX * 1.5 * bonus
	inst.components.fueled.accepting = true
	inst.components.fueled:SetSections(4)
	bonus = ttk_vhth_efficiencyFirepit
	if bonus == "nooverride" then
		bonus = ttk_vhth_efficiency
	end
	inst.components.fueled.bonusmult = TUNING.FIREPIT_BONUS_MULT * 1.5 * bonus
	inst.components.fueled.ontakefuelfn = ontakefuel
	inst.components.fueled:SetUpdateFn(onupdatefueled)
	inst.components.fueled:SetSectionCallback(
		function(section)
			if flameFullyLoaded == "true" then
				if section == 4 then
					addLootItems = 4
				elseif section == 3 then
					if addLootItems ~= 4 then
						addLootItems = 3
					end
				end
			else
				addLootItems = 0
			end

			if section == 0 then
				inst.components.burnable:Extinguish(inst, addLootItems)
				addLootItems = 0
			else
				if not inst.components.burnable:IsBurning() then
					inst.components.burnable:Ignite()
				end

				inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
			end
		end
	)
	bonus = ttk_vhth_startFuelFirepit
	if bonus == "nooverride" then
		bonus = ttk_vhth_startFuel
	end
	inst.components.fueled:InitializeFuelLevel(bonus * inst.components.fueled.maxfuel)
	--Old value: TUNING.FIREPIT_FUEL_START
	flameFullyLoaded = "true"

	-----------------------------

	inst:AddComponent("hauntable")
	inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_HUGE
	inst.components.hauntable:SetOnHauntFn(
		function(inst, haunter)
			local ret = false
			if math.random() <= TUNING.HAUNT_CHANCE_RARE then
				if inst.components.fueled and not inst.components.fueled:IsEmpty() then
					local fuel = SpawnPrefab("petals")
					if fuel then
						inst.components.fueled:TakeFuelItem(fuel)
						inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
						ret = true
					end
				end
			end
			if math.random() <= TUNING.HAUNT_CHANCE_HALF then
				if inst.components.workable and inst.components.workable.workleft > 0 then
					inst.components.workable:WorkedBy(haunter, 1)
					inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
					ret = true
				end
			end
			return ret
		end
	)

	-----------------------------

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:ListenForEvent(
		"onbuilt",
		function()
			inst.AnimState:PlayAnimation("build")
			inst.AnimState:PushAnimation("idle", false)
			inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
			addLootItems = 3 -- initialise loot on build
		end
	)

	return inst
end

return Prefab("common/objects/deluxe_firepit", fn, assets, prefabs), MakePlacer(
	"common/deluxe_firepit_placer",
	"deluxe_firepit",
	"deluxe_firepit",
	"idle"
)
