-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local XD_GetDamageTargets = Boss.XD_GetDamageTargets
local Xd_CalcDamage = Boss.Xd_CalcDamage
local assets =
{
    Asset("ANIM", Boss.ArtPath("anim/sand_spike.zip")),
    Asset("ANIM", Boss.ArtPath("anim/sand_splash_fx.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sand_spike.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_futu_sand_spike.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sand_splash_fx.zip")),
}
local block_assets =
{
    Asset("ANIM", Boss.ArtPath("anim/sand_block.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_sand_block.zip")),
    Asset("ANIM", Boss.ArtPath("anim/sand_splash_fx.zip")),
}
local SPIKE_SIZES =
{
    "short",
    "med",
    "tall",
}
local RADIUS =
{
    ["short"] = .2,
    ["med"] = .4,
    ["tall"] = .6,
    ["block"] = 1.1,
}
local COLLAPSIBLE_TAGS = { "_combat", "_health"}
local NON_COLLAPSIBLE_TAGS = {"ttk_boss_sandblock","qlch", "flying", "shadow", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "INLIMBO" }
local function OnDeath(inst)
    inst:AddTag("NOCLICK")
    inst.Physics:SetActive(false)
    inst.AnimState:PlayAnimation(inst.animname.."_break")
    inst.SoundEmitter:PlaySound(
        "dontstarve/creatures/together/antlion/sfx/break_spike",
        nil,
        (inst.spikesize == "short" and .6) or
        (inst.spikesize == "med" and .8) or
        nil
    )
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(),inst.Remove)
end
local function OnHit(inst)
    if not inst.components.health:IsDead() then
        inst.AnimState:PlayAnimation(inst.animname.."_hit")
    end
end
local function DoDamage(inst, death)
    inst.task = nil
    if inst.jjjspike then
        return
    end
    if not inst.nophysics then
        inst.Physics:SetActive(true)
    end
    if inst.components.health then
        inst:AddTag("ttk_boss_sandblock")
        inst:AddComponent("inspectable")
        inst.components.health:SetInvincible(false)
        inst.components.combat:SetOnHit(OnHit)
    end
    if inst.futuspike or inst.futuspike_small then
        if inst.damagefn then
            inst.damagefn(inst:GetPosition())
        end
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.caster and (inst.caster.isplayer or inst.caster.ttk_boss_playeritem) then
        if inst.caster:IsValid() and not (death and inst.onlyone) then
			local ents = XD_GetDamageTargets(x, y, z, inst.damageradius or 1.55,inst.caster.notattacktag)
			for i,v in pairs(ents) do
				if v:IsValid() and XD_CanAttackTrget(inst.caster,v) then
					local damage = inst.damage or 10
					damage = Xd_CalcDamage(inst.caster,damage,v)
					v.components.combat:GetAttacked(inst.caster,damage)
				end
			end
        end
        if death  then
            OnDeath(inst)
        end
        return
    end
    local ents = TheSim:FindEntities(x, 0, z, inst.damageradius or 1.55, COLLAPSIBLE_TAGS, NON_COLLAPSIBLE_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid() then
            if v.components.combat ~= nil
                and v.components.health ~= nil
                and not v.components.health:IsDead() then
                    local attacker = inst.caster and inst.caster:IsValid() and inst.caster or inst
                    if attacker and attacker.components.combat and attacker.components.combat:CanTarget(v) then
                        local damage = inst.damage or inst.components.combat.defaultdamage
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
                    elseif attacker and inst.mgspike then
                        v.components.combat:GetAttacked(attacker,300,nil,nil,{ttk_boss_consciousnessdamage = 30})
                    end
            end
        end
    end
    if death  then
        OnDeath(inst)
    end
    if inst.boom then
        inst:DoTaskInTime(1.5,function()
            SpawnAt("explode_small",inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, 0, z, inst.damageradius or 1.55, COLLAPSIBLE_TAGS, NON_COLLAPSIBLE_TAGS)
            for i, v in ipairs(ents) do
                if v:IsValid() then
                    if v.components.combat ~= nil
                        and v.components.health ~= nil
                        and not v.components.health:IsDead() and inst.components.combat:IsValidTarget(v) then
                            local attacker = inst.caster and inst.caster:IsValid() and inst.caster or inst
                            if attacker and attacker.components.combat and attacker.components.combat:CanTarget(v) then
                                local damage = inst.damage or inst.components.combat.defaultdamage
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
                            end
                    end
                end
            end
            inst:Remove()
        end)
    end
end
local function DoBreak(inst)
    if not inst.components.health:IsDead() then
        inst.components.health:Kill()
    end
end
local function ChangeToObstacle(inst)
    inst:RemoveEventCallback("animover", ChangeToObstacle)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Physics:Stop()
    inst.Physics:SetMass(0)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
    inst.Physics:Teleport(x, 0, z)
    if inst.futuspike then
        inst:DoTaskInTime(240, OnDeath)
        inst:ListenForEvent("onremove",function()
            if inst.owner and inst.owner.shadowfxs[inst] then
                inst.owner.shadowfxs[inst] = nil
                inst.owner.shadow_count = inst.owner.shadow_count - 1
                inst.owner:CheckShaodows()
            end
        end)
    elseif inst.jjjspike then
        inst.task = inst:DoTaskInTime(2.4, OnDeath)
    elseif inst.futuspike_small then
        inst.task = inst:DoTaskInTime(3, OnDeath)
    elseif inst.animname ~= "block" then
        inst.task = inst:DoTaskInTime(7.7, DoDamage,true)
    else
        inst.task = inst:DoTaskInTime(14, DoBreak)
    end
end
local function StartSpikeAnim(inst)
    inst.task = inst:DoTaskInTime(2 * FRAMES, DoDamage)
    if inst.animname == "block" then
        inst:RemoveEventCallback("animover", StartSpikeAnim)
    end
    inst:ListenForEvent("animover", ChangeToObstacle)
    inst.AnimState:SetLayer(LAYER_WORLD)
    inst.AnimState:SetSortOrder(0)
    inst.AnimState:PlayAnimation(inst.animname.."_pst")
    inst.SoundEmitter:PlaySound(
        "dontstarve/creatures/together/antlion/sfx/break",
        nil,
        (inst.spikesize == "short" and .6) or
        (inst.spikesize == "med" and .8) or
        nil
    )
end
local function PlayBlockSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/antlion/sfx/block")
end
local function KeepTargetFn()
    return false
end
local function MakeSpikeFn(shape, size)
    return function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddPhysics()
        inst.entity:AddNetwork()
        if shape == "spike" then
            inst.spikesize = "tall"
            inst.animname = inst.spikesize
            inst:SetPrefabNameOverride("ttk_qlch")
        else
            inst:AddTag("ttk_boss_sandblock")
            inst.animname = "block"
        end
        inst.spikeradius = RADIUS[inst.animname]
        inst.AnimState:SetBank(Boss.Art("sand_"..shape))
        inst.AnimState:SetBuild(Boss.Art("xd_".."sand_"..shape))
        inst.AnimState:OverrideSymbol("sand_splash", "xd_sand_splash_fx", "sand_splash")
        inst.AnimState:PlayAnimation(inst.animname.."_pre")
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.Physics:SetMass(999999)
        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:SetActive(false)
        inst.Physics:SetCapsule(inst.spikeradius, 2)
        inst.entity:SetCanSleep(false)
        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end
        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(30)
        inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
        if shape == "block" then
            inst.components.combat:SetDefaultDamage(20)
            inst:AddComponent("health")
            inst.components.health:SetMaxHealth(1600)
            inst.components.health:SetInvincible(true)
            inst.components.health.fire_damage_scale = 0
            inst.components.health.canheal = false
            inst.components.health.nofadeout = true
            inst:ListenForEvent("animover", StartSpikeAnim)
            inst:ListenForEvent("death", OnDeath)
            inst:DoTaskInTime(0, PlayBlockSound)
        else
            inst:DoTaskInTime(0.3,StartSpikeAnim)
        end
        inst.OnDeath = OnDeath
        inst.persists = false
        return inst
    end
end
return Prefab("ttk_boss_sandspike", MakeSpikeFn("spike"), assets),
    Prefab("ttk_boss_sandblock", MakeSpikeFn("block"), block_assets)
