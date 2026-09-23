local houseutil = require("ttk_batch19_houseutil")
local TTK_CanAttackTarget = houseutil.CanAttackTarget
local assets = 
{
	Asset("ANIM", "anim/ttk_pog_basic.zip"),
	Asset("ANIM", "anim/ttk_pog_actions.zip"),
	Asset("ANIM", "anim/ttk_pog.zip"),
	Asset("ANIM", "anim/ttk_pog_house.zip"),
	Asset("ANIM", "anim/ttk_pog_fire.zip"),
	Asset("ANIM", "anim/ttk_pog_firefire.zip"),
    Asset("ATLAS", "images/inventoryimages/ttk_pog_house.xml"),
	Asset("IMAGE", "images/inventoryimages/ttk_pog_house.tex"),
	
}

local prefabs = 
{
    "ttk_pog_fire", "ttk_pog_fire_buff", "statue_transition", "statue_transition_2",
    "groundpoundring_fx", "groundpound_fx", "firering_fx", "firesplash_fx",
}
SetSharedLootTable('ttk_pog',
{
    {'meat',             1.00},
	{"ttk_pog_tail",             0.25},
})

local brain = require("brains/ttk_pogbrain")
local FORCED_NIGHTMARE_LOOT = { "nightmarefuel" }
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function OnAttacked(inst, data)
    local attacker = data.attacker
    inst:ClearBufferedAction()
    if inst.components.combat and houseutil.CanAttackTarget(inst, attacker) then
    	inst.components.combat:SetTarget(data.attacker) 
    	inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("ttk_pog") end, MAX_TARGET_SHARES)
    end
end

local function KeepTargetFn(inst, target)
	if inst.components.homeseeker and inst.components.homeseeker.home and inst.components.homeseeker.home:IsValid() then
		return inst:IsNear(inst.components.homeseeker.home,20) and 
			target:IsValid()
			and inst.components.combat:CanTarget(target)
	else 
		return target:IsValid() and inst.components.combat:CanTarget(target)
	end
end

local nottags =  {"INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
local function RetargetFn(inst) 
    local isshadow = inst.isshadow
    return isshadow and FindEntity(inst, 20,
        function(guy)
            return TTK_CanAttackTarget(inst,guy)
        end,
        { "_combat","_health","player" }, 
        nottags
    ) or nil
end

local function ShouldAcceptItem(inst, item)
    if item.components.edible and item.components.edible.foodtype == FOODTYPE.MEAT then
        return inst.components.eater:CanEat(item)
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    inst:PushEvent("doeat")
    local makework = false
    if item.prefab == "meat" then
        inst.meat_count = inst.meat_count + 1
        if inst.meat_count >= 10 then
            inst.meat_count = 0
            makework = true
        end
    elseif item:HasTag("preparedfood") then
        inst.preparedfood_count = (inst.preparedfood_count or 0) + 1
        if inst.preparedfood_count >= 5 then
            inst.preparedfood_count = 0
            makework = true
        end
    end
    if makework then
        inst.components.timer:StopTimer("guyong")
        inst.components.timer:StartTimer("guyong",2400)
        houseutil.SetOwner(inst, giver)
        inst._ttk_tamed = true
        inst.components.lootdropper:SetChanceLootTable(nil)
    end
end

local function OnRefuseItem(inst, giver, item)	
	if giver ~= nil and giver.Transform ~= nil and inst.sg ~= nil and not inst.sg:HasStateTag("busy") then
    	inst:FacePoint(giver.Transform:GetWorldPosition())
		
    end
end

local function OnEat(inst, food)
    if food.components.edible ~= nil then
    end
end

local function DoFx(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("statue_transition_2")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(.8, .8, .8)
    end
    fx = SpawnPrefab("statue_transition")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(.8, .8, .8)
    end
end

local function ChangeToShadow(inst)
	DoFx(inst)
	inst.isshadow = true
	inst.AnimState:SetMultColour(0, 0, 0, .62)
	inst.components.lootdropper:SetLoot(FORCED_NIGHTMARE_LOOT)
	inst.components.lootdropper:SetChanceLootTable('ttk_pog') 
end

local function ChangeToNormal(inst)
	inst.isshadow = false
	inst.AnimState:SetMultColour(1, 1, 1, 1)
	inst.components.lootdropper:SetLoot(nil)
	inst.components.lootdropper:SetChanceLootTable('ttk_pog')
end

local function CalcSanityAura(inst)
    return inst.isshadow and -1 or 0
end

local noltags =  {"ttk_pog","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost"}
local function invalidtarget(inst,target)
    return target and target:IsValid() and target.components.health and not target.components.health:IsDead()
    and target.components.combat
end
local function DoAoe(inst,pos,range,damage,extrafn,damagefn)
    pos = pos or inst:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range or 4, {"_combat","_health"},noltags)
    for _,v in ipairs(ents) do
        if v ~= nil and invalidtarget(inst,v) and (not damagefn or damagefn(inst,v)) then
            v.components.combat:GetAttacked(inst,damage or 100)
            if extrafn then
                extrafn(inst,v)
            end
        end
    end
end

local function UpdateStage(inst)
    if inst.isshadow then
        inst:Xd_ChangeToNormal()
    end
end

local function OnTimerDone(inst, data)
    if data ~= nil and data.name == "guyong" then
        inst._ttk_tamed = false
        inst.components.lootdropper:SetChanceLootTable("ttk_pog")
    end
end

local function OnSave(inst, data)
    houseutil.SaveOwner(inst, data)
    data.meat_count = inst.meat_count
    data.preparedfood_count = inst.preparedfood_count
end

local function OnLoad(inst, data)
    houseutil.LoadOwner(inst, data)
    inst.meat_count = data ~= nil and data.meat_count or 0
    inst.preparedfood_count = data ~= nil and data.preparedfood_count or 0
    if inst._ttk_tamed and inst.components.lootdropper ~= nil then
        inst.components.lootdropper:SetChanceLootTable(nil)
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

	shadow:SetSize(2,0.75)
	trans:SetFourFaced()

	MakeCharacterPhysics(inst, 1, 0.5)

	anim:SetBank("xd_pog")
	anim:SetBuild("xd_pog")
	anim:PlayAnimation("idle_loop")

	inst:AddTag("smallcreature")
	inst:AddTag("animal")
	inst:AddTag("ttk_pog")
	inst:AddTag("scarytoprey")

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.meat_count = 0
    inst.preparedfood_count = 0

	inst:AddComponent("inspectable")

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(400)

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(40)
	inst.components.combat:SetRange(4)
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    
    inst:ListenForEvent("attacked", OnAttacked)
    inst.components.combat.battlecryinterval = 20

	inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('ttk_pog') 
    
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
    inst.components.eater:SetStrongStomach(true) 
    inst.components.eater:SetOnEatFn(OnEat)

	inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("leader")

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = 3
	inst.components.locomotor.runspeed = 3

	inst:AddComponent("timer")

	inst:AddComponent("knownlocations")
    inst:AddComponent("homeseeker")
    inst:AddComponent("herdmember")

	MakeSmallBurnableCharacter(inst, "pog_chest", Vector3(1,0,1))
	MakeSmallFreezableCharacter(inst)

	inst:SetBrain(brain)
	inst:SetStateGraph("SGttk_pog")

    

    inst.isshadow =  false
	inst.Xd_ChangeToShadow = ChangeToShadow
	inst.Xd_ChangeToNormal = ChangeToNormal
    inst:DoTaskInTime(0,UpdateStage)
    inst:ListenForEvent("timerdone", OnTimerDone)

    inst.DoAoe = DoAoe
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

	return inst
end

local function onhammered(inst, worker)
    inst.workover = true
    if inst.components.childspawner ~= nil then
        if not houseutil.ReleaseChildrenForHammer(inst) then return end
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
	
    local childspawner = inst.components.childspawner
    if childspawner then
        
        for child in pairs(childspawner.childrenoutside) do
            if child and child:IsValid() and child.components.combat
                and houseutil.CanAttackTarget(child, worker) then
                child.components.combat:SuggestTarget(worker) 
            end
        end
    end
end

local function canspawn(inst)
    return inst.workover or TheWorld.state.isnight
end

local function OnChildKilled(inst, child)
end

local function CacheItemsAtHome(inst, catcoon)
end

local function onspawned(inst, child)
    inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door") 
    if child ~= nil then
        child.components.homeseeker:SetHome(inst)
        child._ttk_owner_userid = inst._ttk_owner_userid
        child._ttk_owner_name = inst._ttk_owner_name
    end
end

local function housefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("xd_pog_house")
    inst.AnimState:SetBuild("xd_pog_house")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")

	MakeObstaclePhysics(inst, 0.5)

    inst.MiniMapEntity:SetIcon("ttk_pog_house.tex")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then

        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ttk_pog"
    inst.components.childspawner:SetRegenPeriod(2*480)
    inst.components.childspawner:SetSpawnPeriod(5)
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner.canspawnfn = canspawn
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner.onchildkilledfn = OnChildKilled
    inst.components.childspawner:SetSpawnedFn(onspawned)

    MakeSnowCovered(inst)
    AddHauntableDropItemOrWork(inst)

    houseutil.BindOnBuilt(inst)
    inst.OnSave = houseutil.SaveOwner
    inst.OnLoad = houseutil.LoadOwner

    return inst
end

local function firefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("xd_pog_fire")
    inst.AnimState:SetBuild("xd_pog_fire")
    inst.AnimState:PlayAnimation("level2",true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    local s  = 1.6
    inst.AnimState:SetScale(s, s, s)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("colourtweener")
    inst:DoTaskInTime(0.5,function()
        inst.components.colourtweener:StartTween({1, 1, 1, 0}, 0.2, function()
            if inst.damagefn then
                inst:damagefn()
            end
            inst:Remove()
        end)
    end)

    inst:DoTaskInTime(3,inst.Remove)

    inst.persists = false
    
    return inst
end

return Prefab("ttk_pog", fn, assets, prefabs),
    Prefab("ttk_pog_fire", firefn, assets, prefabs),
	Prefab("ttk_pog_house", housefn, assets, prefabs),
    MakePlacer("ttk_pog_house_placer", "xd_pog_house", "xd_pog_house", "idle")
