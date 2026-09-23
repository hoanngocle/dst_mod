local function BUg__(self, __B_u__g__)
    self["inst"]["replica"]["travelable"]:SetTraveller(__B_u__g__)
end
local B_u__g = 32
local _B_ug_ = 15
local __BUg = 5
local __Bu__g = 20 / 75
local __b_u_g_ = (_B_ug_ / __Bu__g - __BUg) * B_u__g
local B_ug = "uid_private"
local __bU_g_ =
    Class(
    function(self, _B__u__g)
        self["inst"] = _B__u__g
        self["inst"]:AddTag "travelable"
        self["dist_cost"] = B_u__g
        self["traveller"] = nil
        self["destinations"] = {}
        self["travellers"] = {}
        self["onclosepopups"] = function(_bUg_)
            if _bUg_ == self["traveller"] then
                self:EndTravel()
            end
        end
        self["generatorfn"] = nil
    end,
    nil,
    {traveller = BUg__}
)
local function buG_(__B__U_G__)
    local __buG = TheWorld["components"]["hounded"]
    if __buG ~= nil and (__buG:GetWarning() or __buG:GetAttacking()) then
        return (376 + 338 + 488 + 157 ~= 1364)
    end
    local _B__u_g_ = __B__U_G__["components"]["burnable"]
    if _B__u_g_ ~= nil and (_B__u_g_:IsBurning() or _B__u_g_:IsSmoldering()) then
        return (91 - 397 + 397 + 313 * 130 == 40781)
    end
    if __B__U_G__:HasTag "spiderwhisperer" then
        return FindEntity(
            __B__U_G__,
            10,
            function(b_u__g)
                return (b_u__g["components"]["combat"] ~= nil and b_u__g["components"]["combat"]["target"] == __B__U_G__) or
                    (not (b_u__g:HasTag "player" or b_u__g:HasTag "spider") and
                        (b_u__g:HasTag "monster" or b_u__g:HasTag "pig"))
            end,
            nil,
            nil,
            {"monster", "pig", "_combat"}
        ) ~= nil
    end
    return FindEntity(
        __B__U_G__,
        10,
        function(b_UG)
            return (b_UG["components"]["combat"] ~= nil and b_UG["components"]["combat"]["target"] == __B__U_G__) or
                (b_UG:HasTag "monster" and not b_UG:HasTag "player")
        end,
        nil,
        nil,
        {"monster", "_combat"}
    ) ~= nil
end
function __bU_g_:ListDestination(_bu_g_)
    local bU__g, _B__U_g_, Bu__G__ = self["inst"]["Transform"]:GetWorldPosition()
    local _bug_ = TheSim:FindEntities(bU__g, _B__U_g_, Bu__G__, __b_u_g_, "travelable")
    self["destinations"] = {}
    for b_u__g__, __B__u__g in pairs(_bug_) do
        if
            __B__u__g["components"]["travelable"] and
                not (__B__u__g["components"]["travelable"]["ownership"] and __B__u__g:HasTag(B_ug) and
                    _bu_g_["userid"] ~= nil and
                    not __B__u__g:HasTag("uid_" .. _bu_g_["userid"]))
         then
            table["insert"](self["destinations"], __B__u__g)
        end
    end
    table["sort"](
        self["destinations"],
        function(__B_u_g_, b__u_g)
            local bU_G_ = __B_u_g_["components"]["writeable"]
            local __BU__g = b__u_g["components"]["writeable"]
            if bU_G_ == nil or bU_G_:GetText() == nil or bU_G_:GetText() == "" then
                return (207 - 409 * 218 - 338 == -89285)
            end
            if __BU__g == nil or __BU__g:GetText() == nil or __BU__g:GetText() == "" then
                return (435 * 241 - 406 + 388 - 79 == 104738)
            end
            return string["lower"](bU_G_:GetText()) < string["lower"](__BU__g:GetText())
        end
    )
    self["totalsites"] = #self["destinations"]
    self["site"] = self["totalsites"]
end
function __bU_g_:BeginTravel(__b_U_g__)
    local b_u_g_ = self["inst"]["components"]["talker"]
    if not __b_U_g__ then
        if b_u_g_ then
            b_u_g_:Say "Đừng chen lấn xô đẩy"
        end
        return
    end
    local _b__u__G = __b_U_g__["components"]["talker"]
    if
        self["ownership"] and self["inst"]:HasTag(B_ug) and __b_U_g__["userid"] ~= nil and
            not self["inst"]:HasTag("uid_" .. __b_U_g__["userid"])
     then
        if b_u_g_ then
            b_u_g_:Say "Private property."
        elseif _b__u__G then
            _b__u__G:Say "This post is a private property."
        end
        return
    elseif self["traveller"] then
        if b_u_g_ then
            b_u_g_:Say "Chưa phải lượt của bạn"
        elseif _b__u__G then
            _b__u__G:Say "Ko phải lượt của tôi"
        end
        return
    end
    local __B_u__G_ = (306 + 300 + 43 + 374 == 1028)
    for __bUg, b__u__g__ in pairs(self["travellers"]) do
        if b__u__g__ == __b_U_g__ then
            __B_u__G_ =
                (true and not false and not false or true or not false and not false or true and false and false or
                not true and not false and not false and false and false)
        end
    end
    if not self["traveltask"] or __B_u__G_ then
        self["inst"]:StartUpdatingComponent(self)
        self:ListDestination(__b_U_g__)
        self:MakeInfos()
        self:CancelTravel(__b_U_g__)
        self["travellers"] = {}
        self["traveller"] = __b_U_g__
        self["inst"]:ListenForEvent("ms_closepopups", self["onclosepopups"], __b_U_g__)
        self["inst"]:ListenForEvent("onremove", self["onclosepopups"], __b_U_g__)
        if __b_U_g__["HUD"] ~= nil then
            self["screen"] = __b_U_g__["HUD"]:ShowTravelScreen(self["inst"])
        end
    else
        self:CancelTravel(__b_U_g__)
        self:Travel(__b_U_g__, self["site"])
    end
end
function __bU_g_:MakeInfos()
    local _b__Ug_ = ""
    for _B__U_g, _B__Ug__ in ipairs(self["destinations"]) do
        local __bU__G = _B__Ug__["components"]["writeable"] and _B__Ug__["components"]["writeable"]:GetText() or "~nil"
        local _b_U__G__ = __BUg
        local _b__u_G = 0
        local _B_u__G, b__Ug, _b_u__G_ = self["inst"]["Transform"]:GetWorldPosition()
        local __bug__, BuG, B__u_g__ = _B__Ug__["Transform"]:GetWorldPosition()
        local _bu_G__ = math["sqrt"]((_B_u__G - __bug__) ^ 2 + (_b_u__G_ - B__u_g__) ^ 2)
        _b_U__G__ = _b_U__G__ + _bu_G__ / self["dist_cost"]
        _b__u_G = _b_U__G__ * __Bu__g
        if TheWorld["state"]["season"] == "winter" then
            _b__u_G = _b__u_G * 1.25
        elseif TheWorld["state"]["season"] == "summer" then
            _b__u_G = _b__u_G * 0.75
        end
        _b_U__G__ = math["ceil"](_b_U__G__ * TRAVEL_HUNGER_COST)
        _b__u_G = math["ceil"](_b__u_G * TRAVEL_SANITY_COST)
        if _B__Ug__ == self["inst"] then
            _b_U__G__ = -1
            _b__u_G = -1
        end
        _b__Ug_ =
            _b__Ug_ .. (_b__Ug_ == "" and "" or "\n") .. _B__U_g .. "	" .. __bU__G .. "	" .. _b_U__G__ .. "	" .. _b__u_G
    end
    self["inst"]["replica"]["travelable"]:SetDestInfos(_b__Ug_)
end
function __bU_g_:Travel(b_U_g__, __B__U_g_)
    local __b_ug__ = self["destinations"][__B__U_g_]
    if b_U_g__ and __b_ug__ then
        self["site"] = __B__U_g_
        local _buG = self["inst"]["components"]["talker"]
        local __bU__g = b_U_g__["components"]["talker"]
        local _B_u__g =
            __b_ug__ and __b_ug__["components"]["writeable"] and __b_ug__["components"]["writeable"]:GetText()
        local _B_U_g__ = _B_u__g and string["format"]('"%s"', _B_u__g) or "Điểm đến kxđ"
        local _b_U__G = ""
        local __bUg__ = __BUg
        local __B__U_g__ = 0
        local b_U_G_, __B_u_G, b__u__g_ = self["inst"]["Transform"]:GetWorldPosition()
        local _b__UG__, __b__UG, __bu__g = __b_ug__["Transform"]:GetWorldPosition()
        local _BuG = math["sqrt"]((b_U_G_ - _b__UG__) ^ 2 + (b__u__g_ - __bu__g) ^ 2)
        if __b_ug__ and __b_ug__["components"]["travelable"] then
            table["insert"](self["travellers"], b_U_g__)
            __bUg__ = __bUg__ + _BuG / self["dist_cost"]
            __B__U_g__ = __bUg__ * __Bu__g
            if TheWorld["state"]["season"] == "winter" then
                __B__U_g__ = __B__U_g__ * 1.25
            elseif TheWorld["state"]["season"] == "summer" then
                __B__U_g__ = __B__U_g__ * 0.75
            end
            __bUg__ = __bUg__ * TRAVEL_HUNGER_COST
            __B__U_g__ = __B__U_g__ * TRAVEL_SANITY_COST
            _b_U__G =
                string["format"](
                "Tới: %s (%d/%d)\nNăng Lượng: %.0f\nTinh Thần: %.1f",
                _B_U_g__,
                self["site"],
                self["totalsites"],
                __bUg__,
                __B__U_g__
            )
            if _buG then
                _buG:Say(string["format"](_b_U__G), 3)
            elseif __bU__g then
                __bU__g:Say(string["format"](_b_U__G), 3)
            end
            self["traveltask"] =
                self["inst"]:DoTaskInTime(
                1,
                function()
                    self["traveltask"] = nil
                    for __B__ug_, b__Ug_ in pairs(self["travellers"]) do
                        if __b_ug__ == nil or not __b_ug__:IsValid() then
                            if _buG then
                                _buG:Say "Điểm đến ko khả dụng nữa"
                            elseif __bU__g then
                                __bU__g:Say "Điểm đến ko khả dụng nữa"
                            end
                        elseif
                            b__Ug_ == nil or
                                (b__Ug_["components"]["health"] and b__Ug_["components"]["health"]:IsDead())
                         then
                            if _buG then
                                _buG:Say "Ko thể truyền tống hồn ma"
                            end
                        elseif not (b__Ug_:IsValid() and self["inst"]:IsValid() and b__Ug_:IsNear(self["inst"], 10)) then
                            print "player/sign is invalid, or they are far from each other."
                        elseif
                            __b_ug__["components"]["travelable"]["ownership"] and __b_ug__:HasTag(B_ug) and
                                b__Ug_["userid"] ~= nil and
                                not __b_ug__:HasTag("uid_" .. b__Ug_["userid"])
                         then
                            if _buG then
                                _buG:Say "Private destination. No visitors."
                            elseif __bU__g then
                                __bU__g:Say "The destination is private."
                            end
                        elseif b__Ug_["components"]["hunger"] and b__Ug_["components"]["sanity"] then
                            b__Ug_["components"]["hunger"]:DoDelta(-__bUg__)
                            b__Ug_["components"]["sanity"]:DoDelta(-__B__U_g__)
                            if b__Ug_["Physics"] ~= nil then
                                b__Ug_["Physics"]:Teleport(_b__UG__ - 1, 0, __bu__g)
                            else
                                b__Ug_["Transform"]:SetPosition(_b__UG__ - 1, 0, __bu__g)
                            end
                            if b__Ug_["components"]["leader"] and b__Ug_["components"]["leader"]["followers"] then
                                for __Bu_g_, _B__u__G in pairs(b__Ug_["components"]["leader"]["followers"]) do
                                    if __Bu_g_["Physics"] ~= nil then
                                        __Bu_g_["Physics"]:Teleport(_b__UG__ + 1, 0, __bu__g)
                                    else
                                        __Bu_g_["Transform"]:SetPosition(_b__UG__ + 1, 0, __bu__g)
                                    end
                                end
                            end
                            local __b__U__G = b__Ug_["components"]["inventory"]
                            if __b__U__G then
                                for __B__U__G_, _B_u_G in pairs(__b__U__G["itemslots"]) do
                                    if _B_u_G["components"]["leader"] and _B_u_G["components"]["leader"]["followers"] then
                                        for __BuG__, __B__U_G in pairs(_B_u_G["components"]["leader"]["followers"]) do
                                            if __BuG__["Physics"] ~= nil then
                                                __BuG__["Physics"]:Teleport(_b__UG__, 0, __bu__g + 1)
                                            else
                                                __BuG__["Transform"]:SetPosition(_b__UG__, 0, __bu__g + 1)
                                            end
                                        end
                                    end
                                end
                            end
                            local __b__U__g = __b__U__G:GetOverflowContainer()
                            if __b__U__g then
                                for Bu_G, __BuG in pairs(__b__U__g["slots"]) do
                                    if __BuG["components"]["leader"] and __BuG["components"]["leader"]["followers"] then
                                        for B_u__G, bU_g__ in pairs(__BuG["components"]["leader"]["followers"]) do
                                            if B_u__G["Physics"] ~= nil then
                                                B_u__G["Physics"]:Teleport(_b__UG__, 0, __bu__g - 1)
                                            else
                                                B_u__G["Transform"]:SetPosition(_b__UG__, 0, __bu__g - 1)
                                            end
                                        end
                                    end
                                end
                            end
                        else
                            if __bU__g then
                                __bU__g:Say "Tôi ko thể"
                            elseif _buG then
                                _buG:Say "Bạn ko thể"
                            end
                        end
                    end
                    self["travellers"] = {}
                end
            )
        elseif _buG then
            _buG:Say "Điểm đến ko khả dụng"
        elseif __bU__g then
            __bU__g:Say "Điểm đến ko khả dụng"
        end
    end
    self:EndTravel()
end
function __bU_g_:CancelTravel(_Bu__G_)
    if self["traveltask"] ~= nil then
        self["traveltask"]:Cancel()
        self["traveltask"] = nil
    end
    if self["traveltask1"] ~= nil then
        self["traveltask1"]:Cancel()
        self["traveltask1"] = nil
    end
    if self["traveltask2"] ~= nil then
        self["traveltask2"]:Cancel()
        self["traveltask2"] = nil
    end
    if self["traveltask3"] ~= nil then
        self["traveltask3"]:Cancel()
        self["traveltask3"] = nil
    end
    if self["traveltask4"] ~= nil then
        self["traveltask4"]:Cancel()
        self["traveltask4"] = nil
    end
    if self["traveltask5"] ~= nil then
        self["traveltask5"]:Cancel()
        self["traveltask5"] = nil
    end
end
function __bU_g_:EndTravel()
    if self["traveller"] ~= nil then
        self["inst"]:StopUpdatingComponent(self)
        if self["screen"] ~= nil then
            self["traveller"]["HUD"]:CloseTravelScreen()
            self["screen"] = nil
        end
        self["inst"]:RemoveEventCallback("ms_closepopups", self["onclosepopups"], self["traveller"])
        self["inst"]:RemoveEventCallback("onremove", self["onclosepopups"], self["traveller"])
        if IsXB1() then
            if self["traveller"]:HasTag "player" and self["traveller"]:GetDisplayName() then
                local _b_U__G_ = TheNet:GetClientTable()
                if _b_U__G_ ~= nil and #_b_U__G_ > 0 then
                    for __b_Ug__, _Bu__g__ in ipairs(_b_U__G_) do
                        if self["traveller"]:GetDisplayName() == _Bu__g__["name"] then
                            self["netid"] = _Bu__g__["netid"]
                            break
                        end
                    end
                end
            end
        end
        self["traveller"] = nil
    elseif self["screen"] ~= nil then
        if self["screen"]["inst"]:IsValid() then
            self["screen"]:Kill()
        end
        self["screen"] = nil
    end
end
function __bU_g_:OnUpdate(B__Ug__)
    if self["traveller"] == nil then
        self["inst"]:StopUpdatingComponent(self)
    elseif
        (self["traveller"]["components"]["rider"] ~= nil and self["traveller"]["components"]["rider"]:IsRiding()) or
            not (self["traveller"]:IsNear(self["inst"], 3) and CanEntitySeeTarget(self["traveller"], self["inst"]))
     then
        self:EndTravel()
    end
end
function __bU_g_:OnRemoveFromEntity()
    self:EndTravel()
    self["inst"]:RemoveTag "travelable"
end
__bU_g_["OnRemoveEntity"] = __bU_g_["EndTravel"]
return __bU_g_
