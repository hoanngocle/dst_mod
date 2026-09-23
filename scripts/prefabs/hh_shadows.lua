local assets = {
	Asset("ANIM", "anim/lavaarena_boarrior_basic.zip"),
	Asset("ANIM", "anim/igris_dungeon.zip"),
	Asset("ANIM", "anim/igris_shadow.zip"),
	Asset("ANIM", "anim/hh_beru_dungeon.zip"),
	Asset("ANIM", "anim/beru_shadow.zip"),
	Asset("ANIM", "anim/lavaarena_beetletaur.zip"),
	Asset("ANIM", "anim/lavaarena_beetletaur_basic.zip"),
	Asset("ANIM", "anim/lavaarena_beetletaur_actions.zip"),
	Asset("ANIM", "anim/lavaarena_beetletaur_block.zip"),
	Asset("ANIM", "anim/lavaarena_beetletaur_fx.zip"),
	Asset("ANIM", "anim/lavaarena_beetletaur_break.zip"),
}

local brain = require("brains/hh_shadow_brain")
local HH_UTILS = require("utils/hh_utils")

local function MakeShadow(name, bank, build, run_speed, max_health, dmg, sg_name, display_name, init_fn)
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddDynamicShadow()
		inst.entity:AddNetwork()

		MakeCharacterPhysics(inst, 1000, 1.5)
		inst.DynamicShadow:SetSize(3.5, 1.5)
		inst.Transform:SetFourFaced()

		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation("idle_loop", true)

		inst:AddTag("companion")
		inst:AddTag("shadow_minion")

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")
		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = run_speed
		inst.components.locomotor.walkspeed = run_speed * 0.7

		inst:AddComponent("follower")
		inst.components.follower:KeepLeaderOnAttacked()
		inst.components.follower.keepdeadleader = true
		inst.components.follower.keepleaderduringminigame = true

		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(max_health)

		-- Bóng ma không cháy
		inst.components.health.fire_damage_scale = 0

		inst:AddComponent("timer") -- StateGraph yêu cầu timer để tính hồi chiêu

		inst:AddComponent("combat")
		inst.components.combat:SetDefaultDamage(dmg)
		inst.components.combat:SetAttackPeriod(2)
		inst.components.combat:SetRange(4.5)
		local old_DoAttack = inst.components.combat.DoAttack
		inst.components.combat.DoAttack = function(combat, target, ...)
			local actual_target = target or combat.target
			if not HH_UTILS:CanShadowDamageTarget(inst, actual_target) then
				if combat.target == actual_target then
					combat:DropTarget()
				end
				return false
			end
			return old_DoAttack(combat, target, ...)
		end
		inst.components.combat:SetRetargetFunction(1, function(inst)
			-- Tìm kẻ thù xung quanh
			local leader = inst.components.follower.leader
			if leader then
				-- Nếu chủ đang đánh ai, hoặc ai đang đánh chủ -> chọn làm mục tiêu
				local target = leader.components.combat and leader.components.combat.target
				if not target then
					target = FindEntity(
						inst,
						15,
						function(guy)
							return guy.components.combat
								and guy.components.combat.target == leader
								and HH_UTILS:CanShadowDamageTarget(inst, guy)
						end,
						{ "_combat", "_health" },
						{
							"player",
							"companion",
							"shadow_minion",
							"INLIMBO",
							"notarget",
							"noattack",
							"flight",
							"invisible",
						}
					)
				end
				return target ~= nil and HH_UTILS:CanShadowDamageTarget(inst, target) and target or nil
			end
			return nil
		end)
		inst.components.combat:SetKeepTargetFunction(function(inst, target)
			return inst.components.combat:CanTarget(target) and HH_UTILS:CanShadowDamageTarget(inst, target)
		end)

		inst:SetStateGraph(sg_name or "SGhh_igris_shadow")
		inst:SetBrain(brain)

		inst:ListenForEvent("attacked", function(inst, data)
			if data and data.attacker and HH_UTILS:CanShadowDamageTarget(inst, data.attacker) then
				inst.components.combat:SetTarget(data.attacker)
			else
				inst.components.combat:DropTarget()
			end
		end)

		inst:ListenForEvent("killed", function(inst, data)
			HH_UTILS:RelayKillToOwner(inst, data)
		end)

		if display_name then
			inst.name = display_name
		end

		-- Cấm server lưu bóng ma vào save file để tránh nhân bản
		inst.persists = false

		if init_fn then
			init_fn(inst)
		end

		return inst
	end

	return Prefab(name, fn, assets)
end

-- Prefab Xác chết để trích xuất
local function MakeCorpse(name, bank, build, anim_name, display_name)
	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		-- Thêm vật lý để có thể click chuột trúng
		MakeObstaclePhysics(inst, 0.5)

		local death_anim = anim_name or "death2"
		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation(death_anim)
		inst.AnimState:SetPercent(death_anim, 1) -- Đứng yên ở frame cuối

		inst:AddTag("shadow_corpse")
		if display_name then
			inst.name = display_name
		else
			inst.name = "Xác Igris"
		end

		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")

		inst.persists = false
		inst:DoTaskInTime(40, inst.Remove)

		return inst
	end
	return Prefab(name, fn, assets)
end

return MakeShadow("hh_igris_shadow", "boarrior", "igris_shadow", 8, 5000, 300, "SGhh_igris_shadow", "Igris"),
	MakeCorpse("hh_corpse_igris", "boarrior", "ttk_igris_dungeon", "death2", "Xác Igris"),
	MakeShadow("hh_beru_shadow", "beetletaur", "beru_shadow", 9, 10000, 600, "SGhh_beru_shadow", "Beru"),
	MakeCorpse("hh_corpse_beru", "beetletaur", "hh_beru_dungeon", "death", "Xác Beru")
