-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local assets_impact =
{
	Asset("ANIM", Boss.ArtPath("anim/deerclops_mutated_actions.zip")),
	Asset("ANIM", Boss.ArtPath("anim/deerclops_mutated.zip")),
	Asset("ANIM", Boss.ArtPath("anim/deer_ice_circle.zip")),
}
local bishop_chargeassets =
{
    Asset("ANIM", Boss.ArtPath("anim/bishop_attack.zip")),
}
local spikeassets = {
    Asset("ANIM", Boss.ArtPath("anim/fossil_spike2.zip")),
}
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:DoTaskInTime(20,inst.Remove)
    return inst
end
local function impact_OnPostUpdateExplosion(inst)
	if inst.dopostupdate then
		inst.dopostupdate = nil
		local parent = inst.entity:GetParent()
		if parent ~= nil then
			if parent.AnimState:AnimDone() then
				inst:Hide()
				inst:DoTaskInTime(0, inst.Remove)
				return
			else
				inst.AnimState:SetFrame(parent.AnimState:GetCurrentAnimationFrame())
			end
		end
		inst:DoTaskInTime(0, inst.RemoveComponent, "updatelooper")
	end
end
local impact_firstplayhack = true
local function impact_DoSound(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/break_iceblock")
end
local function impact_CreateExplosion()
	local inst = CreateEntity()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.persists = false
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.AnimState:SetBank(Boss.Art("deerclops"))
	inst.AnimState:SetBuild(Boss.Art("deerclops_mutated"))
	inst.AnimState:PlayAnimation("ice_impact")
	if impact_firstplayhack then
		impact_firstplayhack = nil
		inst:DoTaskInTime(0, impact_DoSound)
	else
		impact_DoSound(inst)
	end
	if not TheWorld.ismastersim then
		inst:AddComponent("updatelooper")
		inst.components.updatelooper:AddPostUpdateFn(impact_OnPostUpdateExplosion)
		inst.dopostupdate = true
	end
	inst:ListenForEvent("animover", inst.Remove)
	return inst
end
local function impact_KillFX(inst)
	inst:ListenForEvent("animover", inst.Remove)
	inst.AnimState:PlayAnimation("pst")
end
local function impactfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst.AnimState:SetBank(Boss.Art("deer_ice_circle"))
	inst.AnimState:SetBuild(Boss.Art("deer_ice_circle"))
	inst.AnimState:PlayAnimation("impact")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.AnimState:SetScale(2.2, 2.2)
	if not TheNet:IsDedicated() then
		impact_CreateExplosion().entity:SetParent(inst.entity)
	end
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
	inst:DoTaskInTime(2, impact_KillFX)
	return inst
end
local function Projectile_Hit(self,target)
    self:Stop()
    self.inst.Physics:Stop()
    if target and target.components.combat and target.components.health and not target.components.health:IsDead() then
		target.components.combat:GetAttacked(self.inst,self.damage or 100)
    end
    if self.onhit ~= nil then
        self.onhit(self.inst, nil, target)
    end
end
local function OnHit(inst, owner, target)
    SpawnPrefab("bishop_charge_hit").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end
local function OnAnimOver(inst)
    inst:DoTaskInTime(.3, inst.Remove)
end
local function OnThrown(inst)
    inst:ListenForEvent("animover", OnAnimOver)
end
local function bishop_chargefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    inst.Transform:SetFourFaced()
    inst.AnimState:SetBank(Boss.Art("bishop_attack"))
    inst.AnimState:SetBuild(Boss.Art("bishop_attack"))
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("projectile")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile.Hit = Projectile_Hit
    return inst
end
local NUM_VARIATIONS = 7
local PHYSICS_RADIUS = .2
local DAMAGE_RADIUS_PADDING = .5
local SHADOW_SIZE = { 1.2, .75 }
local function DoDamage(inst)
	if inst.damagefn then
		inst.damagefn(inst,inst.owner)
	end
end
local function OnKill(inst)
    inst:AddTag("NOCLICK")
    ErodeAway(inst, 1)
end
local function KillSpike(inst)
    if inst.killtask ~= nil then
        inst.killtask:Cancel()
        inst.killtask = nil
    end
    if not inst.killed then
        if inst.basefx ~= nil then
            inst.killed = true
            if inst.task ~= nil then
                inst.task:Cancel()
                inst.task = nil
            end
            SpawnPrefab("erode_ash").Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst:DoTaskInTime(.5, OnKill)
        else
            inst:Remove()
        end
    end
end
local function OnImpact(inst)
    inst:RemoveEventCallback("animover", OnImpact)
    inst.AnimState:PlayAnimation("impact")
    if inst.lighttask ~= nil then
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end
    inst.AnimState:SetLightOverride(0)
    if inst.shadowtask ~= nil then
        inst.shadowtask:Cancel()
        inst.shadowtask = nil
    end
    if inst.shadowtask2 ~= nil then
        inst.shadowtask2:Cancel()
        inst.shadowtask2 = nil
    end
    inst.DynamicShadow:Enable(false)
    inst.basefx = SpawnPrefab("fossilspike2_base")
    inst.basefx.entity:SetParent(inst.entity)
    if inst.soundlevel ~= nil then
        inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/stalker/fossil_spike", { level = inst.soundlevel })
    else
        inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stalker/fossil_spike")
    end
    DoDamage(inst)
    inst.killtask = inst:DoTaskInTime(.35, KillSpike)
end
local SHADOW_DELTA2 = -.2
local function UpdateShadow2(inst)
    if inst.shadowtask ~= nil then
        inst.shadowtask:Cancel()
        inst.shadowtask = nil
    end
    inst.shadowsize = inst.shadowsize + SHADOW_DELTA2
    local k = 1 - inst.shadowsize
    k = 1 - k * k
    if k <= .5 then
        k = .5
        inst.shadowtask2:Cancel()
        inst.shadowtask2 = nil
    end
    inst.DynamicShadow:SetSize(k * SHADOW_SIZE[1], k * SHADOW_SIZE[2])
end
local SHADOW_DELTA = .05
local function UpdateShadow(inst)
    inst.shadowsize = inst.shadowsize + SHADOW_DELTA
    if inst.shadowsize > 0 then
        inst.DynamicShadow:Enable(true)
        if inst.shadowsize >= 1 then
            inst.shadowsize = 1
            inst.shadowtask:Cancel()
            inst.shadowtask = nil
        end
    end
    local k = inst.shadowsize * inst.shadowsize
    inst.DynamicShadow:SetSize(k * SHADOW_SIZE[1], k * SHADOW_SIZE[2])
end
local LIGHT_DELTA = .03
local function UpdateLight(inst)
    inst.lightvalue = inst.lightvalue + LIGHT_DELTA
    if inst.lightvalue >= 1 then
        inst.lightvalue = 1
        inst.lighttask:Cancel()
        inst.lighttask = nil
    end
    inst.AnimState:SetLightOverride(1 - inst.lightvalue * inst.lightvalue)
end
local function StartSpike(inst, variation)
    inst.task = nil
    if variation > 1 then
        inst.AnimState:OverrideSymbol("bone1", "fossil_spike2", "bone"..tostring(variation))
    end
    inst:ListenForEvent("animover", OnImpact)
    inst.AnimState:PlayAnimation("appear")
    inst.shadowsize = 0
    inst.shadowtask = inst:DoPeriodicTask(0, UpdateShadow)
    inst.shadowtask2 = inst:DoPeriodicTask(0, UpdateShadow2, 43 * FRAMES)
    inst.lightvalue = 0
    inst.lighttask = inst:DoPeriodicTask(0, UpdateLight)
end
local function RestartSpike(inst, delay, variation, soundlevel,targets,owner,damagefn)
    if inst.task ~= nil then
        inst.task:Cancel()
        if variation == nil then
            variation = math.random(NUM_VARIATIONS)
        elseif variation > NUM_VARIATIONS then
            variation = (variation - 1) % NUM_VARIATIONS + 1
        end
		inst.targets = targets
		inst.owner = owner
		inst.damagefn = damagefn
        inst.soundlevel = soundlevel
        inst.task = inst:DoTaskInTime(delay or 0, StartSpike, variation)
    end
end
local function spikefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("fossil_spike2"))
    inst.AnimState:SetBuild(Boss.Art("fossil_spike2"))
    inst.AnimState:PlayAnimation("empty")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetLightOverride(1)
    inst.DynamicShadow:Enable(false)
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst.task = inst:DoTaskInTime(0, StartSpike, math.random(NUM_VARIATIONS))
    inst.RestartSpike = RestartSpike
    inst.KillSpike = KillSpike
    return inst
end
local POINTS_ANGLEDIFF = PI/18
local RADIUS = math.sqrt(TUNING.ALTERGUARDIAN_PHASE3_SUMMONRSQ)
local function GeneratePoints(inst)
    local ix, _, iz = inst.Transform:GetWorldPosition()
    local angle = 0
    while angle < 2*PI do
        local x = ix + RADIUS * math.cos(angle)
        local z = iz + RADIUS * math.sin(angle)
        table.insert(inst._points, {x, z})
        angle = angle + POINTS_ANGLEDIFF
    end
    shuffleArray(inst._points)
end
local function spawn_fx(inst)
    if #inst._points <= 0 then
        GeneratePoints(inst)
    end
    local next_point = table.remove(inst._points)
    local x, z = next_point[1], next_point[2]
    local fx = SpawnPrefab("alterguardian_lasertrail")
    fx.Transform:SetPosition(x, 0, z)
	fx.AnimState:SetAddColour(1, 1, 1, 0)
	fx.AnimState:SetMultColour(1, 1, 1, 1)
end
local function circlefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst:AddTag("NOCLICK")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst._points = {}
    inst:DoPeriodicTask(3*FRAMES, spawn_fx)
    return inst
end
return Prefab("ttk_boss_aoeent", fn),
    Prefab("ttk_boss_impact_circle_fx", impactfn, assets_impact),
	Prefab("ttk_boss_bishop_charge", bishop_chargefn, bishop_chargeassets),
	Prefab("ttk_boss_skill_fossilspike", spikefn, spikeassets),
	Prefab("ttk_boss_skill_circle", circlefn)
