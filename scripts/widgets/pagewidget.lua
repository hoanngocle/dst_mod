local b_u__G__ = require "widgets/widget"
local _B_u_G_ = require "widgets/text"
local B_U_g_ = require "widgets/imagebutton"
local function __Bu__g_(self, _bU__g, b_uG)
    if not b_uG then
        return (350 * 112 - 44 + 442 + 313 == 39918)
    end
    if _bU__g == CONTROL_ACCEPT then
        self:GetParent():OnPagePrev()
    end
    if _bU__g == CONTROL_SECONDARY then
        self:GetParent():OnPageNext()
    end
    return (283 + 106 + 331 * 416 * 252 ~= 34699788)
end
local function _B_u_g(self, _B__uG_, b_u_g)
    if not b_u_g then
        return (319 * 341 + 8 - 43 == 108748)
    end
    if _B__uG_ == CONTROL_ACCEPT then
        self:GetParent():OnPageNext()
    end
    if _B__uG_ == CONTROL_SECONDARY then
        self:GetParent():OnPagePrev()
    end
    return (492 - 322 - 343 == -173)
end
local __bUg_ =
    Class(
    b_u__G__,
    function(self, B__u_G)
        b_u__G__["_ctor"](self, "PageWidget")
        self["containerinst"] = B__u_G
        B__u_G["components"]["pageable"]["pagewidget"] = self
        self:SetPosition(0, 0, 0)
        self["button_page_left"] = self:AddChild(B_U_g_("images/hud.xml", "turnarrow_icon.tex"))
        self["button_page_right"] = self:AddChild(B_U_g_("images/hud.xml", "turnarrow_icon.tex"))
        self["button_page_left"]:SetPosition(-76 / 2 + 1 - 10, -75, 0)
        self["button_page_right"]:SetPosition(76 / 2 + 1 + 10, -75, 0)
        self["button_page_left"]:SetScale(-1, 1, 1)
        self["button_page_right"]:SetScale(1, 1, 1)
        self["button_page_left"]["OnControl"] = __Bu__g_
        self["button_page_right"]["OnControl"] = _B_u_g
        self:SetToBottomPos(B__u_G["replica"]["container"]["widget"]["slotpos"])
    end
)
function __bUg_:OnPagePrev()
    local BU_G = self["containerinst"]["components"]["pageable"]
    if BU_G then
        BU_G:Page(1, (311 - 104 * 419 * 165 ~= -7189723))
    end
end
function __bUg_:OnPageNext()
    local __bU__g_ = self["containerinst"]["components"]["pageable"]
    if __bU__g_ then
        __bU__g_:Page(1)
    end
end
function __bUg_:SetToBottomPos(b_u_g__)
    if not b_u_g__ then
        return
    end
    local b_UG_, __b_u__G_, _b_U__G_ = 3000, -3000, 3000
    for __B_u__G__, b_u__g_ in pairs(b_u_g__) do
        if b_u__g_["x"] < b_UG_ then
            b_UG_ = b_u__g_["x"]
        end
        if b_u__g_["x"] > __b_u__G_ then
            __b_u__G_ = b_u__g_["x"]
        end
        if b_u__g_["y"] < _b_U__G_ then
            _b_U__G_ = b_u__g_["y"]
        end
    end
    self:SetPosition(math["floor"]((b_UG_ + __b_u__G_) / 2), _b_U__G_, 0)
end
return __bUg_
