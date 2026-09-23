local b_u_g__ = require "utils/hh_utils"
local b_UG_ = require "widgets/widget"
local __b_u__G_ = require "widgets/image"
local _b_U__G_ = require "widgets/textbutton"
local __B_u__G__ = require "widgets/truescrollarea"
local HHGuideLock = require "utils/hh_guide_lock"
local HHSummaryLock = require "utils/hh_summary_lock"
local b_u__g_, _bU_G = "images/scrapbook.xml", "scrap2_wide.tex"
local __BUG = {"hh_frame_left", "hh_frame_right", "hh_frame_up", "hh_frame_down"}
local BuG = {"hh_icon_left_up", "hh_icon_right_up", "hh_icon_right_down", "hh_icon_left_down"}
local Bu__g = TUNING["HH_COLOR_CONFIG"] or {}
local __b__U_g_ = TUNING["HH_ICON_CONFIG"] or {}
local __b_U_g_ = {{["name"] = "", ["xml"] = "", ["tex"] = ""}}
local function __b_UG_(_b_U_g, _bU_G_, _b_ug_, B__UG_, BU_G__)
    if not _b_U_g[_bU_G_] then
        _b_U_g[_bU_G_] = _b_U_g:AddChild(__b_u__G_("images/hh_icon/hh_ui_frame.xml", "hh_ui_frame.tex"))
    end
    _b_U_g[_bU_G_]:SetPosition(_b_ug_)
    _b_U_g[_bU_G_]:SetTint(244 / 255, 255 / 255, 0 / 255, 1)
    if _bU_G_ == "hh_frame_left" or _bU_G_ == "hh_frame_right" then
        _b_U_g[_bU_G_]:SetRotation(90)
        _b_U_g[_bU_G_]:SetSize(BU_G__, B__UG_)
    else
        _b_U_g[_bU_G_]:SetSize(B__UG_, BU_G__)
    end
end
local function _b_u_G(__b_u_G__, _bu__G__, __B_UG__, _B_Ug_, __b_u__g_)
    if not __b_u_G__[_bu__G__] then
        __b_u_G__[_bu__G__] = __b_u_G__:AddChild(__b_u__G_("images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"))
    end
    __b_u_G__[_bu__G__]:SetPosition(__B_UG__)
    if __b_u_G__[_bu__G__]["texture"] == "hh_ui_icon.tex" then
        __b_u_G__[_bu__G__]:SetTint(244 / 255, 255 / 255, 0 / 255, 1)
    end
    __b_u_G__[_bu__G__]:SetSize(_B_Ug_, _B_Ug_)
    if b_u_g__:IsHHType(__b_u__g_, "number") then
        __b_u_G__[_bu__G__]:SetRotation(__b_u__g_)
    end
end
local function _B__u__g__(_b__U_g__, __bUg, b__uG__)
    if b_u_g__:IsHHType(__bUg, "number") and b_u_g__:IsHHType(_b__U_g__, "table") and _b__U_g__[b__uG__] then
        _b__U_g__[b__uG__] = __bUg
    end
end
local function _b__Ug(Bu__G__, _b_uG)
    local B__UG = Bu__G__["OnGainFocus"]
    Bu__G__["OnGainFocus"] = function()
        if B__UG then
            B__UG()
        end
        Bu__G__["hh_desc"] = b_u_g__:HHCreateTextUi(Bu__G__, Vector3(0, 0, 1), tostring(_b_uG), {1, 1, 1, 1}, 30)
        Bu__G__["hh_desc"]:MoveTo(Vector3(0, 20, 1), Vector3(0, 40, 1), 0.5)
    end
    local __b_Ug = Bu__G__["OnLoseFocus"]
    Bu__G__["OnLoseFocus"] = function()
        if __b_Ug then
            __b_Ug()
        end
        b_u_g__:HHKillChild(Bu__G__, "hh_desc")
    end
end
local B_u__g =
    Class(
    b_UG_,
    function(self, _b__Ug_)
        b_UG_["_ctor"](self, "hh_hoverer_config_ui")
        self["owner"] = _b__Ug_
        self["root"] = self:AddChild(b_UG_ "ROOT")
        self["root"]:SetVAnchor(ANCHOR_MIDDLE)
        self["root"]:SetHAnchor(ANCHOR_MIDDLE)
        self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self["hh_config"] = {
            ["back_ground_config"] = {7, 5},
            ["frame_config"] = {31, 10},
            ["icon_config"] = {1, 1, 1, 1}
        }
        self["inst"]:ListenForEvent(
            "hh_hoverer_config",
            function()
                if HHSummaryLock.IsOpen(self.owner) then
                    return
                end
                if b_u_g__:HasComponents(self["owner"], "hh_client") then
                    local B__u__g_ = self["owner"]["components"]["hh_client"]:GetValue "hh_hoverer_config"
                    if b_u_g__:IsHHType(B__u__g_, "table") then
                        self["hh_config"] = B__u__g_
                        if self["hh_main_ui"] then
                            b_u_g__:HHKillChild(self, "hh_main_ui")
                            self:CreateMainUi()
                        end
                    end
                end
            end,
            self["owner"]
        )
        self["hh_open_button"] =
            b_u_g__:HHCreateImageButton(
            self["root"],
            "images/crafting_menu_icons.xml",
            "filter_modded.tex",
            Vector3(-585, -330, 1),
            0.2,
            0.2
        )
        _b__Ug(self["hh_open_button"], "Cấu hình\nGiữ " .. STRINGS["RMB"] .. " kéo")
        self["hh_open_button"]:SetOnClick(
            function()
                if not HHGuideLock.IsOpen(self.owner) and not HHSummaryLock.IsOpen(self.owner)
                    and not self.owner.HHMonarchStorageOpen then
                    self:CreateMainUi()
                end
            end
        )
        b_u_g__:MakeUiCanMove(self["hh_open_button"])
    end
)
local function B__uG__(__B__Ug_, _B__UG__, __B_Ug_, _B_uG_, __B__u__G__)
    if not __B__Ug_ then
        return
    end
    if __B__Ug_[_B__UG__] then
        b_u_g__:HHKillChild(__B__Ug_, _B__UG__)
    end
    __B__Ug_[_B__UG__] = __B__Ug_:AddChild(_b_U__G_())
    __B__Ug_[_B__UG__]:SetFont(CODEFONT)
    __B__Ug_[_B__UG__]:SetTextSize(30)
    __B__Ug_[_B__UG__]:SetText(tostring(__B_Ug_))
    __B__Ug_[_B__UG__]:SetPosition(_B_uG_)
    __B__Ug_[_B__UG__]:SetTextColour({0, 0, 0, 1})
    __B__Ug_[_B__UG__]:SetTextFocusColour({1, 1, 1, 1})
    if b_u_g__:IsHHType(__B__u__G__, "function") then
        __B__Ug_[_B__UG__]:SetOnClick(__B__u__G__)
    end
end
local function __b__U_g__(self, b__U_g, Bu_G_)
    if
        self and b_u_g__:IsHHType(self["hh_config"], "table") and b_u_g__:IsHHType(self["hh_config"][Bu_G_], "table") and
            b_u_g__:IsHHType(self["hh_config"][Bu_G_][2], "number")
     then
        if b__U_g == "add" then
            self["hh_config"][Bu_G_][2] = math["min"](self["hh_config"][Bu_G_][2] + 1, 10)
        elseif b__U_g == "reduce" then
            self["hh_config"][Bu_G_][2] = math["max"](self["hh_config"][Bu_G_][2] - 1, 0)
        end
    end
end
function B_u__g:CreateMainUi()
    if HHSummaryLock.IsOpen(self.owner) then
        return
    end
    if self["hh_main_ui"] then
        b_u_g__:HHKillChild(self, "hh_main_ui")
        return
    end
    local bu_g, _Bu_g__ = 0, 0
    local B__u_g, bU__G = 600, 600
    local __bU_g = 20
    bu_g = -B__u_g / 2 + __bU_g
    self["hh_main_ui"] = b_u_g__:HHCreateImageUi(self["root"], b_u__g_, _bU_G, Vector3(100, 0, 1), B__u_g, bU__G)
    self["hh_main_ui"]["hh_close"] =
        b_u_g__:HHCreateImageButton(
        self["hh_main_ui"],
        "images/crafting_menu.xml",
        "pinslot_unpin_button.tex",
        Vector3(B__u_g / 2 - __bU_g, bU__G / 2 - __bU_g, 1),
        0.5,
        0.5
    )
    self["hh_main_ui"]["hh_close"]:SetOnClick(
        function()
            self:CreateMainUi()
        end
    )
    self:CreateHovererUi()
    self["hh_main_ui"]["hh_back_ground_title"] =
        b_u_g__:HHCreateTextUi(
        self["hh_main_ui"],
        Vector3(0, 0, 1),
        "Màu nền",
        {1, 1, 1, 1},
        30,
        (184 - 138 - 28 - 59 + 312 == 271)
    )
    local _b__uG, _Bu__g = self["hh_main_ui"]["hh_back_ground_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_back_ground_title"]:SetPosition(
        -B__u_g / 2 + __bU_g + _b__uG / 2,
        bU__G / 2 - __bU_g - _Bu__g / 2,
        1
    )
    _Bu_g__ = bU__G / 2 - __bU_g - _Bu__g
    local __Bu_G__ = 10
    local _B_U_G = 19
    local bug__ = 30
    for __bU__G, B__U__G in ipairs(Bu__g) do
        local _BUG = __bU__G - 1
        local b_UG__, _b_U__g__ =
            bu_g + (_BUG % _B_U_G) * bug__ + bug__ / 2,
            _Bu_g__ - (math["floor"](_BUG / _B_U_G)) * bug__ - bug__ / 2
        local Bu__g__ =
            B__U__G["color"] and {B__U__G["color"][1] / 255, B__U__G["color"][2] / 255, B__U__G["color"][3] / 255, 1} or
            {1, 1, 1, 1}
        self["hh_main_ui"]["hh_back_ground_color_" .. __bU__G] =
            b_u_g__:HHCreateImageButton(
            self["hh_main_ui"],
            "images/hh_icon/hh_white.xml",
            "hh_white.tex",
            Vector3(b_UG__, _b_U__g__, 1),
            bug__ / 8,
            bug__ / 8,
            Bu__g__
        )
        if __bU__G == self["hh_config"]["back_ground_config"][1] then
            self:HandleBlackGround(Bu__g__[1], Bu__g__[2], Bu__g__[3], self["hh_config"]["back_ground_config"][2] / 10)
            self["hh_main_ui"]["hh_back_ground_ok"] =
                b_u_g__:HHCreateImageUi(
                self["hh_main_ui"],
                "images/ui.xml",
                "checkmark.tex",
                Vector3(b_UG__, _b_U__g__, 1),
                bug__,
                bug__
            )
        end
        _b__Ug(self["hh_main_ui"]["hh_back_ground_color_" .. __bU__G], tostring(B__U__G["name"]))
        self["hh_main_ui"]["hh_back_ground_color_" .. __bU__G]:SetOnClick(
            function()
                b_u_g__:HHKillChild(self["hh_main_ui"], "hh_back_ground_ok")
                self["hh_config"]["back_ground_config"][1] = __bU__G
                self:HandleBlackGround(
                    Bu__g__[1],
                    Bu__g__[2],
                    Bu__g__[3],
                    self["hh_config"]["back_ground_config"][2] / 10
                )
                self["hh_main_ui"]["hh_back_ground_ok"] =
                    b_u_g__:HHCreateImageUi(
                    self["hh_main_ui"],
                    "images/ui.xml",
                    "checkmark.tex",
                    Vector3(b_UG__, _b_U__g__, 1),
                    bug__,
                    bug__
                )
            end
        )
    end
    local _b_ug__ = math["floor"](#Bu__g / _B_U_G)
    if #Bu__g % _B_U_G > 0 then
        _b_ug__ = _b_ug__ + 1
    end
    _Bu_g__ = _Bu_g__ - _b_ug__ * bug__
    self["hh_main_ui"]["hh_back_ground_rgb_a_title"] =
        b_u_g__:HHCreateTextUi(self["hh_main_ui"], Vector3(0, 0, 1), "Mờ", {1, 1, 1, 1}, 30, (362 + 393 - 379 ~= 384))
    local _B__u__g, b_U_G_ = self["hh_main_ui"]["hh_back_ground_rgb_a_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_back_ground_rgb_a_title"]:SetPosition(bu_g + _B__u__g / 2, _Bu_g__ - b_U_G_ / 2, 1)
    B__uG__(
        self["hh_main_ui"],
        "hh_back_ground_rgb_a_reduce",
        "-",
        Vector3(bu_g + 100, _Bu_g__ - b_U_G_ / 2, 1),
        function()
            __b__U_g__(self, "reduce", "back_ground_config")
            if
                self["hh_main_ui"] and self["hh_main_ui"]["hh_back_ground_rgb_a_title"] and
                    self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"]
             then
                self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"]:SetString(
                    tostring(self["hh_config"]["back_ground_config"][2])
                )
            end
            self:HandleBlackGround(nil, nil, nil, self["hh_config"]["back_ground_config"][2] / 10)
        end
    )
    B__uG__(
        self["hh_main_ui"],
        "hh_back_ground_rgb_a_add",
        "+",
        Vector3(bu_g + 200, _Bu_g__ - b_U_G_ / 2, 1),
        function()
            __b__U_g__(self, "add", "back_ground_config")
            if
                self["hh_main_ui"] and self["hh_main_ui"]["hh_back_ground_rgb_a_title"] and
                    self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"]
             then
                self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"]:SetString(
                    tostring(self["hh_config"]["back_ground_config"][2])
                )
            end
            self:HandleBlackGround(nil, nil, nil, self["hh_config"]["back_ground_config"][2] / 10)
        end
    )
    self["hh_main_ui"]["hh_back_ground_rgb_a_title"]["hh_a_str"] =
        b_u_g__:HHCreateTextUi(
        self["hh_main_ui"]["hh_back_ground_rgb_a_title"],
        Vector3(125, 0, 1),
        tostring(self["hh_config"]["back_ground_config"][2]),
        nil,
        30,
        (399 - 334 * 498 == -165933)
    )
    self["hh_main_ui"]["hh_frame_title"] =
        b_u_g__:HHCreateTextUi(
        self["hh_main_ui"],
        Vector3(0, 0, 1),
        "Màu viền",
        {1, 1, 1, 1},
        30,
        (80 * 247 * 239 == 4722640)
    )
    local B__Ug__, __Bu__G_ = self["hh_main_ui"]["hh_frame_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_frame_title"]:SetPosition(
        -B__u_g / 2 + __bU_g + B__Ug__ / 2,
        _Bu_g__ - __bU_g - __Bu__G_ / 2,
        1
    )
    _Bu_g__ = _Bu_g__ - __bU_g - __Bu__G_
    for b__UG, _b__u_g in ipairs(Bu__g) do
        local _buG__ = b__UG - 1
        local __b__U__G__, __b_u_g =
            bu_g + (_buG__ % _B_U_G) * bug__ + bug__ / 2,
            _Bu_g__ - (math["floor"](_buG__ / _B_U_G)) * bug__ - bug__ / 2
        local __B_U_g_ =
            _b__u_g["color"] and {_b__u_g["color"][1] / 255, _b__u_g["color"][2] / 255, _b__u_g["color"][3] / 255, 1} or
            {1, 1, 1, 1}
        self["hh_main_ui"]["hh_frame_color_" .. b__UG] =
            b_u_g__:HHCreateImageButton(
            self["hh_main_ui"],
            "images/hh_icon/hh_white.xml",
            "hh_white.tex",
            Vector3(__b__U__G__, __b_u_g, 1),
            bug__ / 8,
            bug__ / 8,
            __B_U_g_
        )
        if b__UG == self["hh_config"]["frame_config"][1] then
            self:HandleHovererFrame(__B_U_g_[1], __B_U_g_[2], __B_U_g_[3], self["hh_config"]["frame_config"][2] / 10)
            self["hh_main_ui"]["hh_frame_ok"] =
                b_u_g__:HHCreateImageUi(
                self["hh_main_ui"],
                "images/ui.xml",
                "checkmark.tex",
                Vector3(__b__U__G__, __b_u_g, 1),
                bug__,
                bug__
            )
        end
        _b__Ug(self["hh_main_ui"]["hh_frame_color_" .. b__UG], tostring(_b__u_g["name"]))
        self["hh_main_ui"]["hh_frame_color_" .. b__UG]:SetOnClick(
            function()
                b_u_g__:HHKillChild(self["hh_main_ui"], "hh_frame_ok")
                self["hh_config"]["frame_config"][1] = b__UG
                self:HandleHovererFrame(
                    __B_U_g_[1],
                    __B_U_g_[2],
                    __B_U_g_[3],
                    self["hh_config"]["frame_config"][2] / 10
                )
                self["hh_main_ui"]["hh_frame_ok"] =
                    b_u_g__:HHCreateImageUi(
                    self["hh_main_ui"],
                    "images/ui.xml",
                    "checkmark.tex",
                    Vector3(__b__U__G__, __b_u_g, 1),
                    bug__,
                    bug__
                )
            end
        )
    end
    _Bu_g__ = _Bu_g__ - _b_ug__ * bug__
    self["hh_main_ui"]["hh_frame_rgb_a_title"] =
        b_u_g__:HHCreateTextUi(
        self["hh_main_ui"],
        Vector3(0, 0, 1),
        "Mờ",
        {1, 1, 1, 1},
        30,
        (83 + 449 + 167 + 240 - 301 == 638)
    )
    local b__u_g_, BU__G = self["hh_main_ui"]["hh_frame_rgb_a_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_frame_rgb_a_title"]:SetPosition(bu_g + b__u_g_ / 2, _Bu_g__ - BU__G / 2, 1)
    B__uG__(
        self["hh_main_ui"],
        "hh_frame_rgb_a_reduce",
        "-",
        Vector3(bu_g + 100, _Bu_g__ - BU__G / 2, 1),
        function()
            __b__U_g__(self, "reduce", "frame_config")
            if
                self["hh_main_ui"] and self["hh_main_ui"]["hh_frame_rgb_a_title"] and
                    self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"]
             then
                self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"]:SetString(
                    tostring(self["hh_config"]["frame_config"][2])
                )
            end
            self:HandleHovererFrame(nil, nil, nil, self["hh_config"]["frame_config"][2] / 10)
        end
    )
    B__uG__(
        self["hh_main_ui"],
        "hh_frame_rgb_a_add",
        "+",
        Vector3(bu_g + 200, _Bu_g__ - BU__G / 2, 1),
        function()
            __b__U_g__(self, "add", "frame_config")
            if
                self["hh_main_ui"] and self["hh_main_ui"]["hh_frame_rgb_a_title"] and
                    self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"]
             then
                self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"]:SetString(
                    tostring(self["hh_config"]["frame_config"][2])
                )
            end
            self:HandleHovererFrame(nil, nil, nil, self["hh_config"]["frame_config"][2] / 10)
        end
    )
    self["hh_main_ui"]["hh_frame_rgb_a_title"]["hh_a_str"] =
        b_u_g__:HHCreateTextUi(
        self["hh_main_ui"]["hh_frame_rgb_a_title"],
        Vector3(125, 0, 1),
        tostring(self["hh_config"]["frame_config"][2]),
        nil,
        30,
        (189 - 464 * 360 == -166851)
    )
    _Bu_g__ = _Bu_g__ - BU__G
    self["hh_main_ui"]["hh_icon_config_ui_title"] =
        b_u_g__:HHCreateTextUi(
        self["hh_main_ui"],
        Vector3(0, 0, 1),
        "Biểu\ntượng\nbốn\ngóc",
        {1, 1, 1, 1},
        30,
        (402 * 423 * 490 - 271 * 419 ~= 83208996)
    )
    local __BU_g, b_Ug__ = self["hh_main_ui"]["hh_icon_config_ui_title"]:GetRegionSize()
    self["hh_main_ui"]["hh_icon_config_ui_title"]:SetPosition(bu_g + __BU_g / 2, _Bu_g__ - b_Ug__ / 2 - __bU_g, 1)
    bu_g = bu_g + __BU_g
    local __buG__ = b_UG_()
    local _b__uG__, _B_U__G__ = 300, 50
    local B_u_G_ = 40
    for _BU__g__, _B__u_g_ in ipairs(__b__U_g_) do
        local _B__UG_, __BU__G = _b__uG__ / 2 + __bU_g, -_B_U__G__ * (_BU__g__ - 1 / 2)
        __buG__["icon_" .. _BU__g__] =
            b_u_g__:HHCreateImageUi(
            __buG__,
            "images/hh_icon/hh_white.xml",
            "hh_white.tex",
            Vector3(_B__UG_, __BU__G, 1),
            _b__uG__,
            _B_U__G__ - 10,
            {0, 0, 0, 0.3}
        )
        local bu__g__, __B_U_G_ = -_b__uG__ / 2 + B_u_G_ / 2, 0
        if b_u_g__:IsHHType(_B__u_g_, "table") then
            if _B__u_g_["no_icon"] then
                __buG__["icon_" .. _BU__g__]["hh_icon"] =
                    b_u_g__:HHCreateTextUi(
                    __buG__["icon_" .. _BU__g__],
                    Vector3(bu__g__, __B_U_G_, 1),
                    "Ø",
                    {1, 1, 1, 1},
                    B_u_G_
                )
            elseif _B__u_g_["xml"] and _B__u_g_["tex"] then
                __buG__["icon_" .. _BU__g__]["hh_icon"] =
                    b_u_g__:HHCreateImageUi(
                    __buG__["icon_" .. _BU__g__],
                    _B__u_g_["xml"],
                    _B__u_g_["tex"],
                    Vector3(bu__g__, __B_U_G_, 1),
                    B_u_G_,
                    B_u_G_
                )
            end
            B__uG__(
                __buG__["icon_" .. _BU__g__],
                "hh_button_01",
                "◤",
                Vector3(bu__g__ + B_u_G_ * 3 / 2, 0, 1),
                function()
                    self:UpdateIconImg(1, _BU__g__)
                end
            )
            B__uG__(
                __buG__["icon_" .. _BU__g__],
                "hh_button_04",
                "◣",
                Vector3(bu__g__ + B_u_G_ * 5 / 2, 0, 1),
                function()
                    self:UpdateIconImg(4, _BU__g__)
                end
            )
            B__uG__(
                __buG__["icon_" .. _BU__g__],
                "hh_button_02",
                "◥",
                Vector3(bu__g__ + B_u_G_ * 7 / 2, 0, 1),
                function()
                    self:UpdateIconImg(2, _BU__g__)
                end
            )
            B__uG__(
                __buG__["icon_" .. _BU__g__],
                "hh_button_03",
                "◢",
                Vector3(bu__g__ + B_u_G_ * 9 / 2, 0, 1),
                function()
                    self:UpdateIconImg(3, _BU__g__)
                end
            )
            B__uG__(
                __buG__["icon_" .. _BU__g__],
                "hh_button_all",
                "∑",
                Vector3(bu__g__ + B_u_G_ * 11 / 2, 0, 1),
                function()
                    self:UpdateIconImg(1, _BU__g__, (460 - 276 - 163 * 385 == -62571))
                end
            )
        end
    end
    local __b_Ug__ = #__b__U_g_ * _B_U__G__
    local _BU__G_, __b__u_G_ = 200, 150
    local B_uG_ = {["x"] = 0, ["y"] = 0, ["width"] = _b__uG__, ["height"] = __b__u_G_}
    local _BU_g__ = {
        ["widget"] = __buG__,
        ["offset"] = {["x"] = 0, ["y"] = __b__u_G_},
        ["size"] = {["w"] = 0, ["height"] = __b_Ug__}
    }
    local _bUG__ = {["scroll_per_click"] = 5 * 3}
    self["hh_main_ui"]["hh_icon_config_ui"] = self["hh_main_ui"]:AddChild(__B_u__G__(_BU_g__, B_uG_, _bUG__))
    self["hh_main_ui"]["hh_icon_config_ui"]:SetPosition(bu_g, _Bu_g__ - __b__u_G_, 1)
    if
        self["hh_config"] and b_u_g__:IsHHType(self["hh_config"]["icon_config"], "table") and
            b_u_g__:IsHHType(self["hh_config"]["icon_config"][1], "number") and
            b_u_g__:IsHHType(self["hh_config"]["icon_config"][2], "number") and
            b_u_g__:IsHHType(self["hh_config"]["icon_config"][3], "number") and
            b_u_g__:IsHHType(self["hh_config"]["icon_config"][4], "number")
     then
        self:UpdateIconImg(1, self["hh_config"]["icon_config"][1])
        self:UpdateIconImg(2, self["hh_config"]["icon_config"][2])
        self:UpdateIconImg(3, self["hh_config"]["icon_config"][3])
        self:UpdateIconImg(4, self["hh_config"]["icon_config"][4])
    end
    local _Bug__ = 100
    self["hh_main_ui"]["hh_sure_button"] =
        b_u_g__:HHCreateImageButton(
        self["hh_main_ui"],
        "images/hh_icon/hh_white.xml",
        "hh_white.tex",
        Vector3(B__u_g / 2 - _Bug__, -bU__G / 2 + _Bug__ / 2, 1),
        _Bug__ / 8,
        _Bug__ / 16,
        {0, 0, 0, 0.7}
    )
    self["hh_main_ui"]["hh_sure_button"]:SetOnClick(
        function()
            if
                b_u_g__:IsHHType(self["hh_config"], "table") and
                    b_u_g__:IsHHType(self["hh_config"]["back_ground_config"], "table") and
                    b_u_g__:IsHHType(self["hh_config"]["frame_config"], "table") and
                    b_u_g__:IsHHType(self["hh_config"]["back_ground_config"][1], "number") and
                    b_u_g__:IsHHType(self["hh_config"]["back_ground_config"][2], "number") and
                    b_u_g__:IsHHType(self["hh_config"]["frame_config"][1], "number") and
                    b_u_g__:IsHHType(self["hh_config"]["frame_config"][2], "number") and
                    b_u_g__:IsHHType(self["hh_config"]["icon_config"][1], "number") and
                    b_u_g__:IsHHType(self["hh_config"]["icon_config"][2], "number") and
                    b_u_g__:IsHHType(self["hh_config"]["icon_config"][3], "number") and
                    b_u_g__:IsHHType(self["hh_config"]["icon_config"][4], "number")
             then
                if TheSim and TheSim["SetPersistentString"] then
                    TheSim:SetPersistentString(
                        "hh_hoverer_config",
                        b_u_g__:TableToStr(self["hh_config"]),
                        (157 * 322 - 94 * 175 - 330 == 33778)
                    )
                    self["owner"]:PushEvent "hh_hoverer_config"
                end
            end
        end
    )
    self["hh_main_ui"]["hh_sure_button"]["hh_str"] =
        b_u_g__:HHCreateTextUi(self["hh_main_ui"]["hh_sure_button"], Vector3(0, 0, 1), "Áp dụng", nil, 30)
end
function B_u__g:HandleBlackGround(_BUg__, __B__u__g__, _B_u_g__, __b_ug)
    if
        not self["hh_main_ui"] or not self["hh_main_ui"]["hh_hoverer_ui"] or
            not b_u_g__:IsHHType(self["hh_main_ui"]["hh_hoverer_ui"]["tint"], "table")
     then
        return
    end
    local bUG = self["hh_main_ui"]["hh_hoverer_ui"]
    local _b_UG_ = bUG["tint"]
    _B__u__g__(_b_UG_, _BUg__, 1)
    _B__u__g__(_b_UG_, __B__u__g__, 2)
    _B__u__g__(_b_UG_, _B_u_g__, 3)
    _B__u__g__(_b_UG_, __b_ug, 4)
    bUG:SetTint(_b_UG_[1], _b_UG_[2], _b_UG_[3], _b_UG_[4])
end
function B_u__g:HandleHovererFrame(__bU_G, Bu_g_, b_U__g_, B_U__g__)
    if not self["hh_main_ui"] or not self["hh_main_ui"]["hh_hoverer_ui"] then
        return
    end
    local b_u_G = self["hh_main_ui"]["hh_hoverer_ui"]
    local __b_U__G__ = (412 - 274 - 445 ~= -301)
    for __bu__G_, __B_Ug__ in ipairs(__BUG) do
        if not b_u_G[__B_Ug__] or not b_u_g__:IsHHType(b_u_G[__B_Ug__]["tint"], "table") then
            __b_U__G__ = (258 - 431 * 111 * 333 == -15930786)
            break
        end
    end
    for _bU__g_, _B__u_g__ in ipairs(BuG) do
        if not b_u_G[_B__u_g__] or not b_u_g__:IsHHType(b_u_G[_B__u_g__]["tint"], "table") then
            __b_U__G__ = (449 + 343 + 139 - 465 == 473)
            break
        end
    end
    if not __b_U__G__ then
        return
    end
    for _bug, _b_U__g_ in ipairs(__BUG) do
        local __B__U_G__ = b_u_G[_b_U__g_]["tint"]
        _B__u__g__(__B__U_G__, __bU_G, 1)
        _B__u__g__(__B__U_G__, Bu_g_, 2)
        _B__u__g__(__B__U_G__, b_U__g_, 3)
        _B__u__g__(__B__U_G__, B_U__g__, 4)
        b_u_G[_b_U__g_]:SetTint(__B__U_G__[1], __B__U_G__[2], __B__U_G__[3], __B__U_G__[4])
    end
    for __B_ug_, B_UG_ in ipairs(BuG) do
        local __B_U__g_ = b_u_G[B_UG_]["tint"]
        _B__u__g__(__B_U__g_, __bU_G, 1)
        _B__u__g__(__B_U__g_, Bu_g_, 2)
        _B__u__g__(__B_U__g_, b_U__g_, 3)
        _B__u__g__(__B_U__g_, B_U__g__, 4)
        if b_u_G[B_UG_]["texture"] == "hh_ui_icon.tex" then
            b_u_G[B_UG_]:SetTint(__B_U__g_[1], __B_U__g_[2], __B_U__g_[3], __B_U__g_[4])
        end
    end
end
function B_u__g:UpdateIconImg(_b_U__G, B__U__G__, b_u__G_)
    if
        not self["hh_main_ui"] or not self["hh_main_ui"]["hh_hoverer_ui"] or not b_u_g__:IsHHType(_b_U__G, "number") or
            not b_u_g__:IsHHType(B__U__G__, "number") or
            not BuG[_b_U__G]
     then
        return
    end
    local __B__U_G = 45
    local _b__ug_ = {255, 255, 255, 10}
    if
        self["hh_config"] and b_u_g__:IsHHType(self["hh_config"]["frame_config"], "table") and
            b_u_g__:IsHHType(self["hh_config"]["frame_config"][1], "number") and
            b_u_g__:IsHHType(self["hh_config"]["frame_config"][2], "number") and
            b_u_g__:IsHHType(Bu__g[self["hh_config"]["frame_config"][1]], "table") and
            b_u_g__:IsHHType(Bu__g[self["hh_config"]["frame_config"][1]]["color"], "table") and
            B__U__G__ == 1
     then
        __B__U_G = 6
        _b__ug_ = Bu__g[self["hh_config"]["frame_config"][1]]["color"]
        _b__ug_[4] = self["hh_config"]["frame_config"][2]
    end
    if not b_u_g__:IsHHType(self["hh_config"]["icon_config"], "table") then
        self["hh_config"]["icon_config"] = {1, 1, 1, 1}
    end
    local _Bu_G_ = self["hh_main_ui"]["hh_hoverer_ui"]
    if b_u__G_ then
        for __b_uG__, __b_U__g_ in ipairs(BuG) do
            local _bU__G = 0
            local __b__ug, B_u__G = "images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"
            if B__U__G__ == 1 then
                _bU__G = (__b_uG__ - 1) * 90
            end
            if B__U__G__ ~= 1 and __b__U_g_[B__U__G__] and __b__U_g_[B__U__G__]["xml"] and __b__U_g_[B__U__G__]["tex"] then
                __b__ug, B_u__G = __b__U_g_[B__U__G__]["xml"], __b__U_g_[B__U__G__]["tex"]
            end
            if _Bu_G_[__b_U__g_] and _Bu_G_[__b_U__g_]["SetTexture"] then
                _Bu_G_[__b_U__g_]:SetTexture(__b__ug, B_u__G)
                _Bu_G_[__b_U__g_]:SetRotation(_bU__G)
                _Bu_G_[__b_U__g_]:SetTint(_b__ug_[1] / 255, _b__ug_[2] / 255, _b__ug_[3] / 255, _b__ug_[4] / 10)
                _Bu_G_[__b_U__g_]:SetSize(__B__U_G, __B__U_G)
            end
        end
        self["hh_config"]["icon_config"] = {B__U__G__, B__U__G__, B__U__G__, B__U__G__}
    else
        local _B__U__G__ = BuG[_b_U__G] or "hh_icon_left_up"
        if _Bu_G_[_B__U__G__] and _Bu_G_[_B__U__G__]["SetTexture"] then
            local _Bu__G__ = 0
            local _B__U__G_, b_u__g = "images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"
            if B__U__G__ == 1 then
                _Bu__G__ = (_b_U__G - 1) * 90
            end
            if B__U__G__ ~= 1 and __b__U_g_[B__U__G__] and __b__U_g_[B__U__G__]["xml"] and __b__U_g_[B__U__G__]["tex"] then
                _B__U__G_, b_u__g = __b__U_g_[B__U__G__]["xml"], __b__U_g_[B__U__G__]["tex"]
            end
            _Bu_G_[_B__U__G__]:SetTexture(_B__U__G_, b_u__g)
            _Bu_G_[_B__U__G__]:SetRotation(_Bu__G__)
            _Bu_G_[_B__U__G__]:SetTint(_b__ug_[1] / 255, _b__ug_[2] / 255, _b__ug_[3] / 255, _b__ug_[4] / 10)
            _Bu_G_[_B__U__G__]:SetSize(__B__U_G, __B__U_G)
            self["hh_config"]["icon_config"][_b_U__G] = B__U__G__
        end
    end
end
function B_u__g:CreateHovererUi()
    if not self["hh_main_ui"] then
        return
    end
    b_u_g__:HHKillChild(self["hh_main_ui"], "hh_hoverer_ui")
    local _Bu_g_, B__uG = 200, 200
    local bu__g = self["hh_main_ui"]
    bu__g["hh_hoverer_ui"] =
        b_u_g__:HHCreateImageUi(bu__g, "images/global.xml", "square.tex", Vector3(-500, 0, 1), _Bu_g_, B__uG)
    local B_Ug_ = 6
    local Bu__G, __Bu_g_ = _Bu_g_ / 2 + B_Ug_ / 2, B__uG / 2 + B_Ug_ / 2
    local _B_U_G__, b__uG_ = _Bu_g_ + B_Ug_ * 2, B__uG + B_Ug_ * 2
    __b_UG_(bu__g["hh_hoverer_ui"], "hh_frame_left", Vector3(-Bu__G, 0, 1), B_Ug_, b__uG_)
    __b_UG_(bu__g["hh_hoverer_ui"], "hh_frame_right", Vector3(Bu__G, 0, 1), B_Ug_, b__uG_)
    __b_UG_(bu__g["hh_hoverer_ui"], "hh_frame_up", Vector3(0, __Bu_g_, 1), _B_U_G__, B_Ug_)
    __b_UG_(bu__g["hh_hoverer_ui"], "hh_frame_down", Vector3(0, -__Bu_g_, 1), _B_U_G__, B_Ug_)
    _b_u_G(bu__g["hh_hoverer_ui"], "hh_icon_left_up", Vector3(-Bu__G, __Bu_g_, 1), B_Ug_)
    _b_u_G(bu__g["hh_hoverer_ui"], "hh_icon_left_down", Vector3(-Bu__G, -__Bu_g_, 1), B_Ug_, 270)
    _b_u_G(bu__g["hh_hoverer_ui"], "hh_icon_right_up", Vector3(Bu__G, __Bu_g_, 1), B_Ug_, 90)
    _b_u_G(bu__g["hh_hoverer_ui"], "hh_icon_right_down", Vector3(Bu__G, -__Bu_g_, 1), B_Ug_, 180)
end
function B_u__g:CreatBlackUi()
    self["black"] = self["root"]:AddChild(__b_u__G_("images/global.xml", "square.tex"))
    self["black"]:SetVRegPoint(ANCHOR_MIDDLE)
    self["black"]:SetHRegPoint(ANCHOR_MIDDLE)
    self["black"]:SetVAnchor(ANCHOR_MIDDLE)
    self["black"]:SetHAnchor(ANCHOR_MIDDLE)
    self["black"]:SetScaleMode(SCALEMODE_FILLSCREEN)
    self["black"]:SetTint(0, 0, 0, 0.5)
    self["black"]["OnMouseButton"] = function()
    end
end
return B_u__g
