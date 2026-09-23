-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local XD_CanAttackTrget = Boss.XD_CanAttackTrget
local Xd_CalcDamage = Boss.Xd_CalcDamage
local function createassets(name)
    return
    {
        Asset("ANIM", Boss.ArtPath("anim/"..name..".zip")),
        Asset("ANIM", Boss.ArtPath("anim/"..name.."_upg_build.zip")),
    }
end
local function shadowcommonfn(name, sixfaced)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    if sixfaced then
        inst.Transform:SetSixFaced()
    else
        inst.Transform:SetFourFaced()
    end
    inst:AddTag("fx")
    inst:AddTag("hostile")
    inst:AddTag("notraptrigger")
    inst:SetPrefabNameOverride(name)
    inst.AnimState:SetBank(Boss.Art(name))
    inst.AnimState:SetBuild(Boss.Art(name))
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetMultColour(1, 1, 1, .5)
    inst.AnimState:SetFinalOffset(1)
	inst.AnimState:UsePointFiltering(true)
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent("combat")
    inst.sounds =
    {
        death = "dontstarve/sanity/death_pop",
        levelup = "dontstarve/sanity/transform/two",
    }
    inst.persists = false
    return inst
end
local function dorookremove(inst)
    inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover",inst.Remove)
end
local function DoRookAttack(inst,target)
    if inst.doremovetask then
        inst.doremovetask:Cancel()
    end
    local pos = target:GetPosition()
    inst.AnimState:PlayAnimation("teleport_pre")
    inst.AnimState:PushAnimation("teleport", false)
    inst:DoTaskInTime(0,function() inst.SoundEmitter:PlaySound(inst.sounds["attack_grunt"]) end)
    inst:DoTaskInTime(12 * FRAMES,function() inst.SoundEmitter:PlaySound(inst.sounds["teleport"]) end)
    inst:DoTaskInTime(0.97,function()
        if target and target:IsValid() then
            pos = target:GetPosition()
        end
        inst.Physics:Teleport(pos:Get())
        inst:DoTaskInTime(0,function() inst.SoundEmitter:PlaySound(inst.sounds["attack"]) end)
        inst.AnimState:PlayAnimation("teleport_atk")
        inst.AnimState:PushAnimation("teleport_pst", false)
        inst:DoTaskInTime(17 * FRAMES,function()
            if inst.ziyuan_aoe then
                inst.ziyuan_aoe(pos)
            else
                inst.doaoe(inst,pos,3.35,50)
            end
        end)
        inst:DoTaskInTime(1.118,dorookremove)
    end)
end
local function DoRookStart(inst,target)
    inst.AnimState:PlayAnimation("transform")
    inst:DoTaskInTime(20* FRAMES,function() inst.SoundEmitter:PlaySound(inst.sounds.levelup) end)
    inst:DoTaskInTime(3,function()
        if target and target:IsValid() then
            DoRookAttack(inst,target)
        else
            inst.AnimState:PlayAnimation("idle_loop")
        end
    end)
end
local function rookfn()
    local inst = shadowcommonfn("shadow_rook")
    if not TheWorld.ismastersim then
        return inst
    end
    inst.sounds.attack = "dontstarve/sanity/rook/attack_1"
    inst.sounds.attack_grunt = "dontstarve/sanity/rook/attack_grunt"
    inst.sounds.die = "dontstarve/sanity/rook/die"
    inst.sounds.idle = "dontstarve/sanity/rook/idle"
    inst.sounds.taunt = "dontstarve/sanity/rook/taunt"
    inst.sounds.disappear = "dontstarve/sanity/rook/dissappear"
    inst.sounds.hit = "dontstarve/sanity/rook/hit_response"
    inst.sounds.teleport = "dontstarve/sanity/rook/teleport"
    inst.DoAttack = DoRookAttack
    inst.OnStart = DoRookStart
    inst.doremovetask =  inst:DoTaskInTime(10,dorookremove)
    return inst
end
local function DoSwarmFX(inst)
    local fx = SpawnPrefab("shadow_bishop_fx")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.Transform:SetScale(inst.Transform:GetScale())
    fx.AnimState:SetMultColour(inst.AnimState:GetMultColour())
end
local function dobishopremove(inst)
    if inst.damagetask then
        inst.damagetask:Cancel()
    end
    if inst.movetask then
        inst.movetask:Cancel()
    end
    if inst.fxtask then
        inst.fxtask:Cancel()
    end
    inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover",inst.Remove)
    inst:DoTaskInTime(1.5,inst.Remove)
end
local function DoBishopAttack(inst,target)
    if inst.doremovetask then
        inst.doremovetask:Cancel()
    end
    local pos = target:GetPosition()
    inst.AnimState:PlayAnimation("atk_side_pre")
    inst:DoTaskInTime(8 * FRAMES,function() inst.SoundEmitter:PlaySound(inst.sounds.attack,"attack") end)
    inst:DoTaskInTime(0.924,function()
        if target and target:IsValid() then
            pos = target:GetPosition()
        end
        inst.Physics:Teleport(pos:Get())
        inst.AnimState:PlayAnimation("atk_side_loop", true)
        inst.movetask = inst:DoPeriodicTask(0.1,function()
            if target ~= nil and target:IsValid() then
                local scale = inst.Transform:GetScale()
                local speed = 2 / scale
                if inst:IsNear(target, .5) then
                    inst.Physics:Stop()
                else
                    inst:ForceFacePoint(target.Transform:GetWorldPosition())
                    inst.Physics:SetMotorVel(speed, 0, 0)
                end
            end
        end)
        inst.damagetask = inst:DoPeriodicTask(TUNING.SHADOW_BISHOP.ATTACK_TICK,function()
            if inst.ziyuan_aoe then
                inst.ziyuan_aoe(pos)
            elseif inst.doaoe then
                inst.doaoe(inst,pos,1.75,3)
            end
        end, TUNING.SHADOW_BISHOP.ATTACK_START_TICK)
        inst.fxtask = inst:DoPeriodicTask(1.2, DoSwarmFX, .5)
        inst.SoundEmitter:KillSound("attack")
        inst:DoTaskInTime(130 * FRAMES,dobishopremove)
    end)
end
local function DoBishopStart(inst,target)
    inst.AnimState:PlayAnimation("transform")
    inst:DoTaskInTime(22* FRAMES,function() inst.SoundEmitter:PlaySound(inst.sounds.levelup) end)
    inst:DoTaskInTime(2.9,function()
        if target and target:IsValid() then
            DoBishopAttack(inst,target)
        else
            inst.AnimState:PlayAnimation("idle_loop")
        end
    end)
end
local function DoSetTarget(inst,owner,target)
    if inst.doremovetask then
        inst.doremovetask:Cancel()
    end
    local pos = target:GetPosition()
    inst.AnimState:PlayAnimation("atk_side_pre")
    inst:DoTaskInTime(8 * FRAMES,function() inst.SoundEmitter:PlaySound(inst.sounds.attack,"attack") end)
    inst:DoTaskInTime(0.924,function()
        inst.AnimState:PlayAnimation("atk_side_loop", true)
        inst.damagetask = inst:DoPeriodicTask(TUNING.SHADOW_BISHOP.ATTACK_TICK,function()
            if owner and owner:IsValid() and target and target:IsValid() and XD_CanAttackTrget(owner, target) then
                local damage = 46
                damage = Xd_CalcDamage(owner,damage,target)
                target.components.combat:GetAttacked(owner, damage)
            end
        end, TUNING.SHADOW_BISHOP.ATTACK_START_TICK)
        inst.fxtask = inst:DoPeriodicTask(1.2, DoSwarmFX, .5)
        inst.SoundEmitter:KillSound("attack")
        inst:DoTaskInTime(130 * FRAMES,dobishopremove)
    end)
end
local function bishopfn()
    local inst = shadowcommonfn("shadow_bishop", true)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.sounds.attack = "dontstarve/sanity/bishop/attack_1"
    inst.sounds.die = "dontstarve/sanity/bishop/die"
    inst.sounds.idle = "dontstarve/sanity/bishop/idle"
    inst.sounds.taunt = "dontstarve/sanity/bishop/taunt"
    inst.sounds.disappear = "dontstarve/sanity/bishop/dissappear"
    inst.sounds.hit = "dontstarve/sanity/bishop/hit_response"
    inst.DoAttack = DoBishopAttack
    inst.OnStart = DoBishopStart
    inst.doremovetask =  inst:DoTaskInTime(10,dorookremove)
    return inst
end
local function bishopfn1()
    local inst = shadowcommonfn("shadow_bishop", true)
    if not TheWorld.ismastersim then
        return inst
    end
    inst.sounds.attack = "dontstarve/sanity/bishop/attack_1"
    inst.sounds.die = "dontstarve/sanity/bishop/die"
    inst.sounds.idle = "dontstarve/sanity/bishop/idle"
    inst.sounds.taunt = "dontstarve/sanity/bishop/taunt"
    inst.sounds.disappear = "dontstarve/sanity/bishop/dissappear"
    inst.sounds.hit = "dontstarve/sanity/bishop/hit_response"
    inst.DoSetTarget = DoSetTarget
    inst.doremovetask =  inst:DoTaskInTime(10,dorookremove)
    return inst
end
return Prefab("ttk_boss_guaiwu_rook",rookfn,createassets("shadow_rook")),
    Prefab("ttk_boss_guaiwu_bishop",bishopfn,createassets("shadow_bishop")),
    Prefab("ttk_boss_wmz_bishop",bishopfn1,createassets("shadow_bishop"))
