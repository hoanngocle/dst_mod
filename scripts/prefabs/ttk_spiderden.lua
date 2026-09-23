require("worldsettingsutil")
local houseutil = require("ttk_batch19_houseutil")

local prefabs =
{
    "ttk_spider",
    "silk",
}

local assets =
{
    Asset("ANIM", "anim/ttk_spiderden.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local function OnQuakeBegin(inst)
    if inst.components.childspawner ~= nil then
        for _, child in pairs(inst.components.childspawner.childrenoutside) do
            child._quaking = true
            if child.components.sleeper ~= nil then
                child.components.sleeper:WakeUp()
            end
        end
    end
end

local function OnQuakeEnd(inst)
    if inst.components.childspawner ~= nil then
        for _, child in pairs(inst.components.childspawner.childrenoutside) do
            child._quaking = nil
        end
    end
end

local function onspawnspider(inst, spider)
    if spider ~= nil then
        spider._ttk_owner_userid = inst._ttk_owner_userid
        spider._ttk_owner_name = inst._ttk_owner_name
        if spider.components.homeseeker ~= nil then
            spider.components.homeseeker:SetHome(inst)
        end
        if spider.sg ~= nil then
            spider.sg:GoToState("taunt")
        end
    end
end

local function OnKilled(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:ReleaseAllChildren()
    end
    RemovePhysicsColliders(inst)
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_destroy")
    inst.components.lootdropper:DropLoot(inst:GetPosition())
end

local function IsDefender(child)
    return child.prefab == "spider_warrior"
end

local function SpawnDefenders(inst, attacker)
    if not inst.components.health:IsDead() then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_hit")

        if inst.components.childspawner ~= nil then
            local max_release_per_stage = { 2, 4, 6 }
            local num_to_release = math.min(max_release_per_stage[inst.data.stage] or 1, inst.components.childspawner.childreninside)

            num_to_release = math.floor(SpringCombatMod(num_to_release))

            for k = 1, num_to_release do

                local spider = inst.components.childspawner:SpawnChild()
                if spider ~= nil and attacker ~= nil and spider.components.combat ~= nil
                    and houseutil.CanAttackTarget(spider, attacker) then
                    spider.components.combat:SetTarget(attacker)
                    spider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
                end
            end

            if not inst:HasTag("bedazzled") then
            local emergencyspider = inst.components.childspawner:TrySpawnEmergencyChild()
            if emergencyspider ~= nil and attacker ~= nil
                and houseutil.CanAttackTarget(emergencyspider, attacker) then
                emergencyspider.components.combat:SetTarget(attacker)
                emergencyspider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
            end
        end
    end
    end
end

local function OnHit(inst, attacker)
    SpawnDefenders(inst, attacker)
end

local function IsInvestigator(child)
    return child.components.knownlocations:GetLocation("investigate") ~= nil
end

local function SpawnInvestigators(inst, data)
    if not inst.components.health:IsDead() and not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) then
        if inst.components.childspawner ~= nil then
            local max_release_per_stage = { 1, 2, 3 }
            local num_to_release = math.min(3, inst.components.childspawner.childreninside)
            num_to_release = math.floor(SpringCombatMod(num_to_release))

            local num_investigators = inst.components.childspawner:CountChildrenOutside(IsInvestigator)
            num_to_release = num_to_release - num_investigators

            local targetpos = data ~= nil and data.target ~= nil and data.target:GetPosition() or nil

            for _ = 1, num_to_release do
                local spider = inst.components.childspawner:SpawnChild()
                if spider ~= nil and targetpos ~= nil then
                    spider.components.knownlocations:RememberLocation("investigate", targetpos)
                end
            end
        end
    end
end

local function SummonChildren(inst, data)
    if not inst.components.health:IsDead() and
            not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) then

        if inst.components.childspawner ~= nil then
            local children_released = inst.components.childspawner:ReleaseAllChildren()

            if children_released then
                for _, child_released in ipairs(children_released) do
                    child_released:AddDebuff("spider_summoned_buff", "spider_summoned_buff")
                end
            end
        end
    end
end

local function StartSpawning(inst)
    if inst.components.childspawner ~= nil and
            not (inst.components.freezable ~= nil and
                inst.components.freezable:IsFrozen()) and not TheWorld.state.iscaveday then
            if not inst.components.childspawner.spawning then
                inst.components.childspawner:StartSpawning()
            end
    end
end

local function StopSpawning(inst)
    if inst.components.childspawner ~= nil then
        inst.components.childspawner:StopSpawning()
    end
end

local function OnExtinguish(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spidernest_LP", "loop")
end

local function OnIgnite(inst)
    if inst.components.childspawner ~= nil then
        SpawnDefenders(inst)
    end
    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spidernest_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function OnIsCaveDay(inst, iscaveday)
    if iscaveday then
        StopSpawning(inst)
    else
        StartSpawning(inst)
    end
end

local function OnInit(inst)
    inst:WatchWorldState("iscaveday", OnIsCaveDay)
    OnIsCaveDay(inst, TheWorld.state.iscaveday)
end

local function CanTarget(guy)
    return not guy.components.health:IsDead()
end

local TARGET_MUST_TAGS = { "_combat", "_health", "character" }
local TARGET_CANT_TAGS = { "player", "spider","ttk_spider","INLIMBO" }
local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local target = FindEntity(
            inst,
            25,
            CanTarget,
            TARGET_MUST_TAGS, 
            TARGET_CANT_TAGS
        )
        if target ~= nil then
            SpawnDefenders(inst, target)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            return true
        end
    end
    return false
end

local function OnLoadPostPass(inst)
    if inst:GetCurrentPlatform() then
        if inst.components.childspawner then
            inst.components.childspawner:StopRegen()
        end
        inst.GroundCreepEntity:SetRadius(0)
    end
end

local function OnGoHome(_, child)
    
    local hat = child.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    if hat ~= nil then
        child.components.inventory:DropItem(hat)
    end
end

local function OnWork(inst, worker, workleft, numworks)
	if not inst.components.health:IsDead() then
		local hp = inst.components.health.currenthealth
		local delta = 100
		if numworks <= 0 and delta >= hp then
			delta = hp - 1
		end
		inst.components.workable:SetWorkLeft(10)
		inst.components.health:DoDelta(-delta)
		if not inst.components.health:IsDead() then
			OnHit(inst, worker)
		end
	end
end

local function SetStage(inst)
    if POPULATING then
        if not inst.loadtask then
            inst.loadtask = inst:DoTaskInTime(0, function()
                if inst:GetCurrentPlatform() == nil then
                    inst.GroundCreepEntity:SetRadius(9)
                end
                inst.loadtask = nil
            end)
        end
    else
        if inst:GetCurrentPlatform() == nil then
            inst.GroundCreepEntity:SetRadius(9)
        end
    end
end

local function MakeSpiderDenFn()
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddGroundCreepEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

		inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) 
		inst:SetPhysicsRadiusOverride(0.5)
		MakeObstaclePhysics(inst, inst.physicsradiusoverride)

        inst.MiniMapEntity:SetIcon("ttk_spiderden.tex")

        inst.AnimState:SetBank("xd_spiderden")
        inst.AnimState:SetBuild("xd_spiderden")
        inst.AnimState:PlayAnimation("idle", true)

        inst:AddTag("cavedweller")
        inst:AddTag("structure")
		inst:AddTag("lifedrainable") 
        inst:AddTag("beaverchewable") 
        inst:AddTag("hostile")
        inst:AddTag("spiderden")
        inst:AddTag("ttk_spiderden")
        inst:AddTag("hive")
		inst:AddTag("NPC_workable")

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.data = {}

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1000)

        inst:AddComponent("childspawner")
        inst.components.childspawner.childname = "ttk_spider"
        inst.components.childspawner:SetRegenPeriod(100)
        inst.components.childspawner:SetSpawnPeriod(5)
        inst.components.childspawner:SetGoHomeFn(OnGoHome)

        inst.components.childspawner.allowboats = true

        inst.components.childspawner:SetMaxChildren(6)
        
        inst.components.childspawner:SetEmergencyRadius(20)

        inst.components.childspawner:SetSpawnedFn(onspawnspider)
        inst:ListenForEvent("creepactivate", SpawnInvestigators)
        inst:ListenForEvent("startquake", function() OnQuakeBegin(inst) end, TheWorld.net)
        inst:ListenForEvent("endquake", function() OnQuakeEnd(inst) end, TheWorld.net)

        inst.SummonChildren = SummonChildren

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetLoot({"rocks","rocks","rocks","silk","silk","silk","silk","silk","silk"})
        inst.components.lootdropper.droprecipeloot = false

        inst:DoTaskInTime(0, OnInit)

        inst:AddComponent("combat")
        inst.components.combat:SetOnHit(OnHit)
        inst:ListenForEvent("death", OnKilled)
        
        inst:AddComponent("inspectable")

		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(nil)
		inst.components.workable:SetOnWorkCallback(OnWork)

        inst:AddComponent("hauntable")
        inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_MEDIUM
        inst.components.hauntable:SetOnHauntFn(OnHaunt)

        MakeSnowCovered(inst)

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake
		inst.OnLoadPostPass = OnLoadPostPass

        SetStage(inst)

        houseutil.BindOnBuilt(inst)
        inst.OnSave = houseutil.SaveOwner
        inst.OnLoad = houseutil.LoadOwner

		if not POPULATING then
			inst:DoTaskInTime(0, OnLoadPostPass)
		end

        return inst
    end
end

return Prefab("ttk_spiderden", MakeSpiderDenFn(), assets, prefabs),
    MakePlacer("ttk_spiderden_placer", "xd_spiderden", "xd_spiderden", "idle")
