-- Kiếm Quỷ Vương (hh_daogam): sửa độ bền bằng nightmarefuel.
-- Sửa chữa độ bền: kéo 1 nightmarefuel thả vào kiếm (+36 điểm = 10%).
-- Dùng action riêng (không dùng repairable gốc) để đúng 36 điểm/lần thay vì TUNING.NIGHTMAREFUEL_FINITEUSESREPAIRVALUE = 50.
local HHDaogamDurability = GLOBAL.require("utils/hh_daogam_durability")

local function ApplyHHDaogam2FlameBuild(inst, owner)
    if owner ~= nil and owner._hh_daogam2_purple_build then
        inst.AnimState:SetBuild("hh_purple_warg_mutated_breath_fx")
    end
end

local function InstallHHDaogam2FlameBuild(prefab)
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim or inst.SetFXOwner == nil then
            return
        end
        local old_set_fx_owner = inst.SetFXOwner
        inst.SetFXOwner = function(fx, owner, ...)
            old_set_fx_owner(fx, owner, ...)
            ApplyHHDaogam2FlameBuild(fx, owner)
        end
    end)
end

InstallHHDaogam2FlameBuild("warg_mutated_breath_fx")
InstallHHDaogam2FlameBuild("warg_mutated_ember_fx")

local hh_daogam_repair_action = AddAction("HH_DAOGAM_REPAIR", "Sửa chữa", function(act)
    if act.doer ~= nil and act.target ~= nil and act.invobject ~= nil
        and act.target.components.finiteuses ~= nil
        and act.invobject.prefab == "nightmarefuel" then
        local fu = act.target.components.finiteuses
        if fu:GetUses() >= fu.total then
            return false
        end
        local fuel = act.invobject
        if fuel.components.stackable ~= nil then
            fuel = fuel.components.stackable:Get()
        end
        fuel:Remove()
        fu:Repair(HHDaogamDurability.REPAIR_USES)
        local owner = act.target.components.inventoryitem ~= nil and act.target.components.inventoryitem.owner or nil
        local sound_source = owner ~= nil and owner or act.target
        if sound_source.SoundEmitter ~= nil then
            sound_source.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
        end
        return true
    end
end)
hh_daogam_repair_action.rmb = true

-- nightmarefuel gốc đã có component "repairer" (tag finiteuses_nightmare) — chỉ thêm action của mình,
-- gate bằng tag nên không ảnh hưởng cơ chế sửa đồ shadow của game gốc
AddComponentAction("USEITEM", "repairer", function(inst, doer, target, actions, right)
    if inst:HasTag("finiteuses_nightmare") and ((target:HasTag("hh_daogam_item") and target:HasTag("hh_daogam_damaged")) or target:HasTag("hh_daogam2_item") or target:HasTag("hh_daogam3_item") or target:HasTag("hh_daogam4_item") or target:HasTag("hh_daogam5_item")) then
        table.insert(actions, GLOBAL.ACTIONS.HH_DAOGAM_REPAIR)
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.HH_DAOGAM_REPAIR, "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.HH_DAOGAM_REPAIR, "dolongaction"))

-- Tên hiển thị
GLOBAL.STRINGS.NAMES.HH_DAOGAM = "Kiếm Quỷ Vương"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.HH_DAOGAM = "Thanh kiếm tràn đầy sức mạnh bóng tối"
