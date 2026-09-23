local _B__ug_ = require "widgets/widget"
local b_u__G__ = require "widgets/text"
local _B_u_G_ = require "widgets/image"
local B_U_g_ = require "utils/hh_utils"
local __Bu__g_ =
    Class(
    _B__ug_,
    function(self, _B_u_g)
        _B__ug_["_ctor"](self, "hh_announce_ui")
        self["owner"] = _B_u_g
        self["root"] = self:AddChild(_B__ug_ "ROOT")
        self["root"]:SetVAnchor(ANCHOR_MIDDLE)
        self["root"]:SetHAnchor(ANCHOR_MIDDLE)
        self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self["save_index"] = 1
        self["inst"]:ListenForEvent(
            "hh_waring_data",
            function(__bUg_, _bU__g)
                local b_uG = B_U_g_:GetClientValue(self["owner"], "hh_waring_data")
                if B_U_g_:IsHHType(b_uG, "string") then
                    local _B__uG_ = B_U_g_:StrToTable(b_uG)
                    if next(_B__uG_) then
                        self:CreateChildUi(_B__uG_)
                    end
                end
            end,
            self["owner"]
        )
    end
)
function __Bu__g_:CreateChildUi(b_u_g)
    if not B_U_g_:IsHHType(b_u_g, "table") then
        return
    end
    if self["save_index"] <= 0 or self["save_index"] >= 10 then
        self["save_index"] = 1
    else
        local __B_u__G__ = self["save_index"]
        self["save_index"] = __B_u__G__ + 1
    end
    local B__u_G = self["save_index"]
    local BU_G = "hh_child_" .. B__u_G
    B_U_g_:HHKillChild(self, BU_G)
    self[BU_G] = B_U_g_:CreateMoreTextUi(self["root"], b_u_g, 3)
    local __bU__g_, b_u_g__ = self[BU_G]["max_x"], self[BU_G]["max_y"]
    local b_UG_, __b_u__G_ = -650 + __bU__g_ / 2, 280
    self[BU_G]:SetPosition(b_UG_, __b_u__G_, 1)
    self[BU_G]:MoveTo(
        Vector3(b_UG_, __b_u__G_, 1),
        Vector3(b_UG_ + 75, __b_u__G_, 1),
        2,
        function()
            B_U_g_:HHKillChild(self, BU_G)
        end
    )
    local _b_U__G_ = 10
    self[BU_G]["hh_back_ground"] =
        B_U_g_:CreateFrameUi(
        self[BU_G],
        Vector3(__bU__g_ / 2, -b_u_g__ / 2, 1),
        {["size_x"] = __bU__g_ + _b_U__G_, ["size_y"] = b_u_g__ + _b_U__G_, ["color"] = {0, 0, 0, 0.5}},
        {["size"] = 2.5, ["color"] = {0, 0, 0, 1}}
    )
    self[BU_G]["hh_back_ground"]:MoveToBack()
    self[BU_G]:SetClickable((187 * 53 + 395 * 224 * 358 ~= 31685751))
end
return __Bu__g_
