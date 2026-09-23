local __b_UG__ = {Asset("ANIM", "anim/resource_amulet.zip")}
local __b__u_G_ = {{name = "Bùa Ma Thuật", mode = "strengthen"}}
local function __BU_G__(_BU_g, _B__ug_)
end
local function bU_g_(_B_U_g_, b__U__g)
end
function MakeSketchPrefab(BU__g__)
    local b_U_G__ = "nn_magicpaper"
    STRINGS["NAMES"][string["upper"](b_U_G__)] = BU__g__["name"]
    local function Bug()
        local __b_U__G__ = CreateEntity()
        __b_U__G__["entity"]:AddTransform()
        __b_U__G__["entity"]:AddAnimState()
        __b_U__G__["entity"]:AddNetwork()
        MakeInventoryPhysics(__b_U__G__)
        __b_U__G__["AnimState"]:SetBank "hh_vat_pham_ground_so_1"
        __b_U__G__["AnimState"]:SetBuild "hh_vat_pham_ground_so_1"
        __b_U__G__["AnimState"]:PlayAnimation "idle_bua_ma_thuat"
        __b_U__G__:AddTag "nn_magicpaper"
        MakeInventoryFloatable(__b_U__G__, "med", nil, 0.75)
        __b_U__G__["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __b_U__G__
        end
        __b_U__G__:AddComponent "named"
        __b_U__G__:AddComponent "inspectable"
        __b_U__G__:AddComponent "inventoryitem"
        __b_U__G__["components"]["inventoryitem"]["imagename"] = "bua_ma_thuat_inventory"
        __b_U__G__["components"]["inventoryitem"]["atlasname"] = "images/vat_pham_inventory_so_1.xml"
        __b_U__G__:AddComponent "fuel"
        __b_U__G__["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
        MakeHauntableLaunch(__b_U__G__)
        __b_U__G__["OnLoad"] = __BU_G__
        __b_U__G__["OnSave"] = bU_g_
        __b_U__G__["mode"] = BU__g__["mode"]
        __b_U__G__["level"] = BU__g__["level"]
        __b_U__G__["components"]["named"]:SetName(BU__g__["name"])
        return __b_U__G__
    end
    return Prefab(b_U_G__, Bug, __b_UG__)
end
local __b_UG = {}
for __BU_G, B__uG__ in ipairs(__b__u_G_) do
    table["insert"](__b_UG, MakeSketchPrefab(B__uG__))
end
return unpack(__b_UG)
