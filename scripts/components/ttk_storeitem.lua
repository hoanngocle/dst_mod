
local range = 8 
local ORANGE_PICKUP_MUST_TAGS = { "_inventoryitem" }
local ORANGE_PICKUP_CANT_TAGS = { "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "fire", "minesprung", "mineactive" }

local function HasPersonalOwner(item)
    return item.components.xd_bd ~= nil and item.components.xd_bd.owner ~= nil
        or item.components.xd_itemlock ~= nil and item.components.xd_itemlock.userid ~= nil
        or item.components.xd_armorfumo ~= nil and item.components.xd_armorfumo.userid ~= nil
        or item._userid ~= nil
end

local function CanStoreItem(inst, item)
    local permission = item.components.playerserver_permission
    return not HasPersonalOwner(item) and not (permission and permission.owner)
end

local function pickup(inst,self)
    if not inst:IsValid() or inst:HasTag("burnt") then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z,self.range or range, ORANGE_PICKUP_MUST_TAGS, ORANGE_PICKUP_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v:IsValid()  and v.components.inventoryitem ~= nil and
            v.components.inventoryitem.canbepickedup and
            v.components.inventoryitem.cangoincontainer and
            not v.components.inventoryitem:IsHeld() and
            CanStoreItem(inst, v) and
            inst.components.container:CanAcceptCount(v) > 0 then
            local Count = inst.components.container:CanAcceptCount(v)
            SpawnPrefab("sand_puff").Transform:SetPosition(v.Transform:GetWorldPosition())
            local v_pos = v:GetPosition()
            if v.components.stackable ~= nil then
                v = v.components.stackable:Get(Count)
            end
            inst.components.container:GiveItem(v, nil, v_pos)
        end
    end
end

local ttk_storeitem = Class(function(self, inst)
    self.inst = inst
    self.cdtime = 10
    self.inst:DoPeriodicTask(self.cdtime, pickup, self.cdtime+math.random(), self)
end)

return ttk_storeitem
