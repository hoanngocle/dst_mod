-- Standalone wetness protection; does not need Tu Tien character components.
local function Stop(inst)
    inst.components.debuff:Stop()
end

local function OnAttached(inst, target)
    inst.entity:SetParent(target.entity)
    inst.Transform:SetPosition(0, 0, 0)
    if target.components.moistureimmunity == nil then
        target:AddComponent("moistureimmunity")
    end
    target.components.moistureimmunity:AddSource(inst)
    inst:ListenForEvent("death", function() Stop(inst) end, target)
    inst:ListenForEvent("ms_becameghost", function() Stop(inst) end, target)
end

local function OnExtended(inst)
    inst.components.timer:StopTimer("dryover")
    inst.components.timer:StartTimer("dryover", 240)
end

local function OnDetached(inst, target)
    if target ~= nil and target.components.moistureimmunity ~= nil then
        target.components.moistureimmunity:RemoveSource(inst)
    end
    inst:Remove()
end

local function Fn()
    local inst = CreateEntity()
    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst.Remove)
        return inst
    end
    inst.entity:AddTransform()
    inst.entity:Hide()
    inst.entity:SetCanSleep(false)
    inst:AddTag("CLASSIFIED")
    inst.persists = false
    inst:AddComponent("debuff")
    inst.components.debuff:SetAttachedFn(OnAttached)
    inst.components.debuff:SetDetachedFn(OnDetached)
    inst.components.debuff:SetExtendedFn(OnExtended)
    inst:AddComponent("timer")
    inst.components.timer:StartTimer("dryover", 240)
    inst:ListenForEvent("timerdone", function(item, data)
        if data.name == "dryover" then Stop(item) end
    end)
    return inst
end

return Prefab("nhatvuphuonghoa_buff", Fn)
