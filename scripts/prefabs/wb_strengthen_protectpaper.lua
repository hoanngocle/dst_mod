local _b__U__G__ = {Asset("ANIM", "anim/keep_amulet.zip")}
local Bug__ = {{name = "Bùa Bảo Vệ", mode = "strengthen"}}
local function __buG__(_bU_g, __B__ug_)
end
local function _B__u_G__(__bu__g, __b_U__G_)
end
function MakeSketchPrefab(__b__U__g_)
    local B__u__g_ = "wb_strengthen_" .. __b__U__g_["mode"] .. "_protectpaper"
    STRINGS["NAMES"][string["upper"](B__u__g_)] = __b__U__g_["name"]
    local function __B__U_g__()
        local __bu_G_ = CreateEntity()
        __bu_G_["entity"]:AddTransform()
        __bu_G_["entity"]:AddAnimState()
        __bu_G_["entity"]:AddNetwork()
        MakeInventoryPhysics(__bu_G_)
        __bu_G_["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
        __bu_G_["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
        __bu_G_["AnimState"]:PlayAnimation "idle_bua_bao_ve"
        __bu_G_:AddTag "wb_strengthen_protectpaper"
        MakeInventoryFloatable(__bu_G_, "med", nil, 0.75)
        __bu_G_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __bu_G_
        end
        __bu_G_:AddComponent "named"
        __bu_G_:AddComponent "inspectable"
        __bu_G_:AddComponent "inventoryitem"
        __bu_G_["components"]["inventoryitem"]["imagename"] = "bua_bao_ve_inventory"
        __bu_G_["components"]["inventoryitem"]["atlasname"] = "images/vat_pham_inventory_so_1.xml"
        __bu_G_:AddComponent "fuel"
        __bu_G_["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
        MakeHauntableLaunch(__bu_G_)
        __bu_G_["OnLoad"] = __buG__
        __bu_G_["OnSave"] = _B__u_G__
        __bu_G_["mode"] = __b__U__g_["mode"]
        __bu_G_["level"] = __b__U__g_["level"]
        __bu_G_["components"]["named"]:SetName(__b__U__g_["name"])
        return __bu_G_
    end
    return Prefab(B__u__g_, __B__U_g__, _b__U__G__)
end
local __b__ug = {}
for __BU__G, bU_G_ in ipairs(Bug__) do
    table["insert"](__b__ug, MakeSketchPrefab(bU_G_))
end
return unpack(__b__ug)
