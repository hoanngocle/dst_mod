-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
local brain = require "brains/ttk_boss_swordbrain"
local FORMATION_MAX_SPEED = 30
local FORMATION_RADIUS = 2.6
local FORMATION_ROTATION_SPEED = 1.33
local function GetTargetPos(inst,leader)
	if inst.sg and inst.sg.statemem.attackpos  then
		return inst.sg.statemem.attackpos
	end
	local leader = leader or inst.components.follower and inst.components.follower:GetLeader() or nil
	if leader and leader:IsValid() then
        local index = inst.index
        local maxpets = inst.maxpets
        local theta = (index / maxpets) * TWOPI + (inst.thetarante or 1) * GetTime() * FORMATION_ROTATION_SPEED * (inst.speedrate or 1)
        local lx, ly, lz = leader.Transform:GetWorldPosition()
		local range  = inst.range or FORMATION_RADIUS
        lx, lz = lx + range * math.cos(theta), lz + range * math.sin(theta)
		return Vector3(lx, 0, lz)
	end
end
local function set_velocity_world_coordinate(inst, angle, velocity, vy)
	vy = vy or 0
	local face_angle = inst.Transform:GetRotation()
	local theta = (angle - face_angle)*DEGREES
	local vx = velocity * math.cos(theta)
	local vz = velocity * (-math.sin(theta))
	inst.Physics:SetMotorVel(vx, vy, vz)
end
local function cal_angle(start, dest)
	local x1 = start.x
	local z1 = start.z
	local x2 = dest.x
	local z2 = dest.z
	local angle=math.atan2(z1-z2,x2-x1)/DEGREES
	return angle
end
local function OnUpdate(inst, dt)
	if inst._marked_for_despawn then
		return
	end
    local leader = inst.components.follower and inst.components.follower:GetLeader() or nil
	if leader and leader:IsValid() and inst.index and inst.maxpets then
		local pos = GetTargetPos(inst,leader)
        local lx, lz = pos.x,pos.z
        local px, py, pz = inst.Transform:GetWorldPosition()
		if inst.sg.statemem.attackpos then
			inst.Physics:SetMotorVel(inst.sg.statemem.attackspeed or 0,0,0)
		else
			local dx, dz = px - lx, pz - lz
			local dist = math.sqrt(dx*dx + dz*dz)
			if inst.goback then
				if dist < 1 then
					inst.goback = false
				end
			else
			end
			inst.Physics:SetMotorVel(math.min(dist * 20,  FORMATION_MAX_SPEED),0,0)
		end
		if not inst.busy then
        	inst:FacePoint(lx, 0, lz)
		end
        if inst.updatecomponents[inst.components.locomotor] == nil then
        end
    end
end
local function DoSpawn(inst)
	if not inst.nofx then
		SpawnAt("ttk_boss_spawn_fx_medium_static",inst)
		inst:DoTaskInTime(0.2,function()
			inst:Show()
		end)
	else
		inst.AnimState:SetMultColour(1, 1, 1, 0)
		inst.components.colourtweener:StartTween({1,1,1,1}, 0.5, function()
		end)
	end
end
local TWEEN_TARGET = {0, 0, 0, 1}
local TWEEN_TIME = 13 * FRAMES
local function DeSpawn(inst)
	if not inst.nofx then
		SpawnAt("ttk_boss_spawn_fx_medium_static",inst)
	end
	inst._marked_for_despawn = true
	inst.Physics:Stop()
    inst.components.colourtweener:StartTween(TWEEN_TARGET, TWEEN_TIME, inst.Remove)
end
local function spawnwisp(owner)
    if owner:IsValid() then
		local r,g,b,a = owner.AnimState:GetMultColour()
		if a and a == 1 and not owner._hiding  then
        	local wisp = SpawnPrefab("ttk_boss_vortex_fx")
        	if owner.colour then
            	wisp.AnimState:SetBuild(Boss.Art("xd_vortex_fx_white"))
            	wisp.AnimState:SetMultColour(unpack(owner.colour))
        	end
        	local x,y,z = owner.Transform:GetWorldPosition()
        	wisp.Transform:SetPosition(x+math.random()*0.25 -0.25/2,y + 0.5 + math.random()*0.25 -0.25/2,
			z+math.random()*0.25 -0.25/2)
		end
    end
end
local colours = {
	ttk_boss_sword_red = {255/255,193/255,39/255,1},
	ttk_boss_sword_green = {127/255,204/255,194/255,1},
	ttk_boss_sword_blue = {115/255,58/255,235/255,1},
	ttk_boss_sword_mo = {0/255,0/255,0/255,1},
}
local function doaoe(inst)
	if inst.owner and inst.owner:IsValid() then
		local pos = inst:GetPosition()
		local ents = XD_GetDamageTargets(pos.x, 0, pos.z, 2)
		for i, v in pairs(ents) do
			if v  and v:IsValid() and (not v.htz_rotationsword_time or GetTime() - v.htz_rotationsword_time > 0.33 )and v ~= inst.owner and XD_CanAttackTrget(inst.owner, v) then
				v.htz_rotationsword_time =  GetTime()
				local damage = 17
				damage = Xd_CalcDamage(inst.owner,damage,v)
				v.components.combat:GetAttacked(inst.owner, damage)
			end
		end
	end
end
local function MakeNoPhysics(inst, mass, rad)
	mass = mass or 1
    rad = rad or .5
    local physics = inst.entity:AddPhysics()
	physics:SetMass(mass)
    physics:SetCapsule(0.5, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:ClearCollisionMask()
	inst.Physics:SetCollisionMask(COLLISION.GROUND)
end
local function makesword(name,builds,s,bank)
	local  assets = {
		Asset("ANIM", Boss.ArtPath("anim/"..name..".zip")),
	}
	if builds then
		for _,v in ipairs(builds) do
			table.insert(assets,Asset("ANIM", Boss.ArtPath("anim/"..v..".zip")))
		end
	end
	local function fn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()
		MakeNoPhysics(inst)
		inst.Transform:SetFourFaced(inst)
		inst.AnimState:SetBank(Boss.Art(bank or name))
		inst.AnimState:SetBuild(Boss.Art(bank or name))
		inst.AnimState:PlayAnimation("idle")
		inst.AnimState:SetScale(s, s, s)
		if builds then
			for k, v in ipairs(builds) do
				inst.AnimState:AddOverrideBuild(Boss.Art(v))
			end
		end
		if bank then
			inst.AnimState:AddOverrideBuild(Boss.Art(name))
		end
		inst:AddTag("fx")
		inst:AddTag("NOBLOCK")
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end
		inst:SetStateGraph("SGttk_boss_sword")
		inst.persists = false
		inst:AddComponent("knownlocations")
		local follower = inst:AddComponent("follower")
		follower:KeepLeaderOnAttacked()
		follower.keepdeadleader = true
		follower.keepleaderduringminigame = true
		if name ~= "ttk_boss_sword_mo" then
			local updatelooper = inst:AddComponent("updatelooper")
			updatelooper:AddOnUpdateFn(OnUpdate)
		else
			inst:AddComponent("locomotor")
			inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED
			inst.components.locomotor:SetTriggersCreep(false)
			inst.components.locomotor.pathcaps = {  allowocean = true, ignorecreep = true }
			inst.components.locomotor:SetSlowMultiplier(.6)
			inst:SetBrain(brain)
		end
		inst:AddComponent("colourtweener")
		inst.GetTargetPos = GetTargetPos
		inst.skinsymbol = "png"
		inst.SetSkin = function(inst,skin)
			if skin then
				inst.build = name
				inst.skin = skin
				inst.AnimState:OverrideSymbol(inst.skinsymbol, inst.build.."_"..skin, inst.skinsymbol)
				if skin == "duanzui" and not inst._fxtask then
					inst.colour = colours[name] or {1,1,1,1}
					inst._fxtask = inst:DoPeriodicTask(0.2,spawnwisp,0.2)
				end
			end
		end
		if name == "ttk_boss_htz_rotationsword" then
			inst:DoPeriodicTask(1/3,doaoe)
		end
		inst.DoSpawn = DoSpawn
		inst.DeSpawn = DeSpawn
		return inst
	end
	return Prefab(name,fn,assets)
end
local function extractSubstring(str)
    local lastUnderscore = str:match("source_34")
    if lastUnderscore then
        return lastUnderscore
    end
    return nil
end
local function builder_onbuilt(inst, builder)
	if builder and builder.components.ttk_boss_level and builder.components.ttk_boss_level.level >= 12 then
		builder.components.ttk_boss_sword_controller:Summon(inst.mode,inst.linked_skinname and extractSubstring(inst.linked_skinname) or nil)
	end
    inst:Remove()
end
local function MakeBuilder(prefab,mode)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst:AddTag("CLASSIFIED")
        inst.persists = false
        inst:DoTaskInTime(0, inst.Remove)
        if not TheWorld.ismastersim then
            return inst
        end
		inst.mode = mode
        inst.pettype = prefab
        inst.OnBuiltFn = builder_onbuilt
        return inst
    end
    return Prefab(prefab.."_builder", fn,
	{
		Asset("ATLAS", "images/inventoryimages/xd_xianjian_builder.xml"),
		Asset("ATLAS", "images/inventoryimages/xd_mo_builder.xml"),
	})
end
return makesword("ttk_boss_sword_red",nil,1.257),
	makesword("ttk_boss_sword_green",nil,1.257),
	makesword("ttk_boss_sword_blue",nil,1.257),
	makesword("ttk_boss_sword_fj",nil,1.257,"ttk_boss_sword_green"),
	makesword("ttk_boss_htz_rotationsword",nil,1.257),
	makesword("ttk_boss_sword_mo",{"ttk_boss_sword_mo_bz","ttk_boss_sword_mo_skill"},1.257),
	MakeBuilder("ttk_boss_xianjian",1),
	MakeBuilder("ttk_boss_mo",2)
