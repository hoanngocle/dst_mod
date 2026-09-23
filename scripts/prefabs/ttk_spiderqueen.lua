-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_TELE_PLAYER = Boss.XD_TELE_PLAYER
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/spider_queen_build.zip")),
    Asset("ANIM", Boss.ArtPath("anim/spider_queen.zip")),
    Asset("ANIM", Boss.ArtPath("anim/spider_queen_2.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_spiderqueen.zip")),
    Asset("ANIM", Boss.ArtPath("anim/fx_book_web.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_spiderqueen_wave.zip")),
}
local buffassets =
{
    Asset("ANIM", Boss.ArtPath("anim/xd_spiderqueen_buffents.zip")),
}
local prefabs =
{
    "monstermeat",
    "silk",
    "spiderhat",
    "spidereggsack",
}
local brain = require "brains/ttk_boss_spiderqueenbrain"
local loot =
{
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "silk",
    "silk",
    "silk",
    "silk",
    "silk",
    "silk",
    "greengem",
    "greengem",
    "greengem",
    "orangegem",
    "orangegem",
    "orangegem",
    "yellowgem",
    "yellowgem",
    "yellowgem",
    "purplegem",
    "purplegem",
    "purplegem",
    "purplegem",
    "purplegem",
    "ttk_spider_leg",
    "ttk_spider_leg",
}
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
local function ShareTargetFn(dude)
    return dude.prefab == "ttk_spiderqueen" and not dude.components.health:IsDead()
end
local function OnAttacked(inst, data)
	if data and data.attacker ~= nil then
		local target = inst.components.combat.target
		if not (target ~= nil and
			target:HasTag("player") and
			target:IsNear(inst, 6 + target:GetPhysicsRadius(0))) then
			inst.components.combat:SetTarget(data.attacker)
		end
        inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, ShareTargetFn, 2)
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
    inst:RemoveallShaowFx()
end
local function AddShadowFx(inst,fx)
	inst.wangfxs[fx] = true
	fx.owner = inst
end
local function RemoveShaowFx(inst,fx)
	if inst.wangfxs[fx] then
		inst.wangfxs[fx] = nil
		fx.owner = nil
        fx:Despawn()
	end
end
local function RemoveallShaowFx(inst,doattack,damage)
	for fx, v in pairs(inst.wangfxs) do
		fx.owner = nil
        fx:Despawn()
	end
	inst.wangfxs = {}
end
local function OnAttackOther(inst,data)
    local target = data and data.target
    if not (target and target:IsValid()) then
        return
    end
    if target ~= inst.lastattack_target or (GetTime() - inst.lastattack_time) > 30  then
        inst.lastattack_target = target
        inst.lastattack_count = 1
        inst.lastattack_time = GetTime()
    else
        inst.lastattack_count = inst.lastattack_count + 1
        if inst.lastattack_count >= 3 then
            inst.lastattack_count = 0
            local fx = SpawnAt("ttk_boss_spiderqueen_web",target)
            AddShadowFx(inst,fx)
        end
    end
end
local function CanSpell(inst)
    return not (inst.components.health and inst.components.health:IsDead())
    and not inst.gohometask
end
local function wavefn(inst,targets,pos,rotation)
    local wave = SpawnPrefab("ttk_boss_spiderqueen_wave")
    wave.Transform:SetPosition(pos:Get())
    wave.Transform:SetRotation(rotation)
    wave.Physics:SetMotorVel(5, 0, 0)
    wave.idle_time = 1.5
    wave.owner = inst
    wave.targets = targets
    wave.sg:GoToState("instant_rise")
end
local function PushWave(inst,pos,rotation)
    local postbl = {{6,-90},{2,-90},{2,90},{6,90},}
    local targets = {}
    for k,v in ipairs(postbl) do
        local facing_angle = v[2] * DEGREES
        local pt = Vector3(pos.x + v[1] * math.cos(facing_angle), 0, pos.z - v[1] * math.sin(facing_angle))
        wavefn(inst,targets,pt,rotation)
    end
end
local AOE_TARGET_MUSTHAVE_TAGS = { "_combat","_health" }
local AOE_TARGET_CANT_TAGS = {"structure","INLIMBO", "flight", "invisible", "notarget", "noattack","ttk_boss_spider","playerghost"}
local function DoAoeDamage(inst,range,damage,checkfn,attackfn,pos)
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
local function ReSet(inst,removepets)
    inst.skillmode = 1
	inst.components.timer:StopTimer("skill")
	inst.components.timer:StartTimer("skill", 12)
    inst:RemoveallShaowFx()
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
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    MakeCharacterPhysics(inst, 1000, 1)
    inst.DynamicShadow:SetSize(7, 3)
    inst.Transform:SetFourFaced()
    inst:AddTag("cavedweller")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("epic")
    inst:AddTag("smallepic")
    inst:AddTag("largecreature")
    inst:AddTag("spiderqueen")
    inst:AddTag("ttk_boss_spider")
    inst:AddTag("ignore_xd_time_st")
    inst.AnimState:SetBank(Boss.Art("spider_queen"))
    inst.AnimState:SetBuild(Boss.Art("xd_spiderqueen"))
    inst.AnimState:PlayAnimation("idle", true)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.lastattack_target = nil
    inst.lastattack_count = 0
    inst.lastattack_time = 0
    inst.skillmode = 4
    inst:SetStateGraph("SGttk_spiderqueen")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    MakeLargeBurnableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.SPIDER_FLAMMABILITY
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(29500)
    -- Normal health persistence: registry encounters survive save/load.
    inst:AddComponent("grouptargeter")
    inst:AddComponent("timer")
    inst:AddComponent("combat")
    inst.components.combat:SetRange(5)
    inst.components.combat:SetDefaultDamage(75)
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRetargetFunction(2, Retarget)
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura
    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.walkspeed = TUNING.SPIDERQUEEN_WALKSPEED
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true)
    inst:AddComponent("incrementalproducer")
    inst.components.incrementalproducer.countfn = BabyCount
    inst.components.incrementalproducer.producefn = MakeBaby
    inst.components.incrementalproducer.maxcountfn = MaxBabies
    inst.components.incrementalproducer.incrementdelay = 20
    inst:AddComponent("inspectable")
    inst:AddComponent("leader")
    inst:AddComponent("knownlocations")
	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst:SetBrain(brain)
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
    inst.AddShadowFx = AddShadowFx
	inst.RemoveShaowFx = RemoveShaowFx
	inst.RemoveallShaowFx = RemoveallShaowFx
    inst.PushWave = PushWave
    inst.ReSet = ReSet
    inst.CanSpell = CanSpell
    inst.DoAoeDamage = DoAoeDamage
    inst.GoHome = GoHome
    inst:AddComponent("ttk_boss_guaiwu_skills")
    inst.components.ttk_boss_guaiwu_skills.first = false
    inst.components.ttk_boss_guaiwu_skills.noskill =  true
    inst.components.ttk_boss_guaiwu_skills.by = 2
    inst.components.ttk_boss_guaiwu_skills.qx = 4
    return inst
end
local SLOWDOWN_MUST_TAGS = { "locomotor","player" }
local SLOWDOWN_CANT_TAGS = {"flying", "playerghost", "INLIMBO" }
local function doaoedamage(inst, x, y, z,range,damage,attackfn)
    local ents = TheSim:FindEntities(x, y, z, range or 3, AOE_TARGET_MUSTHAVE_TAGS, AOE_TARGET_CANT_TAGS)
    for i,v in pairs(ents) do
        if (not inst.targets or not inst.targets[v]) and inst.owner and inst.owner:IsValid() and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
            if inst.targets then
                inst.targets[v] = true
            end
            local damage = damage or inst.damage or 10
            damage = Xd_CalcDamage(inst.owner,damage,v)
            v.components.combat:GetAttacked(inst.owner,damage)
            if attackfn then
                attackfn(inst,v)
            end
        end
    end
end
local function DoAttack(inst, x, y, z)
    doaoedamage(inst, x, y, z,4,nil)
end
local function OnUpdate(inst, x, y, z)
     for i, v in ipairs(TheSim:FindEntities(x, y, z, 3, SLOWDOWN_MUST_TAGS, SLOWDOWN_CANT_TAGS)) do
         if v.components.locomotor ~= nil then
             v.components.locomotor:PushTempGroundSpeedMultiplier(0.5, WORLD_TILES.MUD)
         end
     end
end
local function OnInit(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoPeriodicTask(0, OnUpdate, nil, x, y, z)
    OnUpdate(inst, x, y, z)
    inst.damagetask = inst:DoPeriodicTask(1, DoAttack, 0.8, x, y, z)
    inst.SoundEmitter:PlaySound("wickerbottom_rework/book_spells/web")
end
local function Despawn(inst)
    if inst.task then
        inst.task:Cancel()
    end
    if inst.damagetask then
        inst.damagetask:Cancel()
    end
    if inst.owner and inst.owner:IsValid() and inst.owner.wangfxs then
        inst.owner.wangfxs[inst] = nil
    end
    inst.AnimState:PlayAnimation("despawn")
    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(3, inst.Remove)
end
local function SetLevel(inst,time,damage)
    if inst.removetask then
        inst.removetask:Cancel()
    end
    inst.removetask = inst:DoTaskInTime(time, Despawn)
    inst.damage = damage
end
local function webfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.Transform:SetRotation(math.random(1, 360))
    local size = 0.8 * 1.3
    inst.Transform:SetScale(size, size, size)
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst:AddTag("NOCLICK")
    inst:AddTag("ttk_boss_spiderqueen_web")
    inst.AnimState:SetBank ("fx_book_web")
    inst.AnimState:SetBuild(Boss.Art("fx_book_web"))
    inst.AnimState:PlayAnimation("spawn")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.SetLevel = SetLevel
    inst.removetask = inst:DoTaskInTime(120, Despawn)
    inst.persists = false
    inst:DoTaskInTime(0, OnInit)
    inst.Despawn = Despawn
    return inst
end
local function DeSmallspawn(inst)
    if inst.task then
        inst.task:Cancel()
    end
    inst.AnimState:PlayAnimation("despawn")
    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(3, inst.Remove)
end
local noltags = {"abigail","companion","player","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
if TheNet:GetPVPEnabled() then
    noltags =  {"INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
end
local function speed_remove_buff(inst)
    if inst._xd_smallweb_speedpot_task ~= nil then
        inst._xd_smallweb_speedpot_task:Cancel()
        inst._xd_smallweb_speedpot_task = nil
    end
    if inst.components.locomotor then
	    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ttk_boss_spiderqueen_smallweb")
    end
end
local function speed_potion(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "ttk_boss_spiderqueen_smallweb", inst.speedrate or 0.25)
    if inst._xd_smallweb_speedpot_task ~= nil then
        inst._xd_smallweb_speedpot_task:Cancel()
        inst._xd_smallweb_speedpot_task = nil
    end
    inst._xd_smallweb_speedpot_task = inst:DoTaskInTime(1, speed_remove_buff)
end
local function OnNotifyNearbyPlayers(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z,4,{"locomotor"},noltags)
    for i, v in ipairs(ents) do
        if v and v:IsValid() and v ~= inst.owner and v.components.locomotor and (not TheNet:GetPVPEnabled() or not (v.components.follower and
        (v.components.follower.leader == inst or v.components.follower.leader == inst.owner) )) then
            if v:HasTag("player") then
                v:PushEvent("unevengrounddetected", { inst = inst, radius = 3, period = 0.6 })
            else
                speed_potion(v)
            end
        end
    end
end
local function smallwebfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.Transform:SetRotation(math.random(1, 360))
    local size = 0.8 * 1.3
    inst.Transform:SetScale(size, size, size)
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst:AddTag("NOCLICK")
    inst:AddTag("ttk_boss_spiderqueen_web")
    inst.AnimState:SetBank ("fx_book_web")
    inst.AnimState:SetBuild(Boss.Art("fx_book_web"))
    inst.AnimState:PlayAnimation("spawn")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.task = inst:DoPeriodicTask(.6, OnNotifyNearbyPlayers, 0.6 * (.3 + .7 * math.random()))
    inst.removetask = inst:DoTaskInTime(10, DeSmallspawn)
    inst.persists = false
    inst.DeSmallspawn = DeSmallspawn
    return inst
end
local function OnRemoveEntity(inst)
    inst.SoundEmitter:KillSound("wave")
end
local function CheckGround(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    doaoedamage(inst, x, y, z,4,37.5,function(inst,target)
        target:PushEvent("knockback", { knocker = inst, radius = 3})
    end)
    local ents = TheSim:FindEntities(x, y, z, 4, {"ttk_boss_spiderqueen_web"}, AOE_TARGET_CANT_TAGS)
    for i,v in pairs(ents) do
        if v and v:IsValid() then
            local fx = SpawnAt("ttk_boss_spiderqueen_cloud",v)
            fx.owner = inst.owner
            v:Remove()
        end
    end
end
local function medfn()
    local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.Transform:SetEightFaced()
    inst.AnimState:SetBuild(Boss.Art("xd_spiderqueen_wave"))
    inst.AnimState:SetBank(Boss.Art("xd_spiderqueen_wave"))
    local size = 1.2
    inst.AnimState:SetScale(size, size, size)
    local phys = inst.entity:AddPhysics()
    phys:SetSphere(1)
    phys:SetCollisionGroup(COLLISION.OBSTACLES)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.WORLD)
    phys:CollidesWith(COLLISION.OBSTACLES)
    phys:CollidesWith(COLLISION.SMALLOBSTACLES)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCollides(false)
    inst:AddTag("scarytoprey")
    inst:AddTag("wave")
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.targets = {}
    inst.damagetask = inst:DoPeriodicTask(0.25, CheckGround)
    inst.damagetask.limit = 16
	inst.persists = false
    inst.OnEntitySleep = inst.Remove
    inst.waveactive = false
    inst:SetStateGraph("SGwave")
    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/wave/LP", "wave")
    inst.SoundEmitter:SetParameter("wave", "size", 0.5)
    inst.OnRemoveEntity = OnRemoveEntity
    return inst
end
local function Stop(inst)
    inst.Physics:Stop()
    inst:Remove()
end
local function RotateToTarget(inst,target)
    if not target:IsValid() then
        return
    end
    local dest = target:GetPosition()
    local direction = dest - inst:GetPosition()
    direction:Normalize()
    local angle = math.acos(direction:Dot(Vector3(1, 0, 0))) / DEGREES
    inst.Transform:SetRotation(angle)
    inst:FacePoint(dest)
end
local function GetDistanceToPoint(inst,x, y, z)
    if x and not y and not z then
        x, y, z = x:Get()
    end
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    if x1 == x and z1 == z then
        return 0
    end
    return math.sqrt((x - x1) ^ 2 + (y - y1) ^ 2 + (z - z1) ^ 2)
end
local function GetSpeed(inst,target)
    if not target:IsValid() then
        return 0
    end
    return GetDistanceToPoint(inst,target:GetPosition())/inst.maxtime
end
local function SpawnEffect(inst,pos)
    SpawnPrefab("ttk_boss_spider_puff_white_back").Transform:SetPosition(pos.x, pos.y - .1, pos.z)
    SpawnPrefab("ttk_boss_spider_puff_white_front").Transform:SetPosition(pos.x, pos.y, pos.z)
end
local function PullPlayer(inst)
    if inst:IsValid() and inst.owner:IsValid() and inst.target:IsValid() and
        inst.owner:CanSpell()  and not IsEntityDeadOrGhost(inst.target) then
        local pos = inst.owner:GetPosition()
        local pt = inst.target:GetPosition()
        local angle = inst.owner:GetAngleToPoint(inst.target:GetPosition())* DEGREES
        local range =  1.5 + inst.owner:GetPhysicsRadius(0)
        SpawnEffect(inst.target,pt)
        pos = Vector3(pos.x+ range * math.cos(angle),pt.y, pos.z - range * math.sin(angle))
        if inst.target.components.locomotor then
            inst.target.components.locomotor:Stop()
        end
        XD_TELE_PLAYER(inst.target,pos)
        if inst.target.SoundEmitter then
            inst.target.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
        end
        SpawnEffect(inst.target,pos)
        local fx = SpawnAt("ttk_boss_spiderqueen_web",pos)
        AddShadowFx(inst.owner,fx)
    end
end
local function Moving(inst)
    if not (inst.target and inst.target:IsValid()) then
        Stop(inst)
        return
    end
    if inst:IsNear(inst.target,2) then
        PullPlayer(inst)
        Stop(inst)
        return
    end
    local ent = FindEntity(inst, 3, nil, {"ttk_boss_spiderqueen_rock"})
	if ent then
        Stop(inst)
        return
    end
    inst.maxtime = math.max(inst.maxtime - FRAMES,FRAMES)
    RotateToTarget(inst,inst.target)
    inst.Physics:SetMotorVel(GetSpeed(inst,inst.target), 0, 0)
end
local function DoThrow(inst,owner,target)
    inst.maxtime = 1.1*0.7
    inst.owner = owner
    inst.target = target
    inst.Physics:ClearCollidesWith(COLLISION.LIMITS)
    RotateToTarget(inst,target)
    inst.Physics:SetMotorVel(GetSpeed(inst,target), 0, 0)
    inst:DoPeriodicTask(0,Moving)
end
local function profn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddPhysics()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)
    inst.entity:SetCanSleep(false)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("xd_spider_pro"))
	inst.AnimState:SetBuild(Boss.Art("xd_spider_pro"))
	inst.AnimState:PlayAnimation("idle1")
	inst:AddTag("projectile")
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
    inst.DoThrow = DoThrow
    inst:DoTaskInTime(3,inst.Remove)
	inst.persists = false
	return inst
end
local function SetOwner(inst,owner)
    inst.entity:SetParent(owner.entity)
    inst.Transform:SetPosition(0,0.7,0)
    inst.owner = owner
end
local function makebuff(name,anim,onground,matserfn)
    local function bufffn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.AnimState:SetBank(Boss.Art("xd_spiderqueen_buffents"))
        inst.AnimState:SetBuild(Boss.Art("xd_spiderqueen_buffents"))
        inst.AnimState:PlayAnimation(anim)
        if onground then
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_BACKGROUND)
        end
        inst:AddTag("fx")
        inst.AnimState:SetFinalOffset(3)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        if matserfn then
            matserfn(inst)
        else
            inst.SetOwner = SetOwner
        end
        inst.persists = false
        return inst
    end
    return Prefab(name,bufffn,buffassets)
end
local function followowner(inst)
    if inst.owner and inst.owner:IsValid() then
        inst.Transform:SetPosition(inst.owner.Transform:GetWorldPosition())
    end
end
local function wavefn(inst)
    inst.SetOwner = function(inst,owner,rotation)
        inst.owner = owner
        inst.Transform:SetRotation(rotation)
    end
    local updatelooper = inst:AddComponent("updatelooper")
    updatelooper:AddOnUpdateFn(followowner)
end
local DRAGONFLY_SPAWNTIMER = "regen_xd_spiderqueen"
local function StartSpawning(inst)
    inst.components.timer:StartTimer(DRAGONFLY_SPAWNTIMER, TUNING.XD_BOSS_SPIDERQUEEN_RESPAWNTIME)
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
    end
end
local function spawnerfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("CLASSIFIED")
    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ttk_spiderqueen"
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
return Prefab("ttk_spiderqueen", fn, assets, prefabs),
    Prefab("ttk_boss_spiderqueen_web", webfn, assets),
    Prefab("ttk_boss_spiderqueen_smallweb", smallwebfn, assets),
    Prefab("ttk_boss_spiderqueen_wave", medfn, assets),
    Prefab("ttk_boss_spiderqueen_pro", profn, assets),
    makebuff("ttk_boss_spiderqueen_buffent1","idle1"),
    makebuff("ttk_boss_spiderqueen_buffent2","idle2"),
    makebuff("ttk_boss_spiderqueen_buffent3","idle3"),
    makebuff("ttk_boss_spiderqueen_waveent","idle4",true,wavefn)
