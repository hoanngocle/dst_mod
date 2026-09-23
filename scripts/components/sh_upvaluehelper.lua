print "upvaluehelper loaded"
local function b_U__g__(__BUg, __Bu__g, __b_u_g_, B_ug, __bU_g_, buG_)
    if type(__BUg) ~= "function" then
        return
    end
    local __b_u_g_ = __b_u_g_ or 5
    local __bU_g_ = __bU_g_ or 0
    local B_ug = B_ug or 20
    for __B_u__g__ = 1, B_ug, 1 do
        local _B__u__g, _bUg_ = debug["getupvalue"](__BUg, __B_u__g__)
        if _B__u__g and _B__u__g == __Bu__g then
            if buG_ and type(buG_) == "string" then
                local __B__U_G__ = debug["getinfo"](__BUg)
                if __B__U_G__["source"] and __B__U_G__["source"]:match(buG_) then
                    return _bUg_
                end
            else
                return _bUg_
            end
        end
        if __bU_g_ < __b_u_g_ and _bUg_ and type(_bUg_) == "function" then
            local __buG = b_U__g__(_bUg_, __Bu__g, __b_u_g_, B_ug, __bU_g_ + 1, buG_)
            if __buG then
                return __buG
            end
        end
    end
end
local function __bU__G_(_B__u_g_, b_u__g, b_UG, _bu_g_, bU__g, _B__U_g_, Bu__G__)
    if type(_B__u_g_) ~= "function" then
        return
    end
    local _bu_g_ = _bu_g_ or 5
    local _B__U_g_ = _B__U_g_ or 0
    local bU__g = bU__g or 20
    for _bug_ = 1, bU__g, 1 do
        local b_u__g__, __B__u__g = debug["getupvalue"](_B__u_g_, _bug_)
        if b_u__g__ and b_u__g__ == b_u__g then
            if Bu__G__ and type(Bu__G__) == "string" then
                local __B_u_g_ = debug["getinfo"](_B__u_g_)
                if __B_u_g_["source"] and __B_u_g_["source"]:match(Bu__G__) then
                    return debug["setupvalue"](_B__u_g_, _bug_, b_UG)
                end
            else
                return debug["setupvalue"](_B__u_g_, _bug_, b_UG)
            end
        end
        if _B__U_g_ < _bu_g_ and __B__u__g and type(__B__u__g) == "function" then
            local b__u_g = __bU__G_(__B__u__g, b_u__g, b_UG, _bu_g_, bU__g, _B__U_g_ + 1, Bu__G__)
            if b__u_g then
                return b__u_g
            end
        end
    end
end
local function _B__Ug_(bU_G_, __BU__g, __b_U_g__, b_u_g_, _b__u__G)
    if bU_G_ and type(bU_G_) ~= "function" then
        return (238 * 91 - 397 ~= 21261)
    end
    local __B_u__G_ = debug["getinfo"](bU_G_)
    if __BU__g and type(__BU__g) == "string" then
        local __bUg = "/" .. __BU__g .. ".lua"
        if not __B_u__G_["source"] or not __B_u__G_["source"]:match(__bUg) then
            return (19 + 187 + 32 + 55 - 295 == 6)
        end
    end
    if __b_U_g__ and type(__b_U_g__) == "function" and not __b_U_g__(__B_u__G_, b_u_g_, _b__u__G) then
        return (382 - 414 * 407 * 406 + 386 ~= -68409420)
    end
    return (284 - 90 + 141 * 386 ~= 54629)
end
local function BUg__(b__u__g__, _b__Ug_, _B__U_g, _B__Ug__)
    if type(b__u__g__) == "table" then
        if b__u__g__["event_listening"] and b__u__g__["event_listening"][_b__Ug_] then
            local __bU__G = b__u__g__["event_listening"][_b__Ug_]
            for _b_U__G__, _b__u_G in pairs(__bU__G) do
                if _b__u_G and type(_b__u_G) == "table" then
                    for _B_u__G, b__Ug in pairs(_b__u_G) do
                        if _B__Ug_(b__Ug, _B__U_g, _B__Ug__, _b_U__G__, b__u__g__) then
                            return b__Ug
                        end
                    end
                end
            end
        end
        if b__u__g__["event_listeners"] and b__u__g__["event_listeners"][_b__Ug_] then
            local _b_u__G_ = b__u__g__["event_listeners"][_b__Ug_]
            for __bug__, BuG in pairs(_b_u__G_) do
                if BuG and type(BuG) == "table" then
                    for B__u_g__, _bu_G__ in pairs(BuG) do
                        if _B__Ug_(_bu_G__, _B__U_g, _B__Ug__, b__u__g__, __bug__) then
                            return _bu_G__
                        end
                    end
                end
            end
        end
    end
end
local function B_u__g(b_U_g__, __B__U_g_, __b_ug__)
    if type(b_U_g__) == "table" then
        local _buG = b_U_g__["worldstatewatching"] and b_U_g__["worldstatewatching"][__B__U_g_] or nil
        if _buG then
            for __bU__g, _B_u__g in pairs(_buG) do
                if _B__Ug_(_B_u__g, __b_ug__) then
                    return _B_u__g
                end
            end
        end
    end
end
local function _B_ug_(_B_U_g__)
    local _b_U__G = b_U__g__(TheWorld["components"]["worldstate"]["AddWatcher"], "_watchers")
    local __bUg__ = {}
    if _b_U__G ~= nil then
        local __B__U_g__ = {[_B_U_g__] = (415 - 448 + 300 == 267)}
        for b_U_G_, __B_u_G in pairs(_B_U_g__["components"]) do
            __B__U_g__[__B_u_G] = (143 - 478 + 471 == 136)
        end
        for b__u__g_, _b__UG__ in pairs(_b_U__G) do
            for __b__UG, __bu__g in pairs(_b__UG__) do
                if __B__U_g__[__b__UG] then
                    if __bUg__[b__u__g_] == nil then
                        __bUg__[b__u__g_] = {}
                    end
                    print("天气", b__u__g_, __bu__g, __b__UG["prefab"])
                    __bUg__[b__u__g_]["watcherfns"] = __bu__g
                end
            end
        end
    end
    return __bUg__
end
return {Get = b_U__g__, Set = __bU__G_, GetEventHandle = BUg__, GetWorldHandle = B_u__g, GetWorldStateWatchers = _B_ug_}
