require "prefabutil"

local assets = {
	Asset("ANIM", "anim/ice_star.zip"),
	Asset("ANIM", "anim/ice_star_flame.zip")
}

local prefabs = {
	"ice_star_flame"
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
	inst:Remove()
end

local function onhit(inst, worker)
	if ttk_vhth_starsSpawnHounds ~= "no" then
		inst.components.lootdropper:SpawnLootPrefab("firehound")
		inst.components.talker:Say("Dừng tay! Ta chưa muốn tiêu tan!")
	else
		inst.components.talker:Say("Dừng tay! Ta chưa muốn tiêu tan!")
	end
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
	local bonus = ttk_vhth_dropLootIceStar
	if bonus == "nooverride" then
		bonus = ttk_vhth_dropLoot
	end
	if bonus == "no" then -- Fix for using old value
		bonus = 0
	elseif bonus == "yes" then
		bonus = 2
	end

	if bonus > 0 then
		if addLootItems == 3 then -- flame max level 10
			if ttk_vhth_starsSpawnHounds ~= "no" then
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
			end
			inst.components.lootdropper:SpawnLootPrefab("ice")
			inst.components.lootdropper:SpawnLootPrefab("ice")
			if math.random(0, bonus) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
			if math.random(0, bonus) >= 2 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
			if math.random(0, bonus) >= 3 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
			if math.random(0, bonus) >= 2 then
				inst.components.lootdropper:SpawnLootPrefab("bluegem")
			end
		elseif addLootItems == 2 then -- flame max level 9
			if ttk_vhth_starsSpawnHounds ~= "no" then
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
			end
			inst.components.lootdropper:SpawnLootPrefab("ice")
			if math.random(0, bonus) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
			if math.random(0, bonus) >= 2 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
			if math.random(0, bonus) >= 3 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
		elseif addLootItems == 1 then -- flame max level 6
			if ttk_vhth_starsSpawnHounds ~= "no" then
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
				if math.random(ttk_vhth_starsSpawnHounds, 4) > 3 then
					inst.components.lootdropper:SpawnLootPrefab("firehound")
				end
			end
			inst.components.lootdropper:SpawnLootPrefab("ice")
			if math.random(0, bonus) >= 1 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
			if math.random(0, bonus) >= 3 then
				inst.components.lootdropper:SpawnLootPrefab("ice")
			end
		end
	end
end

local function ontakefuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function updatefuelrate(inst)
	inst.components.fueled.rate = TheWorld.state.israining and ttk_vhth_burnRateIceStar or ttk_vhth_burnRateIceStar
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
	elseif sec <= 10 then
		local t = {"EMBERS", "EMBERS", "LOW", "LOW", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "HIGH", "HIGH"}
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

	bonus = ttk_vhth_structureSizeIceStar
	if bonus == "nooverride" then
		bonus = ttk_vhth_structureSize
	end
	MakeObstaclePhysics(inst, 1 * bonus) -- Old value = 0.5

	inst.MiniMapEntity:SetIcon("ice_star.tex")
	inst.MiniMapEntity:SetPriority(1)

	inst.AnimState:SetBank("ice_star")
	inst.AnimState:SetBuild("ice_star")
	inst.AnimState:PlayAnimation("idle", false)
	inst:AddTag("campfire")
	-- Native DST exclusion: Flingomatic detection and snowball splash (also offscreen).
	inst:AddTag("shadow_fire")
	inst:AddTag("structure")

	inst:AddComponent("talker")
	inst.components.talker.colour = Vector3(0, 0.4, 1)
	inst.components.talker.font = TALKINGFONT
	inst.components.talker.fontsize = 28
	inst.components.talker.offset = Vector3(0, -520, 0)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	-----------------------
	inst:AddComponent("burnable")
	--inst.components.burnable:SetFXLevel(2)
	inst.components.burnable:AddBurnFX("ice_star_flame", Vector3(0, 0, 0))
	inst:ListenForEvent(
		"onextinguish",
		function()
			onextinguish(inst, addLootItems)
		end
	)
	inst:ListenForEvent("onignite", onignite)
	if IsDLCEnabled(REIGN_OF_GIANTS) then
		if inst.components.burnable then
			inst.components.burnable:StopSmoldering()
		end
	end

	-------------------------
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(5)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	-------------------------

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_HUGE



	inst:ListenForEvent(
		"donetalking",
		function()
			inst.SoundEmitter:KillSound("talk")
		end
	)
	inst:ListenForEvent(
		"ontalk",
		function()
			if not inst.SoundEmitter:PlayingSound("special") then
				inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/talk_LP", "talk")
			end
		end
	)

	-------------------------
	inst:AddComponent("fueled")
	bonus = ttk_vhth_maxFuelIceStar
	if bonus == "nooverride" then
		bonus = ttk_vhth_maxFuel
	end
	inst.components.fueled.maxfuel = TUNING.FIREPIT_FUEL_MAX * 2 * bonus
	inst.components.fueled.accepting = true
	inst.components.fueled.secondaryfueltype = "CHEMICAL"
	inst.components.fueled:SetSections(10)
	bonus = ttk_vhth_efficiencyIceStar
	if bonus == "nooverride" then
		bonus = ttk_vhth_efficiency
	end
	inst.components.fueled.bonusmult = TUNING.FIREPIT_BONUS_MULT * 2 * bonus
	inst.components.fueled.ontakefuelfn = ontakefuel
	inst.components.fueled:SetUpdateFn(onupdatefueled)
	inst.components.fueled:SetSectionCallback(
		function(section, oldSection)
			if flameFullyLoaded == "true" then
				if section == 10 then
					inst.components.talker:Say("Hàn hỏa của ta đang tỏa sáng!")
					addLootItems = 3
					inst.components.fueled.accepting = false
				elseif section > 6 and section <= 9 then
					if addLootItems ~= 3 then
						addLootItems = 2
					end
					inst.components.fueled.accepting = true
				elseif section > 0 and section <= 6 then
					if addLootItems ~= 2 and addLootItems ~= 3 then
						addLootItems = 1
					end
					inst.components.fueled.accepting = true
				end
			else
				addLootItems = 0
			end

			if section == 0 then
				inst.components.burnable:Extinguish(inst, addLootItems)
				addLootItems = 0
				inst.components.fueled.accepting = true
			else
				if not inst.components.burnable:IsBurning() then
					inst.components.burnable:Ignite()
				end

				inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())

				inst:ListenForEvent(
					"onbuilt",
					function()
						inst.AnimState:PlayAnimation("build")
						inst.AnimState:PushAnimation("idle", false)
						inst.components.talker:Say("Ta là linh hỏa vĩnh hằng!")
						inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
						addLootItems = 3 -- initialise loot on build
					end
				)
			end

			bonus = ttk_vhth_sanityBoostIceStar
			if bonus == "nooverride" then
				bonus = ttk_vhth_sanityBoost
			end

			if section > 8 then
				inst.components.sanityaura.aura = TUNING.SANITYAURA_LARGE * bonus
			elseif section <= 8 and section > 3 then
				inst.components.sanityaura.aura = TUNING.SANITYAURA_MED * bonus
			elseif section <= 3 and section > 0 then
				inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL * bonus
			else
				inst.components.sanityaura.aura = 0
			end

			if (section == 1 and section < oldSection) and addLootItems > 0 and ttk_vhth_starsSpawnHounds == "yes" then
				inst.components.talker:Say("Hãy tiếp nhiên liệu! Chó săn sẽ bảo vệ ta!")
			elseif (section == 1 and section < oldSection) and addLootItems > 0 then
				inst.components.talker:Say("Linh hỏa đang yếu đi... hãy tiếp nhiên liệu!")
			elseif (section == 1 and section > oldSection) and addLootItems > 0 then
				inst.components.talker:Say("Linh hỏa đã bừng tỉnh!")
			elseif (section == 2 and section < oldSection) and addLootItems > 0 and ttk_vhth_starsSpawnHounds == "yes" then
				inst.components.talker:Say("Hãy tiếp nhiên liệu! Chó săn sẽ bảo vệ ta!")
			elseif (section == 2 and section < oldSection) and addLootItems > 0 then
				inst.components.talker:Say("Xin đừng để linh hỏa của ta lụi tàn...")
			elseif (section >= 3 and section < 6 and section > oldSection) and addLootItems > 0 then
				inst.components.talker:Say("Thêm nữa! Linh hỏa đang mạnh lên!")
			elseif (section == 4 and section < oldSection) and addLootItems > 0 then
				inst.components.talker:Say("Linh hỏa đang yếu đi... hãy tiếp nhiên liệu!")
			elseif (section == 6 and section > oldSection) and addLootItems > 0 then
				inst.components.talker:Say("Hàn hỏa của ta đang tỏa sáng!")
			elseif (section == 8 and oldSection < section) and addLootItems > 0 then
				inst.components.talker:Say("Hàn hỏa của ta đang tỏa sáng!")
			end

			oldSection = section
		end
	)
	bonus = ttk_vhth_startFuelIceStar
	if bonus == "nooverride" then
		bonus = ttk_vhth_startFuel
	end
	inst.components.fueled:InitializeFuelLevel(bonus * inst.components.fueled.maxfuel)
	-- Old value: Add a third more starting fuel: TUNING.FIREPIT_FUEL_START + (TUNING.FIREPIT_FUEL_START / 3)
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

	return inst
end

return Prefab("common/objects/ice_star", fn, assets, prefabs), MakePlacer(
	"common/ice_star_placer",
	"ice_star",
	"ice_star",
	"idle"
)
