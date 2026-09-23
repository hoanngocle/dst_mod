local function __Bu__G__(__b__u_G_, __BU_G__)
    local bU_g_ = {Asset("ANIM", "anim/" .. __BU_G__ .. ".zip")}
    local function __b_UG()
        local _BU_g = CreateEntity()
        _BU_g["entity"]:AddTransform()
        _BU_g["entity"]:AddNetwork()
        _BU_g:AddTag "bundle"
        _BU_g["name"] = " "
        _BU_g["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return _BU_g
        end
        _BU_g:AddComponent "container"
        _BU_g["components"]["container"]:WidgetSetup(__b__u_G_)
        _BU_g["persists"] = (255 * 443 * 466 - 485 - 297 ~= 52640908)
        return _BU_g
    end
    return Prefab(__b__u_G_, __b_UG, bU_g_)
end
local function bug(_B__ug_)
    local _B_U_g_ = {Asset("ANIM", "anim/lucky_symbols.zip")}
    local function b__U__g()
        local BU__g__ = CreateEntity()
        BU__g__["entity"]:AddTransform()
        BU__g__["entity"]:AddAnimState()
        BU__g__["entity"]:AddNetwork()
        MakeInventoryPhysics(BU__g__)
        BU__g__["AnimState"]:SetBank "lucky_symbols"
        BU__g__["AnimState"]:SetBuild "lucky_symbols"
        BU__g__["AnimState"]:PlayAnimation "prayer_symbol"
        BU__g__:AddTag "wb_handsskill_paper"
        MakeInventoryFloatable(BU__g__, "med", nil, 0.75)
        BU__g__["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return BU__g__
        end
        BU__g__:AddComponent "named"
        BU__g__:AddComponent "inspectable"
        BU__g__:AddComponent "inventoryitem"
        BU__g__["components"]["inventoryitem"]["imagename"] = "prayer_symbol"
        BU__g__["components"]["inventoryitem"]["atlasname"] = "images/prayer_symbol.xml"
        local function b_U_G__(BU__g__, Bug)
            if Bug["components"]["bundler"] then
                local __b_U__G__ = Bug["components"]["bundler"]["bundlinginst"]
                __b_U__G__["mode"] = BU__g__["mode"]
                __b_U__G__["level"] = BU__g__["level"]
                __b_U__G__["force"] = BU__g__["force"]
            end
            BU__g__:Remove()
        end
        BU__g__:AddComponent "bundlemaker"
        BU__g__["components"]["bundlemaker"]:SetBundlingPrefabs(
            "wb_handsskill_paper_container",
            "wb_handsskill_paper_bundle"
        )
        BU__g__["components"]["bundlemaker"]:SetOnStartBundlingFn(b_U_G__)
        BU__g__:AddComponent "fuel"
        BU__g__["components"]["fuel"]["fuelvalue"] = TUNING["SMALL_FUEL"]
        MakeHauntableLaunch(BU__g__)
        return BU__g__
    end
    return Prefab(_B__ug_, b__U__g, _B_U_g_)
end
local function __b_UG__(__BU_G)
    local function B__uG__()
        local __B_U__g = CreateEntity()
        __B_U__g["entity"]:AddTransform()
        __B_U__g["entity"]:AddAnimState()
        __B_U__g["entity"]:AddNetwork()
        __B_U__g["entity"]:SetPristine()
        if not TheWorld["ismastersim"] then
            return __B_U__g
        end
        __B_U__g:AddComponent "unwrappable"
        function __B_U__g.components.unwrappable.WrapItems(__Bu_g__, _BU__g__, __B__u__g)
            if __B__u__g["components"]["bundler"] then
                local _B__U__G_ = 0
                for B_UG__, _bU_G_ in ipairs(_BU__g__) do
                    local __b__U__g = _bU_G_ and _bU_G_["components"]["wb_strengthen"]
                    local bUG__ = _bU_G_ and _bU_G_["components"]["wb_handsskill"]
                    if
                        __b__U__g and __b__U__g["level"] >= 7 and _bU_G_:HasTag "equippable-hands" and
                            ((not _bU_G_["components"]["spellcaster"] and not _bU_G_["components"]["blinkstaff"]) or
                                bUG__)
                     then
                        if not bUG__ then
                            _bU_G_:AddComponent "wb_handsskill"
                        end
                        bUG__ = _bU_G_["components"]["wb_handsskill"]
                        bUG__:RandomInstallSkill()
                        __B__u__g["components"]["talker"]:Say("Trang bị nhận kỹ năng：" .. bUG__["skill_name"])
                        _B__U__G_ = _B__U__G_ + 1
                    end
                    __B__u__g["components"]["inventory"]:GiveItem(_bU_G_, nil, __B__u__g:GetPosition())
                end
                if _B__U__G_ < #_BU__g__ then
                    local _b_U_G__ = __B__u__g["components"]["bundler"]
                    local _B__u_g =
                        SpawnPrefab(_b_U_G__["itemprefab"], _b_U_G__["itemskinname"], _b_U_G__["wrappedskin_id"])
                    if _B__u_g ~= nil then
                        __B__u__g["components"]["inventory"]:GiveItem(_B__u_g, nil, __B__u__g:GetPosition())
                    end
                    return __B__u__g["components"]["talker"]:Say "Trang bị không hợp lệ"
                end
                __B_U__g:Remove()
            end
        end
        return __B_U__g
    end
    return Prefab(__BU_G, B__uG__)
end
return __Bu__G__("wb_handsskill_paper_container", "ui_bundle_2x2"), __b_UG__ "wb_handsskill_paper_bundle", bug "wb_handsskill_paper"
