local function _b__U__G__(_bU_g, __B__ug_)
    local __bu__g = {Asset("ANIM", "anim/" .. __B__ug_ .. ".zip")}
    local function __b_U__G_()
        local __b__U__g_ = CreateEntity()
        __b__U__g_["entity"]:AddTransform()
        __b__U__g_["entity"]:AddNetwork()
        __b__U__g_:AddTag "bundle"
        __b__U__g_["name"] = " "
        __b__U__g_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __b__U__g_
        end
        __b__U__g_:AddComponent "container"
        __b__U__g_["components"]["container"]:WidgetSetup(_bU_g)
        __b__U__g_["persists"] = (476 * 57 + 386 * 296 ~= 141388)
        return __b__U__g_
    end
    return Prefab(_bU_g, __b_U__G_, __bu__g)
end
local function Bug__(B__u__g_, __B__U_g__, __bu_G_, __BU__G, bU_G_)
    local B_ug = {Asset("ANIM", "anim/lucky_symbols.zip")}
    local function __B__UG()
        local _b_u__G = CreateEntity()
        _b_u__G["entity"]:AddTransform()
        _b_u__G["entity"]:AddAnimState()
        _b_u__G["entity"]:AddNetwork()
        MakeInventoryPhysics(_b_u__G)
        _b_u__G["AnimState"]:SetBank "lucky_symbols"
        _b_u__G["AnimState"]:SetBuild "lucky_symbols"
        if bU_G_ then
            _b_u__G["AnimState"]:PlayAnimation "prayer_symbol"
        else
            _b_u__G["AnimState"]:PlayAnimation "keep_symbol"
        end
        _b_u__G["mode"] = __B__U_g__
        _b_u__G["level"] = __bu_G_
        _b_u__G["force"] = __BU__G
        _b_u__G:AddTag "wb_strengthen_levelpaper"
        MakeInventoryFloatable(_b_u__G, "med", nil, 0.75)
        _b_u__G["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return _b_u__G
        end
        _b_u__G:AddComponent "named"
        _b_u__G:AddComponent "inspectable"
        _b_u__G:AddComponent "inventoryitem"
        if bU_G_ then
            _b_u__G["components"]["inventoryitem"]["imagename"] = "prayer_symbol"
            _b_u__G["components"]["inventoryitem"]["atlasname"] = "images/prayer_symbol.xml"
        else
            _b_u__G["components"]["inventoryitem"]["imagename"] = "keep_symbol"
            _b_u__G["components"]["inventoryitem"]["atlasname"] = "images/keep_symbol.xml"
        end
        local function _b_ug_(_b_u__G, b__u__g)
            if b__u__g["components"]["bundler"] then
                local __B_u_G = b__u__g["components"]["bundler"]["bundlinginst"]
                __B_u_G["mode"] = _b_u__G["mode"]
                __B_u_G["level"] = _b_u__G["level"]
                __B_u_G["force"] = _b_u__G["force"]
            end
            _b_u__G:Remove()
        end
        _b_u__G:AddComponent "bundlemaker"
        _b_u__G["components"]["bundlemaker"]:SetBundlingPrefabs(
            "wb_strengthen_levelpaper_container",
            "wb_strengthen_levelpaper_bundle"
        )
        _b_u__G["components"]["bundlemaker"]:SetOnStartBundlingFn(_b_ug_)
        _b_u__G:AddComponent "fuel"
        _b_u__G["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
        MakeHauntableLaunch(_b_u__G)
        return _b_u__G
    end
    return Prefab(B__u__g_, __B__UG, B_ug)
end
local function __buG__(bU_G)
    local function __bU__G_()
        local __bUG = CreateEntity()
        __bUG["entity"]:AddTransform()
        __bUG["entity"]:AddAnimState()
        __bUG["entity"]:AddNetwork()
        __bUG["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __bUG
        end
        __bUG:AddComponent "unwrappable"
        function __bUG.components.unwrappable.WrapItems(_b_u_G_, buG, b__U_G_)
            if b__U_G_["components"]["bundler"] then
                local BU_G__ = b__U_G_["components"]["bundler"]["bundlinginst"]
                local __b__u__g_ = 0
                for _b_Ug, __b_ug__ in ipairs(buG) do
                    local _BUG_ = __b_ug__ and __b_ug__["components"]["wb_strengthen"]
                    local previous_level = _BUG_ and _BUG_:GetLevel()
                    if _BUG_ and (BU_G__["force"] or not _BUG_["do_mode"] or _BUG_["do_mode"] == BU_G__["mode"]) then
                        __b_ug__["components"]["wb_strengthen"]["do_mode"] = BU_G__["mode"]
                        if
                            BU_G__["level"] and BU_G__["level"] == 6 and
                                __b_ug__["components"]["wb_strengthen"]["level"] == 5
                         then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(
                                __b_ug__["components"]["wb_strengthen"]:GetLevel() + 1,
                                (25 - 452 - 50 == -477)
                            )
                        elseif
                            BU_G__["level"] and BU_G__["level"] == 7 and
                                __b_ug__["components"]["wb_strengthen"]["level"] == 6
                         then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(
                                __b_ug__["components"]["wb_strengthen"]:GetLevel() + 1,
                                (262 * 275 + 476 * 140 - 212 ~= 138487)
                            )
                        elseif
                            BU_G__["level"] and BU_G__["level"] == 8 and
                                __b_ug__["components"]["wb_strengthen"]["level"] == 7
                         then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(
                                __b_ug__["components"]["wb_strengthen"]:GetLevel() + 1,
                                (197 - 394 * 260 * 313 ~= -32063519)
                            )
                        elseif
                            BU_G__["level"] and BU_G__["level"] == 9 and
                                __b_ug__["components"]["wb_strengthen"]["level"] == 8
                         then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(
                                __b_ug__["components"]["wb_strengthen"]:GetLevel() + 1,
                                (116 - 222 * 422 == -93568)
                            )
                        elseif
                            BU_G__["level"] and BU_G__["level"] == 10 and
                                __b_ug__["components"]["wb_strengthen"]["level"] == 9
                         then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(
                                __b_ug__["components"]["wb_strengthen"]:GetLevel() + 1,
                                (388 + 461 * 97 + 113 == 45218)
                            )
                        elseif
                            BU_G__["level"] and BU_G__["level"] == 11 and
                                __b_ug__["components"]["wb_strengthen"]["level"] == 10
                         then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(
                                __b_ug__["components"]["wb_strengthen"]:GetLevel() + 1,
                                (126 - 161 + 335 + 145 == 445)
                            )
                        elseif
                            BU_G__["level"] and BU_G__["level"] == 12 and
                                __b_ug__["components"]["wb_strengthen"]["level"] == 11
                         then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(
                                __b_ug__["components"]["wb_strengthen"]:GetLevel() + 1,
                                (26 * 330 * 305 ~= 2616904)
                            )
                        elseif BU_G__["level"] and BU_G__["level"] == 0 then
                            __b_ug__["components"]["wb_strengthen"]:SetLevel(BU_G__["level"])
                        else
                            b__U_G_["components"]["inventory"]:GiveItem(__b_ug__, nil, b__U_G_:GetPosition())
                            return b__U_G_["components"]["talker"]:Say "Trang bị không tương thích với cuộn cường hoá này"
                        end
                        __b__u__g_ = __b__u__g_ + 1
                        if TheWorld.ismastersim and _BUG_:GetLevel() ~= previous_level then
                            b__U_G_:PushEvent("ttk_strengthen_scroll_used", {
                                prefab=b__U_G_.components.bundler.itemprefab, level=_BUG_:GetLevel() })
                        end
                    end
                    b__U_G_["components"]["inventory"]:GiveItem(__b_ug__, nil, b__U_G_:GetPosition())
                end
                local __Bu_G__ = "khôi phục"
                if BU_G__["mode"] == "strengthen" then
                    __Bu_G__ = "cường hoá"
                end
                if __b__u__g_ < #buG then
                    local bU__G_ = b__U_G_["components"]["bundler"]
                    local __B__u_g__ =
                        SpawnPrefab(bU__G_["itemprefab"], bU__G_["itemskinname"], bU__G_["wrappedskin_id"])
                    if __B__u_g__ ~= nil then
                        b__U_G_["components"]["inventory"]:GiveItem(__B__u_g__, nil, b__U_G_:GetPosition())
                    end
                    return b__U_G_["components"]["talker"]:Say("Trang bị này ko thể " .. __Bu_G__ .. " nữa")
                end
                b__U_G_["components"]["talker"]:Say("Đã " .. __Bu_G__ .. " thành công")
                __bUG:Remove()
            end
        end
        return __bUG
    end
    return Prefab(bU_G, __bU__G_)
end
local function _B__u_G__(_Bug, __B__u__G__, b__U__G_, __b__U_g__, __b__U_G)
    local __b_Ug_ = {Asset("ANIM", "anim/blueprint_sketch.zip")}
    local function __B_u__g()
        local BU_G_ = CreateEntity()
        BU_G_["entity"]:AddTransform()
        BU_G_["entity"]:AddAnimState()
        BU_G_["entity"]:AddNetwork()
        MakeInventoryPhysics(BU_G_)
        BU_G_["AnimState"]:SetBank "blueprint_sketch"
        BU_G_["AnimState"]:SetBuild "blueprint_sketch"
        if __b__U_G then
            BU_G_["AnimState"]:PlayAnimation "idle"
        else
            BU_G_["AnimState"]:PlayAnimation "idle"
        end
        BU_G_["mode"] = __B__u__G__
        BU_G_["level"] = b__U__G_
        BU_G_["force"] = __b__U_g__
        BU_G_:AddTag "wb_strengthen_levelpaper"
        MakeInventoryFloatable(BU_G_, "med", nil, 0.75)
        BU_G_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return BU_G_
        end
        BU_G_:AddComponent "named"
        BU_G_:AddComponent "inspectable"
        BU_G_:AddComponent "inventoryitem"
        BU_G_["components"]["inventoryitem"]:ChangeImageName "sketch"
        local function __BUG__(BU_G_, BU__g_)
            if BU__g_["components"]["bundler"] then
                local __b_U_G = BU__g_["components"]["bundler"]["bundlinginst"]
                __b_U_G["mode"] = BU_G_["mode"]
                __b_U_G["level"] = BU_G_["level"]
                __b_U_G["force"] = BU_G_["force"]
            end
            BU_G_:Remove()
        end
        BU_G_:AddComponent "bundlemaker"
        BU_G_["components"]["bundlemaker"]:SetBundlingPrefabs(
            "wb_strengthen_levelpaper_container",
            "wb_strengthen_levelpaper_bundle_test"
        )
        BU_G_["components"]["bundlemaker"]:SetOnStartBundlingFn(__BUG__)
        BU_G_:AddComponent "fuel"
        BU_G_["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
        MakeHauntableLaunch(BU_G_)
        return BU_G_
    end
    return Prefab(_Bug, __B_u__g, __b_Ug_)
end
local function __b__ug(_b_uG)
    local function B__u__G()
        local b__U_g_ = CreateEntity()
        b__U_g_["entity"]:AddTransform()
        b__U_g_["entity"]:AddAnimState()
        b__U_g_["entity"]:AddNetwork()
        b__U_g_["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return b__U_g_
        end
        b__U_g_:AddComponent "unwrappable"
        function b__U_g_.components.unwrappable.WrapItems(__b_u_G_, _bu__G, b__U_g__)
            if b__U_g__["components"]["bundler"] then
                local __BuG = b__U_g__["components"]["bundler"]["bundlinginst"]
                local B__U_G_ = 0
                for BU_g_, B_U__G__ in ipairs(_bu__G) do
                    local __bUg = B_U__G__ and B_U__G__["components"]["wb_strengthen"]
                    if __bUg and (__BuG["force"] or not __bUg["do_mode"] or __bUg["do_mode"] == __BuG["mode"]) then
                        B_U__G__["components"]["wb_strengthen"]["do_mode"] = __BuG["mode"]
                        if __BuG["level"] and __BuG["level"] == 5 then
                            B_U__G__["components"]["wb_strengthen"]:SetLevel(5, (253 + 471 - 365 == 359))
                        elseif __BuG["level"] and __BuG["level"] == 7 then
                            B_U__G__["components"]["wb_strengthen"]:SetLevel(7, (139 * 387 + 260 - 454 == 53599))
                        elseif __BuG["level"] and __BuG["level"] == 9 then
                            B_U__G__["components"]["wb_strengthen"]:SetLevel(
                                9,
                                (false and true or not false or
                                    not false and not false and false and not false and not false and false and false and
                                        not false or
                                    false)
                            )
                        elseif __BuG["level"] and __BuG["level"] == 11 then
                            B_U__G__["components"]["wb_strengthen"]:SetLevel(11, (358 * 171 * 334 + 276 ~= 20447092))
                        elseif __BuG["level"] and __BuG["level"] == 13 then
                            B_U__G__["components"]["wb_strengthen"]:SetLevel(
                                13,
                                (333 * 262 * 139 + 252 - 312 == 12127134)
                            )
                        else
                            b__U_g__["components"]["inventory"]:GiveItem(B_U__G__, nil, b__U_g__:GetPosition())
                            return b__U_g__["components"]["talker"]:Say "Trang bị không tương thích với cuộn cường hoá này"
                        end
                        B__U_G_ = B__U_G_ + 1
                    end
                    b__U_g__["components"]["inventory"]:GiveItem(B_U__G__, nil, b__U_g__:GetPosition())
                end
                local _B_U_g = "khôi phục"
                if __BuG["mode"] == "strengthen" then
                    _B_U_g = "cường hoá"
                end
                if B__U_G_ < #_bu__G then
                    local buG_ = b__U_g__["components"]["bundler"]
                    local _b_U__g__ = SpawnPrefab(buG_["itemprefab"], buG_["itemskinname"], buG_["wrappedskin_id"])
                    if _b_U__g__ ~= nil then
                        b__U_g__["components"]["inventory"]:GiveItem(_b_U__g__, nil, b__U_g__:GetPosition())
                    end
                    return b__U_g__["components"]["talker"]:Say("Trang bị này ko thể " .. _B_U_g .. " nữa")
                end
                b__U_g__["components"]["talker"]:Say("Đã " .. _B_U_g .. " thành công")
                b__U_g_:Remove()
            end
        end
        return b__U_g_
    end
    return Prefab(_b_uG, B__u__G)
end
return _b__U__G__("wb_strengthen_levelpaper_container", "ui_bundle_2x2"), __buG__ "wb_strengthen_levelpaper_bundle", __b__ug "wb_strengthen_levelpaper_bundle_test", _B__u_G__(
    "lv_5",
    "strengthen",
    5,
    (211 * 283 - 108 + 143 - 75 == 59681),
    (1 * 70 - 338 ~= -266)
), _B__u_G__("lv_7", "strengthen", 7, (341 - 21 + 403 == 732), (435 - 491 * 392 * 143 - 260 == -27523321)), _B__u_G__(
    "lv_9",
    "strengthen",
    9,
    (368 + 421 + 89 + 356 ~= 1234),
    (424 + 149 + 188 * 127 == 24449)
), _B__u_G__("lv_11", "strengthen", 11, (486 - 55 * 40 ~= -1714), (214 + 39 - 94 - 439 == -280)), _B__u_G__(
    "lv_13",
    "strengthen",
    13,
    (86 * 103 * 222 - 6 == 1966472),
    (17 + 43 + 483 + 11 + 70 ~= 634)
), Bug__(
    "wb_strengthen_strengthen_6_levelpaper",
    "strengthen",
    6,
    (false and true and false and false and not false and not false and true and not false and false),
    (21 * 279 - 114 - 375 == 5370)
), Bug__(
    "wb_strengthen_strengthen_7_levelpaper",
    "strengthen",
    7,
    (470 - 440 + 325 - 395 == -30),
    (327 - 50 * 217 ~= -10520)
), Bug__(
    "wb_strengthen_strengthen_8_levelpaper",
    "strengthen",
    8,
    (374 * 141 * 158 == 8331979),
    (false or not false and not true and false and false and not true and true and false or not true or not false or
        true and not false)
), Bug__(
    "wb_strengthen_strengthen_9_levelpaper",
    "strengthen",
    9,
    (431 * 294 + 386 - 154 == 126954),
    (221 * 371 * 302 - 172 * 453 ~= 24683373)
), Bug__(
    "wb_strengthen_strengthen_10_levelpaper",
    "strengthen",
    10,
    (210 + 123 * 389 - 40 - 112 == 47909),
    (448 - 178 * 148 - 79 + 74 ~= -25899)
), Bug__(
    "wb_strengthen_strengthen_11_levelpaper",
    "strengthen",
    11,
    (false or
        not false and true and not false and false and false and false and false and false and false and false and
            not false and
            not false),
    (302 + 305 + 120 == 727)
), Bug__(
    "wb_strengthen_strengthen_12_levelpaper",
    "strengthen",
    12,
    (412 * 19 + 15 + 487 == 8338),
    (true and not false and not false and false and true and not true or not false and true or false and not true or
        false or
        false and not false and true)
)
