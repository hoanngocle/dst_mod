-- Statically ported Tu Tien 19.7 combat; see tools/port_phamnhan_boss_combat.py.
local Boss = require("ttk_boss_util")
local TUNING = Boss.TUNING
local STRINGS = Boss.STRINGS
local Prefab = Boss.Prefab
local function OnTimer(inst, data)
    if data.name == "buffover" then
        if inst.overfn ~= nil then
            inst.overfn(inst,inst.components.debuff.target)
        end
        inst.components.debuff:Stop()
    end
end
local function OnStart(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)
    if inst.startfn then
        inst.startfn(inst, target)
    end
    inst:ListenForEvent("death", function()
        inst.components.debuff:Stop()
    end, target)
end
local function OnExtended(inst,target,time)
    if inst.extended_timefn ~= nil then
        inst.extended_timefn(inst,target,time)
    elseif inst.components.timer then
        if inst.maxtime then
            local timeleft = inst.components.timer:GetTimeLeft("buffover") or 0
            local time = math.min(inst.maxtime,timeleft + inst.bufftime)
            inst.components.timer:StopTimer("buffover")
            inst.components.timer:StartTimer("buffover",time)
        else
            inst.components.timer:StopTimer("buffover")
            inst.components.timer:StartTimer("buffover",inst.bufftime)
        end
    end
    if inst.extendedfn then
        inst.extendedfn(inst, target)
    end
end
local function OnDeath(inst,target)
    if inst.deathfn then
        inst.deathfn(inst, target)
    end
	inst:Remove()
end
local function buff_OnSave(inst, data)
    if inst.no_xdsave then
        data.no_xdsave = inst.no_xdsave
    end
    if inst.level then
        data.level = inst.level
    end
end
local function buff_OnLoad(inst, data)
    if data == nil then
        return
    end
    if data.no_xdsave then
        inst.no_xdsave = data.no_xdsave
    end
    if data.level then
        inst.level = data.level
    end
end
local function makebuffs(name,data)
	local function fn()
        local inst = CreateEntity()
        if not TheWorld.ismastersim then
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end
        inst.entity:AddTransform()
        inst.entity:Hide()
        inst.persists = false
        inst:AddTag("CLASSIFIED")
        for k, v in pairs(data) do
            inst[k] = v
        end
        if data.masterfn then
            data.masterfn(inst)
        end
        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnStart)
        inst.components.debuff:SetDetachedFn(OnDeath)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff.keepondespawn = true
        if  data.bufftime ~= nil then
		    inst:AddComponent("timer")
		    inst.components.timer:StartTimer("buffover", data.bufftime)
            inst:ListenForEvent("timerdone", OnTimer)
        end
        inst.OnSave = buff_OnSave
        inst.OnLoad = buff_OnLoad
		return inst
	end
	return Prefab(name, fn)
end
return makebuffs("ttk_boss_ignoreplanarentity",
        {
            bufftime = 30,
            startfn = function(inst,target)
                if target.components.planarentity ~= nil then
                    target.components.planarentity.ttk_boss_ignore = true
                end
            end,
            deathfn = function(inst,target)
                if target.components.planarentity ~= nil then
                    target.components.planarentity.ttk_boss_ignore = false
                end
            end,
        }
    ),
makebuffs("ttk_boss_slow_buff",
    {
        bufftime = 12,
        startfn = function(inst,target)
            if target.components.locomotor ~= nil then
                target.components.locomotor:SetExternalSpeedMultiplier(target, "ttk_boss_slow_buff", 0.7)
            end
            if not target.ttk_boss_slow_buff_ent then
                target.ttk_boss_slow_buff_ent =  SpawnPrefab("ttk_boss_slow_buff_ent")
                target.ttk_boss_slow_buff_ent:SetOwner(target)
            end
        end,
        deathfn = function(inst,target)
            if target.components.locomotor ~= nil then
                target.components.locomotor:RemoveExternalSpeedMultiplier(target, "ttk_boss_slow_buff")
            end
            if target.ttk_boss_slow_buff_ent then
                target.ttk_boss_slow_buff_ent:Remove()
                target.ttk_boss_slow_buff_ent = nil
            end
        end,
    }),
makebuffs("ttk_boss_spiderqueen_buff1",
    {
        bufftime = 3,
        masterfn = function(inst)
            inst.no_xdsave = true
        end,
        startfn = function(inst,target)
            if not inst.ttk_boss_spiderqueen_buffent1 then
                inst.ttk_boss_spiderqueen_buffent1 =  SpawnPrefab("ttk_boss_spiderqueen_buffent1")
                inst.ttk_boss_spiderqueen_buffent1:SetOwner(target)
            end
        end,
        deathfn = function(inst,target)
            if inst.ttk_boss_spiderqueen_buffent1 then
                inst.ttk_boss_spiderqueen_buffent1:Remove()
                inst.ttk_boss_spiderqueen_buffent1 = nil
            end
            if target and target:IsValid() and inst.owner and inst.owner:CanSpell() then
                local fx = SpawnAt("ttk_boss_spiderqueen_web",target)
                inst.owner:AddShadowFx(fx)
                fx:SetLevel(480,20)
            end
        end,
    }),
makebuffs("ttk_boss_spiderqueen_buff2",
    {
        bufftime = 4.5,
        masterfn = function(inst)
            inst.no_xdsave = true
        end,
        startfn = function(inst,target)
            inst.rotation = math.random(-180,180)
            if not inst.fx then
                inst.fx =  SpawnPrefab("ttk_boss_spiderqueen_buffent2")
                inst.fx:SetOwner(target)
            end
            if not inst.arrowfx then
                inst.arrowfx =  SpawnAt("ttk_boss_spiderqueen_waveent",target)
                inst.arrowfx:SetOwner(target,inst.rotation)
            end
        end,
        deathfn = function(inst,target)
            if inst.fx then
                inst.fx:Remove()
                inst.fx = nil
            end
            if inst.arrowfx then
                inst.arrowfx:Remove()
                inst.arrowfx = nil
            end
            if target and target:IsValid() and inst.owner and inst.owner:CanSpell() then
                local pos = target:GetPosition()
                inst.owner:PushWave(pos,inst.rotation)
            end
        end,
    }),
makebuffs("ttk_boss_spiderqueen_buff3",
    {
        bufftime = 6,
        masterfn = function(inst)
            inst.no_xdsave = true
        end,
        startfn = function(inst,target)
            if not inst.fx then
                inst.fx =  SpawnPrefab("ttk_boss_spiderqueen_buffent3")
                inst.fx:SetOwner(target)
            end
        end,
        deathfn = function(inst,target)
            if inst.fx then
                inst.fx:Remove()
                inst.fx = nil
            end
        end,
    })
