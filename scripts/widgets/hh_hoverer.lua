local Theme = require("ttk_hover_theme")
local __BUG = require "widgets/widget"
local BuG = require "widgets/text"
local Bu__g = require "widgets/image"
local __b__U_g_ = require "widgets/imagebutton"
local __b_U_g_ = require "utils/hh_utils"
local __b_UG_ = require "enums/hh_hoverer"
local _b_u_G, _B__u__g__ = "images/global.xml", "square.tex"
local _b__Ug = 30
local B_u__g = 20
local B__uG__ = 15
local __b__U_g__ = 0
local _b_U_g
local _bU_G_ = 22
local _b_ug_ = 22

-- Reuse the existing high-saturation palette already used by the mod's
-- hover/element visuals. These colours are presentation-only on the client.
local DUNGEON_HOVER_NEON_BLUE = {0 / 255, 101 / 255, 255 / 255, 1}
local DUNGEON_HOVER_ORANGE = {255 / 255, 102 / 255, 0 / 255, 1}
local DUNGEON_HOVER_RED = {255 / 255, 11 / 255, 0 / 255, 1}

local DUNGEON_HOVER_RANK_COLORS = {
    E = DUNGEON_HOVER_NEON_BLUE,
    D = DUNGEON_HOVER_NEON_BLUE,
    C = DUNGEON_HOVER_ORANGE,
    B = DUNGEON_HOVER_ORANGE,
    A = DUNGEON_HOVER_RED,
    S = DUNGEON_HOVER_RED,
}

local DUNGEON_HOVER_PARTY_COLORS = {
    [2] = DUNGEON_HOVER_NEON_BLUE,
    [3] = DUNGEON_HOVER_ORANGE,
    [4] = DUNGEON_HOVER_RED,
}

local function ApplyDungeonHoverColors(target, hover_data)
    if target == nil or target["prefab"] ~= "dungeon_gate" or type(hover_data) ~= "table" then
        return
    end

    local info_data = hover_data["hh_99_special_01"]
    if info_data ~= nil and type(info_data["str"]) == "string" then
        local rank = string.match(info_data["str"], "^Hầm Ngục hạng ([EDCBAS])$")
        if rank ~= nil then
            info_data["str_color"] = DUNGEON_HOVER_RANK_COLORS[rank]
        end
    end

    local party_data = hover_data["hh_99_special_02"]
    if party_data ~= nil and type(party_data["str"]) == "string" then
        local party_size = tonumber(string.match(party_data["str"], "^(%d+) thợ săn$"))
        local party_color = party_size ~= nil and DUNGEON_HOVER_PARTY_COLORS[party_size] or nil
        if party_color ~= nil then
            party_data["str_color"] = party_color
        end
    end

    local hunter_rank_data = hover_data["hh_99_special_03"]
    if hunter_rank_data ~= nil and type(hunter_rank_data["str"]) == "string" then
        local rank = string.match(hunter_rank_data["str"], "^Thợ Săn hạng ([EDCBAS])$")
        if rank ~= nil then
            hunter_rank_data["str_color"] = DUNGEON_HOVER_RANK_COLORS[rank]
        end
    end
end

local function HHRainbowHSV(h)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local q = 1 - f
    i = i % 6
    if i == 0 then return 1, f, 0 elseif i == 1 then return q, 1, 0 elseif i == 2 then return 0, 1, f elseif i == 3 then return 0, q, 1 elseif i == 4 then return f, 0, 1 else return 1, 0, q end
end
local B__UG_ = {"hh_icon_left_up", "hh_icon_right_up", "hh_icon_right_down", "hh_icon_left_down"}
local BU_G__ = TUNING["HH_COLOR_CONFIG"] or {}
local __b_u_G__ = TUNING["HH_ICON_CONFIG"] or {}
local function _bu__G__()
    local _b_uG = TheInput:GetHUDEntityUnderMouse()
    _b_uG =
        (_b_uG and _b_uG["widget"] and _b_uG["widget"]["parent"] and _b_uG["widget"]["parent"]["item"]) or
        TheInput:GetWorldEntityUnderMouse() or
        nil
    return _b_uG
end
local function __B_UG__(B__UG, __b_Ug, _b__Ug_)
    if __b_U_g_:IsHHType(__b_Ug, "number") and __b_U_g_:IsHHType(B__UG, "table") and B__UG[_b__Ug_] then
        B__UG[_b__Ug_] = __b_Ug
    end
end
local function _B_Ug_()
    local B__u__g_ = {["back_ground_config"] = {7, 5}, ["frame_config"] = {31, 10}, ["icon_config"] = {1, 1, 1, 1}}
    if TheSim then
        TheSim:GetPersistentString(
            "hh_hoverer_config",
            function(__B__Ug_, _B__UG__)
                if __B__Ug_ and _B__UG__ ~= nil then
                    B__u__g_ = __b_U_g_:StrToTable(_B__UG__)
                end
            end
        )
    end
    return B__u__g_
end
local __b_u__g_ =
    Class(
    __BUG,
    function(self, __B_Ug_)
        __BUG["_ctor"](self, "hh_hoverer_ui")
        self["owner"] = __B_Ug_
        self["root"] = self:AddChild(__BUG "ROOT")
        self["root"]:SetVAnchor(ANCHOR_MIDDLE)
        self["root"]:SetHAnchor(ANCHOR_MIDDLE)
        self["root"]:SetPosition(0, 0, 0)
        self["root"]:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self["hh_config"] = _B_Ug_()
        self["hh_main"] = __b_U_g_:HHCreateImageUi(self, _b_u_G, _B__u__g__, Vector3(0, 0, 1), 10, 10, Theme.background)
        self["inst"]:ListenForEvent(
            "hh_hoverer_config",
            function()
                self["hh_config"] = _B_Ug_()
            end,
            self["owner"]
        )
        self["inst"]:ListenForEvent(
            "hh_update_hoverer",
            function()
                self:UpdateHoverer()
            end,
            self["owner"]
        )
        self:StartUpdating()
    end
)
function __b_u__g_:SetTargetName(_B_uG_)
    if __b_U_g_:IsHHType(_B_uG_, "string") then
        self["hh_hoverer_text"] = _B_uG_
    end
end
local function _b__U_g__(__B__u__G__, b__U_g)
    if b__U_g == "back_ground_config" then return Theme.background end
    if b__U_g == "frame_config" then return Theme.frame end
    local Bu_G_ = {244 / 255, 255 / 255, 0 / 255, 1}
    if
        __b_U_g_:IsHHType(__B__u__G__, "table") and __b_U_g_:IsHHType(__B__u__G__[b__U_g], "table") and
            __b_U_g_:IsHHType(__B__u__G__[b__U_g][1], "number") and
            __b_U_g_:IsHHType(__B__u__G__[b__U_g][2], "number")
     then
        local bu_g = __B__u__G__[b__U_g][1]
        local _Bu_g__ = __B__u__G__[b__U_g][2]
        if BU_G__[bu_g] and __b_U_g_:IsHHType(BU_G__[bu_g]["color"], "table") then
            Bu_G_[1] = BU_G__[bu_g]["color"][1] / 255
            Bu_G_[2] = BU_G__[bu_g]["color"][2] / 255
            Bu_G_[3] = BU_G__[bu_g]["color"][3] / 255
            Bu_G_[4] = _Bu_g__ / 10
        end
    end
    return Bu_G_
end
local function __bUg(B__u_g, bU__G, __bU_g, _b__uG, _Bu__g, __Bu_G__)
    if not B__u_g[bU__G] then
        B__u_g[bU__G] = B__u_g:AddChild(Bu__g("images/hh_icon/hh_ui_frame.xml", "hh_ui_frame.tex"))
    end
    B__u_g[bU__G]:SetPosition(__bU_g)
    local _B_U_G = _b__U_g__(__Bu_G__, "frame_config")
    B__u_g[bU__G]:SetTint(_B_U_G[1], _B_U_G[2], _B_U_G[3], _B_U_G[4])
    if bU__G == "hh_frame_left" or bU__G == "hh_frame_right" then
        B__u_g[bU__G]:SetRotation(90)
        B__u_g[bU__G]:SetSize(_Bu__g, _b__uG)
    else
        B__u_g[bU__G]:SetSize(_b__uG, _Bu__g)
    end
end
local function b__uG__(bug__, _b_ug__, _B__u__g, b_U_G_, B__Ug__, __Bu__G_)
    if not B__UG_[_b_ug__] then
        return
    end
    local b__u_g_ = B__UG_[_b_ug__]
    if
        not __b_U_g_:IsHHType(__Bu__G_, "table") or not __b_U_g_:IsHHType(__Bu__G_["icon_config"], "table") or
            not __b_U_g_:IsHHType(__Bu__G_["icon_config"][_b_ug__], "number") or
            not __b_U_g_:IsHHType(__b_u_G__[__Bu__G_["icon_config"][_b_ug__]], "table")
     then
        return
    end
    if not bug__[b__u_g_] then
        bug__[b__u_g_] = bug__:AddChild(Bu__g("images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex"))
    end
    local BU__G = __b_u_G__[__Bu__G_["icon_config"][_b_ug__]]
    bug__[b__u_g_]:SetPosition(_B__u__g)
    if __Bu__G_["icon_config"][_b_ug__] == 1 then
        bug__[b__u_g_]:SetTexture("images/hh_icon/hh_ui_icon.xml", "hh_ui_icon.tex")
        local __BU_g = Theme.corner
        bug__[b__u_g_]:SetTint(__BU_g[1], __BU_g[2], __BU_g[3], __BU_g[4])
        bug__[b__u_g_]:SetSize(b_U_G_, b_U_G_)
        if __b_U_g_:IsHHType(B__Ug__, "number") then
            bug__[b__u_g_]:SetRotation(B__Ug__)
        end
    elseif BU__G["xml"] and BU__G["tex"] then
        bug__[b__u_g_]:SetTexture(BU__G["xml"], BU__G["tex"])
        bug__[b__u_g_]:SetTint(1, 1, 1, 1)
        bug__[b__u_g_]:SetSize(30, 30)
        bug__[b__u_g_]:SetRotation(0)
    end
end
local function Bu__G__(b_Ug__, __buG__)
    if not (b_Ug__ and b_Ug__["GetSize"]) then
        return
    end
    local _b__uG__, _B_U__G__ = b_Ug__:GetSize()
    local B_u_G_ = TheInput:GetScreenPosition()
    local __b_Ug__, _BU__G_ = TheSim:GetScreenSize()
    local __b__u_G_, B_uG_ = 0, _B_U__G__ / 2
    local _BU_g__ = 100
    local _bUG__, _Bug__ = _BU_g__, __b_Ug__ - _BU_g__
    local __bU__G, B__U__G = _BU_g__, _BU__G_ - _BU_g__
    if B_u_G_["y"] > _BU__G_ / 2 or B_u_G_["y"] + _B_U__G__ > B__U__G then
        B_uG_ = -B_uG_
    end
    local _BUG = 0
    if B_u_G_["x"] < __b_Ug__ / 2 and B_u_G_["x"] - _bUG__ < _b__uG__ / 2 then
        _BUG = _b__uG__ / 2
    elseif B_u_G_["x"] > __b_Ug__ / 2 and _Bug__ - B_u_G_["x"] < _b__uG__ / 2 then
        _BUG = -_b__uG__ / 2
    end
    __b__u_G_ = __b__u_G_ + _BUG
    b_Ug__:SetPosition(__b__u_G_, B_uG_, 1)
    local b_UG__ = _b__U_g__(__buG__, "back_ground_config")
    if b_Ug__["SetTint"] then
        b_Ug__:SetTint(b_UG__[1], b_UG__[2], b_UG__[3], b_UG__[4])
    end
end
function __b_u__g_:UpdateHoverer()
    if not self["owner"] or not self["hh_main"] then
        return
    end
    local _b_U__g__ = _bu__G__()
    if
        not _b_U__g__ or not _b_U__g__["GUID"] or not _b_U__g__["prefab"] or not _b_U__g__["components"] or
            _b_U__g__:HasTag "boat"
     then
        self["hh_main"]:Hide()
        self["hh_main"]:SetSize(10, 10)
        self["inst_more_info"] = nil
        return
    end
    if self["hh_main"]["shown"] then
        Bu__G__(self["hh_main"], self["hh_config"])
    end
    local Bu__g__ = self["owner"]["hh_hoverer_list"]
    if not __b_U_g_:IsHHType(Bu__g__, "table") then
        return
    end
    ApplyDungeonHoverColors(_b_U__g__, Bu__g__)
    if Bu__g__["hh_01_name"] and Bu__g__["hh_01_name"]["str"] then
        Bu__g__["hh_01_name"]["str"] = tostring(self["hh_target_name"])
    end
    local b__UG = __b_U_g_:HHCompareTable(self["inst_more_info"], Bu__g__)
    if b__UG then
        return
    end
    self["inst_more_info"] = Bu__g__
    local _b__u_g = 0
    local _buG__ = 0
    local __b__U__G__ = {}
    local __b_u_g = self["hh_main"]
    local __B_U_g_ = __b_U_g_:TableSortKeys(__b_UG_)
    for hh_dynamic_key in pairs(Bu__g__) do
        if __b_UG_[hh_dynamic_key] == nil and string.match(hh_dynamic_key, "^hh_99_special_%d+$") then table.insert(__B_U_g_, hh_dynamic_key) end
    end
    table.sort(__B_U_g_)
    for __B__u__g__, _B_u_g__ in ipairs(__B_U_g_) do
        if __b_UG_[_B_u_g__] == nil and string.match(_B_u_g__, "^hh_99_special_%d+$") then
            __b_UG_[_B_u_g__] = {bool = true, name = "Đặc thù:", name_color = {1, 0.84, 0, 1}, str = "", format = "%s", str_color = {1, 1, 1, 1}}
        end
        if
            Bu__g__[_B_u_g__] and Bu__g__[_B_u_g__]["bool"] == (135 + 174 + 140 - 131 * 411 ~= -53384) and
                __b_UG_[_B_u_g__]
         then
            local __b_ug = __b_UG_[_B_u_g__]["text_scale"] or _bU_G_
            local bUG = Bu__g__[_B_u_g__]["name"] or __b_UG_[_B_u_g__]["name"] or "Prefix is ​​not defined"
            local _b_UG_ = Bu__g__[_B_u_g__]["name_color"] or __b_UG_[_B_u_g__]["name_color"] or {1, 1, 1, 1}
            local __bU_G = Bu__g__[_B_u_g__]["str"] or "Unfinished suffix"
            local Bu_g_ = Bu__g__[_B_u_g__]["str_color"] or __b_UG_[_B_u_g__]["str_color"] or {1, 1, 1, 1}
            if not __b_u_g["hh_body_" .. _B_u_g__] then
                __b_u_g["hh_body_" .. _B_u_g__] =
                    __b_U_g_:HHCreateTextUi(__b_u_g, Vector3(0, 0, 1), "", {1, 1, 1, 1}, __b_ug)
            end
            if not __b_u_g["hh_body_" .. _B_u_g__]["hh_str"] then
                __b_u_g["hh_body_" .. _B_u_g__]["hh_str"] =
                    __b_U_g_:HHCreateTextUi(
                    __b_u_g["hh_body_" .. _B_u_g__],
                    Vector3(0, 0, 1),
                    "",
                    {1, 1, 1, 1},
                    __b_ug,
                    (false or false and false or not true or not false and not true and not false or
                        not false and not false)
                )
            end
            __b_u_g["hh_body_" .. _B_u_g__]:SetString(bUG)
            __b_u_g["hh_body_" .. _B_u_g__]:SetColour(Theme.label)
            __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]:SetString(__bU_G)
            __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]:SetColour(Theme.Readable(Bu_g_))
            local hh_rainbow_text = __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]
            if hh_rainbow_text._hh_rainbow_task ~= nil then hh_rainbow_text._hh_rainbow_task:Cancel() hh_rainbow_text._hh_rainbow_task = nil end
            if Bu__g__[_B_u_g__]["rainbow"] == true and hh_rainbow_text.inst ~= nil then
                hh_rainbow_text._hh_rainbow_task = hh_rainbow_text.inst:DoPeriodicTask(0, function()
                    local r, g, b = HHRainbowHSV((GetTime() * 0.35) % 1)
                    hh_rainbow_text:SetColour(Theme.Readable({r, g, b, 1}))
                end)
            end
            local b_U__g_, B_U__g__ = __b_u_g["hh_body_" .. _B_u_g__]:GetRegionSize()
            local b_u_G, __b_U__G__ = __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]:GetRegionSize()
            __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]:SetPosition(
                b_U__g_ / 2 + b_u_G / 2,
                B_U__g__ / 2 - __b_U__G__ / 2
            )
            __b_U_g_:HHKillChild(__b_u_g["hh_body_" .. _B_u_g__]["hh_str"], "hh_child_ui")
            local __bu__G_, __B_Ug__ = 0, 0
            if
                Bu__g__[_B_u_g__]["child_ui"] and type(Bu__g__[_B_u_g__]["child_ui"]) == "table" and
                    #Bu__g__[_B_u_g__]["child_ui"] > 0
             then
                __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]["hh_child_ui"] =
                    __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]:AddChild(Bu__g())
                local _B__u_g__ = __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]["hh_child_ui"]
                _B__u_g__:SetPosition(-b_u_G / 2, -__b_U__G__ / 2, 1)
                local _bug = 0
                for _b_U__g_, __B__U_G__ in ipairs(Bu__g__[_B_u_g__]["child_ui"]) do
                    if __b_U_g_:IsHHType(__B__U_G__, "table") then
                        local __B_ug_, B_UG_ = 0, 0
                        local __B_U__g_, _b_U__G = 0
                        if __B__U_G__["tex"] and __B__U_G__["xml"] then
                            _B__u_g__["hh_image_" .. _b_U__g_] =
                                __b_U_g_:HHCreateImageUi(
                                _B__u_g__,
                                __B__U_G__["xml"],
                                __B__U_G__["tex"],
                                Vector3(0, 0, 1),
                                _bU_G_,
                                _bU_G_
                            )
                            local B__U__G__, b_u__G_ = _B__u_g__["hh_image_" .. _b_U__g_]:GetSize()
                            _B__u_g__["hh_image_" .. _b_U__g_]:SetPosition(B__U__G__ / 2, _bug - b_u__G_ / 2, 1)
                            __B_ug_, B_UG_ = B__U__G__, b_u__G_
                        end
                        if __B__U_G__["desc"] then
                            _B__u_g__["hh_text_" .. _b_U__g_] =
                                __b_U_g_:HHCreateTextUi(
                                _B__u_g__,
                                Vector3(0, 0, 1),
                                __B__U_G__["desc"],
                                Theme.Readable(__B__U_G__["desc_color"]),
                                _bU_G_,
                                (494 * 435 + 411 - 263 * 426 ~= 103270)
                            )
                            local __B__U_G, _b__ug_ = _B__u_g__["hh_text_" .. _b_U__g_]:GetRegionSize()
                            _B__u_g__["hh_text_" .. _b_U__g_]:SetPosition(__B_ug_ + __B__U_G / 2, _bug - _b__ug_ / 2, 1)
                            __B_U__g_, _b_U__G = __B__U_G, _b__ug_
                        end
                        _bug = _bug - math["max"](B_UG_, _b_U__G)
                        __bu__G_ = math["max"](__bu__G_, __B_ug_ + __B_U__g_)
                        __B_Ug__ = __B_Ug__ + math["max"](B_UG_, _b_U__G)
                    end
                end
            end
            __b_U__G__ = __b_U__G__ + __B_Ug__
            if _B_u_g__ == "hh_01_name" then
                __b_u_g["hh_body_" .. _B_u_g__]["hh_str"]:SetPosition(
                    b_u_G / 2 - b_U__g_ / 2,
                    B_U__g__ / 2 - __b_U__G__ / 2
                )
            end
            _b__u_g = math["max"](_b__u_g, (b_U__g_ + b_u_G), (b_U__g_ + __bu__G_))
            _buG__ = _buG__ + math["max"](B_U__g__, __b_U__G__)
            local _bU__g_ = -B_U__g__ / 2
            if __b_U__G__ < B_U__g__ * 1.5 then
                _bU__g_ = -math["max"](B_U__g__, __b_U__G__) / 2
            end
            table["insert"](
                __b__U__G__,
                {
                    id = "hh_body_" .. _B_u_g__,
                    pos_x = b_U__g_ / 2,
                    pos_y = _bU__g_,
                    size_y = math["max"](B_U__g__, __b_U__G__)
                }
            )
        else
            __b_U_g_:HHKillChild(__b_u_g, "hh_body_" .. _B_u_g__)
        end
    end
    __b_U_g_:HHKillChild(__b_u_g, "hh_item_image")
    __b_u_g["hh_item_image"] = __b_u_g:AddChild(Bu__g())
    if __b_U_g_:HasReplica(_b_U__g__, "inventoryitem") then
        local _Bu_G_ = _bU_G_ * 2
        local __b_uG__ = _b_U__g__["replica"]["inventoryitem"]:GetAtlas()
        local __b_U__g_ = _b_U__g__["replica"]["inventoryitem"]:GetImage()
        if __b_uG__ and __b_U__g_ then
            __b_u_g["hh_item_image"]:SetTexture(__b_uG__, __b_U__g_)
            __b_u_g["hh_item_image"]:SetSize(_Bu_G_, _Bu_G_)
            if _b_U__g__["inv_image_bg"] and _b_U__g__["inv_image_bg"]["atlas"] and _b_U__g__["inv_image_bg"]["image"] then
                local B_u__G, _B__U__G__ = _b_U__g__["inv_image_bg"]["atlas"], _b_U__g__["inv_image_bg"]["image"]
                __b_u_g["hh_item_image"]:SetTexture(B_u__G, _B__U__G__)
                __b_u_g["hh_item_image"]:SetSize(_Bu_G_, _Bu_G_)
                if _b_U__g__:HasTag "spicedfood" then
                    local _Bu__G__, _B__U__G_ =
                        _b_U__g__["replica"]["inventoryitem"]:GetAtlas(),
                        _b_U__g__["replica"]["inventoryitem"]:GetImage()
                    if _Bu__G__ and _B__U__G_ then
                        __b_u_g["hh_item_image"]["hh_spiced_image"] = __b_u_g["hh_item_image"]:AddChild(Bu__g())
                        __b_u_g["hh_item_image"]["hh_spiced_image"]:SetTexture(_Bu__G__, _B__U__G_)
                        __b_u_g["hh_item_image"]["hh_spiced_image"]:SetSize(_Bu_G_, _Bu_G_)
                    end
                end
            end
            local _bU__G, __b__ug = __b_u_g["hh_item_image"]:GetSize()
            _b__u_g = _b__u_g + _bU__G
        end
    end
    local _BU__g__, _B__u_g_ = -_b__u_g / 2, _buG__ / 2 - 5
    for b_u__g, _Bu_g_ in ipairs(__b__U__G__) do
        local B__uG = _Bu_g_["id"]
        if B__uG and __b_u_g[B__uG] and _Bu_g_["pos_x"] and _Bu_g_["pos_y"] then
            local bu__g, B_Ug_ = _Bu_g_["pos_x"], _Bu_g_["pos_y"]
            local Bu__G = _Bu_g_["size_y"] or 0
            __b_u_g[B__uG]:SetPosition(_BU__g__ + bu__g, _B__u_g_ + B_Ug_ / 2, 1)
            _B__u_g_ = _B__u_g_ - Bu__G
        end
    end
    if __b_u_g["hh_item_image"] then
        local __Bu_g_, _B_U_G__ = __b_u_g["hh_item_image"]:GetSize()
        __b_u_g["hh_item_image"]:SetPosition(_b__u_g / 2 - __Bu_g_ / 2, _buG__ / 2 - _B_U_G__ / 2, 1)
    end
    _b__u_g = _b__u_g + _b_ug_
    _buG__ = _buG__ + _b_ug_
    self["hh_main"]:SetSize(_b__u_g, _buG__)
    self["hh_main"]:Show()
    local _B__UG_ = 3
    local __BU__G, bu__g__ = _b__u_g / 2 + _B__UG_ / 2, _buG__ / 2 + _B__UG_ / 2
    local __B_U_G_, _BUg__ = _b__u_g + _B__UG_ * 2, _buG__ + _B__UG_ * 2
    __bUg(self["hh_main"], "hh_frame_left", Vector3(-__BU__G, 0, 1), _B__UG_, _BUg__, self["hh_config"])
    __bUg(self["hh_main"], "hh_frame_right", Vector3(__BU__G, 0, 1), _B__UG_, _BUg__, self["hh_config"])
    __bUg(self["hh_main"], "hh_frame_up", Vector3(0, bu__g__, 1), __B_U_G_, _B__UG_, self["hh_config"])
    __bUg(self["hh_main"], "hh_frame_down", Vector3(0, -bu__g__, 1), __B_U_G_, _B__UG_, self["hh_config"])
    b__uG__(self["hh_main"], 1, Vector3(-__BU__G, bu__g__, 1), _B__UG_, nil, self["hh_config"])
    b__uG__(self["hh_main"], 2, Vector3(__BU__G, bu__g__, 1), _B__UG_, 90, self["hh_config"])
    b__uG__(self["hh_main"], 3, Vector3(__BU__G, -bu__g__, 1), _B__UG_, 180, self["hh_config"])
    b__uG__(self["hh_main"], 4, Vector3(-__BU__G, -bu__g__, 1), _B__UG_, 270, self["hh_config"])
    Bu__G__(self["hh_main"], self["hh_config"])
end
function __b_u__g_:OnUpdate(b__uG_)
    if not self["owner"] or not self["hh_main"] then
        return
    end
    local B__u__g__ = _bu__G__()
    if
        not B__u__g__ or not B__u__g__["GUID"] or not B__u__g__["prefab"] or not B__u__g__["components"] or
            B__u__g__:HasTag "boat" or
            (B__u__g__:HasTag "NOBLOCK" and not B__u__g__:HasTag "monster" and B__u__g__["prefab"] ~= "abigail" and B__u__g__["prefab"] ~= "hh_macanh_shadow" and B__u__g__["prefab"] ~= "hh_hacanh_shadow")
     then
        self["hh_main"]:Hide()
        self["hh_main"]:SetSize(10, 10)
        self["inst_more_info"] = nil
        _b_U_g = nil
        return
    end
    if self["hh_main"]["shown"] then
        Bu__G__(self["hh_main"], self["hh_config"])
    end
    if not (B__u__g__ ~= _b_U_g or __b__U_g__ + 1 < GetTime() or self["hh_target_name"] ~= self["hh_hoverer_text"]) then
        return
    end
    _b_U_g = B__u__g__
    self["hh_target_name"] = self["hh_hoverer_text"]
    __b__U_g__ = GetTime()
    if
        TheInput:GetWorldEntityUnderMouse() == self["owner"] and
            __b_U_g_:HasComponents(self["owner"], "playercontroller")
     then
        local B_u_g__ = self["owner"]["components"]["playercontroller"]:GetLeftMouseAction()
        if not B_u_g__ then
            self["hh_main"]:Hide()
            return
        end
    end
    SendModRPCToServer(MOD_RPC["hh_rpc"]["hh_hoverer_server"], _b_U_g, self["hh_target_name"])
end
return __b_u__g_
