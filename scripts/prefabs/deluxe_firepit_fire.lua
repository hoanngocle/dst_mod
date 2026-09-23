local assets = {
	Asset("ANIM", "anim/deluxe_firepit_fire.zip"),
	Asset("SOUND", "sound/common.fsb")
}

local lightColour = {255 / 255, 255 / 255, 192 / 255}
--local heats = { 70, 120, 180, 220 }
local heats = {70, 85, 100, 115}
local bonus = ttk_vhth_lightRangeFirepit
if bonus == "nooverride" then
	bonus = ttk_vhth_lightRange
end
local function GetHeatFn(inst)
	--return heats[inst.components.firefx.level] or 20
	return heats[inst.components.firefx.level] or 90
end

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

	inst:AddComponent("firefx")
	inst.components.firefx.levels = {
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
	inst.components.firefx:SetLevel(1)
	inst.components.firefx.usedayparamforsound = true
	return inst
end

return Prefab("common/fx/deluxe_firepit_fire", fn, assets)
