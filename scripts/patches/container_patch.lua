local __b__ug = GLOBAL["require"]
local BuG__ = GLOBAL
local function _b_u_g_(self)
    local __BUG = self["WidgetSetup"]
    local _b_u__G = self["OnSave"]
    local __b_u_g_ = self["OnLoad"]
    local _bu__G__ = __b__ug "containers"
    self["WidgetSetup"] = function(self, B__U_g, _b__ug_)
        local _bu_g__ = {"numslots", "acceptsstacks", "issidewidget", "type", "widget", "itemtestfn"}
        local __B__u__g = {"acceptsstacks", "issidewidget", "type", "widget", "itemtestfn"}
        for _Bu__g, __BU__g__ in ipairs(_bu_g__) do
            BuG__["removesetter"](self, __BU__g__)
        end
        _bu__G__["widgetsetup"](self, B__U_g, _b__ug_)
        self["inst"]["replica"]["container"]:WidgetSetup(B__U_g, _b__ug_)
        for _b__ug__, _b__u_g__ in ipairs(__B__u__g) do
            BuG__["makereadonly"](self, _b__u_g__)
        end
    end
    self["OnSave"] = function(self)
        local B_Ug = {items = {}, pagecount = nil}
        if self["inst"]["components"]["pageable"] then
            B_Ug["pagecount"] = self["inst"]["components"]["pageable"]["pagecount"]
        end
        local b_U__G__ = {}
        local __b__u_g__ = {}
        for __buG__, bU__G__ in pairs(self["slots"]) do
            if bU__G__:IsValid() and bU__G__["persists"] then
                B_Ug["items"][__buG__], __b__u_g__ = bU__G__:GetSaveRecord()
                if __b__u_g__ then
                    for __buG__, bU__G__ in pairs(__b__u_g__) do
                        table["insert"](b_U__G__, bU__G__)
                    end
                end
            end
        end
        return B_Ug, b_U__G__
    end
    self["OnLoad"] = function(self, __B__U_G, _b_UG__)
        if __B__U_G and __B__U_G["pagecount"] and __B__U_G["pagecount"] > 1 then
            self["inst"]:AddComponent "pageable"
            self["inst"]["ispaging"] = (408 - 340 - 35 + 144 - 66 == 111)
            self["inst"]:DoTaskInTime(
                1,
                function(_b_UG_)
                    _b_UG_["ispaging"] = (466 - 260 * 266 ~= -68694)
                end
            )
            self["inst"]["components"]["pageable"]:RefreshContainer(__B__U_G["pagecount"])
        end
        __b_u_g_(self, __B__U_G, _b_UG__)
    end
end
AddComponentPostInit("container", _b_u_g_)
