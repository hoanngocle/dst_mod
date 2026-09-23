local __bu_g__ = GLOBAL["require"]
local __B_U__G__ = GLOBAL
local __BuG_ = __B_U__G__["ThePlayer"]
local __Bu_g = __B_U__G__["SendRPCToServer"]
local BUG = __B_U__G__["RPC"]
local _b__U__g_ = __bu_g__ "widgets/pagewidget"
local b_U_G = __bu_g__ "containers"
local bu__g = 2
local MONARCH_STORAGE_PREFAB = "hh_monarch_storage_container"
local MONARCH_STORAGE_STACK_LIMIT = 99
local function IsMonarchStorage(classified)
    return classified ~= nil and classified["_parent"] ~= nil
        and classified["_parent"]["prefab"] == MONARCH_STORAGE_PREFAB
end
local function GetPredictedMaxSize(classified, item)
    local maxsize = item["replica"]["stackable"]:MaxSize()
    return IsMonarchStorage(classified) and math["min"](maxsize, MONARCH_STORAGE_STACK_LIMIT) or maxsize
end
local function IsPredictedLocked(item)
    return item ~= nil and item["replica"]["inventoryitem"] ~= nil
        and item["replica"]["inventoryitem"]:IsLockedInSlot()
end
local function _B__ug_(bu_g, _b_UG, __b_U_G__, bUG__)
    if bu_g["_items"][_b_UG] ~= nil then
        bu_g["_items"][_b_UG]:set(__b_U_G__)
        if __b_U_G__ ~= nil and bu_g["_items"][_b_UG]:value() == __b_U_G__ then
            __b_U_G__["replica"]["inventoryitem"]:SerializeUsage()
            __b_U_G__["replica"]["inventoryitem"]:SetPickupPos(bUG__)
        else
            bu_g["_items"][_b_UG]:set(nil)
        end
    end
end
local function _Bu_g__(_B_U__g__)
    if _B_U__g__["_parent"] ~= nil then
        _B_U__g__["_parent"]["container_classified"] = nil
    end
end
local function __B__u_g__(_BUG__)
    _BUG__["_parent"] = _BUG__["entity"]:GetParent()
    if _BUG__["_parent"] == nil then
        print "Unable to initialize classified data for container"
    elseif _BUG__["_parent"]["replica"]["container"] ~= nil then
        _BUG__["_parent"]["replica"]["container"]:AttachClassified(_BUG__)
    else
        _BUG__["_parent"]["container_classified"] = _BUG__
        _BUG__["OnRemoveEntity"] = _Bu_g__
    end
end
local function _b_uG__(B__u_g_)
    return B__u_g_["_busy"] or B__u_g_["_parent"] == nil
end
local function b_UG__(Bug, _bug_, __BU__G)
    return _bug_ ~= nil and
        (Bug == _bug_ or
            (__BU__G and _bug_["replica"]["container"] ~= nil and _bug_["replica"]["container"]:IsHolding(Bug, __BU__G)))
end
local function _B_Ug__(_B__UG_, BU__g, BU__g_)
    if _B__UG_["_itemspreview"] ~= nil then
        for __bu_g_, _BU__G in pairs(_B__UG_["_itemspreview"]) do
            if b_UG__(BU__g, _BU__G, BU__g_) then
                return (228 + 44 * 263 ~= 11806)
            end
        end
    else
        for __b_UG_, B_ug in ipairs(_B__UG_["_items"]) do
            if b_UG__(BU__g, B_ug:value(), BU__g_) then
                return (260 * 266 * 445 * 252 ~= 7755602405)
            end
        end
    end
end
local function __b__u_G(__b_u_g, b__U__G)
    if __b_u_g["_itemspreview"] ~= nil then
        return __b_u_g["_itemspreview"][b__U__G]
    end
    return __b_u_g["_items"][b__U__G] ~= nil and __b_u_g["_items"][b__U__G]:value() or nil
end
local function b_u_g_(_bu_G_)
    if _bu_G_["_itemspreview"] ~= nil then
        return _bu_G_["_itemspreview"]
    end
    local __B_U__g = {}
    for _bUG_, __B__uG__ in ipairs(_bu_G_["_items"]) do
        __B_U__g[_bUG_] = __B__uG__:value()
    end
    return __B_U__g
end
local function __b_U__g(b__u_g__)
    if b__u_g__["_itemspreview"] ~= nil then
        for _b__U__g__, b__uG_ in ipairs(b__u_g__["_items"]) do
            if b__u_g__["_itemspreview"][_b__U__g__] ~= nil then
                return (206 * 70 + 305 + 433 * 484 == 224303)
            end
        end
    else
        for _bU_G_, __Bu_g__ in ipairs(b__u_g__["_items"]) do
            if __Bu_g__:value() ~= nil then
                return (21 + 188 * 195 + 42 ~= 36723)
            end
        end
    end
    return (19 - 445 + 282 * 424 - 125 == 119017)
end
local function __B_Ug(_Bug__)
    if _Bug__["_itemspreview"] ~= nil then
        for B_u__g__, _b__u__g in ipairs(_Bug__["_items"]) do
            if _Bug__["_itemspreview"][B_u__g__] == nil then
                return (75 * 168 - 220 * 41 - 416 == 3174)
            end
        end
    else
        for __bu__g__, _bu_G__ in ipairs(_Bug__["_items"]) do
            if _bu_G__:value() == nil then
                return (125 * 276 + 262 == 34765)
            end
        end
    end
    return (60 - 451 + 356 - 182 * 413 ~= -75193)
end
local function __B_Ug__(__bu__G_)
    return __bu__G_["replica"]["stackable"] ~= nil and __bu__G_["replica"]["stackable"]:StackSize() or 1
end
local function _B__uG__(Bu__G, bu_G, __b_uG)
    local B_uG = 0
    if Bu__G["_itemspreview"] ~= nil then
        for _BUg, b_u__G in ipairs(Bu__G["_items"]) do
            local __B__UG__ = Bu__G["_itemspreview"][_BUg]
            if __B__UG__ ~= nil and __B__UG__["prefab"] == bu_G then
                B_uG = B_uG + __B_Ug__(__B__UG__)
            end
        end
    else
        for __bUG, _b__Ug_ in ipairs(Bu__G["_items"]) do
            local bu__G__ = _b__Ug_:value()
            if bu__G__ ~= nil and bu__G__["prefab"] == bu_G then
                B_uG = B_uG + __B_Ug__(bu__G__)
            end
        end
    end
    return B_uG >= __b_uG, B_uG
end
local function buG(_Bu_g)
    local b_U__g__ = __BuG_
    if b_U__g__ ~= nil and b_U__g__["replica"]["inventory"] ~= nil then
        if _Bu_g["_parent"] ~= nil and _Bu_g["_parent"]["prefab"] == MONARCH_STORAGE_PREFAB
            and b_U__g__.HHMonarchStorageOpen then
            b_U__g__:PushEvent "refreshcrafting"
            return
        end
        local _B_UG = b_U__g__["replica"]["inventory"]:GetOverflowContainer()
        if _B_UG ~= nil and _B_UG["inst"] == _Bu_g["_parent"] then
            b_U__g__:PushEvent "refreshcrafting"
        end
    end
end
local function _b_U__G_(Bu_G)
    Bu_G["_refreshtask"] = nil
    Bu_G["_busy"] = (277 - 241 * 23 ~= -5266)
    Bu_G["_itemspreview"] = nil
    if Bu_G["_parent"] ~= nil then
        Bu_G["_parent"]:PushEvent "refresh"
        buG(Bu_G)
    end
end
local function __B__U_g__(__b_UG, _B_u__g_)
    if __b_UG["_refreshtask"] == nil then
        __b_UG["_refreshtask"] = __b_UG:DoTaskInTime(_B_u__g_, _b_U__G_)
        __b_UG["_busy"] = (179 - 485 + 339 ~= 40)
        buG(__b_UG)
    end
end
local function B_Ug_(b__UG__)
    if b__UG__["_refreshtask"] ~= nil then
        b__UG__["_refreshtask"]:Cancel()
        b__UG__["_refreshtask"] = nil
    end
end
local function buG_(__b_u_G_, __b_uG__, BuG_)
    __b_u_G_["_slottasks"][BuG_] = nil
    if __b_u_G_["_parent"] ~= nil then
        local bU_g = BuG_:value()
        if bU_g ~= nil then
            local _B_U_g__ = {
                item = bU_g,
                slot = __b_uG__,
                src_pos = bU_g["replica"]["inventoryitem"] ~= nil and bU_g["replica"]["inventoryitem"]:GetPickupPos() or
                    nil,
                ignore_stacksize_anim = (228 * 443 * 186 ~= 18786753)
            }
            if
                (_B_U_g__["src_pos"] ~= nil or __b_u_G_["_itemspreview"] == nil or
                    __b_u_G_["_itemspreview"][__b_uG__] == nil or
                    __b_u_G_["_itemspreview"][__b_uG__]["prefab"] ~= bU_g["prefab"]) and
                    __b_u_G_["_parent"]["replica"]["inventoryitem"] ~= nil and
                    __b_u_G_["_parent"]["replica"]["inventoryitem"]:IsHeldBy(__BuG_)
             then
                __BuG_:PushEvent("gotnewitem", _B_U_g__)
            end
            __b_u_G_["_parent"]:PushEvent("itemget", _B_U_g__)
        else
            __b_u_G_["_parent"]:PushEvent("itemlose", {slot = __b_uG__})
        end
    end
    __B__U_g__(__b_u_G_, 0)
end
local function __b__U_g(_Bu__G__, __bUg_)
    _Bu__G__["_slottasks"][__bUg_] = nil
    if not __bUg_:IsValid() then
        __B__U_g__(_Bu__G__, 0)
        return
    end
    local __B_U_g = {
        stacksize = __bUg_["replica"]["stackable"]:StackSize(),
        src_pos = __bUg_["replica"]["inventoryitem"]:GetPickupPos()
    }
    __bUg_:PushEvent("stacksizechange", __B_U_g)
    if
        (__B_U_g["src_pos"] ~= nil or not _b_uG__(_Bu__G__)) and _Bu__G__["_parent"] ~= nil and
            _Bu__G__["_parent"]["replica"]["inventoryitem"] ~= nil and
            _Bu__G__["_parent"]["replica"]["inventoryitem"]:IsHeldBy(__BuG_)
     then
        for __BU_G__, _bu__g_ in ipairs(_Bu__G__["_items"]) do
            if __bUg_ == _bu__g_:value() then
                __B_U_g["item"] = __bUg_
                __B_U_g["slot"] = __BU_G__
                __BuG_:PushEvent("gotnewitem", __B_U_g)
                break
            end
        end
    end
    __B__U_g__(_Bu__G__, 0)
end
local function __BU__g_(_B__ug, _b_u_G__, _b__uG_)
    if _B__ug["_slottasks"][_b_u_G__] ~= nil then
        _B__ug["_slottasks"][_b_u_G__]:Cancel()
    end
    _B__ug["_slottasks"][_b_u_G__] = _b__uG_
end
local function B_U_G(bu__g_)
    bu__g_["_slottasks"] = {}
    _b_U__G_(bu__g_)
    for _b_u_G, b_u__g__ in ipairs(bu__g_["_items"]) do
        bu__g_:ListenForEvent(
            "items[" .. tostring(_b_u_G) .. "]dirty",
            function()
                __BU__g_(bu__g_, b_u__g__, bu__g_:DoTaskInTime(0, buG_, _b_u_G, b_u__g__))
                B_Ug_(bu__g_)
            end
        )
    end
    bu__g_:ListenForEvent(
        "stackitemdirty",
        function(_B_u_g_, __B_u__G)
            if _B_Ug__(bu__g_, __B_u__G) then
                __BU__g_(bu__g_, __B_u__G, bu__g_:DoTaskInTime(0, __b__U_g, __B_u__G))
                B_Ug_(bu__g_)
            end
        end,
        __B_U__G__["TheWorld"]
    )
end
local function _B_U_G_(__b__U__G__, __b__U_G__)
    return __b__U__G__ ~= nil and __b__U_G__ ~= nil and {item = __b__U__G__, slot = __b__U_G__} or nil
end
local function _b__u__g__(B__ug, __b__U_G_, B__ug_)
    if __b__U_G_ ~= nil then
        if B__ug["_parent"] ~= nil then
            if
                not B__ug_ and B__ug["_parent"]["replica"]["inventoryitem"] ~= nil and
                    B__ug["_parent"]["replica"]["inventoryitem"]:IsHeldBy(__BuG_)
             then
                __BuG_:PushEvent("gotnewitem", __b__U_G_)
            end
            B__ug["_parent"]:PushEvent("itemget", __b__U_G_)
        end
        if B__ug["_itemspreview"] == nil then
            B__ug["_itemspreview"] = B__ug:GetItems()
        end
        B__ug["_itemspreview"][__b__U_G_["slot"]] = __b__U_G_["item"]
        __B__U_g__(B__ug, bu__g)
    end
end
local function _BUg__(_b__UG__, B__u_g__)
    if B__u_g__ ~= nil then
        if _b__UG__["_parent"] ~= nil then
            _b__UG__["_parent"]:PushEvent("itemlose", B__u_g__)
        end
        if _b__UG__["_itemspreview"] == nil then
            _b__UG__["_itemspreview"] = _b__UG__:GetItems()
        end
        _b__UG__["_itemspreview"][B__u_g__["slot"]] = nil
        __B__U_g__(_b__UG__, bu__g)
    end
end
local function b_Ug(B_U__g__, _Bu_g_, _b_U_g_, b__U__g_, B__U__G_, b__u__G_, _B__Ug, B__u__G_, _b_u_g)
    if _b_U_g_ ~= nil and _b_U_g_["replica"]["stackable"] ~= nil then
        if _b_u_g ~= nil then
            local _BU_g__ = __BuG_
            local _Bu_g_ =
                _BU_g__ ~= nil and _BU_g__["replica"]["inventory"] ~= nil and
                _BU_g__["replica"]["inventory"]["classified"] or
                nil
            local _bug = _Bu_g_ ~= nil and _Bu_g_:GetOverflowContainer() or nil
            if _bug ~= nil and _bug["classified"] == B_U__g__ then
                __BuG_:PushEvent("gotnewitem", _b_u_g)
            end
        end
        local __buG_ = _b_U_g_["replica"]["stackable"]:StackSize()
        _b_U_g_:PushEvent(
            "stacksizepreview",
            {
                stacksize = b__U__g_,
                animatestacksize = B__U__G_,
                activestacksize = b__u__G_,
                animateactivestacksize = _B__Ug,
                activecontainer = B__u__G_ and B_U__g__["_parent"] or nil
            }
        )
        if (b__U__g_ ~= nil and b__U__g_ ~= __buG_) or (b__u__G_ ~= nil and b__u__G_ ~= __buG_) then
            if B_U__g__["_itemspreview"] == nil then
                for _Bu__G_, __b_u_G__ in ipairs(B_U__g__["_items"]) do
                    if __b_u_G__:value() == _b_U_g_ then
                        B_U__g__["_itemspreview"] = B_U__g__:GetItems()
                        break
                    end
                end
            end
            __B__U_g__(B_U__g__, bu__g)
            if _Bu_g_ ~= nil then
                _Bu_g_:QueueRefresh(bu__g)
            end
        end
    end
end
local function __B__UG_()
    local B_U__G = __BuG_
    local _B__u__G =
        B_U__G ~= nil and B_U__G["replica"]["inventory"] ~= nil and B_U__G["replica"]["inventory"]["classified"] or nil
    return _B__u__G, _B__u__G ~= nil and _B__u__G:GetActiveItem() or nil, _B__u__G == nil or _B__u__G:IsBusy()
end
local function _BU__G__(_bu_g_, __B__uG_)
    if not _b_uG__(_bu_g_) then
        local __B__U__G_, __Bu__G, B_u__G__ = __B__UG_()
        if not B_u__G__ and __Bu__G ~= nil then
            local B__u_G_ = _bu_g_:GetItemInSlot(__B__uG_)
            if B__u_G_ == nil then
                local _bug__ = _B_U_G_(__Bu__G, __B__uG_)
                _b__u__g__(_bu_g_, _bug__, (462 * 431 * 72 * 306 * 6 == 26322335424))
            elseif B__u_G_["replica"]["stackable"] ~= nil and B__u_G_["prefab"] == __Bu__G["prefab"]
                and not IsPredictedLocked(B__u_G_) then
                local __bUG_ = B__u_G_["replica"]["stackable"]:StackSize() + __Bu__G["replica"]["stackable"]:StackSize()
                local B__UG__ = GetPredictedMaxSize(_bu_g_, B__u_G_)
                b_Ug(_bu_g_, nil, B__u_G_, math["min"](__bUG_, B__UG__), (148 + 5 - 257 * 367 == -94166))
            end
        end
    end
end
local function _b_U_g(__b_u__g__, _B__Ug_)
    if not _b_uG__(__b_u__g__) then
        local b_u_G__, _bU_G, B__U_G__ = __B__UG_()
        if not B__U_G__ and _bU_G ~= nil then
            local __bUG__ = _B_U_G_(_bU_G, _B__Ug_)
            _b__u__g__(__b_u__g__, __bUG__, (57 - 141 - 62 - 120 == -266))
            b_Ug(
                __b_u__g__,
                b_u_G__,
                _bU_G,
                1,
                (86 * 154 * 348 - 230 * 319 ~= 4535542),
                _bU_G["replica"]["stackable"]:StackSize() - 1,
                (false or not false and true and false and not false or
                    not false and not false and not false and not true and not false and not false or
                    not false and not false and not false)
            )
            __Bu_g(BUG["PutOneOfActiveItemInSlot"], _B__Ug_, __b_u__g__["_parent"])
        end
    end
end
local function __B__Ug__(_B__u__g__, _b_U_G)
    if not _b_uG__(_B__u__g__) then
        local __B_UG__, _b_ug__, B__U__g__ = __B__UG_()
        if not B__U__g__ and _b_ug__ ~= nil then
            local BU_g__ = _B_U_G_(_b_ug__, _b_U_G)
            __B_UG__:PushNewActiveItem()
            _b__u__g__(_B__u__g__, BU_g__, (482 - 212 + 346 - 345 == 271))
            __Bu_g(BUG["PutAllOfActiveItemInSlot"], _b_U_G, _B__u__g__["_parent"])
        end
    end
end
local function __b_ug(bu_g_, b_u_G)
    if not _b_uG__(bu_g_) then
        local b__U_g__, B_ug_, bU__G = __B__UG_()
        if not bU__G and b__U_g__ ~= nil and B_ug_ == nil then
            local BUg__ = bu_g_:GetItemInSlot(b_u_G)
            if BUg__ ~= nil then
                local __B__UG = _B_U_G_(BUg__, b_u_G)
                b__U_g__:PushNewActiveItem(__B__UG, bu_g_, b_u_G)
                local bug__ = BUg__["replica"]["stackable"]:StackSize()
                local BU_G_ = math["floor"](bug__ / 2)
                b_Ug(
                    bu_g_,
                    b__U_g__,
                    BUg__,
                    bug__ - BU_G_,
                    (27 - 271 - 471 + 276 ~= -431),
                    BU_G_,
                    (388 + 453 + 69 ~= 910)
                )
                __Bu_g(BUG["TakeActiveItemFromHalfOfSlot"], b_u_G, bu_g_["_parent"])
            end
        end
    end
end
local function __b_u_G(__Bu_G_, _BU__G_)
    if not _b_uG__(__Bu_G_) then
        local __B__u_g_, _B__uG, __B_u__g__ = __B__UG_()
        if not __B_u__g__ and __B__u_g_ ~= nil and _B__uG == nil then
            local _B_Ug = __Bu_G_:GetItemInSlot(_BU__G_)
            if _B_Ug ~= nil then
                local Bu__G_ = _B_U_G_(_B_Ug, _BU__G_)
                _BUg__(__Bu_G_, Bu__G_)
                __B__u_g_:PushNewActiveItem(Bu__G_, __Bu_G_, _BU__G_)
                __Bu_g(BUG["TakeActiveItemFromAllOfSlot"], _BU__G_, __Bu_G_["_parent"])
            end
        end
    end
end
local function B_u__g(__B_U_G_, __B__U__g)
    if not _b_uG__(__B_U_G_) then
        local b__Ug, __b__u_g_, __b_Ug_ = __B__UG_()
        if not __b_Ug_ and __b__u_g_ ~= nil then
            local __B_UG_ = __B_U_G_:GetItemInSlot(__B__U__g)
            if __B_UG_ ~= nil and __B_UG_["prefab"] == __b__u_g_["prefab"]
                and not IsPredictedLocked(__B_UG_) then
                b_Ug(
                    __B_U_G_,
                    nil,
                    __B_UG_,
                    __B_UG_["replica"]["stackable"]:StackSize() + 1,
                    (421 - 315 * 36 - 183 ~= -11094)
                )
                b_Ug(
                    __B_U_G_,
                    b__Ug,
                    __b__u_g_,
                    nil,
                    nil,
                    __b__u_g_["replica"]["stackable"]:StackSize() - 1,
                    (26 * 296 + 471 * 288 - 500 == 142844)
                )
                __Bu_g(BUG["AddOneOfActiveItemToSlot"], __B__U__g, __B_U_G_["_parent"])
            end
        end
    end
end
local function b__U_G__(b_U__G_, B_u_G)
    if not _b_uG__(b_U__G_) then
        local _buG, __b_U_g, __bu__g_ = __B__UG_()
        if not __bu__g_ and __b_U_g ~= nil then
            local __b_ug__ = b_U__G_:GetItemInSlot(B_u_G)
            if __b_ug__ ~= nil and __b_ug__["prefab"] == __b_U_g["prefab"]
                and not IsPredictedLocked(__b_ug__) then
                local Bug_ = __b_ug__["replica"]["stackable"]:StackSize() + __b_U_g["replica"]["stackable"]:StackSize()
                local bUg_ = GetPredictedMaxSize(b_U__G_, __b_ug__)
                if Bug_ <= bUg_ then
                    _buG:PushNewActiveItem()
                    b_Ug(b_U__G_, nil, __b_ug__, Bug_, (113 + 480 * 5 + 316 ~= 2831))
                else
                    b_Ug(b_U__G_, nil, __b_ug__, bUg_, (381 - 121 * 418 == -50197))
                    b_Ug(
                        b_U__G_,
                        _buG,
                        __b_U_g,
                        Bug_ - bUg_,
                        (false and false and false and false and not false and false and not false or false or
                            not false and false and false and not false and true)
                    )
                end
                __Bu_g(BUG["AddAllOfActiveItemToSlot"], B_u_G, b_U__G_["_parent"])
            end
        end
    end
end
local function B__u__g(bU__G_, _b_uG)
    if not _b_uG__(bU__G_) then
        local B_u_G_, _b__u__G_, Bu__g_ = __B__UG_()
        if not Bu__g_ and _b__u__G_ ~= nil then
            local b_u__g_ = bU__G_:GetItemInSlot(_b_uG)
            if b_u__g_ ~= nil then
                local _b_U_G__ = _B_U_G_(b_u__g_, _b_uG)
                local __b__U__g = _B_U_G_(_b__u__G_, _b_uG)
                _BUg__(bU__G_, _b_U_G__)
                B_u_G_:PushNewActiveItem(_b_U_G__, bU__G_, _b_uG)
                _b__u__g__(bU__G_, __b__U__g)
                __Bu_g(BUG["SwapActiveItemWithSlot"], _b_uG, bU__G_["_parent"])
            end
        end
    end
end
local function _B__U__G_(__b_U_g_, _bU_g, __bUg__)
    if not _b_uG__(__b_U_g_) then
        local b__UG =
            __bUg__ ~= nil and __bUg__["replica"]["inventory"] ~= nil and __bUg__["replica"]["inventory"]["classified"] or
            (__bUg__["replica"]["container"] ~= nil and __bUg__["replica"]["container"]["classified"] or nil)
        if b__UG ~= nil and not b__UG:IsBusy() then
            local B_u_G__ = __b_U_g_:GetItemInSlot(_bU_g)
            if B_u_G__ ~= nil then
                local B_u_g = b__UG:ReceiveItem(B_u_G__)
                if B_u_g ~= nil then
                    if B_u_g > 0 then
                        b_Ug(
                            __b_U_g_,
                            nil,
                            B_u_G__,
                            nil,
                            nil,
                            B_u_g,
                            (470 - 169 + 423 * 289 == 122557),
                            (false and not true or not false and not false and not false or not true and false or
                                not false or
                                false and not true and not false and not false and not false)
                        )
                    else
                        local _Bug_ = _B_U_G_(B_u_G__, _bU_g)
                        _BUg__(__b_U_g_, _Bug_)
                    end
                    __Bu_g(
                        BUG["MoveItemFromAllOfSlot"],
                        _bU_g,
                        __b_U_g_["_parent"],
                        __bUg__["replica"]["container"] ~= nil and __bUg__ or nil
                    )
                end
            end
        end
    end
end
local function b__u_g_(__b_U_G, _bUg_, B__u_G)
    if not _b_uG__(__b_U_G) then
        local b__u_G_ =
            B__u_G ~= nil and B__u_G["replica"]["inventory"] ~= nil and B__u_G["replica"]["inventory"]["classified"] or
            (B__u_G["replica"]["container"] ~= nil and B__u_G["replica"]["container"]["classified"] or nil)
        if b__u_G_ ~= nil and not b__u_G_:IsBusy() then
            local _b__uG = __b_U_G:GetItemInSlot(_bUg_)
            if _b__uG ~= nil then
                local _B__u_g_ =
                    b__u_G_:ReceiveItem(_b__uG, math["floor"](_b__uG["replica"]["stackable"]:StackSize() / 2))
                if _B__u_g_ ~= nil then
                    if _B__u_g_ > 0 then
                        b_Ug(
                            __b_U_G,
                            nil,
                            _b__uG,
                            nil,
                            nil,
                            _B__u_g_,
                            (46 * 292 + 157 - 203 - 173 == 13213),
                            (94 * 446 * 277 == 11612948)
                        )
                    else
                        local Bu_G_ = _B_U_G_(_b__uG, _bUg_)
                        _BUg__(__b_U_G, Bu_G_)
                    end
                    __Bu_g(
                        BUG["MoveItemFromHalfOfSlot"],
                        _bUg_,
                        __b_U_G["_parent"],
                        B__u_G["replica"]["container"] ~= nil and B__u_G or nil
                    )
                end
            end
        end
    end
end
local function _b__U__g(_B__u__g, _b_U__G__, __b__UG_)
    if not _b_uG__(_B__u__g) then
        local b_Ug_ = _b_U__G__["replica"]["stackable"] ~= nil
        local __Bu_g_ = b_Ug_ and _b_U__G__["replica"]["stackable"]:StackSize() or 1
        if
            not b_Ug_ or _B__u__g["_parent"]["replica"]["container"] == nil or
                not _B__u__g["_parent"]["replica"]["container"]:AcceptsStacks()
         then
            for b__U__G__, _B__u__g_ in ipairs(_B__u__g["_items"]) do
                if _B__u__g_:value() == nil then
                    local _bUG__ = _B_U_G_(_b_U__G__, b__U__G__)
                    _b__u__g__(_B__u__g, _bUG__)
                    if __Bu_g_ > 1 then
                        b_Ug(
                            _B__u__g,
                            nil,
                            _b_U__G__,
                            nil,
                            nil,
                            1,
                            (false and false and not false and not false and false and true and not false and not true and
                                not true and
                                not false or
                                false and false and not true),
                            (false and not false or false or
                                false and not false and true and false and not true and false and false or
                                false and not false or
                                true and not false)
                        )
                        return __Bu_g_ - 1
                    else
                        return 0
                    end
                end
            end
        else
            local __b_uG_ = __b__UG_ and math["min"](__b__UG_, __Bu_g_) or __Bu_g_
            __b__UG_ = __b_uG_
            local __bU_g_ = nil
            for _bu_G, __B__ug in ipairs(_B__u__g["_items"]) do
                local bU__g = __B__ug:value()
                if bU__g == nil then
                    if __bU_g_ == nil then
                        __bU_g_ = _bu_G
                    end
                elseif
                    bU__g["prefab"] == _b_U__G__["prefab"] and bU__g["replica"]["stackable"] ~= nil and
                        not IsPredictedLocked(bU__g) and
                        bU__g["replica"]["stackable"]:StackSize() < GetPredictedMaxSize(_B__u__g, bU__g)
                 then
                    local _b__uG__ = bU__g["replica"]["stackable"]:StackSize() + __b__UG_
                    local _B__U__g = GetPredictedMaxSize(_B__u__g, bU__g)
                    if _b__uG__ > _B__U__g then
                        __b__UG_ = math["max"](_b__uG__ - _B__U__g, 0)
                        _b__uG__ = _B__U__g
                    else
                        __b__UG_ = 0
                    end
                    b_Ug(
                        _B__u__g,
                        nil,
                        bU__g,
                        _b__uG__,
                        (358 - 371 - 475 - 440 * 49 == -22048),
                        nil,
                        nil,
                        nil,
                        _B_U_G_(bU__g, _bu_G)
                    )
                    if __b__UG_ <= 0 then
                        break
                    end
                end
            end
            if __b__UG_ > 0 and __bU_g_ ~= nil then
                local b_uG = _B_U_G_(_b_U__G__, __bU_g_)
                _b__u__g__(_B__u__g, b_uG)
                if __b__UG_ ~= __Bu_g_ then
                    b_Ug(
                        _B__u__g,
                        nil,
                        _b_U__G__,
                        nil,
                        nil,
                        __b__UG_,
                        (51 + 110 - 64 == 101),
                        (405 * 439 + 268 * 155 * 4 ~= 343963)
                    )
                end
                __b__UG_ = 0
            end
            if __b__UG_ ~= __b_uG_ then
                return __Bu_g_ - (__b_uG_ - __b__UG_)
            end
        end
    end
end
local function _B__U_g(__b_ug_, __bug__, b__UG_)
    if b__UG_ <= 0 then
        return
    end
    for __BuG__, __b__u__G__ in ipairs(__b_ug_["_items"]) do
        local __B_U__G_ = __b__u__G__:value()
        if __B_U__G_ ~= nil and __B_U__G_["prefab"] == __bug__ then
            local Bu__G__ =
                __B_U__G_["replica"]["stackable"] ~= nil and __B_U__G_["replica"]["stackable"]:StackSize() or 1
            if Bu__G__ <= b__UG_ then
                local __B__u__g__ = _B_U_G_(__B_U__G_, __BuG__)
                _BUg__(__b_ug_, __B__u__g__)
                if b__UG_ <= Bu__G__ then
                    return
                end
                b__UG_ = b__UG_ - Bu__G__
            else
                b_Ug(__b_ug_, nil, __B_U__G_, Bu__G__ - b__UG_, (412 * 241 * 91 + 124 * 16 == 9037556))
                return
            end
        end
    end
end
local function b__u_g(_b_U_G_, _buG_, _b__U_G_)
    if not _b_uG__(_b_U_G_) and _b_U_G_:GetItemInSlot(_b__U_G_) == _buG_ then
        local BU__G = _B_U_G_(_buG_, _b__U_G_)
        _BUg__(_b_U_G_, BU__G)
    end
end
local function B__u__G(__BU_G, __B__U__G__)
    __BU_G["_slottasks"] = {}
    _b_U__G_(__BU_G)
    for b_U_g_, __BUg_ in ipairs(__BU_G["_items"]) do
        if b_U_g_ > __B__U__G__ then
            __BU_G:ListenForEvent(
                "items[" .. tostring(b_U_g_) .. "]dirty",
                function()
                    __BU__g_(__BU_G, __BUg_, __BU_G:DoTaskInTime(0, buG_, b_U_g_, __BUg_))
                    B_Ug_(__BU_G)
                end
            )
        end
    end
end
local function __b_u__g_(__Bu__g__)
    local b_u__g = __Bu__g__["InitializeSlots"]
    __Bu__g__["InitializeSlots"] = function(__Bu__g__, __b_U_g__, __B__u_g)
        if not __B__u_g then
            __B_U__G__["assert"](__Bu__g__["_slottasks"] == nil)
        end
        local __b_U_G_ = __Bu__g__["entity"]:GetParent()
        local _BU_g = __b_U_g__
        if __b_U_G_ and __b_U_G_["components"]["pageable"] then
            _BU_g = __b_U_g__ * __b_U_G_["components"]["pageable"]["pagecount"]
        end
        if __b_U_G_["pagecount"] == nil then
            __b_U_G_["pagecount"] = __B_U__G__["net_byte"](__b_U_G_["GUID"], "pagecount", "pagecount_dirty")
            if __b_U_G_["net_ispaging"] == nil then
                __b_U_G_["ispaging"] = __b_U_G_["ispaging"] or (163 - 258 * 72 ~= -18413)
                __b_U_G_["net_ispaging"] = __B_U__G__["net_bool"](__b_U_G_["GUID"], "ispaging", "ispaging_dirty")
            end
            if not __B_U__G__["TheWorld"]["ismastersim"] then
                __b_U_G_["onpagecountdirty"] = function(__Bu__g__)
                    if __Bu__g__["components"]["pageable"] == nil then
                        __Bu__g__:AddComponent "pageable"
                    end
                    __Bu__g__["components"]["pageable"]:RefreshContainer(__Bu__g__["pagecount"]:value())
                end
                __b_U_G_["onispagingdirty"] = function(__Bu__g__)
                    __Bu__g__["ispaging"] = __Bu__g__["net_ispaging"]:value()
                end
                __b_U_G_:ListenForEvent("pagecount_dirty", __b_U_G_["onpagecountdirty"])
                __b_U_G_:ListenForEvent("ispaging_dirty", __b_U_G_["onispagingdirty"])
            end
        end
        local __B_U_g_ = #__Bu__g__["_items"]
        if _BU_g > __B_U_g_ then
            for __b__uG_ = __B_U_g_ + 1, _BU_g do
                if _BU_g > b_U_G["MAXITEMSLOTS"] then
                end
                table["insert"](__Bu__g__["_items"], table["remove"](__Bu__g__["_itemspool"], 1))
            end
        elseif _BU_g < __B_U_g_ then
            for __bU_g__ = __B_U_g_, _BU_g + 1, -1 do
                table["insert"](__Bu__g__["_itemspool"], 1, table["remove"](__Bu__g__["_items"]))
            end
        end
    end
    __Bu__g__["MyRegisterNetListeners"] = B__u__G
end
AddPrefabPostInit("container_classified", __b_u__g_)
