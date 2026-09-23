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
local RETARGET_CANT_TAGS = { "playerghsot", "ttk_boss_fb_item", }
local function RetargetFn(inst)
    return FindEntity(inst,30,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        nil,
    	RETARGET_CANT_TAGS)
    or nil
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
local noltags =  {"notarget","ttk_boss_fb_item", "noattack", "flight", "invisible", "playerghost"}
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
    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
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
    inst.components.health:SetMaxHealth(32000)
    inst:AddComponent("follower")
    inst.components.follower:KeepLeaderOnAttacked()
    inst.components.follower.keepdeadleader = true
    inst.components.follower.keepleaderduringminigame = true
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(150)
    inst.components.combat:SetAttackPeriod(TUNING.STALKER_ATRIUM_ATTACK_PERIOD)
    inst.components.combat:SetRange(4.8, 5)
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
local function spawnminion(inst)
    if inst.components.health:IsDead() then
        return
    end
    for i, v in ipairs(AllPlayers) do
        if v:IsValid() and inst:IsNear(v,30) and XD_CanAttackTrget(inst,v) then
            local pos = v:GetPosition()
            for k = 1, 3 do
                local theta = math.random() * 2 * PI
                local radius = 8
                local offset = FindWalkableOffset(pos, theta, radius,6, false)
                if offset == nil then
                    offset = Vector3(0,0,0)
                end
                local projectile = SpawnPrefab("ttk_boss_fubenminion")
                projectile.Transform:SetPosition((pos+offset):Get())
                projectile:ForceFacePoint(pos)
                projectile:OnSpawnedBy(inst,v)
            end
        end
    end
end
local function SpawnSnares(inst, targets,nosummon)
    if not nosummon then
        inst.skillmode =  inst.skillmode + 1
        inst.components.timer:StartTimer("skillcdtime",15)
    end
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
                                local damage = 150
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
    if not nosummon then
        spawnminion(inst)
    end
end
local function SpawnFuBenSpikes(inst, pts, level, cache,targets,damagefn)
    for i, v in ipairs(pts) do
        local variation = table.remove(cache.vars, math.random(#cache.vars))
        table.insert(cache.used, variation)
        if #cache.used > 3 then
            table.insert(cache.queued, table.remove(cache.used, 1))
        end
        if #cache.vars <= 0 then
            local swap = cache.vars
            cache.vars = cache.queued
            cache.queued = swap
        end
        local spike = SpawnPrefab("ttk_boss_skill_fossilspike")
        spike.Transform:SetPosition(v:Get())
        spike:RestartSpike(0, variation, level,targets,inst,damagefn)
    end
end
local function GenerateSpiralSpikes(inst)
    local spawnpoints = {}
    local source =  inst
    local x, y, z = source.Transform:GetWorldPosition()
    local spacing = 1.7
    local radius = 2
    local deltaradius = .2
    local angle = 2 * PI * math.random()
    local deltaanglemult = (inst.reversespikes and -2 or 2) * PI * spacing
    inst.reversespikes = not inst.reversespikes
    local delay = 0
    local deltadelay = 2 * FRAMES
    local num = 30
    local map = TheWorld.Map
    for i = 1, num do
        local oldradius = radius
        radius = radius + deltaradius
        local circ = PI * (oldradius + radius)
        local deltaangle = deltaanglemult / circ
        angle = angle + deltaangle
        local x1 = x + radius * math.cos(angle)
        local z1 = z + radius * math.sin(angle)
        if map:IsPassableAtPoint(x1, 0, z1) then
            table.insert(spawnpoints, {
                t = delay,
                level = i / num,
                pts = { Vector3(x1, 0, z1) },
            })
            delay = delay + deltadelay
        end
    end
    return spawnpoints, source
end
local function PlayFlameSound(inst, source)
    source.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/flame")
end
local function SpawnSpikes(inst,damagefn,targets)
    local spikes, source = GenerateSpiralSpikes(inst)
    if #spikes > 0 then
        local cache =
        {
            vars = { 1, 2, 3, 4, 5, 6, 7 },
            used = {},
            queued = {},
        }
        local flames = {}
        local flameperiod = .8
        for i, v in ipairs(spikes) do
            flames[math.floor(v.t / flameperiod)] = true
            inst:DoTaskInTime(v.t, SpawnFuBenSpikes, v.pts, v.level, cache,targets,damagefn)
        end
        if source ~= nil and source.SoundEmitter ~= nil then
            for k, v in pairs(flames) do
                inst:DoTaskInTime(k, PlayFlameSound, source)
            end
        end
    end
end
local function invalidtarget(inst,target)
    return target and target:IsValid() and target.components.health and not target.components.health:IsDead()
    and target.components.combat
end
local function doaoe(inst,pos,range,damage,extrafn,damagefn,consciousnessdamage)
    pos = pos or inst:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range or 4, {"_combat","_health"},noltags)
    for _,v in ipairs(ents) do
        if v ~= nil and invalidtarget(inst,v) and (not damagefn or damagefn(inst,v)) then
            local damage = 150
            damage = Xd_CalcDamage(inst,damage,v)
            v.components.combat:GetAttacked(inst,damage)
            if extrafn then
                extrafn(inst,v)
            end
        end
    end
end
local function dofubenspike(inst)
    local targets = {}
    SpawnSpikes(inst,function(_inst,inst)
        local pt = _inst:GetPosition()
            doaoe(inst,pt,2,15,function(inst,target)
                targets[target] = true
            end,function(inst,target)
                return not targets[target]
            end)
    end,targets)
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
    inst:DoPeriodicTask(10,spawnminion,10)
    inst:DoPeriodicTask(2,dofubenspike,2)
    inst:AddComponent("teleportedoverride")
	inst.components.teleportedoverride:SetDestPositionFn(function(inst)
        local pos = inst.components.knownlocations:GetLocation("spawnpoint")
        if pos ~= nil then
            local offset = FindWalkableOffset(pos, TWOPI * math.random(), 4, 8, false)
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
return Prefab("ttk_stalke_fuben", atrium_fn, assets_atrium)
