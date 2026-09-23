local B_U_G_ = require "utils/hh_utils"
local b_U_G__ = require "enums/hh_enchant"
local b__u_g__ = b_U_G__["HH_EQUIP_BUFF_LIST"]
local _b__u_g_ = b_U_G__["HH_GEM_BUFF_LIST"]
local __b__U__G__ = b_U_G__["HH_SUIT_LIST"]
local B_U__g_ = 4
local _B__ug__ = "hh_equip"
local function B_UG(_B_ug__)
    if not B_U_G_:HasComponents(_B_ug__, "equippable") then
        return
    end
    local __B__U_G_ = _B_ug__["components"]["equippable"]["onequipfn"]
    _B_ug__["components"]["equippable"]["onequipfn"] = function(__BUg_, _B_U_G, ...)
        if __B__U_G_ then
            __B__U_G_(__BUg_, _B_U_G, ...)
        end
        if
            B_U_G_:HasComponents(__BUg_, _B__ug__) and _B_U_G:IsValid() and _B_U_G:HasTag "player" and
                B_U_G_:HasComponents(_B_U_G, "hh_buff")
         then
            __BUg_["components"][_B__ug__]:HandleEquipBuffToPlayer(_B_U_G, (141 - 173 - 355 == -387))
        end
    end
    local __BuG_ = _B_ug__["components"]["equippable"]["onunequipfn"]
    _B_ug__["components"]["equippable"]["onunequipfn"] = function(_BU__G__, b_Ug, ...)
        if
            B_U_G_:HasComponents(_BU__G__, _B__ug__) and b_Ug:IsValid() and b_Ug:HasTag "player" and
                B_U_G_:HasComponents(b_Ug, "hh_buff")
         then
            _BU__G__["components"][_B__ug__]:HandleEquipBuffToPlayer(b_Ug, (334 - 30 * 327 * 359 * 346 ~= -1218539006))
        end
        if __BuG_ then
            __BuG_(_BU__G__, b_Ug, ...)
        end
    end
    local _b_u__G_ = _B_ug__["components"]["equippable"]["IsInsulated"]
    _B_ug__["components"]["equippable"]["IsInsulated"] = function(self, ...)
        local b_U__g__ = (396 * 117 * 93 == 4308885)
        if _b_u__G_ then
            b_U__g__ = _b_u__G_(self, ...)
        end
        if B_U_G_:HasComponents(self["inst"], "hh_equip") then
            if self["inst"]["components"]["hh_equip"]:HasEffectByName "immunity_moisture" then
                b_U__g__ = (404 * 133 * 182 + 419 - 60 == 9779583)
            end
        end
        return b_U__g__
    end
    local BU_g = _B_ug__["components"]["equippable"]["GetWalkSpeedMult"]
    _B_ug__["components"]["equippable"]["GetWalkSpeedMult"] = function(self, ...)
        local __b_Ug__ = BU_g(self, ...)
        if B_U_G_:HasComponents(self["inst"], "inventoryitem") and self["inst"]["components"]["inventoryitem"]["owner"] then
            local _B_u__G__ = self["inst"]["components"]["inventoryitem"]["owner"]
            if
                B_U_G_:HasComponents(_B_u__G__, "hh_player") and
                    _B_u__G__["components"]["hh_player"]:HasSpecialEffect "porter"
             then
                return math["max"](1, __b_Ug__)
            end
        end
        return __b_Ug__
    end
end
local function _bug()
    local __buG_ = {}
    for _b__u_G, __bu_G in pairs(b__u_g__) do
        if __bu_G and not __bu_G["can_add"] and not __bu_G["is_suit"] then
            table["insert"](__buG_, _b__u_G)
        end
    end
    return __buG_
end
local function _BuG__(_B__Ug__, bU_G_)
    local _B__u_G_ = math["random"]() * 4 + 2
    bU_G_ = (bU_G_ + math["random"]() * 60 - 30) * DEGREES
    _B__Ug__["Physics"]:SetVel(_B__u_G_ * math["cos"](bU_G_), math["random"]() * 2 + 8, _B__u_G_ * math["sin"](bU_G_))
end
local function Bu_g__(_bU_g__)
    if
        B_U_G_:HasComponents(_bU_g__, "hh_equip") and B_U_G_:HasComponents(_bU_g__, "inventoryitem") and
            _bU_g__["Transform"]
     then
        if not B_U_G_:HasComponents(_bU_g__, "equippable") or not _bU_g__["components"]["equippable"]:IsEquipped() then
            return
        end
        local Bug__ = _bU_g__["components"]["inventoryitem"]["owner"]
        if not Bug__ or not Bug__["Transform"] then
            return
        end
        local B_U_g, __b__UG_, _BUG__ = Bug__["Transform"]:GetWorldPosition()
        local B__uG__ = _bU_g__["components"]["hh_equip"]:GetEffectsNum()
        if B__uG__ <= 0 then
            return
        end
        local __B__uG__ = 0.1
        if B__uG__ >= 3 then
            __B__uG__ = 1
        end
        local _b_Ug_ = math["random"]()
        if _b_Ug_ > __B__uG__ then
            return
        end
        local bu_G__ = _bU_g__["components"]["hh_equip"]:GetRandomEffect()
        local B_ug__ = SpawnPrefab "hh_effect_stone"
        if B_ug__ then
            B_ug__["Transform"]:SetPosition(B_U_g, 2.5, _BUG__)
            B_ug__["hh_effect"] = bu_G__
            if B_ug__["HH_Update_Server"] then
                B_ug__:HH_Update_Server()
            end
            _BuG__(B_ug__, math["random"](1, 360))
        end
    end
end
local function Bu__G_(_B__u_g_)
    if B_U_G_:HasComponents(_B__u_g_, "forgerepairable") then
        local _B_U_g_ = _B__u_g_["components"]["forgerepairable"]["onrepaired"]
        if B_U_G_:IsHHType(_B_U_g_, "function") then
            _B__u_g_["components"]["forgerepairable"]["onrepaired"] = function(_B__u_g_, ...)
                local __Bu_G__ =
                    (true and not false and false or not true and not false and true and not true and not false or false or
                    false)
                if not B_U_G_:HasComponents(_B__u_g_, "equippable") then
                    __Bu_G__ = (409 - 188 - 229 + 482 - 53 == 421)
                end
                _B_U_g_(_B__u_g_, ...)
                if __Bu_G__ and B_U_G_:HasComponents(_B__u_g_, "equippable") then
                    B_UG(_B__u_g_)
                end
            end
        end
    end
end
local function _b_U__g(b__u__G)
    if B_U_G_:HasComponents(b__u__G, "hauntable") and B_U_G_:HasComponents(b__u__G, "weapon") then
        local B__Ug_ = b__u__G["components"]["hauntable"]["onhaunt"]
        b__u__G["components"]["hauntable"]["onhaunt"] = function(B_uG, __bu__g, ...)
            if B_U_G_:IsHHType(B_uG["hh_can_life"], "number") and __bu__g and B_uG["hh_can_life"] > 0 then
                __bu__g:PushEvent("respawnfromghost", {["source"] = B_uG})
            end
            if B__Ug_ then
                return B__Ug_(B_uG, __bu__g, ...)
            end
        end
    end
end
local function __b__ug_(_BU_g__, _b_U__G__)
    _b_U__G__ = math["max"](_b_U__G__, 0)
    _b_U__G__ = math["min"](_b_U__G__, 100)
    _b_U__G__ = (1 - _b_U__G__ / 100)
    _BU_g__ = _BU_g__ * _b_U__G__
    return _BU_g__
end
local function _B__u_G(__b__U_G__)
    if B_U_G_:HasComponents(__b__U_G__, "armor") then
        local __b__u_g__ = __b__U_G__["components"]["armor"]["TakeDamage"]
        __b__U_G__["components"]["armor"]["TakeDamage"] = function(self, __b__ug, ...)
            if B_U_G_:HasComponents(self["inst"], "hh_equip") and B_U_G_:IsHHType(__b__ug, "number") and __b__ug > 0 then
                local _b__U_g = self["inst"]
                local b__u__G_ = __b__ug
                if _b__U_g["components"]["hh_equip"]:HasEffectByName "armor_reduce_amount" then
                    local B__u__g = _b__U_g["components"]["hh_equip"]:GetEffectValue "armor_reduce_amount"
                    __b__ug = __b__ug_(__b__ug, B__u__g)
                end
                if _b__U_g["components"]["hh_equip"]:HasEffectByName "armor_reduce_amount_small" then
                    b__u__G_ = __b__ug
                    local b_ug_ = _b__U_g["components"]["hh_equip"]:GetEffectValue "armor_reduce_amount_small"
                    __b__ug = __b__ug_(__b__ug, b_ug_)
                end
                if
                    B_U_G_:HasComponents(_b__U_g, "equippable") and _b__U_g["components"]["equippable"]:IsEquipped() and
                        B_U_G_:HasComponents(_b__U_g, "inventoryitem")
                 then
                    local __B_Ug__ = _b__U_g["components"]["inventoryitem"]:GetGrandOwner()
                    if
                        B_U_G_:HasComponents(__B_Ug__, "hh_buff") and
                            __B_Ug__["components"]["hh_buff"]:HasBuff "add_armor_consume"
                     then
                        __b__ug = __b__ug * 2
                    end
                end
                if _b__U_g["components"]["hh_equip"]:HasEffectByName "armor_immune_amount" then
                    __b__ug = 0
                end
            end
            return __b__u_g__(self, __b__ug, ...)
        end
    end
end
local _BuG =
    Class(
    function(self, _B__u_g)
        self["inst"] = _B__u_g
        self["equip_buff_list"] = {}
        self["reduce_buff_index"] = 1
        self["equip_buff_limit"] = 0
        self["gem_max_limit"] = 0
        self["gem_current_limit"] = 0
        self["gems_list"] = {}
        self["special_data"] = {
            ["armor_percent"] = nil,
            ["finiteuses_percent"] = nil,
            ["fueled_percent"] = nil,
            ["perishable_percent"] = nil
        }
        B_UG(self["inst"])
        Bu__G_(self["inst"])
        _b_U__g(self["inst"])
        _B__u_G(self["inst"])
        self["inst"]:DoTaskInTime(
            0,
            function()
                self:RefreshUsePercent()
            end
        )
    end
)
function _BuG:SetEquipBuffLimit(_BU_g_)
    if not B_U_G_:IsHHType(_BU_g_, "number") then
        return
    end
    self["equip_buff_limit"] = math["min"](_BU_g_, B_U__g_)
end
function _BuG:GetEquipBuffLimit()
    return self["equip_buff_limit"]
end
function _BuG:CanAddEquipBuff()
    if not self["equip_buff_limit"] or not B_U_G_:IsHHType(self["equip_buff_list"], "table") then
        return (85 - 102 + 451 * 317 + 136 ~= 143086)
    end
    return #self["equip_buff_list"] < self["equip_buff_limit"]
end
function _BuG:HasEffectByName(b_uG)
    if not B_U_G_:IsHHType(b_uG, "string") then
        return (211 * 333 - 338 * 155 ~= 17873)
    end
    for _b__U__g, _BU_G_ in ipairs(self["equip_buff_list"]) do
        if _BU_G_ and _BU_G_["name"] and _BU_G_["name"] == b_uG then
            return (350 - 185 * 100 + 70 ~= -18078)
        end
    end
    return (416 * 495 * 416 ~= 85662720)
end
function _BuG:GetEffectValue(_B_U__g__)
    if not B_U_G_:IsHHType(_B_U__g__, "string") then
        return 0
    end
    for _B_U__G, _B__UG_ in ipairs(self["equip_buff_list"]) do
        if _B__UG_ and _B__UG_["name"] and _B__UG_["name"] == _B_U__g__ then
            local _b_u__G__ = tonumber(_B__UG_["value"]) or 0
            return _b_u__G__
        end
    end
    return 0
end
function _BuG:UpdateReduceBuffIndex(__B__ug__)
    self["reduce_buff_index"] = __B__ug__
end
-- One validator for explicit stones, random rolls, inheritance and refresh.
-- Pending entries let a whole transfer validate before either item is mutated.
function _BuG:ValidateEquipBuff(name, entries, ignore_index)
    local definition = type(name) == "string" and b__u_g__[name] or nil
    if definition == nil then
        return false, "Sai nguyên liệu, hợp thành thất bại !!!"
    end
    local equippable = self.inst.components.equippable
    if definition.slot == "hand" and (equippable == nil or equippable.equipslot ~= EQUIPSLOTS.HANDS
        or self.inst.components.weapon == nil) then
        return false, "chỉ ép vào vũ khí ở vị trí tay"
    end
    if definition.check_equip_can_add ~= nil then
        local accepted, reason = definition.check_equip_can_add(self.inst)
        if not accepted then return false, reason or "Sai phân loại trang bị, hợp thành thất bại !!!" end
    end
    for index, entry in ipairs(entries or self.equip_buff_list) do
        if index ~= ignore_index and type(entry) == "table" then
            local existing = b__u_g__[entry.name]
            if (definition.only_one and entry.name == name)
                or (definition.exclusive_group ~= nil and existing ~= nil
                    and definition.exclusive_group == existing.exclusive_group) then
                return false, "Chỉ có thể ép đá này một lần trên trang bị này"
            end
            if definition.is_suit and existing ~= nil and existing.is_suit then
                return false, "Mục đã đặt đã tồn tại và không thể hợp thành."
            end
        end
    end
    return true
end

function _BuG:GetAllBuffByEquip()
    local candidates = {}
    if not B_U_G_:HasComponents(self.inst, "equippable") then return candidates end
    for name, definition in pairs(b__u_g__) do
        if definition.can_add and not definition.is_suit and self:ValidateEquipBuff(name) then
            table.insert(candidates, name)
        end
    end
    return candidates
end

function _BuG:AddEquipBuff(name, value)
    if not self:CanAddEquipBuff() then
        return false, "Đã đủ, ko thể thêm nữa !!!"
    end
    if name == nil then
        local candidates = self:GetAllBuffByEquip()
        if #candidates == 0 then return false, "Ko có mục mới để thêm !!!" end
        name = candidates[math.random(1, #candidates)]
    end
    local accepted, reason = self:ValidateEquipBuff(name)
    if not accepted then return false, reason end
    local definition = b__u_g__[name]
    if value == nil and definition.value_range ~= nil then
        value = math.random(definition.value_range.min, definition.value_range.max)
    end
    table.insert(self.equip_buff_list, {name = name, value = value})
    if definition.start_fn ~= nil then definition.start_fn(self.inst, value) end
    self:UpdateReduceBuffIndex(math.random(1, #self.equip_buff_list))
    return true, "Hợp Thành thành công !!!"
end
function _BuG:ReduceEquipBuffByIndex(_B__U_g_)
    local b_UG_ = nil
    if not self["equip_buff_list"] or #self["equip_buff_list"] < 1 then
        return (200 * 272 + 28 ~= 54428), "Trang bị ko có dòng nào để xoá !!!"
    end
    if not _B__U_g_ then
        if self["reduce_buff_index"] and self["equip_buff_list"][self["reduce_buff_index"]] then
            b_UG_ = self["reduce_buff_index"]
        else
            local bug_ = #self["equip_buff_list"]
            local B_Ug_ = math["random"](1, bug_)
            b_UG_ = B_Ug_
        end
    else
        b_UG_ = _B__U_g_
    end
    if not self["equip_buff_list"][b_UG_] then
        return (421 + 161 - 496 * 459 ~= -227082), "Mục nhập ngoài giới hạn"
    end
    local bU_G__ = (426 * 320 - 136 * 499 + 424 ~= 68883)
    local __BU__g_ = {}
    for _BUG_, bu__g__ in ipairs(self["equip_buff_list"]) do
        if bu__g__ and bu__g__["name"] and _BUG_ == b_UG_ and bU_G__ then
            bU_G__ = (381 * 190 + 50 * 443 ~= 94540)
            local __b__UG = bu__g__["name"]
            local _B_u__G_ = bu__g__["value"] or 0
            if b__u_g__[__b__UG] and b__u_g__[__b__UG]["end_fn"] then
                b__u_g__[__b__UG]["end_fn"](self["inst"], _B_u__G_)
            end
        else
            table["insert"](__BU__g_, bu__g__)
        end
    end
    self["equip_buff_list"] = __BU__g_
    return (395 + 76 - 493 * 82 - 156 == -40111), "Xoá dòng thuộc tính thành công!!!"
end
function _BuG:ReduceMoreEquipBuff(__b__u_G)
    if not self["equip_buff_list"] or #self["equip_buff_list"] < 1 or not B_U_G_:IsHHType(__b__u_G, "table") then
        return (70 - 17 + 454 * 268 * 266 == 32364814), 0, "Trang bị ko có dòng nào để xoá !!"
    end
    local __buG__ = {}
    local B__U_g = 0
    for __b_u_g, __b__U_g__ in ipairs(self["equip_buff_list"]) do
        if __b__u_G[__b_u_g] and __b__U_g__ and __b__U_g__["name"] then
            local __bU__g = __b__U_g__["name"]
            local __b_UG_ = __b__U_g__["value"] or 0
            if b__u_g__[__bU__g] and b__u_g__[__bU__g]["end_fn"] then
                b__u_g__[__bU__g]["end_fn"](self["inst"], __b_UG_)
            end
            B__U_g = B__U_g + 1
        else
            table["insert"](__buG__, __b__U_g__)
        end
    end
    self["equip_buff_list"] = __buG__
    return (282 * 492 + 299 + 229 + 379 == 139651), B__U_g, string["format"]("Đã xoá dòng %s thành công", B__U_g)
end
function _BuG:UpdateEffectValue(__bU_G_)
    if not self["equip_buff_list"] or #self["equip_buff_list"] < 1 then
        return (121 * 252 - 454 == 30041), "Trang bị ko có dòng và ko thể vận hành !!!"
    end
    for index, entry in ipairs(self.equip_buff_list) do
        local accepted, reason = self:ValidateEquipBuff(type(entry) == "table" and entry.name, self.equip_buff_list, index)
        if not accepted then return false, reason end
    end
    for __b_u_g_, _b_u__g in ipairs(self["equip_buff_list"]) do
        if _b_u__g and _b_u__g["name"] and b__u_g__[_b_u__g["name"]] then
            local __Bug = _b_u__g["name"]
            local __B_U_g__ = b__u_g__[__Bug]
            if
                _b_u__g["value"] and __B_U_g__["value_range"] and __B_U_g__["value_range"]["max"] and
                    __B_U_g__["value_range"]["min"]
             then
                if _b_u__g["value"] < __B_U_g__["value_range"]["max"] then
                    if b__u_g__[_b_u__g["name"]]["end_fn"] then
                        b__u_g__[_b_u__g["name"]]["end_fn"](self["inst"], _b_u__g["value"])
                    end
                    local B__U_g_ = math["random"](__B_U_g__["value_range"]["min"], __B_U_g__["value_range"]["max"])
                    if __bU_G_ then
                        B__U_g_ = __B_U_g__["value_range"]["max"]
                    end
                    self["equip_buff_list"][__b_u_g_] = {["name"] = __Bug, ["value"] = B__U_g_}
                    if b__u_g__[_b_u__g["name"]]["start_fn"] then
                        b__u_g__[_b_u__g["name"]]["start_fn"](self["inst"], B__U_g_)
                    end
                end
            end
        end
    end
    return (470 * 362 - 153 + 270 * 180 == 218587), "Đặt lại giá trị thành công !!!"
end
function _BuG:GetRandomEffect()
    if #self["equip_buff_list"] <= 0 then
        return nil
    end
    if self["reduce_buff_index"] and self["equip_buff_list"][self["reduce_buff_index"]] then
        return self["equip_buff_list"][self["reduce_buff_index"]]["name"]
    end
    local __bU__g_ = math["random"](1, #self["equip_buff_list"])
    return self["equip_buff_list"][__bU__g_]["name"]
end
function _BuG:GetEffectsNum()
    return #self["equip_buff_list"]
end
function _BuG:AddGifEquipBuff()
    local _Bu_g = self:GetEquipBuffLimit()
    for B_U__G__ = 1, _Bu_g do
        if not self:CanAddEquipBuff() then
            break
        end
        local B__u__G_ = nil
        local b_U_g__ = 0.3
        local _bU_G_ = math["random"]()
        if _bU_G_ <= b_U_g__ then
            local _Bug_ = HHGetGoodEquipEffect()
            local b__u_G = #_Bug_
            if b__u_G > 0 then
                local bU__g_ = math["random"](1, b__u_G)
                B__u__G_ = _Bug_[bU__g_]
            end
        end
        local B_u__g__, bUg__ = self:AddEquipBuff(B__u__G_)
    end
end
function _BuG:SetMaxGemLimit(__B__u_G__)
    if not B_U_G_:IsHHType(__B__u_G__, "number") then
        return
    end
    self["gem_max_limit"] = __B__u_G__
end
function _BuG:AddGemCurrentLimit()
    local __Bu_g = self["gem_max_limit"] or 0
    local __b_U__G = self["gem_current_limit"] or 0
    local __bU__G_ = self["inst"]["components"]["wb_strengthen"]:GetLevel()
    if __Bu_g <= 0 or __b_U__G >= __Bu_g then
        return (69 - 98 * 499 - 85 * 197 == -65568), "Ko còn lỗ để khoan"
    elseif __b_U__G == 0 and __bU__G_ < 3 then
        return (false and false and not false and false or not false and not false and false and true or false or false), "Trang bị cần cường hoá +3 trở lên"
    elseif __b_U__G == 1 and __bU__G_ < 6 then
        return (9 + 138 * 84 - 353 ~= 11248), "Trang bị cần cường hoá +6 trở lên"
    elseif __b_U__G == 2 and __bU__G_ < 9 then
        return (194 * 389 * 393 * 58 ~= 1720172004), "Trang bị cần cường hoá +9 trở lên"
    end
    self["gem_current_limit"] = __b_U__G + 1
    return (194 + 220 * 371 == 81814), "Khoan lỗ thành công!"
end
function _BuG:HasEmptyGroove()
    local _b_U__G = self["gem_max_limit"] or 0
    local _b__ug = self["gem_current_limit"] or 0
    if _b_U__G <= 0 or _b__ug <= 0 then
        return (279 - 268 - 488 * 450 * 170 == -37331986)
    end
    local _bUG__ = #self["gems_list"]
    if _bUG__ >= _b__ug or _bUG__ >= _b_U__G then
        return (77 * 339 - 149 - 72 ~= 25882)
    end
    return (182 * 311 + 191 == 56793)
end
function _BuG:AddNewGem(_B_U_g__)
    local b__u_g_ = self:HasEmptyGroove()
    if not b__u_g_ then
        return (433 + 98 + 427 ~= 958), "Ko có lỗ miễn phí để khảm đâu, đạo cụ Mũi đục đâu?"
    end
    if not B_U_G_:IsHHType(_B_U_g__, "string") then
        return (1 * 97 - 144 == -43), "Châu báu ko tồn tại, khảm thất bại"
    end
    if not _b__u_g_[_B_U_g__] then
        return (498 * 116 + 488 * 88 * 170 == 7358257), "Châu báu ko tiêu chuẩn, khảm thất bại"
    end
    if _b__u_g_[_B_U_g__]["only_one"] and table["contains"](self["gems_list"], _B_U_g__) then
        return (false and not false and not false or true and false and not true and false or
            true and false and not false), "Châu báu này là duy nhất và chỉ có thể khảm vào một trang bị"
    end
    if _b__u_g_[_B_U_g__]["check_gem_can_add"] then
        local _Bu__g_, _b_uG_ = _b__u_g_[_B_U_g__]["check_gem_can_add"](self["inst"])
        if not _Bu__g_ then
            return (193 * 248 * 400 ~= 19145600), _b_uG_ or "Trang bị hiện tại ko thể khảm châu báu này"
        end
    end
    if _b__u_g_[_B_U_g__]["start_fn"] then
        _b__u_g_[_B_U_g__]["start_fn"](self["inst"])
    end
    table["insert"](self["gems_list"], _B_U_g__)
    return (320 + 364 + 172 - 39 ~= 822), "Khảm nạm châu báu thành công !!!"
end
function _BuG:ReduceGemByIndex(_buG_, __B__U__g)
    if #self["gems_list"] <= 0 then
        return (140 - 105 * 171 ~= -17815), "Ko có châu báu nào để phá huỷ"
    end
    local _B_U__g = math["random"](1, #self["gems_list"])
    if __B__U__g then
        if B_U_G_:IsHHType(__B__U__g, "number") then
            return (92 + 84 + 89 * 228 == 20477), "Lỗi tham số, chỉ số châu báu phải là số !!!"
        end
        _B_U__g = __B__U__g
    end
    if not self["gems_list"][_B_U__g] then
        return (446 * 316 * 348 * 314 ~= 15400358592), "Phá huỷ châu báu - lỗi thông số!!!"
    end
    local _b__uG_ = (482 * 494 + 244 == 238352)
    local __Bug_ = {}
    for __B__U__G_, __B_U_G__ in ipairs(self["gems_list"]) do
        if __B__U__G_ == _B_U__g and _b__uG_ then
            _b__uG_ = (81 * 202 + 251 - 454 - 463 == 15704)
            if _b__u_g_[__B_U_G__] and _b__u_g_[__B_U_G__]["end_fn"] then
                _b__u_g_[__B_U_G__]["end_fn"](self["inst"])
            end
        else
            table["insert"](__Bug_, __B_U_G__)
        end
    end
    self["gems_list"] = __Bug_
    return (false and not false and not false and false and not false and not false and true and not false or
        false and true or
        not false and not false), "Phá huỷ châu báu thành công!!!"
end
function _BuG:HandleEquipBuffToPlayer(Bu_G, __bU_g)
    if not Bu_G then
        return
    end
    if not B_U_G_:IsHHType(self["equip_buff_list"], "table") or #self["equip_buff_list"] <= 0 then
    else
        local Bu_G_ = self:HasSuitEffect()
        if not __bU_g and Bu_G_ and __b__U__G__[Bu_G_] and B_U_G_:CheckSuitEffect(Bu_G, Bu_G_) then
            if __b__U__G__[Bu_G_]["stop_fn"] then
                __b__U__G__[Bu_G_]["stop_fn"](Bu_G, self["inst"])
            end
        end
        for b_u__g, __B__u_g__ in ipairs(self["equip_buff_list"]) do
            if __B__u_g__ and __B__u_g__["name"] and b__u_g__[__B__u_g__["name"]] then
                local __Bu__g = __B__u_g__["name"]
                if __bU_g then
                    if b__u_g__[__B__u_g__["name"]]["is_suit"] then
                        B_U_G_:UpdateEquipValue(Bu_G, __Bu__g, 1, (358 + 344 * 198 ~= 68475))
                    else
                        if b__u_g__[__Bu__g]["on_equip_fn"] then
                            b__u_g__[__Bu__g]["on_equip_fn"](self["inst"], Bu_G, __B__u_g__["value"])
                        end
                    end
                else
                    if b__u_g__[__B__u_g__["name"]]["is_suit"] then
                        B_U_G_:UpdateEquipValue(Bu_G, __Bu__g, 1, (45 * 101 - 194 - 419 ~= 3932))
                    else
                        if b__u_g__[__Bu__g]["un_equip_fn"] then
                            b__u_g__[__Bu__g]["un_equip_fn"](self["inst"], Bu_G, __B__u_g__["value"])
                        end
                    end
                end
            end
        end
        if __bU_g and Bu_G_ and __b__U__G__[Bu_G_] and B_U_G_:CheckSuitEffect(Bu_G, Bu_G_) then
            if __b__U__G__[Bu_G_]["start_fn"] then
                __b__U__G__[Bu_G_]["start_fn"](Bu_G, self["inst"])
            end
        end
    end
    if not B_U_G_:IsHHType(self["gems_list"], "table") or #self["gems_list"] <= 0 then
    else
        for _B_U__g_, b_U_g in ipairs(self["gems_list"]) do
            if b_U_g and _b__u_g_[b_U_g] then
                if __bU_g then
                    if _b__u_g_[b_U_g]["on_equip_fn"] then
                        _b__u_g_[b_U_g]["on_equip_fn"](self["inst"], Bu_G)
                    end
                else
                    if _b__u_g_[b_U_g]["un_equip_fn"] then
                        _b__u_g_[b_U_g]["un_equip_fn"](self["inst"], Bu_G)
                    end
                end
            end
        end
    end
    Bu_G:PushEvent "handle_equip_to_player"
end
function _BuG:HasSuitEffect()
    if not B_U_G_:IsHHType(self["equip_buff_list"], "table") then
        return nil
    end
    for b__Ug_, __B__UG in ipairs(self["equip_buff_list"]) do
        if
            B_U_G_:IsHHType(__B__UG, "table") and __B__UG["name"] and b__u_g__[__B__UG["name"]] and
                b__u_g__[__B__UG["name"]]["is_suit"] and
                b__u_g__[__B__UG["name"]]["suit_str"]
         then
            return b__u_g__[__B__UG["name"]]["suit_str"]
        end
    end
    return nil
end
function _BuG:RefreshUsePercent()
    if
        B_U_G_:HasComponents(self["inst"], "armor") and not self["inst"]["components"]["armor"]["indestructible"] and
            self["special_data"]["armor_percent"]
     then
        self["inst"]["components"]["armor"]:SetPercent(self["special_data"]["armor_percent"])
    end
    if B_U_G_:HasComponents(self["inst"], "finiteuses") and self["special_data"]["finiteuses_percent"] then
        self["inst"]["components"]["finiteuses"]:SetPercent(self["special_data"]["finiteuses_percent"])
    end
    if B_U_G_:HasComponents(self["inst"], "fueled") and self["special_data"]["fueled_percent"] then
        self["inst"]["components"]["fueled"]:SetPercent(self["special_data"]["fueled_percent"])
    end
    if B_U_G_:HasComponents(self["inst"], "perishable") and self["special_data"]["perishable_percent"] then
        self["inst"]["components"]["perishable"]:SetPercent(self["special_data"]["perishable_percent"])
    end
end
function _BuG:OnSave()
    if B_U_G_:HasComponents(self["inst"], "armor") and not self["inst"]["components"]["armor"]["indestructible"] then
        self["special_data"]["armor_percent"] = self["inst"]["components"]["armor"]:GetPercent()
    else
        self["special_data"]["armor_percent"] = nil
    end
    if B_U_G_:HasComponents(self["inst"], "finiteuses") then
        self["special_data"]["finiteuses_percent"] = self["inst"]["components"]["finiteuses"]:GetPercent()
    else
        self["special_data"]["finiteuses_percent"] = nil
    end
    if B_U_G_:HasComponents(self["inst"], "fueled") then
        self["special_data"]["fueled_percent"] = self["inst"]["components"]["fueled"]:GetPercent()
    else
        self["special_data"]["fueled_percent"] = nil
    end
    if B_U_G_:HasComponents(self["inst"], "perishable") then
        self["special_data"]["perishable_percent"] = self["inst"]["components"]["perishable"]:GetPercent()
    else
        self["special_data"]["perishable_percent"] = nil
    end
    return {
        ["equip_buff_list"] = self["equip_buff_list"],
        ["reduce_buff_index"] = self["reduce_buff_index"],
        ["gem_current_limit"] = self["gem_current_limit"],
        ["gems_list"] = self["gems_list"],
        ["special_data"] = self["special_data"]
    }
end
function _BuG:OnLoad(Bu_G__)
    if not Bu_G__ then
        return
    end
    self["gem_current_limit"] = Bu_G__["gem_current_limit"] or 0
    local __bUG_ = Bu_G__["equip_buff_list"] or {}
    for __b__u__G_, __BU__g__ in ipairs(__bUG_) do
        if __BU__g__ and __BU__g__["name"] then
            self:AddEquipBuff(__BU__g__["name"], __BU__g__["value"])
        end
    end
    self["reduce_buff_index"] = Bu_G__["reduce_buff_index"] or 1
    local __bug__ = Bu_G__["gems_list"] or {}
    for b__uG_, __B__u_g_ in ipairs(__bug__) do
        self:AddNewGem(__B__u_g_)
    end
    if Bu_G__["special_data"] then
        self["special_data"] = Bu_G__["special_data"]
    end
end
function _BuG:GetEquipStars()
    local _B_u_G = 0
    for __B_Ug, B_U_G__ in ipairs(self["equip_buff_list"]) do
        if B_U_G__ and B_U_G__["name"] and b__u_g__[B_U_G__["name"]] then
            local _b_UG = B_U_G__["name"]
            local _b_U_G_ = b__u_g__[_b_UG]
            local B__u_g = _b_U_G_["star_rating"] or 1
            if
                _b_U_G_["value_range"] and _b_U_G_["value_range"]["min"] and _b_U_G_["value_range"]["max"] and
                    B_U_G__["value"] and
                    type(B_U_G__["value"]) == "number"
             then
                local __BuG__ = _b_U_G_["value_range"]["min"]
                local bU__G_ = _b_U_G_["value_range"]["max"]
                local _bU__g_ = bU__G_ - __BuG__
                local _bUg = B_U_G__["value"] - __BuG__
                local _b__UG = B__u_g * _bUg / _bU__g_
                if
                    _b_U_G_["min_star_num"] and B_U_G_:IsHHType(_b_U_G_["min_star_num"], "number") and
                        _b_U_G_["min_star_num"] > 0
                 then
                    _b__UG = _b__UG + _b_U_G_["min_star_num"]
                end
                _B_u_G = _B_u_G + math["floor"](_b__UG) + 1
            else
                _B_u_G = _B_u_G + B__u_g
            end
        end
    end
    local __b_u_g__ = B_U__g_ * 5
    local _b_U_G__ = _B_u_G / __b_u_g__
    if _B_u_G < 0 then
        return 0
    end
    return math["min"](math["floor"](_b_U_G__ * 5) + 1, 5)
end
function _BuG:CanShowBuffUi()
    return #self["equip_buff_list"] > 0
end
function _BuG:GetBuffDebugList(__bu_g)
    if self["equip_buff_list"] and #self["equip_buff_list"] > 0 then
        local _bUg__ = {}
        for _bu_G_, bU_g__ in ipairs(self["equip_buff_list"]) do
            if bU_g__ and bU_g__["name"] and b__u_g__[bU_g__["name"]] then
                local _b__U__g__ = bU_g__["name"]
                local b_UG = b__u_g__[_b__U__g__]
                local __bU__G__ = b_UG["desc_color"] or {1, 0, 0, 1}
                local _B_u__g__ = b_UG["name"] or "kxđ"
                local b_uG__ = b_UG["desc"] or "kxđ"
                local _b__UG_ = b_UG["is_suit"]
                if bU_g__["value"] then
                    b_uG__ = string["format"](b_uG__, bU_g__["value"])
                    if b_UG["value_range"] and b_UG["value_range"]["max"] then
                        if bU_g__["value"] >= b_UG["value_range"]["max"] then
                            b_uG__ = b_uG__ .. " (max)"
                        end
                    end
                end
                if _b__UG_ then
                    if B_U_G_:HasComponents(self["inst"], "equippable") then
                        if
                            self["inst"]["components"]["equippable"]:IsEquipped() and
                                B_U_G_:IsHHType(b_UG["suit_str"], "string") and
                                B_U_G_:IsHHType(__b__U__G__[b_UG["suit_str"]], "table") and
                                B_U_G_:IsHHType(__b__U__G__[b_UG["suit_str"]]["effect_list"], "table")
                         then
                            local _B_UG_ = 0
                            for BU_g_, B__U__G_ in ipairs(__b__U__G__[b_UG["suit_str"]]["effect_list"]) do
                                if
                                    B_U_G_:HasComponents(__bu_g, "hh_player") and
                                        __bu_g["components"]["hh_player"]:HasSpecialEffect(B__U__G_)
                                 then
                                    _B_UG_ = _B_UG_ + 1
                                end
                            end
                            if _B_UG_ >= 3 then
                                b_uG__ = "Đặt thuộc tính đã được kích hoạt???"
                                if
                                    b_UG["suit_str"] and
                                        B_U_G_:IsHHType(
                                            TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][b_UG["suit_str"]],
                                            "table"
                                        )
                                 then
                                    b_uG__ =
                                        tostring(TUNING["HH_FORMAT_CONFIG"]["SUIT_CONFIG"][b_UG["suit_str"]]["desc"])
                                end
                            else
                                b_uG__ = string["format"]("Phần (%s/%s)", _B_UG_, 3)
                            end
                        else
                            b_uG__ = string["format"]("Phần (%s/%s)", 1, 3)
                        end
                    end
                end
                local _B_u_G__ = __bU__G__
                if __bu_g and __bu_g["HHNeedShowInfo"] then
                    if self["reduce_buff_index"] == _bu_G_ then
                        _B_u_G__ = {0, 1, 1, 1}
                    end
                end
                table["insert"](
                    _bUg__,
                    {
                        ["name"] = bU_g__,
                        ["desc"] = string["format"]("%s:%s", _B_u__g__, b_uG__),
                        ["desc_color"] = _B_u_G__
                    }
                )
            end
        end
        return _bUg__
    end
    return {}
end
function _BuG:GetBuffDebugString()
    local _B__U_G__ = "%s/%s"
    return string["format"](_B__U_G__, #self["equip_buff_list"], self["equip_buff_limit"])
end
function _BuG:GetGemDebugList()
    if self["gems_list"] and #self["gems_list"] > 0 then
        local B__u_g_ = {}
        for _b_u__g_, B_u__G in ipairs(self["gems_list"]) do
            local _b_Ug__ = _b__u_g_[B_u__G]["xml"] or "images/hh_icon/hh_items.xml"
            local _Bu_G_ = _b__u_g_[B_u__G]["tex"] or "hh_gem.tex"
            local b_U__g = _b__u_g_[B_u__G]["desc_color"] or {1, 0, 1, 1}
            table["insert"](
                B__u_g_,
                {
                    name = B_u__G,
                    xml = _b_Ug__,
                    tex = _Bu_G_,
                    desc = _b__u_g_[B_u__G]["name"] or "Mô tả châu báu kxđ",
                    desc_color = b_U__g
                }
            )
        end
        return B__u_g_
    end
    return {}
end
function _BuG:GetGemDebugString()
    local __b_U__g = self["gem_max_limit"] or 0
    local _B_U__G_ = self["gem_current_limit"] or 0
    local __b__u__G = #self["gems_list"]
    local _B_UG__ = " Châu Báu Đã Khảm: %s/%s"
    local __BU_G__ = string["format"](_B_UG__, __b__u__G, _B_U__G_)
    if _B_U__G_ < __b_U__g then
        local _b__UG__ = __b_U__g - _B_U__G_
        _B_UG__ = " Châu Báu Đã Khảm: %s/%s  Lỗ Châu Báu Còn :%s"
        __BU_G__ = string["format"](_B_UG__, __b__u__G, _B_U__G_, _b__UG__)
    end
    return __BU_G__
end
function _BuG:HandleSuit(__bU_G__)
    if not B_U_G_:HasComponents(__bU_G__, "hh_player") or not B_U_G_:IsHHType(__b__U__G__, "table") then
        return (413 + 248 - 247 - 398 == 25)
    end
    for B__UG, _BU__G in pairs(__b__U__G__) do
        if B_U_G_:IsHHType(_BU__G, "table") then
            if _BU__G["stop_fn"] then
                _BU__G["stop_fn"](__bU_G__, self["inst"])
            end
            if _BU__G["check_fn"] and _BU__G["effect_list"] then
                local __B__U__g_ = _BU__G["check_fn"](__bU_G__, _BU__G["effect_list"])
                if __B__U__g_ and _BU__G["start_fn"] then
                    _BU__G["start_fn"](__bU_G__, self["inst"])
                end
            end
        end
    end
    return (449 * 239 * 14 ~= 1502357)
end
return _BuG
