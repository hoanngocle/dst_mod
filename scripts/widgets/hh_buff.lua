local B_ug__ = require "widgets/widget"
local BU_g_ = require "widgets/text"
local b_Ug = require "widgets/image"
local _BUG = require "utils/hh_utils"
local buG = require "enums/hh_buff"
local B_UG, _BU_g__ = "images/hh_icon/hh_buff_icon.xml", "hh_buff_icon.tex"
local _B_U__G__ = 40
local __B__UG__ = 5
local _b_UG_, __BU__G_ = 0, -70
local __bu__g__ = 20
local __b__u__g__ = 2
local function __Bug_(_bU__G__)
    if _bU__G__ < 0 then
        return "00"
    elseif _bU__G__ < 10 then
        return "0" .. _bU__G__
    end
    return _bU__G__
end
local function _B_UG__(_B__U__g)
    local _b__u__g__ = math["floor"](_B__U__g / 60)
    local b__Ug_ = math["floor"](_B__U__g - (_b__u__g__ * 60))
    return string["format"]("%s:%s", __Bug_(_b__u__g__), __Bug_(b__Ug_))
end
local function _bu__g__(B_u_G__)
    local __b__U__G = {}
    if _BUG:HasComponents(B_u_G__, "hh_client") then
        local _BUg_ = B_u_G__["components"]["hh_client"]:GetValue "hh_client_buff"
        if _BUG:IsHHType(_BUg_, "table") then
            __b__U__G = _BUg_
        end
    end
    return __b__U__G
end
local function StartVisualCountdown(self)
    if not self['hh_visual_updating'] then
        self['hh_visual_updating'] = true
        self:StartUpdating()
    end
end
local function StopVisualCountdown(self)
    if self['hh_visual_updating'] then
        self['hh_visual_updating'] = false
        self:StopUpdating()
    end
end
local function RefreshVisualCountdown(self, _B_ug_, _b__U__g)
    local _b__U__G = self['hh_visual_timers'][_B_ug_]
    local _B__u__g = self[_B_ug_]
    if not _b__U__G or type(_b__U__g) ~= 'number' or not _B__u__g or not _B__u__g['hh_time'] then
        return
    end
    local _B__U__G = math['max'](0, math['ceil'](_b__U__g))
    if _b__U__G['last_displayed'] ~= _B__U__G then
        _B__u__g['hh_time']:SetString(tostring(_B_UG__(_B__U__G)))
        _b__U__G['last_displayed'] = _B__U__G
    end
end
local __bu_g =
    Class(
    B_ug__,
    function(self, _b_u_g)
        B_ug__["_ctor"](self, "hh_buffer_ui")
        self["owner"] = _b_u_g
        self:SetVAnchor(1)
        self:SetHAnchor(ANCHOR_MIDDLE)
        self:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self["hh_buff_table"] = {}
        self:HandleBuffUi()
        self["inst"]:ListenForEvent(
            "hh_client_buff",
            function(buG__, _b__UG_)
                self:HandleBuffUi()
            end,
            self["owner"]
        )
    end
)
function __bu_g:HandleBuffUi()
    self['hh_visual_timers'] = self['hh_visual_timers'] or {}
    local _snapshot_time = GetTime()
    local _has_timed_buff = false
    local B__u_g_ = self["hh_buff_table"]
    local _b_u_g_ = _bu__g__(self["owner"])
    if _b_u_g_ == nil or not _BUG:IsHHType(_b_u_g_) == "table" then
        return
    end
    for _B__uG, _b__uG in ipairs(B__u_g_) do
        if not buG[_b__uG] or not _b_u_g_[_b__uG] then
            _BUG:HHKillChild(self, _b__uG)
            self['hh_visual_timers'][_b__uG] = nil
        end
    end
    local _B_u__G = _BUG:TableSortKeys(_b_u_g_)
    self["hh_buff_table"] = _B_u__G
    for b__U__g__, _B_ug_ in ipairs(_B_u__G) do
        local __B__U__G__ = b__U__g__ - 1
        if buG[_B_ug_] then
            local _B__uG_ = __B__U__G__ % __B__UG__
            local __b_U_G_ = math["floor"](__B__U__G__ / __B__UG__)
            local b__U__G = tonumber(_b_u_g_[_B_ug_]["time"])
            if b__U__G then
                b__U__G = _B_UG__(math["ceil"](b__U__G))
            else
                b__U__G = " "
            end
            local _b__U__g = _b_u_g_[_B_ug_]['time']
            if type(_b__U__g) == 'number' then
                self['hh_visual_timers'][_B_ug_] = {
                    ['remaining_at_snapshot'] = _b__U__g,
                    ['snapshot_time'] = _snapshot_time,
                    ['last_displayed'] = nil
                }
                if _b__U__g > 0 then
                    _has_timed_buff = true
                end
            else
                self['hh_visual_timers'][_B_ug_] = nil
            end
            if self[_B_ug_] then
                local B_ug_ = self[_B_ug_]:GetPosition()
                local __b_u_G_, _b_U__G =
                    _b_UG_ + _B__uG_ * __b__u__g__ * _B_U__G__,
                    __BU__G_ - __b_U_G_ * _B_U__G__ * __b__u__g__
                if B_ug_["x"] ~= __b_u_G_ or B_ug_["y"] ~= _b_U__G then
                    self[_B_ug_]:MoveTo(B_ug_, Vector3(__b_u_G_, _b_U__G, 1), 0.5)
                end
            else
                self[_B_ug_] =
                    _BUG:HHCreateImageUi(
                    self,
                    B_UG,
                    _BU_g__,
                    Vector3(
                        _b_UG_ + _B__uG_ * _B_U__G__ * __b__u__g__,
                        __BU__G_ - __b_U_G_ * _B_U__G__ * __b__u__g__,
                        1
                    ),
                    50,
                    50
                )
                if buG[_B_ug_]["xml"] and buG[_B_ug_]["tex"] then
                    local __Bu__g__, __b_Ug_ = buG[_B_ug_]["xml"], buG[_B_ug_]["tex"]
                    self[_B_ug_]["buff_icon"] =
                        _BUG:HHCreateImageUi(self[_B_ug_], __Bu__g__, __b_Ug_, Vector3(0, 0, 1), _B_U__G__, _B_U__G__)
                end
                if buG[_B_ug_]["icon_text"] then
                    self[_B_ug_]["icon_text"] =
                        _BUG:HHCreateTextUi(
                        self[_B_ug_],
                        Vector3(0, 0, 1),
                        tostring(buG[_B_ug_]["icon_text"]),
                        nil,
                        __bu__g__
                    )
                end
                local b__u_g = buG[_B_ug_]["str"] or "Describe"
                self[_B_ug_]["OnGainFocus"] = function()
                    self[_B_ug_]["hh_desc"] =
                        _BUG:HHCreateTextUi(self[_B_ug_], Vector3(0, 0, 1), tostring(b__u_g), {1, 1, 1, 1}, __bu__g__)
                    self[_B_ug_]["hh_desc"]:MoveTo(Vector3(0, _B_U__G__ / 2, 1), Vector3(0, _B_U__G__, 1), 0.5)
                end
                self[_B_ug_]["OnLoseFocus"] = function()
                    _BUG:HHKillChild(self[_B_ug_], "hh_desc")
                end
                self[_B_ug_]["hh_time"] =
                    _BUG:HHCreateTextUi(
                    self[_B_ug_],
                    Vector3(0, -_B_U__G__ / 2 - __bu__g__ / 2, 1),
                    tostring(b__U__G),
                    {1, 1, 1, 1},
                    __bu__g__
                )
                local _bu_G__ = buG[_B_ug_]["name"] or "Unnamed"
                self[_B_ug_]["hh_text"] =
                    _BUG:HHCreateTextUi(
                    self[_B_ug_],
                    Vector3(0, _B_U__G__ / 2 + __bu__g__ / 2, 1),
                   tostring(_bu_G__),
                   {1, 1, 1, 1},
                   __bu__g__
               )
           end
            if type(_b__U__g) == 'number' then
                RefreshVisualCountdown(self, _B_ug_, _b__U__g)
            elseif self[_B_ug_] and self[_B_ug_]['hh_time'] then
                self[_B_ug_]['hh_time']:SetString(' ')
            end
        end
    end
    if _has_timed_buff then
        StartVisualCountdown(self)
    else
        StopVisualCountdown(self)
    end
end
function __bu_g:OnUpdate(_b__ug__)
    if TheNet:IsServerPaused() then
        return
    end
    local _B__u_g_ = self['hh_visual_timers']
    if not _B__u_g_ then
        StopVisualCountdown(self)
        return
    end
    local _b_u__G_ = GetTime()
    local _has_timed_buff = false
    for _B_ug_, __B_U__G_ in pairs(_B__u_g_) do
        if __B_U__G_ and type(__B_U__G_['remaining_at_snapshot']) == 'number' then
            local _b__U__G =
                __B_U__G_['remaining_at_snapshot'] - (_b_u__G_ - __B_U__G_['snapshot_time'])
            RefreshVisualCountdown(self, _B_ug_, _b__U__G)
            if _b__U__G > 0 then
                _has_timed_buff = true
            end
        end
    end
    if not _has_timed_buff then
        StopVisualCountdown(self)
    end
end
return __bu_g
