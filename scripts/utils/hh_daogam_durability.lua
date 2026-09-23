-- Hệ độ bền cho Kiếm Quỷ Vương (hh_daogam).
-- 360 điểm = 100%. hh_daogam2 tự trừ đúng 1 điểm cho mỗi đòn đánh trúng và mỗi lần bị đánh/đỡ đòn.
-- Hết độ bền (0%): kiếm tự tháo khỏi tay về túi/balo (đầy thì rớt xuống đất) và không thể cầm lại
-- cho tới khi độ bền >= 1% (sửa bằng 1 nightmarefuel = +36 điểm = 10% qua action HH_DAOGAM_REPAIR).

local HHDaogamDurability = {}

HHDaogamDurability.MAX_USES = 360
HHDaogamDurability.REPAIR_USES = 36

function HHDaogamDurability.GetRepairPercent()
    return math.floor(HHDaogamDurability.REPAIR_USES / HHDaogamDurability.MAX_USES * 100 + 0.5)
end

function HHDaogamDurability.GetRepairDescription()
    return string.format("Dùng Nhiên Liệu Ác Mộng để khôi phục %d%% độ bền", HHDaogamDurability.GetRepairPercent())
end

-- Tag "hh_daogam_damaged" (tự sync xuống client) để action Sửa chữa chỉ hiện khi độ bền < 100%
local function OnPercentUsedChange(inst, data)
    if data ~= nil and data.percent ~= nil and data.percent < 1 then
        inst:AddTag("hh_daogam_damaged")
    else
        inst:RemoveTag("hh_daogam_damaged")
    end
end

-- Hết độ bền: tự tháo khỏi slot tay, trả về túi/balo; túi đầy thì GiveItem tự rớt xuống đất
function HHDaogamDurability.OnFinished(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil and owner.components.inventory ~= nil
        and inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
        if item ~= nil then
            owner.components.inventory:GiveItem(item)
        end
        if owner.components.talker ~= nil then
            owner.components.talker:Say("Kiếm Quỷ Vương đã cạn năng lượng, cần Nhiên Liệu Ác Mộng để sửa chữa!")
        end
    end
end

-- Gắn độ bền; consumption_action: ACTIONS bị trừ 1 điểm mỗi lần dùng công cụ (nil nếu chỉ trừ khi đánh)
function HHDaogamDurability.AddTo(inst, consumption_action)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(HHDaogamDurability.MAX_USES)
    inst.components.finiteuses:SetUses(HHDaogamDurability.MAX_USES)
    if consumption_action ~= nil then
        inst.components.finiteuses:SetConsumption(consumption_action, 1)
    end
    inst.components.finiteuses:SetOnFinished(HHDaogamDurability.OnFinished)
    inst:ListenForEvent("percentusedchange", OnPercentUsedChange)
end

-- Áp số điểm độ bền lên item mới sinh ra; trả lại item để dùng nối chuỗi
function HHDaogamDurability.ApplyUses(item, uses)
    if item ~= nil and uses ~= nil and item.components.finiteuses ~= nil then
        item.components.finiteuses:SetUses(uses)
    end
    return item
end

-- Chuyển độ bền hiện tại từ item cũ sang item mới (gọi TRƯỚC khi Remove item cũ)
function HHDaogamDurability.Transfer(old, new)
    if old ~= nil and old.components.finiteuses ~= nil then
        HHDaogamDurability.ApplyUses(new, old.components.finiteuses:GetUses())
    end
    return new
end

return HHDaogamDurability
