-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_futu.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_futu_small.zip")),
    Asset("ANIM", Boss.ArtPath("anim/rocky.zip")),
    Asset("ANIM", Boss.ArtPath("anim/rocky_parasite_death.zip")),
    Asset("SOUND", "sound/rocklobster.fsb"),
}
local prefabs =
{
    "ttk_xshj_blueprint",
}
local brain = require "brains/ttk_boss_futubrain"
local smallbrain = require "brains/ttk_boss_futu_smallbrain"
local loot =
{
    "greengem",
    "greengem",
    "greengem",
    "greengem",
    "greengem",
    "orangegem",
    "orangegem",
    "yellowgem",
    "yellowgem",
    "purplegem",
    "purplegem",
    "purplegem",
    "ttk_boss_mgqg",
}
for k = 1, 25 do
    table.insert(loot,"rocks")
end
local function UpdatePlayerTargets(inst)
	local toadd = {}
	local toremove = {}
	local x, y, z = inst.Transform:GetWorldPosition()
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		toremove[k] = true
	end
	for i, v in ipairs(FindPlayersInRange(x, y, z, 30, true)) do
		if toremove[v] then
			toremove[v] = nil
		else
			table.insert(toadd, v)
		end
	end
	for k in pairs(toremove) do
		inst.components.grouptargeter:RemoveTarget(k)
	end
	for i, v in ipairs(toadd) do
		inst.components.grouptargeter:AddTarget(v)
	end
end
local function Retarget(inst)
	UpdatePlayerTargets(inst)
	local target = inst.components.combat.target
	local inrange = target ~= nil and inst:IsNear(target, 6 + target:GetPhysicsRadius(0))
	if target ~= nil and target:HasTag("player") then
		local newplayer = inst.components.grouptargeter:TryGetNewTarget()
		return newplayer ~= nil
			and newplayer:IsNear(inst, inrange and 6 + newplayer:GetPhysicsRadius(0) or 12)
			and newplayer
			or nil,
			true
	end
	local nearplayers = {}
	for k in pairs(inst.components.grouptargeter:GetTargets()) do
		if inst:IsNear(k, inrange and 6 + k:GetPhysicsRadius(0) or 12) then
			table.insert(nearplayers, k)
		end
	end
	return #nearplayers > 0 and nearplayers[math.random(#nearplayers)] or nil, true
end
local SHARE_TARGET_DIST = 30
local function CalcSanityAura(inst, observer)
    return  -TUNING.SANITYAURA_HUGE
end
local function OnAttacked(inst, data)
	if data and data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
			target:HasTag("player") and
			target:IsNear(inst, 6 + target:GetPhysicsRadius(0))) then
			inst.components.combat:SetTarget(data.attacker)
		end
	end
end
local function BabyCount(inst)
    return inst.components.leader.numfollowers
end
local function MakeBaby(inst)
    local angle = (inst.Transform:GetRotation() + 180) * DEGREES
    local prefab = "ttk_boss_spider"
    local spider = inst.components.lootdropper:SpawnLootPrefab(prefab)
    if spider ~= nil then
        local rad = spider:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0) + .25
        local x, y, z = inst.Transform:GetWorldPosition()
        spider.Transform:SetPosition(x + rad * math.cos(angle), 0, z - rad * math.sin(angle))
        spider.sg:GoToState("taunt")
        inst.components.leader:AddFollower(spider)
        if inst.components.combat.target ~= nil then
            spider.components.combat:SetTarget(inst.components.combat.target)
        end
    end
end
local PLAYER_TAGS = { "player" }
local PLAYER_IGNORE_TAGS = { "playerghost" }
local function MaxBabies(inst)
    return 7
end
local function OnDead(inst)
    inst:RemoveallWaveFx()
    inst:RemoveallShaowFx()
    inst:StopYunShi()
end
local function AddWaveFx(inst,fx)
	inst.wangfxs[fx] = true
	fx.owner = inst
end
local function RemoveWaveFx(inst,fx)
	if inst.wangfxs[fx] then
		inst.wangfxs[fx] = nil
		fx.owner = nil
        fx:Despawn()
	end
end
local function RemoveallWaveFx(inst,doattack,damage)
	for fx, v in pairs(inst.wangfxs) do
		fx.owner = nil
        fx:Despawn()
	end
	inst.wangfxs = {}
end
local function OnAttackOther(inst,data)
end
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat","_health" }
local AOE_TARGET_CANT_TAGS = {"structure","INLIMBO", "flight", "invisible", "notarget", "noattack","ttk_futu","playerghost"}
local function DoAoeDamage(inst,range,damage,checkfn,attackfn,pos)
    if not inst:IsValid() then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    if pos then
        x, z = pos.x,pos.z
    end
    local ents = TheSim:FindEntities(x, y, z, range or 3, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
    for i,v in pairs(ents) do
        if  v:IsValid() and (not checkfn or checkfn(inst,v)) and XD_CanAttackTrget(inst,v) then
            local damage = damage or inst.components.combat.defaultdamage
            damage = Xd_CalcDamage(inst,damage,v)
            v.components.combat:GetAttacked(inst,damage)
            if attackfn then
                attackfn(inst,v)
            end
        end
    end
end
local function DestroySink(inst,fx)
    local x, y, z = fx.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3.5, {"ttk_boss_sandspike_futu"}, {"structure","INLIMBO", "invisible","playerghost"})
    for i,v in pairs(ents) do
        if  v:IsValid() then
            if v.GoDeath then
                v:GoDeath()
            else
                inst:RemoveShaowFx(v)
            end
        end
    end
end
local function ReSet(inst,removepets)
    inst:RemoveallWaveFx()
    inst:RemoveallShaowFx()
    inst:StopYunShi()
    for pet,v in pairs(inst.components.leader.followers) do
        if pet:IsValid() and pet.GoDeath then
            pet:GoDeath()
        end
    end
    inst.skillmode = 1
	inst.components.timer:StopTimer("skill")
	inst.components.timer:StartTimer("skill", 12)
end
local function GoHome(inst)
    if inst.gohometask then
        inst.gohometask:Cancel()
    end
    inst.gohometask = inst:DoTaskInTime(2,function()
        inst.gohometask = nil
        inst.reset = false
    end)
    inst:ReSet()
	inst.components.health:SetPercent(1)
    inst.sg:GoToState("gohome")
    if inst.components.combat ~= nil then
        inst.components.combat:SetTarget(nil)
        inst.components.combat:BlankOutAttacks(2)
    end
end
local function StartYunShi(inst)
    if inst.yunshi_task then
        inst.yunshi_task:Cancel()
    end
    inst.ysnum = 0
    inst.yunshi_task = inst:DoPeriodicTask(1,function()
        for k = 1, 8 do
            inst:DoTaskInTime(math.random(),function()
                local map = TheWorld.Map
                local pos = inst:GetPosition()
                local offset = FindValidPositionByFan(math.random() * 2 * PI,math.random(28),32,function(offset)
                    local pt = Vector3(pos.x + offset.x, 0, pos.z + offset.z)
                    return true
                end)
                if offset then
                    pos = pos + offset
                end
                local fx = SpawnAt("ttk_boss_stmeteor",pos)
                fx.owner = inst
                fx.damagefn = function(pos)
                    inst:DoAoeDamage(3.5,45,nil,nil,pos)
                end
            end)
        end
        inst.ysnum = inst.ysnum + 1
        if inst.ysnum >= 25 then
            if inst.yunshi_task then
                inst.yunshi_task:Cancel()
                inst.yunshi_task = nil
            end
        end
    end)
end
local function StopYunShi(inst)
    if inst.yunshi_task then
        inst.yunshi_task:Cancel()
        inst.yunshi_task = nil
    end
end
local function SpawnSinkHole(inst)
    local skillpos = {
        {0},
        {-5,5},
        {-10,0,10},
        {-15,-5,5,15},
        {-20,-10,0,10,20},
        {-30,-15,-5,5,15,30},
    }
    local x, y, z = inst.Transform:GetWorldPosition()
    local range = 2
    local facing_angle = inst.Transform:GetRotation()
    inst:StartThread(function()
        for _,v in ipairs(skillpos) do
            for _,rot in ipairs(v) do
                local angle = (facing_angle + rot)* DEGREES
                local x1,y1,z1 = x + range * math.cos(angle),y,z - range * math.sin(angle)
                local fx = SpawnAt("ttk_boss_daywalker_sinkhole",Vector3(x1,y1,z1))
                fx:DoFXCollapse(30)
                inst:DoAoeDamage(3.5,90,nil,nil,Vector3(x1,y1,z1))
                AddWaveFx(inst,fx)
                DestroySink(inst,fx)
            end
            range = range + 3
            Sleep(0.33)
        end
    end)
end
local function SpawnSandSpike(inst,targets)
    for k, v in ipairs(targets) do
        if v:IsValid() then
            local pos = v:GetPosition()
            local fx = SpawnAt("ttk_boss_sandspike",pos)
            fx:AddTag("ttk_boss_sandspike_futu")
            fx.AnimState:SetBuild(Boss.Art("xd_futu_sand_spike"))
            fx.owner = inst
            fx.futuspike = true
            inst:AddShadowFx(fx)
            fx.damagefn = function(pos)
                inst:DoAoeDamage(1.6,20,nil,nil,pos)
            end
        end
    end
end
local function SpawnRock(inst,targets)
    for k, v in ipairs(targets) do
        if v:IsValid() then
            local pos = v:GetPosition()
            local theta = math.random() * TWOPI
            local radius = 3
            local offset = FindWalkableOffset(pos, theta, radius, 6, true)
            if offset ~= nil then
                pos.x = pos.x + offset.x
                pos.z = pos.z + offset.z
            end
            local rock = SpawnAt("ttk_boss_futu_rock",pos)
            rock.damagefn = function(pos)
                inst:DoAoeDamage(4.5,75,nil,nil,pos)
                if inst:IsValid() and not inst.components.health:IsDead() and v:IsValid() and v.components.health and
                    not v.components.health:IsDead() and BabyCount(inst) < 6 then
                    local monster = SpawnAt("ttk_boss_futu_small",pos)
                    monster:SetTarget(v)
                    monster:AddTag("ttk_boss_sandspike_futu")
                    inst.components.leader:AddFollower(monster)
                    monster:ListenForEvent("death",function()
                        monster.components.health:SetInvincible(false)
                        monster.components.health:Kill()
                    end,inst)
                    monster:ListenForEvent("onremove",function()
                        if monster:IsValid() then
                            monster:Remove()
                        end
                    end,inst)
                end
            end
        end
    end
end
local function doaoefx(inst,fx)
    local pos = fx:GetPosition()
    SpawnAt("groundpoundring_fx",pos)
    local points = XD_GetGroundPoints(pos)
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab("groundpound_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end
end
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat","player" }
local AOE_TARGET_CANT_TAGS = { "INLIMBO", "flight", "invisible", "notarget", "noattack" }
local function CheckShaodows(inst)
	if inst.shadow_count > 0 then
		if not inst.shadowtask then
			inst.shadowtask =  inst:DoPeriodicTask(5,function()
				if inst:IsValid() then
					inst.components.combat.ignorehitrange = true
					local damage = inst.shadow_count * 6
					local x,y,z = inst.Transform:GetWorldPosition()
					local ents = TheSim:FindEntities(x, y, z, 28, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
					for i, v in ipairs(ents) do
						if v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and inst.components.combat:CanTarget(v) then
                            SpawnAt("ttk_boss_baihu_gzfx",v)
							v.components.combat:GetAttacked(inst,damage,nil,"ttk_boss_no_attackedsg")
						end
					end
                    for fx, v in pairs(inst.shadowfxs) do
						if fx:IsValid() then
							SpawnAt("ttk_boss_baihu_gzfx",fx)
						end
					end
					inst.components.combat.ignorehitrange = false
				end
			end,5)
		end
	elseif inst.shadowtask then
		inst.shadowtask:Cancel()
		inst.shadowtask = nil
	end
end
local function AddShadowFx(inst,fx)
	inst.shadowfxs[fx] = true
	fx.owner = inst
	inst.shadow_count = inst.shadow_count + 1
	CheckShaodows(inst)
end
local function doremoveattack(inst,fx,damage)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 28, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
	for i, v in ipairs(ents) do
		if v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and inst.components.combat:CanTarget(v) then
            doaoefx(inst,v)
			v.components.combat:GetAttacked(inst,damage or 40)
		end
	end
end
local function RemoveShaowFx(inst,fx)
	if inst.shadowfxs[fx] then
		inst.shadowfxs[fx] = nil
		fx.owner = nil
        doaoefx(inst,fx)
		doremoveattack(inst,fx)
		fx:OnDeath()
		inst.shadow_count = inst.shadow_count - 1
		CheckShaodows(inst)
	end
end
local function RemoveallShaowFx(inst,doattack,damage)
	for fx, v in pairs(inst.shadowfxs) do
		fx.owner = nil
        doaoefx(inst,fx)
		if doattack then
			doremoveattack(inst,fx,damage)
		end
        fx:OnDeath()
		inst.shadow_count = inst.shadow_count - 1
	end
	inst.shadowfxs = {}
	CheckShaodows(inst)
end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    MakeCharacterPhysics(inst, 1000, 1)
    inst.DynamicShadow:SetSize(4, 2)
    inst.Transform:SetFourFaced()
    local s  = 1.52
    inst.Transform:SetScale(s, s, s)
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("epic")
    inst:AddTag("largecreature")
    inst:AddTag("ttk_futu")
    inst:AddTag("ignore_xd_time_st")
    inst.AnimState:SetBank(Boss.Art("rocky"))
    inst.AnimState:SetBuild(Boss.Art("xd_futu"))
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.lastattack_target = nil
    inst.lastattack_count = 0
    inst.lastattack_time = 0
    inst.skillmode = 1
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(42500)
    -- Normal health persistence: registry encounters survive save/load.
    inst:AddComponent("grouptargeter")
    inst:AddComponent("timer")
    inst:AddComponent("combat")
    inst.components.combat:SetRange(4)
    inst.components.combat:SetDefaultDamage(58.5)
    inst.components.combat:SetAttackPeriod(4)
    inst.components.combat:SetRetargetFunction(2, Retarget)
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -2/10
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = 3/1.52
    inst.components.locomotor.runspeed = 3/1.52
    inst:AddComponent("inventory")
    inst:AddComponent("incrementalproducer")
    inst.components.incrementalproducer.countfn = BabyCount
    inst.components.incrementalproducer.producefn = MakeBaby
    inst.components.incrementalproducer.maxcountfn = MaxBabies
    inst.components.incrementalproducer.incrementdelay = 10
    inst:AddComponent("inspectable")
    inst:AddComponent("leader")
    inst:AddComponent("knownlocations")
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst:SetBrain(brain)
    inst:SetStateGraph("SGttk_futu")
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onattackother",OnAttackOther)
    inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(function(inst)
        local pos = inst.components.knownlocations:GetLocation("spawnpoint")
        if pos ~= nil then
            local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
            return offset ~= nil and pos + offset or pos
        end
    end)
    inst.wangfxs = {}
    inst.AddWaveFx = AddWaveFx
	inst.RemoveWaveFx = RemoveWaveFx
	inst.RemoveallWaveFx = RemoveallWaveFx
    inst.ReSet = ReSet
    inst.shadowfxs = {}
	inst.shadow_count = 0
    inst.AddShadowFx = AddShadowFx
	inst.RemoveShaowFx = RemoveShaowFx
	inst.RemoveallShaowFx = RemoveallShaowFx
    inst.CheckShaodows = CheckShaodows
    inst.SpawnSandSpike = SpawnSandSpike
    inst.SpawnSinkHole = SpawnSinkHole
    inst.StartYunShi = StartYunShi
    inst.SpawnRock = SpawnRock
    inst.StopYunShi = StopYunShi
    inst.DoAoeDamage = DoAoeDamage
    inst.GoHome = GoHome
    inst:AddComponent("ttk_boss_guaiwu_skills")
    inst.components.ttk_boss_guaiwu_skills.first = false
    inst.components.ttk_boss_guaiwu_skills.noskill =  true
    inst.components.ttk_boss_guaiwu_skills.by = 1
    inst.components.ttk_boss_guaiwu_skills.qx = 4
    return inst
end
local TARGET_MUST_TAGS = { "_combat", "character" }
local TARGET_CANT_TAGS = {"INLIMBO"}
local function FindTarget_Small(inst)
    return FindEntity(inst,12,function(guy)
            return (not inst.bedazzled and (not guy:HasTag("monster") or guy:HasTag("player")))
            and not (inst.components.follower ~= nil and inst.components.follower.leader == guy)
                and inst.components.combat:CanTarget(guy)
        end,
        TARGET_MUST_TAGS,
        TARGET_CANT_TAGS
    )
end
local function OnAttackOther_Small(inst,data)
end
local function OnHitOther(inst, data)
    if not data or data.redirected  then
        return
    end
    if  data.target ~= nil and data.target:IsValid() and data.target.components.health and not data.target.components.health:IsDead() then
        data.target:PushEvent("knockback", { knocker = inst, radius = 2})
    end
end
local function GoDeath(inst)
    if not inst.components.health:IsDead() then
        inst.components.health:SetInvincible(false)
        inst.components.health:Kill()
    end
end
local function SpawnSandSpikeSmall(inst,targets)
    for k, v in ipairs(targets) do
        if v:IsValid() then
            local pos = v:GetPosition()
            local fx = SpawnAt("ttk_boss_sandspike",pos)
            fx.AnimState:SetBuild(Boss.Art("xd_futu_sand_spike"))
            fx.animname = "med"
            fx.owner = inst
            fx.futuspike_small = true
            fx.damagefn = function(pos)
                inst:DoAoeDamage(1.3,75,nil,nil,pos)
            end
        end
    end
end
local function smallfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    MakeCharacterPhysics(inst, 1000, 1)
    inst.DynamicShadow:SetSize(2, 0.6)
    inst.Transform:SetFourFaced()
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("ttk_futu")
    inst:AddTag("notarget")
    inst.AnimState:SetBank(Boss.Art("rocky"))
    inst.AnimState:SetBuild(Boss.Art("xd_futu_small"))
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("lootdropper")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(500)
    inst.components.health:SetInvincible(true)
    inst:AddComponent("timer")
    inst:AddComponent("combat")
    inst.components.combat:SetRange(3)
    inst.components.combat:SetDefaultDamage(65)
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRetargetFunction(2, FindTarget_Small)
    local old_SetTarget =  inst.components.combat.SetTarget
    inst.components.combat.SetTarget = function(self,target,...)
        if inst.target ~= nil and target ~= inst.target then
            return false
        end
        return old_SetTarget(self,target,...)
    end
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -2/10
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 1.5
    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    inst:AddComponent("follower")
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst:SetBrain(smallbrain)
    inst:SetStateGraph("SGttk_futu")
    inst.SetTarget = function(inst,target)
        inst.target = target
        inst.components.combat:SetTarget(target)
    end
    inst:ListenForEvent("onhitother", OnHitOther)
    inst:PushEvent("loseloyalty", function()
        GoDeath(inst)
    end)
    inst.DoAoeDamage = DoAoeDamage
    inst.GoDeath = GoDeath
    inst.SpawnSandSpikeSmall = SpawnSandSpikeSmall
    inst:DoTaskInTime(120,function()
        GoDeath(inst)
    end)
    inst.persists = false
    return inst
end
local DRAGONFLY_SPAWNTIMER = "regen_xd_futu"
local function StartSpawning(inst)
    inst.components.timer:StartTimer(DRAGONFLY_SPAWNTIMER, TUNING.XD_BOSS_FUTU_RESPAWNTIME)
end
local function GenerateNewDragon(inst)
    inst.components.childspawner:AddChildrenInside(1)
    inst.components.childspawner:StartSpawning()
end
local function ontimerdone(inst, data)
    if data.name == DRAGONFLY_SPAWNTIMER then
        GenerateNewDragon(inst)
    end
end
local function onspawned(inst, child)
    if child and child.components.knownlocations then
        child.components.knownlocations:RememberLocation("spawnpoint", inst:GetPosition(),true)
        child:PushEvent("entershield")
    end
end
local function spawnerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("CLASSIFIED")
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ttk_futu"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(1, 0)
    inst.components.childspawner.onchildkilledfn = StartSpawning
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner:StopRegen()
    inst.components.childspawner:SetSpawnedFn(onspawned)
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    return inst
end
return Prefab("ttk_futu", fn, assets, prefabs),
    Prefab("ttk_boss_futu_small", smallfn, assets, prefabs)
