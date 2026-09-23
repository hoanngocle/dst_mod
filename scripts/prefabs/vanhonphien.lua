-- Adapted from Tu Tien 19.7; see CREDITS.md.
local rules = require("vanhonphien_rules")
local banner_damage = require("vanhonphien_damage")
local banner_attack = require("vanhonphien_attack")

local assets =
{
    Asset("ANIM", "anim/vanhonphien_soul.zip"),     
    Asset("ANIM", "anim/lavaarena_elemental_basic.zip"),   
    Asset("ANIM", "anim/vanhonphien.zip"),
    Asset("ATLAS", "images/inventoryimages/vanhonphien.xml"),
    Asset("IMAGE", "images/inventoryimages/vanhonphien.tex"),      
}

local prefabs =
{
}

local function SaveBanner(inst, data)
    data.soul_count = inst.soul_count or 0
    data.userid = inst._userid
    banner_damage.Save(inst, data)
end

local function LoadBanner(inst, data)
    if data ~= nil then
        inst.soul_count = math.max(0, math.min(2, tonumber(data.soul_count) or 0))
        inst._userid = data.userid
        banner_damage.Load(inst, data)
    end
end

local function TransferState(inst, other)
    banner_damage.Restore(inst)
    local data = {}
    SaveBanner(inst, data)
    LoadBanner(other, data)
    banner_damage.Restore(other)
    local timers = inst.components.timer:OnSave()
    if timers ~= nil then
        other.components.timer:OnLoad(timers)
    end
end

local function ondeploy(inst, pt, deployer)
    local item = SpawnPrefab("vanhonphien_ground")
    item.Transform:SetPosition(pt:Get())
    item.SoundEmitter:PlaySound("dontstarve/common/sign_craft")
    TransferState(inst, item)
    item._userid = deployer ~= nil and deployer.userid or nil
    if rules.IsLivingPlayer(deployer) then
        if deployer.components.timer == nil then
            deployer:AddComponent("timer")
        end
        local timer = deployer.components.timer
        if not timer:TimerExists("vanhonphien_soul_cd")
            and not item.components.timer:TimerExists("initial_cd") then
            for _ = 1, 2 do
                item:SpawnPet(deployer)
            end
            timer:StartTimer("vanhonphien_soul_cd", 60)
            item.components.timer:StartTimer("initial_cd", 60)
        end
    end

    inst:Remove()
end

local function ChangeToItem(inst,doer)
    local item = SpawnPrefab("vanhonphien")
    item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    if doer and doer.components.inventory then
        doer.components.inventory:GiveItem(item,nil,inst:GetPosition())
    end
    TransferState(inst, item)


end

local function OnDismantle(inst, doer)
    ChangeToItem(inst, doer)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("xd_wmz_zhf")
    inst.AnimState:SetBuild("xd_wmz_zhf")
    inst.AnimState:PlayAnimation("idle")
    local s  = 0.8
    inst.Transform:SetScale(s, s, s)
    inst:AddTag("portableitem")
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, "med", 0.1, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    banner_damage.Install(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/vanhonphien.xml"

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)
    inst.OnSave = SaveBanner
    inst.OnLoad = LoadBanner
    inst.soul_count = 0

    inst:AddComponent("timer")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

local wortox_soul_common = require("prefabs/wortox_soul_common")
local function IsValidVictim(victim, explosive)
    return wortox_soul_common.HasSoul(victim) and (victim.components.health and victim.components.health:IsDead() or explosive)
end

local function OnRestoreSoul(victim)
    victim._vanhonphien_nosoultask = nil
end

local function OnEntityDropLoot(inst, data)
    local victim = data ~= nil and data.inst or nil
    if not victim or victim._vanhonphien_nosoultask or not victim:IsValid() then
        return
    end
    if IsValidVictim(victim, data.explosive) and inst:IsNear(victim,18) then
        victim._vanhonphien_nosoultask = victim:DoTaskInTime(5, OnRestoreSoul)
        local fx = SpawnAt("vanhonphien_soulfx", victim)
        if fx ~= nil then
            fx.owner = inst
            fx.dofind = false
        end
    end
end

local function SpawnPet(inst,player)
    if not rules.IsLivingPlayer(player) then
        return
    end
    local pos = inst:GetPosition()
    local theta = math.random() * 2 * PI
    local radius = math.random(2,8)
    local offset = FindWalkableOffset(pos, theta, radius,12, true)
    if offset == nil then
        offset = Vector3(0,0,0)
    end
    local projectile = SpawnPrefab("vanhonphien_soul")
    projectile.Transform:SetPosition((pos+offset):Get())
    projectile:OnSpawnedBy(player)
    projectile.components.entitytracker:TrackEntity("banner",inst)
    inst.soul_entitys[projectile] = true
    inst:ListenForEvent("onremove", function()
        inst.soul_entitys[projectile] = nil
    end, projectile)  
end

local function AddSoul(inst)
    inst.soul_count = math.min(inst.soul_count + 1,2)
    if inst.soul_count >= 2 then
        local find = nil
        for k = 1,4 do
            if not inst.components.timer:TimerExists("cd"..k) then
                find = k
                break
            end
        end
        if find then
            local player = rules.FindOwner(inst._userid)
            if rules.IsLivingPlayer(player) and player:IsNear(inst,16) then
                SpawnPet(inst,player)
                inst.components.timer:StartTimer("cd"..find,60)
                inst.soul_count = 0
            end
        end
    end
end

local function OnRemoveEntity(inst)
	for k, v in pairs(inst.soul_entitys) do
		if k:IsValid() then k:Kill() end
	end
end

local function groundfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("xd_wmz_zhf")
    inst.AnimState:SetBuild("xd_wmz_zhf")
    inst.AnimState:PlayAnimation("ground")

    inst:AddTag("vanhonphien")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.soul_entitys = {}
    inst.soul_count = 0
    inst._userid = nil

    inst:AddComponent("inspectable")
    
    inst:AddComponent("portablestructure")
    inst.components.portablestructure:SetOnDismantleFn(OnDismantle)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("timer")

    inst._onentitydroplootfn = function(src, data) OnEntityDropLoot(inst, data) end
    inst:ListenForEvent("entity_droploot", inst._onentitydroplootfn, TheWorld)

    if inst._vanhonphien_fx == nil then
        inst._vanhonphien_fx = SpawnPrefab("vanhonphien_vortexspawner")
    end
    inst._vanhonphien_fx.entity:SetParent(inst.entity)
    inst._vanhonphien_fx.weapon = inst
    inst._vanhonphien_fx.col = {0/255,0/255,0/255,1}

    inst.SpawnPet = SpawnPet
    inst.OnRemoveEntity = OnRemoveEntity
    inst.AddSoul = AddSoul
    inst.OnSave = SaveBanner
    inst.OnLoad = LoadBanner
    inst:ListenForEvent("timerdone", function(_, data)
        if data ~= nil and string.match(data.name, "^cd%d$")
            and inst.soul_count >= 2 then
            inst:AddSoul()
        end
    end)

    return inst
end

local prefabs =
{
    "fireball_projectile",
    "fireball_cast_fx",
}

local brain = require "brains/vanhonphienbrain"
local nottags = {"abigail","companion","player","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
if TheNet:GetPVPEnabled() then
    nottags =  {"INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
end
local function RetargetFn(inst)
    if not inst:IsValid() then
        return nil
    end
    local owner = inst.owner
    return owner ~= nil and FindEntity(inst, 24,
        function(guy)
            return rules.CanAttack(inst, guy)
                and (guy.components.combat:TargetIs(owner) or
                owner.components.combat:TargetIs(guy) or
                guy.components.combat:TargetIs(inst) )
        end,
        { "_combat","_health" }, 
        nottags
    ) or nil
end

local function OnAttacked(inst, data)
    if data ~= nil and rules.CanAttack(inst, data.attacker) then
        inst.components.combat:SuggestTarget(data.attacker)
    end
end


local function KeepTargetFn(inst, target)
    return rules.CanAttack(inst, target) and inst.components.combat:CanTarget(target) 
end

local function EquipWeapon(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local weapon = CreateEntity()
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(function()
            local banner = inst.components.entitytracker:GetEntity("banner")
            return banner_damage.Get(banner)
        end)
        
        weapon.components.weapon:SetProjectile("vanhonphien_projectile")
        weapon.components.weapon:SetOnAttack(function(item, attacker, target, projectile)
            banner_attack.OnAttack(inst, item, attacker, target, projectile)
        end)
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
        weapon:AddComponent("equippable")
        weapon:AddTag("nosteal")
        weapon:AddTag("rangedweapon")
        weapon:AddTag("extinguisher")
        inst.components.inventory:Equip(weapon)
    end
end

local function  Kill(inst)
    if not inst.components.health:IsDead()  then
        inst.components.health.minhealth = 0
        inst.components.health:SetInvincible(false)
        inst.components.health:Kill()
    end
end

local function copyowner(inst,owner,load,skin)
    inst.owner = owner
    inst.components.follower:SetLeader(owner)
    -- Projectile weapon reads the banner carrier; no Solo import is required.
    inst:ListenForEvent("onremove", function() inst:Kill() end, owner)
    inst:ListenForEvent("death", function() inst:Kill() end, owner)
end

local function areahitcheck(ent,inst)
    return rules.CanAttack(inst, ent)
end

local sound_path = "dontstarve/common/lava_arena/spell/elemental/"

local function soulfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(1.1, .7)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("lavaarena_elemental_basic")
    inst.AnimState:SetBuild("xd_wmz_zhf_soul")
    inst.AnimState:Hide("head_spikes")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("notarget")
    inst:AddTag("noattack")
    inst:AddTag("alwaysblock")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("notraptrigger")
    inst:AddTag("companion")
    inst:AddTag("stronggrip")
    inst:AddTag("soulless")

    inst:SetPhysicsRadiusOverride(.5)
    MakeGhostPhysics(inst, 1, inst.physicsradiusoverride)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.sounds = {
		enter  = sound_path .. "enter",
		idle   = sound_path .. "idle_LP",
		hit    = sound_path .. "hit",
		attack = sound_path .. "attack",
		death  = sound_path .. "death",
	}

    inst.attack_mode = true
    inst:AddComponent("health")
    inst.components.health:SetInvincible(true)
    inst.components.health:SetMaxHealth(100)
    inst.components.health.minhealth = 1

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(20)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRange(22,22)
    inst.components.combat:SetRetargetFunction(0.2, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetAreaDamage(3, 1, areahitcheck)
    local old_DoAreaAttack = inst.components.combat.DoAreaAttack
    inst.components.combat.DoAreaAttack = function(self,target, range, weapon, validfn, stimuli, excludetags, ...)
        excludetags = nottags
        return old_DoAreaAttack(self,target, range, weapon, validfn, stimuli, excludetags, ...)
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("knownlocations")

    inst:AddComponent("inspectable")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 6
    inst.components.locomotor.runspeed = 6
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = {  allowocean = true, ignorecreep = true }
    inst.components.locomotor:SetSlowMultiplier(.6)

    inst:SetBrain(brain)

    inst:SetStateGraph("SGvanhonphien_soul")

    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("inventory")

    inst:AddComponent("entitytracker")
    inst:AddComponent("follower")

    inst:DoTaskInTime(0,EquipWeapon)
    inst:DoTaskInTime(60, Kill)
    inst.OnSpawnedBy = copyowner
    inst.persists = false
    inst.Kill =  Kill
    return inst
end

local soulassets =
{
    Asset("ANIM", "anim/wortox_soul_ball.zip"),
}

local prefabs =
{
}

local SCALE = .8
local SPEED = 10
local TINT = { r = 0 / 255, g = 0 / 255, b = 0 / 255 }

local function CreateTail()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()

    inst.AnimState:SetBank("wortox_soul_ball")
    inst.AnimState:SetBuild("wortox_soul_ball")
    inst.AnimState:PlayAnimation("disappear")
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetMultColour(0/255, 0/255, 0/255,1)
    inst.AnimState:SetFinalOffset(3)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    for tail, _ in pairs(inst._tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail()
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * 2 * PI
        local offsradius = (math.random() * .2 + .2) * SCALE
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset, y + voffset, z + math.cos(rot) * hoffset)
        tail.Physics:SetMotorVel(SPEED * (.2 + math.random() * .3), 0, 0)
        inst._tails[tail] = true
        inst:ListenForEvent("onremove", function(tail) inst._tails[tail] = nil end, tail)
        tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)
    end
end

local function OnHit(inst, attacker, target)
    if target ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local fx = SpawnPrefab("vanhonphien_soulfx_in")
        fx.Transform:SetPosition(x, y, z)
        fx:Setup(target)
        if target.AddSoul then
            target:AddSoul()
        end
    end
    inst:Remove()
end

local function OnHasTailDirty(inst)
    if inst._hastail:value() and inst._tails == nil then
        inst._tails = {}
        if inst.components.updatelooper == nil then
            inst:AddComponent("updatelooper")
        end
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateProjectileTail)
    end
end

local function OnThrownTimeout(inst)
    inst._timeouttask = nil
    inst.components.projectile:Miss(inst.components.projectile.target)
end

local function OnThrown(inst)
    if inst._timeouttask ~= nil then
        inst._timeouttask:Cancel()
    end
    inst._timeouttask = inst:DoTaskInTime(6, OnThrownTimeout)
    if inst._seektask ~= nil then
        inst._seektask:Cancel()
        inst._seektask = nil
    end
    inst.AnimState:Hide("blob")
    inst._hastail:set(true)
    if not TheNet:IsDedicated() then
        OnHasTailDirty(inst)
    end
end

local function SeekSoulStealer(inst)
    if inst.dofind then
        inst.dofind = false
        local ent = FindEntity(inst, 16, nil, {"vanhonphien"})
        if ent then 
            inst.owner = ent
            inst.components.projectile:Throw(inst, ent, inst)
        end
        return
    end
    if inst.owner and inst.owner:IsValid() and inst:IsNear(inst.owner,18) then
        if  inst.owner:IsValid() then
            inst.components.projectile:Throw(inst, inst.owner, inst)
        elseif inst.components.projectile.start then
            inst.components.projectile:Miss(inst.components.projectile.target)
        end
    end
end

local function OnTimeout(inst)
    inst._timeouttask = nil
    if inst._seektask ~= nil then
        inst._seektask:Cancel()
        inst._seektask = nil
    end
    inst:ListenForEvent("animover", inst.Remove)
    inst.AnimState:PlayAnimation("idle_pst")
    inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("wortox_soul_ball")
    inst.AnimState:SetBuild("wortox_soul_ball")
    inst.AnimState:PlayAnimation("idle_pre")
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetMultColour(0/255, 0/255, 0/255,1)

    inst:AddTag("weapon")

    inst:AddTag("projectile")

    inst._hastail = net_bool(inst.GUID, "vanhonphien_soulfx._hastail", "hastaildirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("hastaildirty", OnHasTailDirty)

        return inst
    end

    inst.AnimState:PushAnimation("idle_loop", true)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(SPEED)
    inst.components.projectile:SetHitDist(.5)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)

    inst.dofind = true
    inst._seektask = inst:DoPeriodicTask(.5, SeekSoulStealer, 1)
    inst._timeouttask = inst:DoTaskInTime(12, OnTimeout)

    inst.persists = false

    return inst
end

local function PushColour(inst, addval, multval)
    if inst.components.highlight == nil then
        inst.AnimState:SetHighlightColour(TINT.r * addval, TINT.g * addval, TINT.b * addval, 0)
        inst.AnimState:OverrideMultColour(multval, multval, multval, 1)
    else
        inst.AnimState:OverrideMultColour()
    end
end

local function PopColour(inst)
    if inst.components.highlight == nil then
        inst.AnimState:SetHighlightColour()
    end
    inst.AnimState:OverrideMultColour()
end

local function OnUpdateTargetTint(inst)
    if inst._tinttarget:IsValid() then
		local curframe = inst.AnimState:GetCurrentAnimationFrame()
        if curframe < 10 then
            local k = curframe / 10
            k = k * k
            PushColour(inst._tinttarget, (1 - k) * .7, k * .7 + .3)
        else
            inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateTargetTint)
            inst.OnRemoveEntity = nil
            PopColour(inst._tinttarget)
        end
    else
        inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateTargetTint)
        inst.OnRemoveEntity = nil
    end
end

local function OnRemoveEntity(inst)
    if inst._tinttarget:IsValid() then
        PopColour(inst._tinttarget)
    end
end

local function OnTargetDirty(inst)
    if inst._target:value() ~= nil and inst._tinttarget == nil then
        if inst.components.updatelooper == nil then
            inst:AddComponent("updatelooper")
        end
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateTargetTint)
        inst._tinttarget = inst._target:value()
        inst.OnRemoveEntity = OnRemoveEntity
    end
end

local function Setup(inst, target)
    inst._target:set(target)
    if not TheNet:IsDedicated() then
        OnTargetDirty(inst)
    end
    if target.SoundEmitter ~= nil then
        target.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
    end
end

local function infn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("wortox_soul_ball")
    inst.AnimState:SetBuild("wortox_soul_ball")
    inst.AnimState:PlayAnimation("idle_pst")
	inst.AnimState:SetFrame(6)
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetMultColour(0/255, 0/255, 0/255,1)

    inst:AddTag("FX")

    inst._target = net_entity(inst.GUID, "vanhonphien_soulfx_in._target", "targetdirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("targetdirty", OnTargetDirty)

        return inst
    end
    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false
    inst.Setup = Setup

    return inst
end

local assets_fireballhit =
{
    Asset("ANIM", "anim/fireball_2_fx.zip"),
    Asset("ANIM", "anim/deer_fire_charge.zip"),
}

local assets_blossomhit =
{
    Asset("ANIM", "anim/lavaarena_heal_projectile.zip"),
}

local assets_gooballhit =
{
    Asset("ANIM", "anim/gooball_fx.zip"),
}

local function CreateTail(bank, build, lightoverride, addcolour, multcolour)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("disappear")
    if addcolour ~= nil then
        inst.AnimState:SetAddColour(unpack(addcolour))
    end
    if multcolour ~= nil then
        inst.AnimState:SetMultColour(unpack(multcolour))
    end
    if lightoverride > 0 then
        inst.AnimState:SetLightOverride(lightoverride)
    end
    inst.AnimState:SetFinalOffset(3)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst, bank, build, speed, lightoverride, addcolour, multcolour, hitfx, tails)
    local x, y, z = inst.Transform:GetWorldPosition()
    for tail, _ in pairs(tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail(bank, build, lightoverride, addcolour, multcolour)
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * 2 * PI
        local offsradius = math.random() * .2 + .2
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset, y + voffset, z + math.cos(rot) * hoffset)
        tail.Physics:SetMotorVel(speed * (.2 + math.random() * .3), 0, 0)
        tails[tail] = true
        inst:ListenForEvent("onremove", function(tail) tails[tail] = nil end, tail)
        tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)
    end
end

local function MakeProjectile(name, bank, build, speed, lightoverride, addcolour, multcolour, hitfx)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local prefabs = hitfx ~= nil and { hitfx } or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)
        RemovePhysicsColliders(inst)

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle_loop", true)
        if addcolour ~= nil then
            inst.AnimState:SetAddColour(unpack(addcolour))
        end
        if multcolour ~= nil then
            inst.AnimState:SetMultColour(unpack(multcolour))
        end
        if lightoverride > 0 then
            inst.AnimState:SetLightOverride(lightoverride)
        end
        inst.AnimState:SetFinalOffset(3)

        inst:AddTag("projectile")

        if not TheNet:IsDedicated() then
            inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil, bank, build, speed, lightoverride, addcolour, multcolour, hitfx, {})
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst:AddComponent("projectile")
        inst.components.projectile:SetSpeed(speed)
        inst.components.projectile:SetHitDist(1)
        inst.components.projectile:SetOnHitFn(function()
            local fx = SpawnPrefab(hitfx)
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:Remove()    
        end)
        inst.components.projectile:SetOnMissFn(inst.Remove)
        inst.components.projectile.range = 30
        local original_hit = inst.components.projectile.Hit
        inst.components.projectile.Hit = function(self, target)
            return banner_attack.Hit(self, target, original_hit)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function fireballhit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fireball_fx")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetMultColour(0, 0, 0, .75)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    inst:DoTaskInTime(1.5, inst.Remove)

    return inst
end

return Prefab("vanhonphien",itemfn,assets,{"vanhonphien_ground"}),
       Prefab("vanhonphien_ground", groundfn,assets,{"vanhonphien", "vanhonphien_soul", "vanhonphien_soulfx", "vanhonphien_vortexspawner", "collapse_small"}),
       Prefab("vanhonphien_soul", soulfn,assets,{"vanhonphien_projectile"}),
       Prefab("vanhonphien_soulfx", fxfn, soulassets, {"vanhonphien_soulfx_in"}),
       Prefab("vanhonphien_soulfx_in", infn, soulassets),
       MakePlacer("vanhonphien_placer", "xd_wmz_zhf", "xd_wmz_zhf", "ground"),
       MakeProjectile("vanhonphien_projectile", "fireball_fx", "fireball_2_fx", 20, 1, nil, {0, 0, 0, .75}, "vanhonphien_hit_fx"),
       Prefab("vanhonphien_hit_fx", fireballhit_fn, assets_fireballhit)
