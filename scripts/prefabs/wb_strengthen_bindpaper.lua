local function __b__ug__(Bug__, __buG__)
    local _B__u_G__ = {Asset("ANIM", "anim/" .. __buG__ .. ".zip")}
    local function __b__ug()
        local _bU_g = CreateEntity()
        _bU_g["entity"]:AddTransform()
        _bU_g["entity"]:AddNetwork()
        _bU_g:AddTag "bundle"
        _bU_g["name"] = " "
        _bU_g["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return _bU_g
        end
        _bU_g:AddComponent "container"
        _bU_g["components"]["container"]:WidgetSetup(Bug__)
        _bU_g["persists"] = (476 * 57 + 386 * 296 ~= 141388)
        return _bU_g
    end
    return Prefab(Bug__, __b__ug, _B__u_G__)
end
local function __B__u_g_(__B__ug_)
    local __bu__g = {Asset("ANIM", "anim/lucky_symbols.zip")}
    local function __b_U__G_()
        local __b__U__g_ = CreateEntity()
        __b__U__g_["entity"]:AddTransform()
        __b__U__g_["entity"]:AddAnimState()
        __b__U__g_["entity"]:AddNetwork()
        MakeInventoryPhysics(__b__U__g_)
        __b__U__g_["AnimState"]:SetBank "lucky_symbols"
        __b__U__g_["AnimState"]:SetBuild "lucky_symbols"
        __b__U__g_["AnimState"]:PlayAnimation "destiny_symbol"
        __b__U__g_:AddTag "wb_strengthen_bindpaper"
        MakeInventoryFloatable(__b__U__g_, "med", nil, 0.75)
        __b__U__g_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __b__U__g_
        end
        __b__U__g_:AddComponent "named"
        __b__U__g_:AddComponent "inspectable"
        __b__U__g_:AddComponent "inventoryitem"
        __b__U__g_["components"]["inventoryitem"]["imagename"] = "destiny_symbol"
        __b__U__g_["components"]["inventoryitem"]["atlasname"] = "images/destiny_symbol.xml"
        local function B__u__g_(__b__U__g_, __B__U_g__)
            __b__U__g_:Remove()
        end
        __b__U__g_:AddComponent "bundlemaker"
        __b__U__g_["components"]["bundlemaker"]:SetBundlingPrefabs(
            "wb_strengthen_bindpaper_container",
            "wb_strengthen_bindpaper_bundle"
        )
        __b__U__g_["components"]["bundlemaker"]:SetOnStartBundlingFn(B__u__g_)
        __b__U__g_:AddComponent "fuel"
        __b__U__g_["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
        MakeHauntableLaunch(__b__U__g_)
        return __b__U__g_
    end
    return Prefab(__B__ug_, __b_U__G_, __bu__g)
end
local function _b__U__G__(__bu_G_)
    local function __BU__G()
        local bU_G_ = CreateEntity()
        bU_G_["entity"]:AddTransform()
        bU_G_["entity"]:AddAnimState()
        bU_G_["entity"]:AddNetwork()
        bU_G_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return bU_G_
        end
        bU_G_:AddComponent "unwrappable"
        function bU_G_.components.unwrappable.WrapItems(B_ug, __B__UG, _b_u__G)
            for _b_ug_, b__u__g in ipairs(__B__UG) do
                local __B_u_G = b__u__g and b__u__g["components"]["wb_strengthen"]
                if __B_u_G then
                    if __B_u_G:HasBuff "bind" then
                        __B_u_G:UnBindBuff "bind"
                        _b_u__G["components"]["talker"]:Say "Bây giờ nó đã trở lại bình thường"
                    else
                        __B_u_G:BindBuff("bind", {userid = _b_u__G["userid"], name = _b_u__G["name"]})
                        _b_u__G["components"]["talker"]:Say "Người khác sẽ ko thể cầm nó lên hahaha"
                    end
                end
                _b_u__G["components"]["inventory"]:GiveItem(b__u__g, nil, _b_u__G:GetPosition())
            end
            bU_G_:Remove()
        end
        return bU_G_
    end
    return Prefab(__bu_G_, __BU__G)
end
return __b__ug__("wb_strengthen_bindpaper_container", "ui_bundle_2x2"), _b__U__G__ "wb_strengthen_bindpaper_bundle", __B__u_g_ "wb_strengthen_bindpaper"
