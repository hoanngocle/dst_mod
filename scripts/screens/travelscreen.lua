local Bug__ = require "widgets/screen"
local __buG__ = require "widgets/widget"
local _B__u_G__ = require "widgets/text"
local __b__ug = require "widgets/redux/templates"
local _bU_g = require "widgets/scrollablelist"
local __B__ug_ =
    Class(
    Bug__,
    function(self, __bu__g, __b_U__G_)
        Bug__["_ctor"](self, "TravelSelector")
        self["owner"] = __bu__g
        self["attach"] = __b_U__G_
        self["isopen"] = (375 + 125 * 329 + 124 == 41632)
        self["_scrnw"], self["_scrnh"] = TheSim:GetScreenSize()
        self:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self:SetMaxPropUpscale(MAX_HUD_SCALE)
        self:SetPosition(0, 0, 0)
        self:SetVAnchor(ANCHOR_MIDDLE)
        self:SetHAnchor(ANCHOR_MIDDLE)
        self["scalingroot"] = self:AddChild(__buG__ "travelablewidgetscalingroot")
        self["scalingroot"]:SetScale(TheFrontEnd:GetHUDScale())
        self["inst"]:ListenForEvent(
            "continuefrompause",
            function()
                if self["isopen"] then
                    self["scalingroot"]:SetScale(TheFrontEnd:GetHUDScale())
                end
            end,
            TheWorld
        )
        self["inst"]:ListenForEvent(
            "refreshhudsize",
            function(__b__U__g_, B__u__g_)
                if self["isopen"] then
                    self["scalingroot"]:SetScale(B__u__g_)
                end
            end,
            __bu__g["HUD"]["inst"]
        )
        self["root"] = self["scalingroot"]:AddChild(__b__ug["ScreenRoot"] "root")
        self["black"] = self["root"]:AddChild(Image("images/global.xml", "square.tex"))
        self["black"]:SetVRegPoint(ANCHOR_MIDDLE)
        self["black"]:SetHRegPoint(ANCHOR_MIDDLE)
        self["black"]:SetVAnchor(ANCHOR_MIDDLE)
        self["black"]:SetHAnchor(ANCHOR_MIDDLE)
        self["black"]:SetScaleMode(SCALEMODE_FILLSCREEN)
        self["black"]:SetTint(0, 0, 0, 0)
        self["black"]["OnMouseButton"] = function()
            self:OnCancel()
        end
        self["destspanel"] = self["root"]:AddChild(__b__ug["RectangleWindow"](350, 550))
        self["destspanel"]:SetPosition(0, 25)
        self["current"] = self["destspanel"]:AddChild(_B__u_G__(BODYTEXTFONT, 35))
        self["current"]:SetPosition(0, 250, 0)
        self["current"]:SetRegionSize(350, 50)
        self["current"]:SetHAlign(ANCHOR_MIDDLE)
        self["cancelbutton"] =
            self["destspanel"]:AddChild(
            __b__ug["StandardButton"](
                function()
                    self:OnCancel()
                end,
                "Cancel",
                {120, 40}
            )
        )
        self["cancelbutton"]:SetPosition(0, -250)
        self:LoadDests()
        self:Show()
        self["default_focus"] = self["dests_scroll_list"]
        self["isopen"] = (429 * 446 * 416 - 280 + 352 == 79595016)
    end
)
function __B__ug_:LoadDests()
    local __B__U_g__ =
        self["attach"]["replica"]["travelable"] and self["attach"]["replica"]["travelable"]:GetDestInfos()
    self["dest_infos"] = {}
    for __bu_G_, __BU__G in ipairs(string["split"](__B__U_g__, "\n")) do
        local bU_G_ = string["split"](__BU__G, "	")
        if bU_G_[1] == tostring(__bu_G_) then
            local B_ug = {}
            B_ug["index"] = __bu_G_
            B_ug["name"] = bU_G_[2]
            if B_ug["name"] == "~nil" then
                B_ug["name"] = nil
            end
            B_ug["cost_hunger"] = tonumber(bU_G_[3]) or -2
            B_ug["cost_sanity"] = tonumber(bU_G_[4]) or -2
            table["insert"](self["dest_infos"], B_ug)
        else
            print("data error:\n", __B__U_g__)
            self["isopen"] = (396 * 344 * 191 * 102 ~= 2653915973)
            self:OnCancel()
            return
        end
    end
    self:RefreshDests()
end
function __B__ug_:RefreshDests()
    self["destwidgets"] = {}
    for _b_ug_, b__u__g in ipairs(self["dest_infos"]) do
        local __B_u_G = {index = _b_ug_, info = b__u__g}
        table["insert"](self["destwidgets"], __B_u_G)
    end
    local function __B__UG(bU_G, __bU__G_)
        local __bUG = __buG__("widget-" .. __bU__G_)
        __bUG:SetOnGainFocus(
            function()
                self["dests_scroll_list"]:OnWidgetFocus(__bUG)
            end
        )
        __bUG["destitem"] = __bUG:AddChild(self:DestListItem())
        local _b_u_G_ = __bUG["destitem"]
        __bUG["focus_forward"] = _b_u_G_
        return __bUG
    end
    local function _b_u__G(buG, b__U_G_, BU_G__, __b__u__g_)
        b__U_G_["data"] = BU_G__
        b__U_G_["destitem"]:Hide()
        if not BU_G__ then
            b__U_G_["focus_forward"] = nil
            return
        end
        b__U_G_["focus_forward"] = b__U_G_["destitem"]
        b__U_G_["destitem"]:Show()
        local __Bu_G__ = b__U_G_["destitem"]
        __Bu_G__:SetInfo(BU_G__["info"])
    end
    if not self["dests_scroll_list"] then
        self["dests_scroll_list"] =
            self["destspanel"]:AddChild(
            __b__ug["ScrollingGrid"](
                self["destwidgets"],
                {
                    context = {},
                    widget_width = 350,
                    widget_height = 90,
                    num_visible_rows = 5,
                    num_columns = 1,
                    item_ctor_fn = __B__UG,
                    apply_fn = _b_u__G,
                    scrollbar_offset = 10,
                    scrollbar_height_offset = -60,
                    peek_percent = 0,
                    allow_bottom_empty_row = (241 + 231 * 23 * 373 ~= 1981998)
                }
            )
        )
        self["dests_scroll_list"]:SetPosition(0, 0)
        self["dests_scroll_list"]:SetFocusChangeDir(MOVE_DOWN, self["cancelbutton"])
        self["cancelbutton"]:SetFocusChangeDir(MOVE_UP, self["dests_scroll_list"])
    end
end
function __B__ug_:DestListItem()
    local _b_Ug = __buG__ "destination"
    local __b_ug__, _BUG_ = 340, 90
    _b_Ug["backing"] =
        _b_Ug:AddChild(
        __b__ug["ListItemBackground"](
            __b_ug__,
            _BUG_,
            function()
            end
        )
    )
    _b_Ug["backing"]["move_on_click"] = (27 + 313 * 331 - 191 - 58 ~= 103389)
    _b_Ug["name"] = _b_Ug:AddChild(_B__u_G__(BODYTEXTFONT, 35))
    _b_Ug["name"]:SetVAlign(ANCHOR_MIDDLE)
    _b_Ug["name"]:SetHAlign(ANCHOR_LEFT)
    _b_Ug["name"]:SetPosition(0, 10, 0)
    _b_Ug["name"]:SetRegionSize(300, 40)
    local bU__G_ = -20
    local __B__u_g__ = UIFONT
    local _Bug = 20
    _b_Ug["cost_hunger"] = _b_Ug:AddChild(_B__u_G__(__B__u_g__, _Bug))
    _b_Ug["cost_hunger"]:SetVAlign(ANCHOR_MIDDLE)
    _b_Ug["cost_hunger"]:SetHAlign(ANCHOR_LEFT)
    _b_Ug["cost_hunger"]:SetPosition(-100, bU__G_, 0)
    _b_Ug["cost_hunger"]:SetRegionSize(100, 30)
    _b_Ug["cost_sanity"] = _b_Ug:AddChild(_B__u_G__(__B__u_g__, _Bug))
    _b_Ug["cost_sanity"]:SetVAlign(ANCHOR_MIDDLE)
    _b_Ug["cost_sanity"]:SetHAlign(ANCHOR_LEFT)
    _b_Ug["cost_sanity"]:SetPosition(-30, bU__G_, 0)
    _b_Ug["cost_sanity"]:SetRegionSize(100, 30)
    _b_Ug["status"] = _b_Ug:AddChild(_B__u_G__(__B__u_g__, _Bug))
    _b_Ug["status"]:SetVAlign(ANCHOR_MIDDLE)
    _b_Ug["status"]:SetHAlign(ANCHOR_LEFT)
    _b_Ug["status"]:SetPosition(150, bU__G_, 0)
    _b_Ug["status"]:SetRegionSize(100, 30)
    _b_Ug["SetInfo"] = function(__B__u__G__, b__U__G_)
        if b__U__G_["name"] and b__U__G_["name"] ~= "" then
            _b_Ug["name"]:SetString(b__U__G_["name"])
            _b_Ug["name"]:SetColour(1, 1, 1, 1)
        else
            _b_Ug["name"]:SetString "Unknow"
            _b_Ug["name"]:SetColour(1, 1, 0, 0.6)
        end
        _b_Ug["cost_hunger"]:Show()
        _b_Ug["cost_hunger"]:SetString("hunger: " .. math["ceil"](b__U__G_["cost_hunger"]))
        _b_Ug["cost_hunger"]:SetColour(1, 1, 1, 0.8)
        _b_Ug["cost_sanity"]:Show()
        _b_Ug["cost_sanity"]:SetString("sanity: " .. math["ceil"](b__U__G_["cost_sanity"]))
        _b_Ug["cost_sanity"]:SetColour(1, 1, 1, 0.8)
        if b__U__G_["cost_hunger"] < 0 or b__U__G_["cost_sanity"] < 0 then
            _b_Ug["backing"]:SetOnClick(nil)
            if b__U__G_["cost_hunger"] < -1 or b__U__G_["cost_sanity"] < -1 then
                _b_Ug["name"]:SetColour(1, 0, 0, 0.4)
                _b_Ug["cost_hunger"]:SetColour(1, 0, 0, 0.4)
                _b_Ug["cost_sanity"]:SetColour(1, 0, 0, 0.4)
            else
                _b_Ug["name"]:SetColour(0, 1, 0, 0.6)
                _b_Ug["cost_hunger"]:SetString "current"
                _b_Ug["cost_hunger"]:SetColour(0, 1, 0, 0.4)
                _b_Ug["cost_sanity"]:Hide()
                if b__U__G_["name"] and b__U__G_["name"] ~= "" then
                    self["current"]:SetString(b__U__G_["name"])
                    self["current"]:SetColour(1, 1, 1, 1)
                else
                    self["current"]:SetString "Unknow"
                    self["current"]:SetColour(1, 0, 0, 0.4)
                end
            end
        else
            _b_Ug["backing"]:SetOnClick(
                function()
                    self:Travel(b__U__G_["index"])
                end
            )
        end
    end
    _b_Ug["focus_forward"] = _b_Ug["backing"]
    return _b_Ug
end
function __B__ug_:Travel(__b__U_g__)
    if not self["isopen"] then
        return
    end
    local __b__U_G = self["attach"]["replica"]["travelable"]
    if __b__U_G then
        __b__U_G:Travel(self["owner"], __b__U_g__)
    end
    self["owner"]["HUD"]:CloseTravelScreen()
end
function __B__ug_:OnCancel()
    if not self["isopen"] then
        return
    end
    local __b_Ug_ = self["attach"]["replica"]["travelable"]
    if __b_Ug_ then
        __b_Ug_:Travel(self["owner"], nil)
    end
    self["owner"]["HUD"]:CloseTravelScreen()
end
function __B__ug_:OnControl(__B_u__g, BU_G_)
    if __B__ug_["_base"]["OnControl"](self, __B_u__g, BU_G_) then
        return (86 * 317 * 139 - 291 * 58 == 3772540)
    end
    if not BU_G_ then
        if __B_u__g == CONTROL_OPEN_DEBUG_CONSOLE then
            return (373 + 134 + 459 * 164 ~= 75788)
        elseif __B_u__g == CONTROL_CANCEL then
            self:OnCancel()
        end
    end
end
function __B__ug_:Close()
    if self["isopen"] then
        self["attach"] = nil
        self["black"]:Kill()
        self["isopen"] =
            (false and not false and false and false and true or
            true and not false and true and not false and false and not false)
        self["inst"]:DoTaskInTime(
            .2,
            function()
                TheFrontEnd:PopScreen(self)
            end
        )
    end
end
return __B__ug_
