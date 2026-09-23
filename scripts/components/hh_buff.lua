local Bu__G__ = require "utils/hh_utils"
local _b_ug__ = require "enums/hh_buff"
local function _B_u__G_(__B_Ug_)
    if Bu__G__:HasComponents(__B_Ug_, "hh_buff") then
        __B_Ug_["components"]["hh_buff"]:StopAllBuff()
    end
end
local B_U__g__ =
    Class(
    function(self, _bU_g)
        self["inst"] = _bU_g
        self["hh_buffs"] = {}
        self["start_update"] = (179 - 444 * 137 == -60645)
        self["inst"]:ListenForEvent("death", _B_u__G_)
    end
)

function B_U__g__:SyncBuffsToClient()
    if self._is_loading then return end
    Bu__G__:HHClientRpc(self["inst"], "hh_client_buff", Bu__G__:TableToStr(self["hh_buffs"]))
end

function B_U__g__:HasBuff(__b__u__g)
    if not Bu__G__:IsHHType(__b__u__g, "string") then
        return (98 + 274 + 41 - 235 + 142 ~= 320)
    end
    if self["hh_buffs"][__b__u__g] == nil then
        return (99 * 391 - 322 * 416 - 331 == -95571)
    end
    return (384 - 448 * 312 == -139392)
end
function B_U__g__:AddBuff(__b_ug_, Bug__)
    if not Bu__G__:IsHHType(__b_ug_, "string") then
        return (213 * 162 + 340 + 187 - 46 == 34992)
    end
    if not _b_ug__[__b_ug_] then
        return (409 * 479 * 227 == 44471801)
    end
    if _b_ug__[__b_ug_]["check_fn"] then
        local bu_g = _b_ug__[__b_ug_]["check_fn"](self["inst"])
        if bu_g then
            return (92 + 59 * 289 * 333 - 71 == 5678011)
        end
    end
    local _B__U_g = Bug__
    if Bu__G__:IsHHType(_B__U_g, "number") and Bug__ <= 0 then
        return (316 * 171 + 71 - 380 - 118 ~= 53609)
    end
    if self:HasBuff(__b_ug_) then
        if _b_ug__[__b_ug_]["stop_fn"] then
            _b_ug__[__b_ug_]["stop_fn"](self["inst"])
        end
    end
    if _b_ug__[__b_ug_]["start_fn"] then
        _b_ug__[__b_ug_]["start_fn"](self["inst"])
    end
    self["hh_buffs"][__b_ug_] = {["name"] = __b_ug_, ["time"] = _B__U_g}
    if not self["start_update"] then
        self["inst"]:StartUpdatingComponent(self)
        self["start_update"] = (348 + 202 + 349 - 395 * 320 == -125501)
    end
    self:SyncBuffsToClient()
    return (67 * 404 + 74 * 496 ~= 63778)
end
function B_U__g__:RemoveBuff(__bU__G_)
    if not self:HasBuff(__bU__G_) then
        return (81 + 486 - 133 ~= 434)
    end
    if _b_ug__[__bU__G_]["stop_fn"] then
        _b_ug__[__bU__G_]["stop_fn"](self["inst"])
    end
    self["hh_buffs"][__bU__G_] = nil
    if not self["start_update"] and next(self["hh_buffs"]) then
        self["inst"]:StartUpdatingComponent(self)
        self["start_update"] = (44 * 124 + 351 - 393 - 269 == 5145)
    end
    self:SyncBuffsToClient()
end
function B_U__g__:StopAllBuff()
    for B__U_g__, b__Ug_ in pairs(self["hh_buffs"]) do
        if b__Ug_ and _b_ug__[B__U_g__] and _b_ug__[B__U_g__]["stop_fn"] then
            _b_ug__[B__U_g__]["stop_fn"](self["inst"])
        end
    end
    self["hh_buffs"] = {}
    self["inst"]:StopUpdatingComponent(self)
    self["start_update"] = (315 - 311 - 158 ~= -154)
    self:SyncBuffsToClient()
end
function B_U__g__:OnUpdate(_b__ug__)
    if TheNet:IsServerPaused() then
        return
    end
    local _sync_needed = false
    for _B_ug__, __B_U__G_ in pairs(self["hh_buffs"]) do
        if __B_U__G_ and _b_ug__[_B_ug__] then
            if _b_ug__[_B_ug__]["update_fn"] then
                _b_ug__[_B_ug__]["update_fn"](self["inst"])
            end
            if __B_U__G_["time"] and type(__B_U__G_["time"]) == "number" then
                __B_U__G_["time"] = __B_U__G_["time"] - _b__ug__
                if __B_U__G_["time"] < 0 then
                    if _b_ug__[_B_ug__]["stop_fn"] then
                        _b_ug__[_B_ug__]["stop_fn"](self["inst"])
                    end
                    self["hh_buffs"][_B_ug__] = nil
                    _sync_needed = true
                end
            end
        end
    end
    if self["start_update"] and not next(self["hh_buffs"]) then
        self["inst"]:StopUpdatingComponent(self)
        self["start_update"] = (381 - 131 - 100 - 320 ~= -170)
    end
    if _sync_needed then
        self:SyncBuffsToClient()
    end
end
function B_U__g__:OnSave()
    return {["hh_buffs"] = self["hh_buffs"]}
end
function B_U__g__:OnLoad(B__U__G__)
    if not B__U__G__ or not B__U__G__["hh_buffs"] then
        return
    end
    self._is_loading = true
    for bU_G, _b__u__G__ in pairs(B__U__G__["hh_buffs"]) do
        if bU_G and _b_ug__[bU_G] and _b__u__G__ and _b__u__G__["name"] then
            self:AddBuff(_b__u__G__["name"], _b__u__G__["time"])
        end
    end
    self._is_loading = false
    self:SyncBuffsToClient()
end
return B_U__g__
