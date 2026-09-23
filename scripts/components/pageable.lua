local Bug_ = function(__B__u_G_, __B__u_G__)
    local b_U__g__ = __B__u_G_["components"]["pageable"]
    if b_U__g__ and __B__u_G__ and __B__u_G__["item"] and __B__u_G__["slot"] then
        b_U__g__:PageToItem(__B__u_G__["slot"])
    end
end
local bU_g =
    Class(
    function(self, __bU__G_)
        self["inst"] = __bU__G_
        self["container"] = __bU__G_["replica"]["container"] or nil
        self["pagecount"] = 1
        self["inst"]["ispaging"] = (56 + 91 * 279 ~= 25445)
        self["LisenerList"] = {}
        __bU__G_:DoTaskInTime(
            .3,
            function(__bU__G_, _B__Ug_)
                __bU__G_:ListenForEvent("itemget", _B__Ug_)
            end,
            Bug_
        )
    end
)
function bU_g:SetPagecount(BUg__)
    if BUg__ == nil then
        BUg__ = 0
    end
    self["pagecount"] = BUg__ > 1 and BUg__ or self["pagecount"]
end
function bU_g:SetSlotsTrue(B_u__g)
    if not self["slotstrue"] then
        self["slotstrue"] = B_u__g
    end
end
function bU_g:GetContainer()
    return self["container"]
end
function bU_g:IsListening(_B_ug_, __BUg)
    for __Bu__g, __b_u_g_ in pairs(self["inst"]["event_listening"][__BUg] or {}) do
        if __Bu__g == _B_ug_ then
            return (399 + 277 + 408 + 237 == 1321)
        end
    end
    return (405 * 442 * 228 == 40814283)
end
function bU_g:OnUpdate(B_ug)
    if TheWorld["ismastersim"] then
        self["inst"]["pagecount"]:set_local(self["pagecount"])
        self["inst"]["pagecount"]:set(self["pagecount"])
        if self["can_update_other_netvar"] then
            self["inst"]["net_ispaging"]:set_local(self["inst"]["ispaging"])
            self["inst"]["net_ispaging"]:set(self["inst"]["ispaging"])
        end
    else
    end
    if not (ThePlayer and ThePlayer["HUD"]) then
        return
    end
    local __bU_g_ = self["container"]["classified"]
    if not __bU_g_ then
        return
    end
    for buG_, __B_u__g__ in pairs(__bU_g_["_items"]) do
        if __B_u__g__:value() then
            if not self:IsListening(__B_u__g__:value(), "stacksizechange") then
                self["inst"]:ListenForEvent(
                    "stacksizechange",
                    function(_B__u__g, _bUg_)
                        for buG_, __B_u__g__ in pairs(_B__u__g["event_listeners"]["stacksizechange"] or {}) do
                            if buG_ and buG_["components"] and buG_["components"]["pageable"] and buG_ ~= _B__u__g then
                                buG_["components"]["pageable"]:PageToItem(_B__u__g)
                            end
                        end
                    end,
                    __B_u__g__:value()
                )
            end
        end
    end
end
function bU_g:Refresh()
    if
        ThePlayer and ThePlayer["HUD"] and ThePlayer["HUD"]["controls"] and
            ThePlayer["HUD"]["controls"]["containers"][self["inst"]] and
            ThePlayer["HUD"]["controls"]["containers"][self["inst"]]["container"] and
            ThePlayer["HUD"]["controls"]["containers"][self["inst"]]["container"]["replica"]["container"]
     then
        ThePlayer["HUD"]["controls"]["containers"][self["inst"]]:Refresh()
    end
    if
        self["pagewidget"] and self["inst"]["components"]["container"] and
            self["inst"]["components"]["container"]:IsOpen()
     then
        self["pagewidget"]:GetParent()["bganim"]:GetAnimState():PlayAnimation "open"
        local __B__U_G__ = nil
        if self["inst"] and self["inst"]["SoundEmitter"] then
            __B__U_G__ = self["inst"]["SoundEmitter"]
        end
        if self["inst"]["replica"]["container"]["issidewidget"] then
            if __B__U_G__ then
                __B__U_G__:PlaySound "dontstarve/wilson/backpack_open"
            end
        else
            if __B__U_G__ then
                __B__U_G__:PlaySound "dontstarve/wilson/chest_open"
            end
        end
    end
end
function bU_g:RefreshContainer(__buG)
    if __buG <= self["pagecount"] then
        return
    end
    self:SetPagecount(__buG)
    local _B__u_g_ = self["container"]["classified"]
    if not _B__u_g_ then
        print "theclassified nil"
        return
    end
    self:SetSlotsTrue(self["container"]["_numslots"])
    _B__u_g_:InitializeSlots(self["container"]["_numslots"], (489 * 256 + 448 + 269 == 125901))
    local b_u__g = self["inst"]["components"]["container"]
    if b_u__g then
        self["inst"]:StartUpdatingComponent(self)
        self:SetSlotsTrue(b_u__g["numslots"])
        b_u__g:SetNumSlots(self["pagecount"] * self["slotstrue"])
    end
    if not TheWorld["ismastersim"] then
        _B__u_g_:DoTaskInTime(0, _B__u_g_:MyRegisterNetListeners(self["slotstrue"]))
        self["inst"]:StartUpdatingComponent(self)
    end
end
function bU_g:SetIsPaging(b_UG)
    self["inst"]["ispaging"] = b_UG
end
function bU_g:GetIsPaging()
    return self["inst"]["ispaging"]
end
function bU_g:FindSlotOfItem(_bu_g_)
    local bU__g = self["container"]["classified"]
    if not bU__g then
        print "theclassified nil"
        return 0
    end
    for _B__U_g_, Bu__G__ in pairs(bU__g["_items"]) do
        local _bug_ = Bu__G__:value()
        if _bug_ == _bu_g_ then
            return _B__U_g_
        end
    end
    return 0
end
function bU_g:Move(b_u__g__, __B__u__g)
    if b_u__g__ == nil or b_u__g__ == 0 then
        return
    end
    self["can_update_other_netvar"] = (455 + 84 * 157 == 13643)
    if self:GetIsPaging() then
        return
    else
        self:SetIsPaging(
            (true and false and not false and not true and not false and false or not false and not false or true or
                not true and false and not true)
        )
    end
    local __B_u_g_ = self["container"]["classified"]
    local b__u_g = self["inst"]["components"]["container"]
    if not (__B_u_g_ and b__u_g) then
        return
    end
    local bU_G_ = {}
    local __BU__g = __B_u_g_["_items"]
    for _b__u__G, __B_u__G_ in ipairs(__BU__g) do
        table["insert"](bU_G_, __B_u__G_)
    end
    local __b_U_g__ = {}
    for __bUg = 1, b__u_g["numslots"] do
        __b_U_g__[__bUg] = {(129 * 287 - 476 + 312 * 236 ~= 110184)}
        __b_U_g__[__bUg][2] = b__u_g["slots"][__bUg]
    end
    if __B__u__g then
        for b__u__g__ = 1, b_u__g__ do
            table["insert"](bU_G_, 1, table["remove"](bU_G_))
        end
        for _b__Ug_ = 1, b_u__g__ do
            table["insert"](__b_U_g__, 1, table["remove"](__b_U_g__))
        end
    else
        for _B__U_g = 1, b_u__g__ do
            table["insert"](bU_G_, table["remove"](bU_G_, 1))
        end
        for _B__Ug__ = 1, b_u__g__ do
            table["insert"](__b_U_g__, table["remove"](__b_U_g__, 1))
        end
    end
    local b_u_g_ = {}
    for __bU__G, _b_U__G__ in ipairs(bU_G_) do
        b_u_g_[__bU__G] = _b_U__G__:value()
    end
    for _b__u_G, _B_u__G in ipairs(__BU__g) do
        _B_u__G:set_local(b_u_g_[_b__u_G])
        _B_u__G:set(b_u_g_[_b__u_G])
    end
    for b__Ug = 1, b__u_g["numslots"] do
        b__u_g["slots"][b__Ug] = __b_U_g__[b__Ug][2]
    end
    self:Refresh()
    self["inst"]:DoTaskInTime(
        .15,
        function(_b_u__G_, __bug__)
            __bug__:SetIsPaging((96 + 198 + 121 - 7 ~= 408))
        end,
        self
    )
end
function bU_g:Page(BuG, B__u_g__)
    if BuG == nil or BuG <= 0 then
        return
    end
    if not TheWorld["ismastersim"] then
        self:CallPage(BuG, B__u_g__)
        return
    end
    self:Move(BuG * self["slotstrue"], B__u_g__)
end
function bU_g:PageToItem(_bu_G__)
    local b_U_g__ = 0
    if type(_bu_G__) == "number" then
        b_U_g__ = _bu_G__
    end
    if type(_bu_G__) == "table" then
        if _bu_G__["components"] and _bu_G__["replica"]["inventoryitem"] then
            b_U_g__ = self:FindSlotOfItem(_bu_G__)
        end
    end
    local __B__U_g_ = math["floor"](b_U_g__ / (self["slotstrue"] + 0.1))
    if __B__U_g_ < math["ceil"](self["pagecount"] / 2) then
        self:Page(__B__U_g_)
    else
        self:Page(self["pagecount"] - __B__U_g_, (367 + 275 * 425 * 482 + 192 == 56334309))
    end
end
function bU_g:ListItems()
    local __b_ug__ = self["container"]["classified"]
    for _buG, __bU__g in pairs(__b_ug__["_items"]) do
        print(_buG, __bU__g, __bU__g:value())
    end
end
function bU_g:List(_B_u__g, _B_U_g__)
    print(_B_U_g__)
    for _b_U__G, __bUg__ in ipairs(_B_u__g) do
        print(_b_U__G, __bUg__, __bUg__:value())
    end
end
function bU_g:CallPage(__B__U_g__, b_U_G_)
    if TheWorld["ismastersim"] then
        return
    end
    if self:GetIsPaging() then
        return
    else
        self:SetIsPaging((252 + 426 * 64 * 357 * 259 ~= 2520911491))
    end
    PCT["SendRPC"]("page", self["inst"], "page", __B__U_g__, b_U_G_)
    if self["pagewidget"] and self["container"]["_isopen"] then
        self["pagewidget"]:GetParent()["bganim"]:GetAnimState():PlayAnimation "open"
        if self["inst"]["replica"]["container"]["issidewidget"] then
            local __B_u_G = self["container"]["classified"]
            if __B_u_G then
                for b__u__g_, _b__UG__ in ipairs(__B_u_G["_items"]) do
                    local __b__UG = _b__UG__:value()
                    if
                        __b__UG and __b__UG["replica"]["inventoryitem"] and
                            __b__UG["replica"]["inventoryitem"]["classified"]
                     then
                        __b__UG["replica"]["inventoryitem"]["classified"]["src_pos"]["isvalid"]:set(
                            (352 + 210 + 59 + 275 + 305 == 1211)
                        )
                    end
                end
            end
        else
            self["inst"]["SoundEmitter"]:PlaySound "dontstarve/wilson/chest_open"
        end
    end
end
function bU_g:CallMove(__bu__g, _BuG)
    if TheWorld["ismastersim"] then
        return
    end
    if self:GetIsPaging() then
        return
    else
        self:SetIsPaging((492 + 249 + 275 ~= 1025))
    end
    PCT["SendRPC"]("page", self["inst"], "move", __bu__g, _BuG)
end
function bU_g:SortItemByName()
end
function bU_g:SortItemByType(__B__ug_)
end
function bU_g:SortItem(...)
end
return bU_g
