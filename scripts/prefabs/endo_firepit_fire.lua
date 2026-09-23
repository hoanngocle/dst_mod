local assets = {
	Asset("ANIM", "anim/endo_firepit_fire.zip"),
	Asset("SOUND", "sound/common.fsb")
}

local lightColour = {25 / 255, 255 / 255, 255 / 255}
local heats = {-25, -35, -40, -55}
local bonus = ttk_vhth_lightRangeEndoFirepit
if bonus == "nooverride" then
	bonus = ttk_vhth_lightRange
end

local function GetHeatFn(inst)
	return heats[inst.components.firefx.level] or -120
end

local firelevels = {
	{
		anim = "level1",
		sound = "dontstarve/common/campfire",
		radius = 4 * bonus,
		intensity = 0.75,
		falloff = 0.5,
		colour = lightColour,
		soundintensity = 0.1
	},
	{
		anim = "level2",
		sound = "dontstarve/common/campfire",
		radius = 6 * bonus,
		intensity = 0.8,
		falloff = 0.45,
		colour = lightColour,
		soundintensity = 0.3
	},
	{
		anim = "level3",
		sound = "dontstarve/common/campfire",
		radius = 8 * bonus,
		intensity = 0.85,
		falloff = 0.4,
		colour = lightColour,
		soundintensity = 0.6
	},
	{
		anim = "level4",
		sound = "dontstarve/common/campfire",
		radius = 10 * bonus,
		intensity = 0.9,
		falloff = 0.35,
		colour = lightColour,
		soundintensity = 1
	}
}

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("deluxe_firepit_fire")
	inst.AnimState:SetBuild("deluxe_firepit_fire")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetRayTestOnBB(true)
	inst.AnimState:SetFinalOffset(1)

	inst:AddTag("FX")

	--HASHEATER (from heater component) added to pristine state for optimization
	inst:AddTag("HASHEATER")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("heater")
	inst.components.heater.heatfn = GetHeatFn
	inst.components.heater:SetThermics(false, true)

	inst:AddComponent("firefx")
	inst.components.firefx.levels = firelevels
	inst.components.firefx:SetLevel(1)
	inst.components.firefx.usedayparamforsound = true

	inst.AnimState:SetAddColour(0.1, 0.5, 1, 1)

	return inst
end

return Prefab("common/fx/endo_firepit_fire", fn, assets)
