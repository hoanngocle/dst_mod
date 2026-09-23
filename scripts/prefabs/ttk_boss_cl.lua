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
    Asset("ANIM", Boss.ArtPath("anim/xd_cl.zip")),
    Asset("ANIM", Boss.ArtPath("anim/tornado.zip")),
    Asset("ANIM", Boss.ArtPath("anim/twister_actions.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_cl_stroke.zip")),
    Asset("ANIM", Boss.ArtPath("anim/xd_cl_tornado.zip")),
	Asset("ATLAS", "images/inventoryimages/xd_cl.xml"),
    Asset("IMAGE", "images/inventoryimages/xd_cl.tex"),
}
local prefabs = {
}
local function speed_remove_buff(inst)
    if inst._xd_sinkhole_speedpot_task ~= nil then
        inst._xd_sinkhole_speedpot_task:Cancel()
        inst._xd_sinkhole_speedpot_task = nil
    end
    if inst.components.locomotor then
	    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "ttk_boss_sinkhole")
    end
end
local function speed_potion(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "ttk_boss_sinkhole", inst.speedrate or 0.25)
    if inst._xd_sinkhole_speedpot_task ~= nil then
        inst._xd_sinkhole_speedpot_task:Cancel()
        inst._xd_sinkhole_speedpot_task = nil
    end
    inst._xd_sinkhole_speedpot_task = inst:DoTaskInTime(1, speed_remove_buff)
end
local function OnNotifyNearbyPlayers(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z,3,{"locomotor"},noltags)
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
local NUM_FX = 7
local FX_THETA_DELTA = TWOPI / NUM_FX
local FX_RADIUS = 1.6
local function SpawnFx(inst, scale, pos)
    local theta = math.random() * TWOPI
    pos = pos or inst:GetPosition()
    SpawnPrefab("sinkhole_spawn_fx_"..math.random(3)).Transform:SetPosition(pos:Get())
    for i = 1, NUM_FX do
        local dust = SpawnPrefab("sinkhole_spawn_fx_"..math.random(3))
        dust.Transform:SetPosition(
            pos.x + math.cos(theta) * FX_RADIUS * (1 + math.random() * .1),
            0,
            pos.z - math.sin(theta) * FX_RADIUS * (1 + math.random() * .1)
        )
        local s = scale + math.random() * .2
        local x_scale = (i % 2 == 0 and -s) or s
        dust.Transform:SetScale(x_scale, s, s)
        theta = theta + FX_THETA_DELTA
    end
    inst.SoundEmitter:PlaySoundWithParams("dontstarve/creatures/together/antlion/sfx/ground_break", { size = 2 })
end
local function fxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("sinkhole"))
    inst.AnimState:SetBuild(Boss.Art("antlion_sinkhole"))
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.Transform:SetEightFaced()
    inst:AddTag("fx")
    inst:AddTag("NOCLICK")
    inst:AddTag("ttk_boss_sinkhole")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.removetask = inst:DoTaskInTime(12,function()
        if inst.detecttask ~= nil then
            inst.detecttask:Cancel()
            inst.detecttask = nil
        end
        ErodeAway(inst)
    end)
    inst.detecttask = inst:DoPeriodicTask(.6, OnNotifyNearbyPlayers, 0.6 * (.3 + .7 * math.random()))
    inst.persists = false
    inst.SetLifetime = function(inst,time,owner,speed)
        if owner then
            inst.owner = owner
        end
        if speed then
            inst.speedrate = speed
        end
        if inst.removetask then
            inst.removetask:Cancel()
        end
        local pos = inst:GetPosition()
        SpawnFx(inst, 1, pos)
        inst.removetask = inst:DoTaskInTime(time,function()
            if inst.detecttask ~= nil then
                inst.detecttask:Cancel()
                inst.detecttask = nil
            end
            ErodeAway(inst)
        end)
    end
    inst.SetFx = function(inst,dofx)
        if inst.detecttask ~= nil then
            inst.detecttask:Cancel()
            inst.detecttask = nil
        end
        if dofx then
            local pos = inst:GetPosition()
            SpawnFx(inst, dofx, pos)
        end
        inst:DoTaskInTime(3,function()
            ErodeAway(inst)
        end)
    end
    return inst
end
local function fx1fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("sinkhole"))
    inst.AnimState:SetBuild(Boss.Art("antlion_sinkhole"))
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
    inst.Transform:SetEightFaced()
    inst:AddTag("fx")
    inst:AddTag("NOCLICK")
    inst:AddTag("ttk_boss_sinkhole1")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.removetask = inst:DoTaskInTime(12,function()
        if inst.detecttask ~= nil then
            inst.detecttask:Cancel()
            inst.detecttask = nil
        end
        ErodeAway(inst)
    end)
    inst.detecttask = inst:DoPeriodicTask(.6, OnNotifyNearbyPlayers, 0.6 * (.3 + .7 * math.random()))
    inst.persists = false
    inst.SetLifetime = function(inst,time,owner,speed)
        if owner then
            inst.owner = owner
        end
        if speed then
            inst.speedrate = speed
        end
        if inst.removetask then
            inst.removetask:Cancel()
        end
        local pos = inst:GetPosition()
        SpawnFx(inst, 1, pos)
        inst.removetask = inst:DoTaskInTime(time,function()
            if inst.detecttask ~= nil then
                inst.detecttask:Cancel()
                inst.detecttask = nil
            end
            ErodeAway(inst)
        end)
    end
    inst.SetFx = function(inst,dofx)
        if inst.detecttask ~= nil then
            inst.detecttask:Cancel()
            inst.detecttask = nil
        end
        if dofx then
            local pos = inst:GetPosition()
            SpawnFx(inst, dofx, pos)
        end
        inst:DoTaskInTime(3,function()
            ErodeAway(inst)
        end)
    end
    return inst
end
local function ontornadolifetime(inst)
    if inst.damagetask then
        inst.damagetask:Cancel()
    end
    if inst.speedtask then
        inst.speedtask:Cancel()
    end
    if inst.fx then
        inst.fx:Remove()
    end
    inst.AnimState:PlayAnimation("tornado_pst")
    inst:ListenForEvent("animover", function(inst)
        inst:Remove()
    end)
end
local function GetPositionAdjacentTo(p1, p2,distance)
    local offset = p1-p2
    offset:Normalize()
    offset = offset * distance
    return (p2 + offset)
end
local function SingleUpdateRepel(inst,range,item)
	if inst:IsValid() and inst.entity:IsVisible() and inst.cl_speedpos and (item or inst.components.locomotor) then
		local distsq = inst:GetDistanceSqToPoint(inst.cl_speedpos.x, 0, inst.cl_speedpos.z)
		if distsq > 1  then
			local new = GetPositionAdjacentTo(inst.cl_speedpos, inst:GetPosition(),range or 0.1)
			inst.Transform:SetPosition(new:Get())
		end
	end
end
local function DoDamage(inst)
    if inst.nodamage then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = XD_GetDamageTargets(x, y, z,3)
    for i,v in pairs(ents) do
        if inst.owner and inst.owner:IsValid() and v:IsValid() and v ~= inst.owner and XD_CanAttackTrget(inst.owner,v) then
            local damage = 26.3
            damage = Xd_CalcDamage(inst.owner,damage,v)
            v.components.combat:GetAttacked(inst.owner,damage)
        end
    end
end
local nospeedltags = {"abigail","companion","player","INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost","FX"}
if TheNet:GetPVPEnabled() then
    nospeedltags =  {"INLIMBO","wall", "notarget", "noattack", "flight", "invisible", "playerghost","FX"}
end
local function DoSpeed(inst)
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 10, nil,nospeedltags,{"_inventoryitem","locomotor"})
    for k,v in pairs(ents) do
        if v ~= inst and v:IsValid() then
            if v:HasTag("player") then
                if v ~= inst.owner then
                    v:PushEvent("unevengrounddetected", { inst = inst, radius = 6, period = 0.6 })
                end
            elseif v.components.combat and v.components.health ~= nil and not v.components.health:IsDead() and not (v.components.follower and
                (v.components.follower.leader == inst or v.components.follower.leader == inst.owner) ) then
                    if not inst.seeedfn or inst.seeedfn(inst,v) then
                        v.cl_speedpos =  Point(pt.x,pt.y,pt.z)
                        SingleUpdateRepel(v)
                    end
            elseif v:IsValid() and v.Physics and v.components.inventoryitem and not v.components.inventoryitem:IsHeld() and v.entity:GetParent() == nil then
                if not inst.seeedfn or inst.seeedfn(inst,v) then
                    v.cl_speedpos =  Point(pt.x,pt.y,pt.z)
                    SingleUpdateRepel(v,nil,true)
                end
            end
        end
    end
end
local function tornadofn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetBank(Boss.Art("tornado"))
    inst.AnimState:SetBuild(Boss.Art("xd_cl_tornado"))
    inst.AnimState:PlayAnimation("tornado_pre")
    inst.AnimState:PushAnimation("tornado_loop")
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tornado", "spinLoop")
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    if not inst.damagetask then
        inst.damagetask = inst:DoPeriodicTask(0.253,DoDamage)
    end
    if not inst.speedtask then
        inst.speedtask = inst:DoPeriodicTask(0,DoSpeed)
    end
    inst.fx = inst:SpawnChild("ttk_boss_cl_tornadofx")
    inst:DoTaskInTime(5.1, ontornadolifetime)
    inst:DoTaskInTime(7,inst.Remove)
    return inst
end
local function tornadofxfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank(Boss.Art("twister"))
    inst.AnimState:SetBuild(Boss.Art("xd_cl_stroke"))
    inst.AnimState:PlayAnimation("vacuum_loop",true)
    inst.AnimState:SetMultColour(255/255,207/255,41/255,0.7)
    local s  = 0.7
    inst.Transform:SetScale(s, s, s)
    inst:AddTag("fx")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false
    inst:DoTaskInTime(7,inst.Remove)
    return inst
end
return 
    Prefab("ttk_boss_sinkhole", fxfn, assets, prefabs),
    Prefab("ttk_boss_sinkhole1", fx1fn, assets, prefabs),
    Prefab("ttk_boss_cl_tornado", tornadofn, assets, prefabs),
    Prefab("ttk_boss_cl_tornadofx", tornadofxfn, assets, prefabs)
