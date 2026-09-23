-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_GetGroundPoints = Boss.XD_GetGroundPoints
require "prefabutil"
local assets_robin =
{
    Asset("ANIM", Boss.ArtPath("anim/mutated_robin.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_jcbird_spitter.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_jcbird.zip")),
}
local assets_crow =
{
    Asset("ANIM", Boss.ArtPath("anim/mutated_crow.zip")),
}
local prefabs =
{
	"ttk_boss_jcbird_spittersplat",
}
SetSharedLootTable( 'ttk_boss_jcbird',
{
})
local brain = require "brains/ttk_boss_jcbirdbrain"
local easing = require("easing")
local function LaunchProjectile(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()
    local projectile = SpawnPrefab("ttk_boss_jcbird_spittersplat")
    projectile.Transform:SetPosition(x, y, z)
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.FIRE_DETECTOR_RANGE
    local speed = easing.linear(rangesq, 15, 1, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-35)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
    projectile.shooter = inst
end
local function IsNearInvadeTarget(inst, dist)
    local target = inst.components.entitytracker:GetEntity("swarmTarget")
    return target == nil or inst:IsNear(target, dist)
end
local RETARGET_MUST_TAGS = { "_combat" }
local INVADER_RETARGET_CANT_TAGS = { "playerghost", "INLIMBO"}
local function Retarget(inst)
        return   FindEntity(
                inst,
                16,
                function(guy)
                    if inst.components.combat:CanTarget(guy) and guy:HasTag("player") or (guy.components.follower and guy.components.follower:GetLeader() and guy.components.follower:GetLeader():HasTag("player")) then
                        return guy
                    end
                end,
                RETARGET_MUST_TAGS,
                INVADER_RETARGET_CANT_TAGS
            )
        or nil
end
local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
end
local function commonPreMain(inst)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.entity:AddDynamicShadow()
    inst.sounds =
    {
        flyin = "dontstarve/birds/flyin",
        chirp = "moonstorm/creatures/mutated_crow/chirp",
        takeoff = "moonstorm/creatures/mutated_crow/take_off",
        attack = "moonstorm/creatures/mutated_crow/attack",
    }
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:SetMass(1)
    inst.Physics:SetSphere(1)
	inst:AddTag("NOBLOCK")
	inst:AddTag("soulless")
	inst:AddTag("hostile")
    inst:AddTag("monster")
    inst:AddTag("scarytoprey")
    inst:AddTag("ttk_boss_skill_pet")
    inst:AddTag("avoid_jfsnfire")
    inst:AddTag("ttk_boss_jfsnpet")
    inst.Transform:SetFourFaced()
    
    
    
    inst.DynamicShadow:SetSize(1, .75)
    inst.DynamicShadow:Enable(false)
	return inst
end
local function commonPostMain(inst)
    inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.MUTANT_BIRD_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.MUTANT_BIRD_WALK_SPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(true)
    inst.components.locomotor:SetTriggersCreep(true)
	inst:AddComponent("health")
    inst:AddComponent("entitytracker")
    inst:AddComponent("timer")
	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(40)
    inst:AddComponent("lootdropper")
	inst:AddComponent("knownlocations")
    inst:SetStateGraph("SGttk_boss_jcbird")
    inst:SetBrain(brain)
    inst.persists = false
    return inst
end
local function doxd_fireringdamage(inst,pt,points,ignite,damage,range)
    SpawnPrefab("firering_fx").Transform:SetPosition(pt:Get())
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp_voice")
    local map = TheWorld.Map
    for i, v1 in ipairs(points) do
        for i,v in ipairs(v1) do
            if map:IsLandTileAtPoint(v:Get()) and not map:IsDockAtPoint(v:Get()) then
                SpawnPrefab("firesplash_fx").Transform:SetPosition(v.x, 0, v.z)
            end
        end
    end
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z,range or 8,{"_health","_combat"},{ "FX", "NOCLICK", "DECOR", "INLIMBO","avoid_jfsnfire" })
    for k,v in pairs(ents) do
        if v.components.health ~= nil and not v.components.health:IsDead() then
            local attacker = inst.owner and inst.owner:IsValid() and inst.owner or inst
            if attacker and attacker.components.combat and attacker.components.combat:CanTarget(v) then
                local olddamage
                if damage ~= attacker.components.combat.defaultdamage then
                    olddamage = attacker.components.combat.defaultdamage
                    attacker.components.combat:SetDefaultDamage(damage)
                end
                attacker.components.combat.ignorehitrange = true
                attacker.components.combat:DoAttack(v)
                attacker.components.combat.ignorehitrange = false
                if olddamage and attacker.components.combat then
                    attacker.components.combat:SetDefaultDamage(olddamage)
                end
                if ignite and not (v.components.health and v.components.health:IsDead()) and v.components.burnable then
                    if not v.components.burnable:IsBurning() and (v.components.burnable.canlight or v.components.combat ~= nil) then
                        v.components.burnable:Ignite(true, attacker)
                    end
                end
            end
        end
    end
end
local function ondeath(inst)
    local boss = inst.components.entitytracker:GetEntity("ttk_jfsn")
    if boss and not boss.components.health:IsDead() then
        local pt = inst:GetPosition()
        local points = XD_GetGroundPoints(pt,3,1.5,1.5)
        local tauntfx = SpawnPrefab("tauntfire_fx")
        tauntfx.Transform:SetPosition(pt:Get())
        tauntfx.Transform:SetRotation(inst.Transform:GetRotation())
        doxd_fireringdamage(inst,pt,points,nil,50)
        if boss.OnPetDeath then
            boss:OnPetDeath()
        end
    end
end
local function qianghua(inst)
    if not inst.qianghua and not inst.components.health:IsDead() then
        inst.qianghua = true
        if not inst.fx then
            inst.fx = SpawnPrefab("ttk_boss_jcbird_fire")
            inst.fx.entity:SetParent(inst.entity)
            inst.fx.persists = false
            inst.fx.AnimState:PlayAnimation("level1_controlled_burn",true)
            inst.components.combat.externaldamagemultipliers:SetModifier(inst, 1.25)
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "ttk_jfsn", 1.25)
            if inst:HasTag("spitter") then
                inst.components.health.nofadeout = true
                inst.components.health.minhealth =  1
                local old_percent = inst.components.health:GetPercent()
                inst.components.health.maxhealth = inst.components.health.maxhealth + math.ceil(inst.components.health.maxhealth*0.25)
                inst.components.health:SetPercent(old_percent)
            end
        end
    end
end
local function onattacked(inst,data)
    if data and data.attacker and data.attacker:HasTag("ttk_jfsn") and not inst.components.health:IsDead() then
        inst.components.health:Kill()
    end
end
local function runnerfn()
	local inst = CreateEntity()
	inst = commonPreMain(inst)
    inst.AnimState:SetBuild(Boss.Art("xd_jcbird"))
    inst.AnimState:SetBank(Boss.Art("mutated_crow"))
    inst.AnimState:PlayAnimation("idle", true)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst = commonPostMain(inst)
    inst.components.health:SetMaxHealth(3300)
    inst:ListenForEvent("death",ondeath)
    inst:ListenForEvent("attacked",onattacked)
    inst:DoPeriodicTask(0.5,function()
        if not inst.components.health:IsDead() and inst.boss and inst.boss:IsValid() and inst:IsNear(inst.boss,3) then
            inst.components.health:Kill()
        end
    end)
    inst.QiangHua = qianghua
	return inst
end
local function spitterfn()
	local inst = CreateEntity()
	inst = commonPreMain(inst)
    inst.AnimState:SetBank(Boss.Art("mutated_robin"))
    inst.AnimState:SetBuild(Boss.Art("xd_jcbird_spitter"))
    inst.AnimState:PlayAnimation("idle",true)
    inst.sounds =
    {
        flyin = "dontstarve/birds/flyin",
        chirp = "moonstorm/creatures/mutated_robin/chirp",
        takeoff = "moonstorm/creatures/mutated_robin/take_off",
        attack = "moonstorm/creatures/mutated_robin/attack",
        spit_pre = "moonstorm/creatures/mutated_robin/bile_shoot_spin_pre",
    }
    inst:AddTag("spitter")
    inst:AddTag("avoid_jfsndamage")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst = commonPostMain(inst)
    inst.components.health:SetMaxHealth(1000)
    inst.components.combat:SetAttackPeriod(TUNING.MUTANT_BIRD_ATTACK_COOLDOWN)
	inst.components.combat:SetRange(3)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetRange(12)
	inst.LaunchProjectile = LaunchProjectile
    inst.QiangHua = qianghua
    inst.targetdist = 10
    inst.maxdist = 6
	return inst
end
local function OnHitBile(inst, attacker, target)
    local pt = inst:GetPosition()
    SpawnAt("bile_splash",pt)
    if inst:IsOnOcean() then
        SpawnAt("bile_puddle_water",pt)
    else
        SpawnAt("bile_puddle_land",pt)
    end
    local fire = SpawnAt(inst.shooter and inst.shooter.fireprefab or  "ttk_boss_jfsn_fire",pt)
    fire.owner = inst.shooter
    if fire.SetOther then
        fire:SetOther()
    end
    if inst.shooter and inst.shooter.damage then
        fire.damage = inst.shooter.damage
    end
    inst:Remove()
end
local function splatfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetDontRemoveOnSleep(true)
    inst:AddTag("projectile")
    inst:AddTag("NOCLICK")
    inst.AnimState:SetBank(Boss.Art("bird_bileshoot"))
    inst.AnimState:SetBuild(Boss.Art("bird_bileshoot"))
    inst.AnimState:PlayAnimation("spin_pre",false)
    inst.AnimState:PlayAnimation("spin_loop",true)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("locomotor")
    inst:AddComponent("wateryprotection")
    inst:AddComponent("complexprojectile")
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.5, 0))
    inst.components.complexprojectile:SetOnHit(OnHitBile)
    return inst
end
local function firefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank(Boss.Art("fire"))
    inst.AnimState:SetBuild(Boss.Art("fire"))
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(FINALOFFSET_MAX)
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    return inst
end
local function fire1fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("wilson"))
    inst.AnimState:SetBuild(Boss.Art("willow_pyrocast"))
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:PlayAnimation("pyrocast")
    inst:AddTag("FX")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("lootdropper")
    inst.components.lootdropper.min_speed = 1
    inst.components.lootdropper.max_speed = 3
    inst:ListenForEvent("animover",function(inst)
        if inst.owner then
            inst.owner.jfsn_bird_task =  nil
            if inst.boss and inst.boss:IsValid() and not inst.boss.components.health:IsDead() then
                local fire = inst.components.lootdropper:SpawnLootPrefab("ttk_boss_jfsn_fire")
                fire:SetBird("ttk_boss_jcbird",inst.boss)
                fire = inst.components.lootdropper:SpawnLootPrefab("ttk_boss_jfsn_fire")
                fire.boss = inst.boss
                fire:SetBird("ttk_boss_jcbird_spitter",inst.boss)
                fire = inst.components.lootdropper:SpawnLootPrefab("ttk_boss_jfsn_fire")
                fire.boss = inst.boss
                fire:SetBird("ttk_boss_jcbird_spitter",inst.boss)
            end
        end
        inst:Remove()
    end)
    inst.persists = false
    return inst
end
return Prefab("ttk_boss_jcbird", runnerfn, assets_crow, prefabs),
       Prefab("ttk_boss_jcbird_spitter", spitterfn, assets_robin, prefabs),
       Prefab("ttk_boss_jcbird_spittersplat", splatfn),
       Prefab("ttk_boss_jcbird_fire", firefn) ,
       Prefab("ttk_boss_jcbird_fire_over", fire1fn)
