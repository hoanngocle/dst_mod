-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
SetSharedLootTable("ttk_boss_stalker",
{
})
local brain = require "brains/ttk_boss_stalkerziyunbrain"
local nottags = {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function RetargetFn(inst)
    local owner = inst.owner
    return owner ~= nil and FindEntity(inst, 10,
        function(guy)
            return owner:IsValid() and XD_CanAttackTrget(inst,guy)
                and (guy.components.combat:TargetIs(owner) or
                owner.components.combat:TargetIs(guy) or
                guy.components.combat:TargetIs(inst) )
        end,
        { "_combat","_health" },
        nottags
    ) or nil
end
local function OnAttacked(inst, data)
    if data.attacker ~= nil then
        if data.attacker == inst.owner then
        elseif data.attacker.components.combat ~= nil then
            inst.components.combat:SuggestTarget(data.attacker)
        end
    end
end
local function onhit(inst,data)
    if data and data.target and data.target:IsValid() then
        SpawnAt("ttk_boss_stalke_hitfx",data.target)
    end
end
local function IsValidTakendDamage(inst)
    return inst:IsValid() and not inst.components.health:IsDead()
end
local attacktag = {"_combat","_health"}
local noltags =  {"ttk_boss_ziyun","notarget", "noattack", "flight", "invisible", "playerghost"}
local function DoAoeAttck(inst,pt,range,damage,targets,knocker)
	inst.components.combat.ignorehitrange = true
	local dist = math.sqrt(inst:GetDistanceSqToPoint(pt))
	local ents =  TheSim:FindEntities(pt.x, 0, pt.z, range or 4, attacktag,noltags)
	for i, v in ipairs(ents) do
		if (not targets or not targets[v]) and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and XD_CanAttackTrget(inst,v) then
			if targets then
				targets[v] = true
			end
            local damage = damage or inst.components.combat.defaultdamage
            damage = Xd_CalcDamage(inst,damage,v)
			v.components.combat:GetAttacked(inst,damage)
			if knocker then
				v:PushEvent("knockback", { knocker = knocker, radius = 2})
			end
		end
	end
	inst.components.combat.ignorehitrange = false
end
local function commonfn(bank, build, shadowsize, canfight, atriumstalker)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(unpack(shadowsize))
    MakeGhostPhysics(inst, 1000, .75)
    inst.AnimState:SetBank(Boss.Art(bank))
    inst.AnimState:SetBuild(Boss.Art("stalker_shadow_build"))
    inst.AnimState:AddOverrideBuild(Boss.Art(build))
    inst.AnimState:PlayAnimation("idle", true)
    inst:AddTag("notraptrigger")
    inst:AddTag("notarget")
    inst:AddTag("ttk_boss_ziyun")
    inst:SetPrefabNameOverride("ttk_boss_ziyuanboss")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("locomotor")
	inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { allowocean = true, ignorecreep = true }
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed =  3
    inst:AddComponent("health")
    inst.components.health.nofadeout = true
    inst.components.health:SetInvincible(true)
    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(30)
    inst.components.combat:SetAttackPeriod(TUNING.STALKER_ATRIUM_ATTACK_PERIOD)
    inst.components.combat:SetRange(4, 4)
    inst.components.combat:SetRetargetFunction(1,RetargetFn)
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", onhit)
    inst:ListenForEvent("onareaattackother", onhit)
    inst.sounds =
    {
        death = "dontstarve/sanity/death_pop",
        levelup = "dontstarve/sanity/transform/two",
    }
    inst:SetStateGraph("SGttk_boss_stalker_ziyun")
    inst:SetBrain(brain)
    inst.DoAoeAttck = DoAoeAttck
    inst.persists = false
    return inst
end
local function OnSpawnedBy(inst, stalker)
    if stalker then
        inst.owner = stalker
        stalker.mode1_pet = inst
        inst.components.follower:SetLeader(stalker)
        inst:ForceFacePoint(stalker.Transform:GetWorldPosition())
        inst:ListenForEvent("onremove", function()
            if inst and inst:IsValid() then
                inst:Remove()
            end
        end,stalker)
        inst:ListenForEvent("mode_change", function(_,data)
            if data and data.new ~= 1 then
                inst.sg:GoToState("death")
            end
        end,stalker)
        inst:ListenForEvent("onremove", function()
            if stalker and  stalker.mode1_pet == inst then
                stalker.mode1_pet = nil
            end
        end)
    end
end
local SNARE_OVERLAP_MIN = 1
local SNARE_OVERLAP_MAX = 3
local SNAREOVERLAP_TAGS = { "fossilspike", "groundspike" }
local function NoSnareOverlap(x, z, r)
    return #TheSim:FindEntities(x, 0, z, r or SNARE_OVERLAP_MIN, SNAREOVERLAP_TAGS) <= 0
end
local function SpawnSnare(inst, x, z, r, num, target,combattargets)
    local vars = { 1, 2, 3, 4, 5, 6, 7 }
    local used = {}
    local queued = {}
    local count = 0
    local dtheta = PI * 2 / num
    local thetaoffset = math.random() * PI * 2
    local delaytoggle = 0
    local map = TheWorld.Map
    for theta = math.random() * dtheta, PI * 2, dtheta do
        local x1 = x + r * math.cos(theta)
        local z1 = z + r * math.sin(theta)
        if map:IsPassableAtPoint(x1, 0, z1) and not map:IsPointNearHole(Vector3(x1, 0, z1)) then
            local spike = SpawnPrefab("ttk_boss_stalker_ziyunspike")
            spike.Transform:SetPosition(x1, 0, z1)
            spike.targets = combattargets
            spike.owner = inst
            local delay = delaytoggle == 0 and 0 or .2 + delaytoggle * math.random() * .2
            delaytoggle = delaytoggle == 1 and -1 or 1
            local duration = 10
            local variation = table.remove(vars, math.random(#vars))
            table.insert(used, variation)
            if #used > 3 then
                table.insert(queued, table.remove(used, 1))
            end
            if #vars <= 0 then
                local swap = vars
                vars = queued
                queued = swap
            end
            spike:RestartSpike(delay, duration, variation)
            count = count + 1
        end
    end
    if count <= 0 then
        return false
    end
    return true
end
local function SpawnSnares(inst, targets)
    inst.skillmode =  inst.skillmode + 1
    inst.components.timer:StartTimer("skillcdtime",15)
    local count = 0
    local combattargets = {}
    for i, v in ipairs(targets) do
        if v:IsValid() and
            v:IsNear(inst, 12) then
            local x, y, z = v.Transform:GetWorldPosition()
            local islarge = v:HasTag("largecreature")
            local r = v:GetPhysicsRadius(0) + (islarge and 1.5 or .5)
            local num = islarge and 12 or 6
            if NoSnareOverlap(x, z, r + SNARE_OVERLAP_MAX) then
                if SpawnSnare(inst, x, z, r, num, v,combattargets) then
                    inst:DoTaskInTime(0.5,function()
                        local ents = XD_GetDamageTargets(x, y, z,2)
                        for i,v in pairs(ents) do
                            if v:IsValid() and not combattargets[v] and XD_CanAttackTrget(inst,v) then
                                combattargets[v] = true
                                local damage = 10
                                damage = Xd_CalcDamage(inst,damage,v)
                                v.components.combat:GetAttacked(inst,damage)
                            end
                        end
                    end)
                    count = count + 1
                    if count >= 7 then
                        return
                    end
                end
            end
        end
    end
    for i, v in ipairs(AllPlayers) do
        if v:IsValid() and inst:IsNear(v,20) and XD_CanAttackTrget(inst,v) then
            local pos = v:GetPosition()
            for k = 1, 3 do
                local theta = math.random() * 2 * PI
                local radius = 8
                local offset = FindWalkableOffset(pos, theta, radius,6, true)
                if offset == nil then
                    offset = Vector3(0,0,0)
                end
                local projectile = SpawnPrefab("ttk_boss_ziyunminion")
                projectile.Transform:SetPosition((pos+offset):Get())
                projectile:ForceFacePoint(pos)
                projectile:OnSpawnedBy(inst,v)
            end
        end
    end
end
local function invalidtarget(inst,target)
    return target and target:IsValid() and target.components.health and not target.components.health:IsDead()
    and target.components.combat
end
local function SpellSkill(inst, targets)
    local target = targets and targets[1] or nil
    inst.skillmode =  1
    inst.components.timer:StartTimer("skillcdtime",15)
    if inst:IsValid() and  invalidtarget(inst,target) then
        local pt = target:GetPosition()
        local fx = SpawnAt("ttk_boss_aoeent",pt)
        fx:SetPrefabNameOverride(inst.prefab)
        local radius = math.random(2,6)
        local theta = math.random() * 2* PI
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local fx1 = SpawnAt("ttk_boss_guaiwu_rook",pt+offset)
        fx1.owner = inst
        fx1:OnStart(target)
        fx1.ziyuan_aoe = function(pt)
            if inst and inst:IsValid() then
                inst:DoAoeAttck(pt,3.35,70)
            end
        end
        fx:DoTaskInTime(3,function()
            for k= 1 ,2 do
                local radius = math.random(2,6)
                local theta = math.random() * 2* PI
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                local fx1 = SpawnAt("ttk_boss_guaiwu_bishop",pt+offset)
                fx1.owner = inst
                fx1:OnStart(target)
                fx1.ziyuan_aoe = function(pt)
                    if inst and inst:IsValid() then
                        inst:DoAoeAttck(pt,1.75,4)
                    end
                end
            end
        end)
        return true
    end
end
local function atrium_fn()
    local inst = commonfn("stalker", "stalker_atrium_build", { 4, 2 }, true, true)
    inst:SetPrefabNameOverride("stalker_atrium")
    if not TheWorld.ismastersim then
        return inst
    end
    inst.skillmode = 1
    inst._attack_count = 0
    inst.SpawnSnares = SpawnSnares
    inst.SpellSkill = SpellSkill
    inst.OnSpawnedBy = OnSpawnedBy
    inst.IsValidTakendDamage = IsValidTakendDamage
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("skillcdtime",5)
    inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(function(inst)
        local pos = inst.components.knownlocations:GetLocation("spawnpoint")
        if pos ~= nil then
            local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, true, false)
            return offset ~= nil and pos + offset or pos
        end
    end)
    return inst
end
local assets_atrium =
{
    Asset("ANIM", Boss.ArtPath("anim/stalker_basic.zip")),
    Asset("ANIM", Boss.ArtPath("anim/stalker_action.zip")),
    Asset("ANIM", Boss.ArtPath("anim/stalker_atrium.zip")),
    Asset("ANIM", Boss.ArtPath("anim/stalker_shadow_build.zip")),
    Asset("ANIM", Boss.ArtPath("anim/stalker_atrium_build.zip")),
}
local fx_assets_atrium =
{
    Asset("ANIM", Boss.ArtPath("anim/fossil_stalker.zip")),
}
local spike_assets_atrium =
{
    Asset("ANIM", Boss.ArtPath("anim/fossil_spike.zip")),
}
local function DoSpawn(inst,owner)
    inst:DoPeriodicTask(0.1,function()
        inst.level = inst.level + 1
        inst.AnimState:PlayAnimation("1_"..inst.level)
        if inst.level >= 8 then
            local x, y, z = inst.Transform:GetWorldPosition()
            local rot = inst.Transform:GetRotation()
            inst:Remove()
            if owner and owner:IsValid() then
                local stalker = SpawnPrefab("ttk_boss_stalker_ziyun")
                stalker.Transform:SetPosition(x, y, z)
                stalker.Transform:SetRotation(rot)
                stalker.sg:GoToState("resurrect")
                stalker:OnSpawnedBy(owner)
            end
        end
    end,0.1)
end
local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeObstaclePhysics(inst, .45)
    inst.AnimState:SetBank(Boss.Art("fossil_stalker"))
    inst.AnimState:SetBuild(Boss.Art("fossil_stalker"))
    inst.AnimState:PlayAnimation("1_1")
    inst:AddTag("structure")
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.level = 1
    inst.persists = false
    inst.DoSpawn = DoSpawn
    return inst
end
local NUM_VARIATIONS = 7
local PHYSICS_RADIUS = .2
local DAMAGE_RADIUS_PADDING = .5
local function ChangeToObstacle(inst)
    inst:RemoveEventCallback("animover", ChangeToObstacle)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Physics:Stop()
    inst.Physics:SetMass(0)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:Teleport(x, 0, z)
end
local function SpikeLaunch(inst, launcher, basespeed, startheight, startradius)
    local x0, y0, z0 = launcher.Transform:GetWorldPosition()
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local dx, dz = x1 - x0, z1 - z0
    local dsq = dx * dx + dz * dz
    local angle
    if dsq > 0 then
        local dist = math.sqrt(dsq)
        angle = math.atan2(dz / dist, dx / dist) + (math.random() * 20 - 10) * DEGREES
    else
        angle = TWOPI * math.random()
    end
    local sina, cosa = math.sin(angle), math.cos(angle)
    local speed = basespeed + math.random()
    inst.Physics:Teleport(x0 + startradius * cosa, startheight, z0 + startradius * sina)
    inst.Physics:SetVel(cosa * speed, speed * 5 + math.random() * 2, sina * speed)
end
local function OnKill2(inst)
    inst:AddTag("NOCLICK")
    inst.Physics:SetActive(false)
    ErodeAway(inst, 1)
end
local function OnKill(inst)
    SpawnPrefab("erode_ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:DoTaskInTime(.5, OnKill2)
end
local function KillSpike(inst)
    if not inst.killed then
        if inst.basefx ~= nil then
            inst.killed = true
            if inst.task ~= nil then
                inst.task:Cancel()
                inst.task = nil
            end
            inst:RemoveEventCallback("animover", ChangeToObstacle)
            if inst.basefx:IsValid() then
                inst.basefx.AnimState:PlayAnimation("base_pst"..tostring(inst.basefx.variation))
                inst:DoTaskInTime(1, OnKill)
            else
                OnKill(inst)
            end
        else
            inst:Remove()
        end
    end
end
local function StartSpike(inst, duration, variation)
    inst.task = inst:DoTaskInTime(duration, KillSpike)
    if variation > 1 then
        inst.AnimState:OverrideSymbol("bone1", "fossil_spike", "bone"..tostring(variation))
    end
    inst.basefx = SpawnPrefab("fossilspike_base")
    inst.basefx.entity:SetParent(inst.entity)
    inst:ListenForEvent("animover", ChangeToObstacle)
    inst.AnimState:PlayAnimation("fossil_pst")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")
end
local function RestartSpike(inst, delay, duration, variation)
    if inst.task ~= nil then
        inst.task:Cancel()
        if variation == nil then
            variation = math.random(NUM_VARIATIONS)
        elseif variation > NUM_VARIATIONS then
            variation = (variation - 1) % NUM_VARIATIONS + 1
        end
        inst.task = inst:DoTaskInTime(delay or 0, StartSpike, duration, variation)
    end
end
local function spikefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("fossil_spike"))
    inst.AnimState:SetBuild(Boss.Art("fossil_spike"))
    inst.AnimState:PlayAnimation("empty")
    inst.AnimState:SetFinalOffset(1)
    inst.Physics:SetMass(99999)
    inst.Physics:SetCollisionGroup(COLLISION.SMALLOBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:SetCapsule(PHYSICS_RADIUS, 2)
    inst:AddTag("notarget")
    inst:AddTag("groundspike")
    inst:AddTag("fossilspike")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.task = inst:DoTaskInTime(0, StartSpike, 5 + math.random(), math.random(NUM_VARIATIONS))
    inst.RestartSpike = RestartSpike
    inst.KillSpike = KillSpike
    return inst
end
return Prefab("ttk_boss_stalker_ziyun", atrium_fn, assets_atrium),
    Prefab("ttk_boss_stalker_ziyunfx", fxfn, fx_assets_atrium),
    Prefab("ttk_boss_stalker_ziyunspike", spikefn, spike_assets_atrium)
