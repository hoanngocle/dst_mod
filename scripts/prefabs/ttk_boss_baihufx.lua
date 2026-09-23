-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets =
{
	Asset("ANIM", Boss.ArtPath("anim/xd_baihu_fx.zip")),
}
local function swordfx(name,anim,scale,bloom)
	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()
		inst.Transform:SetFourFaced(inst)
		inst.AnimState:SetBank(Boss.Art("xd_baihu_fx"))
		inst.AnimState:SetBuild(Boss.Art("xd_baihu_fx"))
		inst.AnimState:PlayAnimation(anim or "idle")
		if scale then
			inst.Transform:SetScale(scale, scale, scale)
		end
		if bloom then
			inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
		end
		inst.AnimState:SetFinalOffset(1)
		inst:AddTag("fx")
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end
		inst:ListenForEvent("animover", inst.Remove)
		inst.persists = false
		inst:DoTaskInTime(3, inst.Remove)
		return inst
	end
	return Prefab(name,fn,assets)
end
return	swordfx("ttk_boss_baihu_fsfx","fs",8),
	swordfx("ttk_boss_baihu_cjfx","chuiji",2.5),
	swordfx("ttk_boss_baihu_gzfx","gz",3.75)
