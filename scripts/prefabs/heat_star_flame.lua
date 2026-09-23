local assets = {
	Asset("ANIM", "anim/heat_star_flame.zip"),
	Asset("SOUND", "sound/common.fsb")
}

local lightColour = {248 / 255, 197 / 255, 181 / 255}
local heats = {70, 85, 100, 100, 115, 115, 115, 115, 130, 130}
local bonus = ttk_vhth_lightRangeHeatStar
if bonus == "nooverride" then
	bonus = ttk_vhth_lightRange
end

local function GetHeatFn(inst)
	return heats[inst.components.firefx.level] or 100
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("heat_star_flame")
	inst.AnimState:SetBuild("heat_star_flame")
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

	inst:AddComponent("firefx")
	inst.components.firefx.levels = {
		{
			anim = "level1",
			sound = "dontstarve/common/campfire",
			radius = 6 * bonus,
			intensity = 0.7,
			falloff = 0.5,
			colour = lightColour,
			soundintensity = 0.1
		},
		{
			anim = "level2",
			sound = "dontstarve/common/campfire",
			radius = 8 * bonus,
			intensity = 0.8,
			falloff = 0.5,
			colour = lightColour,
			soundintensity = 0.2
		},
		{
			anim = "level3_slow",
			sound = "dontstarve/common/campfire",
			radius = 9 * bonus,
			intensity = 0.8,
			falloff = 0.44,
			colour = lightColour,
			soundintensity = 0.3
		},
		{
			anim = "level3",
			sound = "dontstarve/common/campfire",
			radius = 10 * bonus,
			intensity = 0.8,
			falloff = 0.41,
			colour = lightColour,
			soundintensity = 0.4
		},
		{
			anim = "level4",
			sound = "dontstarve/common/campfire",
			radius = 11 * bonus,
			intensity = 0.9,
			falloff = 0.39,
			colour = lightColour,
			soundintensity = 0.5
		},
		{
			anim = "level4",
			sound = "dontstarve/common/campfire",
			radius = 11.5 * bonus,
			intensity = 0.9,
			falloff = 0.39,
			colour = lightColour,
			soundintensity = 0.6
		},
		{
			anim = "level4_fast",
			sound = "dontstarve/common/campfire",
			radius = 12.5 * bonus,
			intensity = 0.9,
			falloff = 0.39,
			colour = lightColour,
			soundintensity = 0.7
		},
		{
			anim = "level4_fast",
			sound = "dontstarve/common/campfire",
			radius = 13 * bonus,
			intensity = 0.9,
			falloff = 0.37,
			colour = lightColour,
			soundintensity = 0.8
		},
		{
			anim = "level5_slow",
			sound = "dontstarve/common/campfire",
			radius = 13.5 * bonus,
			intensity = 0.9,
			falloff = 0.35,
			colour = lightColour,
			soundintensity = 0.9
		},
		{
			anim = "level5",
			sound = "dontstarve/common/campfire",
			radius = 14 * bonus,
			intensity = 0.9,
			falloff = 0.33,
			colour = lightColour,
			soundintensity = 1
		}
	}
	inst.components.firefx:SetLevel(1)
	inst.components.firefx.usedayparamforsound = true
	return inst
end

return Prefab("common/fx/heat_star_flame", fn, assets)
