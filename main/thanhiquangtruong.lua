local G = GLOBAL
local common = require("thanhiquangtruong_common")
table.insert(PrefabFiles, "thanhiquangtruong")
table.insert(PrefabFiles, "thanhiquangtruongfx")

G.STRINGS.NAMES.THANHIQUANGTRUONG = "Thần Hi Quang Trượng"
G.STRINGS.RECIPE_DESC.THANHIQUANGTRUONG = "Bước nhanh, độn quang tới nơi đã khám phá."
G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.THANHIQUANGTRUONG = "Tăng tốc 30%. Độn quang tốn 1 lượt; qua bản đồ tốn 3. Đá Sa Mạc nạp 15 lượt."

RegisterInventoryItemAtlas("images/inventoryimages/thanhiquangtruong.xml", "thanhiquangtruong.tex")
AddRecipe2("thanhiquangtruong", {
    G.Ingredient("townportaltalisman", 3),
    G.Ingredient("yellowgem", 1),
    G.Ingredient("ttk_lingshi2", 1),
}, G.TECH.MAGIC_THREE, {
    atlas = "images/inventoryimages/thanhiquangtruong.xml",
    image = "thanhiquangtruong.tex",
    no_deconstruction = true,
}, { "MAGIC", "TOOLS" })

local mapblink = G.Action({
    priority = 20,
    rmb = true,
    customarrivecheck = function() return true end,
    mount_valid = true,
    encumbered_valid = true,
    map_action = true,
    map_only = true,
    closes_map = true,
})
mapblink.id = "THANHIQUANGTRUONG_MAPBLINK"
mapblink.str = "Độn Quang"
mapblink.maponly_checkvalidpos_fn = function(act)
    local staff = common.EquippedStaff(act.doer)
    local point = act:GetActionPoint()
    if staff == nil or not staff:HasTag(common.READY_TAG)
        or not common.ValidPoint(act.doer, point, true) then
        return false
    end
    return true, nil, point.x, point.z
end
mapblink.fn = function(act)
    local staff = common.EquippedStaff(act.doer)
    return staff ~= nil and staff.components.blinkstaff ~= nil
        and staff.components.blinkstaff:Blink(act:GetActionPoint(), act.doer, true) or false
end
AddAction(mapblink)
AddStategraphActionHandler("wilson", G.ActionHandler(mapblink, "quicktele"))
AddStategraphActionHandler("wilson_client", G.ActionHandler(mapblink, "quicktele"))

AddComponentAction("POINT", "blinkstaff", function(inst, doer, pos, actions)
    if inst.prefab == common.PREFAB and not inst:HasTag(common.READY_TAG) then
        for i = #actions, 1, -1 do
            if actions[i] == G.ACTIONS.BLINK then
                table.remove(actions, i)
            end
        end
    end
end)

AddComponentPostInit("playercontroller", function(self)
    local original = self.GetMapActions
    self.GetMapActions = function(controller, position, maptarget, actiondef, ...)
        local left, right = original(controller, position, maptarget, actiondef, ...)
        if controller.skip_inherentmapaction or (actiondef ~= nil and actiondef ~= mapblink) then
            return left, right
        end
        local staff = common.EquippedStaff(controller.inst)
        if staff ~= nil and staff:HasTag(common.READY_TAG) then
            local act = G.BufferedAction(controller.inst, nil, mapblink, staff, position)
            right = controller:RemapMapAction(act, position)
        end
        return left, right
    end
end)
