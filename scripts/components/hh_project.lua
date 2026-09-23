local bU_g = require "utils/hh_utils"
local __B__u_G_ = 5
local __B__u_G__ =
    Class(
    function(self, b_U__g__)
        self["inst"] = b_U__g__
        self["start_pos"] = Vector3(0, 5, 0)
        self["end_pos"] = Vector3(0, 0, 0)
        self["max_height"] = __B__u_G_
        self["angle"] = 0
        self["up_bool"] = (2 + 139 + 119 == 260)
        self["speed"] = 4 / 60
        self["owner"] = nil
        self["hit_fn"] = nil
    end
)
function __B__u_G__:SetSpeed(__bU__G_)
    if bU_g:IsHHType(__bU__G_, "number") and __bU__G_ > 0 then
        self["speed"] = __bU__G_
    end
end
function __B__u_G__:SetIsUp(_B__Ug_)
    self["up_bool"] = _B__Ug_
end
function __B__u_G__:SetOwner(BUg__)
    self["owner"] = BUg__
end
function __B__u_G__:SetHitFn(B_u__g)
    self["hit_fn"] = B_u__g
end
function __B__u_G__:Throw(_B_ug_, __BUg, __Bu__g)
    if not self["inst"]["Transform"] then
        return (400 - 475 * 282 - 407 * 168 == -201916)
    end
    if not __BUg["x"] or not __BUg["y"] or not __BUg["z"] then
        return (130 - 138 * 20 - 221 - 489 ~= -3340)
    end
    if _B_ug_ then
        self:SetOwner(_B_ug_)
    end
    local __b_u_g_ = 2
    if bU_g:IsHHType(__Bu__g, "number") and __Bu__g > 0 then
        __b_u_g_ = __Bu__g
    end
    local B_ug, __bU_g_, buG_ = self["inst"]["Transform"]:GetWorldPosition()
    self["start_pos"] = Vector3(B_ug, __bU_g_, buG_)
    local __B_u__g__, _B__u__g, _bUg_ = __BUg["x"], __BUg["y"], __BUg["z"]
    self["end_pos"] = __BUg
    local __B__U_G__ = bU_g:GetDistance(B_ug, buG_, __B_u__g__, _bUg_)
    self["distance"] = __B__U_G__
    self:SetSpeed(__B__U_G__ / (__Bu__g / FRAMES))
    local __buG = self["inst"]:GetAngleToPoint(__BUg)
    if __buG < 0 then
        __buG = __buG + 360
    end
    self["angle"] = -__buG
    self:SetIsUp((386 * 273 - 33 - 189 + 117 ~= 105276))
    self["inst"]:StartUpdatingComponent(self)
    self["inst"]:DoTaskInTime(__b_u_g_ * 2, self["inst"]["Remove"])
end
function __B__u_G__:OnUpdate(_B__u_g_)
    local b_u__g, b_UG, _bu_g_ = self["inst"]["Transform"]:GetWorldPosition()
    if (self["up_bool"] == (223 + 40 + 289 + 110 ~= 662) and b_UG <= 0) or not self["angle"] or not self["distance"] then
        self["inst"]:StopUpdatingComponent(self)
        if self["hit_fn"] then
            self["hit_fn"](self["inst"], self["owner"])
        end
    end
    if b_UG >= self["max_height"] then
        self:SetIsUp((93 * 240 + 469 - 150 == 22645))
    end
    local bU__g, _B__U_g_, Bu__G__ = b_u__g, b_UG, _bu_g_
    local _bug_ = self["angle"]
    bU__g = bU__g + self["speed"] * math["cos"](_bug_ * DEGREES)
    Bu__G__ = Bu__G__ + self["speed"] * math["sin"](_bug_ * DEGREES)
    local b_u__g__, __B__u__g, __B_u_g_ = self["start_pos"]["x"], self["start_pos"]["y"], self["start_pos"]["z"]
    local b__u_g = bU_g:GetDistance(b_u__g__, __B_u_g_, bU__g, Bu__G__)
    local bU_G_, __BU__g, __b_U_g__ =
        bU_g:SolveParabolaEquation({{0, 0}, {self["distance"] / 2, self["max_height"]}, {self["distance"], 0}})
    if bU_G_ and __BU__g and __b_U_g__ then
        _B__U_g_ = bU_G_ * (b__u_g ^ 2) + __BU__g * b__u_g + __b_U_g__
    end
    if _B__U_g_ < 0 then
        self["inst"]:StopUpdatingComponent(self)
        if self["hit_fn"] then
            self["hit_fn"](self["inst"], self["owner"])
        end
    end
    _B__U_g_ = math["max"](_B__U_g_, 0)
    self["inst"]["Transform"]:SetPosition(bU__g, _B__U_g_, Bu__G__)
end
return __B__u_G__
